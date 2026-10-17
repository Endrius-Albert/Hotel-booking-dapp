#Runs the full booking flow against the HotelBooking contract on Ganache.
#It deploys the contract, tests every rule from design.md and prints the results.

from pathlib import Path

import solcx
from packaging.version import Version
from web3 import Web3

GANACHE_URL = "http://127.0.0.1:8545"
SOLC_VERSION = "0.8.20"
CONTRACT_FILE = Path(__file__).resolve().parent.parent / "contracts" / "HotelBooking.sol"

ONE_DAY = 24 * 60 * 60
STATUS = ["Booked", "CheckedIn", "Cancelled", "NoShow"]

w3 = Web3(Web3.HTTPProvider(GANACHE_URL))
results = []


def eth(wei):
    return f"{w3.from_wei(wei, 'ether'):.4f} ETH"


def step(title):
    print(f"\n=== {title} ===")


def check(name, passed, detail=""):
    results.append(passed)
    label = "PASS" if passed else "FAIL"
    print(f"  [{label}] {name}" + (f" -> {detail}" if detail else ""))


def send(fn, sender, value=0):
    tx_hash = fn.transact({"from": sender, "value": value})
    return w3.eth.wait_for_transaction_receipt(tx_hash)


def expect_revert(name, fn, sender, expected, value=0):
    #A simulated call: if the contract rejects it, nothing changes on the blockchain
    try:
        fn.call({"from": sender, "value": value})
        check(name, False, "was not rejected")
    except Exception as error:
        message = str(error)
        found = expected in message
        check(name, found, f'rejected: "{expected}"' if found else message[:120])


def contract_balance(contract):
    return w3.eth.get_balance(contract.address)


def chain_time():
    return w3.eth.get_block("latest")["timestamp"]


def time_travel(seconds):
    #Ganache lets us move the blockchain clock forward instead of waiting days
    w3.provider.make_request("evm_increaseTime", [seconds])
    w3.provider.make_request("evm_mine", [])


def compile_contract():
    if Version(SOLC_VERSION) not in solcx.get_installed_solc_versions():
        print(f"  Downloading Solidity compiler {SOLC_VERSION} (first run only)...")
        solcx.install_solc(SOLC_VERSION)

    output = solcx.compile_standard(
        {
            "language": "Solidity",
            "sources": {"HotelBooking.sol": {"content": CONTRACT_FILE.read_text(encoding="utf-8")}},
            "settings": {
                "evmVersion": "paris",
                "outputSelection": {"*": {"*": ["abi", "evm.bytecode.object"]}},
            },
        },
        solc_version=SOLC_VERSION,
    )
    compiled = output["contracts"]["HotelBooking.sol"]["HotelBooking"]
    return compiled["abi"], compiled["evm"]["bytecode"]["object"]


def main():
    if not w3.is_connected():
        raise SystemExit(f"Ganache is not running on {GANACHE_URL}")

    hotel, guest, stranger = w3.eth.accounts[:3]
    price = w3.to_wei(1, "ether")

    step("1. Compile and deploy")
    abi, bytecode = compile_contract()
    receipt = send(w3.eth.contract(abi=abi, bytecode=bytecode).constructor(), hotel)
    contract = w3.eth.contract(address=receipt.contractAddress, abi=abi)
    print(f"  Contract deployed at {contract.address} (block {receipt.blockNumber})")
    print(f"  Hotel (receiver): {hotel}")
    print(f"  Guest (sender):   {guest}")

    step("2. Hotel lists four rooms")
    for name in ["Room 101", "Room 102", "Room 103", "Room 104"]:
        send(contract.functions.addRoom(name, price), hotel)
    check("Hotel added 4 rooms", contract.functions.roomCount().call() == 4)
    expect_revert("Guest cannot add a room",
                  contract.functions.addRoom("Fake Room", 1), guest,
                  "Only the hotel can do this")

    step("3. Guest books all four rooms (1 ETH per night)")
    now = chain_time()
    far, near = now + 5 * ONE_DAY, now + ONE_DAY
    expect_revert("Wrong payment is rejected",
                  contract.functions.bookRoom(1, far, 1), guest,
                  "Payment must equal price x nights", value=price // 2)
    expect_revert("Hotel cannot book its own room",
                  contract.functions.bookRoom(1, far, 1), hotel,
                  "The hotel cannot book its own rooms", value=price)
    for room_id, date in [(1, far), (2, near), (3, near), (4, near)]:
        send(contract.functions.bookRoom(room_id, date, 1), guest, value=price)
    expect_revert("A booked room cannot be booked again",
                  contract.functions.bookRoom(1, far, 1), guest,
                  "Room is already booked", value=price)
    check("4 ETH held in escrow", contract_balance(contract) == 4 * price,
          eth(contract_balance(contract)))

    step("4. Cancellations")
    expect_revert("Only the guest can cancel",
                  contract.functions.cancelBooking(2), stranger,
                  "Only the guest can cancel this booking")

    receipt = send(contract.functions.cancelBooking(1), guest)
    event = contract.events.BookingCancelled().process_receipt(receipt)[0]["args"]
    check("Early cancellation gives a full refund",
          event["refundAmount"] == price and event["hotelAmount"] == 0,
          f"guest {eth(event['refundAmount'])}, hotel {eth(event['hotelAmount'])}")

    hotel_before = w3.eth.get_balance(hotel)
    receipt = send(contract.functions.cancelBooking(2), guest)
    event = contract.events.BookingCancelled().process_receipt(receipt)[0]["args"]
    check("Late cancellation splits 50/50",
          event["refundAmount"] == price // 2 and event["hotelAmount"] == price // 2,
          f"guest {eth(event['refundAmount'])}, hotel {eth(event['hotelAmount'])}")
    check("Hotel received its half", w3.eth.get_balance(hotel) - hotel_before == price // 2)

    step("5. Time rules before the check-in date")
    expect_revert("Check-in before the date is rejected",
                  contract.functions.checkIn(3), hotel, "Too early to check in")
    expect_revert("No-show before the window is rejected",
                  contract.functions.markNoShow(4), hotel, "No-show window has not passed")
    expect_revert("Guest cannot confirm check-in",
                  contract.functions.checkIn(3), guest, "Only the hotel can do this")

    step("6. Moving the blockchain clock forward 3 days")
    time_travel(3 * ONE_DAY)
    print("  Done with evm_increaseTime + evm_mine")

    step("7. Check-in and no-show")
    before = contract_balance(contract)
    send(contract.functions.checkIn(3), hotel)
    check("Check-in releases 1 ETH to the hotel", before - contract_balance(contract) == price)
    expect_revert("Second check-in is rejected (no double payment)",
                  contract.functions.checkIn(3), hotel, "Booking is not active")

    before = contract_balance(contract)
    send(contract.functions.markNoShow(4), hotel)
    check("No-show releases 1 ETH to the hotel", before - contract_balance(contract) == price)

    step("8. Final state")
    for booking_id in range(1, 5):
        booking = contract.functions.getBooking(booking_id).call()
        print(f"  Booking {booking_id}: room {booking[1]}, status {STATUS[booking[6]]}")
    check("Contract balance is back to 0", contract_balance(contract) == 0,
          eth(contract_balance(contract)))

    print(f"\n{sum(results)}/{len(results)} checks passed")


if __name__ == "__main__":
    main()