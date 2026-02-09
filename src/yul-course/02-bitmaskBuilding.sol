// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;

contract StoragePart1 {
    uint128 public C = 4;
    uint96 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    function setStorage(string memory varName, uint256 newVal) external returns (bytes32 retVal) {
        uint32 bitOffset;
        uint32 bitLen;

        // forge-lint: disable-start(asm-keccak256)

        bytes32 varHash = keccak256(bytes(varName));

        if (varHash == keccak256(bytes("C"))) {
            bitOffset = 0;
            bitLen = 128;
        } else if (varHash == keccak256(bytes("D"))) {
            bitOffset = 128;
            bitLen = 96;
        } else if (varHash == keccak256(bytes("E"))) {
            bitOffset = 224;
            bitLen = 16;
        } else if (varHash == keccak256(bytes("F"))) {
            bitOffset = 240;
            bitLen = 8;
        } else {
            revert("Unknown storage variable");
        }
        // forge-lint: disable-end(asm-keccak256)

        assembly {
            let currVal := sload(0)

            // build up the mask
            let bitsOnRight := sub(exp(2, bitLen), 1)
            let mask := not(shl(bitOffset, bitsOnRight))

            let currValMasked := and(currVal, mask)
            let valShifted := shl(bitOffset, newVal)
            let newStorageVal := or(currValMasked, valShifted)

            sstore(0, newStorageVal)
        }

        // return storage 0
        assembly {
            retVal := sload(0x0)
        }
    }

    function getStorageSlot(uint256 slot) public view returns (bytes32 retVal) {
        assembly {
            retVal := sload(slot)
        }
    }
}
