// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../src/NFTBatchTransfer.sol"; 

contract DeployNFTBatchTransfer is Script {
  function run() public {
    vm.startBroadcast();
    new NFTBatchTransfer();
    vm.stopBroadcast();
  }
}