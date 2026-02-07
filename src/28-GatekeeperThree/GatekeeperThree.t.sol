// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GatekeeperThree} from "./GatekeeperThree.sol";
import {SolveGatekeeperThree} from "./SolveGatekeeperThree.sol";

contract GatekeeperThreeTest is Test {
    GatekeeperThree gatekeeper;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        gatekeeper = new GatekeeperThree();
    }

    function testSolveGatekeeperThree() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);

        // The 2nd argument is for tx.origin() setting
        vm.startPrank(alice, alice);

        // deploy solver
        SolveGatekeeperThree solver = new SolveGatekeeperThree{value: 0.00101 ether}(address(gatekeeper));

        gatekeeper.createTrick();

        // read storage slot 2 of gatekeeper
        bytes32 slot2 = vm.load(address(gatekeeper.trick()), bytes32(uint256(2)));
        uint256 password = uint256(slot2);

        solver.solve(password);
        assertEq(gatekeeper.entrant(), alice, "entrant is not set to alice");
    }
}
