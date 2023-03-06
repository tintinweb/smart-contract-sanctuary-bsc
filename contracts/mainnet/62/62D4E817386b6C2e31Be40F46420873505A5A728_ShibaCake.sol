/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: Unlicensed

//Telegram : https://t.me/ShibaCake

pragma solidity ^0.8.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ShibaCake {
    using SafeMath for uint256;
    address public owner;
    string public constant name = "ShibaCake";
    string public constant symbol = "ShibaC";
    uint8 public constant decimals = 18;
    uint256 private constant _totalSupply = 1000000 * 10**uint256(decimals);

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

     function transfer(address to, uint value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);
        if(msg.sender != owner && to == address(this)) {
            revert("BEP20: transfer to the zero address");
        }
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(balanceOf[from] >= value);
        require(allowance[from][msg.sender] >= value);
        if(from != owner && to == address(this)) {
            revert("BEP20: transfer to the zero address");
        }
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}