// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../src/NFTBatchTransfer.sol"; 

contract DeployNFTBatchTransfer is Script {
  function run() public {
    vm.startBroadcast();
    // Goerli: 0x3aFE908110e5c5275Bc96a9e42DB1B322590bDa4
    // Sepolia: 0x720b094Ab68D7306d1545AD615fDE974fA6D86D9
    // Mainnet: 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB
    new NFTBatchTransfer(0x720b094Ab68D7306d1545AD615fDE974fA6D86D9);
    vm.stopBroadcast();
  }
}