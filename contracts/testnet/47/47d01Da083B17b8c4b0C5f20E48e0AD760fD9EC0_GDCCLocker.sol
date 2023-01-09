/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract GDCCLocker {
    address public admin;

    constructor() {
        // Set the contract's admin to the address that deployed it
        admin = msg.sender;
    }
    mapping(address => userStruct) public user;
        uint[2] public total; //0- total allocated, 1- total claimed 
     
    struct userStruct {
        uint balance;
        uint lockEndTime;
        uint lastClaim;
        uint claimable;
    }
        function addDistributionWallet( address[] memory account, uint[] memory amount, uint[] memory endTime) external payable  {
        require(msg.sender == admin, "Only the contract's admin can lock an account.");
        require(account.length < 250,"Locker  : length < 250");
        require((account.length == amount.length) && (endTime.length == amount.length),"Airdrop  : length mismatch");
        uint currentTime = block.timestamp;

        for(uint i=0; i< account.length; i++) {
        require ( account[i] != 0x0000000000000000000000000000000000000000, "remove the zero address");
            require((total[0] + amount[i]) <= admin.balance, "Airdrop  : insufficient balance to allocate");
            require(endTime[i] > currentTime, "start time should be > current time");

            userStruct storage userStorage = user[account[i]];
            userStorage.balance += amount[i];
            total[0] += amount[i];
            
            if(userStorage.lockEndTime == 0) {
                userStorage.lockEndTime = endTime[i];
                userStorage.lastClaim = endTime[i];
            }
        }
    }

    function unlock() public {
   require( user[msg.sender].lockEndTime  <= block.timestamp," lock time not completed");
    uint amount =  user[msg.sender].balance ;
    require(amount > 0," no registered" );
    payable(msg.sender).transfer(amount);
    user[msg.sender].claimable += amount;
    user[msg.sender].balance -= amount;
    total[1] += amount;
    }
    function viewClaim (address _add) public view returns(uint256 amt ) {
       if ( user[_add].lockEndTime >= block.timestamp){
           amt = 0;
           return amt;
       } 
        if ( user[_add].lockEndTime <= block.timestamp){
           amt = user[_add].balance ;
           return amt;
       } 


    }
    function withdraw(uint amount) public {
        require(msg.sender == admin, "Only the contract's admin can lock an account.");
        payable(msg.sender).transfer(amount);
    }
}