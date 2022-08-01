/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

contract Ownable 
{    
    // Variable that maintains 
    // owner address
    address private _owner;
    
    // Sets the original owner of 
    // contract when it is deployed
    constructor()
    {
        _owner = msg.sender;
    }
    
    // Publicly exposes who is the
    // owner of this contract
    function owner() public view returns(address) 
    {
        return _owner;
    }
    
    // onlyOwner modifier that validates only 
    // if caller of function is contract owner, 
    // otherwise not
    modifier onlyOwner() 
    {
        require(isOwner(),
        "Function accessible only by the owner !!");
        _;
    }
    
    // function for owners to verify their ownership. 
    // Returns true for owners otherwise false
    function isOwner() public view returns(bool) 
    {
        return msg.sender == _owner;
    }
}

contract NorfWallet is Ownable {
   
   
    mapping(address => string) private _admins;
    mapping(string => bool) private _roles;
 
       
    constructor(string memory _baserole, address _baseUser ) public {
        addRole(_baserole);
        addToAdmins(_baseUser, _baserole);
    }

    function addRole(string memory _role) public onlyOwner {
       _roles[_role] = true;
    }

    function roleExits(string memory _role) public view onlyOwner returns(bool){
         require(_roles[_role], "This role not exists");
         return true;
    }

    function addToAdmins(address _user, string memory _role) public onlyOwner {
       require(_roles[_role], "This role not exists");
       _admins[_user] = _role;
    }

    function removeFromAdmins(address _user) public onlyOwner {
        require(keccak256(abi.encodePacked(_admins[_user])) != "", "This address not added");
        delete _admins[_user];
    }

    
    function hasAccess(string memory _role) public view returns(bool)
    {
       address userAddress = msg.sender;
       require(keccak256(abi.encodePacked(_admins[userAddress])) != "", "This address not added");
       return keccak256(abi.encodePacked(_admins[userAddress])) == keccak256(abi.encodePacked(_role));
    }
   
   
}