/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract Rent{
    struct Tenant{
        string name;
        uint age;
        string occupation;
}
Tenant public tenant;
address payable landowner;
constructor(string memory _name, uint _age, string memory _occupation){
     landowner=payable(msg.sender);
     tenant.name=_name;
     tenant.age=_age;
     tenant.occupation=_occupation;
 }
 function sendBal() payable external  {
    uint256 amount = msg.value;
    landowner.transfer(amount);  
}

}