// /home/philljoe/projects/conditional-tokens/scripts/deploy/DeployLiquidityPool.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the LiquidityPoolUpgradeable implementation contract
import "../../src/market/LiquidityPoolUpgradeable.sol";

/**
 * @title DeployLiquidityPool
 * @notice Script to deploy the LiquidityPoolUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployLiquidityPool is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it, initializing with the required parameters.
     */
    function run() external {
        // Retrieve necessary addresses and parameters from environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address collateralToken = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        address rewardToken = vm.envAddress("REWARD_TOKEN_ADDRESS");
        address conditionalTokens = vm.envAddress("CONDITIONAL_TOKENS_ADDRESS");
        address oracleHandler = vm.envAddress("ORACLE_HANDLER_ADDRESS");
        uint256 rewardRate = vm.envUint("REWARD_RATE");

        // Validate inputs
        require(admin != address(0), "DeployLiquidityPool: Admin address cannot be zero");
        require(collateralToken != address(0), "DeployLiquidityPool: Collateral token address cannot be zero");
        require(rewardToken != address(0), "DeployLiquidityPool: Reward token address cannot be zero");
        require(conditionalTokens != address(0), "DeployLiquidityPool: ConditionalTokens address cannot be zero");
        require(oracleHandler != address(0), "DeployLiquidityPool: OracleHandler address cannot be zero");
        require(rewardRate > 0, "DeployLiquidityPool: Reward rate must be greater than zero");

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        LiquidityPoolUpgradeable implementation = new LiquidityPoolUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            LiquidityPoolUpgradeable.initialize.selector,
            admin,
            collateralToken,
            rewardToken,
            conditionalTokens,
            oracleHandler,
            rewardRate
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the LiquidityPoolUpgradeable interface for easier interaction
        LiquidityPoolUpgradeable liquidityPool = LiquidityPoolUpgradeable(address(proxy));

        // Output the deployed proxy address to the console
        console.log("LiquidityPoolUpgradeable Proxy deployed at:", address(liquidityPool));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
