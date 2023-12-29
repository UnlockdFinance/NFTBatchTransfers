// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {IERC721Receiver} from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

import {MockACLManager} from './MockACLManager.sol';

/**
 * @title ERC721 Base Wrapper
 * @dev Implements a generic ERC721 wrapper for any NFT that needs to be "managed"
 **/
contract MockSoulbound is ERC721, IERC721Receiver {

    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/
    error TransferNotSupported();
    error ApproveNotSupported();
    error SetApprovalForAllNotSupported();
    error BurnerNotApproved();
    error ERC721ReceiverNotSupported();


    /*//////////////////////////////////////////////////////////////
                           VARIABLES
    //////////////////////////////////////////////////////////////*/
    ERC721 internal immutable _erc721;
    address internal _aclManager;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Emitted when a token is minted.
     * @param minter Address of the minter.
     * @param tokenId ID of the minted token.
     * @param to Address of the recipient.
     */
    event Mint(address indexed minter, uint256 tokenId, address indexed to);
    
    /**
     *  @notice Emitted when a token is burned.
     * @param burner Address of the burner.
     * @param tokenId ID of the burned token.
     * @param owner Address of the token owner.
     */
    event Burn(address indexed burner, uint256 tokenId, address indexed owner);

    /**
     * @dev Emitted when the contract is initialized.
     * @param name of the underlying asset.
     * @param symbol of the underlying asset.
     */
    event Initialized(string name, string symbol);

    /*//////////////////////////////////////////////////////////////
                            INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    /** 
     * @notice Initializes the underlying asset contract by setting the ERC721 address.
     * @param underlyingAsset The address of the underlying asset to be wrapped.
     */ 
    constructor (
        address underlyingAsset,
        string memory name, 
        string memory symbol
    ) ERC721(name, symbol) {
        _erc721 = ERC721(underlyingAsset);
    }

    /*//////////////////////////////////////////////////////////////
                            ERC721
    //////////////////////////////////////////////////////////////*/

    function preMintChecks(address, uint256) public virtual {}

    /**
     * @notice Mints a new token.
     * @dev Mints a new ERC721 token representing the underlying asset and stores the real asset in this contract.
     * @param to The address to mint the token to.
     * @param tokenId The token ID to mint.
     */
    function baseMint(address to, uint256 tokenId) public {
        _erc721.safeTransferFrom(msg.sender, address(this), tokenId);
        _mint(to, tokenId);

        emit Mint(msg.sender, tokenId, to);
    }

    /**
     * @notice Burns a token.
     * @dev Burns an ERC721 token and transfers the underlying asset to its owner.
     * @param tokenId The token ID to burn.
     */
    function baseBurn(uint256 tokenId, address to) public {
        if(!_isApprovedOrOwner(_msgSender(), tokenId)) revert BurnerNotApproved();
        
        _burn(tokenId);
        _erc721.safeTransferFrom(address(this), to, tokenId);

        emit Burn(msg.sender, tokenId, _erc721.ownerOf(tokenId));
    }

    /**
     * @dev See {ERC721-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _erc721.tokenURI(tokenId);
    }

    /**
     * @dev See {ERC721-approve}.
     */
    function approve(address, uint256) public pure override {
        revert ApproveNotSupported();
    }

    /**
     * @dev See {ERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address, bool) public pure override {
        revert SetApprovalForAllNotSupported();
    }

    /**
     * @dev See {ERC721-onERC721Received}.
     */
    function onERC721Received(
    address, 
    address, 
    uint256 tokenId, 
    bytes calldata data
    ) external override returns (bytes4) {
        if(msg.sender == address(_erc721)) {
        
            (address unlockdWallet) = abi.decode(data, (address));
            preMintChecks(unlockdWallet, tokenId);
            _mint(unlockdWallet, tokenId);
        }
        
        return this.onERC721Received.selector;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev See {ERC721-_transfer}.
     */
    function _transfer(address, address, uint256) internal pure override {
        revert TransferNotSupported();
    }
}