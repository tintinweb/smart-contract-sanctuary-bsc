// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/// @title Referral Tracker
/// @author 0x6Fa02ed6248A4a78609368441265a5798ebaFC78
/// @notice This contracts allows pre-approved smart contracts to attach referrers to wallets. A wallet can only has one referrer, which is attached for life. This contract can be used to payout referral fees.
/// @dev Built for Rounds V4. Use is restricted to pre-approved contracts.
contract Referral {
    address public owner;

    mapping(address=>address) public referrers;      // user -> referrer
    mapping(address=>address[]) public referrals;   // referrer -> [users]
    mapping(address=>uint256) public referralCount; // referrer -> referralCount
    uint256 referred;

    mapping(address=>bool) public is_admin;

    // Events
    event newReferral(address user, address referrer, address from_contract);
    event newAdmin(address admin);
    event byeAdmin(address admin);

    constructor () {
        owner = msg.sender;
        addAdmin(owner);
    }

    /// @notice Attach a referrer address to a user address.
    /// @param user User Address
    /// @param referrer Referrer Address
    /// @return success True if the referrer was attached ot the user
    function refer(address user, address referrer) public returns (bool) {
        require(is_admin[msg.sender], "Forbidden");
        require(user!=referrer, "Self Referral Forbidden");
        if (user==referrer) {
            return false;
        }
        if (referrers[user]==address(0)) {
            referrers[user] = referrer;
            referrals[referrer].push(user);
            referralCount[referrer] = referralCount[referrer] + 1;
            referred = referred + 1;
            emit newReferral(user, referrer, msg.sender);
            return true;
        }
        return true;
    }

    /// @notice Restricted to owner. Allow a contract to refer users.
    /// @param admin Contract or wallet Address
    function addAdmin(address admin) public {
        require(msg.sender==owner, "Forbidden");
        is_admin[admin] = true;
        emit newAdmin(admin);
    }

    /// @notice Restricted to owner. Stop allowing a contract to refer users.
    /// @param admin Contract or wallet Address
    function disableAdmin(address admin) public {
        require(msg.sender==owner, "Forbidden");
        is_admin[admin] = false;
        emit byeAdmin(admin);
    }

    /// @notice Returns the referrer attached to the user or 0x0000000000000000000000000000000000000000 if the user has no referrer.
    /// @param user User Address
    /// @return hasReferrer True if the user has a referrer
    /// @return referrer Referrer address
    function get(address user) public view returns (bool, address) {
        return (referrers[user]!=address(0), referrers[user]);
    }
}