/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

pragma solidity 0.5.16;


contract StoneCoin{

    mapping (address => uint) public balances;

    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public{
        name = "StoneCoin";
        symbol = "SNC";
        decimals = 10;
        balances[msg.sender] = 1000000000000000;
    }

    function balanceOf(address money) public view returns(uint){
        return balances[money];
    }
}