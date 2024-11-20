// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import OpenZeppelin's ERC1967Proxy for proxy deployment
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Import the FeeManagerUpgradeable implementation contract
import "../../src/fee/FeeManagerUpgradeable.sol";

/**
 * @title DeployFeeManager
 * @notice Script to deploy the FeeManagerUpgradeable contract along with its proxy.
 * @dev Utilizes the ERC1967Proxy pattern for upgradeability.
 */
contract DeployFeeManager is Script {
    function run() external {
        address admin = vm.envAddress("ADMIN_ADDRESS");
        uint256 initialFee = vm.envUint("INITIAL_FEE");
        address initialRecipient = vm.envAddress("FEE_RECIPIENT_ADDRESS");
        address feeToken = vm.envAddress("FEE_TOKEN_ADDRESS");
        
        require(admin != address(0), "DeployFeeManager: ADMIN_ADDRESS is zero");
        require(initialRecipient != address(0), "DeployFeeManager: FEE_RECIPIENT_ADDRESS is zero");
        require(feeToken != address(0), "DeployFeeManager: FEE_TOKEN_ADDRESS is zero");
        require(initialFee > 0, "DeployFeeManager: INITIAL_FEE must be greater than zero");
        
        vm.startBroadcast();
        
        FeeManagerUpgradeable implementation = new FeeManagerUpgradeable();
        
        bytes memory initializer = abi.encodeWithSelector(
            FeeManagerUpgradeable.initialize.selector,
            admin,
            initialFee,
            initialRecipient,
            feeToken
        );
        
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initializer
        );
        
        console.log("FeeManagerUpgradeable Proxy deployed at:", address(proxy));
        
        vm.stopBroadcast();
    }
}