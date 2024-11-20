// /home/philljoe/projects/conditional-tokens/scripts/finance/ManageUserBalances.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/fee/FeeManagerUpgradeable.sol";
import "../../src/market/LiquidityPoolUpgradeable.sol"; // Corrected import path


/**
 * @title ManageUserBalancesScript
 * @notice Script to manage user balances by staking ETH or ERC20 tokens into the LiquidityPoolUpgradeable contract.
 * @dev Utilizes Foundry's Script library for deployment and interaction.
 */
contract ManageUserBalancesScript is Script {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Executes the staking process for a user.
     * @dev Retrieves necessary parameters from environment variables and invokes the stake function on the LiquidityPoolUpgradeable contract.
     */
    function run() external {
        // Load environment variables
        address liquidityPoolAddress = vm.envAddress("LIQUIDITY_POOL_PROXY_ADDRESS");
        address userAddress = vm.envAddress("USER_ADDRESS");
        uint256 stakeAmount = vm.envUint("STAKE_AMOUNT"); // Amount to stake in wei or smallest unit of token
        string memory stakeType = vm.envString("STAKE_TYPE"); // "ETH" or "ERC20"
        address stakeTokenAddress = vm.envAddress("STAKE_TOKEN_ADDRESS"); // ERC20 token address, if applicable
        address feeManagerAddress = vm.envAddress("FEE_MANAGER_PROXY_ADDRESS"); // FeeManagerUpgradeable contract address

        // Validate inputs
        require(liquidityPoolAddress != address(0), "ManageUserBalances: Invalid LiquidityPool address");
        require(userAddress != address(0), "ManageUserBalances: Invalid user address");
        require(stakeAmount > 0, "ManageUserBalances: Stake amount must be greater than zero");
        require(
            keccak256(bytes(stakeType)) == keccak256("ETH") || keccak256(bytes(stakeType)) == keccak256("ERC20"),
            "ManageUserBalances: Invalid stake type"
        );
        if (keccak256(bytes(stakeType)) == keccak256("ERC20")) {
            require(stakeTokenAddress != address(0), "ManageUserBalances: Invalid stake token address");
        }

        // Determine which account to broadcast from
        // Assuming staking is done by the user themselves, the script should use the user's private key
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        require(userPrivateKey != 0, "ManageUserBalances: User private key not set");

        vm.startBroadcast(userPrivateKey);

        // Cast to LiquidityPoolUpgradeable interface
        LiquidityPoolUpgradeable liquidityPool = LiquidityPoolUpgradeable(liquidityPoolAddress);

        if (keccak256(bytes(stakeType)) == keccak256("ETH")) {
            // Stake ETH
            // Assuming the stake function accepts the user's address and amount, and handles the ETH sent
            liquidityPool.stake{value: stakeAmount}(userAddress, stakeAmount);
            console.log("Staked ETH for user:", userAddress, "Amount:", stakeAmount, "wei");
        } else if (keccak256(bytes(stakeType)) == keccak256("ERC20")) {
            // Stake ERC20 tokens
            // Assuming the stake function accepts the user's address and amount, and pulls tokens from the user
            // Ensure that the user has approved the LiquidityPool to spend the tokens before running this script

            IERC20Upgradeable stakeToken = IERC20Upgradeable(stakeTokenAddress);

            // Approve LiquidityPool to spend tokens
            stakeToken.safeApprove(liquidityPoolAddress, stakeAmount);
            console.log("Approved LiquidityPool to spend", stakeAmount, "tokens");

            // Call the stake function without sending ETH
            liquidityPool.stake(userAddress, stakeAmount);
            console.log("Staked ERC20 tokens for user:", userAddress, "Amount:", stakeAmount, "Token:", stakeTokenAddress);
        }

        vm.stopBroadcast();
    }
}
