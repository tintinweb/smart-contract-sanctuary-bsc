pragma solidity ^0.8.10;

import "./BEP20.sol";

/**
* @title Staking contract
* @notice Implements the staking functionality
 **/
contract Staking {
    mapping(BEP20 => uint) public stakingTokens;

    BEP20 public immutable rewardsToken;

    address public owner;

    uint public rewardRate;

    // Duration of rewards to be paid out (in seconds)
    uint public duration;
    // Timestamp of when the rewards finish
    uint public finishAt;
    // Minimum of last updated time and reward finish time
    uint public updatedAt;

    // Sum of (reward rate * dt * 1e18 / total supply)
    uint public rewardPerTokenStored;

    // User address => rewardPerTokenStored
    mapping(address => uint) public userRewardPerTokenPaid;

    // User address => rewards to be claimed
    mapping(address => uint) public rewards;

    // User address => staked amount
    mapping(BEP20 => mapping(address => uint)) public balanceOf;

    constructor(
        BEP20[] memory _tokens,
        BEP20 _rewardToken
    ) {
        owner = msg.sender;

        for (uint256 i = 0; i < _tokens.length; i++) {
            stakingTokens[_tokens[i]] = 0;
        }
        rewardsToken = _rewardToken;
    }

    function addStakingTokens(BEP20[] memory _tokens) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            stakingTokens[_tokens[i]] = 0;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateReward(address _account, BEP20 _token) {
        rewardPerTokenStored = rewardPerToken(_token);
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account, _token);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }

    function stake(uint _amount, BEP20 _token) external updateReward(msg.sender, _token) {
        require(_amount > 0, "amount = 0");
        require(stakingTokens[_token] > 0, "no such token");

        _token.transferFrom(msg.sender, address(this), _amount);

        balanceOf[_token][msg.sender] += _amount;

        // update total supply
        stakingTokens[_token] += _amount;
    }

    function withdraw(uint _amount, BEP20 _token) external updateReward(msg.sender, _token) {
        require(_amount > 0, "amount = 0");
        require(stakingTokens[_token] > 0, "no such token");

        balanceOf[_token][msg.sender] -= _amount;

        // update total supply
        stakingTokens[_token] -= _amount;

        _token.transfer(msg.sender, _amount);
    }

    function earned(address _account, BEP20 _token) public view returns (uint) {
        return
            ((balanceOf[_token][_account] *
                (rewardPerToken(_token) - userRewardPerTokenPaid[_account])) / 1e18) +
                rewards[_account];
    }

    function rewardPerToken(BEP20 _token) public view returns (uint) {
        if (stakingTokens[_token] == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            stakingTokens[_token];
    }

    function getReward(BEP20 _token) external updateReward(msg.sender, _token) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}