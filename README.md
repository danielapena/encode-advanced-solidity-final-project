# Future Heritage Automation

## Overview

Future Heritage Automation is a Solidity-based project that leverages Chainlink's decentralized automation to facilitate the automatic transfer of heritage tokens at a specified future time. This project is built using the Hardhat development environment and utilizes OpenZeppelin's upgradeable contracts.

## Features

- **Automated Token Transfers**: Schedule future token transfers that are automatically executed by Chainlink's decentralized automation.
- **Upgradeable Contracts**: Built with upgradeable smart contracts using OpenZeppelin's UUPS pattern.
- **Security**: Ensures only the token owner can schedule, update, or cancel future transfers.

## Prerequisites

- Node.js
- npm
- Hardhat

## Usage

### Compile the Contracts

To compile the smart contracts, run:

```sh
npx hardhat compile
```

## Smart Contracts

### **FutureTransferUpgradeable**

The main contract responsible for scheduling and executing future token transfers.

#### **Functions**

- **`createFutureTransfer(address to, uint256 tokenId, uint256 transferTime)`**  
  Schedule a new future transfer.

- **`updateFutureTransfer(uint256 transferId, address newTo, uint256 newTransferTime)`**  
  Update an existing future transfer.

- **`cancelFutureTransfer(uint256 transferId)`**  
  Cancel a scheduled future transfer.

- **`checkUpkeep(bytes calldata checkData)`**  
  Check if any scheduled transfers need to be executed.

- **`performUpkeep(bytes calldata performData)`**  
  Execute the scheduled transfers.

---

### **ILockableERC721**

An interface for the ERC721 token contract with additional locking functionality.

