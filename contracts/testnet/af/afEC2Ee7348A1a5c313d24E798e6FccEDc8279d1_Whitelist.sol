/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Whitelist {
    
    struct user{
       address userAddress;
       bool x;
    }

    struct use {
        string userName;
        bool lilo;       
    } 

    
    address public owner;
    uint public totalUser =0;
    
    mapping(address => bool) umoid;
    mapping(address => use) public checkUser;
    
    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Ownable: caller is not the owner");
      _;
    }

    modifier isWhitelisted(address _address) {
      require(umoid[_address], "Whitelist: You need to be whitelisted");
      _;
    }

    function addUser(address _userAddress, string memory _userName) public onlyOwner {
       use memory v;
       v.userName = _userName;
       v.lilo = true;
       checkUser[_userAddress] = v;
       totalUser++;
    }

    function removeUser(address _userAddress, string memory _userName) public onlyOwner {
       use memory v;
       v.userName = _userName;
       v.lilo = false;
       checkUser[_userAddress] = v;
       totalUser--;
    }
    
    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = umoid[_whitelistedAddress];
      return userIsWhitelisted;
    }

    function exampleFunction() public view isWhitelisted(msg.sender) returns(bool){
      return (true);
    }

}