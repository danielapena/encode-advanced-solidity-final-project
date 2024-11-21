// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILockable {
    function lockToken(uint256 tokenId) external;
    function unlockToken(uint256 tokenId) external;
    function isTokenLocked(uint256 tokenId) external view returns (bool);
}

interface ILockableERC721 is IERC721, ILockable {}