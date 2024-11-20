// scripts/deploy/DeployGovernanceManager.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the GovernanceManagerUpgradeable implementation contract
import "../../src/governance/GovernanceManagerUpgradeable.sol";

/**
 * @title DeployGovernanceManager
 * @notice Script to deploy the GovernanceManagerUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployGovernanceManager is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it, initializing with the admin address.
     */
    function run() external {
        // Retrieve the admin address from environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        GovernanceManagerUpgradeable implementation = new GovernanceManagerUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            GovernanceManagerUpgradeable.initialize.selector,
            admin
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the GovernanceManagerUpgradeable interface for easier interaction
        GovernanceManagerUpgradeable governanceManager = GovernanceManagerUpgradeable(address(proxy));

        // Output the deployed proxy address to the console
        console.log("GovernanceManagerUpgradeable Proxy deployed at:", address(governanceManager));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
