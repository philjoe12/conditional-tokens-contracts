// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/forge-std/src/Script.sol";
import "../../src/market/IMarketManagerUpgradeable.sol";

contract CreateMarketScript is Script {
    function run() external {
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 questionId = vm.envBytes32("QUESTION_ID");
        string memory outcomeTokensStr = vm.envString("OUTCOME_TOKENS");
        string memory category = vm.envString("CATEGORY");
        string memory description = vm.envString("DESCRIPTION");
        uint256 fee = vm.envUint("FEE");
        uint256 duration = vm.envUint("DURATION");

        require(marketManagerAddress != address(0), "CreateMarketScript: Invalid MarketManager address");
        require(questionId != bytes32(0), "CreateMarketScript: Invalid Question ID");
        require(bytes(outcomeTokensStr).length > 0, "CreateMarketScript: Outcome tokens cannot be empty");
        require(bytes(category).length > 0, "CreateMarketScript: Category cannot be empty");
        require(bytes(description).length > 0, "CreateMarketScript: Description cannot be empty");
        require(fee <= 10000, "CreateMarketScript: Fee cannot exceed 100%");
        require(duration > 0, "CreateMarketScript: Duration must be greater than zero");

        string[] memory outcomeTokens = _split(outcomeTokensStr, ",");
        require(outcomeTokens.length >= 2, "CreateMarketScript: At least two outcomes required");

        vm.startBroadcast();

        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);
        bytes32 marketId = marketManager.createMarket(
            questionId,
            outcomeTokens,
            category,
            description,
            fee,
            duration
        );

        console.log("Market Created Successfully:");
        console.log("Market ID:", toHexString(marketId));
        console.log("Category:", category);
        console.log("Description:", description);
        console.log("Fee (basis points):", fee);
        console.log("Duration (seconds):", duration);
        console.log("Outcomes:");
        for (uint256 i = 0; i < outcomeTokens.length; i++) {
            console.log("- Outcome", i, ":", outcomeTokens[i]);
        }

        vm.stopBroadcast();
    }

    function _split(string memory _base, string memory _delimiter) internal pure returns (string[] memory) {
        bytes memory baseBytes = bytes(_base);
        bytes memory delimiterBytes = bytes(_delimiter);
        require(delimiterBytes.length == 1, "CreateMarketScript: Delimiter must be a single character");

        uint256 splitCount = 1;
        for(uint256 i = 0; i < baseBytes.length; i++) {
            if(baseBytes[i] == delimiterBytes[0]) {
                splitCount++;
            }
        }

        string[] memory result = new string[](splitCount);
        uint256 currentIndex = 0;
        uint256 arrayIndex = 0;

        for(uint256 i = 0; i < baseBytes.length; i++) {
            if(baseBytes[i] == delimiterBytes[0]) {
                bytes memory tempBytes = new bytes(i - currentIndex);
                for(uint256 j = 0; j < i - currentIndex; j++) {
                    tempBytes[j] = baseBytes[currentIndex + j];
                }
                result[arrayIndex] = string(tempBytes);
                arrayIndex++;
                currentIndex = i + 1;
            }
        }

        bytes memory lastBytes = new bytes(baseBytes.length - currentIndex);
        for(uint256 j = 0; j < baseBytes.length - currentIndex; j++) {
            lastBytes[j] = baseBytes[currentIndex + j];
        }
        result[arrayIndex] = string(lastBytes);

        return result;
    }

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