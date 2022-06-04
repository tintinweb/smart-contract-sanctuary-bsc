/**
 * @title Referrals
 * @dev Referrals contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./SafeMath.sol";
import "./IERC20.sol";
import "./IERC721.sol";
import "./Ownable.sol";
import "./IHelp.sol";
import "./IBlacklist.sol";

pragma solidity 0.8.4;

contract Referrals is Ownable {
    IBlacklist public blacklist;
    using SafeMath for uint256;

    struct MemberStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 time;
    }
    mapping(address => MemberStruct) public members; // Membership structure
    mapping(uint256 => address) public membersList; // Member listing by id
    mapping(uint256 => mapping(uint256 => address)) public memberChild; // List of referrals by user
    uint256 public lastMember; // ID of the last registered member

    /**
     * @dev add new members to the referrals database.
     *
     * Requirements:
     *
     * first member.
     * sender has the authorized role
     */
    function addMember(address _member, address _parent) public onlyAuthorized {
        if (lastMember > 0) {
            require(members[_parent].isExist, "Sponsor not exist");
        }
        MemberStruct memory memberStruct;
        memberStruct = MemberStruct({
            isExist: true,
            id: lastMember,
            referrerID: members[_parent].id,
            referredUsers: 0,
            time: block.timestamp
        });
        members[_member] = memberStruct;
        membersList[lastMember] = _member;
        memberChild[members[_parent].id][
            members[_parent].referredUsers
        ] = _member;
        members[_parent].referredUsers++;
        lastMember++;
        emit eventNewUser(msg.sender, _member, _parent);
    }

    /**
     * @dev returns the list of referrals.
     */
    function getListReferrals(address _member)
        public
        view
        returns (address[] memory)
    {
        address[] memory referrals = new address[](
            members[_member].referredUsers
        );
        if (members[_member].referredUsers > 0) {
            for (uint256 i = 0; i < members[_member].referredUsers; i++) {
                if (memberChild[members[_member].id][i] != address(0)) {
                    referrals[i] = memberChild[members[_member].id][i];
                } else {
                    break;
                }
            }
        }
        return referrals;
    }

    /**
     * @dev returns the address of the sponsor of an account.
     * return main address when _account is blacklisted.
     *
     * Requirements:
     *
     * address `account` cannot be the zero address.
     */
    function getSponsor(address _account) public view returns (address) {
        if (blacklist.isBlacklisted(_account) == false) {
            if (
                blacklist.isBlacklisted(
                    membersList[members[_account].referrerID]
                ) == false
            ) {
                return membersList[members[_account].referrerID];
            }
            return membersList[0];
        } else {
            return membersList[0];
        }
    }

    /**
     * @dev check if an address is registered
     *
     * Requirements:
     *
     * address `account` cannot be the zero address.
     * _user must exist.
     */
    function isMember(address _user) public view returns (bool) {
        return members[_user].isExist;
    }

    event eventNewUser(address _mod, address _member, address _parent);

    /**
     * @dev add address to the onlyAuthorized() role.
     *
     * Requirements:
     *
     * address `account` cannot be the zero address.
     * sender must be owner.
     */
    function setAuthorizedAddress(address addr, bool isAuthorized)
        external
        onlyOwner
    {
        authorizedAddresses[addr] = isAuthorized;
    }

    /**
     * @dev update the address blacklist contract.
     *
     * Requirements:
     *
     * address `_blacklistContract` cannot be the zero address.
     * sender must be owner.
     */
    function UpdateBlacklistContract(address _blacklistContract)
        public
        onlyOwner
    {
        blacklist = IBlacklist(_blacklistContract);
    }
}