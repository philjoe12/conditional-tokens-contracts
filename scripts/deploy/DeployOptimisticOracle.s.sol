// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/oracle/OptimisticOracleUpgradeable.sol";

contract DeployOptimisticOracle is Script {
    function run() external {
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        vm.startBroadcast();

        OptimisticOracleUpgradeable implementation = new OptimisticOracleUpgradeable();

        bytes memory initializer = abi.encodeWithSelector(
            OptimisticOracleUpgradeable.initialize.selector,
            admin
        );

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        console.log("OptimisticOracle Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}