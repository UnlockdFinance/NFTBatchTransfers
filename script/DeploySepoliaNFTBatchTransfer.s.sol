// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../src/NFTBatchTransfer.sol"; 

contract DeploySepoliaNFTBatchTransfer is Script {
  function run() public {
    vm.startBroadcast();
    // This 0x720b094Ab68D7306d1545AD615fDE974fA6D86D9 is the sepolia unlockd cryptoPunksMarket contract address
    new NFTBatchTransfer(0x720b094Ab68D7306d1545AD615fDE974fA6D86D9);
    vm.stopBroadcast();
  }
}