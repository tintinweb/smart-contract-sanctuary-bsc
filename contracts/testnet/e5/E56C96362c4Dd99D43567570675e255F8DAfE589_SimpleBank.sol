/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

pragma solidity ^0.4.17;

contract SimpleBank {
    
    mapping (address => uint) private balances;
    address public contractOwner;
    
    function SimpleBank() public {
        contractOwner = msg.sender;
    }

    event Deposit(address account, uint amount);
    event Withdraw(address account, uint amount);

    modifier restricted(){
        require(msg.sender == contractOwner);
        _;
    } 

    function deposit() public payable returns(uint) {
        require(balances[msg.sender] + msg.value >= balances[msg.sender]);
        balances[msg.sender] += msg.value;
        return balances[msg.sender];
    }

    function withdraw(uint withdrawAmount) public returns(uint) {
        require(balances[msg.sender] - withdrawAmount <= balances[msg.sender]);
        balances[msg.sender] -= withdrawAmount;
        msg.sender.transfer(withdrawAmount);
        return balances[msg.sender];     
    }

    function getBalance() public view returns(uint) {
        return balances[msg.sender];
    }

    function getSpecificAccountBalance(address account) public restricted view returns(uint) {
        return balances[account];
    }
}