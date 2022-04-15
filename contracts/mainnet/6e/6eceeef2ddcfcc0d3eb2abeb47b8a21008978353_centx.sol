/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



//0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 BUSD MAINNET
//0xeb917D96206fd3DD4f9F48d0854d90c015027a73 ANCW TESTNET


contract centx {
    address owner;
    uint256 totalhave;
    constructor() {
        owner = msg.sender;
    }

    modifier justowner {
        require(owner == msg.sender,"You are not !");
        _;
    }

    function ChangeOwner(address newowner) public justowner {
        owner = newowner;
    }
    

    
    function deposit() public payable{
        totalhave+=msg.value;
    }

    function withdraw(address payable sendadress,uint256 amount) public justowner{
        sendadress.transfer(amount);
        totalhave-=amount;
    }


    function gameplay(address payable sendadress,uint256 randomsonuc) public payable returns(bool Final){
        uint256 amount = msg.value;
        if(amount*2 <= totalhave && randomsonuc == 1) {
            sendadress.transfer(amount*2);
            totalhave -= amount;
            return true;
        }else{
            totalhave += amount;
            return false;
        }

    }
    

    function totalhaves() public view returns(uint256 TOTAL) {
        return(totalhave);
    }

    function playerbalance() public view returns(uint256 TOTAL){
        return msg.sender.balance;
    }

    function getowner() public view returns(address OWNER) {
        return(owner);
    }



}