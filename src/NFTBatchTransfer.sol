// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
 * @title NFTBatchTransfer
 * @dev This is a public contract in order to allow batch transfers of NFTs,
 * in a single transaction, reducing gas costs and improving efficiency.
 */
contract NFTBatchTransfer {
    // Immutable address for the CryptoPunks contract. This is set at deployment and cannot be altered afterwards.
    address public immutable punkContract;

    // Struct to encapsulate information about an individual NFT transfer.
    // It holds the address of the ERC721 contract and the specific token ID to be transferred.
    struct NftTransfer {
        address contractAddress;
        uint256 tokenId;
    }

    // Modifer to ensure an address is valid (not the zero address)
    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    /**
     * @dev Constructor to set the initial state of the contract.
     * @param _punkContract The address of the CryptoPunks contract.
     */
    constructor(address _punkContract) {
        punkContract = _punkContract;
    }

    /**
     * @dev Orchestrates a batch transfer of standard ERC721 NFTs.
     * @param nftTransfers An array of NftTransfer structs detailing the NFTs to be moved.
     * @param to The recipient's address.
     */
    function batchTransferFrom(
        NftTransfer[] calldata nftTransfers,
        address to
    ) external nonZeroAddress(to) {
        uint256 length = nftTransfers.length;

        // Capturing the initial gas at the start for later comparisons.
        uint256 gasLeftStart = gasleft();

        // Iterate through each NFT in the array to facilitate the transfer.
        for (uint i = 0; i < length; ) {
            address contractAddress = nftTransfers[i].contractAddress;
            uint256 tokenId = nftTransfers[i].tokenId;

            // Dynamically call the `transferFrom` function on the target ERC721 contract.
            (bool success, ) = contractAddress.call(
                abi.encodeWithSignature(
                    "transferFrom(address,address,uint256)",
                    msg.sender,
                    to,
                    tokenId
                )
            );

            // Check the transfer status and gas consumption.
            if (!success || gasleft() < gasLeftStart / 2) {
                revert("Transfer failed");
            }

            // Use unchecked block to bypass overflow checks for efficiency.
            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev Manages a batch transfer of NFTs, specifically tailored for CryptoPunks alongside other standard ERC721 NFTs.
     * @param nftTransfers An array of NftTransfer structs specifying the NFTs for transfer.
     * @param to The destination address for the NFTs.
     */
    function batchPunkTransferFrom(
        NftTransfer[] calldata nftTransfers,
        address to
    ) external nonZeroAddress(to) {
        uint256 length = nftTransfers.length;
        uint256 gasLeftStart = gasleft();
        bool success;

        // Process batch transfers, differentiate between CryptoPunks and standard ERC721 tokens.
        for (uint i = 0; i < length; i++) {
            address contractAddr = nftTransfers[i].contractAddress;
            uint256 tokenId = nftTransfers[i].tokenId;

            if (contractAddr != punkContract) {
                // If it's not a CryptoPunk, use the standard ERC721 `transferFrom` function.
                (success, ) = contractAddr.call(
                    abi.encodeWithSignature(
                        "transferFrom(address,address,uint256)",
                        msg.sender,
                        to,
                        tokenId
                    )
                );
            } else {
                // If it's a CryptoPunk, use the specific `transferPunk` function.
                punkContract.call{value: 0}(
                    abi.encodeWithSignature("buyPunk(uint256)", tokenId)
                );

                (success, ) = punkContract.call(
                    abi.encodeWithSignature(
                        "transferPunk(address,uint256)",
                        to,
                        tokenId
                    )
                );
            }

            // Check the transfer status and gas consumption.
            if (!success || gasleft() < gasLeftStart / 2) {
                revert("Transfer failed");
            }
        }
    }

    // Explicitly reject any Ether sent to the contract
    fallback() external {
        revert("Contract does not accept Ether");
    }

    // Explicitly reject any Ether transfered to the contract
    receive() external payable {
        revert("Contract does not accept Ether");
    }
}
