// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockCustomERC721.sol";

contract DeployMockCustomERC721 is Script {
  function run() public {
    vm.startBroadcast();
    MockCustomERC721 mockCustomERC721 = new MockCustomERC721("BAYC", "BAYC");
    mockCustomERC721.setBaseURI("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
    vm.stopBroadcast();
  }
}