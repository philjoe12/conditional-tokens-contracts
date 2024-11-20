// scripts/deploy/DeployUmaCtfAdapter.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the UmaCtfAdapterUpgradeable implementation contract
import "../../src/oracle/UmaCtfAdapterUpgradeable.sol";

/**
 * @title DeployUmaCtfAdapter
 * @notice Script to deploy the UmaCtfAdapterUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployUmaCtfAdapter is Script {
    /**
     * @notice The main entry point for the deployment script.
     * @dev Deploys the implementation contract, then deploys the proxy pointing to it, initializing with the required parameters.
     */
    function run() external {
        // Retrieve necessary addresses and parameters from environment variables
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address optimisticOracle = vm.envAddress("OPTIMISTIC_ORACLE_ADDRESS");
        address oracleHandler = vm.envAddress("ORACLE_HANDLER_ADDRESS");
        uint256 bondAmount = vm.envUint("BOND_AMOUNT");

        // Validate bondAmount (optional, based on your requirements)
        require(bondAmount > 0, "DeployUmaCtfAdapter: Bond amount must be greater than zero");

        // Start broadcasting transactions to the specified RPC
        vm.startBroadcast();

        // Deploy the implementation contract
        UmaCtfAdapterUpgradeable implementation = new UmaCtfAdapterUpgradeable();

        // Prepare the initialization data for the proxy (calling the initialize function)
        bytes memory initializer = abi.encodeWithSelector(
            UmaCtfAdapterUpgradeable.initialize.selector,
            admin,
            optimisticOracle,
            oracleHandler,
            bondAmount
        );

        // Deploy the proxy contract pointing to the implementation, with the initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );

        // Cast the proxy address to the UmaCtfAdapterUpgradeable interface for easier interaction
        UmaCtfAdapterUpgradeable umaCtfAdapter = UmaCtfAdapterUpgradeable(address(proxy));

        // Optionally, perform additional setup or role assignments if necessary
        // For example, if the admin is different from the deployer, you might want to revoke roles from the deployer
        // and ensure the admin has the necessary roles. However, since the initialize function already sets up roles,
        // additional role management may not be necessary here.

        // Output the deployed proxy address to the console
        console.log("UmaCtfAdapterUpgradeable Proxy deployed at:", address(umaCtfAdapter));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
