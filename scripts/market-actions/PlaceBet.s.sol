// /home/philljoe/projects/conditional-tokens/scripts/market-actions/PlaceBet.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/market/IMarketManagerUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PlaceBetScript is Script {
    function run() external {
        // Load environment variables
        address marketManagerAddress = vm.envAddress("MARKET_MANAGER_PROXY_ADDRESS");
        bytes32 marketId = vm.envBytes32("MARKET_ID");
        uint256 outcomeIndex = vm.envUint("OUTCOME_INDEX");
        uint256 betAmount = vm.envUint("BET_AMOUNT"); // Amount in token units
        string memory orderTypeStr = vm.envString("ORDER_TYPE"); // "GTC", "FOK", "GTD"
        uint256 feeRateBps = vm.envUint("FEE_RATE_BPS"); // Fee in basis points
        uint256 expiration = vm.envUint("EXPIRATION"); // Unix timestamp for GTD
        uint256 nonce = vm.envUint("NONCE"); // Unique nonce for the order
        uint256 signatureType = vm.envUint("SIGNATURE_TYPE"); // 0: EOA, 1: POLY_PROXY, 2: POLY_GNOSIS_SAFE

        // Derived variables
        address signerAddress = vm.envAddress("SIGNER_ADDRESS");
        string memory message = vm.envString("ORDER_MESSAGE"); // EIP712 message

        // Validate inputs
        require(marketManagerAddress != address(0), "PlaceBetScript: Invalid MarketManager address");
        require(marketId != bytes32(0), "PlaceBetScript: Invalid Market ID");
        require(betAmount > 0, "PlaceBetScript: Bet amount must be greater than zero");
        require(signatureType <= 2, "PlaceBetScript: Invalid signature type");

        // Start broadcasting transactions
        vm.startBroadcast();

        // Cast to IMarketManagerUpgradeable interface
        IMarketManagerUpgradeable marketManager = IMarketManagerUpgradeable(marketManagerAddress);

        // ERC20 token details (Assuming USDC; replace with your token if different)
        address tokenAddress = marketManager.tokenAddress(); // Ensure this function exists
        IERC20 token = IERC20(tokenAddress);

        // Approve the MarketManager to spend tokens
        uint256 allowance = token.allowance(address(this), marketManagerAddress);
        if (allowance < betAmount) {
            token.approve(marketManagerAddress, type(uint256).max);
            console.log("Approved token for betting");
        }

        // Prepare the order parameters
        uint8 orderType;
        if (keccak256(abi.encodePacked(orderTypeStr)) == keccak256("GTC")) {
            orderType = 1;
        } else if (keccak256(abi.encodePacked(orderTypeStr)) == keccak256("FOK")) {
            orderType = 2;
        } else if (keccak256(abi.encodePacked(orderTypeStr)) == keccak256("GTD")) {
            orderType = 3;
        } else {
            revert("PlaceBetScript: Invalid Order Type");
        }

        // Sign the order (EIP712)
        bytes memory signature = signOrder(signerAddress, message);

        // Place the bet
        bytes32 orderId = marketManager.placeBet(
            marketId,
            outcomeIndex,
            betAmount,
            feeRateBps,
            orderType,
            expiration,
            nonce,
            signatureType,
            signature
        );

        console.log(
            "Bet placed on market:",
            toHexString(marketId),
            "outcome index:",
            outcomeIndex,
            "amount:",
            betAmount,
            "order ID:",
            toHexString(orderId)
        );

        vm.stopBroadcast();
    }

    /**
     * @notice Signs the order message using EIP712.
     * @param signer The address of the signer.
     * @param message The message to sign.
     * @return signature The signed message.
     */
    function signOrder(address signer, string memory message) internal returns (bytes memory signature) {
        // Implement EIP712 signing logic here
        // This typically involves off-chain signing and passing the signature as an environment variable
        // For scripting purposes, assume the signature is provided as an environment variable
        signature = bytes(vm.envString("ORDER_SIGNATURE"));
        require(signature.length > 0, "PlaceBetScript: Invalid signature");
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
