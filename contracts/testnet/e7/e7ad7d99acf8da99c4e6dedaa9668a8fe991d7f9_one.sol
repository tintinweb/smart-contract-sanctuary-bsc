/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract one {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        name = "My Token";
        symbol = "MTK";
        decimals = 18;
        totalSupply = 1000000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function setName(string memory _newName) public {
        require(msg.sender == owner, "Only the owner can change the name");
        name = _newName;
    }
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[msg.sender] >= value, "ERC20: insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[from] >= value, "ERC20: insufficient balance");
        require(allowance[from][msg.sender] >= value, "ERC20: insufficient allowance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function renounceOwnership() public {
        require(msg.sender == owner, "MyToken: only owner can renounce ownership");
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}