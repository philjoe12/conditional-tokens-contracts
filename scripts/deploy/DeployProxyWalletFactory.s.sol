// scripts/deploy/DeployProxyWalletFactory.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the ProxyWalletFactoryUpgradeable implementation contract
import "../../src/proxy/ProxyWalletFactoryUpgradeable.sol";

/**
 * @title DeployProxyWalletFactory
 * @notice Script to deploy the ProxyWalletFactoryUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployProxyWalletFactory is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it, initializing with the required parameters.
     */
    function run() external {
        // Retrieve necessary addresses and parameters from environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        // Add other initialization parameters if required by your contract's initializer
        // For example:
        // address someDependency = vm.envAddress("SOME_DEPENDENCY_ADDRESS");
        // uint256 initialParameter = vm.envUint("INITIAL_PARAMETER");

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        ProxyWalletFactoryUpgradeable implementation = new ProxyWalletFactoryUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        // Adjust the parameters based on your initializer's signature
        bytes memory initializer = abi.encodeWithSelector(
            ProxyWalletFactoryUpgradeable.initialize.selector,
            admin
            // , someDependency, initialParameter // Include additional parameters if needed
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the ProxyWalletFactoryUpgradeable interface for easier interaction
        ProxyWalletFactoryUpgradeable proxyWalletFactory = ProxyWalletFactoryUpgradeable(address(proxy));

        // Optionally, perform additional setup or role assignments if necessary
        // For example, if the deployer needs to transfer roles to the admin:
        // if (admin != msg.sender) {
        //     proxyWalletFactory.grantRole(proxyWalletFactory.ADMIN_ROLE(), admin);
        //     proxyWalletFactory.grantRole(proxyWalletFactory.SOME_OTHER_ROLE(), admin);
        //
        //     // Optionally revoke roles from deployer
        //     proxyWalletFactory.revokeRole(proxyWalletFactory.DEFAULT_ADMIN_ROLE(), msg.sender);
        // }

        // Output the deployed proxy address to the console
        console.log("ProxyWalletFactoryUpgradeable Proxy deployed at:", address(proxyWalletFactory));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
