// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
 * @title NFTBatchTransfer
 * @dev This is a public contract in order to allow batch transfers of NFTs,
 * in a single transaction, reducing gas costs and improving efficiency.
 */
contract NFTBatchTransfer {

    // Immutable address for the CryptoPunks contract. This is set at deployment and cannot be changed afterwards.
    address immutable public punkContract;

    // Struct to encapsulate information about an individual NFT transfer.
    // It holds the address of the ERC721 contract and the specific token ID to be transferred.
    struct NftTransfer {
        address contractAddress;
        uint256 tokenId;
    }

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
    ) external {
        uint256 length = nftTransfers.length;

        // Capturing the initial gas at the start for later comparisons. Useful to preemptively identify
        // transactions that might run out of gas and revert them proactively.
        uint256 gasLeftStart = gasleft();

        // Iterate through each NFT in the array to facilitate the transfer.
        for(uint i = 0; i < length;) {
            address contractAddress = nftTransfers[i].contractAddress;
            uint256 tokenId = nftTransfers[i].tokenId;

            // Generate the signature for the `transferFrom` function of the ERC721 protocol.
            bytes4 signature = bytes4(keccak256("transferFrom(address,address,uint256)"));

            // Dynamically call the `transferFrom` function on the target ERC721 contract.
            (bool success, ) = address(uint160(contractAddress))
                                            .call(abi.encodeWithSelector(signature, msg.sender, to, tokenId));

            // If the transfer fails or consumes over half the starting gas, revert the transaction.
            if(!success || gasleft() < gasLeftStart/2) {
                revert("Transfer failed");
            }

            // Using unchecked block to prevent overflow checks on each loop iteration for efficiency.
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
    function batchPunkTransferFrom(NftTransfer[] calldata nftTransfers, address to) external {
        
        // Generating the signature for the `transferPunk` function specific to the CryptoPunks contract.
        bytes4 punkTransferSig = bytes4(keccak256("transferPunk(address,uint256)"));
        // If not a CryptoPunk, use the standard ERC721 `transferFrom` function.
        bytes4 erc721TransferSig = bytes4(keccak256("transferFrom(address,address,uint256)"));

        uint256 length = nftTransfers.length;
        uint256 gasLeftStart = gasleft();
        bool success;

        // Processing batch transfers, differentiating between CryptoPunks and other standard ERC721 tokens.
        for(uint i = 0; i < length; i++) {
            address contractAddr = nftTransfers[i].contractAddress;
            uint256 tokenId = nftTransfers[i].tokenId;

            if(contractAddr != punkContract) {
                (success, ) = contractAddr
                    .call(
                        abi.encodeWithSelector(
                            erc721TransferSig, 
                            msg.sender, 
                            to,
                            tokenId
                        )  
                    );
            }
            else {
                // If it's a CryptoPunk, use the specific `transferPunk` function.
                (success, ) = punkContract.call(
                    abi.encodeWithSelector(
                        punkTransferSig,
                        to,
                        tokenId 
                    )
                );
            }

            // Check the transfer status and gas consumption, reverting if necessary.
            if(!success || gasleft() < gasLeftStart/2) {
                revert("Transfer failed");
            } 
        }  
    }

    // Explicitly reject any Ether sent to the contract
    fallback() external {
        revert("Contract does not accept Ether");
    }
}