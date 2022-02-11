/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

/// Console Cowboys Smart Contract Hacking Course
/// @author Olie Brown @ficti0n
/// http://cclabs.io 


pragma solidity ^0.6.6;

contract simpleAuth2 {
    address owner;
    mapping (address =>uint) balances;
    
    constructor() public {
      owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
  }

    function deposit() public payable{
 	    balances[msg.sender] = balances[msg.sender]+msg.value;	
    }
    
    function withdraw(uint amount) public payable {
        require (balances[msg.sender] >= amount);
        msg.sender.transfer(amount);
    }
    
    function kill() public onlyOwner{
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }
}