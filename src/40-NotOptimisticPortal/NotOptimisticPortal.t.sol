// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NotOptimisticPortal} from "./NotOptimisticPortal.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Lib_RLPReader} from "../helpers/lib/rlp/Lib_RLPReader.sol";
import {Lib_RLPWriter} from "../helpers/lib/rlp/Lib_RLPWriter.sol";
import {Test, console} from "forge-std/Test.sol";

bytes constant RLP_BLOCK_HEADER =
    hex"f90204a00000000000000000000000000000000000000000000000000000000000000000a01dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347940000000000000000000000000000000000000000a0d7d3685b57d9897755fad850b19f7c43debfded002e18a9e8e5b63639882b6f9a0c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470a0c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470b90100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000184039fd3988401c9c38080845fc630578b4354465f5061796c6f6164a00000000000000000000000000000000000000000000000000000000000000000880000000000000000";

address constant GOVERNANCE_ADDR = 0xB43eBB13D1C42709651c032C7894962023A1f90A;

address constant PLAYER_ADDR = 0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7;

contract NotOptimisticPortalTest is Test {
    using Lib_RLPWriter for bytes;
    using Lib_RLPWriter for bytes[];
    using Lib_RLPReader for bytes;
    using Lib_RLPReader for Lib_RLPReader.RLPItem;

    NotOptimisticPortal portal;
    ERC20 asToken;

    function setUp() public {
        portal = new NotOptimisticPortal("CTFToken", "CTFT", RLP_BLOCK_HEADER, GOVERNANCE_ADDR);

        asToken = ERC20(address(portal));
    }

    function testLearnRLPEncodeDecode() public {
        Lib_RLPReader.RLPItem[] memory rlpItems = RLP_BLOCK_HEADER.readList();
        // src on block header info
        // https://github.com/ethereum/go-ethereum/blob/master/core/types/block.go#L68
        console.log("item len: %s", rlpItems.length);
        bytes32 parentHash = rlpItems[0].readBytes32();
        bytes32 stateRoot = rlpItems[3].readBytes32();
        uint256 blockNumber = rlpItems[8].readUint256();
        uint256 timestamp = rlpItems[11].readUint256();

        console.log("blockNumber: %s", blockNumber);
        console.log("timestamp: %s", timestamp);
    }

    function testSendNExecuteMessage() public {
        uint256 salt = 1;
        uint256 amount = 0;
        uint16 bufferIndex = 1;

        address[] memory receiverArr = new address[](1);
        receiverArr[0] = address(portal);

        bytes[] memory dataArr = new bytes[](1);
        dataArr[0] = abi.encodeWithSignature("transferOwnership_____610165642(address)", PLAYER_ADDR);

        portal.sendMessage(amount, receiverArr, dataArr, salt);

        NotOptimisticPortal.ProofData memory proofs =
            NotOptimisticPortal.ProofData({stateTrieProof: hex"", storageTrieProof: hex"", accountStateRlp: hex""});

        // portal.executeMessage(address(this), amount, receiverArr, dataArr, salt, proofs, bufferIndex);
    }
}
