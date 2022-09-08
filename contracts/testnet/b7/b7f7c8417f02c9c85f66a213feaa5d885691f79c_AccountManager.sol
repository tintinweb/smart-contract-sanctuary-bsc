/**
 *Submitted for verification at BscScan.com on 2022-09-07
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

contract Ownable {
    address private _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }
}

contract Account is Ownable {
    struct Withdrawal {
        uint256 amount;
        uint256 timestamp;
    }
    struct WithdrawalLimit {
        uint8 time;
        uint256 amount;
    }
    Withdrawal[] private _withdrawals;
    WithdrawalLimit private _withdrawalLimit;
    IERC20 private _token;
    address private _wallet;

    constructor(IERC20 token, address wallet, WithdrawalLimit memory withdrawalLimit) {
        _token = token;
        _wallet = wallet;
        _withdrawalLimit = withdrawalLimit;
    }

    function getWithdrawalLimit() external view returns(Account.WithdrawalLimit memory) {
        return _withdrawalLimit;
    }

    function setWithdrawalLimit(uint8 time, uint256 amount) external {
        _withdrawalLimit.time = time;
        _withdrawalLimit.amount = amount;
    }

    function topUp(uint256 amount) external onlyOwner {
        _token.transfer(_wallet, amount);
    }

    function withdraw(address recipient, uint256 amount) external onlyOwner {
        require(_withdrawalLimit.amount >= amount, "Withdrawal limit exceeds!");
        Withdrawal storage lastWithdrawal = _withdrawals[_withdrawals.length - 1];
        if (block.timestamp - lastWithdrawal.timestamp < _withdrawalLimit.time) {
            lastWithdrawal.amount += amount;
            require(_withdrawalLimit.amount >= lastWithdrawal.amount, "Withdrawal limit exceeds!");
        } else {
            _withdrawals.push(Withdrawal(amount, block.timestamp));
        }
        _token.transfer(recipient, amount);
    }
}

contract AccountManager is Ownable {
    address public constant ZERO = address(0);

    // account address => token => Account
    mapping(address => mapping(address => Account)) private _accounts;
    address public wallet;

    function setWallet(address wallet_) external onlyOwner {
        wallet = wallet_;
    }

    function getWithdrawalLimit(address account, address token) external view returns(Account.WithdrawalLimit memory) {
        return _accounts[account][token].getWithdrawalLimit();
    }

    function setWithdrawalLimit(address account, address token, uint8 limitTime, uint256 limitAmount) external onlyOwner {
        _accounts[account][token].setWithdrawalLimit(limitTime, limitAmount);
    }

    function createAccount(address account, address token, uint8 limitTime, uint256 limitAmount) external onlyOwner {
        _accounts[account][token] = new Account(IERC20(token), wallet, Account.WithdrawalLimit(limitTime, limitAmount));
    }

    function topUp(address token, uint256 amount) external {
        require(address(_accounts[msg.sender][token]) != ZERO, "Account is not registered!");
        require(wallet != ZERO, "Wallet is not set!");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).transfer(address(_accounts[msg.sender][token]), amount);
        _accounts[msg.sender][token].topUp(amount);

    }

    function withdraw(address account, address token, uint256 amount) external onlyOwner {
        require(wallet != ZERO, "Wallet is not set!");
        IERC20(token).transferFrom(wallet, address(this), amount);
        IERC20(token).transfer(address(_accounts[account][token]), amount);
        _accounts[account][token].withdraw(account, amount);
    }
}