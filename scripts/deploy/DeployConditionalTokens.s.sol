// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ConditionalTokens.sol";

contract DeployConditionalTokens is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy ConditionalTokens contract
        ConditionalTokens conditionalTokens = new ConditionalTokens();

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the deployed address
        console.log("ConditionalTokens deployed at:", address(conditionalTokens));
    }
}