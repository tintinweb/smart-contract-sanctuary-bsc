/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    //当前合约的token总量 
    function totalSupply() external view returns (uint);
    //某一个账户的当前余额
    function balanceOf(address account) external view returns (uint);
    //把账户中的余额由当前交易者转到另一账户，写入方法向链外汇报一个事件
    function transfer(address recipient,uint amount) external returns (bool);
    //可以查到某一个账户对另一个账户批准的额度是多少
    function allowance(address owner,address spender) external view returns (uint);
    //批准，把一个账户中的数量，批准给另一个账户
    function approve(address spender, uint amount) external returns (bool);
    //
    function transferFrom(address spender, address recipient,uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender,uint amount);
}

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "TEst";//名字
    string public symbol ="TEST";//缩写
    uint8 public decimals = 18;//精度：1->1000000000000000000

    function transfer(address recipient,uint amount) external returns (bool){
        balanceOf[msg.sender]-= amount;
        balanceOf[recipient]+= amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient,uint amount) external returns (bool){
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function mint (uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }
    function burn(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply -= amount;
        emit Transfer( msg.sender, address(0), amount);
    }
}