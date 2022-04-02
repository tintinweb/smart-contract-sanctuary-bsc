/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity ^0.4.25;
contract BuddySystem {
    event onUpdateBuddy(address indexed player, address indexed buddy);
    mapping(address => address) private buddies;
    function() payable external {
        require(false, "Don't send funds to this contract!");
    }
    function updateBuddy(address buddy) public {
        buddies[msg.sender] = buddy;
        emit onUpdateBuddy(msg.sender, buddy);
    }
    function myBuddy() public view returns (address){
        return buddyOf(msg.sender);
    }
    function buddyOf(address player) public view returns (address) {
        return buddies[player];
    }
}