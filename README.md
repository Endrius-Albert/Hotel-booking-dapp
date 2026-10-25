# Hotel Booking DApp

This repository is my CA1 project for Distributed Digital Transactions at CCT College Dublin (BSc (Hons) in Computing in IT, 3rd year).

I chose the **Hotel Booking** scenario. The project is a smart contract that connects a hotel and a guest directly: the guest (sender) pays the contract, the contract holds the money in escrow, and the hotel (receiver) is paid automatically when the booking rules say so. The blockchain is the middle layer, instead of a booking platform.

## The Problem

Most hotel bookings in Europe go through Online Travel Agencies (OTAs). They charge hotels a commission on every booking (usually 10–30%), hold the guest's money and decide the cancellation rules. The full research is in [`research-notes.md`](research-notes.md).

## How the Contract Works

| Action | Who can do it | What happens to the money |
|---|---|---|
| `addRoom` / `setRoomAvailability` | Hotel | – |
| `bookRoom` | Guest | Exact payment (price × nights) is locked in the contract |
| `cancelBooking` 48h+ before check-in | The booking's guest | 100% refunded to the guest |
| `cancelBooking` later | The booking's guest | 50% to the guest, 50% to the hotel |
| `checkIn` (from the check-in date) | Hotel | 100% released to the hotel |
| `markNoShow` (24h after the check-in date) | Hotel | 100% released to the hotel |
| `getRoom` / `getBooking` / `getContractBalance` | Anyone | Read-only |

Every action checks that the booking is still active before any money moves, so a booking can never be paid twice. The full design, including the UML diagrams and the test plan, is in [`Design.md`].

## Project Structure

```
contracts/HotelBooking.sol   the smart contract (Solidity 0.8.20)
scripts/interact.py          deploys the contract and runs 17 automated checks (web3.py)
scripts/run.sh               starts Ganache, runs interact.py, then stops Ganache
Design.md                    roles, rules, UML diagrams and test plan
research-notes.md            research for the proposal, with Harvard references
requirements.txt             Python libraries
```

## Tools

- **Solidity 0.8.20** – the smart contract
- **Remix IDE** – writing, compiling and manual testing (EVM version: Paris)
- **Ganache 7.9** – local blockchain with test accounts
- **Python 3 + web3.py + py-solc-x** – automated deployment and testing
- **Shell script (Bash)** – runs the whole test flow with one command

## How to Run

**1. Install the requirements** (Node.js and Python 3 must already be installed):

```bash
npm install -g ganache
python -m pip install -r requirements.txt
```

**2. Run the automated tests** (on Windows, use Git Bash):

```bash
bash scripts/run.sh
```

The script starts a fresh Ganache, compiles and deploys the contract, runs every booking scenario, moves the blockchain clock forward with `evm_increaseTime` to test the time rules, and prints the gas used by each transaction. On the first run it also downloads the Solidity compiler.

**3. Test manually in Remix (optional):**

1. Run `ganache --deterministic` in a terminal and leave it open.
2. Open `contracts/HotelBooking.sol` in [Remix](https://remix.ethereum.org), set the EVM version to **Paris** and compile.
3. In *Deploy & Run*, choose **Dev – Ganache Provider** (`http://127.0.0.1:8545`) and deploy with the first account (the hotel).
4. Use the second account as the guest. `checkInDate` is a Unix timestamp, and payments go in the **Value** field.

## Test Results

All **17/17 checks pass**. They cover:

- **Access control:** only the hotel can add rooms and confirm check-in; only the booking's guest can cancel.
- **Payments:** wrong amounts, double bookings and the hotel booking its own room are rejected.
- **Escrow:** four bookings of 1 ETH leave 4 ETH held by the contract.
- **Refunds:** full refund 48h+ before check-in, 50/50 split after that.
- **Time rules:** check-in and no-show are rejected before their time and work after it.
- **Security:** a second check-in is rejected, so there is no double payment.
- **Final state:** the contract balance returns to 0 ETH.

## Status

✅ Smart contract, automated tests and documentation complete.
🚧 Poster and video presentation in progress.
