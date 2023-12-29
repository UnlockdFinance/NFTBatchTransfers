// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title DelegationWalletRegistry
 * @author BootNode
 * @dev Registry contract that store information related to the Delegation Wallets deployed by the
 * DelegationWalletFactory contract. This contract can be used as a reliable source to validate that a given address is
 * a valid Delegation Wallet.
 */
contract MockDelegationWalletRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;

    ////////////////////////////////////////////
    //  Errors
    ////////////////////////////////////////////
    error DelegationWalletRegistry__setFactory_invalidAddress();
    error DelegationWalletRegistry__setWallet_invalidWalletAddress();
    error DelegationWalletRegistry__setWallet_invalidOwnerAddress();

    ////////////////////////////////////////////
    //  Structs
    ////////////////////////////////////////////
    struct Wallet {
        address wallet;
        address owner;
    }

    ////////////////////////////////////////////
    //  Variables
    ////////////////////////////////////////////
    /**
     * @notice Stores the DelegationWallets deployed by the factory indexed by the address of the Safe component.
     */
    mapping(address => Wallet) internal wallets;

    /**
     * @notice Stores the addresses of DelegationWallets Safe component deployed for the same owner.
     */
    mapping(address => EnumerableSet.AddressSet) internal walletsByOwner;

    ////////////////////////////////////////////
    //  Initialization
    ////////////////////////////////////////////
    constructor() {}

    ////////////////////////////////////////////
    //  External functions
    ////////////////////////////////////////////
    /**
     * @notice Sets a new deployed Wallet.
     * @param _wallet - The address of the DelegationWallet's Safe component.
     * @param _owner - The address of the DelegationWallet's owner component.
     */
    function setWallet(
        address _wallet,
        address _owner
    ) external {
        if (_wallet == address(0)) revert DelegationWalletRegistry__setWallet_invalidWalletAddress();
        if (_owner == address(0)) revert DelegationWalletRegistry__setWallet_invalidOwnerAddress();
        
        wallets[_wallet] = Wallet(_wallet, _owner);

        walletsByOwner[_owner].add(_wallet);
    }

    /**
     * @notice Returns the Wallet info for a given Safe component.
     * @param _wallet - The address of the DelegationWallet's Safe component.
     */
    function getWallet(address _wallet) external view returns (Wallet memory) {
        return wallets[_wallet];
    }

    /**
     * @notice Returns the entire set of Wallets for a given owner.
     * @param _owner - The address of the DelegationWallet's owner component.
     * @dev WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is
     * designed to mostly be used by view accessors that are queried without any gas fees. Developers should keep in
     * mind that this function has an unbounded cost, and using it as part of a state-changing function may render the
     * function uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function getOwnerWalletAddresses(address _owner) external view returns (address[] memory) {
        return walletsByOwner[_owner].values();
    }

    /**
     * @notice Returns the `_index` Wallet for a given owner.
     * @param _owner - The address of the DelegationWallet's owner component.
     * @param _index - The index of the wallet in the set of wallets deployed for the `owner`, the firs element is at
     * index 1.
     */
    function getOwnerWalletAt(address _owner, uint256 _index) external view returns (Wallet memory) {
        return wallets[walletsByOwner[_owner].at(_index)];
    }
}
