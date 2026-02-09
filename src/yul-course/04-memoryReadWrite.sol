// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;

struct Point {
    uint256 x;
    uint256 y;
}

contract MemoryReadWrite {
    event MemoryPointer(bytes32 indexed, bytes32 indexed);
    event DynMemory(uint256 loc, uint256 arrLen, uint256 firstEl);

    function readwrite() external pure {
        assembly {
            mstore(0, 7)
            mstore8(0, 7)
        }
    }

    function memPointer() external {
        bytes32 x40;
        bytes32 _msize;

        assembly {
            // this is loading the next available free pointer
            x40 := mload(0x40)
            // msize() retrieve the largest access bytes in our solidity code
            // _msize := msize()
        }
        emit MemoryPointer(x40, _msize);

        Point memory p = Point({x: 1, y: 2});

        assembly {
            // this is loading the next available free pointer
            x40 := mload(0x40)
            // _msize := msize()
        }
        emit MemoryPointer(x40, _msize);

        assembly {
            pop(mload(0xff))
            x40 := mload(0x40)
            // _msize := msize()
        }
        emit MemoryPointer(x40, _msize);
    }

    function readDynMemory(uint256[] memory arr) external {
        uint256 loc;
        uint256 arrLen;
        uint256 firstEl;

        assembly {
            loc := arr
            arrLen := mload(arr)
            firstEl := mload(add(arr, 0x20))
        }

        emit DynMemory(loc, arrLen, firstEl);
    }
}
