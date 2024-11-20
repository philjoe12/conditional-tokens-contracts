// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/conditional/ConditionalTokensUpgradeable.sol";

contract DeployConditionalTokens is Script {
    function run() external {
        // Get deployment parameters from environment
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address oracleHandler = vm.envAddress("ORACLE_HANDLER_ADDRESS");
        address marketManager = vm.envAddress("MARKET_MANAGER_ADDRESS");
        address collateralToken = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        string memory uri = vm.envString("BASE_URI");

        vm.startBroadcast();

        // Deploy implementation
        ConditionalTokensUpgradeable implementation = new ConditionalTokensUpgradeable();

        // Prepare initialization data
        bytes memory initializer = abi.encodeWithSelector(
            ConditionalTokensUpgradeable.initialize.selector,
            admin,
            oracleHandler,
            marketManager,
            collateralToken,
            uri
        );

        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        ConditionalTokensUpgradeable conditionalTokens = ConditionalTokensUpgradeable(address(proxy));

        console.log("Implementation deployed at:", address(implementation));
        console.log("Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
