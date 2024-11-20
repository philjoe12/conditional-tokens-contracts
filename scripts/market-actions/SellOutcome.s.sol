// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/conditional/IConditionalTokensUpgradeable.sol";


/**
 * @title SellOutcomeScript
 * @notice Script to facilitate the sale of specific outcomes in a prediction market.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract SellOutcomeScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the outcome sale process.
     * @dev Retrieves necessary parameters from environment variables, approves token transfer, and sells the outcome.
     */
    function run() external {
        // Load environment variables
        address conditionalTokensAddress = vm.envAddress("CONDITIONAL_TOKENS_PROXY_ADDRESS");
        address outcomeTokenAddress = vm.envAddress("OUTCOME_TOKEN_ADDRESS");
        address userAddress = vm.envAddress("USER_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        bytes32 outcomeId = vm.envBytes32("OUTCOME_ID");
        uint256 sellAmount = vm.envUint("SELL_AMOUNT"); // Amount to sell in outcomeToken's smallest unit

        // Validate inputs
        require(conditionalTokensAddress != address(0), "SellOutcomeScript: Invalid ConditionalTokens address");
        require(outcomeTokenAddress != address(0), "SellOutcomeScript: Invalid Outcome Token address");
        require(userAddress != address(0), "SellOutcomeScript: Invalid User address");
        require(sellAmount > 0, "SellOutcomeScript: Sell amount must be greater than zero");
        require(marketId != bytes32(0), "SellOutcomeScript: Invalid Market ID");
        require(outcomeId != bytes32(0), "SellOutcomeScript: Invalid Outcome ID");

        vm.startBroadcast();

        // Cast to ConditionalTokensUpgradeable interface
        IConditionalTokensUpgradeable conditionalTokens = IConditionalTokensUpgradeable(conditionalTokensAddress);

        // Cast to IERC20Upgradeable interface for outcome token
        IERC20Upgradeable outcomeToken = IERC20Upgradeable(outcomeTokenAddress);

        // Approve the ConditionalTokensUpgradeable contract to spend the sellAmount
        outcomeToken.safeApprove(conditionalTokensAddress, sellAmount);
        console.log("Approved ConditionalTokens to spend", sellAmount, "outcome tokens");

        // Sell the specified outcome
        conditionalTokens.sellOutcome(marketId, outcomeId, sellAmount);
        console.log(
            "Sold Outcome:",
            outcomeId,
            "in Market:",
            marketId,
            "for Amount:",
            sellAmount,
            "outcome tokens"
        );

        vm.stopBroadcast();
    }
}
