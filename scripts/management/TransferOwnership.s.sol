// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/access/AccessControlManagerUpgradeable.sol";

contract TransferOwnershipScript is Script {
    function run() external {
        // Load environment variables
        address accessControlAddress = vm.envAddress("ACCESS_CONTROL_PROXY_ADDRESS");
        address newAdmin = vm.envAddress("NEW_ADMIN_ADDRESS");

        vm.startBroadcast();

        // Cast to AccessControlManagerUpgradeable interface
        AccessControlManagerUpgradeable accessControl = AccessControlManagerUpgradeable(accessControlAddress);

        // Grant ADMIN_ROLE to the new admin
        accessControl.grantRole(accessControl.ADMIN_ROLE(), newAdmin);

        // Optionally, revoke ADMIN_ROLE from the current admin
        // address currentAdmin = vm.envAddress("CURRENT_ADMIN_ADDRESS");
        // accessControl.revokeRole(accessControl.ADMIN_ROLE(), currentAdmin);

        console.log("Ownership transferred to:", newAdmin);

        vm.stopBroadcast();
    }
}
