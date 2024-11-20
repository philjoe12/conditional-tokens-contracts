// /home/philljoe/projects/conditional-tokens/scripts/oracle-interaction/InteractWithOracles.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library
import "forge-std/Script.sol";

// Import interfaces
import "../../src/oracle/IUmaCtfAdapterUpgradeable.sol";


/**
 * @title InteractWithOraclesScript
 * @notice Script to interact with UMA's Optimistic Oracle for proposing and resolving market prices.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract InteractWithOraclesScript is Script {
    /**
     * @notice Executes the oracle interaction process.
     * @dev Proposes or resolves prices for a given market condition.
     */
    function run() external {
        // Load environment variables
        address umaCtfAdapterAddress = vm.envAddress("UMA_CTF_ADAPTER_ADDRESS");
        bytes32 conditionId = vm.envBytes32("CONDITION_ID");
        string memory message = vm.envString("ORACLE_MESSAGE"); // Message to sign for proposal
        uint256 price = vm.envUint("ORACLE_PRICE"); // Price to propose
        uint256 nonce = vm.envUint("ORACLE_NONCE"); // Nonce for the proposal
        uint256 liveness = vm.envUint("UMA_LIVENESS"); // Liveness period in seconds

        // Validate inputs
        require(umaCtfAdapterAddress != address(0), "InteractWithOracles: Invalid UmaCtfAdapter address");
        require(conditionId != bytes32(0), "InteractWithOracles: Invalid Condition ID");
        require(price > 0, "InteractWithOracles: Price must be greater than zero");

        // Cast to UmaCtfAdapterUpgradeable interface
        IUmaCtfAdapterUpgradeable umaCtfAdapter = IUmaCtfAdapterUpgradeable(umaCtfAdapterAddress);

        vm.startBroadcast();

        // Propose a price
        umaCtfAdapter.proposePrice(conditionId, price, message, nonce, liveness);
        console.log("Proposed price:", price, "for condition:", toHexString(conditionId));

        // Optionally, resolve the price if it's been challenged and liveness has passed
        // uint256 currentTimestamp = block.timestamp;
        // if (currentTimestamp >= proposalTimestamp + liveness) {
        //     umaCtfAdapter.resolvePrice(conditionId);
        //     console.log("Resolved price for condition:", toHexString(conditionId));
        // }

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
