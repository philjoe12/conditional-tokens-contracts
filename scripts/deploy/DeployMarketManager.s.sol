// scripts/deploy/DeployMarketManager.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the MarketManagerUpgradeable implementation contract
import "../../src/market/MarketManagerUpgradeable.sol";

/**
 * @title DeployMarketManager
 * @notice Script to deploy the MarketManagerUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployMarketManager is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it, initializing with the required parameters.
     */
    function run() external {
        // Retrieve necessary addresses from environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address oracleHandler = vm.envAddress("ORACLE_HANDLER_ADDRESS");
        address conditionalTokens = vm.envAddress("CONDITIONAL_TOKENS_ADDRESS");
        address collateralToken = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        MarketManagerUpgradeable implementation = new MarketManagerUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            MarketManagerUpgradeable.initialize.selector,
            admin,
            oracleHandler,
            conditionalTokens,
            collateralToken
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the MarketManagerUpgradeable interface for easier interaction
        MarketManagerUpgradeable marketManager = MarketManagerUpgradeable(address(proxy));

        // Output the deployed proxy address to the console
        console.log("MarketManagerUpgradeable Proxy deployed at:", address(marketManager));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
