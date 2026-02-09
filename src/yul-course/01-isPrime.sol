// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;

contract YulTypes {
    function getNumber() external pure returns (string memory) {
        bytes32 x = "";
        assembly {
            x := "hello world"
        }

        return string(abi.encode(x));
    }

    function isPrime(uint256 x) public pure returns (bool p) {
        p = true;

        assembly {
            let halfX := add(div(x, 2), 1)
            for { let i := 2 } lt(i, halfX) { i := add(i, 1) } {
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }
            }
        }
    }

    function testPrime() external pure {
        assert(isPrime(2));
        assert(isPrime(7));
        assert(isPrime(13));
        assert(!isPrime(9));
        assert(!isPrime(15));
    }
}

contract StorageBasics {
    uint256 x = 2;
    uint256 y = 34;
    uint256 z = 56;

    function getSlot(uint256 slot) external view returns (uint256 val) {
        assembly {
            val := sload(slot)
        }
    }

    function setSlot(uint256 slot, uint256 val) external {
        assembly {
            sstore(slot, val)
        }
    }

    function setX(uint256 _x) public {
        x = _x;
    }

    function getX() public view returns (uint256 val) {
        val = x;
    }
}
