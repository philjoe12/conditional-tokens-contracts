// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "lib/forge-std/src/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the AccessControlManagerUpgradeable implementation contract
import "../../src/access/AccessControlManagerUpgradeable.sol";


/**
 * @title DeployAccessControlManager
 * @notice Script to deploy the AccessControlManagerUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployAccessControlManager is Script {
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
        AccessControlManagerUpgradeable implementation = new AccessControlManagerUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            AccessControlManagerUpgradeable.initialize.selector,
            admin
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the AccessControlManagerUpgradeable interface for easier interaction
        AccessControlManagerUpgradeable accessControlManager = AccessControlManagerUpgradeable(address(proxy));

        // Output the deployed proxy address to the console
        console.log("AccessControlManagerUpgradeable Proxy deployed at:", address(accessControlManager));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
