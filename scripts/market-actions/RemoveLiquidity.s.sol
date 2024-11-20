// /home/philljoe/projects/conditional-tokens/scripts/market-actions/RemoveLiquidity.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Script library for deployment scripting
import "forge-std/Script.sol";

// Import the ILiquidityPoolUpgradeable interface
import "../../src/market/ILiquidityPoolUpgradeable.sol";

// Import OpenZeppelin's IERC20Upgradeable and SafeERC20Upgradeable for ERC20 interactions


/**
 * @title RemoveLiquidityScript
 * @notice Script to remove liquidity by unstaking collateral tokens from the LiquidityPoolUpgradeable contract.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract RemoveLiquidityScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the liquidity removal process.
     * @dev Retrieves necessary parameters from environment variables, approves token transfer if needed, and unstakes tokens.
     */
    function run() external {
        // Load environment variables
        address liquidityPoolAddress = vm.envAddress("LIQUIDITY_POOL_PROXY_ADDRESS");
        address collateralTokenAddress = vm.envAddress("COLLATERAL_TOKEN_ADDRESS");
        uint256 removeAmount = vm.envUint("REMOVE_AMOUNT"); // Amount to remove in collateralToken's smallest unit

        // Validate inputs
        require(liquidityPoolAddress != address(0), "RemoveLiquidityScript: Invalid LiquidityPool address");
        require(collateralTokenAddress != address(0), "RemoveLiquidityScript: Invalid Collateral Token address");
        require(removeAmount > 0, "RemoveLiquidityScript: Remove amount must be greater than zero");

        vm.startBroadcast();

        // Cast to ILiquidityPoolUpgradeable interface
        ILiquidityPoolUpgradeable liquidityPool = ILiquidityPoolUpgradeable(liquidityPoolAddress);

        // Cast to IERC20Upgradeable interface for collateral token
        IERC20Upgradeable collateralToken = IERC20Upgradeable(collateralTokenAddress);

        // Optional: Check the user's staked balance before attempting to remove liquidity
        uint256 stakedBalance = liquidityPool.getStakedBalance(msg.sender);
        require(stakedBalance >= removeAmount, "RemoveLiquidityScript: Insufficient staked balance");

        // Remove liquidity by unstaking the specified amount
        liquidityPool.unstake(removeAmount);
        console.log("Unstaked", removeAmount, "collateral tokens from LiquidityPool at:", liquidityPoolAddress);

        // Optional: Handle post-unstaking logic, such as resetting approvals or updating state
        // For example, if the contract previously approved the LiquidityPool to spend tokens, and you no longer need it:
        // collateralToken.safeApprove(liquidityPoolAddress, 0);
        // console.log("Reset collateral token approval for LiquidityPool");

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
