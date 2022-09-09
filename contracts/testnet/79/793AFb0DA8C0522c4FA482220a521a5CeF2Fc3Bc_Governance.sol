/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

contract Governance {

    /**
        Contract Owner
     */
    address private owner;

    /**
        User => Permission Rank
     */
    mapping ( address => uint8 ) public permissions;

    /**
        Ensures Authority
     */
    modifier onlyOwner {
        require(
            msg.sender == owner,
            'Only Owner'
        );
        _;
    }

    /**
        Signifies Owner Has Changed
     */
    event ChangeOwner(address oldOwner, address newOwner);

    function setPermissions(address user, uint8 permissionRank) external onlyOwner {
        permissions[user] = permissionRank;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            'Zero Address'
        );
        emit ChangeOwner(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() external onlyOwner {
        emit ChangeOwner(owner, address(0));
        owner = address(0);
    }

    function hasPermissions(address user, uint8 rank) external view returns (bool) {
        return permissions[user] >= rank;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

}