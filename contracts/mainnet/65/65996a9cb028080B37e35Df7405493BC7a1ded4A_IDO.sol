/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

pragma solidity ^0.8.0;

interface Iuser{
        function userInfo(address account) external view returns(uint invest, address[] memory invitees, bool isPartner, bool isClaimed, bool isRefund, bool isReStake,uint totalAmount,uint nftnum);
}

contract IDO {

    address constant public _IDO = 0xF8BEE6F9c81d0Ea3312eB452b3C018304e497006;

    struct User {
        uint invest;
        address[] invitees;
        uint nftnum;
        bool isPartner;
        bool isClaimed;
        bool isRefund;
        bool isReStake;
    }
    mapping(address => User) _users;

    function bindbox() external {


        (uint invest, address[] memory invitees, bool isPartner, bool isClaimed, bool isRefund, bool isReStake,uint totalAmount,uint nftnum) = Iuser(_IDO).userInfo(msg.sender);

        User storage user = _users[msg.sender];
        require(user.isClaimed!=true,"mapped");
        user.invest = invest;
        user.invitees = invitees;
        user.isPartner = isPartner;
        user.nftnum = nftnum;  
        user.isClaimed = true;           

    }

    function closebox() external {

        User storage user = _users[msg.sender];
        // require(user.nftnum == 0, "not open");

        user.nftnum -= 1;
                

    }

    
    function openbox() external {

        User storage user = _users[msg.sender];
        // require(user.nftnum == 0, "not open");
        // require(user.invest >= 38e18, "not open");

        user.nftnum += 1;
                

    }

    function setbox(uint num) external {

        User storage user = _users[msg.sender];
        require(user.invest >= 38e18, "not open");

        user.nftnum = num;
                

    }

     function userInfo(address account) external view returns(uint invest, address[] memory invitees, bool isPartner,uint nftnum){

        User memory user = _users[account];
        return (user.invest, user.invitees, user.isPartner, user.nftnum);
    }

}