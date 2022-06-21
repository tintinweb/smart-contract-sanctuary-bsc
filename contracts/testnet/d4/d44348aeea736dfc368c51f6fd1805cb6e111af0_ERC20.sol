/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// File: contracts\utils\Ownable.sol

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

abstract contract Ownable {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function newOwner() public view virtual returns (address) {
        return _newOwner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner());
        _newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner(), "Ownable: caller is not the new owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

// File: contracts\token\ERC20.sol

contract ERC20 is Ownable {

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint private _totalSupply;

    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = totalSupply_;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint) {
        return _decimals;
    }

    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }


    function transfer(address recipient, uint amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        uint allowed = _allowances[sender][msg.sender];
        require(allowed >= amount, "ERC20: transfer amount exceeds allowance");

        if (allowed < type(uint).max) {
            unchecked {
                _approve(sender, msg.sender, allowed - amount);
            }
        }

        _transfer(sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) external view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function mint(uint amount) external onlyOwner { 
        _mint(msg.sender, amount);
    }

    function mintTo(address account, uint amount) external onlyOwner { 
        require(account != address(0), "ERC20: mint to the zero address");
        _mint(account, amount);
    }

    function burn(uint amount) external onlyOwner {
        uint accountBalance = _balances[msg.sender];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }


    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint amount) internal { 
        require(amount > 0, "ERC20: Zero mint amount");

        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }
}