// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockERC721.sol"; 

contract DeployMockERC721Mfers is Script {
  function run() public {
    vm.startBroadcast();
    MockERC721 mfers = new MockERC721("MFERS", "MFERS");
    mfers.setBaseURI("ipfs://QmWiQE65tmpYzcokCheQmng2DCM33DEhjXcPB6PanwpAZo/");
    vm.stopBroadcast();
  }
}