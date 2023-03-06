/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract SpinToEarn {
    address public owner;
    address public poolToken;
    address public rewardToken;
    uint public poolBalance;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Deposit(address indexed sender, uint amount);
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(address _poolToken, address _rewardToken) {
        owner = msg.sender;
        poolToken = _poolToken;
        rewardToken = _rewardToken;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        emit Transfer(_from, _to, _value);
        return true;
    }

    function deposit(uint _amount) external onlyOwner {
        require(_amount > 0, "Deposit amount must be greater than 0");

        // Set the allowance for the spender
        IERC20 token = IERC20(poolToken);
        token.allowance(msg.sender, address(this));
        token.approve(msg.sender, _amount);

        token.transferFrom(msg.sender, address(this), _amount);
        poolBalance += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function spinWheel() external {
        require(poolBalance > 0, "No pool balance");

        uint rewardAmount = _getRandomReward();
        IERC20(rewardToken).transfer(msg.sender, rewardAmount);

        poolBalance -= rewardAmount;

        // Automatically approve the transfer of the reward token
        IERC20(rewardToken).approve(msg.sender, rewardAmount);
    }

    function _getRandomReward() private view returns (uint) {
        // For demo purposes, this just returns a random number between 1-10
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 10 + 1;
    }
}