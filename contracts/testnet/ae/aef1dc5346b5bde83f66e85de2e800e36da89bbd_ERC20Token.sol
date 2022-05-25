/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract ERC20Token {
    event Approval(address indexed from, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    string constant private _name = "ERC20 Token";
    string constant private _symbol = "T-O-K-E-N";
    uint8 private _decimals = 8;
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor (uint256 supply) {
        _totalSupply = supply * 10 ** _decimals;
        _balances[msg.sender] += _totalSupply;
    }

    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function decimals() external view returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function allowance(address account, address spender) external view returns (uint256) { return _allowances[account][spender]; }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns(bool){
        address spender = msg.sender;
        require(_allowances[from][spender] >= amount, "Amount Greater Than Allowance");
        _allowances[from][spender] = _allowances[from][spender] - amount;
        return _transfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns(bool) {
        uint256 _balance = _balances[from];
        require(_balance >= amount, "Amount Exceeds Balance");
        _balances[from] = _balance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
    
}