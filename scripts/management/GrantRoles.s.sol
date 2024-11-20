// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/access/AccessControlManagerUpgradeable.sol";
import "../../src/fee/FeeManagerUpgradeable.sol";
import "../../src/governance/GovernanceManagerUpgradeable.sol";
import "../../src/market/MarketManagerUpgradeable.sol";

import "../../src/market/LiquidityPoolUpgradeable.sol";
import "../../src/oracle/OracleHandlerUpgradeable.sol";
import "../../src/conditional/ConditionalTokensUpgradeable.sol";

contract GrantRoles is Script {
    function run() external {
        // Load environment variables
        address accessControlAddress = vm.envAddress("ACCESS_CONTROL_PROXY_ADDRESS");
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        address feeManagerAddress = vm.envAddress("FEE_MANAGER_PROXY_ADDRESS");
        address governanceManagerAddress = vm.envAddress("GOVERNANCE_MANAGER_PROXY_ADDRESS");
        address rewardsManagerAddress = vm.envAddress("REWARDS_MANAGER_PROXY_ADDRESS"); 
        address liquidityPoolAddress = vm.envAddress("LIQUIDITY_POOL_PROXY_ADDRESS");
        address oracleHandlerAddress = vm.envAddress("ORACLE_HANDLER_PROXY_ADDRESS");
        address conditionalTokensAddress = vm.envAddress("CONDITIONAL_TOKENS_PROXY_ADDRESS");

        vm.startBroadcast();

        // AccessControlManagerUpgradeable
        AccessControlManagerUpgradeable accessControl = AccessControlManagerUpgradeable(accessControlAddress);

        // Grant roles to MarketManager
        accessControl.grantRole(accessControl.MARKET_MANAGER_ROLE(), marketManagerAddress);

        // Grant roles to FeeManager
        accessControl.grantRole(accessControl.FEE_MANAGER_ROLE(), feeManagerAddress);

        // Grant roles to GovernanceManager
        accessControl.grantRole(accessControl.GOVERNANCE_MANAGER_ROLE(), governanceManagerAddress);

        // Grant roles to RewardsManager
        accessControl.grantRole(accessControl.REWARDS_MANAGER_ROLE(), rewardsManagerAddress);

        // Grant roles to LiquidityPool
        accessControl.grantRole(accessControl.LIQUIDITY_PROVIDER_ROLE(), liquidityPoolAddress);

        // Grant roles to OracleHandler
        accessControl.grantRole(accessControl.ORACLE_HANDLER_ROLE(), oracleHandlerAddress);

        // Grant roles to ConditionalTokens
        accessControl.grantRole(accessControl.CONDITIONAL_TOKENS_ROLE(), conditionalTokensAddress);

        console.log("Roles granted successfully.");

        vm.stopBroadcast();
    }
}
