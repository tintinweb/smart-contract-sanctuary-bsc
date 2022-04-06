// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Basic.sol";

contract Members is Basic {
    struct MemberStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 time;
    }
    mapping(address => MemberStruct) public members;
    mapping(uint256 => address) public membersList;
    mapping(uint256 => mapping(uint256 => address)) public memberChild;
    uint256 public lastMember;

    //constructor() public {}

    function isMember(address _user) public view returns (bool) {
        return members[_user].isExist;
    }

    function addMember(address _member, address _parent) public onlyMod {
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
    }

    function infoMember(address _member)
        public
        view
        returns (
            bool isExist,
            uint256 id,
            uint256 referrerID,
            uint256 referredUsers,
            uint256 time
        )
    {
        MemberStruct memory member = members[_member];
        return (
            member.isExist,
            member.id,
            member.referrerID,
            member.referredUsers,
            member.time
        );
    }

    function getParentTree(address _member, uint256 _deep)
        public
        view
        returns (address[] memory)
    {
        address[] memory parentTree = new address[](_deep);
        address referrerLevel = membersList[members[_member].referrerID];
        if (referrerLevel != address(0)) {
            parentTree[0] = referrerLevel;
        }
        for (uint256 i = 1; i < _deep; i++) {
            if (referrerLevel != address(0)) {
                referrerLevel = getUserReferrerLast(referrerLevel);
                if (referrerLevel != address(0)) {
                    parentTree[i] = referrerLevel;
                }
            } else {
                break;
            }
        }
        return parentTree;
    }

    function getUserReferrerLast(address _user) public view returns (address) {
        return membersList[members[_user].referrerID];
    }
}