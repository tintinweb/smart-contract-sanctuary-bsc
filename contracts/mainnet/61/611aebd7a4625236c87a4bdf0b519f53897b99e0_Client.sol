/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT


contract Client  {
 
    address payable private hub;
    address public owner;
    uint256 public balance;

    
    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    
    constructor(address payable _hub) {
        hub = _hub;
        owner = msg.sender;
    }
    
    receive() payable external {
        balance += msg.value;
        emit TransferReceived(msg.sender, msg.value);
    }    

  
    
    function withdraw(uint amount, address payable destAddr) public {
        require(msg.sender == owner, "Only owner can withdraw funds"); 
        require(amount <= balance, "Insufficient funds");
        
        destAddr.transfer(amount);
        balance -= amount;
        emit TransferSent(msg.sender, destAddr, amount);
    }
    
    function start() public {
        require(msg.sender == owner, "Only owner can start the process"); 
        hub.transfer(balance);
        balance = 0;
        emit TransferSent(msg.sender, hub, balance);
    }   
}