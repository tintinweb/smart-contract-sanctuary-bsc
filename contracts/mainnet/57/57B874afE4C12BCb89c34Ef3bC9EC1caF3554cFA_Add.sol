/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

pragma solidity ^0.5.0;

contract Add{
struct User {
    uint256 id;
    string name;
 
    // other stuff

    bool set; // This boolean is used to differentiate between unset and zero struct values
}
 address public owner;
 modifier onlyOwner() {
       require(owner == msg.sender);
            _;
}
constructor() public {
  owner = msg.sender;
}
mapping(address => User) public users;

function createUser(address _userAddress, uint256 _userId, string memory _userName) public  {
    User storage user = users[_userAddress];
    // Check that the user did not already exist:
    require(!user.set);
    //Store the user
    users[_userAddress] = User({
        id: _userId,
        name: _userName,
        set: true
    });
}

}