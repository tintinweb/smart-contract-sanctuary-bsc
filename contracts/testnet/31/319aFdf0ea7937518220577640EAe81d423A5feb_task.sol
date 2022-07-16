/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.12;

contract task{
    uint256 public count;
    address [] public users;
    mapping(address=>uint256) public balance;


receive()external payable{
   
    balance[msg.sender]+=msg.value;
    count++;
    users.push(msg.sender);

}


function duplicate()public view returns(bool){
    bool valid;
    for(uint256 i=0;i<=users.length;i++){
        if(users[i]==msg.sender){
            valid=true;
        }
        else{
            valid = false;
        }   
    }
     return valid;  
}



// function r()public view returns(bool){
//     return duplicate();
// }

}