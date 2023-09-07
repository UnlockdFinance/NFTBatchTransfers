// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockPunkMarket.sol";

contract DeployMockPunkMarket is Script {
  function run() public {
    vm.startBroadcast();
    MockPunkMarket mockPunkMarket = new MockPunkMarket();
    mockPunkMarket.allInitialOwnersAssigned();
    vm.stopBroadcast();
  }
}