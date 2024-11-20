// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "lib/forge-std/src/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the FixedProductMarketMakerUpgradeable implementation contract
import "../../src/market/FixedProductMarketMakerUpgradeable.sol";

/**
 * @title DeployFixedProductMarketMaker
 * @notice Script to deploy the FixedProductMarketMakerUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployFixedProductMarketMaker is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it,
     *      initializing with the admin address, collateral token, fee manager, and conditional tokens addresses.
     */
    function run() external {
        // Retrieve environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address collateralToken = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        address feeManagerProxy = vm.envAddress("FEE_MANAGER_PROXY_ADDRESS");
        address conditionalTokensProxy = vm.envAddress("CONDITIONAL_TOKENS_PROXY_ADDRESS");
        uint256 initialLiquidity = vm.envUint("INITIAL_LIQUIDITY"); // e.g., 1000 tokens with 18 decimals

        // Validate environment variables
        require(admin != address(0), "DeployFPMM: ADMIN_ADDRESS is zero");
        require(collateralToken != address(0), "DeployFPMM: COLLATERAL_TOKEN_ADDRESS is zero");
        require(feeManagerProxy != address(0), "DeployFPMM: FEE_MANAGER_PROXY_ADDRESS is zero");
        require(conditionalTokensProxy != address(0), "DeployFPMM: CONDITIONAL_TOKENS_PROXY_ADDRESS is zero");
        // initialLiquidity can be zero or any value based on contract requirements

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        FixedProductMarketMakerUpgradeable implementation = new FixedProductMarketMakerUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            FixedProductMarketMakerUpgradeable.initialize.selector,
            admin,
            collateralToken,
            feeManagerProxy,
            conditionalTokensProxy,
            initialLiquidity
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the FixedProductMarketMakerUpgradeable interface for easier interaction
        FixedProductMarketMakerUpgradeable fixedProductMarketMaker = FixedProductMarketMakerUpgradeable(address(proxy));

        // Output the deployed proxy address to the console
        console.log("FixedProductMarketMakerUpgradeable Proxy deployed at:", address(fixedProductMarketMaker));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
