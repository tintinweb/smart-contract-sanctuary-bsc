/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {

    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract MaxStaking is Auth {

    struct Tier {
        uint16 apr;
        uint32 duration;
        uint256 tokenLimit;
        uint256 minTokens;
        uint256 stakedTokens;
        uint256 stakeCount;
    }

    struct Stake {
        uint256 stakedAmount;
        uint256 owedReward;
        uint32 stakingStart;
        uint32 tierStart;
        uint8 currentTier;
        bool finished;
    }

    bool public stakingActive = true;
    address public stakingToken;
    uint8 public stakingTokenDecimals;
    uint8 constant internal FIRST_TIER = 9;
    uint16 constant public denominator = 10000;

    mapping (uint8 => Tier) internal _tiers;
    mapping (address => mapping (uint256 => Stake)) internal _stakeStatus;
    mapping (address => uint256) public _stakesAdded;
    //mapping (uint8 => QueuedStake[]) internal _queueItems;

    event Staked(address indexed user, uint256 stakeIndex, uint256 amount);
    event Unstaked(address indexed user, uint256 stakeIndex, uint256 amount);
    event Reward(address indexed user, uint256 amount);
    event StakeFinished(address indexed user, uint256 stakeIndex, uint8 lastTier);
    event StakeUpgrade(address indexed user, uint256 stakeIndex, uint8 newTier);

    modifier validTier(uint8 tier) {
        require(tier > 0 && tier < 10, "Valid tiers are 1 to 9.");
        _;
    }

    /**
     * @dev Stake index starts at 0 so stakes done count will always be index + 1.
     */
    modifier validStakeIndex(address user, uint256 index) {
        require(index < getStakesDone(user), "Stake does not exist.");
        _;
    }

    constructor(address stakingTok) Auth(msg.sender) {
        // Staking token values.
        stakingToken = stakingTok;
        uint8 decimals = IERC20(stakingTok).decimals();
        stakingTokenDecimals = decimals;
        uint32 duration = 7 days;
        uint256 tokenLimit = 1_000_000_000_000 * (10 ** stakingTokenDecimals); // 1 trillion
        uint256 billion = 1_000_000_000 * (10 ** stakingTokenDecimals); // 1 billion
        _tiers[9].apr = 500;
        _tiers[9].duration = duration;
        _tiers[9].tokenLimit = tokenLimit;
        _tiers[8].apr = 1000;
        _tiers[8].duration = duration;
        _tiers[8].tokenLimit = tokenLimit;
        _tiers[7].apr = 1500;
        _tiers[7].duration = duration;
        _tiers[7].tokenLimit = tokenLimit;
        _tiers[6].apr = 3000;
        _tiers[6].duration = duration;
        _tiers[6].tokenLimit = tokenLimit;
        _tiers[6].minTokens = 10 * billion;
        _tiers[5].apr = 4000;
        _tiers[5].duration = duration;
        _tiers[5].tokenLimit = tokenLimit;
        _tiers[5].minTokens = 20 * billion;
        _tiers[4].apr = 6000;
        _tiers[4].duration = duration;
        _tiers[4].tokenLimit = tokenLimit;
        _tiers[4].minTokens = 30 * billion;
        _tiers[3].apr = 8000;
        _tiers[3].duration = duration;
        _tiers[3].tokenLimit = tokenLimit;
        _tiers[3].minTokens = 50 * billion;
        _tiers[2].apr = 16000;
        _tiers[2].duration = duration;
        _tiers[2].tokenLimit = tokenLimit;
        _tiers[2].minTokens = 80 * billion;
        _tiers[1].apr = 32000;
        _tiers[1].duration = duration;
        _tiers[1].tokenLimit = tokenLimit;
        _tiers[1].minTokens = 100 * billion;
    }

    function configureTier(uint8 tier, uint16 apr, uint32 duration, uint256 limit, uint256 min) external validTier(tier) authorized {
        Tier storage t = _tiers[tier];
        require(t.stakeCount == 0, "Tier cannot be configured while it has active stakes.");
        _setTierValues(tier, apr, duration, limit, min);
    }

    function _setTierValues(uint8 tier, uint16 apr, uint32 duration, uint256 limit, uint256 min) internal {
        Tier storage t = _tiers[tier];
        t.apr = apr;
        t.duration = duration;
        t.tokenLimit = limit;
        t.minTokens = min;
    }

    function setStakingActive(bool status) external authorized {
        stakingActive = status;
    }

    function stake(uint256 amount) external {
        require(stakingActive, "Staking is not currently active.");
        require(amount > 0, "Amount needs to be bigger than 0.");
        Tier storage firstTier = _tiers[FIRST_TIER];
        require(amount >= firstTier.minTokens, "Amount is lower than the minimum required for the first tier.");
        require(_hasTierStakeSpace(firstTier, amount), "First tier is full right now.");

        uint256 stakeIndex = _stakesAdded[msg.sender];
        uint32 rnow = uint32(block.timestamp);

        // Add new stake to the list of user's stakes.
        Stake memory nstake;
        nstake.currentTier = FIRST_TIER;
        nstake.stakedAmount = amount;
        nstake.stakingStart = rnow;
        nstake.tierStart = rnow;
        _stakeStatus[msg.sender][stakeIndex] = nstake;
        unchecked {
            ++_stakesAdded[msg.sender];
            // Update tier status.
            firstTier.stakedTokens += amount;
            ++firstTier.stakeCount;
        }
        
        IERC20(stakingToken).transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, stakeIndex, amount);
    }

    function completeTierFor(address staker, uint256 stakeIndex) external validStakeIndex(staker, stakeIndex) {
        _completeTier(staker, stakeIndex);
    }

    function completeTier(uint256 stakeIndex) external validStakeIndex(msg.sender, stakeIndex) {
        _completeTier(msg.sender, stakeIndex);
    }

    function _completeTier(address staker, uint256 stakeIndex) internal {
        Stake storage s = _stakeStatus[staker][stakeIndex];
        require(s.currentTier > 1, "This stake is already at the top tier.");
        require(!s.finished, "This stake has already finished.");

        // Check if time is over.
        Tier storage currentTier = _tiers[s.currentTier];
        require(_canTierBeCompleted(currentTier, s.tierStart), "Cannot finish tier yet.");

        // Check if stake can be promoted to next tier.
        // If they cannot, they are automatically unstaked.
        uint8 next = s.currentTier - 1;
        Tier storage nextTier = _tiers[next];
        if (nextTier.minTokens > s.stakedAmount) {
            _unstake(staker, stakeIndex);
        } else {
            require(_hasTierStakeSpace(nextTier, s.stakedAmount), "Next tier is full. Unstake or try to promote later again.");
            uint256 tierReward = getFullTierReward(s.stakedAmount, s.currentTier);
            // Add completed tier reward to the amount owed.
            // This amount is received after unstaking.
            if (tierReward > 0) {
                unchecked {
                    s.owedReward += tierReward;
                }
            }
            s.currentTier = next;
            s.tierStart = uint32(block.timestamp);
            unchecked {
                currentTier.stakeCount--;
                currentTier.stakedTokens -= s.stakedAmount;
                nextTier.stakeCount++;
                nextTier.stakedTokens += s.stakedAmount;
            }
            emit StakeUpgrade(staker, stakeIndex, next);
        }
    }

    function unstake(uint256 stakeIndex) external validStakeIndex(msg.sender, stakeIndex) {
        _unstake(msg.sender, stakeIndex);
    }

    function _unstake(address user, uint256 stakeIndex) internal {
        Stake storage s = _stakeStatus[user][stakeIndex];
        uint256 toGive = s.owedReward;

        // Check if current tier has been completed to award it or ignore it.
        uint8 currTier = s.currentTier;
        Tier storage t = _tiers[currTier];
        if (_canTierBeCompleted(t, s.tierStart)) {
            // Add this tier's reward to the owed amount.
            toGive += getFullTierReward(s.stakedAmount, currTier);
            s.owedReward = 0;
        }

        // Send all accumulated reward, if any.
        if (toGive > 0) {
            _payReward(user, toGive);
        }

        // Update tier.
        unchecked {
            t.stakeCount--;
            t.stakedTokens -= s.stakedAmount;
        }

        // Mark stake as finished and return stake.
        s.finished = true;
        IERC20(stakingToken).transfer(user, s.stakedAmount);
        s.stakedAmount = 0;

        emit StakeFinished(user, stakeIndex, currTier);
    }

    function _canTierBeCompleted(Tier storage tier, uint32 tierStart) internal view returns (bool) {
        return block.timestamp - tierStart >= tier.duration;
    }

    function _hasTierStakeSpace(Tier storage tier, uint256 amount) internal view returns (bool) {
        // Check if tier is full.
        if (tier.stakedTokens >= tier.tokenLimit) {
            return false;
        }
        // Check for available tokens until tier limit.
        uint256 available = tier.tokenLimit - tier.stakedTokens;
        return amount <= available;
    }

    function _payReward(address receiver, uint256 rewardAmount) internal {
        IERC20(stakingToken).transfer(receiver, rewardAmount);
        emit Reward(receiver, rewardAmount);
    }

    function getFullTierReward(uint256 amount, uint8 tier) public view returns (uint256) {
        if (amount == 0 || tier == 0 || tier > 9) {
            return 0;
        }
        Tier storage tierConfig = _tiers[tier];
        return getAPRrewardByTime(amount, tierConfig.apr, tierConfig.duration);
    }

    function getAPRrewardByTime(uint256 amount, uint16 apr, uint32 elapsedTime) public pure returns (uint256) {
        if (elapsedTime == 0 || apr == 0 || amount == 0) {
            return 0;
        }
        uint256 annuality = amount * apr / denominator;
        return (elapsedTime * annuality) / 365 days;
    }

    function getTierStakedTokens(uint8 tier) public view returns (uint256) {
        if (tier == 0 || tier > 9) {
            return 0;
        }
        Tier storage t = _tiers[tier];
        return t.stakedTokens;
    }

    function getTotalStakedTokens() public view returns (uint256) {
        uint256 total;
        for (uint8 i = 1; i <= 9; i++) {
            total += getTierStakedTokens(i);
        }

        return total;
    }

    function getTierAPR(uint8 tier) external view returns (uint16) {
        if (tier == 0 || tier > 9) {
            return 0;
        }
        Tier storage t = _tiers[tier];
        return t.apr;
    }

    function getTierMinTokens(uint8 tier) external view returns (uint256) {
        if (tier == 0 || tier > 9) {
            return 0;
        }
        Tier storage t = _tiers[tier];
        return t.minTokens;
    }

    function getTierTokenLimit(uint8 tier) external view returns (uint256) {
        if (tier == 0 || tier > 9) {
            return 0;
        }
        Tier storage t = _tiers[tier];
        return t.tokenLimit;
    }

    function getStakesDone(address user) public view returns (uint256) {
        return _stakesAdded[user];
    }

    function countActiveStakes(address user) public view returns (uint256) {
        uint256 done = getStakesDone(user);
        if (done == 0) {
            return 0;
        }
        uint256 active;
        for (uint256 i = 0; i < done; i++) {
            if (!_stakeStatus[user][i].finished) {
                active++;
            }
        }

        return active;
    }

    function getLastStakeIndex(address user) external view returns (uint256) {
        uint256 done = getStakesDone(user);
        if (done == 0) {
            return 0;
        }
        return done - 1;
    }

    function getTierState(uint8 tier) external view returns (Tier memory) {
        return _tiers[tier];
    }

    function getStake(address user, uint256 index) external view returns (Stake memory) {
        return _stakeStatus[user][index];
    }
}