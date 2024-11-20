// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;  

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../../src/market/MarketManagerUpgradeable.sol";
import "../../src/market/IMarketManagerUpgradeable.sol";
import "../../src/oracle/UmaCtfAdapterUpgradeable.sol";
import "../../src/rewards/RewardsManagerUpgradeable.sol";
import "../../src/fee/FeeManagerUpgradeable.sol";

contract MarketManagerUpgradeableTest is Test {
    // Contract instances
    MarketManagerUpgradeable implementation;
    TransparentUpgradeableProxy proxy;
    MarketManagerUpgradeable marketManager;
    ProxyAdmin proxyAdmin;

    UmaCtfAdapterUpgradeable umaCtfAdapter;
    FeeManagerUpgradeable feeManager;
    RewardsManagerUpgradeable rewardsManager; // Properly declared

    // Roles
    bytes32 public constant MARKET_MANAGER_ROLE = keccak256("MARKET_MANAGER_ROLE");
    bytes32 public constant REWARDS_MANAGER_ROLE = keccak256("REWARDS_MANAGER_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    // Addresses
    address admin;
    address user1;
    address user2;
    address treasuryAddress;
    address rewardsToken;
    address stakingToken;

    uint256 constant INITIAL_FEE_RATE = 100; // 1%

    // Event Declarations
    event MarketCreated(
        bytes32 indexed marketId,
        string category,
        string description,
        uint256 fee,
        bool active,
        bool acceptingOrders,
        uint256 endTime,
        address conditionalTokens,
        bytes32 conditionId
    );

    event BetPlaced(
        bytes32 indexed marketId,
        address indexed user,
        uint256 outcomeIndex,
        uint256 amount
    );

    event BetCanceled(
        bytes32 indexed marketId,
        address indexed user,
        uint256 outcomeIndex,
        uint256 amount
    );

    event WinningsWithdrawn(
        bytes32 indexed marketId,
        address indexed user,
        uint256 amount
    );

    event MarketResolved(
        bytes32 indexed marketId,
        uint256 winningOutcomeIndex
    );

    event FeesWithdrawn(address indexed recipient, uint256 amount);

    function setUp() public {
        admin = address(this);
        user1 = address(0x123);
        user2 = address(0x456);
        treasuryAddress = address(0x789);
        rewardsToken = address(0xabc);
        stakingToken = address(0xdef);

        // Fund user2 with ETH for testing
        vm.deal(user2, 10 ether);

        // Deploy actual contracts
        umaCtfAdapter = new UmaCtfAdapterUpgradeable();
        rewardsManager = new RewardsManagerUpgradeable();
        feeManager = new FeeManagerUpgradeable();

        // Initialize contracts with test parameters
        umaCtfAdapter.initialize(admin, address(0), address(0), 0);
        rewardsManager.initialize(admin, address(0), address(0));
        feeManager.initialize(admin, INITIAL_FEE_RATE, treasuryAddress, rewardsToken);
        rewardsManager.initialize(admin, rewardsToken, stakingToken);


        // Deploy Implementation
        implementation = new MarketManagerUpgradeable();

        // Deploy ProxyAdmin
        proxyAdmin = new ProxyAdmin(admin);

        // Encode initializer
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address)",
            address(umaCtfAdapter),
            address(rewardsManager),
            address(feeManager)
        );

        // Deploy Proxy
        proxy = new TransparentUpgradeableProxy(
            address(implementation),
            address(proxyAdmin),
            data
        );

        // Cast proxy to MarketManagerUpgradeable
        marketManager = MarketManagerUpgradeable(address(proxy));
    }

    function testInitialRoles() public {
        bool hasAdminRole = marketManager.hasRole(
            marketManager.DEFAULT_ADMIN_ROLE(),
            admin
        );
        assertTrue(hasAdminRole, "Admin should have DEFAULT_ADMIN_ROLE");

        bool hasMarketManagerRole = marketManager.hasRole(
            MARKET_MANAGER_ROLE,
            admin
        );
        assertTrue(hasMarketManagerRole, "Admin should have MARKET_MANAGER_ROLE");

        bool hasRewardsManagerRole = marketManager.hasRole(
            REWARDS_MANAGER_ROLE,
            admin
        );
        assertTrue(hasRewardsManagerRole, "Admin should have REWARDS_MANAGER_ROLE");

        bool hasFeeManagerRole = marketManager.hasRole(
            FEE_MANAGER_ROLE,
            admin
        );
        assertTrue(hasFeeManagerRole, "Admin should have FEE_MANAGER_ROLE");

        bool hasOracleRole = marketManager.hasRole(
            ORACLE_ROLE,
            admin
        );
        assertTrue(hasOracleRole, "Admin should have ORACLE_ROLE");
    }

    function testGrantAndRevokeRoles() public {
        marketManager.grantRole(MARKET_MANAGER_ROLE, user1);
        bool hasRole = marketManager.hasRole(MARKET_MANAGER_ROLE, user1);
        assertTrue(hasRole, "User1 should have MARKET_MANAGER_ROLE");

        marketManager.revokeRole(MARKET_MANAGER_ROLE, user1);
        hasRole = marketManager.hasRole(MARKET_MANAGER_ROLE, user1);
        assertFalse(hasRole, "User1 should not have MARKET_MANAGER_ROLE");
    }

    function testOnlyMarketManagerCanCreateMarket() public {
        bytes32 questionId = keccak256("Will ETH reach $5000 by next week?");
        
        // Correctly declare and initialize outcomeTokens
        string[] memory outcomeTokens = new string[](2);
        outcomeTokens[0] = "Yes";
        outcomeTokens[1] = "No";

        string memory category = "Cryptocurrency";
        string memory description = "Predict if ETH will reach $5000";
        uint256 fee = 100; // 1%
        uint256 duration = 7 days;

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)",
                user1,
                MARKET_MANAGER_ROLE
            )
        );
        marketManager.createMarket(
            questionId,
            outcomeTokens,
            category,
            description,
            fee,
            duration
        );
    }

    function testMarketCreation() public {
        marketManager.grantRole(MARKET_MANAGER_ROLE, user1);
        assertTrue(
            marketManager.hasRole(MARKET_MANAGER_ROLE, user1),
            "User1 should have MARKET_MANAGER_ROLE"
        );

        bytes32 questionId = keccak256("Will ETH reach $5000 by next week?");
        
        // Correctly declare and initialize outcomeTokens
        string[] memory outcomeTokens = new string[](2);
        outcomeTokens[0] = "Yes";
        outcomeTokens[1] = "No";

        string memory category = "Cryptocurrency";
        string memory description = "Predict if ETH will reach $5000";
        uint256 fee = 100; // 1%
        uint256 duration = 7 days;

        vm.prank(user1);

        vm.expectEmit(true, true, false, true);
        emit MarketCreated(
            keccak256(abi.encodePacked(questionId, block.timestamp, user1)),
            category,
            description,
            fee,
            true,
            true,
            block.timestamp + duration,
            address(0),
            bytes32(0)
        );

        bytes32 marketId = marketManager.createMarket(
            questionId,
            outcomeTokens,
            category,
            description,
            fee,
            duration
        );

        bool exists = marketManager.marketExists(marketId);
        assertTrue(exists, "Market should exist after creation");

        IMarketManagerUpgradeable.MarketMetadata memory metadata = marketManager.getMarketMetadata(marketId);
        assertEq(metadata.category, category, "Category mismatch");
        assertEq(metadata.description, description, "Description mismatch");
        assertEq(metadata.fee, fee, "Fee mismatch");
        assertTrue(metadata.active, "Market should be active");
        assertTrue(metadata.acceptingOrders, "Market should be accepting orders");
        assertEq(metadata.endTime, block.timestamp + duration, "End time mismatch");
        assertEq(metadata.conditionalTokens, address(0), "ConditionalTokens address mismatch");
    }

    function testPlaceBet() public {
        marketManager.grantRole(MARKET_MANAGER_ROLE, user1);

        bytes32 questionId = keccak256("Will BTC reach $60000 by next month?");

        // Correctly declare and initialize outcomeTokens
        string[] memory outcomeTokens = new string[](2);
        outcomeTokens[0] = "Yes";
        outcomeTokens[1] = "No";

        string memory category = "Cryptocurrency";
        string memory description = "Predict if BTC will reach $60000";
        uint256 fee = 200; // 2%
        uint256 duration = 30 days;

        vm.prank(user1);
        bytes32 marketId = marketManager.createMarket(
            questionId,
            outcomeTokens,
            category,
            description,
            fee,
            duration
        );

        uint256 betAmount = 1 ether;
        uint256 outcomeIndex = 0; // "Yes"

        vm.prank(user2);
        vm.expectEmit(true, true, false, true);
        emit BetPlaced(marketId, user2, outcomeIndex, betAmount);
        marketManager.placeBet{value: betAmount}(marketId, outcomeIndex);

        (uint256 amount, uint256 idx, bool withdrawn) = marketManager.getUserBet(marketId, user2);
        assertEq(amount, betAmount, "Bet amount mismatch");
        assertEq(idx, outcomeIndex, "Outcome index mismatch");
        assertFalse(withdrawn, "Bet should not be withdrawn");
    }

    function testCancelBet() public {
        marketManager.grantRole(MARKET_MANAGER_ROLE, user1);

        bytes32 questionId = keccak256("Will DOGE reach $1 by next month?");

        // Correctly declare and initialize outcomeTokens
        string[] memory outcomeTokens = new string[](2);
        outcomeTokens[0] = "Yes";
        outcomeTokens[1] = "No";

        string memory category = "Cryptocurrency";
        string memory description = "Predict if DOGE will reach $1";
        uint256 fee = 150; // 1.5%
        uint256 duration = 30 days;

        vm.prank(user1);
        bytes32 marketId = marketManager.createMarket(
            questionId,
            outcomeTokens,
            category,
            description,
            fee,
            duration
        );

        uint256 betAmount = 0.5 ether;
        uint256 outcomeIndex = 1; // "No"

        vm.prank(user2);
        marketManager.placeBet{value: betAmount}(marketId, outcomeIndex);

        uint256 initialBalance = user2.balance;

        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit BetCanceled(marketId, user2, outcomeIndex, betAmount);
        marketManager.cancelBet(marketId, outcomeIndex, user2);

        (uint256 amount, uint256 idx, bool withdrawn) = marketManager.getUserBet(marketId, user2);
        assertEq(amount, 0, "Bet amount should be zero after cancellation");
        assertEq(idx, outcomeIndex, "Outcome index should remain the same");
        assertTrue(withdrawn, "Bet should be marked as withdrawn");

        uint256 finalBalance = user2.balance;
        assertEq(finalBalance, initialBalance + betAmount, "User2 should have received the refund");
    }
}
