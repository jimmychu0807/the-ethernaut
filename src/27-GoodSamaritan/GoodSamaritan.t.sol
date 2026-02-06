// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GoodSamaritan, Coin, Wallet} from "./GoodSamaritan.sol";
import {SolveGoodSamaritan} from "./SolveGoodSamaritan.sol";

contract GoodSamaritanTest is Test {
    address deployer;
    GoodSamaritan sam;
    Wallet samWallet;
    Coin samCoin;

    function setUp() public {
        deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        sam = new GoodSamaritan();
        samWallet = sam.wallet();
        samCoin = sam.coin();

        assertEq(samCoin.balances(address(samWallet)), 10 ** 6);
    }

    function testDonation() public {
        address alice = makeAddr("alice");
        vm.startPrank(alice);

        uint256 aPrevBal = samCoin.balances(alice);
        uint256 sPrevBal = samCoin.balances(address(samWallet));

        sam.requestDonation();

        uint256 aAfterBal = samCoin.balances(alice);
        uint256 sAfterBal = samCoin.balances(address(samWallet));

        assertTrue(aAfterBal - aPrevBal == sPrevBal - sAfterBal);
        assertTrue(aAfterBal > aPrevBal);
    }

    function testDepletingSamWallet() public {
        address alice = makeAddr("alice");
        vm.startPrank(alice);

        SolveGoodSamaritan solution = new SolveGoodSamaritan();
        solution.requestDonation(address(sam));
        assertEq(samCoin.balances(address(samWallet)), 0);
    }
}
