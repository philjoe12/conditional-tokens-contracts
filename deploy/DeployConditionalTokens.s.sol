// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/Script.sol";
import "../src/ConditionalTokens.sol";
contract DeployConditionalTokens is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the ConditionalTokens contract
        ConditionalTokens conditionalTokens = new ConditionalTokens();

        console.log("ConditionalTokens deployed at:", address(conditionalTokens));
        vm.stopBroadcast();
    }
}
