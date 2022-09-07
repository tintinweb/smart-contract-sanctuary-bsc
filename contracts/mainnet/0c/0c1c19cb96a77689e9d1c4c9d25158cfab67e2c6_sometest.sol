/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract sometest {
    address public lastSender;
    uint public ret;
    mapping(address => mapping(address => uint) )  userBalance; // asset => balance 

    function add(uint256 a,uint256 b) public {
        lastSender = msg.sender;
        ret=a+b;
    }

    //存款
    function deposit(address token,uint256 amount) public {
        uint balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender,address(this),amount);
        uint balanceAfter = IERC20(token).balanceOf(address(this));
        uint changed = balanceAfter - balanceBefore;
        userBalance[msg.sender][token]+=changed;
    }
    
    //取款
    function withdraw(address token,uint256 amount) public {
        uint balance = userBalance[msg.sender][token];
        require(balance > amount,"balance not enough");
        userBalance[msg.sender][token]-=amount;
        IERC20(token).transfer(msg.sender,amount);
    }

}