// /home/philljoe/projects/conditional-tokens/scripts/finance/HandleFees.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/fee/FeeManagerUpgradeable.sol";

/**
 * @title HandleFeesScript
 * @notice Script to handle the withdrawal of fees from the FeeManagerUpgradeable contract.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract HandleFeesScript is Script {
    /**
     * @notice Executes the fee withdrawal process.
     * @dev Retrieves necessary parameters from environment variables and invokes the withdrawFees function.
     */
    function run() external {
        // Load environment variables
        address feeManagerAddress = vm.envAddress("FEE_MANAGER_PROXY_ADDRESS");
        address recipient = vm.envAddress("FEE_RECIPIENT_ADDRESS");
        uint256 feeAmount = vm.envUint("FEE_AMOUNT"); // Amount to withdraw in feeToken's smallest unit
        string memory feeType = vm.envString("FEE_TYPE"); // Type of fee being withdrawn (e.g., "Withdrawal")

        // Validate inputs
        require(feeManagerAddress != address(0), "HandleFeesScript: Invalid FeeManager address");
        require(recipient != address(0), "HandleFeesScript: Invalid recipient address");
        require(feeAmount > 0, "HandleFeesScript: Fee amount must be greater than zero");
        require(bytes(feeType).length > 0, "HandleFeesScript: Fee type cannot be empty");

        vm.startBroadcast();

        // Cast to FeeManagerUpgradeable interface
        FeeManagerUpgradeable feeManager = FeeManagerUpgradeable(feeManagerAddress);

        // Execute the withdrawal
        feeManager.withdrawFees(recipient, feeAmount, feeType);

        // Log the withdrawal details
        console.log("Fees withdrawn to:", recipient);
        console.log("Amount withdrawn:", feeAmount);
        console.log("Fee Type:", feeType);

        vm.stopBroadcast();
    }
}
