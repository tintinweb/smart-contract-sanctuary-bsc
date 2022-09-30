/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Coin {


    //1.定义状态变量,存储数据
    address public miner;
    mapping (address => uint) public balances;

    //定义事件，当操作执行成功的时候发出事件
    event Sent(address from, address to, uint amount);

    //定义错误，当操作执行失败的时候发出错误
    error InsufficientBalance(uint requested,uint avaliable);

    //构造函数，初始化合约创建者
    constructor () {
        miner = msg.sender;
    }


    //挖矿函数
    function mint(address receiver,uint amount) public {
        require(msg.sender == miner);
        balances[receiver] += amount;
    }

    
    //转账函数
    function send(address receiver,uint amount) public {

        if (amount > balances[msg.sender])

            //错误使用revert发出，参数用中括号包裹
            revert InsufficientBalance({
                requested:amount,
                avaliable:balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(msg.sender,receiver,amount);
    } 

    

}