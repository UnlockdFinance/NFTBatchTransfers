// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
 * @title NFTBatchTransfer
 * @dev A smart contract to transfer multiple NFTs in a single transaction.
 */
contract NFTBatchTransfer {

    uint256 public immutable MAX_NFTS = 50;  // maximum number of NFTs that can be transferred in a single transaction
    
    struct NftTransfer {
        address contractAddress;
        uint256 tokenId;
    }

    // Custom errors
    error TooManyNfts(uint256 provided, uint256 maxAllowed);

    event TransferBatch(address indexed from, address indexed to, address[] contracts, uint256[] tokenIds);

    /**
     * @dev Transfers multiple NFTs from the caller to a recipient.
     * @param nftTransfers An array of NftTransfer structs.
     * @param to The address of the recipient.
     */
    function batchTransferFrom(
        NftTransfer[] calldata nftTransfers,
        address to
    ) external {
        if (nftTransfers.length > MAX_NFTS) {
            revert TooManyNfts(nftTransfers.length, MAX_NFTS);
        }

        address[] memory contracts = new address[](nftTransfers.length);
        uint256[] memory tokenIds = new uint256[](nftTransfers.length);

        for (uint i = 0; i < nftTransfers.length; i++) {
            contracts[i] = nftTransfers[i].contractAddress;
            tokenIds[i] = nftTransfers[i].tokenId;
            IERC721(nftTransfers[i].contractAddress).safeTransferFrom(msg.sender, to, nftTransfers[i].tokenId);
        }

        emit TransferBatch(msg.sender, to, contracts, tokenIds);
    }
}

