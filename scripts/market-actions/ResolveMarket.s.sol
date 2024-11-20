// /home/philljoe/projects/conditional-tokens/scripts/market-actions/ResolveMarket.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library
import "forge-std/Script.sol";

// Import the IMarketManagerUpgradeable interface
import "../../src/market/IMarketManagerUpgradeable.sol";

/**
 * @title ResolveMarketScript
 * @notice Script to resolve a market by reporting the winning outcome.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract ResolveMarketScript is Script {
    /**
     * @notice Executes the market resolution process.
     * @dev Retrieves necessary parameters from environment variables and calls reportPayout on MarketManager.
     */
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        uint256 winningOutcomeIndex = vm.envUint("WINNING_OUTCOME_INDEX");

        // Validate inputs
        require(marketManagerAddress != address(0), "ResolveMarketScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "ResolveMarketScript: Invalid Market ID");
        // Assuming the winningOutcomeIndex is valid (should be less than the number of outcomes)
        require(winningOutcomeIndex >= 0, "ResolveMarketScript: Invalid winning outcome index");

        vm.startBroadcast();

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);

        // Optional: Check if the caller has the ORACLE_ROLE
        // If your interface includes the hasRole function from AccessControl
        // bytes32 ORACLE_ROLE = keccak256("ORACLE_ROLE");
        // require(marketManager.hasRole(ORACLE_ROLE, msg.sender), "ResolveMarketScript: Caller does not have ORACLE_ROLE");

        // Resolve the market by reporting the payout
        marketManager.reportPayout(marketId, winningOutcomeIndex);

        console.log("Market resolved successfully:");
        console.log("Market ID:", toHexString(marketId));
        console.log("Winning Outcome Index:", winningOutcomeIndex);

        vm.stopBroadcast();
    }

    /**
     * @notice Converts a bytes32 value to a hexadecimal string.
     * @param _value The bytes32 value to convert.
     * @return str The hexadecimal string representation.
     */
    function toHexString(bytes32 _value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + 64);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 32; i++) {
            str[2 + i * 2] = alphabet[uint8(_value[i] >> 4)];
            str[3 + i * 2] = alphabet[uint8(_value[i] & 0x0f)];
        }
        return string(str);
    }
}
