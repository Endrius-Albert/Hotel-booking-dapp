//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//A hotel booking contract with escrow.
//The guest pays, the contract holds the money, and the rules decide who gets it.
contract HotelBooking {
   
    enum Status { Booked, CheckedIn, Cancelled, NoShow }

    struct Room {
        uint256 id;
        string name;
        uint256 pricePerNight; //in wei
        bool available;        //the hotel can open or close the room
        bool isBooked;         //true while the room has an active booking
    }

    struct Booking {
        uint256 id;
        uint256 roomId;
        address guest;
        uint256 checkInDate;   //Unix timestamp
        uint256 nights;
        uint256 amountPaid;    //held in the contract until the booking ends
        Status status;
    }

    address public hotel;      //the account that deploys the contract
    uint256 public roomCount;
    uint256 public bookingCount;

    //Cancellation and no-show rules
    uint256 public constant FREE_CANCELLATION_WINDOW = 48 hours;
    uint256 public constant NO_SHOW_WINDOW = 24 hours;

    //Look up rooms and bookings by ID
    mapping(uint256 => Room) private rooms;
    mapping(uint256 => Booking) private bookings;

    //Each event is a public record of what happened
    event RoomAdded(uint256 indexed roomId, string name, uint256 pricePerNight);
    event RoomAvailabilityChanged(uint256 indexed roomId, bool available);
    event RoomBooked(
        uint256 indexed bookingId,
        uint256 indexed roomId,
        address indexed guest,
        uint256 checkInDate,
        uint256 nights,
        uint256 amountPaid
    );
    event BookingCancelled(uint256 indexed bookingId, address indexed guest, uint256 refundAmount, uint256 hotelAmount);
    event CheckedIn(uint256 indexed bookingId, uint256 amountReleased);
    event NoShowMarked(uint256 indexed bookingId, uint256 amountReleased);

    //msg.sender is verified by the caller's signature (ECDSA)
    modifier onlyHotel() {
        require(msg.sender == hotel, "Only the hotel can do this");
        _;
    }

    modifier roomExists(uint256 roomId) {
        require(roomId > 0 && roomId <= roomCount, "Room does not exist");
        _;
    }

    modifier bookingExists(uint256 bookingId) {
        require(bookingId > 0 && bookingId <= bookingCount, "Booking does not exist");
        _;
    }

    //The deployer becomes the hotel
    constructor() {
        hotel = msg.sender;
    }

    //Hotel actions

    function addRoom(string calldata name, uint256 pricePerNight) external onlyHotel {
        require(bytes(name).length > 0, "Room name is required");
        require(pricePerNight > 0, "Price must be greater than zero");

        roomCount++;
        rooms[roomCount] = Room(roomCount, name, pricePerNight, true, false);

        emit RoomAdded(roomCount, name, pricePerNight);
    }

    function setRoomAvailability(uint256 roomId, bool available)
        external
        onlyHotel
        roomExists(roomId)
    {
        rooms[roomId].available = available;
        emit RoomAvailabilityChanged(roomId, available);
    }

    function checkIn(uint256 bookingId) external onlyHotel bookingExists(bookingId) {
        Booking storage booking = bookings[bookingId];

        require(booking.status == Status.Booked, "Booking is not active");
        require(block.timestamp >= booking.checkInDate, "Too early to check in");

        //The status changes before the money moves, so it can't be paid twice
        booking.status = Status.CheckedIn;
        rooms[booking.roomId].isBooked = false;

        _send(hotel, booking.amountPaid);
        emit CheckedIn(bookingId, booking.amountPaid);
    }

    //The guest didn't arrive within 24h of the check-in date
    function markNoShow(uint256 bookingId) external onlyHotel bookingExists(bookingId) {
        Booking storage booking = bookings[bookingId];

        require(booking.status == Status.Booked, "Booking is not active");
        require(
            block.timestamp >= booking.checkInDate + NO_SHOW_WINDOW,
            "No-show window has not passed"
        );

        booking.status = Status.NoShow;
        rooms[booking.roomId].isBooked = false;

        _send(hotel, booking.amountPaid);
        emit NoShowMarked(bookingId, booking.amountPaid);
    }

    //Guest actions

    //the payment stays in the contract until check-in, cancellation or no-show
    function bookRoom(uint256 roomId, uint256 checkInDate, uint256 nights)
        external
        payable
        roomExists(roomId)
    {
        Room storage room = rooms[roomId]; 

        require(msg.sender != hotel, "The hotel cannot book its own rooms");
        require(room.available, "Room is not available");
        require(!room.isBooked, "Room is already booked");
        require(checkInDate > block.timestamp, "Check-in date must be in the future");
        require(nights > 0, "Stay must be at least one night");
        require(msg.value == room.pricePerNight * nights, "Payment must equal price x nights");

        room.isBooked = true;
        bookingCount++;
        bookings[bookingCount] = Booking(
            bookingCount,
            roomId,
            msg.sender,
            checkInDate,
            nights,
            msg.value,
            Status.Booked
        );

        emit RoomBooked(bookingCount, roomId, msg.sender, checkInDate, nights, msg.value);
    }

    //Full refund up to 48h before check-in, half after that
    function cancelBooking(uint256 bookingId) external bookingExists(bookingId) {
        Booking storage booking = bookings[bookingId];

        require(msg.sender == booking.guest, "Only the guest can cancel this booking");
        require(booking.status == Status.Booked, "Booking is not active");
        require(block.timestamp < booking.checkInDate, "Check-in date has passed");

        uint256 refund;
        uint256 hotelShare;

        if (block.timestamp + FREE_CANCELLATION_WINDOW <= booking.checkInDate) {
            refund = booking.amountPaid;
        } else {
            refund = booking.amountPaid / 2;
            hotelShare = booking.amountPaid - refund; //avoids losing 1 wei on odd amounts
        }

        booking.status = Status.Cancelled;
        rooms[booking.roomId].isBooked = false;

        _send(booking.guest, refund);
        if (hotelShare > 0) {
            _send(hotel, hotelShare);
        }

        emit BookingCancelled(bookingId, booking.guest, refund, hotelShare);
    }

    //Read-only 

    function getRoom(uint256 roomId) external view roomExists(roomId) returns (Room memory) {
        return rooms[roomId];
    }

    function getBooking(uint256 bookingId) external view bookingExists(bookingId) returns (Booking memory) {
        return bookings[bookingId];
    }

    //How much money the contract is holding right now
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //Sends ETH and cancels everything if the transfer fails
    function _send(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Transfer failed");
    }
}