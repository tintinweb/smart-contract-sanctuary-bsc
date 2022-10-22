/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract MyToken{

    mapping(address=>uint) public balances;
    constructor(uint totalSupply){
        balances[msg.sender]=totalSupply;
    }
    event transferEvent(address from,address to,uint amount);
    function transfer(address to,uint amout) public returns(bool){
        address from =msg.sender;
        require(balances[from]>=amout,"not enough balance");
        balances[from]-=amout;
        balances[to]+=amout;
        emit transferEvent(from,to,amout);
        return true;
    }
}