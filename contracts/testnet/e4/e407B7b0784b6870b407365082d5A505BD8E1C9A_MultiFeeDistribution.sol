// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../interfaces/IChefIncentivesController.sol";
import "../interfaces/IMultiFeeDistribution.sol";
import "../interfaces/LockedBalance.sol";
import "../interfaces/IMintableToken.sol";
import "../interfaces/IPriceProvider.sol";
import "../interfaces/IDisqualifier.sol";
import "../interfaces/IAutoCompounder.sol";

import "../dependencies/openzeppelin/contracts/IERC20.sol";
import "../dependencies/openzeppelin/contracts/IERC20Detailed.sol";
import "../dependencies/openzeppelin/contracts/SafeERC20.sol";
import "../dependencies/openzeppelin/contracts/SafeMath.sol";
import "../dependencies/openzeppelin/upgradeability/Initializable.sol";
import "../dependencies/openzeppelin/upgradeability/OwnableUpgradeable.sol";
import "../libraries/AddressPagination.sol";

/// @title Multi Fee Distribution Contract
/// @author Radiant
/// @dev All function calls are currently implemented without side effects
contract MultiFeeDistribution is
    IMultiFeeDistribution,
    Initializable,
    OwnableUpgradeable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IMintableToken;
    using AddressPagination for address[];

    struct Reward {
        uint256 periodFinish;
        uint256 rewardPerSecond;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        // tracks already-added balances to handle accrued interest in aToken rewards
        // for the stakingToken this value is unused and will always be 0
        uint256 balance;
    }

    struct Balances {
        uint256 total; // sum of earnings and lockings; no use when LP and RDNT is different
        uint256 unlocked; // RDNT token
        uint256 locked; // LP token or RDNT token
        uint256 lockedWithMultiplier; // Multiplied locked amount
        uint256 earned; // RDNT token
    }

    /********************** Constants ***********************/

    uint256 public constant QUART = 25000; //  25%
    uint256 public constant HALF = 65000; //  65%
    uint256 public constant WHOLE = 100000; // 100%

    /// @notice Proportion of burn amount
    uint256 public BURN;

    /// @notice Duration that rewards are streamed over
    uint256 public REWARDS_DURATION;

    /// @notice Duration that rewards loop back
    uint256 public REWARDS_LOOKBACK;

    /// @notice Multiplier for earnings, fixed to 1
    uint256 public constant DEFAULT_MUTLIPLIER = 1;

    /// @notice Duration of lock/earned penalty period, used for earnings
    uint256 public DEFAULT_LOCK_DURATION;

    address public rewardConverter;

    /********************** Contract Addresses ***********************/

    /// @notice Address of Middle Fee Distribution Contract
    IMiddleFeeDistribution public middleFeeDistribution;

    /// @notice Address of CIC contract
    IChefIncentivesController public incentivesController;

    /// @notice Address of RDNT
    IMintableToken public rdntToken;

    /// @notice Address of LP token
    IERC20 public stakingToken;

    // Address of MFD stats
    address internal mfdStats;

    // Address of Lock Zapper
    address internal lockZapAddr;

    // Address of Price Provider
    IPriceProvider internal priceProvider;

    /// @notice Address of Disqualifier
    IDisqualifier public disqualifier;

    /********************** Lock & Earn Info ***********************/

    // Private mappings for balance data
    mapping(address => Balances) private balances;
    mapping(address => LockedBalance[]) private userLocks;
    mapping(address => LockedBalance[]) private userEarnings;

    /// @notice Total staked supply to this contract
    uint256 public totalSupply;

    /// @notice Total locked value
    uint256 public lockedSupply;

    /// @notice Total locked value in multipliers
    uint256 public lockedSupplyWithMultiplier;

    /// @notice Total burnt amount
    uint256 public burnedSupply;

    /// @notice Time lengths
    uint256[] public lockPeriod;

    /// @notice Multipliers
    uint256[] public rewardMultipliers;

    /********************** Reward Info ***********************/

    /// @notice Reward tokens being distributed
    address[] public rewardTokens;

    /// @notice Reward data per token
    mapping(address => Reward) public rewardData;

    /// @notice user -> reward token -> rpt; RPT for paid amount
    mapping(address => mapping(address => uint256))
        public userRewardPerTokenPaid;

    /// @notice user -> reward token -> amount; used to store reward amount
    mapping(address => mapping(address => uint256)) public rewards;

    mapping(address => mapping(address => uint256)) public unclaimedBounties;

    /********************** Other Info ***********************/

    /// @notice DAO wallet
    address public override daoTreasury;

    /// @notice Addresses approved to call mint
    mapping(address => bool) public minters;

    /// @notice Addresses to relock
    mapping(address => bool) public autoRelockDisabled;
    // note: relock disabled is default, autocompound default false
    mapping(address => bool) public autocompoundEnabled;

    /// @notice Default lock index for relock
    mapping(address => uint256) public defaultLockIndex;

    /// @notice Flag to prevent more minter addings
    bool public mintersAreSet;

    // Users list
    address[] internal userlist;
    mapping(address => uint256) internal indexOf;
    mapping(address => bool) internal inserted;

    mapping(address => uint256) public lastClaimTime;

    // to prevent unbounded lock length iteration during withdraw/clean
    uint256 maxLockWithdrawPerTxn;

    /********************** Events ***********************/

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, bool locked);
    event Withdrawn(
        address indexed user,
        address indexed token,
        uint256 receivedAmount,
        uint256 penalty,
        uint256 burn
    );
    event RewardPaid(
        address indexed user,
        address indexed rewardToken,
        uint256 reward
    );
    event IneligibleRewardRemoved(
        address indexed user,
        address indexed rewardToken,
        uint256 reward
    );
    event RewardsDurationUpdated(address token, uint256 newDuration);
    event MaxLockWithdrawPerTxnUpdated(uint256 newLimit);
    event Recovered(address token, uint256 amount);

    /**
     * @dev Constructor
     *  First reward MUST be the RDNT token or things will break
     *  related to the 50% penalty and distribution to locked balances.
     * @param _rdntToken RDNT token address.
     * @param _priceProvider Price Provider address.
     * @param _rewardsDuration set reward stream time.
     * @param _rewardsLookback reward lookback
     * @param _lockDuration lock duration
     */

    function initialize(
        address _rdntToken,
        address _priceProvider,
        uint256 _rewardsDuration,
        uint256 _rewardsLookback,
        uint256 _lockDuration
    ) public initializer {
        require(_priceProvider != address(0), "Not a valid address");
        require(_rewardsDuration != uint256(0), "Not a valid number");
        require(_rewardsLookback != uint256(0), "Not a valid number");
        require(_lockDuration != uint256(0), "Not a valid number");
        require(REWARDS_LOOKBACK <= REWARDS_DURATION, "Underflow error");

        __Ownable_init();

        priceProvider = IPriceProvider(_priceProvider);
        rdntToken = IMintableToken(_rdntToken);
        rewardTokens.push(_rdntToken);
        rewardData[_rdntToken].lastUpdateTime = block.timestamp;

        maxLockWithdrawPerTxn = 50;

        REWARDS_DURATION = _rewardsDuration;
        REWARDS_LOOKBACK = _rewardsLookback;
        DEFAULT_LOCK_DURATION = _lockDuration;
    }

    /********************** Setters ***********************/
       
    /**
     * @notice Set MFD Stats.
     */
    function setMFDStats(address _mfdStats)
        external
        onlyOwner
    {
        mfdStats = _mfdStats;
    }

    /**
     * @notice Set price provider.
     */
    function setPriceProvider(IPriceProvider _priceProvider)
        external
        onlyOwner
    {
        priceProvider = _priceProvider;
    }

    /**
     * @notice Set rewards duration.
     */
    function setRewardsDuration(uint256 _rewardsDuration)
        external
        onlyOwner
    {
        REWARDS_DURATION = _rewardsDuration;
    }

    /**
     * @notice Set rewards lookback.
     */
    function setRewardsLookback(uint256 _rewardsLookback)
        external
        onlyOwner
    {
        REWARDS_LOOKBACK = _rewardsLookback;
    }

     /**
     * @notice Set lock duration.
     */
    function set(uint256 _lockDuration)
        external
        onlyOwner
    {
        DEFAULT_LOCK_DURATION = _lockDuration;
    }


    /**
     * @notice Set minters
     * @dev Can be called only once
     */
    function setMinters(address[] memory _minters) external onlyOwner {
        require(!mintersAreSet);
        for (uint256 i; i < _minters.length; i++) {
            minters[_minters[i]] = true;
        }
        mintersAreSet = true;
    }

    /**
     * @notice Add a new reward token to be distributed to stakers.
     */
    function setLockTypeInfo(
        uint256[] memory _lockPeriod,
        uint256[] memory _rewardMultipliers
    ) external onlyOwner {
        require(
            _lockPeriod.length == _rewardMultipliers.length,
            "length mismatch"
        );
        delete lockPeriod;
        delete rewardMultipliers;
        for (uint256 i = 0; i < _lockPeriod.length; i += 1) {
            lockPeriod.push(_lockPeriod[i]);
            rewardMultipliers.push(_rewardMultipliers[i]);
        }
    }

    /**
     * @notice Set CIC.
     */
    function setIncentivesController(IChefIncentivesController _controller)
        external
        onlyOwner
    {
        incentivesController = _controller;
    }

    /**
     * @notice Set Middle Fee Distribution.
     */
    function setMiddleFeeDistribution(
        IMiddleFeeDistribution _middleFeeDistribution
    ) external onlyOwner {
        middleFeeDistribution = _middleFeeDistribution;
    }

    /**
     * @notice Set Disqualifier
     */
    function setDisqualifier(IDisqualifier _disqualifier) external onlyOwner {
        disqualifier = _disqualifier;
    }

    /**
     * @notice Set LP token.
     */
    function setLPToken(IERC20 _stakingToken) external onlyOwner {
        require(address(stakingToken) == address(0));
        stakingToken = _stakingToken;
    
    }
    function setMaxLockWithdrawPerTxn(uint256 _newVal) external onlyOwner {
        require(maxLockWithdrawPerTxn != 0);
        maxLockWithdrawPerTxn = _newVal;
        emit MaxLockWithdrawPerTxnUpdated(_newVal);
    }

    /**
     * @notice Set DAO Treasury.
     */
    function setDAOTreasury(address _daoTreasury) external onlyOwner {
        require(_daoTreasury != address(0));
        daoTreasury = _daoTreasury;
    }

    /**
     * @notice Set burn amount proporation
     */
    function setBURN(uint256 _BURN) external onlyOwner {
        require(_BURN <= WHOLE);
        BURN = _BURN;
    }

    function setRewardConverter(address _rewardConverter) external onlyOwner {
        rewardConverter = _rewardConverter;
    }

    /**
     * @notice Add a new reward token to be distributed to stakers.
     */
    function addReward(address _rewardToken) external override {
        require(minters[msg.sender]);
        require(rewardData[_rewardToken].lastUpdateTime == 0);
        rewardTokens.push(_rewardToken);
        rewardData[_rewardToken].lastUpdateTime = block.timestamp;
        rewardData[_rewardToken].periodFinish = block.timestamp;
    }

    /********************** View functions ***********************/

    /**
     * @notice Returns mfd stats address.
     */
    function getMFDstatsAddress() external view override returns (address) {
        return mfdStats;
    }

    /**
     * @notice Return the number of users.
     */
    function lockersCount() external view override returns (uint256) {
        return userlist.length;
    }

    /**
     * @notice Return address of stakingToken.
     */
    function getStakingTokenAddress() external view override returns (address) {
        return address(stakingToken);
    }

    /**
     * @notice Set default lock type index for user relock.
     */
    function setDefaultRelockTypeIndex(uint256 _index) external override {
        require(_index < lockPeriod.length, "Invalid lock type");
        defaultLockIndex[msg.sender] = _index;
    }

    function getDefaultRelockTypeIndex(address _user) external override view returns (uint256) {
        return defaultLockIndex[_user];
    }

    /**
     * @notice Return the number of lockTypes.
     */
    function lockTypesLength() public view returns (uint256) {
        return lockPeriod.length;
    }

    function getLockDurations()
        external
        view
        returns (uint256[] memory durations)
    {
        durations = new uint256[](lockTypesLength());
        for (uint256 i = 0; i < lockTypesLength(); i += 1) {
            durations[i] = lockPeriod[i];
        }
    }

    function getLockMultipliers()
        external
        view
        returns (uint256[] memory multipliers)
    {
        multipliers = new uint256[](lockTypesLength());
        for (uint256 i = 0; i < lockTypesLength(); i += 1) {
            multipliers[i] = rewardMultipliers[i];
        }
    }

    /**
     * @notice Set relock status
     */
    function setRelock(bool _status) external {
        autoRelockDisabled[msg.sender] = !_status;
    }

    function setAutocompound(bool _status) external override {
        autocompoundEnabled[msg.sender] = _status;
    }

    function getAutocompoundEnabled(address _user) external view override returns(bool) {
        return autocompoundEnabled[_user];
    }

    function autocompound(address _user) external override {
        require(msg.sender == address(disqualifier), "!disqualifier");
        require(autocompoundEnabled[_user], "!AC");
        IAutoCompounder(rewardConverter).swapRewardsToLpForUser(_user);
    }

    /**
     * @notice Return the list of users.
     */
    function getUsers(uint256 page, uint256 limit)
        external
        view
        override
        returns (address[] memory)
    {
        return userlist.paginate(page, limit);
    }

    /**
     * @notice Returns all locks of a user.
     */
    function lockInfo(address user)
        external
        view
        override
        returns (LockedBalance[] memory)
    {
        return userLocks[user];
    }

    function hasAutoRelockDisabled(address _user)
        public
        view
        override
        returns (bool)
    {
        return autoRelockDisabled[_user];
    }

    /**
     * @notice Update price provider
     */
    function _updatePriceProvider() internal {
        priceProvider.update();
    }

    /**
     * @notice Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders.
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        require(
            rewardData[tokenAddress].lastUpdateTime == 0,
            "Cannot withdraw token"
        );
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setLockZap(address _lockZapAddr) public onlyOwner {
        lockZapAddr = _lockZapAddr;
    }

    /**
     * @notice Withdraw and restake assets.
     */
    function relock() external {
        uint256 amount = _withdrawExpiredLocksFor(msg.sender, true, true);
        stake(amount, msg.sender, defaultLockIndex[msg.sender]);
    }

    /**
     * @notice Total balance of an account, including unlocked, locked and earned tokens.
     */
    function totalBalance(address user)
        external
        view
        override
        returns (uint256 amount)
    {
        if (address(stakingToken) == address(rdntToken)) {
            return balances[user].total;
        }
        return balances[user].locked;
    }

    /**
     * @notice Information on a user's lockings
     * @return total balance of locks
     * @return unlockable balance
     * @return locked balance
     * @return lockedWithMultiplier
     * @return lockData which is an array of locks
     */
    function lockedBalances(address user)
        external
        view
        override
        returns (
            uint256 total,
            uint256 unlockable,
            uint256 locked,
            uint256 lockedWithMultiplier,
            LockedBalance[] memory lockData
        )
    {
        LockedBalance[] storage locks = userLocks[user];
        uint256 idx;
        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    lockData = new LockedBalance[](locks.length - i);
                }
                lockData[idx] = locks[i];
                idx++;
                locked = locked.add(locks[i].amount);
                lockedWithMultiplier = lockedWithMultiplier.add(locks[i].amount.mul(locks[i].multiplier));
            } else {
                unlockable = unlockable.add(locks[i].amount);
            }
        }
        return (balances[user].locked, unlockable, locked, lockedWithMultiplier, lockData);
    }

    /**
     * @notice Earnings which is locked yet
     * @dev Earned balances may be withdrawn immediately for a 50% penalty.
     * @return total earnings
     * @return unlocked earnings
     * @return earningsData which is an array of all infos
     */
    function earnedBalances(address user)
        public
        view
        returns (
            uint256 total,
            uint256 unlocked,
            EarnedBalance[] memory earningsData
        )
    {
        unlocked = balances[user].unlocked;
        LockedBalance[] storage earnings = userEarnings[user];
        uint256 idx;
        for (uint256 i = 0; i < earnings.length; i++) {
            if (earnings[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    earningsData = new EarnedBalance[](earnings.length - i);
                }
                (, uint256 penaltyAmount, , ) = ieeWithdrawableBalances(
                    user,
                    earnings[i].unlockTime
                );
                earningsData[idx].amount = earnings[i].amount;
                earningsData[idx].unlockTime = earnings[i].unlockTime;
                earningsData[idx].penalty = penaltyAmount;
                idx++;
                total = total.add(earnings[i].amount);
            } else {
                unlocked = unlocked.add(earnings[i].amount);
            }
        }
        return (total, unlocked, earningsData);
    }

    /**
     * @notice Final balance received and penalty balance paid by user upon calling exit.
     * @dev This is earnings, not locks.
     */
    function withdrawableBalance(address user)
        public
        view
        returns (
            uint256 amount,
            uint256 penaltyAmount,
            uint256 burnAmount
        )
    {
        Balances storage bal = balances[user];
        uint256 earned = bal.earned;
        if (earned > 0) {
            uint256 length = userEarnings[user].length;
            for (uint256 i = 0; i < length; i++) {
                uint256 earnedAmount = userEarnings[user][i].amount;
                if (earnedAmount == 0) continue;
                uint256 unlockTime = userEarnings[user][i].unlockTime;

                uint256 penaltyFactor;
                if (unlockTime > block.timestamp) {
                    // 90% on day 1, decays to 25% on day 90
                    penaltyFactor = unlockTime
                        .sub(block.timestamp)
                        .mul(HALF)
                        .div(DEFAULT_LOCK_DURATION)
                        .add(QUART); // 25% + timeLeft/DEFAULT_LOCK_DURATION * 65%
                }

                penaltyAmount = penaltyAmount.add(
                    earnedAmount.mul(penaltyFactor).div(WHOLE)
                );
                burnAmount = burnAmount.add(penaltyAmount.mul(BURN).div(WHOLE));
            }
        }
        amount = bal.unlocked.add(earned).sub(penaltyAmount);
        return (amount, penaltyAmount, burnAmount);
    }

    /********************** Reward functions ***********************/

    /**
     * @notice Reward amount of the duration.
     * @param _rewardToken for the reward
     */
    function getRewardForDuration(address _rewardToken)
        public
        view
        returns (uint256)
    {
        return
            rewardData[_rewardToken].rewardPerSecond.mul(REWARDS_DURATION).div(
                1e12
            );
    }

    /**
     * @notice Returns reward applicable timestamp.
     */
    function lastTimeRewardApplicable(address _rewardToken)
        public
        view
        returns (uint256)
    {
        uint256 periodFinish = rewardData[_rewardToken].periodFinish;
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /**
     * @notice Reward amount per token
     * @dev Reward is distributed only for locks.
     * @param _rewardToken for reward
     */
    function rewardPerToken(address _rewardToken)
        public
        view
        returns (uint256 rptStored)
    {
        rptStored = rewardData[_rewardToken].rewardPerTokenStored;
        if (lockedSupplyWithMultiplier > 0) {
            uint256 newReward = lastTimeRewardApplicable(_rewardToken)
                .sub(rewardData[_rewardToken].lastUpdateTime)
                .mul(rewardData[_rewardToken].rewardPerSecond);
            rptStored = rptStored.add(
                newReward.mul(1e18).div(lockedSupplyWithMultiplier)
            );
        }
    }

    /**
     * @notice Address and claimable amount of all reward tokens for the given account.
     * @param account for rewards
     */
    function claimableRewards(address account)
        public
        view
        override
        returns (IMultiFeeDistribution.RewardData[] memory rewardsData)
    {
        rewardsData = new IMultiFeeDistribution.RewardData[](rewardTokens.length);
        for (uint256 i = 0; i < rewardsData.length; i++) {
            rewardsData[i].token = rewardTokens[i];
            rewardsData[i].amount = _earned(
                account,
                rewardsData[i].token,
                balances[account].lockedWithMultiplier,
                rewardPerToken(rewardsData[i].token)
            ).div(1e12);
        }
        return rewardsData;
    }

    /********************** Operate functions ***********************/

    /**
     * @notice Stake tokens to receive rewards.
     * @dev Locked tokens cannot be withdrawn for DEFAULT_LOCK_DURATION and are eligible to receive rewards.
     */
    function stake(
        uint256 amount,
        address onBehalfOf,
        uint256 typeIndex
    ) public override {
        require(amount > 0, "Cannot stake 0");
        _stake(amount, onBehalfOf, typeIndex, false);
    }

    function _stake(
        uint256 amount,
        address onBehalfOf,
        uint256 typeIndex,
        bool isRelock
    ) internal {

        require(typeIndex < lockPeriod.length, "Invalid lock type");

        incentivesController.beforeLockUpdate(onBehalfOf);

        _updateReward(onBehalfOf);

        uint256 transferAmount = amount;
        if (onBehalfOf == msg.sender || msg.sender == lockZapAddr) {
            uint256 withdrawnAmt;
            if (!autoRelockDisabled[onBehalfOf]) {
                withdrawnAmt = _withdrawExpiredLocksFor(
                    onBehalfOf,
                    true,
                    false
                );
                amount = amount.add(withdrawnAmt);
            } else {
                _withdrawExpiredLocksFor(onBehalfOf, true, true);
            }
        }

        Balances storage bal = balances[onBehalfOf];
        bal.total = bal.total.add(amount);
        totalSupply = totalSupply.add(amount);

        bal.locked = bal.locked.add(amount);
        lockedSupply = lockedSupply.add(amount);

        bal.lockedWithMultiplier = bal.lockedWithMultiplier.add(
            amount.mul(rewardMultipliers[typeIndex])
        );
        lockedSupplyWithMultiplier = lockedSupplyWithMultiplier.add(
            amount.mul(rewardMultipliers[typeIndex])
        );

        uint256 unlockTime = block.timestamp.add(lockPeriod[typeIndex]);
        LockedBalance[] storage lockings = userLocks[onBehalfOf];
        lockings.push(
            LockedBalance({
                amount: amount,
                unlockTime: unlockTime,
                multiplier: rewardMultipliers[typeIndex],
                duration: lockPeriod[typeIndex]
            })
        );

        _addToList(onBehalfOf);

        if (!isRelock) {
            stakingToken.safeTransferFrom(
                msg.sender,
                address(this),
                transferAmount
            );
        }

        _updatePriceProvider();

        incentivesController.afterLockUpdate(onBehalfOf);

        emit Staked(onBehalfOf, amount, true);
    }

    /**
     * @notice Add to earnings
     * @dev Minted tokens receive rewards normally but incur a 50% penalty when
     *  withdrawn before DEFAULT_LOCK_DURATION has passed.
     */
    function mint(
        address user,
        uint256 amount,
        bool withPenalty
    ) external override {
        require(minters[msg.sender], "!minter");
        if (amount == 0) return;

        _updateReward(user);

        if (user == address(this)) {
            // minting to this contract adds the new tokens as incentives for lockers
            _notifyReward(address(rdntToken), amount);
            return;
        }

        Balances storage bal = balances[user];
        bal.total = bal.total.add(amount);
        totalSupply = totalSupply.add(amount);
        if (withPenalty) {
            bal.earned = bal.earned.add(amount);
            LockedBalance[] storage earnings = userEarnings[user];
            uint256 unlockTime = block.timestamp.add(DEFAULT_LOCK_DURATION);
            earnings.push(
                LockedBalance({
                    amount: amount,
                    unlockTime: unlockTime,
                    multiplier: DEFAULT_MUTLIPLIER,
                    duration: DEFAULT_LOCK_DURATION
                })
            );
        } else {
            bal.unlocked = bal.unlocked.add(amount);
        }
        _updatePriceProvider();
        emit Staked(user, amount, false);
    }

    /**
     * @notice Withdraw tokens from earnings and unlocked.
     * @dev First withdraws unlocked tokens, then earned tokens. Withdrawing earned tokens
     *  incurs a 50% penalty which is distributed based on locked balances.
     */
    function withdraw(uint256 amount) external {
        address _address = msg.sender;
        require(amount != 0, "Cannot withdraw 0");

        uint256 penaltyAmount;
        uint256 burnAmount;
        Balances storage bal = balances[_address];

        if (amount <= bal.unlocked) {
            bal.unlocked = bal.unlocked.sub(amount);
        } else {
            uint256 remaining = amount.sub(bal.unlocked);
            require(bal.earned >= remaining, "Insufficient unlocked balance");
            bal.unlocked = 0;
            uint256 sumEarned = bal.earned;
            uint256 i;
            for (i = 0; ; i++) {
                uint256 earnedAmount = userEarnings[_address][i].amount;
                if (earnedAmount == 0) continue;

                uint256 penaltyFactor;
                uint256 unlockTime = userEarnings[_address][i].unlockTime;
                if (unlockTime > block.timestamp) {
                    // 90% on day 1, decays to 25% on day 90
                    penaltyFactor = unlockTime
                        .sub(block.timestamp)
                        .mul(HALF)
                        .div(DEFAULT_LOCK_DURATION)
                        .add(QUART); // 25% + timeLeft/DEFAULT_LOCK_DURATION * 65%
                }

                // Amount required from this lock, taking into account the penalty
                uint256 requiredAmount = remaining.mul(WHOLE).div(
                    WHOLE.sub(penaltyFactor)
                );
                if (requiredAmount >= earnedAmount) {
                    requiredAmount = earnedAmount;
                    remaining = remaining.sub(
                        earnedAmount.mul(WHOLE.sub(penaltyFactor)).div(WHOLE)
                    ); // remaining -= earned * (1 - pentaltyFactor)
                } else {
                    userEarnings[_address][i].amount = earnedAmount.sub(
                        requiredAmount
                    );
                    remaining = 0;
                }
                sumEarned = sumEarned.sub(requiredAmount);

                penaltyAmount = penaltyAmount.add(
                    requiredAmount.mul(penaltyFactor).div(WHOLE)
                ); // penalty += amount * penaltyFactor
                burnAmount = burnAmount.add(penaltyAmount.mul(BURN).div(WHOLE)); // burn += penalty * burnFactor

                if (remaining == 0) {
                    break;
                } else {
                    require(sumEarned != 0, "Insufficient balance");
                }
            }
            if(i > 0) {
                for (uint256 j = i; j < userEarnings[_address].length; j++) {
                    userEarnings[_address][j - i] = userEarnings[_address][j];
                }
                for (uint256 j = 0; j < i; j++) {
                    userEarnings[_address].pop();
                }
            }
            bal.earned = sumEarned;
        }

        // Update values
        bal.total = bal.total.sub(amount).sub(penaltyAmount);

        _withdrawTokens(_address, amount, penaltyAmount, burnAmount, false);
    }

    function ieeWithdrawableBalances(address user, uint256 unlockTime)
        internal
        view
        returns (
            uint256 amount,
            uint256 penaltyAmount,
            uint256 burnAmount,
            uint256 index
        )
    {
        for (uint256 i = 0; i < userEarnings[user].length; i++) {
            if (userEarnings[user][i].unlockTime == unlockTime) {
                uint256 earnedAmount = userEarnings[user][i].amount;
                uint256 penaltyFactor;
                // 90% on day 1, decays to 25% on day 90
                penaltyFactor = unlockTime
                    .sub(block.timestamp)
                    .mul(HALF)
                    .div(DEFAULT_LOCK_DURATION)
                    .add(QUART); // 25% + timeLeft/DEFAULT_LOCK_DURATION * 65%

                penaltyAmount = earnedAmount.mul(penaltyFactor).div(WHOLE);
                burnAmount = penaltyAmount.mul(BURN).div(WHOLE);
                amount = earnedAmount.sub(penaltyAmount);
                index = i;
                break;
            }
        }
    }

    /**
     * @notice Withdraw individual unlocked balance and earnings, optionally claim pending rewards.
     */
    function individualEarlyExit(bool claimRewards, uint256 unlockTime)
        external
    {
        address onBehalfOf = msg.sender;
        require(unlockTime > block.timestamp, "Already unlocked.");
        (
            uint256 amount,
            uint256 penaltyAmount,
            uint256 burnAmount,
            uint256 index
        ) = ieeWithdrawableBalances(onBehalfOf, unlockTime);

        for (uint256 i = index + 1; i < userEarnings[onBehalfOf].length; i++) {
            userEarnings[onBehalfOf][i - 1] = userEarnings[onBehalfOf][i];
        }

        Balances storage bal = balances[onBehalfOf];
        bal.total = bal.total.sub(amount).sub(penaltyAmount);
        bal.earned = bal.earned.sub(amount).sub(penaltyAmount);

        _withdrawTokens(
            onBehalfOf,
            amount,
            penaltyAmount,
            burnAmount,
            claimRewards
        );
    }

    /**
     * @notice Withdraw full unlocked balance and earnings, optionally claim pending rewards.
     */
    function exit(bool claimRewards) external override {
        address onBehalfOf = msg.sender;
        (
            uint256 amount,
            uint256 penaltyAmount,
            uint256 burnAmount
        ) = withdrawableBalance(onBehalfOf);

        delete userEarnings[onBehalfOf];

        Balances storage bal = balances[onBehalfOf];
        bal.total = bal.total.sub(bal.unlocked).sub(bal.earned);
        bal.unlocked = 0;
        bal.earned = 0;

        _withdrawTokens(
            onBehalfOf,
            amount,
            penaltyAmount,
            burnAmount,
            claimRewards
        );
    }

    /**
     * @notice Claim all pending staking rewards.
     */
    function getReward(address[] memory _rewardTokens) public {
        _updateReward(msg.sender);
        _getReward(msg.sender, _rewardTokens);
        // todo: only update if has locks
        lastClaimTime[msg.sender] = block.timestamp;
    }

    /**
     * @notice Claim all pending staking rewards.
     */
    function getAllRewards() public {
        return getReward(rewardTokens);
    }

    /**
     * @notice Calculate earnings.
     */
    function _earned(
        address _user,
        address _rewardToken,
        uint256 _balance,
        uint256 _currentRewardPerToken
    ) internal view returns (uint256 earnings) {
        earnings = rewards[_user][_rewardToken];
        uint256 realRPT = _currentRewardPerToken.sub(
            userRewardPerTokenPaid[_user][_rewardToken]
        );
        earnings = earnings.add(_balance.mul(realRPT).div(1e18));
    }

    /**
     * @notice Update user reward info.
     */
    function _updateReward(address account) internal {
        uint256 balance = balances[account].lockedWithMultiplier;
        uint256 length = rewardTokens.length;
        for (uint256 i = 0; i < length; i++) {
            address token = rewardTokens[i];
            uint256 rpt = rewardPerToken(token);

            Reward storage r = rewardData[token];
            r.rewardPerTokenStored = rpt;
            r.lastUpdateTime = lastTimeRewardApplicable(token);

            if (account != address(this)) {
                rewards[account][token] = _earned(account, token, balance, rpt);
                userRewardPerTokenPaid[account][token] = rpt;
            }
        }
    }

    /**
     * @notice Add new reward.
     * @dev If prev reward period is not done, then it resets `rewardPerSecond` and restarts period
     */
    function _notifyReward(address _rewardToken, uint256 reward) internal {
        Reward storage r = rewardData[_rewardToken];
        if (block.timestamp >= r.periodFinish) {
            r.rewardPerSecond = reward.mul(1e12).div(REWARDS_DURATION);
        } else {
            uint256 remaining = r.periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(r.rewardPerSecond).div(1e12);
            r.rewardPerSecond = reward.add(leftover).mul(1e12).div(
                REWARDS_DURATION
            );
        }

        r.lastUpdateTime = block.timestamp;
        r.periodFinish = block.timestamp.add(REWARDS_DURATION);
        r.balance = r.balance.add(reward);
    }

    /**
     * @notice Notify unseen rewards.
     * @dev for rewards other than stakingToken, every 24 hours we check if new
     *  rewards were sent to the contract or accrued via aToken interest.
     */
    function _notifyUnseenReward(address token) internal {
        require(token != address(0), "Not a valid address");
        if (token == address(rdntToken)) {
            return;
        }
        Reward storage r = rewardData[token];
        uint256 periodFinish = r.periodFinish;
        require(periodFinish != 0, "Unknown reward token");
        if (
            periodFinish <
            block.timestamp.add(REWARDS_DURATION - REWARDS_LOOKBACK)
        ) {
            uint256 unseen = IERC20(token).balanceOf(address(this)).sub(
                r.balance
            );
            if (unseen > 0) {
                _notifyReward(token, unseen);
            }
        }
    }

    /**
     * @notice User gets reward
     */
    function _getReward(address _user, address[] memory _rewardTokens)
        internal
    {
        middleFeeDistribution.forwardReward(_rewardTokens);
        uint256 length = _rewardTokens.length;
        for (uint256 i; i < length; i++) {
            address token = _rewardTokens[i];
            _notifyUnseenReward(token);
            uint256 reward = rewards[_user][token].div(1e12);
            if (reward > 0) {
                rewards[_user][token] = 0;
                rewardData[token].balance = rewardData[token].balance.sub(
                    reward
                );

                IERC20(token).safeTransfer(_user, reward);

                emit RewardPaid(_user, token, reward);
            }
        }
        _updatePriceProvider();
    }

    /**
     * @notice Withdraw tokens from MFD
     */
    function _withdrawTokens(
        address onBehalfOf,
        uint256 amount,
        uint256 penaltyAmount,
        uint256 burnAmount,
        bool claimRewards
    ) internal {
        require(onBehalfOf == msg.sender);
        _updateReward(onBehalfOf);

        totalSupply = totalSupply.sub(amount).sub(penaltyAmount);

        rdntToken.safeTransfer(onBehalfOf, amount);
        if (penaltyAmount > 0) {
            if (burnAmount > 0) {
                rdntToken.burn(burnAmount);
                burnedSupply = burnedSupply.add(burnAmount);
            }
            rdntToken.safeTransfer(daoTreasury, penaltyAmount.sub(burnAmount));
        }

        if (claimRewards) {
            _getReward(onBehalfOf, rewardTokens);
        }

        emit Withdrawn(
            onBehalfOf,
            address(rdntToken),
            amount,
            penaltyAmount,
            burnAmount
        );
        _updatePriceProvider();
    }

    /********************** Eligibility + Disqualification ***********************/

    /**
     * @notice Bounty amount of user per each reward token
     * @dev Reward is RDNT and rTokens
     */
    function bountyForUser(address _user)
        public
        view
        override
        returns (IMultiFeeDistribution.RewardData[] memory bounties)
    {
        uint256 percentOver = _getIneligiblePercent(_user);

        IMultiFeeDistribution.RewardData[]
            memory pendingRewards = claimableRewards(_user);
        bounties = new IMultiFeeDistribution.RewardData[](
            pendingRewards.length
        );

        for (uint256 i = 0; i < pendingRewards.length; i++) {
            address token = pendingRewards[i].token;
            uint256 amount = pendingRewards[i].amount;

            bounties[i].token = token;
            // > 100% ineligible time
            if (percentOver > 10000) {
                bounties[i].amount = amount;
            } else {
                bounties[i].amount = amount.mul(percentOver).div(10000);
            }
        }
    }

    /**
     * @notice Disqualify user
     * @dev Reward is RDNT and rTokens
     */
    function disqualifyUser(address _user, address)
        public
        override
        returns (IMultiFeeDistribution.RewardData[] memory bounties)
    {
        require(msg.sender == address(disqualifier), "!disqualifier");
        _updateReward(_user);

        uint256 length = rewardTokens.length;
        bounties = bountyForUser(_user);

        for (uint256 i; i < length; i++) {
            address token = bounties[i].token;
            uint256 penalty = bounties[i].amount;
            uint256 reward = rewards[_user][token].div(1e12);
            if (penalty != 0) {
                uint256 newUserBal;
                if (reward < penalty) {
                    newUserBal = 0;
                    penalty = reward;
                } else {
                    newUserBal = reward.sub(penalty);
                }
                rewards[_user][token] = newUserBal.mul(1e12);
                rewards[address(disqualifier)][token] = rewards[
                    address(disqualifier)
                ][token].add(penalty.mul(1e12));
                emit IneligibleRewardRemoved(_user, token, reward);
            }
        }
    }

    /**
     * @notice Decide ineligble percent of the user
     */
    function _getIneligiblePercent(address _user)
        internal
        view
        returns (uint256 percentOver)
    {
        uint256 totalLockAMTxTIME;
        uint256 expiredAMTxTIME;
        uint256 LCT = lastClaimTime[_user];

        for (uint256 i = 0; i < userLocks[_user].length; i++) {
            uint256 startTime = LCT != 0
                ? LCT
                : userLocks[_user][i].unlockTime.sub(
                    userLocks[_user][i].duration
                );
            totalLockAMTxTIME = totalLockAMTxTIME.add(userLocks[_user][i].amount.mul(
                block.timestamp.sub(startTime)
            ));
            if (userLocks[_user][i].unlockTime < block.timestamp) {
                uint256 timeDiff = block.timestamp.sub(
                    userLocks[_user][i].unlockTime
                );
                expiredAMTxTIME = expiredAMTxTIME.add(timeDiff.mul(userLocks[_user][i].amount));
            }
        }
        if (totalLockAMTxTIME != 0) {
            percentOver = expiredAMTxTIME.mul(10000).div(totalLockAMTxTIME);
        }
    }

    /**
     * @notice Withdraw all lockings tokens where the unlock time has passed
     */
    function _cleanWithdrawableLocks(
        address user,
        uint256 totalLock,
        uint256 totalLockWithMultiplier
    ) internal returns (uint256 lockAmount, uint256 lockAmountWithMultiplier) {
        LockedBalance[] storage locks = userLocks[user];

        if (locks.length != 0) {
            uint256 length = locks.length <= maxLockWithdrawPerTxn ? locks.length : maxLockWithdrawPerTxn;
            for (uint256 i = 0; i < length; ) {
                if (locks[i].unlockTime <= block.timestamp) {
                    lockAmount = lockAmount.add(locks[i].amount);
                    lockAmountWithMultiplier = lockAmountWithMultiplier.add(
                        locks[i].amount.mul(locks[i].multiplier)
                    );
                    locks[i] = locks[locks.length - 1];
                    locks.pop();
                    length = length - 1;
                } else {
                    i = i + 1;
                }
            }
            if (locks.length == 0) {
                lockAmount = totalLock;
                lockAmountWithMultiplier = totalLockWithMultiplier;
                delete userLocks[user];

                _removeFromList(user);
            }
        }
    }

    /**
     * @notice Withdraw all currently locked tokens where the unlock time has passed.
     * @param _address of the user.
     */
    function _withdrawExpiredLocksFor(
        address _address,
        bool isRelockAction,
        bool doTransfer
    ) internal returns (uint256) {
        incentivesController.beforeLockUpdate(_address);
        _updateReward(_address);

        Balances storage bal = balances[_address];
        (
            uint256 amount,
            uint256 amountWithMultiplier
        ) = _cleanWithdrawableLocks(
                _address,
                bal.locked,
                bal.lockedWithMultiplier
            );
        bal.locked = bal.locked.sub(amount);
        bal.lockedWithMultiplier = bal.lockedWithMultiplier.sub(
            amountWithMultiplier
        );
        bal.total = bal.total.sub(amount);
        totalSupply = totalSupply.sub(amount);
        lockedSupply = lockedSupply.sub(amount);
        lockedSupplyWithMultiplier = lockedSupplyWithMultiplier.sub(
            amountWithMultiplier
        );
        incentivesController.afterLockUpdate(_address);

        if (!isRelockAction && !autoRelockDisabled[_address]) {
            _stake(amount, _address, defaultLockIndex[_address], true);
        } else {
            if (doTransfer) {
                stakingToken.safeTransfer(_address, amount);
                emit Withdrawn(_address, address(stakingToken), amount, 0, 0);
            }
        }
        return amount;
    }

    /**
     * @notice Withdraw all currently locked tokens where the unlock time has passed.
     */
    function withdrawExpiredLocks() external {
        withdrawExpiredLocksFor(msg.sender);
    }

    function withdrawExpiredLocksFor(address _address)
        public
        override
        returns (uint256)
    {
        return _withdrawExpiredLocksFor(_address, false, true);
    }

    function bulkWithdrawExpiredLocksFor(address[] memory users) external {
        for (uint256 i = 0; i < users.length; i += 1) {
            withdrawExpiredLocksFor(users[i]);
        }
    }

    function withdrawExpiredLocksWithoutRelockFor(address _address) public returns (uint256) {
        return _withdrawExpiredLocksFor(_address, true, true);
    }

    function zapVestingToLp(address _user) external override returns(uint256 total) {
        require(msg.sender == lockZapAddr, "!lockzap");
        (total, , ) = earnedBalances(_user);

        rdntToken.safeTransfer(lockZapAddr, total);

        delete userEarnings[_user];
        Balances storage bal = balances[_user];
        bal.earned = 0;

        return total;
    }

    function getLastClaimTime(address _user) public override view returns (uint256) {
        return lastClaimTime[_user];
    }

    function claimFromConverter(address onBehalf) public override {
        require(msg.sender == rewardConverter, "!converter");
        _updateReward(onBehalf);
        middleFeeDistribution.forwardReward(rewardTokens);
        uint256 length = rewardTokens.length;
        for (uint256 i; i < length; i++) {
            address token = rewardTokens[i];
            _notifyUnseenReward(token);
            uint256 reward = rewards[onBehalf][token].div(1e12);
            if (reward > 0) {
                rewards[onBehalf][token] = 0;
                rewardData[token].balance = rewardData[token].balance.sub(
                    reward
                );

                IERC20(token).safeTransfer(rewardConverter, reward);
                emit RewardPaid(onBehalf, token, reward);
            }
        }
        _updatePriceProvider();
        lastClaimTime[onBehalf] = block.timestamp;
    }

    /********************** Lockers list ***********************/

    function _addToList(address user) internal {
        if (inserted[user] == false) {
            inserted[user] = true;
            indexOf[user] = userlist.length;
            userlist.push(user);
        }
    }

    function _removeFromList(address user) internal {
        assert(inserted[user] == true);

        delete inserted[user];

        uint256 index = indexOf[user];
        uint256 lastIndex = userlist.length - 1;
        address lastUser = userlist[lastIndex];

        indexOf[lastUser] = index;
        delete indexOf[user];

        userlist[index] = lastUser;
        userlist.pop();
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IChefIncentivesController {

  /**
   * @dev Called by the corresponding asset on any update that affects the rewards distribution
   * @param user The address of the user
   **/
  function handleActionBefore(
    address user
  ) external;

  /**
   * @dev Called by the corresponding asset on any update that affects the rewards distribution
   * @param user The address of the user
   * @param userBalance The balance of the user of the asset in the lending pool
   * @param totalSupply The total supply of the asset in the lending pool
   **/
  function handleActionAfter(
    address user,
    uint256 userBalance,
    uint256 totalSupply
  ) external;

  /**
   * @dev Called by the locking contracts after locking or unlocking happens
   * @param user The address of the user
   **/
  function beforeLockUpdate(address user) external;

  /**
    * @notice Hook for lock update.
    * @dev Called by the locking contracts after locking or unlocking happens
    */
  function afterLockUpdate(address _user) external;

  function addPool(address _token, uint256 _allocPoint) external;

  function claim(address _user, address[] calldata _tokens) external;

  function setClaimReceiver(address _user, address _receiver) external;
  function getRegisteredTokens () external view returns (address[] memory);
  function disqualifyUser(address _user, address _hunter) external returns (uint256 bounty);
  function bountyForUser(address _user) external view returns (uint256 bounty);

  function allPendingRewards(address _user) external view returns (uint256 pending);
  function claimAll(address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

struct LockedBalance {
    uint256 amount;
    uint256 unlockTime;
    uint256 multiplier;
    uint256 duration;
}

struct EarnedBalance {
    uint256 amount;
    uint256 unlockTime;
    uint256 penalty;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "./LockedBalance.sol";

interface IFeeDistribution {
    function addReward(address rewardsToken) external;
    function mint(address user, uint256 amount, bool withPenalty) external;
    function lockedBalances(address user) external view returns (uint256, uint256, uint256, uint256, LockedBalance[] memory);
}

interface IMultiFeeDistribution is IFeeDistribution {
    
    struct RewardData {
        address token;
        uint256 amount;
    }

    
    function exit(bool claimRewards) external;
    function stake(uint256 amount, address onBehalfOf, uint256 typeIndex) external;
    function lockInfo(address user) external view returns (LockedBalance[] memory);
    function getDefaultRelockTypeIndex(address _user) external view returns (uint256);
    function hasAutoRelockDisabled(address user) external view returns (bool);
    function totalBalance(address user) external view returns (uint256);
    function getMFDstatsAddress () external view returns (address);
    function zapVestingToLp (address _address) external returns (uint256);
    function getUsers(uint256 page, uint256 limit) external view returns (address[] memory);
    function lockersCount() external view returns (uint256);
    function withdrawExpiredLocksFor(address _address) external returns (uint256);
    function getLastClaimTime(address _user) external view returns (uint256);
    function disqualifyUser(address _user, address hunter) external returns (IMultiFeeDistribution.RewardData[] memory bounties);
    function claimFromConverter(address) external;
    function bountyForUser(address _user) external view returns (IMultiFeeDistribution.RewardData[] memory bounties);
    function claimableRewards(address account) external view returns (IMultiFeeDistribution.RewardData[] memory rewards);
    function setAutocompound(bool _newVal) external;
    function getAutocompoundEnabled(address _user) external view returns(bool);
    function autocompound(address _user) external;
    function setDefaultRelockTypeIndex(uint256 _index) external;
    function daoTreasury() external view returns (address);
    function getStakingTokenAddress() external view returns (address);
}

interface IMiddleFeeDistribution is IFeeDistribution {
    function forwardReward(address[] memory _rewardTokens) external;
    function getMFDstatsAddress () external view returns (address);
    function lpLockingRewardRatio () external view returns (uint256);
    function getRdntTokenAddress () external view returns (address);
    function getLPFeeDistributionAddress () external view returns (address);
    function getMultiFeeDistributionAddress () external view returns (address);
    function operationExpenseRatio () external view returns (uint256);
    function operationExpenses () external view returns (address);
}

// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.7.6;

import "../dependencies/openzeppelin/contracts/IERC20.sol";

interface IMintableToken is IERC20 {
    function mint(address _receiver, uint256 _amount) external returns (bool);
    function burn(uint256 _amount) external returns (bool);
    function setMinter(address _minter) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IPriceProvider {
    function getTokenPrice(bool _useDelay) external view returns (uint256);
    function getTokenPriceUsd(bool _useDelay) external view returns (uint256);
    function getLpTokenPrice(bool _useDelay) external view returns (uint256);
    function getLpTokenPriceUsd(bool _useDelay) external view returns (uint256);
    function decimals() external view returns (uint256);
    function update() external;
    function baseTokenPriceInUsdProxyAggregator() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IAutoCompounder {
    function swapRewardsToLp() external returns (uint256 liquidity);
    function swapRewardsToLpForUser(address _user) external returns (uint256 liquidity);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IDisqualifier {
    function processUser(address _user, bool _withdrawLocks) external returns (uint256 bounty);
    function getBaseBounty() external view returns (uint256 bounty);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

library AddressPagination {
    function paginate(
        address[] memory array,
        uint256 page,
        uint256 limit
    ) internal pure returns (address[] memory result) {
        result = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            if (page * limit + i >= array.length) {
                result[i] = address(0);
            } else {
                result[i] = array[page * limit + i];
            }
        }
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

  function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {Address} from './Address.sol';

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        //solium-disable-next-line
        assembly {
            cs := extcodesize(address())
        }
        return cs == 0;
    }

    modifier onlyInitializing() {
        require(initializing, "Initializable: contract is not initializing");
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

import {IERC20} from './IERC20.sol';

interface IERC20Detailed is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

import "./Initializable.sol";
import "./ContextUpgradeable.sol";

contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

import "./Initializable.sol";

contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    uint256[50] private __gap;
}