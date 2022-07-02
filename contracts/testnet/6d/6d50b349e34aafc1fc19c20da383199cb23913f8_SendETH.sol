/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


contract SendETH {
    // 构造函数，payable使得部署的时候可以转eth进去
    constructor() payable{}
    // receive方法，接收eth时被触发
    receive() external payable{}



    // 用transfer()发送ETH
    function transferETH(address payable _to, uint256 amount) external payable{
        _to.transfer(amount);
    }


    // call()发送ETH
    function callETH(address payable _to, uint256 amount) external payable{
    // 处理下call的返回值，如果失败，revert交易并发送error
    (bool success,) = _to.call{value: amount}("");
    if(!success){
    	// revert CallFailed();
    }
    }


    //get balance
    function getMsgSenderBalance() external payable returns(uint)  {
      return   msg.value;
    }


        // 返回合约ETH余额
    function getBalance() view public returns(uint) {
        return address(this).balance / 1 ether;
    }

   
     
}