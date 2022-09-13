/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

//SPDX-License-Identifier: MIT
pragma solidity <= 0.8.17;

//By : 0xdaebak
//https://github.com/0xdaebak


contract MultiWalletTransfer{

//transfer balance to multiple wallets   
 function transferToWallets(address[] calldata to, uint256[] calldata amounts) public payable {
   
    uint256 balance = msg.value;
    for(uint i = 0 ; i< to.length ; i++){
      require(balance >= amounts[i],"insufficient balance");
      (bool sent, ) = to[i].call{value: amounts[i]}("");
      balance = balance - amounts[i];
      require(sent == true, "failed to transfer");
    }
    require(balance == 0,"balance remaining");
 }


}