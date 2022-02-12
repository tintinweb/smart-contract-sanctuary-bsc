/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// File: contracts/game/Evangelist.sol
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

contract Evangelist {
    struct User {
        bool status;
        address referral;
        address[] referre;
    }

    mapping(address => User) public userInfo;
    event SetEvangalist(address user, address evangalist);

    function setEvangalist(address referral) external {
        require(
            (referral != address(0x00)) && (referral != msg.sender),
            "Zero/invalid address"
        );
        address user = msg.sender;
        require(
            !userInfo[user].status,
            "Only once user can set the evangalist address"
        );
        userInfo[user].status = true;
        userInfo[user].referral = referral;

        userInfo[referral].referre.push(user);

        emit SetEvangalist(msg.sender, referral);
    }

    function getReferral(address user)
        external
        view
        returns (address referral)
    {
        return (userInfo[user].referral);
    }

    function getUserInfo(address user)
        external
        view
        returns (address referral, address[] memory referre)
    {
        return (userInfo[user].referral, userInfo[user].referre);
    }
}