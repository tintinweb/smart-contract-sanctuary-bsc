/**
 *Submitted for verification at BscScan.com on 2023-02-11
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
        uint256 minTokens;
    }

    enum RoundState {
        DRAFT,
        ONGOING,
        FINISHED
    }

    struct Round {
        uint32 roundStart;
        uint32 tierTimer;
        uint32 endTime;
        uint256 stakedTokens;
        uint256 stakeCount;
        uint256[9] tierConfigIds;
    }

    struct PendingStake {
        bool processed;
        address staker;
        uint256 stakeAmount;
    }

    struct Stake {
        uint256 stakeAmount;
        uint256 round;
        uint256 claimedReward;
        uint8 maxTier;
        uint8 unstakeTier;
        bool finished;
    }

    // Token for staking and rewards.
    address public stakingToken;
    uint8 public stakingTokenDecimals;

    // Staking system data.
    uint8 constant public FIRST_TIER = 9;
    uint8 constant public TIER_NOT_FOUND = 0;
    uint16 constant public denominator = 10000;
    uint32 internal _tierDuration;
    uint256 internal _tokenLimit;
    uint256 internal _absoluteMinStake;

    // Tier config data.
    // Tiers can be updated but that change will only reflect when a round enters on it.
    // We keep track of tier config for rounds so we can get rewards and limits while calculating yield.
    // This allows to store only data for tiers and rounds and use it to calc individual user yield and limits.
    uint256[9] internal _tierConfigIDs = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    mapping (uint8 => mapping (uint256 => Tier)) internal _tierConfig;

    // Staking status.
    bool public acceptingStakeEntries = false;
    mapping (uint256 => Round) internal _stakingRound;
    uint256 public nextRound;
    mapping (address => mapping (uint256 => Stake)) internal _stakeStatus;
    mapping (address => uint256[]) internal _userRoundStakes;
    uint32 public nextUpgradePossible;

    // Waitlist
    uint256 internal _waitlistIndex; // Next waitlist item to process.
    uint256 internal _lastWaitlistEntry; // ID for most recent waitlist entry.
    uint8 internal _maxWaitlistProcess = 10; // Processing more than 255 items would be extremely gas costly.
    mapping (uint256 => PendingStake) internal _waitList;
    mapping (address => bool) internal _inWaitlist;
    mapping (address => uint256) internal _userWaitlistIndex;

    event StakeEntriesStatus(bool active);
    event Staked(address indexed user, uint256 indexed round, uint256 amount);
    event WaitlistAdded(address indexed user, uint256 amount);
    event WaitlistCancel(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed round, uint8 tierCompleted, uint256 rewardAmount);
    event RoundStarted(uint256 indexed round, uint32 ends);
    event TierUpdated(uint8 indexed tier, uint256 configIndex, uint16 apr, uint256 minTokens);

    error InvalidTier(uint8 attempted);
    error TierNotEmpty(uint8 tier);
    error InvalidRound(uint256 invalidID, uint256 maxValidRound);
    error InvalidStakeAmount(uint256 amount, uint256 min, uint256 max);
    error StakingAvailable();
    error StakingUnavailable();
    error AlreadyStaked(uint256 round);
    error StakeNotFound(uint256 round);
    error UpgradeTooEarly(uint32 minUpgradeTime);
    error AlreadyInWaitlist(address staker);
    error NotInWaitlist();
    error RoundsOngoing();

    modifier validTier(uint8 tier) {
        if (tier == 0 || tier > 9) {
            revert InvalidTier(tier);
        }
        _;
    }

    constructor(address stakingTok) Auth(msg.sender) {
        // Staking token configuration.
        stakingToken = stakingTok;
        uint8 decimals = IERC20(stakingTok).decimals();
        stakingTokenDecimals = decimals;

        // Token limit and tier duration are the same for all tiers within a round.
        // A tier must've been active for duration value to upgrade a new staking round to tier 9.
        // Limit specifies the upper token limit for a round.
        // Absolute minimum specifies the min amount to enter a stake.
        _tokenLimit = 1_000_000_000_000 * (10 ** stakingTokenDecimals);
        _tierDuration = 7 days;
        _absoluteMinStake = 1 * (10 ** stakingTokenDecimals);

        // Tier configuration.
        // When a tier is updated, the new config will be used when a round enters it for the first time.
        uint256 billion = 1_000_000_000 * (10 ** stakingTokenDecimals);
        uint16[9] memory aprs = [32000, 16000, 8000, 6000, 4000, 3000, 1500, 1000, 500];
        uint256[9] memory mins = [
            100 * billion, 80 * billion, 50 * billion,
            30 * billion, 20 * billion, 10 * billion, 0, 0, 0
        ];
        for (uint8 i = 1; i < 10; i++) {
            Tier storage tier = _tierConfig[i][0];
            uint256 index = i - 1;
            tier.apr = aprs[index];
            tier.minTokens = mins[index];
        }
    }

    /**
     * @dev Activates staking round in preparation and allows for new signups on the next.
     */
    function upgrade() external authorized {
        // Very first upgrade is a special case.
        if (nextRound == 0) {
            _firstUpgrade();
            return;
        }

        // Now accepting new stakes for the next round.
        if (!acceptingStakeEntries) {
            acceptingStakeEntries = true;
            emit StakeEntriesStatus(true);
        }

        // When there's an active tier 9 going on, we must check that it's now at tier 8
        // before next round can start on tier 9.
        uint32 upgradeTime = nextUpgradePossible;
        if (block.timestamp < upgradeTime) {
           revert UpgradeTooEarly(upgradeTime);
        }

        // Tier 9 starts.
        _publishRound();
    }

    /**
     * @dev Used to manage the first signup open and upgrade.
     */
    function _firstUpgrade() internal {
        // First round does not need to check whether previous round has passed tier 9.
        // Instead, it needs to check whether to allow entries only or start it.
        // First call, stake entries will be allowed for the first tier 9 of the contract.
        // Second call, this staking group will start counting as active,
        // and the next round will begin preparation.
        if (!acceptingStakeEntries) {
            acceptingStakeEntries = true;
            emit StakeEntriesStatus(false);
        } else {
            _publishRound();
        }
    }

    /**
     * @dev Stakes awaiting for a new run for the first tier (9) start.
     */
    function _publishRound() internal {
        uint256 unpublishedRound = nextRound;
        Round storage r = _getRound(unpublishedRound);

        // Store the tier configuration to be used.
        r.tierConfigIds = _tierConfigIDs;

        // Store the tier duration for this round.
        uint32 rnow = uint32(block.timestamp);
        uint32 timePerTier = _tierDuration;
        r.tierTimer = timePerTier;
        r.roundStart = rnow;
        unchecked {
            // When is round finished.
            r.endTime = rnow + (timePerTier * 9);

            // Increase ID for the next round.
            ++nextRound;

            // Store the time when next upgrade is possible.
            nextUpgradePossible = rnow + timePerTier;

            emit RoundStarted(unpublishedRound, rnow + (timePerTier * 9));
        }

        // Process waitlist.
        _processWaitlist();
    }

    /**
     * @dev Disallows people from adding stakes for the first tier.
     */
    function pauseStakeEntries() external authorized {
        if (acceptingStakeEntries) {
            acceptingStakeEntries = false;
            emit StakeEntriesStatus(false);
        }
    }

    /**
     * @dev Add a stake to a new round or to waitlist for next round.
     */
    function stake(uint256 amount) external {
        // Check if amount is valid on global config.
        uint256 limit = _tokenLimit;
        uint256 min = _absoluteMinStake;
        if (amount < min || amount > limit) {
            revert InvalidStakeAmount(amount, min, limit);
        }

        // Check if staking is currently unavailable.
        if (!acceptingStakeEntries) {
            revert StakingUnavailable();
        }

        // Only one entry per round.
        uint256 nextRoundID = nextRound;
        address staker = msg.sender;
        Stake storage newStake = _getStake(staker, nextRoundID);
        if (newStake.stakeAmount > 0) {
            revert AlreadyStaked(nextRoundID);
        }

        Round storage draftRound = _getRound(nextRoundID);
        // Check current tier 9 min entry.
        min = _getTierMinTokens(draftRound, FIRST_TIER);
        if (amount < min) {
            revert InvalidStakeAmount(amount, min, limit);
        }

        // From here on, the stake gets in or it gets on the waitlist.
        IERC20(stakingToken).transferFrom(staker, address(this), amount);

        // Check if there's actually space on the round.
        unchecked {
            if (draftRound.stakedTokens + amount > limit) {
                // Add to waitlist unless he is already there, then revert and save gas.
                if (_inWaitlist[staker]) {
                    revert AlreadyInWaitlist(staker);
                }
                _addWaitlistEntry(staker, amount);
                return;
            }
        }

        // Valid stake, update and ready to go.
        newStake.round = nextRoundID;
        newStake.maxTier = _maxTierForRound(draftRound, amount);
        newStake.stakeAmount = amount;
        _userRoundStakes[staker].push(nextRoundID);

        // Update stake data for round.
        _roundStake(draftRound, amount);

        emit Staked(staker, nextRoundID, amount);
    }

    /**
     * @dev Returns minimum amount of tokens for a tier for a round.
     */
    function _getTierMinTokens(Round storage r, uint8 tier) internal view returns (uint256) {
        uint256 configIndex = tier - 1;
        uint256 tierConfigID = r.tierConfigIds[configIndex];
        Tier storage t = _tierConfig[tier][tierConfigID];
        uint256 tierMin = t.minTokens;
        if (tierMin < _absoluteMinStake) {
            return _absoluteMinStake;
        }

        return tierMin;
    }

    function _canJoinRound(Round storage r, uint256 amount) internal view returns (bool) {
        // Check if there's space for the stake.
        if (amount + r.stakedTokens > _tokenLimit) {
            return false;
        }

        return true;
    }

    /**
     * @dev Gets the max tier that an amount can reach on a round.
     */
    function _maxTierForRound(Round storage r, uint256 amount) internal view returns (uint8) {
        uint256 minForTier;
        // If we are here, the amount can do the entirety of the first tier, so we check from 8 onwards.
        for (uint8 tier = 8; tier > 0; tier--) {
            minForTier = _getTierMinTokens(r, tier);
            if (amount < minForTier) {
                unchecked {
                    return tier + 1;
                }
            }
        }

        return 1;
    }

    /**
     * @dev Gets stake status for a user on a round.
     */
    function getStake(address user, uint256 round) external view returns (Stake memory) {
        uint256 maxRoundID = nextRound;
        if (round > maxRoundID) {
            revert InvalidRound(round, maxRoundID);
        }
        return _getStake(user, round);
    }

    function _getStake(address user, uint256 round) internal view returns (Stake storage) {
        return _stakeStatus[user][round];
    }

    /**
     * @dev Stores a new stake onto a round.
     */
    function _roundStake(Round storage r, uint256 amount) internal {
        unchecked {
            ++r.stakeCount;
            r.stakedTokens += amount;
        }
    }

    /**
     * @dev Stores a pending stake for a round. They'll join next available round.
     */
    function _addWaitlistEntry(address staker, uint256 amount) internal {
        if (_inWaitlist[staker]) {
            revert AlreadyInWaitlist(staker);
        }

        // Get next waitlist index.
        uint256 newWaitlistIndex;
        unchecked {
            newWaitlistIndex = ++_lastWaitlistEntry;
        }

        // Add the pending stake to the waitlist.
        PendingStake storage pending = _waitList[newWaitlistIndex];
        pending.staker = staker;
        pending.stakeAmount = amount;
        pending.processed = false;
        _inWaitlist[staker] = true;
        _userWaitlistIndex[staker] = newWaitlistIndex;

        emit WaitlistAdded(staker, amount);
    }

    /**
     * @dev When a new round opens for stakes the waitlist fills it first. 
     */
    function _processWaitlist() internal {
        // A max of 0 effectively disables waitlist.
        uint256 max = _maxWaitlistProcess;
        if (max == 0) {
            return;
        }

        // Check if there are waiting stakes.
        uint256 waitingStakes = countWaitlistEntries();
        if (waitingStakes == 0) {
            return;
        }

        // What index we start checking waitlist from.
        uint256 start = _waitlistIndex;
        // What index to check up to. Since start is checked, end is not inclusive.
        uint256 end;
        uint256 itemsToProcess = waitingStakes > max ? max : waitingStakes;
        // Amount of tokens that can be still staked.
        uint256 tokensAvailable;
        Round storage newRound = _getRound(nextRound);
        unchecked {
            end = start + itemsToProcess;
            tokensAvailable = _tokenLimit - newRound.stakedTokens;
        }

        // Check if there's actually token space.
        if (tokensAvailable < _absoluteMinStake) {
            return;
        }

        _runWaitlistItems(start, end, tokensAvailable);
    }

    function _runWaitlistItems(uint256 start, uint256 end, uint256 tokensAvailable) internal {
        uint256 newRoundIndex = nextRound;
        // Stake count and token amount to add if we process items.
        uint256 stakedAmountToAdd;
        uint256 stakeCountToAdd;
        // What index we'll resume checking on next call.
        uint256 nextWaitListIndex;
        Round storage newRound = _getRound(nextRound);

        // Process waitlist while there's token space.
        for (uint256 i = start; i < end; i++) {
            PendingStake storage item = _waitList[i];

            // Canceled or processed waitlist item, ignore and continue checking.
            if (item.processed) {
                nextWaitListIndex = i;
                continue;
            }

            // If next pending stake won't fit, stop here.
            // Update index to continue from this pending item next time.
            uint256 amountToStake = item.stakeAmount;
            if (amountToStake > tokensAvailable) {
                nextWaitListIndex = i;
                break;
            }

            // Check that stake does not exist yet.
            address staker = item.staker;
            Stake storage newStake = _stakeStatus[staker][newRoundIndex];
            if (newStake.stakeAmount > 0) {
                _cancelPendingStake(item);
                nextWaitListIndex = i;
                continue;
            }

            // Pending stake joins the new round and is marked as processed.
            newStake.round = newRoundIndex;
            newStake.stakeAmount = amountToStake;
            newStake.maxTier = _maxTierForRound(newRound, amountToStake);
            _userRoundStakes[staker].push(newRoundIndex);
            _cancelPendingStake(item);

            // Track of round stake status to write to storage all at once later.
            unchecked {
                nextWaitListIndex = i + 1;
                stakedAmountToAdd += amountToStake;
                stakeCountToAdd++;
                tokensAvailable -= amountToStake;
            }

            // If tokens available are below minimum, next index is already stored and we can exit.
            if (tokensAvailable < _absoluteMinStake) {
                break;
            }
        }

        // Write the round data for all items processed.
        _waitlistIndex = nextWaitListIndex;
        unchecked {
            newRound.stakedTokens += stakedAmountToAdd;
            newRound.stakeCount += stakeCountToAdd;
        }
    }

    /**
     * @dev Return how many pending stakes on the waitlist.
     */
    function countWaitlistEntries() public view returns (uint256) {
        // _waitlistIndex points to the next item to be processed, so it's to be included.
        // If lastEntry is 0, there's been no waitlist items added.
        // First waitlist item ever leads to index and entry being both 1.
        // After that, fully processed waitlist is index = lastEntry + 1.
        uint256 index = _waitlistIndex;
        uint256 lastEntry = _lastWaitlistEntry;
        if (lastEntry == 0 || index > lastEntry) {
            return 0;
        }
        unchecked {
            return lastEntry + 1 - index;
        }
    }

    /**
     * @dev How many waitlist entries to process per function call.
     */
    function setWaitlistStakesToProcess(uint8 itemsPerCall) external authorized {
        _maxWaitlistProcess = itemsPerCall;
    }

    /**
     * @dev Cancels a user's stake on the waitlist.
     */
    function _cancelPendingStake(PendingStake storage pending) internal {
        // Confirm the item is yet to be processed.
        if (pending.processed) {
            return;
        }

        // Check and mark as processed so it's ignored when processing queue.
        pending.processed = true;
        uint256 amountToReturn = pending.stakeAmount;
        pending.stakeAmount = 0;

        // Delete waitlist data for user.
        // Index 0 is used to mark a non existing waitlist item.
        address staker = pending.staker;
        _inWaitlist[staker] = false;
        _userWaitlistIndex[staker] = 0;

        // Return tokens intended for the stake.
        IERC20(stakingToken).transfer(staker, amountToReturn);

        emit WaitlistCancel(staker, amountToReturn);
    }

    function unstake(uint256 round) external {
        _unstake(msg.sender, round);
    }

    function unstakeWaitlist() external {
        address staker = msg.sender;
       _findCancelPendingStake(staker);
    }

    function _findCancelPendingStake(address staker) internal {
         if (!_inWaitlist[staker]) {
            revert NotInWaitlist();
        }
        uint256 wlUserIndex = _userWaitlistIndex[staker];
        PendingStake storage item = _waitList[wlUserIndex];
        _cancelPendingStake(item);
    }

    function _unstake(address staker, uint256 round) internal {
        uint256 nextRoundID = nextRound;
        if (round > nextRoundID) {
            revert InvalidRound(round, nextRoundID);
        }

        // Unstake call on draft round with an active waitlist: Waitlist cancel action.
        bool isDraftRound = round == nextRoundID;
        if (isDraftRound && _inWaitlist[staker]) {
            _findCancelPendingStake(staker);
            return;
        }

        // Regular unstake.
        // Check if the user was actually staked.
        Stake storage s = _stakeStatus[staker][round];
        uint256 stakedAmount = s.stakeAmount;
        if (stakedAmount == 0 || s.finished) {
            revert StakeNotFound(round);
        }

        Round storage r = _getRound(round);
        // If unstake is during first tier there is no yield.
        if (_getRoundCurrentTier(r) == FIRST_TIER) {
            _roundUnstake(r, stakedAmount);
            emit Unstaked(staker, round, TIER_NOT_FOUND, 0);

            // Staking didn't start, check waitlist to see if someone can take their place.
            if (isDraftRound) {
                _processWaitlist();
            }
            return;
        }

        // Check the tiers successfully completed.
        uint8 tierForYield = _getMaxTierForYield(r, s.maxTier);

        // Calculate and send yield reward.
        uint256 yield = _calculateYield(r, tierForYield, stakedAmount);
        s.finished = true;
        s.stakeAmount = 0;
        s.claimedReward = yield;
        s.unstakeTier = tierForYield;
        _roundUnstake(r, stakedAmount);
        IERC20(stakingToken).transfer(staker, stakedAmount + yield);

        emit Unstaked(staker, round, tierForYield, yield);
    }

    /**
     * @dev Remove stake count and amount from a round.
     */
    function _roundUnstake(Round storage r, uint256 amount) internal {
        unchecked {
            --r.stakeCount;
            r.stakedTokens -= amount;
        }
    }

    /**
     * @dev Get what tier is a round occupying right now.
     */
    function getRoundCurrentTier(uint256 round) external view returns (uint8) {
        uint256 maxRoundID = nextRound;
        if (round > maxRoundID) {
            return FIRST_TIER;
        }
        Round storage r = _stakingRound[round];
        return _getRoundCurrentTier(r);
    }

    function _getRoundCurrentTier(Round storage r) internal view returns (uint8) {
        RoundState state = _getRoundState(r);
        if (state == RoundState.DRAFT) {
            return FIRST_TIER;
        }
        if (state == RoundState.FINISHED) {
            return 1;
        }
        uint256 timestamp = block.timestamp;
        uint256 endTime = r.endTime;
        uint256 startTime = r.roundStart;
        if (endTime == 0 || startTime == 0 || startTime > timestamp) {
            return FIRST_TIER;
        }
        if (endTime <= timestamp) {
            return 1;
        }
        // Here, startTime is always less than timestamp.
        unchecked {
            uint256 deltaTime = timestamp - startTime;
            uint256 timePerTier = r.tierTimer;
            if (deltaTime < timePerTier) {
                return FIRST_TIER;
            }
            // Since the timer has not completed and it's a multiple of timePerTier,
            // it will always be below 9.
            uint8 upgradeTimes = uint8(deltaTime / timePerTier);
            return FIRST_TIER - upgradeTimes;
        }
    }

    /**
     * @dev Return tiers completed by a staker for yield calculation.
     */
    function _getMaxTierForYield(Round storage r, uint8 maxTier) internal view returns (uint8) {
        if (_getRoundState(r) == RoundState.FINISHED) {
            return maxTier;
        }

        uint8 completedTier = _getRoundCurrentTier(r) + 1;
        return completedTier < maxTier ? completedTier : maxTier;
    }

    function _calculateYield(Round storage r, uint8 tierCompleted, uint256 amount) internal view returns (uint256) {
        if (amount == 0 || tierCompleted > FIRST_TIER || tierCompleted == TIER_NOT_FOUND) {
            return 0;
        }
        uint256[9] memory tierConfigIDs = r.tierConfigIds;
        uint256 reward;
        uint256 tierConfigId;
        for (uint8 i = FIRST_TIER; i >= tierCompleted; i--) {
            tierConfigId = tierConfigIDs[i - 1];
            Tier storage config = _tierConfig[i][tierConfigId];
            reward += getYieldByTime(amount, config.apr, r.tierTimer);
        }

        return reward;
    }

    function getYieldByTime(uint256 amount, uint16 apr, uint32 elapsedTime) public pure returns (uint256) {
        if (elapsedTime == 0 || apr == 0 || amount == 0) {
            return 0;
        }
        uint256 annuality = amount * apr / denominator;
        return (elapsedTime * annuality) / 365 days;
    }

    /**
     * @dev Returns the reward for a user in a round if they unstaked now.
     */
    function getPendingReward(address user, uint256 round) external view returns (uint256) {
        if (round >= nextRound) {
            return 0;
        }
        Stake storage s = _stakeStatus[user][round];
        uint256 amount = s.stakeAmount;
        if (amount == 0 || s.finished || s.maxTier == TIER_NOT_FOUND) {
            return 0;
        }
        Round storage r = _getRound(round);
        RoundState state = _getRoundState(r);
        if (state == RoundState.DRAFT) {
            return 0;
        }
        uint8 maxTier = _getMaxTierForYield(r, s.maxTier);
        return _calculateYield(r, maxTier, amount);
    }

    /**
     * @dev Given a tier, returns the most recent configuration for it.
     */
    function getTierConfig(uint8 tier) external view validTier(tier) returns (Tier memory) {
        return _getTierConfig(tier);
    }

    function _getTierConfig(uint8 tier) internal view returns (Tier storage) {
        uint256 index;
        unchecked {
            index = tier - 1;
        }
        uint256 configId = _tierConfigIDs[index];
        return _getTierConfigAt(tier, configId);
    }

    function _getTierConfigAt(uint8 tier, uint256 configId) internal view returns (Tier storage) {
        return _tierConfig[tier][configId];
    }

    function getTierAPR(uint8 tier) external view validTier(tier) returns (uint16) {
        Tier storage t = _getTierConfig(tier);
        return t.apr;
    }

    /**
     * @dev How many tokens can fit in a round.
     */
    function getTokenLimit() external view returns (uint256) {
        return _tokenLimit;
    }

    /**
     * @dev Current global tier duration.
     */
    function getTierDuration() external view returns (uint32) {
        return _tierDuration;
    }

    /**
     * @dev Number of rounds the user has staked into.
     */
    function countStakesByUser(address user) external view returns (uint256) {
        return _userRoundStakes[user].length;
    }

    /**
     * @dev All IDs of rounds joined by user.
     */
    function getRoundsJoined(address user) external view returns (uint256[] memory) {
        return _userRoundStakes[user];
    }

    /**
     * @dev Round ID at a specific index.
     */
    function getRoundJoinedAt(address user, uint256 index) external view returns (uint256) {
        return _userRoundStakes[user][index];
    }

    /**
     * @dev Checks whether a user joined a specific round.
     */
    function joinedRound(address user, uint256 round) public view returns (bool) {
        if (round > nextRound) {
            return false;
        }
        return _stakeStatus[user][round].stakeAmount > 0;
    }

    /**
     * @dev Gets data from an existing round.
     */
    function getRound(uint256 index) external view returns (Round memory) {
        uint256 maxRoundID = nextRound;
        if (index > maxRoundID) {
            revert InvalidRound(index, maxRoundID);
        }
        return _getRound(index);
    }

    function _getRound(uint256 index) internal view returns (Round storage) {
        return _stakingRound[index];
    }

    /**
     * @dev Returns the tier of a staker on an active round.
     */
    function getTierForUserInRound(address staker, uint256 round) external view returns (uint8) {
        if (!joinedRound(staker, round)) {
            return TIER_NOT_FOUND;
        }
        Stake storage s = _stakeStatus[staker][round];
        if (s.finished) {
            return s.unstakeTier;
        }
        Round storage r = _getRound(round);
        RoundState currStatus = _getRoundState(r);
        if (currStatus == RoundState.DRAFT) {
            return FIRST_TIER;
        }
        if (currStatus == RoundState.FINISHED) {
            return s.maxTier;
        }
        uint8 roundCurrTier = _getRoundCurrentTier(r);
        if (s.maxTier < roundCurrTier) {
            return s.maxTier;
        }
        return roundCurrTier;
    }

    function getNextRoundID() external view returns (uint256) {
        return nextRound;
    }

    /**
     * @dev Calculates round state from its data.
     */
    function getRoundState(uint256 round) external view returns (RoundState) {
        Round storage r = _stakingRound[round];
        return _getRoundState(r);
    }

    function _getRoundState(Round storage r) internal view returns (RoundState) {
        uint32 start = r.roundStart;
        uint256 timestamp = block.timestamp;
        if (start == 0 || timestamp < start) {
            return RoundState.DRAFT;
        }
        if (r.endTime < timestamp) {
            return RoundState.FINISHED;
        }
        return RoundState.ONGOING;
    }

    /**
     * @dev Returns the timestamp of when a tier will be completed in a specific round.
     */
    function getTierCompletionTime(uint256 round, uint8 tier) external view returns (uint32) {
        if (round >= nextRound) {
            return 0;
        }
        Round storage r = _stakingRound[round];
        return _getTierCompletionTime(r, tier);
    }

    function _getTierCompletionTime(Round storage r, uint8 tier) internal view returns (uint32) {
        if (tier == TIER_NOT_FOUND || tier > 9) {
            return 0;
        }
        // If timestamps on uint32 overflow everyone involved in this it's the year 21xx and we are all dead.
        // Tier will always be below 9 and above 0 here.
        unchecked {
            if (tier == FIRST_TIER) {
                return r.roundStart + r.tierTimer;
            }
            uint32 upgrades = FIRST_TIER - tier + 1;
            return r.roundStart + (r.tierTimer * upgrades);
        }
    }

    /**
     * @dev Allows to change the configuration of an empty tier.
     */
    function configureTier(uint8 tier, uint16 apr, uint256 min) external validTier(tier) authorized {
        // Check that tier is not being used.
        if (!_isTierEmpty(tier)) {
            revert TierNotEmpty(tier);
        }

        // Update values.
        uint256 newId = _setTierValues(tier, apr, min);

        // Point to the tier config on active rounds that did not reach it yet.
        _updateTierForAvailableRounds(tier, newId);
    }

    /**
     * @dev Update the configuration of a tier for those staking rounds that did not reach it.
     */
    function _updateTierForAvailableRounds(uint8 tier, uint256 newId) internal {
        uint256 nextRoundIndex = nextRound;
        uint256 tierIndex = tier - 1;

        // First round ever.
        if (nextRoundIndex == 0) {
            Round storage firstRound = _getRound(0);
            firstRound.tierConfigIds[tierIndex] = newId;
            return;
        }

        // Find active rounds to update.
        uint256 checks = nextRoundIndex > 8 ? 9 : nextRoundIndex;
        uint8 olderTier;
        for (uint256 i = 1; i <= checks; i++) {
            Round storage olderRound = _getRound(nextRoundIndex - i);
            if (_getRoundState(olderRound) == RoundState.FINISHED) {
                return;
            }
            olderTier = _getRoundCurrentTier(olderRound);
            if (olderTier > tier) {
                olderRound.tierConfigIds[tierIndex] = newId;
            } else {
                return;
            }
        }
    }

    /**
     * @dev Given a tier, finds out if it's being used in ongoing stakes.
     */
    function _isTierEmpty(uint8 tier) internal view returns (bool) {
        uint256 nextRoundIndex = nextRound;

        // No round has ever been started.
        if (nextRoundIndex == 0) {
            return true;
        }

        uint256 checks = nextRoundIndex > 8 ? 9 : nextRoundIndex;
        uint8 olderTier;
        for (uint256 i = 1; i <= checks; i++) {
            Round storage olderRound = _getRound(nextRoundIndex - i);

            // If round at that tier, it's being used.
            olderTier = _getRoundCurrentTier(olderRound);
            if (olderTier == tier) {
                return false;
            }

            // If we get to a finished round and tier has not been found in use yet,
            // it is for sure not being used.
            if (_getRoundState(olderRound) == RoundState.FINISHED) {
                return true;
            }
        }

        return true;
    }

    function isTierEmpty(uint8 tier) external view returns (bool) {
        return _isTierEmpty(tier);
    }

    function _setTierValues(uint8 tier, uint16 apr, uint256 min) internal returns (uint256) {
        // Tier is always 1-9 here.
        // If tiers are updated to uint256 max, something's wrong.
        uint256 next;
        unchecked {
            uint256 currentID = _tierConfigIDs[tier - 1];
            next = currentID + 1;
        }

        Tier storage t = _tierConfig[tier][next];
        t.apr = apr;
        t.minTokens = min;

        emit TierUpdated(tier, next, apr, min);

        return next;
    }

    function setTierDuration(uint32 newDuration) external authorized {
        if (acceptingStakeEntries) {
            revert StakingAvailable();
        }
        uint256 nextRoundID = nextRound;
        if (nextRoundID > 0) {
            Round storage previous = _getRound(nextRoundID);
            if (_getRoundState(previous) != RoundState.FINISHED) {
                revert RoundsOngoing();
            }
        }
        _tierDuration = newDuration;
    }
    
    function getWhitelistEntries() external view returns (PendingStake[] memory) {
        uint256 count = countWaitlistEntries();
        PendingStake[] memory entries = new PendingStake[](count);
        if (count > 0) {
            uint256 start = _waitlistIndex;
            for (uint256 i = 0; i < count; i++) {
                entries[i] = _waitList[start + i];
            }
        }

        return entries;
    }

    function canEnterTierForRound(uint256 amount, uint256 round, uint8 tier) external view validTier(tier) returns (bool) {
        if (amount < _absoluteMinStake) {
            return false;
        }
        Round storage r = _getRound(round);
        uint256 tierConfigIndex = r.tierConfigIds[tier - 1];
        Tier storage tierConfig = _getTierConfigAt(tier, tierConfigIndex);

        return amount >= tierConfig.minTokens;
    }

    /**
     * @dev Counts number of stakes and their tokens either on an active tier.
     */
    function countAllActiveStakes() external view returns (uint256 stakes, uint256 stakedTokens) {
        uint256 nextRoundID = nextRound;

        // No ongoing stakes.
        if (nextRoundID == 0) {
            return (0, 0);
        }

        // Check from most recent round up to nine rounds until a finished one or all of them.
        // Max active rounds are 9.
        uint256 checks = nextRoundID > 8 ? 9 : nextRoundID;
        for (uint256 i = 1; i <= checks; i++) {
            uint256 checkRound = nextRoundID - i;
            Round storage r = _getRound(checkRound);
            RoundState state = _getRoundState(r);
            if (state == RoundState.FINISHED) {
                break;
            }
            unchecked {
                stakes += r.stakeCount;
                stakedTokens += r.stakedTokens;
            }
        }
    }

    function countDraftStakes() external view returns (uint256 stakes, uint256 stakedTokens) {
        Round storage r = _getRound(nextRound);
        return (r.stakeCount, r.stakedTokens);
    }

    function countWaitlistStakes() external view returns (uint256 stakes, uint256 stakedTokens) {
        uint256 waitingStakes = countWaitlistEntries();
        if (waitingStakes == 0) {
            return (0, 0);
        }

        uint256 start = _waitlistIndex;
        uint256 end = start + waitingStakes;

        for (uint256 i = start; i < end; i++) {
            PendingStake storage item = _waitList[i];
            if (item.processed) {
                continue;
            }
            unchecked {
                stakes++;
                stakedTokens += item.stakeAmount;
            }
        }
    }
}