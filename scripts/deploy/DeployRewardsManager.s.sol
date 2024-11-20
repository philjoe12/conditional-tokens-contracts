// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/forge-std/src/Script.sol";
import "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/rewards/RewardsManagerUpgradeable.sol";

contract DeployRewardsManager is Script {
    function run() external {
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address rewardsToken = vm.envAddress("REWARDS_TOKEN_ADDRESS");
        address marketManager = vm.envAddress("MARKET_MANAGER_ADDRESS");

        vm.startBroadcast();

        RewardsManagerUpgradeable implementation = new RewardsManagerUpgradeable();

        bytes memory initializer = abi.encodeWithSelector(
            RewardsManagerUpgradeable.initialize.selector,
            admin,
            rewardsToken,
            marketManager
        );

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        console.log("RewardsManagerUpgradeable Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}