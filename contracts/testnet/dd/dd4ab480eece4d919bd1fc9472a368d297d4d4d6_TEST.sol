/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TEST {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public stakedBalance;
    uint256 public stakingPool;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor() {
        name = "TEST";
        symbol = "TEST";
        decimals = 18;
        totalSupply = 48000000 * 10 ** decimals;
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_value <= balanceOf[msg.sender], "ERC20: transfer amount exceeds balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "ERC20: approve to the zero address");
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_value <= balanceOf[_from], "ERC20: transfer amount exceeds balance");
        require(_value <= allowance[_from][msg.sender], "ERC20: transfer amount exceeds allowance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "ERC20: Cannot stake 0 tokens");
        require(balanceOf[msg.sender] >= _amount, "ERC20: Not enough tokens to stake");

        balanceOf[msg.sender] -= _amount;
        stakedBalance[msg.sender] += _amount;
        stakingPool += _amount / 2; // Add 50% of staked tokens to staking pool
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) public {
        require(_amount > 0, "ERC20: Cannot unstake 0 tokens");
        require(stakedBalance[msg.sender] >= _amount, "ERC20: Not enough tokens to unstake");

        uint256 reward = _amount * (stakingPool / totalSupply); // Calculate reward based on staking pool
       
    }
}