// /home/philljoe/projects/conditional-tokens/scripts/market-actions/UpdateMarketMetadata.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library
import "forge-std/Script.sol";

// Import interfaces
import "../../src/market/IMarketManagerUpgradeable.sol";

/**
 * @title UpdateMarketMetadataScript
 * @notice Script to update metadata of an existing market.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract UpdateMarketMetadataScript is Script {
    /**
     * @notice Executes the market metadata update process.
     * @dev Updates category, description, fee, and other metadata for a given market.
     */
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        string memory newCategory = vm.envString("NEW_CATEGORY");
        string memory newDescription = vm.envString("NEW_DESCRIPTION");
        uint256 newFee = vm.envUint("NEW_FEE"); // Fee in basis points
        bool newActiveStatus = vm.envBool("NEW_ACTIVE_STATUS");
        bool newAcceptingOrders = vm.envBool("NEW_ACCEPTING_ORDERS");
        // Add more metadata fields as needed

        // Validate inputs
        require(marketManagerAddress != address(0), "UpdateMarketMetadataScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "UpdateMarketMetadataScript: Invalid Market ID");
        require(bytes(newCategory).length > 0, "UpdateMarketMetadataScript: New category cannot be empty");
        require(bytes(newDescription).length > 0, "UpdateMarketMetadataScript: New description cannot be empty");
        require(newFee <= 10000, "UpdateMarketMetadataScript: Fee cannot exceed 100%");

        vm.startBroadcast();

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);

        // Call updateMarketMetadata on MarketManagerUpgradeable
        marketManager.updateMarketMetadata(
            marketId,
            newCategory,
            newDescription,
            newFee,
            newActiveStatus,
            newAcceptingOrders
            // Add more metadata fields as needed
        );

        console.log("Updated metadata for market ID:", toHexString(marketId));

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
