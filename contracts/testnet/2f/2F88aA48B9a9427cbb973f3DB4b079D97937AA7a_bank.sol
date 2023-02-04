/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

pragma solidity ^0.6.1;

contract bank{

    int balance;

    constructor()public{
        balance = 1200;
    }

    function getbalance() public view returns(int){
        return balance;
    }

    function addmoney( int add)public{
        balance = balance + add;
    }
    
    function withdraw(int with) public{
        balance = balance - with;
    }
    

}