// /home/philljoe/projects/conditional-tokens/scripts/market-actions/AddLiquidity.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import the LiquidityPoolUpgradeable implementation contract
import "../../src/market/LiquidityPoolUpgradeable.sol";

// Import OpenZeppelin's IERC20Upgradeable and SafeERC20Upgradeable for ERC20 interactions


/**
 * @title AddLiquidityScript
 * @notice Script to add liquidity by staking collateral tokens into the LiquidityPoolUpgradeable contract.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract AddLiquidityScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the liquidity addition process.
     * @dev Retrieves necessary parameters from environment variables, approves token transfer, and stakes tokens.
     */
    function run() external {
        // Load environment variables
        address liquidityPoolAddress = vm.envAddress("LIQUIDITY_POOL_PROXY_ADDRESS");
        address collateralTokenAddress = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        uint256 stakeAmount = vm.envUint("STAKE_AMOUNT"); // Amount to stake in collateralToken's smallest unit

        // Validate inputs
        require(liquidityPoolAddress != address(0), "AddLiquidityScript: Invalid LiquidityPool address");
        require(collateralTokenAddress != address(0), "AddLiquidityScript: Invalid Collateral Token address");
        require(stakeAmount > 0, "AddLiquidityScript: Stake amount must be greater than zero");

        vm.startBroadcast();

        // Cast to LiquidityPoolUpgradeable interface
        LiquidityPoolUpgradeable liquidityPool = LiquidityPoolUpgradeable(liquidityPoolAddress);

        // Cast to IERC20Upgradeable interface for collateral token
        IERC20Upgradeable collateralToken = IERC20Upgradeable(collateralTokenAddress);

        // Approve the LiquidityPoolUpgradeable contract to spend the stakeAmount
        collateralToken.safeApprove(liquidityPoolAddress, stakeAmount);
        console.log("Approved LiquidityPool to spend", stakeAmount, "collateral tokens");

        // Stake the collateral tokens
        liquidityPool.stake(stakeAmount);
        console.log("Staked", stakeAmount, "collateral tokens to LiquidityPool at:", liquidityPoolAddress);

        vm.stopBroadcast();
    }
}
