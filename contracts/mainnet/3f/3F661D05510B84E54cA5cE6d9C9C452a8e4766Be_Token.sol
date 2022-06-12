/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Token {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    
    uint256 private _tTotal; 
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    constructor () {
        _tTotal = 100 * 10**3 * 10**18;     
        _tOwned[msg.sender] = _tTotal;
        // Create a pancakeswap pair for this new token
        IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        _name = "Bruuuuuh";
        _symbol = "BRUH";
        _decimals = 9;
        emit Transfer(address(0), msg.sender, _tTotal);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount);
        return true;
    }

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + amount;
        emit Transfer(from, to, amount);
    }
}