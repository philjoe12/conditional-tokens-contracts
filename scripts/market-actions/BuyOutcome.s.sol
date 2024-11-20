// /home/philljoe/projects/conditional-tokens/scripts/market-actions/BuyOutcome.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/conditional/IConditionalTokensUpgradeable.sol";


/**
 * @title BuyOutcomeScript
 * @notice Script to facilitate the purchase of specific outcomes in a prediction market.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract BuyOutcomeScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the outcome purchase process.
     * @dev Retrieves necessary parameters from environment variables, approves token transfer, and buys the outcome.
     */
    function run() external {
        // Load environment variables
        address conditionalTokensAddress = vm.envAddress("CONDITIONAL_TOKENS_PROXY_ADDRESS");
        address collateralTokenAddress = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        address userAddress = vm.envAddress("USER_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        bytes32 outcomeId = vm.envBytes32("OUTCOME_ID");
        uint256 purchaseAmount = vm.envUint("PURCHASE_AMOUNT"); // Amount to spend in collateralToken's smallest unit

        // Validate inputs
        require(conditionalTokensAddress != address(0), "BuyOutcomeScript: Invalid ConditionalTokens address");
        require(collateralTokenAddress != address(0), "BuyOutcomeScript: Invalid Collateral Token address");
        require(userAddress != address(0), "BuyOutcomeScript: Invalid User address");
        require(purchaseAmount > 0, "BuyOutcomeScript: Purchase amount must be greater than zero");
        require(marketId != bytes32(0), "BuyOutcomeScript: Invalid Market ID");
        require(outcomeId != bytes32(0), "BuyOutcomeScript: Invalid Outcome ID");

        vm.startBroadcast();

        // Cast to ConditionalTokensUpgradeable interface
        IConditionalTokensUpgradeable conditionalTokens = IConditionalTokensUpgradeable(conditionalTokensAddress);

        // Cast to IERC20Upgradeable interface for collateral token
        IERC20Upgradeable collateralToken = IERC20Upgradeable(collateralTokenAddress);

        // Approve the ConditionalTokensUpgradeable contract to spend the purchaseAmount
        collateralToken.safeApprove(conditionalTokensAddress, purchaseAmount);
        console.log("Approved ConditionalTokens to spend", purchaseAmount, "collateral tokens");

        // Buy the specified outcome
        conditionalTokens.buyOutcome(marketId, outcomeId, purchaseAmount);
        console.log(
            "Purchased Outcome:",
            outcomeId,
            "in Market:",
            marketId,
            "with Amount:",
            purchaseAmount,
            "collateral tokens"
        );

        vm.stopBroadcast();
    }
}
