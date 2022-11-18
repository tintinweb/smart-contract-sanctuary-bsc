// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "./BEP20.sol";

/**
* @title Staking contract
* @notice Implements the staking functionality
 **/
contract Staking {
    // Constants
    uint256 public constant STAKE_LOCK_TIME = 30 days;
    uint256 public constant SNAPSHOT_INTERVAL = 1 days;

    mapping(BEP20 => uint) public stakingTokens;
    mapping(BEP20 => uint) public stakingTokensBalances;

    uint256 public immutable DEPLOY_TIME = block.timestamp;

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

    // Snapshots for globals
    struct GlobalsSnapshot {
        uint256 interval;
        uint256 totalStaked;
    }
    mapping(BEP20 => GlobalsSnapshot[]) private globalsSnapshots;

    // Stake
    struct StakeStruct {
        uint256 amount; // Amount of tokens on this stake
        uint256 global_snapshot_index; // Amount of tokens on this stake
        uint256 account_snapshot_index; // Amount of tokens on this stake
        uint256 staketime; // Time this stake was created
        uint256 claimedTime; // Time this stake was claimed (if 0, stake hasn't been claimed)
    }

    // Stake mapping
    // address => stakeID => stake
    mapping(BEP20 => mapping(address => StakeStruct[])) public stakes;

    // Snapshots for accounts
    struct AccountSnapshot {
        uint256 interval;
        uint256 votingPower;
    }
    mapping(BEP20 => mapping(address => AccountSnapshot[])) private accountSnapshots;


    constructor(
        BEP20[] memory _tokens,
        BEP20 _rewardToken
    ) {
        owner = msg.sender;

        for (uint256 i = 0; i < _tokens.length; i++) {
            stakingTokens[_tokens[i]] = 1;
            stakingTokensBalances[_tokens[i]] = 0;
        }
        rewardsToken = _rewardToken;
    }

    function intervalAtTime(uint256 _time) public view returns (uint256) {
        require(_time >= DEPLOY_TIME, "Staking: Requested time is before contract was deployed");
        return (_time - DEPLOY_TIME) / SNAPSHOT_INTERVAL;
    }

    /**
     * @notice Gets current interval
     * @return interval
    */
    function currentInterval() public view returns (uint256) {
        return intervalAtTime(block.timestamp);
    }

    function latestGlobalsSnapshotInterval(BEP20 _token) public view returns (uint256) {
        if (globalsSnapshots[_token].length > 0) {
            // If a snapshot exists return the interval it was taken
            return globalsSnapshots[_token][globalsSnapshots[_token].length - 1].interval;
        } else {
            // Else default to 0
            return 0;
        }
    }

    /**
     * @notice Returns interval of latest account snapshot
     * @param _account - account to get latest snapshot of
     * @return Latest account snapshot interval
    */
    function latestAccountSnapshotInterval(address _account, BEP20 _token) public view returns (uint256) {
        if (accountSnapshots[_token][_account].length > 0) {
            // If a snapshot exists return the interval it was taken
            return accountSnapshots[_token][_account][accountSnapshots[_token][_account].length - 1].interval;
        } else {
            // Else default to 0
            return 0;
        }
    }

    /**
     * @notice Returns account snapshot at index
     * @param _account - account to get snapshot of
     * @param _index - index to get snapshot at
     * @return Account snapshot
    */
    function accountSnapshot(address _account, uint256 _index, BEP20 _token) external view returns (AccountSnapshot memory) {
        return accountSnapshots[_token][_account][_index];
    }

    /**
     * @notice Checks if account and globals snapshots need updating and updates
     * @param _account - Account to take snapshot for
    */
    function snapshot(address _account, BEP20 _token) internal {
        uint256 _currentInterval = currentInterval();

        // If latest global snapshot is less than current interval, push new snapshot
        if(latestGlobalsSnapshotInterval(_token) < _currentInterval) {
            globalsSnapshots[_token].push(GlobalsSnapshot(
                    _currentInterval,
                    stakingTokensBalances[_token]
                )
            );
        }

        // If latest account snapshot is less than current interval, push new snapshot
        // Skip if account is 0 address
        if(_account != address(0) && latestAccountSnapshotInterval(_account, _token) < _currentInterval) {
            accountSnapshots[_token][_account].push(AccountSnapshot(
                    _currentInterval,
                    balanceOf[_token][_account]
                )
            );
        }
    }

    function addStakingTokens(BEP20[] memory _tokens) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (stakingTokens[_tokens[i]] == 0) {
                stakingTokens[_tokens[i]] = 1;
                stakingTokensBalances[_tokens[i]] = 0;
            }
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }

    function stake(uint _amount, BEP20 _token)  public returns (uint256) {
        require(_amount > 0, "amount = 0");
        require(stakingTokens[_token] > 0, "no such token");

        // Check if snapshot needs to be taken
        snapshot(msg.sender, _token);

        // Get stakeID
        uint256 stakeID = stakes[_token][msg.sender].length;

        // Set stake values
        stakes[_token][msg.sender].push(
            StakeStruct(
                _amount,
                globalsSnapshots[_token].length - 1,
                accountSnapshots[_token][msg.sender].length - 1,
                block.timestamp,
                0
            )
        );

        _token.transferFrom(msg.sender, address(this), _amount);

        balanceOf[_token][msg.sender] += _amount;

        // update total supply
        stakingTokensBalances[_token] += _amount;

        return stakeID;
    }

    function withdraw(uint _stakeID, BEP20 _token) public {
        require(stakingTokens[_token] > 0, "no such token");

        require(
            stakes[_token][msg.sender][_stakeID].claimedTime == 0,
            "Staking: Stake already claimed"
        );

        // Check if snapshot needs to be taken
        snapshot(msg.sender, _token);

        // Set stake claimed time
        stakes[_token][msg.sender][_stakeID].claimedTime = block.timestamp;

        balanceOf[_token][msg.sender] -= stakes[_token][msg.sender][_stakeID].amount;

        // update total supply
        stakingTokensBalances[_token] -= stakes[_token][msg.sender][_stakeID].amount;

        _token.transfer(msg.sender, stakes[_token][msg.sender][_stakeID].amount);
    }

    function earned(address _account, BEP20 _token, uint _stakeID) public view returns (uint) {
        return stakes[_token][_account][_stakeID].amount * 2;
    }

    function rewardPerToken(BEP20 _token) public view returns (uint) {
        if (stakingTokensBalances[_token] == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            stakingTokensBalances[_token];
    }

    function getReward(BEP20 _token, uint _stakeID) external {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint _amount) external onlyOwner {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}