// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;
import {console} from "forge-std/Test.sol";

contract OtherContract {
    function getVal() external pure returns (uint256 val) {
        val = 42;
    }

    function multiply(uint256 a, uint256 b) external pure returns (uint256 val) {
        console.log("a: %s, b: %s", a, b);

        assembly {
            val := mul(a, b)
        }
    }
}

contract ExternalCalls {
    function externalViewCallNoArgs(address _a) external view returns (uint256) {
        bytes4 sel = OtherContract.getVal.selector;

        assembly {
            mstore(0, sel)
            // 3rd param: argOffset, 4th: argSize
            // 5th param: byte offset in memory of the return val, 6th: byte len
            let success := staticcall(gas(), _a, 0, 4, 0, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            return(0, 0x20)
        }
    }

    function callMultiply(address _a, uint256 a, uint256 b) external view returns (uint256 result) {
        bytes4 sel = OtherContract.multiply.selector;
        assembly {
            let mptr := mload(0x40)
            mstore(mptr, sel) // selector
            mstore(add(mptr, 0x04), a) // first param
            mstore(add(mptr, 0x24), b) // second param

            let success := staticcall(gas(), _a, mptr, 0x44, mptr, 0x20)
            if iszero(success) {
                revert(0, 0)
            }

            result := mload(mptr)
            mstore(0x40, add(mptr, 0x44))
        }
    }
}
