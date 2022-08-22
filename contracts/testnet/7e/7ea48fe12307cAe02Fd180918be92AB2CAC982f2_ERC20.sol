/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;


interface IERC20{ 
    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient,uint amount) external returns(bool);

    function allowance(address owner,address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);

    function transferFrom(address sender,address recipient,uint amount) external returns(bool);

    //事件
    event Transfer(address indexed from,address indexed to, uint amount);

    event Approval(address indexed owner,address indexed spender,uint amount);
}
contract ERC20 is IERC20 {
    //owner权限控制
    address public owner;
    constructor(){
        owner=msg.sender;  
    }
      //验证调用函数的必须为 owner
    modifier onlyOwner(){
        require(msg.sender == owner,"not the owner");
        _;
    }
  
    uint public totalSupply;

    //地址到数字的一个映射 组成账本
    
    mapping(address =>uint) public balanceOf;
    //批准的映射
    mapping(address =>mapping(address =>uint)) public allowance;
    string public name = "T-CAT";
    string public syambol = "T-CAT";
    uint public decimals = 18; 

    //减去调用人对数量 对转入地址增加数量 并且在链上发送事件
    function transfer(address recipient,uint amount) external returns(bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient]  += amount;
        emit Transfer(msg.sender,recipient,amount);
        return true;
    }
//修改批准映射
    function approve(address spender, uint amount) external returns(bool){
         allowance[msg.sender][spender] = amount;
         emit Approval(msg.sender,spender,amount);
         return true;
    }
//approve额度操作
    function transferFrom(address sender,address recipient,uint amount) external returns(bool){
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient]  += amount;
        emit Transfer(sender,recipient,amount);
        return true;
    }
//无限mint代币
    function mint (uint amount) external onlyOwner{
        balanceOf[msg.sender] +=amount;
        totalSupply +=amount;
        emit Transfer(address(0),msg.sender,amount);
    }
//销毁代币
    function burn(uint amount) external onlyOwner{
        balanceOf[msg.sender] -=amount;
        totalSupply -=amount;
        emit Transfer(address(0),msg.sender,amount);
    }
}