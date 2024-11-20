// /home/philljoe/projects/conditional-tokens/scripts/market-actions/WithdrawWinnings.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library
import "forge-std/Script.sol";

// Import the IMarketManagerUpgradeable interface
import "../../src/market/IMarketManagerUpgradeable.sol";

/**
 * @title WithdrawWinningsScript
 * @notice Script to withdraw winnings from a specific market.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract WithdrawWinningsScript is Script {
    /**
     * @notice Executes the winnings withdrawal process.
     * @dev Withdraws winnings for a given market ID and user.
     */
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        address userAddress = vm.envAddress("USER_ADDRESS"); // Address of the user withdrawing winnings

        // Validate inputs
        require(marketManagerAddress != address(0), "WithdrawWinningsScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "WithdrawWinningsScript: Invalid Market ID");
        require(userAddress != address(0), "WithdrawWinningsScript: Invalid User address");

        vm.startBroadcast();

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);
 
        // Optional: Check if the market has been resolved
        bool isResolved = marketManager.isMarketResolved(marketId);
        require(isResolved, "WithdrawWinningsScript: Market is not yet resolved");

        // Optional: Check if the user has winnings to withdraw
        uint256 winnings = marketManager.getWinnings(marketId, userAddress);
        require(winnings > 0, "WithdrawWinningsScript: No winnings to withdraw");

        // Withdraw winnings
        marketManager.withdrawWinnings(marketId, userAddress);

        console.log("Winnings withdrawn successfully:");
        console.log("Market ID:", toHexString(marketId));
        console.log("User Address:", userAddress);
        console.log("Amount Withdrawn:", winnings);

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
