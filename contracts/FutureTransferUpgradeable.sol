// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {ILockableERC721} from "./interfaces/ILockableERC721.sol";

contract FutureTokenTransferUpgradeable is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    AutomationCompatibleInterface
{
    struct FutureTransfer {
        address from;
        address to;
        uint256 tokenId;
        uint256 transferTime;
        bool transferred;
    }

    ILockableERC721 public tokenContract;
    mapping(uint256 => FutureTransfer) public futureTransfers;
    uint256 public futureTransferCounter;

    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            tokenContract.ownerOf(tokenId) == msg.sender,
            "Caller must own the token"
        );
        _;
    }

    modifier onlyFutureTimestamp(uint256 transferTime) {
        require(
            transferTime > block.timestamp,
            "Transfer time must be in the future"
        );
        _;
    }

    modifier onlyOwnerOfTransferToken(uint256 transferId) {
        require(
            tokenContract.ownerOf(futureTransfers[transferId].tokenId) == msg.sender,
            "Only the owner of the token can change the transfer settings"
        );
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address currentNFTContract) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        tokenContract = ILockableERC721(currentNFTContract);
        futureTransferCounter = 0;
    }

    function setTokenContract(address newTokenContract) external onlyOwner {
        tokenContract = ILockableERC721(newTokenContract);
    }

    function createFutureTransfer(
        address to,
        uint256 tokenId,
        uint256 transferTime
    ) onlyTokenOwner(tokenId) onlyFutureTimestamp(transferTime) external {
        require(
            !tokenContract.isTokenLocked(tokenId),
            "Token is already locked"
        );

        futureTransfers[futureTransferCounter] = FutureTransfer({
            from: msg.sender,
            to: to,
            tokenId: tokenId,
            transferTime: transferTime,
            transferred: false
        });

        tokenContract.lockToken(tokenId);

        futureTransferCounter++;
    }

    function updateFutureTransfer(
        uint256 transferId,
        address newTo,
        uint256 newTransferTime
    ) onlyFutureTimestamp(newTransferTime) onlyOwnerOfTransferToken(transferId) external {
        require(
            transferId < futureTransferCounter,
            "Invalid transfer ID"
        );

        futureTransfers[transferId].to = newTo;
        futureTransfers[transferId].transferTime = newTransferTime;
    }

    // TODO: Refactor to use tokenId instead of transferId so user doesn't need to know the transferId
    function cancelFutureTransfer(uint256 transferId) onlyOwnerOfTransferToken(transferId) external {
        require(
            transferId < futureTransferCounter,
            "Invalid transfer ID"
        );

        for (uint256 i = transferId; i < futureTransferCounter - 1; i++) {
            futureTransfers[i] = futureTransfers[i + 1];
        }
        futureTransferCounter--;

        tokenContract.unlockToken(futureTransfers[transferId].tokenId);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = false;
        for (uint256 i = 0; i < futureTransferCounter; i++) {
            if (
                block.timestamp >= futureTransfers[i].transferTime &&
                !futureTransfers[i].transferred
            ) {
                upkeepNeeded = true;
                break;
            }
        }
        performData = new bytes(0);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        for (uint256 i = 0; i < futureTransferCounter; i++) {
            if (
                block.timestamp >= futureTransfers[i].transferTime &&
                !futureTransfers[i].transferred
            ) {
                tokenContract.unlockToken(futureTransfers[i].tokenId);
                tokenContract.transferFrom(
                    futureTransfers[i].from,
                    futureTransfers[i].to,
                    futureTransfers[i].tokenId
                );
                futureTransfers[i].transferred = true;
            }
        }
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}
}
