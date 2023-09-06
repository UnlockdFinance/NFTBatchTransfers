// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../src/NFTBatchTransfer.sol"; 

contract DeployMainNFTBatchTransfer is Script {
  function run() public {
    vm.startBroadcast();
    new NFTBatchTransfer(0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB);
    vm.stopBroadcast();
  }
}