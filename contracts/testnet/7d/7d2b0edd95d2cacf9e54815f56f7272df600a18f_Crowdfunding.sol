/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

contract Crowdfunding {
    // 创作者
    address public author;

    // 参与金额
    mapping(address => uint) public joined;

    // 众筹目标
    uint constant Target = 10 ether;

    // 众筹截止时间
    uint public endTime;

    // 记录当前众筹价格
    uint public price  = 0.02 ether;

    // 作者提取资金之后，关闭众筹
    bool public closed = false;

    // 部署合约时调用，初始化作者以及众筹结束时间
    constructor() public {
        author = msg.sender;
        endTime = now + 5 days;
    }

    // 更新价格，这是一个内部函数
    function updatePrice() internal {
        uint rise = address(this).balance / 1 ether * 0.002 ether;
        price = 0.02 ether + rise;
    }

    // 用户向合约转账时 触发的回调函数
    receive() external payable {
        require(now < endTime && !closed , "Crowdfunding is over");
        require(joined[msg.sender] == 0 , "You have participated in crowdfunding");
        require (msg.value >= price, "The offer is too low");

        joined[msg.sender] = msg.value;
        updatePrice();
    }

    // 作者提取资金
    function withdrawFund() external {
        require(msg.sender == author, "You are not the author");
        require(address(this).balance >= Target, "Failed to achieve the goal of crowdfunding");
        closed = true;   
        msg.sender.transfer(address(this).balance);
    }

    // 读者赎回资金
    function withdraw() external {
        require(now > endTime, "It's not the end time of crowdfunding");
        require(!closed, "Crowdfunding meets the standard, and crowdfunding funds have been withdrawn");
        require(Target > address(this).balance, "Crowdfunding meets the standard, and you can't withdraw funds");
        
        msg.sender.transfer(joined[msg.sender]);
    }

}