/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EvolveXToken {
    string public name = "EvolutionX";
    string public symbol = "EVX";
    uint256 public totalSupply = 100000000000 * 10**18;
    uint8 public decimals = 18;
    uint256 public rewardPerDay = 1000 * 10**18;
    uint256 public lastClaimedTime;
    address public owner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public whitelist;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event RewardClaimed(address indexed to, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        lastClaimedTime = block.timestamp;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value > 0 && _value <= balanceOf[msg.sender]);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0));
        require(_to != address(0));
        require(_value > 0 && _value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

   function claimReward() public returns (bool success) {
        uint256 reward = calculateReward();
        require(reward > 0);

        lastClaimedTime = block.timestamp;
        balanceOf[owner] += reward;

        emit RewardClaimed(owner, reward);
        return true;
    }

    function calculateReward() public view returns (uint256) {
        uint256 timeSinceLastClaimed = block.timestamp - lastClaimedTime;
        return timeSinceLastClaimed * rewardPerDay / 1 days;
    }
}