// /home/philljoe/projects/conditional-tokens/scripts/market-actions/ClaimRefund.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import the IMarketManagerUpgradeable interface
import "../../src/market/IMarketManagerUpgradeable.sol";

/**
 * @title ClaimRefundScript
 * @notice Script to claim a refund for a specific market using the MarketManagerUpgradeable contract.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract ClaimRefundScript is Script {
    /**
     * @notice Executes the refund claiming process.
     * @dev Retrieves necessary parameters from environment variables and calls claimRefund on MarketManager.
     */
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");

        // Validate inputs
        require(marketManagerAddress != address(0), "ClaimRefundScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "ClaimRefundScript: Invalid Market ID");

        vm.startBroadcast();

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);

        // Optional: Check if the market exists
        bool marketExists = bytes(marketManager.getMarketDetails(marketId).category).length > 0;
        require(marketExists, "ClaimRefundScript: Market does not exist");

        // Optional: Check if the market is active or resolved
        bool isActive = marketManager.isMarketActive(marketId);
        bool isResolved = marketManager.isMarketResolved(marketId);
        require(!isActive || isResolved, "ClaimRefundScript: Market is neither active nor resolved");

        // Optional: Check if the user has any refunds to claim
        // Note: This assumes that the contract has logic to handle refunds for active markets
        // If refunds are only available for canceled or unresolved markets, adjust accordingly
        // Also, assuming the user executing the script is the one claiming the refund

        // Claim the refund
        marketManager.claimRefund(marketId);

        // Log the refund claim
        console.log("Refund claimed successfully for Market ID:", toHexString(marketId));

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
