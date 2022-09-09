// SPDX-License-Identifier: UNLICENSED

// Uncomment this line to use console.log
// import "hardhat/console.sol";

pragma solidity ^0.8.9;

contract ERC20 {
    string public constant name = "ERC20";
    string public constant symbol = "ERC20";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        uint256 amount = 100e6 * 1e18;
        _balances[msg.sender] = amount;
        totalSupply = amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        uint256 fromAmount = _balances[msg.sender];
        require(fromAmount >= amount, "ERC20: balance exceeded");

        _balances[msg.sender] = fromAmount - amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_allowances[from][msg.sender] > amount, "ERC20: insufficient allowance");
        _allowances[from][msg.sender] = _allowances[from][msg.sender] - amount;

        uint256 fromAmount = _balances[from];
        require(fromAmount >= amount, "ERC20: balance exceeded");

        _balances[from] = fromAmount - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}