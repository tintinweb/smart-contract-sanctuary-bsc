/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract DepositFunds {
    mapping(address => uint)public balances;

    function deposit()external payable {
        balances[msg.sender] += msg.value;
    }
 
    function withdraw(uint _amount)external{
        // uint bal = balances[msg.sender];
        require(balances[msg.sender] >= _amount);

        (bool sent, ) = msg.sender.call{value:balances[msg.sender]}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }
    function getbalance()public view returns(uint){
        return address(this).balance;
    }
}