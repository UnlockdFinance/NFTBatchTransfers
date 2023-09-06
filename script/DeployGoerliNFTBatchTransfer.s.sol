// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../src/NFTBatchTransfer.sol"; 

contract DeployGoerliNFTBatchTransfer is Script {
  function run() public {
    vm.startBroadcast();
    // This 0x3aFE908110e5c5275Bc96a9e42DB1B322590bDa4 is the goerli unlockd cryptoPunksMarket contract address
    new NFTBatchTransfer(0x3aFE908110e5c5275Bc96a9e42DB1B322590bDa4);
    vm.stopBroadcast();
  }
}