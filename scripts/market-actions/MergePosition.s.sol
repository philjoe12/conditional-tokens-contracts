// /home/philljoe/projects/conditional-tokens/scripts/market-actions/MergePosition.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import the IConditionalTokensUpgradeable interface
import "../../src/conditional/IConditionalTokensUpgradeable.sol";

// Import OpenZeppelin's IERC20Upgradeable and SafeERC20Upgradeable for ERC20 interactions


/**
 * @title MergePositionScript
 * @notice Script to merge positions in the Conditional Tokens framework using the ConditionalTokensUpgradeable contract.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract MergePositionScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the position merging process.
     * @dev Retrieves necessary parameters from environment variables and calls mergePositions on ConditionalTokens.
     */
    function run() external {
        // Load environment variables
        address conditionalTokensAddress = vm.envAddress("CONDITIONAL_TOKENS_ADDRESS");
        address collateralTokenAddress = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        bytes32 conditionId = vm.envBytes32("CONDITION_ID");
        uint256[] memory partition = parsePartition(vm.envString("PARTITION")); // Comma-separated outcome indexes
        uint256 amount = vm.envUint("AMOUNT"); // Amount of collateral tokens to merge

        // Validate inputs
        require(conditionalTokensAddress != address(0), "MergePositionScript: Invalid ConditionalTokens address");
        require(collateralTokenAddress != address(0), "MergePositionScript: Invalid Collateral Token address");
        require(conditionId != bytes32(0), "MergePositionScript: Invalid Condition ID");
        require(partition.length > 0, "MergePositionScript: Partition cannot be empty");
        require(amount > 0, "MergePositionScript: Amount must be greater than zero");

        vm.startBroadcast();

        // Cast to IConditionalTokensUpgradeable interface
        IConditionalTokensUpgradeable conditionalTokens = IConditionalTokensUpgradeable(conditionalTokensAddress);

        // Cast to IERC20Upgradeable interface for collateral token
        IERC20Upgradeable collateralToken = IERC20Upgradeable(collateralTokenAddress);

        // Approve the ConditionalTokens contract to spend the collateral tokens
        collateralToken.safeApprove(conditionalTokensAddress, amount);
        console.log("Approved ConditionalTokens to spend", amount, "collateral tokens");

        // Merge positions
        bytes32; // Parent collection IDs (empty for base collateral)
        conditionalTokens.mergePositions(
            collateralTokenAddress,
            conditionId,
            partition,
            amount
        );
        console.log("Merged positions for condition ID:", toHexString(conditionId));

        vm.stopBroadcast();
    }

    /**
     * @notice Parses a comma-separated string of partition indexes into a uint256 array.
     * @param _partitionStr The partition string to parse.
     * @return partitionArray An array of parsed partition indexes.
     */
    function parsePartition(string memory _partitionStr) internal pure returns (uint256[] memory partitionArray) {
        // Split the string by commas
        string[] memory strArray = _split(_partitionStr, ",");
        partitionArray = new uint256[](strArray.length);
        for (uint256 i = 0; i < strArray.length; i++) {
            // Convert each string element to uint256
            partitionArray[i] = parseUint(strArray[i]);
        }
    }

    /**
     * @notice Splits a string by a delimiter.
     * @param _base The base string to split.
     * @param _delimiter The delimiter to split by.
     * @return splitArray An array of split strings.
     */
    function _split(string memory _base, string memory _delimiter) internal pure returns (string[] memory splitArray) {
        bytes memory baseBytes = bytes(_base);
        bytes memory delimiterBytes = bytes(_delimiter);
        require(delimiterBytes.length == 1, "MergePositionScript: Delimiter must be a single character");

        uint256 splitCount = 1;
        for (uint256 i = 0; i < baseBytes.length; i++) {
            if (baseBytes[i] == delimiterBytes[0]) {
                splitCount++;
            }
        }

        splitArray = new string[](splitCount);
        uint256 currentIndex = 0;
        uint256 arrayIndex = 0;
        for (uint256 i = 0; i < baseBytes.length; i++) {
            if (baseBytes[i] == delimiterBytes[0]) {
                uint256 length = i - currentIndex;
                bytes memory temp = new bytes(length);
                for (uint256 j = 0; j < length; j++) {
                    temp[j] = baseBytes[currentIndex + j];
                }
                splitArray[arrayIndex] = string(temp);
                arrayIndex++;
                currentIndex = i + 1;
            }
        }
        // Add the last element
        uint256 remainingLength = baseBytes.length - currentIndex;
        bytes memory temp = new bytes(remainingLength);
        for (uint256 j = 0; j < remainingLength; j++) {
            temp[j] = baseBytes[currentIndex + j];
        }
        splitArray[arrayIndex] = string(temp);
    }

    /**
     * @notice Parses a string into a uint256.
     * @param _a The string to parse.
     * @return val The parsed uint256 value.
     */
    function parseUint(string memory _a) internal pure returns (uint256 val) {
        bytes memory bresult = bytes(_a);
        uint256 res = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            uint8 c = uint8(bresult[i]);
            require(c >= 48 && c <= 57, "MergePositionScript: Invalid character in partition");
            res = res * 10 + (c - 48);
        }
        return res;
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
