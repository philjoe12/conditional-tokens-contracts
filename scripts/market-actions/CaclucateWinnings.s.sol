// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library
import "forge-std/Script.sol";

// Import the IMarketManagerUpgradeable interface
import "../../src/market/IMarketManagerUpgradeable.sol";

/**
 * @title CalculateWinningsScript
 * @notice Script to calculate potential winnings from a specific market
 * @dev Utilizes Foundry's Script library for deployment and interaction
 */
contract CalculateWinningsScript is Script {
    /**
     * @notice Executes the winnings calculation process
     * @dev Calculates potential winnings for a given market ID and user
     */
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        address userAddress = vm.envAddress("USER_ADDRESS");

        // Validate inputs
        require(marketManagerAddress != address(0), "CalculateWinningsScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "CalculateWinningsScript: Invalid Market ID");
        require(userAddress != address(0), "CalculateWinningsScript: Invalid User address");

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);

        // Get market status
        bool isActive = marketManager.isMarketActive(marketId);
        bool isResolved = marketManager.isMarketResolved(marketId);

        // Get user's bet details
        (uint256 betAmount, uint256 outcomeIndex, bool withdrawn) = marketManager.getUserBet(marketId, userAddress);

        // Calculate potential winnings
        uint256 potentialWinnings = marketManager.getWinnings(marketId, userAddress);

        // Log all relevant information
        console.log("Market Calculation Results:");
        console.log("Market ID:", toHexString(marketId));
        console.log("User Address:", userAddress);
        console.log("Market Status:");
        console.log("  - Active:", isActive);
        console.log("  - Resolved:", isResolved);
        console.log("Bet Details:");
        console.log("  - Amount:", betAmount);
        console.log("  - Outcome Index:", outcomeIndex);
        console.log("  - Withdrawn:", withdrawn);
        console.log("Potential Winnings:", potentialWinnings);
    }

    /**
     * @notice Converts a bytes32 value to a hexadecimal string
     * @param _value The bytes32 value to convert
     * @return str The hexadecimal string representation
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