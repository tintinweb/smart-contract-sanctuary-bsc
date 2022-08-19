// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Auth.sol";

contract Hero is IERC20, IERC20Metadata, Auth {

    string _name = "Nirwana Token";
    string _symbol = "NT";
    uint8 _decimals = 18;
    uint256 _totalSupply = 1_000_000_000 * (10 ** _decimals);
    mapping(address => uint256) _balances;
    mapping(address => bool) _feeExemption;
    mapping(address => mapping(address => uint256)) _allowances;

    uint16 _tax = 1500;
    uint16 _denominator = 10000;

    bool _isTaxEnable = true;

    address _taxAddress = 0x7BC537e26478789d3709cD68972C6A6DC6611Cde;

    constructor() Auth(msg.sender) {
        _balances[msg.sender] = _totalSupply;
        _feeExemption[msg.sender] = true;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
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

    function shouldAddressTakeFee(address from, address to) internal view returns (bool) {
        return _feeExemption[from] && _feeExemption[to];
    }

    function _transfer (address from, address to, uint256 amount) internal {
        require (_balances[from] >= amount, "Balance not enough");
        require (to != address(0), "Cannot send to zero address");
        require (from != address(0), "Cannot send from zero address");

        uint256 taxamount = 0;
        unchecked {
            if (_isTaxEnable && shouldAddressTakeFee(from, to)) {
                taxamount = amount * _tax / _denominator;
            }
            _balances[from] -= amount;
            _balances[to] += amount - taxamount;
            _balances[_taxAddress] += taxamount;
        }
        emit Transfer(from, to, amount);
        emit Transfer(from, _taxAddress, taxamount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require (_balances[msg.sender] >= amount, "Balance not enough");
        require (to != address(0), "Cannot send to zero address");
        require (msg.sender != address(0), "Cannot send to zero address");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require (_balances[from] >= amount, "Balance not enough");
        require (to != address(0), "Cannot send to zero address");
        require (from != address(0), "Cannot send from zero address");
        require (_allowances[from][msg.sender] >= amount, "Allowance not enough");
        unchecked {
            _allowances[from][msg.sender] -= amount;
        }
        _transfer(from, to, amount);
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

    function setTax(uint16 amount) external onlyOwner returns (uint16) {
        require(amount <= 2500, "Tax limit is 2500");
        require(amount > 0, "Tax cant set to 0, use toggleTax instead");
        _tax = amount;
        return _tax;
    }

    function tax() external view returns (uint16) {
        return _tax;
    }

    function denominator() external view returns (uint16) {
        return _denominator;
    }

    function toggleTax(bool state) external onlyOwner returns (bool success) {
        _isTaxEnable = state;
        return true;
    }

    function isTaxEnable() view external returns (bool) {
        return _isTaxEnable;
    }

}