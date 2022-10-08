/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract EtherSenderPlus2 {
    address payable owner = payable(msg.sender);

    modifier onlyOwner {
        require(owner == msg.sender, "you are not authorizeid");
        _;
    }

    // Check that a minimum of 0.02 ether is injected
    constructor() payable {   
        if (msg.value >= 0.02 ether) {            
        } else {
            revert("Inject minimum 0.02 ether"); }                  
    }   
 
    // Sending 0.01 eth to the EOA call
    function sendLimitEthers() external {
        if (getBalance() >= 0.01 ether) {            
        } else {
            revert("without sufficient funds");
        }
        address payable to = payable(msg.sender);
        uint amount = (0.01 ether);
        to.transfer(amount);
    }

    // Sending half balance
    function sendHalfBalance() external {
        require(getBalance() > 0,"without sufficient funds");
        address payable to = payable(msg.sender);
        uint amount = getBalance() / 2;
        to.transfer(amount);
    }

    // Withdraw entier balance 
    function withdrawAllBalance() external onlyOwner {  
        require (getBalance() > 0,"not funds");    
        address payable to = payable(msg.sender);
        uint amount = getBalance();  
        to.transfer(amount);
    }  

    // Total public balance from the Smart contract
    function getBalance() public view returns (uint) {
        uint balance = address(this).balance;
        return balance;
    }   
}