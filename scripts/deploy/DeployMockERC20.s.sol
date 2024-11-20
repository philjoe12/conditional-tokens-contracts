// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "lib/forge-std/src/Script.sol";

// Import your Token_ERC20 contract
import "../../src/collateral/MockERC20.sol";

/**
 * @title DeployMockERC20
 * @notice Script to deploy the Token_ERC20 contract, which inherits from MockERC20 and initializes it.
 */
contract DeployMockERC20 is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the Token_ERC20 contract with specified parameters.
     */
    function run() external {
        // Define token parameters
        string memory name = "Mock Token";     // You can also fetch this from environment variables if preferred
        string memory symbol = "MCK";          // Similarly, fetchable from environment variables
        uint8 decimals = 18;                    // Standard ERC20 decimals

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the Token_ERC20 contract, which initializes itself via the constructor
        MockERC20 token = new MockERC20();

        // Output the deployed token address to the console
        console.log("MockERC20 (Token_ERC20) deployed at:", address(token));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
