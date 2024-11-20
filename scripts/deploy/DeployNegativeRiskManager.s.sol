// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/risk/NegativeRiskManagerUpgradeable.sol";

contract DeployNegativeRiskManager is Script {
    function run() external {
        // Retrieve necessary addresses from environment variables
        address marketManager = vm.envAddress("MARKET_MANAGER_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy implementation contract
        NegativeRiskManagerUpgradeable implementation = new NegativeRiskManagerUpgradeable();

        // Prepare initialization data
        bytes memory initializer = abi.encodeWithSelector(
            NegativeRiskManagerUpgradeable.initialize.selector,
            marketManager
        );

        // Deploy proxy contract
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast proxy to NegativeRiskManagerUpgradeable interface
        NegativeRiskManagerUpgradeable negativeRiskManager = NegativeRiskManagerUpgradeable(address(proxy));

        if (admin != msg.sender) {
            // Define role constants
            bytes32 adminRole = keccak256("ADMIN_ROLE");
            bytes32 riskManagerRole = keccak256("RISK_MANAGER_ROLE");
            bytes32 defaultAdminRole = 0x00;

            // Grant roles to admin
            negativeRiskManager.grantRole(adminRole, admin);
            negativeRiskManager.grantRole(riskManagerRole, admin);

            // Revoke roles from deployer
            negativeRiskManager.revokeRole(defaultAdminRole, msg.sender);
            negativeRiskManager.revokeRole(adminRole, msg.sender);
            negativeRiskManager.revokeRole(riskManagerRole, msg.sender);
        }

        // Log deployed address
        console.log("NegativeRiskManagerUpgradeable Proxy deployed at:", address(negativeRiskManager));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}