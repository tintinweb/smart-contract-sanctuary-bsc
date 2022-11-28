/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract{

//สร้างตัวแปร

//type modifier name;

    // bool status = false;
    // string public name = "Test String";
    // int amount = 500;

    string name;
    int wallet;

    constructor(string memory getname,int getwallet){
         require(getwallet > 0,"More Zero");
         name = getname;
         wallet = getwallet;
    }

    function getBalance() public view returns(int checkMoney){
        return wallet;
    }

    function setBalance() public pure returns(int cutMoney){
        return 50;
    }

    function inputMoney(int newinputmoney) public{
        wallet = wallet+newinputmoney;
    }

    


}