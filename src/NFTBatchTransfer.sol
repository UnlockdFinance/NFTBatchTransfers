// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
 * @title NFTBatchTransfer
 * @dev This is a public contract in order to allow batch transfers of NFTs,
 * in a single transaction, reducing gas costs and improving efficiency.
 * It is designed to work with standard ERC721 contracts
 * No events, use the ones from the ERC721 contract
 */
contract NFTBatchTransfer {

    // Struct to encapsulate information about an individual NFT transfer.
    // It holds the address of the ERC721 contract and the specific token ID to be transferred.
    struct NftTransfer {
        address contractAddress;
        uint256 tokenId;
    }

    /**
     * @dev Constructor to set the initial state of the contract.
    **/
    constructor() {}

    /**
     * @dev Orchestrates a batch transfer of standard ERC721 NFTs.
     * @param nftTransfers An array of NftTransfer structs detailing the NFTs to be moved.
     * @param to The recipient's address.
     */
    function batchTransferFrom(
        NftTransfer[] calldata nftTransfers,
        address to
    ) external payable {
        uint256 length = nftTransfers.length;

        // Capturing the initial gas at the start for later comparisons.
        uint256 gasLeftStart = gasleft();

        // Iterate through each NFT in the array to facilitate the transfer.
        for (uint i = 0; i < length;) {
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
                revert("Gas too low");
            }

            // Use unchecked block to bypass overflow checks for efficiency.
            unchecked {
                i++;
            }
        }
    }

    // Explicitly reject any Ether sent to the contract
    fallback() external payable {
        revert("Fallback not allowed");
    }

    // Explicitly reject any Ether transfered to the contract
    receive() external payable {
        revert("Contract does not accept Ether");
    }
}
