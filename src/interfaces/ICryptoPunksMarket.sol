// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title ICryptoPunksMarket
 * @author Unlockd
 * @notice Defines the basic interface to interact with PunksMarket.
 **/
interface ICryptoPunksMarket {
  function punkIndexToAddress(uint256 index) external view returns (address);
}