// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Hotel booking with escrow: the guest pays, the contract holds the money,
// and the rules decide when it goes to the hotel or back to the guest.
contract HotelBooking {
    // The possible states of a booking 
    enum Status { Booked, CheckedIn, Cancelled, NoShow }

    struct Room {
        uint256 id;
        string name;
        uint256 pricePerNight; // in wei
        bool available;        // the hotel can open or close the room
        bool isBooked;         // true while the room has an active booking
    }

    // Only the guest's wallet address is stored, no personal data (GDPR)
    struct Booking {
        uint256 id;
        uint256 roomId;
        address guest;
        uint256 checkInDate;   // Unix timestamp
        uint256 nights;
        uint256 amountPaid;    // held in escrow until check-in, cancellation or no-show
        Status status;
    }

    address public hotel;      // the receiver: whoever deploys the contract
    uint256 public roomCount;
    uint256 public bookingCount;

    // ID => data, like a lookup table
    mapping(uint256 => Room) private rooms;
    mapping(uint256 => Booking) private bookings;

    // Events create a permanent public record of each step
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

    // Access control: msg.sender is proven by the caller's ECDSA signature
    modifier onlyHotel() {
        require(msg.sender == hotel, "Only the hotel can do this");
        _;
    }

    modifier roomExists(uint256 roomId) {
        require(roomId > 0 && roomId <= roomCount, "Room does not exist");
        _;
    }

    // Runs once at deployment: the deployer becomes the hotel
    constructor() {
        hotel = msg.sender;
    }

    // ---------- Hotel functions ----------

    function addRoom(string calldata name, uint256 pricePerNight) external onlyHotel {
        require(bytes(name).length > 0, "Room name is required");
        require(pricePerNight > 0, "Price must be greater than zero");

        roomCount++; // IDs start at 1
        rooms[roomCount] = Room(roomCount, name, pricePerNight, true, false);

        emit RoomAdded(roomCount, name, pricePerNight);
    }

    // Lets the hotel close a room
    function setRoomAvailability(uint256 roomId, bool available)
        external
        onlyHotel
        roomExists(roomId)
    {
        rooms[roomId].available = available;
        emit RoomAvailabilityChanged(roomId, available);
    }

        // ---------- Guest functions ----------

    // payable: this function receives the guest's money, which stays in the contract's balance (escrow) until a later rule releases or refunds it
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

    // ---------- Read-only functions  ----------

    function getRoom(uint256 roomId) external view roomExists(roomId) returns (Room memory) {
        return rooms[roomId];
    }

    function getBooking(uint256 bookingId) external view returns (Booking memory) {
        require(bookingId > 0 && bookingId <= bookingCount, "Booking does not exist");
        return bookings[bookingId];
    }

    // Shows the money currently held in escrow
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

}