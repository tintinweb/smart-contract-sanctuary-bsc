/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity ^0.5.13;


contract FunctionsExample {

    mapping(address => uint) public balanceReceived;

    address payable owner;

    constructor() public {
        owner = msg.sender;
    }

    function destroySmartContract() public {
        require(msg.sender ==owner, "You are not the owner");
        selfdestruct(owner);     
    }
    
    function receiveMoney() public payable {
        assert(balanceReceived[msg.sender] + msg.value >= balanceReceived[msg.sender]);
        balanceReceived[msg.sender] += msg.value;
    }

    function withdrawMoney(address payable _to, uint _amount) public {
        require(_amount <= balanceReceived[msg.sender], "Not Enough Funds");
        assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - _amount);
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }

        function () external payable {
            receiveMoney();
        }
    }