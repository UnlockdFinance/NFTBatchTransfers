// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

/**
 * @title IUSablierLockupLinear - Interface for the USablierLockupLinear contract
 **/
interface IUSablierLockupLinear {


    /*//////////////////////////////////////////////////////////////
                            CONTRACT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice validates is the given ERC20 token is allowed by the protocol (WETH and USDC).
     * @param asset the address of the ERC20 token
     */
    function isERC20Allowed(address asset) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                                ERC721
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Mints a new token.
     * @dev Mints a new ERC721 token representing a Sablier stream, verifies if the stream is cancelable and
     * and if the asset in the stream is supported by the protocol.
     * @param to The address to mint the token to.
     * @param tokenId The token ID to mint.
     */
    function mint(address to, uint256 tokenId) external;

    /**
     * @notice Burns a token.
     * @dev Burns a token, can only be called by the owner or approved address of the token.
     * @param to The address to burn the token to.
     * @param tokenId The token ID to burn.
     */
    function burn(address to, uint256 tokenId) external;
}