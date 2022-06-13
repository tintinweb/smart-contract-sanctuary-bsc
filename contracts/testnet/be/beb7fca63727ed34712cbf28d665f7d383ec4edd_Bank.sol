/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity 0.7.5;


contract Bank {

mapping (address => uint) balance;  //This mapping defines address as key and Ether Balance Value

/*@dev A set of events has been created to log changes on balances */

event checkDepositLogs(address reciever , uint amount);
event checkWithdrawLogs(address withdrawAddress, uint amount);
event checkTransferLogs(address transferfrom, uint amount);


address owner;



modifier onlyOwner {
    require(msg.sender == owner, "Only the owner has the ability to excute this function");
    _;
}

constructor(address _owner) {
    owner = _owner;
}


function depositBalance() public payable returns(uint) {


    balance[msg.sender] += msg.value;
    emit checkDepositLogs(msg.sender,msg.value);
    return balance[msg.sender];

}

function withdrawFunds(uint amount) public {

    require(balance[msg.sender] >= amount,"Insufficient Balance");
    uint newPreviousBalance = balance[msg.sender];
    balance[msg.sender] -= amount;
    assert(balance[msg.sender] == newPreviousBalance - amount);
    emit checkWithdrawLogs(msg.sender,amount);
    msg.sender.transfer(amount);




}



function transferFunds(address recipient, uint amount) public {

    require(balance[msg.sender] >= amount,"Insufficient Balance");
    require(msg.sender != recipient,"Owner cannot transfer funds to himself");
    emit checkTransferLogs(msg.sender,amount);
    _transfer(msg.sender,recipient,amount);

}




function _transfer(address from, address to, uint amount) private {

    balance[from] -= amount;
    balance[to] += amount;

}




function getBalance() public view returns(uint) {
    return balance[msg.sender];

}

}