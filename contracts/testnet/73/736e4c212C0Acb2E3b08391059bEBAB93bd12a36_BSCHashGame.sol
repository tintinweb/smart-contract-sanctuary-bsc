// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";

contract BSCHashGame {
    using SafeMath for uint256;
    using Address for address;

    address public owner;
    address private _operator;

    uint256 private _totalbnb;
    mapping(address => uint256) private _totaltoken;
    mapping(address => bool) private _staker;
    mapping(address => uint256) private _stakeBalance;
    uint256 private _totalStake;

    event Charge(uint256 amount);
    event Deposit(uint256 amount);
    event Withdraw(uint256 amount, uint256 fee);
    event Stake(address staker, uint256 amount);
    event UnStake(address staker, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function setOperator(address operator) public {
        require(owner == msg.sender, "You're not Owner");
        require(operator != address(0), "Can't set zero address for operator");
        require(_operator == address(0), "Already set operator");

        _operator = operator;
    }

    function hideOperator() public view returns(address) {
        require(owner == msg.sender, "You're not Owner");
        
        return _operator;
    }

    function setStaker(address staker) public {
        require(_operator == msg.sender, "You're not Operator");
        
        _staker[staker] = true;
        _stakeBalance[staker] = 0;
    }

    function stake() payable public {
        require(_staker[msg.sender] == true, "You're not Staker");
        
        _stakeBalance[msg.sender] = _stakeBalance[msg.sender].add(msg.value);
        _totalStake = _totalStake.add(msg.value);
        _totalbnb = _totalbnb.add(msg.value);

        emit Stake(msg.sender, msg.value);
    }

    function unStake(address staker, uint256 amount) public {
        require(_operator == msg.sender, "You're not Operator");
        require(_totalbnb >= amount, "Out of balance");
        require(_totalStake >= amount, "Out of balance");
        require(_staker[staker] == true, "Address is not Staker");
        require(_stakeBalance[staker] >= amount, "Exceed Stake balance");
        
        _stakeBalance[staker] = _stakeBalance[staker].sub(amount);
        _totalStake = _totalStake.sub(amount);
        _totalbnb = _totalbnb.sub(amount);

        payable(staker).transfer(amount);

        emit UnStake(staker, amount);
    }

    function chargeBNB() payable public {
        require(msg.value > 0, "Unable to charge zero.");
        _totalbnb = _totalbnb.add(msg.value);

        emit Charge(msg.value);
    }

    function chargeToken(address token, uint256 amount) public {
        require(amount > 0, "Unable to charge zero.");

        IBEP20 Token = IBEP20(token);
        _totaltoken[token] = _totaltoken[token].add(amount);
        
        Token.transferFrom(msg.sender, address(this), amount);

        emit Charge(amount);
    }

    function bnbBalance() public view returns(uint256) {
        return _totalbnb;
    }

    function tokenBalance(address token) public view returns(uint256) {
        return _totaltoken[token];
    }

    function isStaker(address staker) public view returns(bool) {
        return _staker[staker];
    }

    function totalStakeBalance() public view returns(uint256) {
        return _totalStake;
    }

    function stakeBalance(address staker) public view returns(uint256) {
        return _stakeBalance[staker];
    }

    function depositBNB() payable public {
        require(msg.sender == _operator, "You aren't the operator");
        _totalbnb = _totalbnb.add(msg.value);

        emit Deposit(msg.value);
    }

    function depositToken(address token, uint256 amount) public {
        require(msg.sender == _operator, "You aren't the operator");

        IBEP20 Token = IBEP20(token);
        _totaltoken[token] = _totaltoken[token].add(amount);
        Token.transferFrom(msg.sender, address(this), amount);

        emit Deposit(amount);
    }

    function withdrawBNB(address recipient, uint256 amount, uint256 fee) public {
        require(msg.sender == _operator, "You aren't the operator");
        require(_totalbnb >= amount, "Out of balance");

        uint256 outcome = amount;

        if (fee > 0) {
            outcome = amount.sub(fee);
        }

        _totalbnb = _totalbnb.sub(outcome);
        payable(recipient).transfer(outcome);

        emit Withdraw(outcome, fee);
    }

    function withdrawToken(address token, address recipient, uint256 amount, uint256 fee) public {
        require(msg.sender == _operator, "You aren't the operator");
        require(_totaltoken[token] >= amount, "Out of balance");

        IBEP20 Token = IBEP20(token);

        uint256 outcome = amount;

        if (fee > 0) {
            outcome = amount.sub(fee);
        }
        
        _totaltoken[token] = _totaltoken[token].sub(outcome);

        Token.approve(recipient, outcome);
        Token.transfer(recipient, outcome);

        emit Withdraw(outcome, fee);
    }
}