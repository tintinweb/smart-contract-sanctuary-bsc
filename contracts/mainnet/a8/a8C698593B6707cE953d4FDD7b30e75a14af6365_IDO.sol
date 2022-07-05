/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

pragma solidity ^0.8.0;

contract IDO {

    struct User {
        uint invest;
        address[] invitees;
        uint nftnum;
        bool isPartner;
    }
    mapping(address => User) _users;

    function firstbox(uint num) external {

        User storage user = _users[msg.sender];

        user.nftnum = num-1;             

    }

    function closebox() external {

        User storage user = _users[msg.sender];
        require(user.nftnum == 0, "not open");

        user.nftnum -= 1;
                

    }

     function userInfo(address account) external view returns(uint invest, address[] memory invitees, bool isPartner,uint nftnum){

        User memory user = _users[account];
        return (user.invest, user.invitees, user.isPartner, user.nftnum);
    }

}