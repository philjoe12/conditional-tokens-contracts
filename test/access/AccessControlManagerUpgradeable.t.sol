// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Import the Test contract from Forge standard library
import "lib/forge-std/src/Test.sol";

import "lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

// Import the AccessControlManagerUpgradeable contract
import "../../src/access/AccessControlManagerUpgradeable.sol";

/**
 * @title AccessControlManagerUpgradeableTest
 * @dev Test cases for the AccessControlManagerUpgradeable contract
 */
contract AccessControlManagerUpgradeableTest is Test {
     // Define the custom errors as per IAccessControl.sol
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error AccessControlBadConfirmation();

    TransparentUpgradeableProxy proxy; // Declaration added here
    AccessControlManagerUpgradeable accessControl;
    ProxyAdmin proxyAdmin;
    address admin;
    address newCreator;
    address feeAdmin;
    address rewardsAdmin;
    address nonAdmin;

    // Events from AccessControlUpgradeable
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function setUp() public {
        // Define the admin address for initialization
        admin = address(this);
        newCreator = address(0x123);
        feeAdmin = address(0x456);
        rewardsAdmin = address(0x789);
        nonAdmin = address(0xABC);

        // Deploy the implementation contract
        AccessControlManagerUpgradeable implementation = new AccessControlManagerUpgradeable();

        // Deploy the ProxyAdmin contract
        proxyAdmin = new ProxyAdmin(admin);

        // Prepare the initialization data
        bytes memory data = abi.encodeWithSignature("initialize(address)", admin);

        // Deploy the proxy, pointing to the implementation and initializing it
        proxy = new TransparentUpgradeableProxy(address(implementation), address(proxyAdmin), data);


        // Cast the proxy address to the AccessControlManagerUpgradeable interface
        accessControl = AccessControlManagerUpgradeable(address(proxy));
    }

    function testInitialAdminRole() public {
        // Check that the admin has the DEFAULT_ADMIN_ROLE
        bool hasAdminRole = accessControl.hasRoleIn(accessControl.DEFAULT_ADMIN_ROLE(), admin);
        assertTrue(hasAdminRole, "Admin should have DEFAULT_ADMIN_ROLE");
    }

    function testGrantRole() public {
        // Grant MARKET_CREATOR_ROLE to newCreator
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Verify the role was granted
        bool hasRole = accessControl.hasRoleIn(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        assertTrue(hasRole, "New creator should have MARKET_CREATOR_ROLE");
    }

    function testRevokeRole() public {
        // Grant and then revoke MARKET_CREATOR_ROLE
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        accessControl.revokeRoleFrom(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Verify the role was revoked
        bool hasRole = accessControl.hasRoleIn(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        assertFalse(hasRole, "New creator should not have MARKET_CREATOR_ROLE after revocation");
    }

    /**
     * @notice Test that only the admin can grant roles.
     * @dev Expects a revert when a non-admin tries to grant a role.
     */

    function testOnlyAdminCanGrantRole() public {
        console.log("Testing non-admin grant role...");
        console.log("Current caller:", msg.sender);
        console.log("Non-admin address:", nonAdmin);
        
        // Make sure nonAdmin doesn't have admin role
        assertFalse(
            accessControl.hasRole(accessControl.DEFAULT_ADMIN_ROLE(), nonAdmin),
            "Non-admin should not have admin role"
        );

        // Attempt to grant role from non-admin
        vm.startPrank(nonAdmin);
        
        bytes memory expectedError = abi.encodeWithSelector(
            AccessControlUnauthorizedAccount.selector,
            nonAdmin,
            accessControl.DEFAULT_ADMIN_ROLE()
        );
        
        vm.expectRevert(expectedError);
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        vm.stopPrank();
    }


    /**
     * @notice Test that only the admin can revoke roles.
     * @dev Expects a revert when a non-admin tries to revoke a role.
     */
    function testOnlyAdminCanRevokeRole() public {
        // Grant role to newCreator first
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Attempt to revoke role from non-admin (should fail)
        vm.prank(nonAdmin);
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", nonAdmin, accessControl.DEFAULT_ADMIN_ROLE()));
        accessControl.revokeRoleFrom(accessControl.MARKET_CREATOR_ROLE(), newCreator);
    }

    function testAdminCanGrantMultipleRoles() public {
        // Grant FEE_ADMIN_ROLE
        accessControl.grantRoleTo(accessControl.FEE_ADMIN_ROLE(), feeAdmin);
        bool hasFeeAdminRole = accessControl.hasRoleIn(accessControl.FEE_ADMIN_ROLE(), feeAdmin);
        assertTrue(hasFeeAdminRole, "Fee Admin should have FEE_ADMIN_ROLE");

        // Grant REWARDS_ADMIN_ROLE
        accessControl.grantRoleTo(accessControl.REWARDS_ADMIN_ROLE(), rewardsAdmin);
        bool hasRewardsAdminRole = accessControl.hasRoleIn(accessControl.REWARDS_ADMIN_ROLE(), rewardsAdmin);
        assertTrue(hasRewardsAdminRole, "Rewards Admin should have REWARDS_ADMIN_ROLE");
    }

    function testRoleRevocationDoesNotAffectOtherRoles() public {
        // Grant multiple roles to newCreator
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        accessControl.grantRoleTo(accessControl.FEE_ADMIN_ROLE(), newCreator);

        // Revoke MARKET_CREATOR_ROLE
        accessControl.revokeRoleFrom(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Verify MARKET_CREATOR_ROLE is revoked
        bool hasMarketCreatorRole = accessControl.hasRoleIn(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        assertFalse(hasMarketCreatorRole, "Market Creator Role should be revoked");

        // Verify FEE_ADMIN_ROLE still exists
        bool hasFeeAdminRole = accessControl.hasRoleIn(accessControl.FEE_ADMIN_ROLE(), newCreator);
        assertTrue(hasFeeAdminRole, "Fee Admin Role should still be active");
    }

    function testGrantRoleEmitsEvent() public {
        // Expect the RoleGranted event
        vm.expectEmit(true, true, false, true);
        emit RoleGranted(accessControl.MARKET_CREATOR_ROLE(), newCreator, admin);
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);
    }

    function testRevokeRoleEmitsEvent() public {
        // Grant role first
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Expect the RoleRevoked event
        vm.expectEmit(true, true, false, true);
        emit RoleRevoked(accessControl.MARKET_CREATOR_ROLE(), newCreator, admin);
        accessControl.revokeRoleFrom(accessControl.MARKET_CREATOR_ROLE(), newCreator);
    }

        function testNoUnintendedRoles() public {
        // Define a list of roles
        bytes32[] memory roles = new bytes32[](4);
        roles[0] = accessControl.MARKET_ROLE();
        roles[1] = accessControl.FEE_ADMIN_ROLE();
        roles[2] = accessControl.REWARDS_ADMIN_ROLE();
        roles[3] = accessControl.GOVERNANCE_ADMIN_ROLE();

        for (uint256 i = 0; i < roles.length; i++) {
            bool hasRole = accessControl.hasRoleIn(roles[i], admin);
            assertFalse(hasRole, string(abi.encodePacked("Admin should not have role: ", toString(roles[i]))));
        }
    }

    /**
     * @notice Test that a role holder can renounce their role.
     * @dev Expects a revert with AccessControlBadConfirmation() when renouncing.
     */
    function testRenounceRole() public {
        // Grant role to newCreator
        accessControl.grantRoleTo(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Simulate newCreator renouncing the role
        vm.prank(newCreator);
        vm.expectRevert(abi.encodeWithSignature("AccessControlBadConfirmation()"));
        accessControl.renounceRole(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Simulate the correct account renouncing its own role (should pass)
        vm.prank(newCreator);
        accessControl.renounceRole(accessControl.MARKET_CREATOR_ROLE(), newCreator);

        // Verify the role was renounced
        bool hasRole = accessControl.hasRoleIn(accessControl.MARKET_CREATOR_ROLE(), newCreator);
        assertFalse(hasRole, "New creator should have renounced MARKET_CREATOR_ROLE");
    }

    // Helper function to convert bytes32 to string
    function toString(bytes32 _role) internal pure returns (string memory) {
        return string(abi.encodePacked(_role));
    }

    // Helper function to convert an address to a string
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    // Helper function to convert a bytes32 to a string
    function toHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = hexChars[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = hexChars[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    /**
     * @notice Helper function to convert a single byte to its ASCII character.
     * @param b The byte to convert.
     * @return c The ASCII character corresponding to the byte.
     */
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}