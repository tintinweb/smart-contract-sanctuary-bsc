/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
//Created by: manuDev - estudioscrypto
//github: https://github.com/estudioscrypto
//contact: [email protected]
//standard erc20 token

pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external;
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external;
    function transferFrom( address sender,address recipient,uint amount ) external;
    event Mint(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, address indexed to, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract EST is IERC20 {

    string public name = "Estudio Token";
    string public symbol = "EST";
    uint8 public decimals = 18;
    uint public totalSupply = 1000*10**18;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    address public Owner;

    constructor() {
        Owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "ERROR: YOU NOT OWNER");
        _;
    }

    function transfer(address recipient, uint amount) public {
        require(recipient != address(0),"ERROR: zero direction not allowed");
        require(balanceOf[msg.sender] >= amount,"ERROR: insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }

    function approve(address spender, uint amount) external {
        require(spender != address(0),"ERROR: zero direction not allowed");
        require(balanceOf[msg.sender] >= amount,"ERROR: insufficient balance");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom( address sender, address recipient, uint amount ) external {
        require(sender != address(0),"ERROR: zero direction not allowed");
        require(recipient != address(0),"ERROR: zero direction not allowed");
        require(allowance[msg.sender][sender] >= amount,"ERROR: You do not have permissions to send these tokens");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function burn(uint amount) public {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burn(msg.sender, address(0), amount);
    }

    function mint(uint amount) public onlyOwner{
        totalSupply = totalSupply+amount;
        balanceOf[Owner] += amount;
        emit Mint(address(0), Owner, amount);
    }
}