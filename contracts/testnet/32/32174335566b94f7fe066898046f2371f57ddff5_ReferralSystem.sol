/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReferralSystem {
    address owner;


    constructor ()  
    {
        owner = msg.sender;
    }


    event onUpdateBuddy(address indexed player, address indexed buddy);
    

    mapping(address => address) private buddies;
    mapping(address => address[]) private Treeofbuddies;

   

        function updateBuddy(address buddy) public {

        require(buddyOf(buddy) != address(0) || buddy == owner && buddy != msg.sender ,"upline not found");
        require(buddyOf(msg.sender) == address(0) ,"Already have a team leader!");
        address upline = buddy; 
        buddies[msg.sender] = buddy;
        

        do {
               Treeofbuddies[msg.sender].push(upline);  // do while loop	
               upline = buddyOf(upline);
               
            }

             while (upline != address(0));
        
        
        emit onUpdateBuddy(msg.sender, buddy);
    }

    

    ///@dev Return the buddy of a player
    function buddyOf(address player) public view returns (address) {
        return buddies[player];
    }


        function buddyOft(address player) public view returns (address [] memory) {
        return Treeofbuddies[player];
    }

}