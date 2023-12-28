// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ICryptoPunksMarket} from "../src/interfaces/ICryptoPunksMarket.sol";
import {IUSablierLockupLinear} from "../src/interfaces/IUSablierLockupLinear.sol";
import {IACLManager} from '../src/interfaces/IACLManager.sol';

/**
 * @title NFTBatchTransfer
 * @dev This is a public contract in order to allow batch transfers of NFTs,
 * in a single transaction, reducing gas costs and improving efficiency.
 * It is designed to work with standard ERC721 contracts, as well as the CryptoPunks contract.
 * No events, use the ones from the ERC721 contract
 */
contract UnlockdBatchTransfer {

    /*//////////////////////////////////////////////////////////////
                             ERRORS
    //////////////////////////////////////////////////////////////*/
    error TransferFromFailed();
    error BuyFailed();
    error TransferFailed();
    error NotOwner();
    error CantReceiveETH();
    error Fallback();
    error NotProtocolOwner();
    
    /*//////////////////////////////////////////////////////////////
                            VARIABLES
    //////////////////////////////////////////////////////////////*/
    // Immutable address for the CryptoPunks contract. This is set at deployment and cannot be altered afterwards.
    address public immutable _punkContract;
    // Immutable address for the Unlockd ACLManager contract. This is set at deployment and cannot be altered afterwards.
    address public immutable _aclManager;

    // Mapping to keep track of which ERC721 contracts needs to be wrapped. 
    mapping(address => address) public toBeWrapped;

    /*//////////////////////////////////////////////////////////////
                              STRUCTS
    //////////////////////////////////////////////////////////////*/
    // Struct to encapsulate information about an individual NFT transfer.
    // It holds the address of the ERC721 contract and the specific token ID to be transferred.
    struct NftTransfer {
        address contractAddress;
        uint256 tokenId;
    }

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Modifier that checks if the sender has Protocol ROLE
     */
    modifier onlyProtocol() {
        if (IACLManager(_aclManager).isProtocol(msg.sender) != true) {
            revert NotProtocolOwner();
        } 
        _;
    }

    /*//////////////////////////////////////////////////////////////
                          INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Constructor to set the initial state of the contract.
     * @param punkContract The address of the CryptoPunks contract.
     * @param aclManager The address of the ACLManager contract.
     */
    constructor(address punkContract, address aclManager) {
        _punkContract = punkContract;
        _aclManager = aclManager;
    }

    /*//////////////////////////////////////////////////////////////
                    Fallback and Receive Functions
    //////////////////////////////////////////////////////////////*/
    // Explicitly reject any Ether sent to the contract
    fallback() external payable {
        revert Fallback();
    }

    // Explicitly reject any Ether transfered to the contract
    receive() external payable {
        revert CantReceiveETH();
    }

    /*//////////////////////////////////////////////////////////////
                          LOGIC
    //////////////////////////////////////////////////////////////*/
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

            // Check the transfer status.
            if (!success) {
                revert TransferFromFailed();
            }

            if(isToBeWrapped(contractAddress) != address(0)) {
                _wrapNFT(contractAddress, tokenId, to);
            }

            // Use unchecked block to bypass overflow checks for efficiency.
            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev Manages a batch transfer of NFTs, that allow the use of 
     * CryptoPunks alongside other standard ERC721 NFTs.
     * @param nftTransfers An array of NftTransfer structs specifying the NFTs for transfer.
     * @param to The destination address for the NFTs.
     */
    function batchPunkTransferFrom(
        NftTransfer[] calldata nftTransfers,
        address to
    ) external payable {
        uint256 length = nftTransfers.length;
        bool success;

        // Process batch transfers, differentiate between CryptoPunks and standard ERC721 tokens.
        for (uint i = 0; i < length;) {
            address contractAddr = nftTransfers[i].contractAddress;
            uint256 tokenId = nftTransfers[i].tokenId;

            // Check if the NFT is a CryptoPunk.
            if (contractAddr != _punkContract) {
                // If it's not a CryptoPunk, use the standard ERC721 `transferFrom` function.
                (success, ) = contractAddr.call(
                    abi.encodeWithSignature(
                        "transferFrom(address,address,uint256)",
                        msg.sender,
                        to,
                        tokenId
                    )
                );

                if(isToBeWrapped(contractAddr) != address(0)) {
                    _wrapNFT(contractAddr, tokenId, to);
                }
            } 
            // If it's a CryptoPunk, use the CryptoPunksMarket contract to transfer the punk.
            else { 
                // Verify OwnerShip
                if(ICryptoPunksMarket(_punkContract).punkIndexToAddress(tokenId) != msg.sender) 
                    revert NotOwner();
                
                // If it's a CryptoPunk, first the contract buy the punk to be allowed to transfer it.
                (success, ) = _punkContract.call{value: 0}(
                    abi.encodeWithSignature("buyPunk(uint256)", tokenId)
                );

                // Check the buyPunk status
                if (!success) {
                    revert BuyFailed();
                }

                // Once the punk is owned by the contract, the transfer method is executed
                (success, ) = _punkContract.call(
                    abi.encodeWithSignature(
                        "transferPunk(address,uint256)",
                        to,
                        tokenId
                    )
                );
                
                // Check the transfer status.
                if (!success) {
                    revert TransferFailed();
                }
            }

            // Use unchecked block to bypass overflow checks for efficiency.
            unchecked { 
                i++; 
            }
        }
    }

    function _wrapNFT(address asset, uint256 tokenId, address to) internal {
        address wrapContract = toBeWrapped[asset];
        IUSablierLockupLinear(wrapContract).mint(to, tokenId); 
    }

    /*//////////////////////////////////////////////////////////////
                        GETTERS AND SETTERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Sets the value of the toBeWrapped mapping for a given asset.
     * @param asset the address of the asset to be set
     * @param wrapper the address of the wrapped asset
     */
    function setToBeWrapped(address asset, address wrapper) external onlyProtocol {
        toBeWrapped[asset] = wrapper;
    }

    /**
     * @notice Checks if an asset is to be wrapped.
     * @param asset the address of the asset to be checked
     */
    function isToBeWrapped(address asset) public view returns (address) {
        return toBeWrapped[asset];
    }
}