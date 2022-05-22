/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TimeLockWallet {
    address public owner;

    mapping(address=>uint256) public balanceOf;
    mapping(address=>bool) public isVerified;
    mapping(address=>Person) public addrToPerson;
    uint256 public addressCount;

    struct Person {
        string _name;
        uint256 _age;
        string _address;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Invalid, only the owner can access this function");
        _;
    }

    modifier onlyVerifiedUser{
        require(isVerified[msg.sender]==true, "Invalid, user not verified");
        _;
    }
    
    modifier onlyUnverifiedUser{
        require(isVerified[msg.sender]==false, "Invalid you are already a verified user");
        _;
    }

    constructor(){ 
        owner = msg.sender;
    }

    event PersonAdded(
        address _addr
    );

    function addAddress(address _addr) public onlyOwner{

        uint256 endTime = block.timestamp + 10 days;

        if(isVerified[_addr] == true && endTime >= block.timestamp) {
            balanceOf[_addr] = 0;
            addressCount+=1;
            emit PersonAdded(_addr);
        }
    }

    function verifyAddress(string memory _name, uint256 _age, string memory _addr) public onlyUnverifiedUser {
        addrToPerson[msg.sender] = Person(_name, _age, _addr);
        isVerified[msg.sender] = true;
    }
}