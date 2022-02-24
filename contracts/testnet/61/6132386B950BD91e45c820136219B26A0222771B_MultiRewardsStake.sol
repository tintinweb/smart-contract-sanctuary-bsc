//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./Math.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

//solhint-disable not-rely-on-time
contract MultiRewardsStake is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Base staking info
    IERC20 public stakingToken;
    uint256 public periodFinish;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    address public rewardsDistributor;
    
    // User reward info
    mapping(address => mapping (address => uint256)) private _userRewardPerTokenPaid;
    mapping(address => mapping (address => uint256)) private _rewards;

    // Reward token data
    uint256 private _totalRewardTokens;
    mapping (uint => RewardToken) private _rewardTokens;
    mapping (address => uint) private _rewardTokenToIndex;

    // User deposit data
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    // Store reward token data
    struct RewardToken {
        address token;
        uint256 rewardRate;
        uint256 rewardPerTokenStored;
    }

    constructor(
        address rewardsDistributor_,
        address[] memory rewardTokens_,
        address stakingToken_
    ) {
        rewardsDistributor = rewardsDistributor_;
        stakingToken = IERC20(stakingToken_);
        _totalRewardTokens = rewardTokens_.length;

        for (uint i; i < rewardTokens_.length; i++) {
            _rewardTokens[i + 1] = RewardToken({
                token: rewardTokens_[i],
                rewardRate: 0,
                rewardPerTokenStored: 0
            });
            _rewardTokenToIndex[rewardTokens_[i]] = i + 1;
        }

        rewardsDuration = 5 minutes;
    }

    /* VIEWS */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function totalRewardTokens() external view returns (uint256) {
        return _totalRewardTokens;
    }

    // Get reward rate for all tokens
    function rewardPerToken() public view returns (uint256[] memory) {
        uint256[] memory tokens = new uint256[](_totalRewardTokens);
        if (_totalSupply == 0) {
            for (uint i = 0; i < _totalRewardTokens; i++) {
                tokens[i] = _rewardTokens[i + 1].rewardPerTokenStored;
            }
        } else {
            for (uint i = 0; i < _totalRewardTokens; i++) {
                RewardToken storage rewardToken = _rewardTokens[i + 1];
                tokens[i] = rewardToken.rewardPerTokenStored.add(
                    lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardToken.rewardRate)
                    .mul(10 ** IERC20(rewardToken.token).decimals())
                    .div(_totalSupply)
                );
            }
        }

        return tokens;
    }

    // Get reward rate for individual token
    function rewardForToken(address token) public view returns (uint256) {
        uint256 index = _rewardTokenToIndex[token];
        if (_totalSupply == 0) {
            return _rewardTokens[index].rewardPerTokenStored;
        } else {
            return _rewardTokens[index].rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(_rewardTokens[index].rewardRate)
                .mul(10 ** IERC20(_rewardTokens[index].token).decimals())
                .div(_totalSupply)
            );
        }
    }

    function getRewardTokens() public view returns (RewardToken[] memory) {
        RewardToken[] memory tokens = new RewardToken[](_totalRewardTokens);
        for (uint i = 0; i < _totalRewardTokens; i++) {
            tokens[i] = _rewardTokens[i + 1];
        }

        return tokens;
    }

    function earned(address account) public view returns (uint256[] memory) {
        uint256[] memory earnings = new uint256[](_totalRewardTokens);
        uint256[] memory tokenRewards = rewardPerToken();
        for (uint i = 0; i < _totalRewardTokens; i++) {
            address token = _rewardTokens[i + 1].token;
            earnings[i] = _balances[account]
                .mul(tokenRewards[i]
                    .sub(_userRewardPerTokenPaid[account][token])
                )
                .div(10 ** IERC20(token).decimals())
                .add(_rewards[account][token]
            );
        }

        return earnings;
    }

    function getRewardForDuration() external view returns (uint256[] memory) {
        uint256[] memory currentRewards = new uint256[](_totalRewardTokens);
        for (uint i = 0; i < _totalRewardTokens; i++) {
            currentRewards[i] = _rewardTokens[i + 1].rewardRate.mul(rewardsDuration);
        }

        return currentRewards;
    }

    /* === MUTATIONS === */

    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        for (uint i = 0; i < _totalRewardTokens; i++) {
            uint256 currentReward = _rewards[msg.sender][_rewardTokens[i + 1].token];
            if (currentReward > 0) {
                _rewards[msg.sender][_rewardTokens[i + 1].token] = 0;
                IERC20(_rewardTokens[i + 1].token).safeTransfer(msg.sender, currentReward);
                emit RewardPaid(msg.sender, currentReward);
            }
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* === RESTRICTED FUNCTIONS === */

    function notifyRewardAmount(uint256[] memory reward) public onlyDistributor updateReward(address(0)) {
        require(reward.length == _totalRewardTokens, "Wrong reward amounts");
        for (uint i = 0; i < _totalRewardTokens; i++) {
            RewardToken storage rewardToken = _rewardTokens[i + 1];
            if (block.timestamp >= periodFinish) {
                rewardToken.rewardRate = reward[i].div(rewardsDuration);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardToken.rewardRate);
                rewardToken.rewardRate = reward[i].add(leftover).div(rewardsDuration);
            }

            uint256 balance = IERC20(rewardToken.token).balanceOf(address(this));
            require(rewardToken.rewardRate <= balance.div(rewardsDuration), "Reward too high");
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);

        emit RewardAdded(reward);
    }

    function addRewardToken(address token) external onlyDistributor {
        require(_totalRewardTokens < 6, "Too many tokens");
        require(IERC20(token).balanceOf(address(this)) > 0, "Must prefund contract");

        // Increment total reward tokens
        _totalRewardTokens += 1;

        // Create new reward token record
        _rewardTokens[_totalRewardTokens] = RewardToken({
            token: token,
            rewardRate: 0,
            rewardPerTokenStored: 0
        });

        _rewardTokenToIndex[token] = _totalRewardTokens;

        uint256[] memory rewardAmounts = new uint256[](_totalRewardTokens);

        for (uint i = 0; i < _totalRewardTokens; i++) {
            if (i == _totalRewardTokens - 1) {
                rewardAmounts[i] = IERC20(token).balanceOf(address(this));
            }
            // else {
            //     rewardAmounts[i] = IERC20(_rewardTokens[i + 1].token).balanceOf(address(this));
            //     if (_rewardTokens[i + 1].token == address(stakingToken)) {
            //         rewardAmounts[i] = rewardAmounts[i].sub(_totalSupply);
            //     }
            // }
        }

        notifyRewardAmount(rewardAmounts);
    }

    function removeRewardToken(address token) public onlyDistributor updateReward(address(0)) {
        require(_totalRewardTokens > 1, "Cannot have 0 reward tokens");
        // Get the index of token to remove
        uint indexToDelete = _rewardTokenToIndex[token];

        // Start at index of token to remove. Remove token and move all later indices lower.
        for (uint i = indexToDelete; i <= _totalRewardTokens; i++) {
            // Get token of one later index
            RewardToken storage rewardToken = _rewardTokens[i + 1];

            // Overwrite existing index with index + 1 record
            _rewardTokens[i] = rewardToken;

            // Delete original
            delete _rewardTokens[i + 1];

            // Set new index
            _rewardTokenToIndex[rewardToken.token] = i;
        }

        _totalRewardTokens -= 1;
    }

    function emergencyWithdrawal(address token) external onlyDistributor updateReward(address(0)) {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "Contract holds no tokens");
        IERC20(token).transfer(rewardsDistributor, balance);
        removeRewardToken(token);
    }

    /* === MODIFIERS === */

    modifier updateReward(address account) {
        uint256[] memory rewardsPerToken = rewardPerToken();
        uint256[] memory currentEarnings = earned(account);
        lastUpdateTime = lastTimeRewardApplicable();
        for (uint i = 0; i < _totalRewardTokens; i++) {
            RewardToken storage rewardToken = _rewardTokens[i + 1];
            rewardToken.rewardPerTokenStored = rewardsPerToken[i];
            if (account != address(0)) {
                _rewards[account][rewardToken.token] = currentEarnings[i];
                _userRewardPerTokenPaid[account][rewardToken.token] = rewardsPerToken[i];                
            }
        }
        _;
    }

    modifier onlyDistributor() {
        require(msg.sender == rewardsDistributor, "Call not distributor");
        _;
    }

    /* === EVENTS === */

    event RewardAdded(uint256[] reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}