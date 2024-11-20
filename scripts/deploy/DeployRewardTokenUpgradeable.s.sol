// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/contracts/RewardTokenUpgradeable.sol";

contract DeployRewardTokenUpgradeable is Script {
    function run() external {
        // Load environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        string memory tokenName = vm.envString("TOKEN_NAME");
        string memory tokenSymbol = vm.envString("TOKEN_SYMBOL");

        vm.startBroadcast();

        // Deploy implementation
        RewardTokenUpgradeable implementation = new RewardTokenUpgradeable();

        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                RewardTokenUpgradeable.initialize.selector,
                tokenName,
                tokenSymbol,
                admin
            )
        );

        RewardTokenUpgradeable rewardToken = RewardTokenUpgradeable(address(proxy));

        console.log("RewardTokenUpgradeable Proxy deployed at:", address(rewardToken));

        vm.stopBroadcast();
    }
}
