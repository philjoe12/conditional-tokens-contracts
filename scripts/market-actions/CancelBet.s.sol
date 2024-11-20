// /home/philljoe/projects/conditional-tokens/scripts/market-actions/CancelBet.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library
import "forge-std/Script.sol";

// Import the MarketManager interface
import "../../src/market/IMarketManagerUpgradeable.sol";

/**
 * @title CancelBetScript
 * @notice Script to cancel a bet on a specific market and outcome.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract CancelBetScript is Script {
    /**
     * @notice Executes the bet cancellation process.
     * @dev Cancels a bet for a given market ID and outcome index.
     */
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        uint256 outcomeIndex = vm.envUint("OUTCOME_INDEX");
        address userAddress = vm.envAddress("USER_ADDRESS"); // Address of the user canceling the bet

        // Validate inputs
        require(marketManagerAddress != address(0), "CancelBetScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "CancelBetScript: Invalid Market ID");
        require(outcomeIndex < 2, "CancelBetScript: Invalid Outcome Index"); // Assuming binary outcomes (0 or 1)

        vm.startBroadcast();

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);

        // Optional: Check if the market is accepting orders or if the user has an active bet
        bool isActive = marketManager.getMarketStatus(marketId);
        require(isActive, "CancelBetScript: Market is not active");

        bool isAcceptingOrders = marketManager.isAcceptingOrders(marketId);
        require(isAcceptingOrders, "CancelBetScript: Market is not accepting orders");

        // Optional: Retrieve user's current bet details (if the contract supports it)
        // (This requires the MarketManagerUpgradeable to have a function like getUserBet)
        // (Assuming such a function exists)
        // (If not, this part can be omitted or adjusted based on actual contract functionality)
        /*
        (uint256 currentBetAmount, bool hasActiveBet) = marketManager.getUserBet(marketId, userAddress, outcomeIndex);
        require(hasActiveBet, "CancelBetScript: No active bet to cancel");
        require(currentBetAmount > 0, "CancelBetScript: Bet amount is zero");
        */

        // Cancel the bet
        marketManager.cancelBet(marketId, outcomeIndex, userAddress);

        console.log("Bet canceled successfully:");
        console.log("Market ID:", toHexString(marketId));
        console.log("Outcome Index:", outcomeIndex);
        console.log("User Address:", userAddress);

        vm.stopBroadcast();
    }

    /**
     * @notice Converts a bytes32 value to a hexadecimal string.
     * @param _value The bytes32 value to convert.
     * @return str The hexadecimal string representation.
     */
    function toHexString(bytes32 _value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + _value.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < _value.length; i++) {
            str[2 + i * 2] = alphabet[uint8(_value[i] >> 4)];
            str[3 + i * 2] = alphabet[uint8(_value[i] & 0x0f)];
        }
        return string(str);
    }
}
