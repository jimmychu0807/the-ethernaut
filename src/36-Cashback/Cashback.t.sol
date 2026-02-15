// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";
import {CashbackCollision} from "./CashbackCollision.sol";
import {Test, console, Vm} from "forge-std/Test.sol";

address constant CURRENCY_ANOTHER = 0x13AaF3218Facf57CfBf5925E15433307b59BCC37;
address constant SUPER_NFT_ADDR = 0x0Ae3Cf507ea6caF9d13Ea5e624AE2bAb386ce354;

// forge-lint: disable-next-item(asm-keccak256)
contract SolveCashback is Test {
    Cashback cashback;
    CashbackCollision cc;
    address payable alice;
    uint256 aliceSK;
    address bob;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        // currencies
        address[] memory _currencies = new address[](2);
        _currencies[0] = Currency.unwrap(CurrencyLibrary.NATIVE_CURRENCY);
        _currencies[1] = CURRENCY_ANOTHER;

        // cashback
        uint256[] memory _cashbacks = new uint256[](2);
        _cashbacks[0] = 50;
        _cashbacks[1] = 200;

        // maxCashback
        uint256[] memory _maxCashbacks = new uint256[](2);
        _maxCashbacks[0] = 0xde0b6b3a7640000;
        _maxCashbacks[1] = 0x1b1ae4d6e2ef500000;

        // superCashbackNFT addr
        address _superCashbackNFT = SUPER_NFT_ADDR;

        cashback = new Cashback(_currencies, _cashbacks, _maxCashbacks, _superCashbackNFT);
        cc = new CashbackCollision();

        _setUpAccounts();

        vm.stopPrank();
    }

    function _setUpAccounts() internal {
        aliceSK = 0xA11CE;
        alice = payable(vm.addr(aliceSK));
        vm.deal(alice, 1 ether);

        bob = makeAddr("bob");
        vm.deal(bob, 1 ether);
    }

    function testSolveCashback() public {
        uint256 amount = 0.1 ether;

        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(address(cashback), aliceSK);

        vm.startPrank(alice, alice);
        vm.attachDelegation(signedDelegation);
        // confirm alice behaves like a smart contract
        require(alice.code.length > 0, "Alice is not behaving like a smart contract");

        Cashback(alice).payWithCashback(CurrencyLibrary.NATIVE_CURRENCY, bob, amount);

        vm.stopPrank();
    }
}

/***
- how to call _mint()?

function accrueCashback(Currency currency, uint256 amount)
    external
    onlyDelegatedToCashback
    onlyUnlocked
    onlyOnCashback {...}

// Smart Account Functions
function payWithCashback(Currency currency, address receiver, uint256 amount)
    external
    unlock
    onlyEOA
    notOnCashback {...}

function consumeNonce()
    external
    onlyCashback
    notOnCashback
    returns (uint256) {...}
*/
