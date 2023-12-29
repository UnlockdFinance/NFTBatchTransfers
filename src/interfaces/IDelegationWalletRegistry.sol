// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

interface IDelegationWalletRegistry {
    struct Wallet {
        address wallet;
        address owner;
        address guard;
        address guardOwner;
        address delegationOwner;
        address protocolOwner;
    }

    function setFactory(address _delegationWalletFactory) external;

    function setWallet(
        address _wallet,
        address _owner,
        address _guard,
        address _guardOwner,
        address _delegationGuard,
        address _protocolOwner
    ) external;

    function getWallet(address _wallet) external view returns (Wallet memory);

    function getOwnerWalletAddresses(address _owner) external view returns (address[] memory);

    function getOwnerWalletAt(address _owner, uint256 _index) external view returns (Wallet memory);
}
