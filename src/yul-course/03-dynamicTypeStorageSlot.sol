// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

contract MyContract {
    uint256[3] fixedArray;
    uint256[] bigArray;
    uint8[] smallArray;

    mapping(uint256 => uint256) public map1;
    mapping(uint256 => mapping(uint256 => uint256)) public nestedMap1;

    constructor() {
        fixedArray = [99, 999, 9999];
        bigArray = [88, 888];
        smallArray = [2, 22, 222];

        map1[10] = 777;
        map1[11] = 555;
        nestedMap1[1][2] = 555;
    }

    function getStorageSlot(uint256 slot) public view returns (bytes32 retVal) {
        assembly {
            retVal := sload(slot)
        }
    }

    function getBigArrayLen() public view returns (uint256 val) {
        uint8 bigArrLenSlot = 3;
        assembly {
            val := sload(bigArrLenSlot)
        }
    }

    // forge-lint: disable-next-item(asm-keccak256)
    function getBigArrayView(uint32 idx) public view returns (uint256 val) {
        uint8 bigArrLenSlot = 3;
        bytes32 bigArrSlot = keccak256(abi.encode(bigArrLenSlot));
        assembly {
            val := sload(add(bigArrSlot, idx))
        }
    }

    function getSmallArrayLen() public view returns (uint256 val) {
        uint8 smallArrLenSlot = 4;
        assembly {
            val := sload(smallArrLenSlot)
        }
    }

    // forge-lint: disable-next-item(asm-keccak256)
    function getSmallArrayView(uint32 idx) public view returns (bytes32 val) {
        uint8 smallArrLenSlot = 4;
        bytes32 SmallArrSlot = keccak256(abi.encode(smallArrLenSlot));
        assembly {
            val := sload(add(SmallArrSlot, idx))
        }
    }

    // forge-lint: disable-next-item(asm-keccak256)
    function getMapping(uint256 key) external view returns (uint256 retVal) {
        uint256 slot;
        assembly {
            slot := map1.slot
        }
        // slot is a `5`

        bytes32 storageLoc = keccak256(abi.encode(key, slot));
        assembly {
            retVal := sload(storageLoc)
        }
    }

    // forge-lint: disable-next-item(asm-keccak256)
    function getNestedMapping(uint256 key1, uint256 key2) external view returns (uint256 retVal) {
        uint256 slot;
        assembly {
            slot := nestedMap1.slot
        }

        // 1st layer
        bytes32 storageLoc = keccak256(abi.encode(key1, slot));
        // 2nd layer
        storageLoc = keccak256(abi.encode(key2, storageLoc));

        assembly {
            retVal := sload(storageLoc)
        }
    }
}
