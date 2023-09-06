<p align="center" style="margin-bottom:32px">
  <a href="https://unlockd.finance">
    <img alt="Unlockd logo" src="https://miro.medium.com/max/660/1*YEp9mC_4sVUuFpBzatz3dQ.png" width="auto" height="92px" />
  </a>
  <a href="https://unlockd.finance">
    <img alt="Unlockd logo" src="https://halborn.com/wp-content/uploads/2021/10/audited-by-halborn-green.png.webp" width="auto" height="92px" />
  </a>
  
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" alt="figma"/>
    <img src="https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white" alt="typescript"/>   
    <img src="https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black" alt="solidity"/>  
    <img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="google-cloud"/>

[![](https://dcbadge.vercel.app/api/server/unlockd)](https://discord.gg/unlockd)

</p>

<p align="center">
Unlockd is a decentralized non-custodial NFT lending protocol where users can participate as depositors or borrowers. Depositors provide liquidity to the market to earn a passive income, while borrowers are able to borrow in an overcollateralized fashion, using NFTs as collaterl.
</p>

<p align="center">
NFTBatchTransfer enables bulk transfers of ERC721 tokens and CryptoPunks, streamlining transactions for efficiency. Callers are responsible for input validation.
</p>
<br/>

# 🗂️ Index

- [Documentation](#-documentation)
- [Setup](#-setup)
- [Test](#-test)
- [Deployments](#-deployments)


# 📝 Documentation

## Overview
The NFTBatchTransfer contract is designed to facilitate the batch transfer of NFTs (Non-Fungible Tokens) in a single transaction. This not only reduces gas costs but also enhances the efficiency of multiple transfers. The contract is compatible with the standard ERC721 token protocol and is specifically tailored to work with the CryptoPunks contract.

## Key Features:

- Batch Transfer: Allows for multiple NFTs to be transferred in one transaction.
- Gas Efficiency: Optimized to minimize gas usage during batch transfers.
- CryptoPunks Special Handling: Special methods for handling the unique nature of CryptoPunks transfers.

## Contract Structure

### Public Variables:
    punkContract: Holds the immutable address of the CryptoPunks contract. This address is set during deployment and cannot be altered afterward.

### Struct:
    NftTransfer: A struct used to encapsulate the details of an NFT transfer. It contains:
        contractAddress: The address of the ERC721 contract.
        tokenId: The specific ID of the token to be transferred.

### Constructor:
    NFTBatchTransfer(address _punkContract): Initializes the contract with the address of the CryptoPunks contract.

### Main Functions:

    batchTransferFrom(NftTransfer[] calldata nftTransfers, address to):
    
    Allows for the batch transfer of standard ERC721 NFTs.
    Requires the details of the NFTs to be transferred in the form of NftTransfer struct array and the recipient's address.
    Uses dynamic calls to invoke the transferFrom method on target ERC721 contracts.
    
    
    batchPunkTransferFrom(NftTransfer[] calldata nftTransfers, address to):
    
    Orchestrates a batch transfer for CryptoPunks alongside other standard ERC721 NFTs.
    Distinguishes between CryptoPunks and standard ERC721 tokens, applying special handling for CryptoPunks.
    For CryptoPunks, the contract first buys the punk (if necessary) and then executes the transfer.

### Fallback and Receive Functions:
    
    fallback(): A fallback function that rejects any Ether sent to the contract.
    
    receive(): Explicitly rejects any Ether transferred to the contract.

## Important Note on Address ZERO:

For optimization and simplicity purposes, the batchTransferFrom and batchPunkTransferFrom functions in the NFTBatchTransfer contract do not internally validate the supplied addresses for zero address (0x0000000000000000000000000000000000000000).

This design choice was made to keep the contract functions lean and efficient. It is the responsibility of the caller to ensure that they do not provide the zero address when invoking these functions. Providing the zero address may result in the loss of NFTs, as they would be sent to an unrecoverable address.

Always double-check and validate addresses before calling the functions to prevent any unintended transfers.


# 🎬 Setup

You will need to have Foundry installed in your machine, I recomend to check https://book.getfoundry.sh/

### Install

```bash
$ forge install
```

### Build

```bash
$ forge build
```

# 🧪 Test

### Tests

```bash
$ forge test
```

### Check coverage and create a report

```bash
$ mkdir coverage && forge coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage
```

### Format

```bash
$ forge fmt
```

### Gas Snapshots

```bash
$ forge snapshot
```


# 🚀 Deployments

CryptoPunksMarket Address: "0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB"

### Deploy

```bash
$ forge script script/NFTBatchTransfer.s.sol:NFTBatchTransferScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```
