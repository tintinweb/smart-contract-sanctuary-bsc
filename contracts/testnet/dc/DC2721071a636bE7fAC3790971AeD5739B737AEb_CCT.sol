/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom( address sender,address recipient,uint amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract CCT is IERC20 {

    string public name = "Crypto Cans Token";
    string public symbol = "CCT";
    uint8 public decimals = 18;
    address public Owner;
    uint public totalSupply = 10000000*10**decimals;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor() {
        Owner = 0x20a4DaBC7C80C1139Ffc84C291aF4d80397413Da;
        balanceOf[0x20a4DaBC7C80C1139Ffc84C291aF4d80397413Da] = totalSupply;
        emit Transfer(address(0), 0x20a4DaBC7C80C1139Ffc84C291aF4d80397413Da, totalSupply);
    }

    function getOwner() public view returns(address){ return Owner; }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint amount) external {
        require(msg.sender == Owner);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}

//0x20a4DaBC7C80C1139Ffc84C291aF4d80397413Da
//0x7daF5a75C7B3f6d8c5c2b53117850a5d09006168

//address del contrato
//0x6B396D7841426EDd2a1aD72d60E94C6F7beA573d