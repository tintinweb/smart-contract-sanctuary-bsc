/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/
pragma solidity ^0.4.25;
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, 'only owner');
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

pragma solidity ^0.4.25;
contract BuddySystem is Ownable {
    event onUpdateBuddy(address indexed player, address indexed buddy);
    mapping(address => address) private buddies;
    function() payable external {
        require(false, "Don't send funds to this contract!");
    }
    function updateBuddy(address buddy) public {
        buddies[msg.sender] = buddy;
        emit onUpdateBuddy(msg.sender, buddy);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
   
    function updateBuddyFromPresale(address buddy, address _buddies) public onlyOwner {
          buddies[_buddies] = buddy;
        emit onUpdateBuddy(_buddies, buddy);
    }
    function myBuddy() public view returns (address){
        return buddyOf(msg.sender);
    }
    function buddyOf(address player) public view returns (address) {
        return buddies[player];
    }
}