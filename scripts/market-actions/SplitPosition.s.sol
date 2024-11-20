// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import the IConditionalTokensUpgradeable interface
import "../../src/conditional/IConditionalTokensUpgradeable.sol";

// Import OpenZeppelin's IERC20Upgradeable and SafeERC20Upgradeable for ERC20 interactions

/**
 * @title SplitPositionScript
 * @notice Script to facilitate the splitting of specific outcomes back into collateral tokens in a prediction market.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract SplitPositionScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the position splitting process.
     * @dev Retrieves necessary parameters from environment variables and calls splitPositions on ConditionalTokens.
     */
    function run() external {
        // Load environment variables
        address conditionalTokensAddress = vm.envAddress("CONDITIONAL_TOKENS_PROXY_ADDRESS");
        address collateralTokenAddress = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        address userAddress = vm.envAddress("USER_ADDRESS");
        bytes32 conditionId = vm.envBytes32("CONDITION_ID");
        uint256[] memory partition = parsePartition(vm.envString("PARTITION")); // Comma-separated outcome indexes
        uint256 amount = vm.envUint("AMOUNT"); // Amount of outcome tokens to split

        // Validate inputs
        require(conditionalTokensAddress != address(0), "SplitPositionScript: Invalid ConditionalTokens address");
        require(collateralTokenAddress != address(0), "SplitPositionScript: Invalid Collateral Token address");
        require(userAddress != address(0), "SplitPositionScript: Invalid User address");
        require(amount > 0, "SplitPositionScript: Amount must be greater than zero");
        require(conditionId != bytes32(0), "SplitPositionScript: Invalid Condition ID");
        require(partition.length > 0, "SplitPositionScript: Partition cannot be empty");

        vm.startBroadcast();

        // Cast to ConditionalTokensUpgradeable interface
        IConditionalTokensUpgradeable conditionalTokens = IConditionalTokensUpgradeable(conditionalTokensAddress);

        // Cast to IERC20Upgradeable interface for collateral token
        IERC20Upgradeable collateralToken = IERC20Upgradeable(collateralTokenAddress);

        // Approve the ConditionalTokensUpgradeable contract to spend the outcome tokens
        collateralToken.safeApprove(conditionalTokensAddress, amount);
        console.log("Approved ConditionalTokens to spend", amount, "collateral tokens");

        // Split positions
        // Assuming that splitPositions takes collateralToken, conditionId, partition, and amount
        // Adjust the parameters as per your IConditionalTokensUpgradeable interface
        conditionalTokens.splitPositions(
            collateralTokenAddress,
            conditionId,
            partition,
            amount
        );
        console.log("Split positions for condition ID:", toHexString(conditionId), "Amount:", amount);

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
        require(delimiterBytes.length == 1, "SplitPositionScript: Delimiter must be a single character");

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
        bytes memory tempLast = new bytes(remainingLength);
        for (uint256 j = 0; j < remainingLength; j++) {
            tempLast[j] = baseBytes[currentIndex + j];
        }
        splitArray[arrayIndex] = string(tempLast);
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
            require(c >= 48 && c <= 57, "SplitPositionScript: Invalid character in partition");
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
