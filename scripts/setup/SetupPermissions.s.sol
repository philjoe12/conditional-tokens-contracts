// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/forge-std/src/Script.sol";
import "../../src/market/IMarketManagerUpgradeable.sol";
import "../../src/oracle/IOracleHandlerUpgradeable.sol";
import "../../src/rewards/IRewardsManagerUpgradeable.sol";
import "../../src/fee/IFeeManagerUpgradeable.sol";
import "../../src/access/IAccessControlUpgradeable.sol";

contract SetupPermissions is Script {
    function run() external {
        // Load environment variables
        address marketManager = vm.envAddress("MARKET_MANAGER_ADDRESS");
        address oracleHandler = vm.envAddress("ORACLE_HANDLER_ADDRESS");
        address rewardsManager = vm.envAddress("REWARDS_MANAGER_ADDRESS");
        address feeManager = vm.envAddress("FEE_MANAGER_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");

        // Start with logging the addresses
        console.log("Setting up permissions with addresses:");
        console.log("MarketManager:", marketManager);
        console.log("OracleHandler:", oracleHandler);
        console.log("RewardsManager:", rewardsManager);
        console.log("FeeManager:", feeManager);
        console.log("Admin:", admin);

        // Define role hashes - these should match the ones defined in your contracts
        bytes32 DEFAULT_ADMIN_ROLE = 0x00;
        bytes32 MARKET_MANAGER_ROLE = keccak256("MARKET_MANAGER_ROLE");
        bytes32 REWARDS_MANAGER_ROLE = keccak256("REWARDS_MANAGER_ROLE");
        bytes32 FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
        bytes32 ORACLE_ROLE = keccak256("ORACLE_ROLE");

        vm.startBroadcast();

        // Verify contract code exists at addresses
        require(address(marketManager).code.length > 0, "No code at MarketManager address");
        require(address(oracleHandler).code.length > 0, "No code at OracleHandler address");
        require(address(rewardsManager).code.length > 0, "No code at RewardsManager address");
        require(address(feeManager).code.length > 0, "No code at FeeManager address");

        console.log("All contracts verified to exist at specified addresses");

        // Try direct role grants without checking first
        try IAccessControlUpgradeable(marketManager).grantRole(DEFAULT_ADMIN_ROLE, admin) {
            console.log("Granted DEFAULT_ADMIN_ROLE to admin on MarketManager");
        } catch {
            console.log("Failed to grant DEFAULT_ADMIN_ROLE to admin on MarketManager");
        }

        try IAccessControlUpgradeable(marketManager).grantRole(MARKET_MANAGER_ROLE, admin) {
            console.log("Granted MARKET_MANAGER_ROLE to admin on MarketManager");
        } catch {
            console.log("Failed to grant MARKET_MANAGER_ROLE to admin on MarketManager");
        }

        try IAccessControlUpgradeable(marketManager).grantRole(REWARDS_MANAGER_ROLE, rewardsManager) {
            console.log("Granted REWARDS_MANAGER_ROLE to rewardsManager");
        } catch {
            console.log("Failed to grant REWARDS_MANAGER_ROLE to rewardsManager");
        }

        try IAccessControlUpgradeable(marketManager).grantRole(FEE_MANAGER_ROLE, feeManager) {
            console.log("Granted FEE_MANAGER_ROLE to feeManager");
        } catch {
            console.log("Failed to grant FEE_MANAGER_ROLE to feeManager");
        }

        try IAccessControlUpgradeable(marketManager).grantRole(ORACLE_ROLE, oracleHandler) {
            console.log("Granted ORACLE_ROLE to oracleHandler");
        } catch {
            console.log("Failed to grant ORACLE_ROLE to oracleHandler");
        }

        // Try to grant roles on other contracts
        try IAccessControlUpgradeable(oracleHandler).grantRole(DEFAULT_ADMIN_ROLE, admin) {
            console.log("Granted DEFAULT_ADMIN_ROLE to admin on OracleHandler");
        } catch {
            console.log("Failed to grant DEFAULT_ADMIN_ROLE to admin on OracleHandler");
        }

        try IAccessControlUpgradeable(rewardsManager).grantRole(DEFAULT_ADMIN_ROLE, admin) {
            console.log("Granted DEFAULT_ADMIN_ROLE to admin on RewardsManager");
        } catch {
            console.log("Failed to grant DEFAULT_ADMIN_ROLE to admin on RewardsManager");
        }

        try IAccessControlUpgradeable(feeManager).grantRole(DEFAULT_ADMIN_ROLE, admin) {
            console.log("Granted DEFAULT_ADMIN_ROLE to admin on FeeManager");
        } catch {
            console.log("Failed to grant DEFAULT_ADMIN_ROLE to admin on FeeManager");
        }

        vm.stopBroadcast();
        
        console.log("Setup script completed");
    }

    function _grantRoleWithLogging(
        IAccessControlUpgradeable contractInstance,
        bytes32 role,
        address account,
        string memory description
    ) internal {
        // First check if the role is already granted
        bool hasRole = contractInstance.hasRole(role, account);
        if (hasRole) {
            console.log("Role already granted:", description);
            return;
        }

        // Then attempt to grant the role
        try contractInstance.grantRole(role, account) {
            console.log("Successfully granted", description);
        } catch Error(string memory reason) {
            console.log("Failed to grant", description);
            console.log("Reason:", reason);
            revert(string(abi.encodePacked("Failed to grant role: ", reason)));
        } catch (bytes memory) {
            console.log("Failed to grant", description);
            console.log("Reason: Unknown error (likely access control)");
            revert("Failed to grant role: Unknown error");
        }
    }
}