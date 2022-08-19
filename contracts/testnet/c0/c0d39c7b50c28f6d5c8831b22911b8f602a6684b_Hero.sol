// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

contract Hero is IERC20, IERC20Metadata {

    string _name = "Nirwana Token";
    string _symbol = "NT";
    uint8 _decimals = 18;
    uint256 _totalSupply = 1_000_000_000 * (10 ** _decimals);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    uint16 _tax = 1500;
    uint16 _denominator = 10000;
    bool _isTaxEnable = true;

    address _taxAddress = 0x7BC537e26478789d3709cD68972C6A6DC6611Cde;

    constructor() {
        _balances[msg.sender] = _totalSupply;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require (_balances[msg.sender] >= amount, "Balance not enough");
        require (to != address(0), "Cannot send to zero address");
        uint256 taxamount = amount*_tax/_denominator;
        unchecked {
            _balances[msg.sender] -= amount;
            _balances[to] += amount - taxamount;
            _balances[_taxAddress] += taxamount;
        }
        emit Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, _taxAddress, taxamount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require (spender != address(0), "Cant approve to zero address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require (_balances[from] >= amount, "Balance not enough");
        require (_allowances[from][msg.sender] >= amount, "Allowance not enough");
        uint256 taxamount = amount*_tax/_denominator;
        unchecked {
            _balances[from] -= amount;
            _allowances[from][msg.sender] -= amount;
            _balances[to] += amount - taxamount;
            _balances[_taxAddress] += taxamount;
        }
        emit Transfer(from, to, amount);
        emit Transfer(from, _taxAddress, taxamount);
        return true;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function setTax(uint16 amount) external returns (bool) {
        require(amount <= 2500, "Tax limit is 2500");
        require(amount > 0, "Tax cant set to 0, use toggleTax instead");
        _tax = amount;
        return true;
    }

    function toggleTax(bool state) external returns (bool success) {
        _isTaxEnable = state;
        return true;
    }

    function isTaxEnable() view external returns (bool) {
        return _isTaxEnable;
    }

}