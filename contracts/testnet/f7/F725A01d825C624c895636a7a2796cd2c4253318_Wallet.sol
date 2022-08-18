/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract Wallet {
    address public constant ZERO = address(0);
    address public constant DEAD = address(0xdead);

    struct MerchantProps {
        uint256 limitTime;
        uint256 limitAmount;
        uint256 withdrawalAmount;
        uint256 withdrawalAt;
    }

    struct Account {
        uint256 balance;
        uint256 limitTime;
        uint256 limitAmount;
        uint256 withdrawalAmount;
        uint256 withdrawalAt;
    }

    address private _owner;
    address private _operator;
    IERC20 private _currentToken;
    uint256 private _defaultAccountWithdrawLimitTime;
    uint256 private _defaultAccountWithdrawLimitAmount;
    mapping(address => MerchantProps) private _merchants;
    mapping(address => Account) private _accounts;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "Caller =/= operator.");
        _;
    }

    constructor(address token) {
        _currentToken = IERC20(token);
    }

    function getCurrentToken() external view returns (address) {
        return address(_currentToken);
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != DEAD && newOwner != ZERO, "Cannot renounce.");
        _owner = newOwner;
    }

    function transferOperator(address newOperator) external onlyOwner {
        require(newOperator != DEAD && newOperator != ZERO, "Cannot renounce.");
        _operator = newOperator;
    }

    function setDefaultAccountWithdrawLimitTime(uint256 time) external onlyOwner {
        _defaultAccountWithdrawLimitTime = time;
    }

    function setDefaultAccountWithdrawLimitAmount(uint256 amount) external onlyOwner {
        _defaultAccountWithdrawLimitAmount = amount;
    }

    function topUpAccount(uint256 amount) external {
        _accounts[msg.sender].balance += amount;
        if (_accounts[msg.sender].limitTime == 0) {
            _accounts[msg.sender].limitTime = _defaultAccountWithdrawLimitTime;
        }
        if (_accounts[msg.sender].limitAmount == 0) {
            _accounts[msg.sender].limitAmount = _defaultAccountWithdrawLimitAmount;
        }
        try _currentToken.transferFrom(msg.sender, address(this), amount) {} catch {
            revert("Token transfer errored. Not enough allowance perhaps?");
        }
    }

    function withdrawAccount(address account, uint256 amount, uint256 balance) external onlyOperator {
        require(_accounts[account].balance >= amount, "Insufficient funds");
        if (block.timestamp - _accounts[account].withdrawalAt < 24 * 1 hours) {
            _accounts[account].withdrawalAmount += amount;
        } else {
            _accounts[account].withdrawalAmount = amount;
        }
        require(_accounts[account].withdrawalAmount >= _accounts[account].limitAmount, "Withdrawal limit exceeded");
        _accounts[account].balance = balance;
        _accounts[account].withdrawalAt = block.timestamp;
        _currentToken.transfer(account, amount);
    }

    function registerMerchant(address merchant, uint256 limitTime, uint256 limitAmount) external onlyOwner {
        _merchants[merchant].limitTime = limitTime;
        _merchants[merchant].limitAmount = limitAmount;
    }

    function withdrawMerchant(address merchant, uint256 amount) external onlyOperator {
        if (block.timestamp - _merchants[merchant].withdrawalAt < 24 * 1 hours) {
            _merchants[merchant].withdrawalAmount += amount;
        } else {
            _merchants[merchant].withdrawalAmount = amount;
        }
        require(_merchants[merchant].withdrawalAmount >= _merchants[merchant].limitAmount, "Withdrawal limit exceeded");
        _merchants[merchant].withdrawalAt = block.timestamp;
        _currentToken.transfer(merchant, amount);
    }


}