# Hotel Booking DApp

Hi! This repository is for my CA1 project in Distributed Digital Transactions at CCT College Dublin (BSc in Computing in IT, 3rd year).

I chose the **Hotel Booking** scenario. The goal is to build a simple smart contract that connects a hotel and a guest directly, without a booking platform in the middle.

## The Problem

Today, most people book hotels through big online platforms. These platforms charge hotels a commission on every booking, and they also decide what happens with the guest's money and with cancellations. For the guest, the cancellation rules are not always clear. For the hotel, a part of every booking goes to someone else.

## My Idea

My idea is to replace the middleman with a smart contract on the blockchain.

- The hotel adds a room and its price.
- The guest books the room and pays. The money stays locked in the contract.
- When the guest checks in, the contract sends the money to the hotel.
- If the guest cancels in time, the contract gives the money back automatically.

The rules are written in the code, so both sides can see them and nobody can change them later.

## Tools

- **Solidity** – to write the smart contract
- **Remix IDE** – to write, compile and test the contract
- **Ganache** – a local blockchain with test accounts
- **Python (web3.py)** – to interact with the contract from a script
- **Shell script** – to run everything automatically

## Project Structure

- `contracts/` – the Solidity smart contract
- `scripts/` – the Python and Shell scripts

## Status

🚧 Just getting started. The setup is done, and I'm now researching the current booking system and planning the contract.