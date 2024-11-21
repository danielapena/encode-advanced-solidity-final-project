# Encode Advanced Solidity Final Project - Future Heritage Token Automation

## Overview

Future Heritage Automation is a Solidity-based project that leverages Chainlink's decentralized automation to facilitate the automatic transfer of heritage tokens at a specified future time. This project is built using the Hardhat development environment and utilizes OpenZeppelin's upgradeable contracts.

![chainlink](/.docs/chainlink-automation-example.png)

## Goal of the project

- Get comfortable with upgradeable contract standards
- Play with DePin projects

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

## Execution steps

1. Deploy ERC721 contract
2. Deploy Future Transfer contract with ERC721 in the constructor
3. From the ERC721 contract, grant role of `TOKEN_OPERATOR_ROLE` to the Future Transfer contract
4. Setup Chainlink automation with Future Transfer contract
![Image](/.docs/1-register-upkeep.png)
![Image](/.docs/2-confirm-registration.png)
![Image](/.docs/3-chainlink-automation.png)
5. Mint a token from ERC721 (`safeMint`) -> [tx example](https://testnet.snowtrace.io/tx/0x5e0e317377884618a0c42654db216413b1f83c601b42e0695d56b71a47b74217?chainid=43113).

6. As token owner, authorize Future Transfer protocol to transfer token on behalf of (`setApprovalForAll`) -> [tx example](https://testnet.snowtrace.io/tx/0xc6903e03b7002811968a4a56e8f344ed06da156c28b2520a1a532921cd11c17b?chainid=43113).
7. As the token owner, setup a future transfer (`createFutureTransfer(address to, uint256 tokenId, uint256 transferTime)`) -> [tx example](https://testnet.snowtrace.io/tx/0xfee7a1f10f176bd2cc85577c2058b93bd9b576f0817c5add8159dc4e6365c3c9)
8. When the time condition is met, the automation will automatically call the action, and automatically transfer the token -> [tx example](https://testnet.snowtrace.io/tx/0xe7d1c954fc8ec7f80fccdca1b0c44f03714518d107627c9e1e98eaccd729c03c)

## Working Demo

- Chainlink Automation: https://automation.chain.link/fuji/63295474412089319238590707313905625913099835957765178029568550638379665064292
- Example of an automated transfer of a token: https://testnet.snowtrace.io/tx/0xe7d1c954fc8ec7f80fccdca1b0c44f03714518d107627c9e1e98eaccd729c03c
