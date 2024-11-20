// scripts/deploy/DeployOracleHandler.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the OracleHandlerUpgradeable implementation contract
import "../../src/oracle/OracleHandlerUpgradeable.sol";

/**
 * @title DeployOracleHandler
 * @notice Script to deploy the OracleHandlerUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployOracleHandler is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it, initializing with the required parameters.
     */
    function run() external {
        // Retrieve necessary addresses from environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        OracleHandlerUpgradeable implementation = new OracleHandlerUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            OracleHandlerUpgradeable.initialize.selector,
            admin
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the OracleHandlerUpgradeable interface for easier interaction
        OracleHandlerUpgradeable oracleHandler = OracleHandlerUpgradeable(address(proxy));

        // Output the deployed proxy address to the console
        console.log("OracleHandlerUpgradeable Proxy deployed at:", address(oracleHandler));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
