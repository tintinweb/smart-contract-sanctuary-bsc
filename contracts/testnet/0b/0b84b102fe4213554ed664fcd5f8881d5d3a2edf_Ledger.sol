/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// File: contracts/Ledger.sol


pragma solidity ^0.8.0;

contract Ledger{
    struct UserInfo {
        uint256 amount; 
        uint256 rewardDebt; 
    }
    mapping(address => UserInfo) public userInfo;

    function deposit(uint256 _amount) external {
        require(_amount > 0, "error amount");
        
        UserInfo storage user = userInfo[msg.sender];
        user.amount = user.amount + _amount;

    }

    function withdraw(uint256 _amount) external  {
        require(_amount > 0, "error amount");

        UserInfo storage user = userInfo[msg.sender];

        require(user.amount >= _amount, "error amount");

         user.amount = user.amount - _amount;
    }

}