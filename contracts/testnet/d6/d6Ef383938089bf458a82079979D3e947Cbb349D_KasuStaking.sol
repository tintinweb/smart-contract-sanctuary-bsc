// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./GenericTokenStaking.sol";
import "./MyToken.sol";

contract KasuStaking is GenericTokenStaking {

    function initialize(address tokenAddress, IStakingUtil util) external initializer whenNotPaused {
        GenericTokenStaking.init(util);
        stakingToken = IERC20(tokenAddress);
        //
        // set bonus and pre penalty pool balances
        MyToken token = MyToken(tokenAddress);
        bonusPoolBalance = token.getAmountMintedForBonusPool();
        prePenaltyPoolBalance = token.getAmountMintedForPrePenaltyPool();
    }

    // calculates the 10% of the saked amount, and transfers that amount of tokens from the prePenaltyPool to the penaltyPool (until the prePenaltyPool runs out)
    function pumpPenaltyPool(uint256 amount) internal override {
        uint8 pumpPercentage = stakingUtil.getPumpPenaltyPoolPercentage(PERCENTAGE_TO_PUMP_PENALTY_POOL); // set the percentage
        uint256 amountToTransfer = amount * pumpPercentage / 100; // get the % of the amount being staked. this is the amount to transfer to the penalty pool
        // check how much the prePenaltyPool has left
        // if it has less than the expected amount, return everything left (and update the amount variable!)
        if (amountToTransfer <= getPrePenaltyPoolBalance()) {
            // there is still enough balance
            penaltyPoolBalance = getPenaltyPoolBalance() + amountToTransfer; // increase the balance for the penaltyPool
            prePenaltyPoolBalance = getPrePenaltyPoolBalance() - amountToTransfer; // reduce the prePenaltyPool amount available
        }
        else {
            // there is not enough remaining prePenaltyPool balance, so we'll use ALL the remaining balance...
            penaltyPoolBalance = getPenaltyPoolBalance() + getPrePenaltyPoolBalance();
            prePenaltyPoolBalance = 0;
        }
    }

    function getTotalStakingTokenBalance() public override view returns (uint256) {
        return getTotalAmountStaked() + getBonusPoolBalance() + getPrePenaltyPoolBalance() + 
            getPenaltyPoolBalance() + getDevPoolBalance() + getAdsPoolBalance() + getCharityPoolBalance();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * The size of the __gap array is calculated so that the amount of storage used by a 
     * contract always adds up to the same number (in this case 50 storage slots).
     * Note: the compiler does not reserve a storage slot for constants
     */
    uint256[43] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./StakingUtil.sol";
import "./util/Helper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

library Library  {
    struct Staker {
        uint256 dayStartedStaking; // aka sinceBlockNumber
        uint256 initialStakedAmount; // initial staked amount
        uint256 stakedAmount; // initial staked amount + bonus (if applicable).
        bool exists;
        //
        uint256 lockupPeriodEnd; 
    }

    // struct to use in a division with the objective to keep as many decimal points as possible
    struct FloatingPointValue {
        // to get the actual value (with decimal points) divide the valueMultiplied by the multiplier
        uint256 valueMultiplied; // the value multiplied by the multiplier
        uint256 multiplier; // the value of the multiplier
    }
}

abstract contract GenericTokenStaking is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    // usings
    using Library for Library.Staker;
    using Library for Library.FloatingPointValue;

    // constants
    // penalty to pay
    uint8 private constant INITIAL_PENALTY_PERCENTAGE = 15; // this is the max penalty percentage to pay (at the beginning)
    uint8 private constant MONTHLY_PENALTY_PERCENTAGE_DISCOUNT = 1; // this is how much (in percentage) the penalty percentage reduces per month (it has to be a full month though)
    uint8 private constant MINIMUM_PENALTY_PERCENTAGE = 3; // this is the minimum penalty percentage to pay 
    // rewards to get
    uint8 private constant DAILY_PERCENTAGE_DISCOUNT = 1; // this is how much (in %) more of your rewards you will get waiting 1 more day (after 100 days there is no difference)
    uint256 public constant MULTIPLIED_FOR_5_DECIMAL_POINTS = 1e5; //100000
    // pump penalty pool by a percentage from the staking amount (when someone stakes), until the pre penalty pool runs out
    uint8 public constant PERCENTAGE_TO_PUMP_PENALTY_POOL = 10;
    uint256 internal constant ONE_WEEK_IN_MS = 604800000; // 1 week in milliseconds
    uint256 internal constant TWO_WEEKS_IN_MS = 1209600000; // 2 weeks in milliseconds

    // variables 
    // business logic
    uint256 private _totalAmountStaked;
    uint256 private _totalNumberOfStakers;
    uint256 private _previousTotalAmountStaked;
    uint256 private _totalCoinsOverTime;
    uint256 private _lastDayTotalCoinsOverTimeCalculation; // aka _lastBlockNumberTotalCoinsOverTimeCalculation
    mapping(address => Library.Staker) internal allStakers;
    // Pools (Bonus, Penalty, Dev, Ads, Charity)
    uint256 internal bonusPoolBalance;
    uint256 internal prePenaltyPoolBalance; // balance to use to automatically keep refilling the penalty pool (until it runs out)
    uint256 internal penaltyPoolBalance; // the actual penalty pool balance
    uint256 private _devPoolBalance;
    uint256 private _adsPoolBalance;
    uint256 private _charityPoolBalance;
    //
    // other variables
    IERC20 internal stakingToken;
    IStakingUtil internal stakingUtil;
    // Pause / Unpause
    bool private _paused;
    uint256 private _dateTimeStartedPause; // date time when contract was paused 

    // others
    Helper internal helper;

    // events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event PenaltyPaid(address indexed user, uint256 amount);
    event StakingRewardsPaid(address indexed user, uint256 amount);
    event StakingRewardsUserIsEntitledTo(address indexed user, uint256 amount);
    event LockupBonusGiven(uint256 amount);

    modifier checkLockupHasEnded() {
        require(allStakers[msg.sender].lockupPeriodEnd < stakingUtil.getBlockTimestamp(), "Lockup period has not ended yet.");
        _;
    }

    // function to be called as soon as the contract is deployed (it can be called only once)
    function init(IStakingUtil util) internal onlyInitializing {
        _totalCoinsOverTime = 0;
        //
        bonusPoolBalance = 0;
        prePenaltyPoolBalance = 0;
        penaltyPoolBalance = 0;
        _devPoolBalance = 0;
        _adsPoolBalance = 0;
        _charityPoolBalance = 0;
        _totalNumberOfStakers = 0;
        // set stakingUtil
        stakingUtil = util;
        //        
        helper = new Helper();
        //
        _paused = false;
        _dateTimeStartedPause = 0;
        //
        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    }

    function stake(uint256 amount, uint8 lockupInYears) external {
        stakeForStaker(amount, lockupInYears, msg.sender);
    }

    function stakeForStaker(uint256 amount, uint8 lockupInYears, address staker) public whenNotPaused nonReentrant {
        require(amount > 0, "Cannot stake 0");
        require(staker != address(0), "Staker address shouldn't be 0x0!");
        require(allStakers[staker].stakedAmount == 0, "staking balance has to be 0");
        require(lockupInYears <= 10, "Cannot lock for 11 years or more");
        //
        pumpPenaltyPool(amount);
        // core staking
        _previousTotalAmountStaked = _totalAmountStaked;
        allStakers[staker].dayStartedStaking = stakingUtil.getBlockTimestamp();        
        allStakers[staker].exists = true;
        allStakers[staker].initialStakedAmount = amount;
        calculateLatestTotalCoinsOverTimeWhenEntering();
        _totalNumberOfStakers = _totalNumberOfStakers + 1;
        uint256 amountPlusBonuses = handleLockupBonus(amount, lockupInYears, staker); // not part of core staking
        _totalAmountStaked = _totalAmountStaked + amountPlusBonuses;
        allStakers[staker].stakedAmount = amountPlusBonuses;
        assert(allStakers[staker].stakedAmount >= allStakers[staker].initialStakedAmount);
        // note we only send the amount as the bonus is already there. And the sender is always msg.sender (regardless of who is the staker)!
        emit Staked(staker, amountPlusBonuses);
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Error during transfer");
        //
    }    

    function unstake() external checkLockupHasEnded nonReentrant {
        require(allStakers[msg.sender].stakedAmount > 0, "staking balance has to be > 0");
        //
        calculateLatestTotalCoinsOverTimeWhenExiting();
        Library.FloatingPointValue memory percentageToGetFromPenaltyPool = getLatestPercentageToGetFromPenaltyPool(_totalCoinsOverTime);
        uint256 personalTotalCoinsOverTime = getPersonalTotalCoinsOverTime();
        _totalAmountStaked = _totalAmountStaked - allStakers[msg.sender].stakedAmount;
        _totalCoinsOverTime = _totalCoinsOverTime - personalTotalCoinsOverTime;        
        _totalNumberOfStakers = _totalNumberOfStakers - 1;
        //
        uint256 rewardsToPayToStaker = getRewardsAmountFromPenaltyPoolUpdatingBalance(percentageToGetFromPenaltyPool);
        uint256 unstakedAmountToReturnToUser = getStakedAmountSubstractingPenalty();
        uint256 totalAmountToPayToStaker = unstakedAmountToReturnToUser + rewardsToPayToStaker;
        delete allStakers[msg.sender];
        assert(allStakers[msg.sender].stakedAmount == 0);
        emit StakingRewardsPaid(msg.sender, rewardsToPayToStaker);
        emit Unstaked(msg.sender, unstakedAmountToReturnToUser);
        require(stakingToken.transfer(msg.sender, totalAmountToPayToStaker), "Error during transfer");
        assert(stakingToken.balanceOf(address(this)) >= getTotalStakingTokenBalance());
    }

    /* solhint-disable no-empty-blocks */
    function pumpPenaltyPool(uint256 amount) internal virtual {

    }
    /* solhint-enable no-empty-blocks */

    function handleLockupBonus(uint256 amount, uint8 lockupInYears, address staker) internal virtual returns (uint256) {
        uint256 amountPlusBonuses;
        if (lockupInYears > 0) {            
            allStakers[staker].lockupPeriodEnd = calculateLockupPeriodEnd(lockupInYears);
            uint256 bonusShouldGet = calculateBonus(amount, lockupInYears); // this is what should get
            uint256 bonusGot; // this is what will get (might be less as the bonus pool might not have enough)
            // check how much the bonus pool has left
            // if it has less than the expected amount, return everything left (and update the amount variable!)
            if (bonusShouldGet <= getBonusPoolBalance()) {
                bonusGot = bonusShouldGet;
                bonusPoolBalance = getBonusPoolBalance() - bonusShouldGet; //reduce the bonus amount available
            }
            else {
                // there is not enough remaining bonus balance, so we'll use ALL the remaining balance...
                bonusGot = getBonusPoolBalance();
                bonusPoolBalance = 0;
            }
            amountPlusBonuses = amount + bonusGot;
            emit LockupBonusGiven(bonusGot);
        }
        else
        {
            amountPlusBonuses = amount;
            allStakers[staker].lockupPeriodEnd = 0; // no lock-up
        }
        //
        return amountPlusBonuses;
    }

    function calculateBonus(Library.FloatingPointValue memory amount, uint8 lockupInYears) internal pure returns (uint256) {
        require(lockupInYears > 0, "lockupInYears has to be > 0");
        //
        uint8 percentage = 0;
        if (lockupInYears == 1) {
            percentage = 10;
        } else if (lockupInYears == 2)  {
            percentage = 25;
        } else if (lockupInYears == 3)  {
            percentage = 40;
        } else if (lockupInYears == 4)  {
            percentage = 60;
        } else if (lockupInYears == 5)  {
            percentage = 80;
        } else {
            percentage = 100; // lockupInYears >= 6
        }
        //
        return (amount.valueMultiplied * percentage) / 100 / amount.multiplier;
    }

    function calculateBonus(uint256 amount, uint8 lockupInYears) internal pure returns (uint256) {        
        // multiplier: 1 by default (no effect)
        Library.FloatingPointValue memory floatingPointValue = Library.FloatingPointValue({valueMultiplied: amount, multiplier: 1});
        //
        return calculateBonus(floatingPointValue, lockupInYears);
    }

    function getPersonalTotalCoinsOverTime() private view returns (uint256) {
        uint256 millisecondsSinceStartedStaking = getMillisecondsSinceStartedStaking(msg.sender);
        return millisecondsSinceStartedStaking * allStakers[msg.sender].stakedAmount;
    }

    // returns the calculated value of totalCoinsOverTime when exiting
    function calculateTotalCoinsOverTimeWhenExiting() private view returns (uint256) {
        uint256 differenceInMilliseconds = getMillisecondsDifference(getCurrentDayNumber(), _lastDayTotalCoinsOverTimeCalculation);
        uint256 totalCoinsOverTime = _totalCoinsOverTime + (differenceInMilliseconds * _totalAmountStaked);
        //
        return totalCoinsOverTime;
    }

    // returns the calculated value of totalCoinsOverTime when Entering
    function calculateTotalCoinsOverTimeWhenEntering() private view returns (uint256) {
        uint256 differenceInMilliseconds = getMillisecondsDifference(getCurrentDayNumber(), _lastDayTotalCoinsOverTimeCalculation);
        uint256 totalCoinsOverTime = _totalCoinsOverTime + (differenceInMilliseconds * _previousTotalAmountStaked);
        //
        return totalCoinsOverTime;
    }

    // function to be called externally when the staker wants to check what's their percentage of the penalty pool they would get if unstaking
    // returns the percentage to get from penalty pool. As a FloatingPointValue type, containing the value (multiplied by a multiplier), 
    // and the multiplier value itself (so the value can be divided back)
    function getPercentageToGetFromPenaltyPool() public view returns (Library.FloatingPointValue memory) {
        require(allStakers[msg.sender].stakedAmount > 0, "staking balance has to be > 0");
        //
        // offChainTotalCoinsOverTime has the number of total coins over time, but this value is not yet persisted in the blockchain!
        uint256 offChainTotalCoinsOverTime = calculateTotalCoinsOverTimeWhenExiting();
        return getLatestPercentageToGetFromPenaltyPool(offChainTotalCoinsOverTime);
    }

    // function to be called externally when the staker wants to check what's the amount they would get if unstaking
    // returns amountToGet and isMaxRewardsPossible
    // amountToGet is the amount the user would get if unstaking (approximate)
    // isMaxRewardsPossible defines if the user would get all the rewards they are untitled too based on the time they have been staking
    function getAmountToGetIfUnstaking() external view returns (uint256, bool) {
        require(allStakers[msg.sender].stakedAmount > 0, "staking balance has to be > 0");
        //
        uint256 stakedAmount = allStakers[msg.sender].stakedAmount;
        uint256 penaltyToPay = stakedAmount * calculatePercentageForPenaltyToPay() / 100;
        (uint256 rewardsToPayToStaker, uint256 rewardsStakerIsEntitledTo) = getRewardsAmountFromPenaltyPool(getPercentageToGetFromPenaltyPool());
        uint256 amountToGet = stakedAmount - penaltyToPay + rewardsToPayToStaker;
        bool isMaxRewardsPossible = rewardsToPayToStaker == rewardsStakerIsEntitledTo;
        //
        return (amountToGet, isMaxRewardsPossible);
    }

    // This method calculates and gets the amount of rewards (from penalty pool) to pay the staker
    function getRewardsAmountFromPenaltyPoolUpdatingBalance(Library.FloatingPointValue memory percentageToGetFromPenaltyPool) private returns (uint256) {
        (uint256 rewardsToPayToStaker, uint256 rewardsStakerIsEntitledTo) = getRewardsAmountFromPenaltyPool(percentageToGetFromPenaltyPool);
        //
        penaltyPoolBalance = getPenaltyPoolBalance() - rewardsToPayToStaker;
        emit StakingRewardsUserIsEntitledTo(msg.sender, rewardsStakerIsEntitledTo / percentageToGetFromPenaltyPool.multiplier / 100);
        //
        return rewardsToPayToStaker;
    }

    // returns a tuple of rewardsToPayToStaker / rewardsStakerIsEntitledTo
    // rewardsStakerIsEntitledTo is what the user should get (without taking into account the % of rewards to get)
    // rewardsToPayToStaker is what the user will actually get
    function getRewardsAmountFromPenaltyPool(Library.FloatingPointValue memory percentageToGetFromPenaltyPool) public view returns (uint256, uint256) {
        require(allStakers[msg.sender].stakedAmount > 0, "staking balance has to be > 0");
        //
        uint256 rewardsStakerIsEntitledTo = getPenaltyPoolBalance() * percentageToGetFromPenaltyPool.valueMultiplied;
        uint256 percentageToGet = calculatePercentageOfRewardsToGet();
        uint256 rewardsToPayToStaker = (rewardsStakerIsEntitledTo * percentageToGet) / 100 / 100 / percentageToGetFromPenaltyPool.multiplier;
        //
        return (rewardsToPayToStaker, rewardsStakerIsEntitledTo);
    }

    // Gets the staked amount substracting the penalty to pay for unstaking
    function getStakedAmountSubstractingPenalty() private returns (uint256) {
        // from the penalty paid:
        // 75% goes to penalty pool
        // 20% to dev fund
        // 3% to ads
        // 2% for charity
        uint256 stakedAmount = allStakers[msg.sender].stakedAmount;
        uint256 penaltyPercentageToPay = calculatePercentageForPenaltyToPay();
        uint256 penaltyToPay = stakedAmount * penaltyPercentageToPay;
        uint256 amountToPayToStaker = stakedAmount - (penaltyToPay / 100);
        //
        uint256 amountForPenaltyPoolBalance = (penaltyToPay * getPercentageAllocationForPenaltyPool()) / 100 / 100;
        uint256 amountForDevPoolBalance = (penaltyToPay * getPercentageAllocationForDevPool()) / 100 / 100;
        uint256 amountForAdsPoolBalance = (penaltyToPay * getPercentageAllocationForAdsPool()) / 100 / 100;
        uint256 amountForCharityPoolBalance = (penaltyToPay * getPercentageAllocationForCharityPool()) / 100 / 100;
        penaltyPoolBalance = getPenaltyPoolBalance() + amountForPenaltyPoolBalance;
        _devPoolBalance = getDevPoolBalance() + amountForDevPoolBalance;
        _adsPoolBalance = getAdsPoolBalance() + amountForAdsPoolBalance;
        _charityPoolBalance = getCharityPoolBalance() + amountForCharityPoolBalance;
        //
        emit PenaltyPaid(msg.sender, (penaltyToPay / 100));
        //
        return amountToPayToStaker;
    }
    
    // make it public so people can check what's the percentage they would get discounted from their rewards if they unstake
    function calculatePercentageOfRewardsToGet() public view returns (uint256) {      
        // initially the staker would get 0% of the rewards (if they unstake and have rewards)
        // this percentage keeps increasing 1% daily until it reaches 100%, when they can get all the rewards they are entitled to

        // divide the result of getDaysSinceStartedStaking by 100000 (getDaysSinceStartedStaking returns the number of days multiplied by 100000 to support 5 decimal points)
        uint256 percentageToGet = getDaysSinceStartedStaking(msg.sender) * DAILY_PERCENTAGE_DISCOUNT / MULTIPLIED_FOR_5_DECIMAL_POINTS;
        //
        if (percentageToGet < 100)
            return percentageToGet;
        else
            return 100; // 100 is the max! 
    }

    // make it public so people can check what's the percentage they would pay if they unstake
    function calculatePercentageForPenaltyToPay() public view returns (uint256) {      
        // reducing 12%  per year
        // reducing ~ 1% per month

        uint256 monthlyDiscount = MONTHLY_PENALTY_PERCENTAGE_DISCOUNT;
        uint256 discountToApply = getMonthsSinceStartedStaking(msg.sender) * monthlyDiscount;
        if (discountToApply > INITIAL_PENALTY_PERCENTAGE) {
            return MINIMUM_PENALTY_PERCENTAGE;
        }            
        else {
            uint256 penaltyPercentage = INITIAL_PENALTY_PERCENTAGE - discountToApply;
            //
            if (penaltyPercentage > MINIMUM_PENALTY_PERCENTAGE)
                return penaltyPercentage;
            else
                return MINIMUM_PENALTY_PERCENTAGE;
        }
    }

    // returns the percentage to get from penalty pool (multiplied by a dynamic value so we can get up as many decimal points as possible. This is the 1st value)
    // and the multiplier used (2nd value). So we can divide the value and get the correct decimal points
    function getLatestPercentageToGetFromPenaltyPool(uint256 totalCoinsOverTime) private view returns (Library.FloatingPointValue memory) {
        uint256 multiplierForDecimalPoints = helper.findOptimumMultiplier(getPersonalTotalCoinsOverTime() * 100);
        uint256 percentageToGetFromPenaltyPool = (getPersonalTotalCoinsOverTime() * 100 * multiplierForDecimalPoints) / totalCoinsOverTime;
        assert(percentageToGetFromPenaltyPool / multiplierForDecimalPoints <= 100); // assert the % to get from penalty pool is always <= 100
        //
        return Library.FloatingPointValue({valueMultiplied: percentageToGetFromPenaltyPool, multiplier: multiplierForDecimalPoints});
    }

    function getMonthsSinceStartedStaking(address account) public view returns (uint256) {
        // we consider that a month has 30.44 days
        // we have to divide by 3044000 as getDaysSinceStartedStaking already returns a value multiplied by 100000
        return getDaysSinceStartedStaking(account) / 3044000; // 30.44 * MULTIPLIED_FOR_5_DECIMAL_POINTS =  3044000
    }

    // returns the number of days since started staking (multiplied by 100 to support 2 decimal points) 
    function getDaysSinceStartedStaking(address account) public view returns (uint256) {
        // multiply milliseconds by 100000 first to support 5 decimal points
        return (getMillisecondsSinceStartedStaking(account) * MULTIPLIED_FOR_5_DECIMAL_POINTS/ 1000) / 60 / 60 / 24; 
    }

    function getMillisecondsSinceStartedStaking(address account) private view returns (uint256) {
        if (allStakers[account].exists) {
            assert (stakingUtil.getBlockTimestamp() >= allStakers[account].dayStartedStaking);
            return getMillisecondsDifference(stakingUtil.getBlockTimestamp(), allStakers[account].dayStartedStaking);
        }
        else {
            return 0;
        }
    }

    function getMillisecondsDifference(uint256 timestamp1, uint256 timestamp2) private pure returns (uint256) {
        return timestamp1 - timestamp2;
    }

    function calculateLatestTotalCoinsOverTimeWhenExiting() private {       
        if (getCurrentDayNumber() > _lastDayTotalCoinsOverTimeCalculation) {
            _totalCoinsOverTime = calculateTotalCoinsOverTimeWhenExiting();
        }
        _lastDayTotalCoinsOverTimeCalculation = getCurrentDayNumber();
    }

    function calculateLatestTotalCoinsOverTimeWhenEntering() private {
        if (getCurrentDayNumber() > _lastDayTotalCoinsOverTimeCalculation) {
            _totalCoinsOverTime = calculateTotalCoinsOverTimeWhenEntering();
        }
        _lastDayTotalCoinsOverTimeCalculation = getCurrentDayNumber();
    }

    function calculateLockupPeriodEnd(uint8 lockupInYears) internal view returns (uint256) {
        //return stakingUtil.getBlockTimestamp() + (lockupInYears * 365 days);
        // on average a year has 31556952 seconds (The Gregorian (western) solar calendar has 365.2425 days, taking into account leap years)
        // but we need to multiply that number by 1000 to convert it to milliseconds
        return stakingUtil.getBlockTimestamp() + (lockupInYears * (31556952 * 1000));
    }

    function getCurrentDayNumber() internal view returns (uint256) {
        return stakingUtil.getBlockTimestamp(); 
    }

    function getTotalAmountStaked() public view returns (uint256) {
        return _totalAmountStaked;
    }

    /**
     * @dev Returns the actual staked amount (deposited + bonus)
     */
    function getAmountStakedOf(address account) external view returns (uint256) {
        return allStakers[account].stakedAmount;
    }

    /**
     * @dev Returns the initial amount that was staked/deposited, but does not reflect the current staked amount
     * Used for making it easier to calculate ROI (initial deposited amount vs unstaked amount)
     */
    function getInitialStakedAmountOf(address account) external view returns (uint256) {
        return allStakers[account].initialStakedAmount;
    }

    function getBonusPoolBalance() public view returns (uint256) {
        return stakingUtil.getBonusPoolBalance(bonusPoolBalance);
    }

    function getPrePenaltyPoolBalance() public view returns (uint256) {
        return stakingUtil.getPrePenaltyPoolBalance(prePenaltyPoolBalance);
    } 

    function getPenaltyPoolBalance() public view returns (uint256) {
        return penaltyPoolBalance;
    } 

    function getDevPoolBalance() public view returns (uint256) {
        return _devPoolBalance;
    }   

    function getAdsPoolBalance() public view returns (uint256) {
        return _adsPoolBalance;
    }   

    function getCharityPoolBalance() public view returns (uint256) {
        return _charityPoolBalance;
    }

    function getDateTimeStartedPause() external view returns (uint256) {
        return _dateTimeStartedPause;
    }

    /* balanceOf(address(this))...
    should be equal to getTotalStakingTokenBalance() - in an ideal world
    but could be greater than getTotalStakingTokenBalance() - if someone transferred staking tokens to this contract
    but should never be less than getTotalStakingTokenBalance() - otherwise there are not enough tokens!
    */ 
    /* solhint-disable no-empty-blocks */
    function getTotalStakingTokenBalance() public virtual view returns (uint256) {}
    /* solhint-enable no-empty-blocks */

    function getTotalNumberOfStakers() external view returns (uint256) {
        return _totalNumberOfStakers;
    }

    function getPercentageAllocationForPenaltyPool() internal virtual pure returns (uint8) {
        return 75;
    }

    function getPercentageAllocationForDevPool() internal virtual pure returns (uint8) {
        return 20;
    }

    function getPercentageAllocationForAdsPool() internal virtual pure returns (uint8) {
        return 3;
    }

    function getPercentageAllocationForCharityPool() internal virtual pure returns (uint8) {
        return 2;
    }

    function transferToPool(uint256 amount) internal virtual {
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Error during transfer");
    }

    // transfer staking tokens to bonus pool
    function transferToBonusPool(uint256 amount) external whenNotPaused {
        require(amount > 0, "Cannot send 0 tokens");
        //
        bonusPoolBalance = getBonusPoolBalance() + amount;
        transferToPool(amount);
    }

    // transfer staking tokens to pre penalty pool
    function transferToPrePenaltyPool(uint256 amount) external whenNotPaused {
        require(amount > 0, "Cannot send 0 tokens");
        //
        prePenaltyPoolBalance = getPrePenaltyPoolBalance() + amount;
        transferToPool(amount);
    }

    // transfer staking tokens to penalty pool
    function transferToPenaltyPool(uint256 amount) external whenNotPaused {
        require(amount > 0, "Cannot send 0 tokens");
        //
        penaltyPoolBalance = getPenaltyPoolBalance() + amount;
        transferToPool(amount);
    }

    function moveFromPrePenaltyPoolToBonusPool(uint256 amount) external onlyOwner whenNotPaused {
        require(amount > 0, "Cannot move 0 tokens.");
        require(amount <= getPrePenaltyPoolBalance(), "amount is higher than balance");
        //
        prePenaltyPoolBalance = getPrePenaltyPoolBalance() - amount;
        bonusPoolBalance = getBonusPoolBalance() + amount;
    }

    function moveFromBonusPoolToPrePenaltyPool(uint256 amount) external onlyOwner whenNotPaused {
        require(amount > 0, "Cannot move 0 tokens.");
        require(amount <= getBonusPoolBalance(), "amount is higher than balance");
        //
        bonusPoolBalance = getBonusPoolBalance() - amount;
        prePenaltyPoolBalance = getPrePenaltyPoolBalance() + amount;
    }

    function withdrawFromPool(uint256 amount, address toAccount) private onlyOwner {
        require(amount > 0, "Cannot move 0 tokens.");
        require(stakingToken.transfer(toAccount, amount), "Error during transfer");
        assert(stakingToken.balanceOf(address(this)) >= getTotalStakingTokenBalance());
    }

    function withdrawFromDevPool(uint256 amount, address toAccount) external onlyOwner whenNotPaused nonReentrant {
        require(amount <= getDevPoolBalance(), "amount is higher than balance");
        //        
        _devPoolBalance = getDevPoolBalance() - amount;
        withdrawFromPool(amount, toAccount);
    }

    function withdrawFromAdsPool(uint256 amount, address toAccount) external onlyOwner whenNotPaused nonReentrant {
        require(amount <= getAdsPoolBalance(), "amount is higher than balance");
        //
        _adsPoolBalance = getAdsPoolBalance() - amount;
        withdrawFromPool(amount, toAccount);
    }

    function withdrawFromCharityPool(uint256 amount, address toAccount) external onlyOwner whenNotPaused nonReentrant {
        require(amount <= getCharityPoolBalance(), "amount is higher than balance");
        //
        _charityPoolBalance = getCharityPoolBalance() - amount;
        withdrawFromPool(amount, toAccount);
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     * - The contract cannot be paused if it has been paused within the last 2 weeks.
     *   In other words, you need to wait 2 weeks since last time it was paused to be able to pause it again.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // ================= Overridden functions =================
    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     * Note: it returns false 1 week or more after the contract was paused.
     * In other words, the contract cannot be paused for more than 1 week.
     */
    function paused() public view override returns (bool) {
        if (_paused) {
            if ((_dateTimeStartedPause + ONE_WEEK_IN_MS) <= stakingUtil.getBlockTimestamp())
                return false; // if it's been 1 week or more since the contract was paused, it's automatically unpaused
            else
                return true;
        }
        else
            return false;
    }

    function _pause() internal override whenNotPaused {
        require(stakingUtil.getBlockTimestamp() >= (_dateTimeStartedPause + TWO_WEEKS_IN_MS), "Cannot pause yet.");
        _paused = true;
        _dateTimeStartedPause = stakingUtil.getBlockTimestamp();
        emit Paused(_msgSender());
    }

    function _unpause() internal override whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    // ========================================================

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * The size of the __gap array is calculated so that the amount of storage used by a 
     * contract always adds up to the same number (in this case 50 storage slots).
     * Note: the compiler does not reserve a storage slot for constants
     */
    uint256[33] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MyToken is ERC20Upgradeable {

    function initialize(address stakingContract) external initializer {
        __ERC20_init("MyToken", "MT");
        // mint a total of 1 Trillion (1,000,000,000,000) => 1000000000000000000000000000000
        _mint(msg.sender, 6e29); // 600 Billion -> 600,000,000,000
        _mint(stakingContract, getAmountMintedForStakingContract()); // for incentive bonuses and penalty pool
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function getAmountMintedForStakingContract() public pure returns (uint256) {
        return getAmountMintedForBonusPool() + getAmountMintedForPrePenaltyPool();
    }
    
    function getAmountMintedForBonusPool() public pure returns (uint256) {
        return 2e29; // 200 Billion -> 200,000,000,000
    }

    function getAmountMintedForPrePenaltyPool() public pure returns (uint256) {
        return 2e29; // 200 Billion -> 200,000,000,000
    }

    function getAmountMintedForBonusPoolOfLPStaking() external pure returns (uint256) {
        return 2e29; // 200 Billion -> 200,000,000,000
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./GenericTokenStaking.sol";

interface IStakingUtil {
    function getBlockTimestamp() external view returns (uint256);
    function getBonusPoolBalance(uint256 bonusPoolBalance) external pure returns (uint256);
    function getPrePenaltyPoolBalance(uint256 prePenaltyPoolBalance) external pure returns (uint256);
    function getPumpPenaltyPoolPercentage(uint8 percentage) external pure returns (uint8);
}

contract StakingUtil is IStakingUtil {

    // usings
    using Library for Library.Staker;

    /* solhint-disable not-rely-on-time */
    function getBlockTimestamp() external view override returns (uint256) {
        return block.timestamp;
    }
    /* solhint-enable not-rely-on-time */

    function getBonusPoolBalance(uint256 bonusPoolBalance) external pure override returns (uint256) {
        return bonusPoolBalance;
    }

    function getPrePenaltyPoolBalance(uint256 prePenaltyPoolBalance) external pure override returns (uint256) {
        return prePenaltyPoolBalance;
    }

    function getPumpPenaltyPoolPercentage(uint8 percentage) external pure override returns (uint8) {
        return percentage;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// to be used only for Helper contract.
contract ArithmeticOperationsForHelper {
    // add function to check if overflows. then it can be used with a try catch
    function multiply(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }
}

contract Helper {
    
    ArithmeticOperationsForHelper private operations = new ArithmeticOperationsForHelper();

    // Finds and returns the optimum multiplier to use for emulating floating numbers in solidity. 
    // That is the minimum value you need to multiply without losing precision in the decimal points.
    // To do this it finds the minimum value to multiply the parameter so that it doesn't overflow.
    // the value parameter should be the dividend.
    function findOptimumMultiplier(uint256 value) external view returns (uint256) {
        // uint256 MAX_INT =  115792089237316195423570985008687907853269984665640564039457584007913129639935
        uint256 multiplier = findMultiplier(value);
        //
        bool found = false;
        while (!found) {
            try operations.multiply(value, multiplier) {
                found = true;
            }
            catch {
                multiplier = multiplier / 100;
            }
        }
        //
        return multiplier;
    }

    function findMultiplier(uint256 value) private pure returns (uint256) {
        uint256 multiplier;
        if (value < 1157920892373161954235709850086879078532) {
            if (value < 1157920892373161954235709) {
                if (value < 11579) {
                    // < 11579
                    multiplier = 1e77; //100000000000000000000000000000000000000000000000000000000000000000000000000000
                }
                else if (value >= 11579 && value < 1157920892) {
                    //11579 x 1157920892
                    multiplier = 1e73; //10000000000000000000000000000000000000000000000000000000000000000000000000
                }
                else if (value >= 1157920892 && value < 115792089237316) {
                    //1157920892 x 115792089237316
                    multiplier = 1e68; //100000000000000000000000000000000000000000000000000000000000000000000
                }
                else if (value >= 115792089237316 && value < 11579208923731619542) {
                    //115792089237316 x 11579208923731619542
                    multiplier = 1e63; //1000000000000000000000000000000000000000000000000000000000000000
                }
                else {
                    //11579208923731619542 x 1157920892373161954235709
                    multiplier = 1e58; //10000000000000000000000000000000000000000000000000000000000
                }
            }
            else {
                if (value < 115792089237316195423570985008) {
                    //1157920892373161954235709 x 115792089237316195423570985008
                    multiplier = 1e53; //100000000000000000000000000000000000000000000000000000
                }
                else if (value >= 115792089237316195423570985008 && value < 11579208923731619542357098500868790) {
                    //115792089237316195423570985008 x 11579208923731619542357098500868790
                    multiplier = 1e48; //1000000000000000000000000000000000000000000000000
                }
                else {
                    //11579208923731619542357098500868790 x 1157920892373161954235709850086879078532
                    multiplier = 1e43; //10000000000000000000000000000000000000000000
                }
            }            
        }
        else {
            if (value < 115792089237316195423570985008687907853269984665640564039457) {
                if (value < 115792089237316195423570985008687907853269984) {
                    //1157920892373161954235709850086879078532 x 115792089237316195423570985008687907853269984
                    multiplier = 1e38; //100000000000000000000000000000000000000
                }
                else if (value >= 115792089237316195423570985008687907853269984 && value < 11579208923731619542357098500868790785326998466564) {
                    //115792089237316195423570985008687907853269984 x 11579208923731619542357098500868790785326998466564
                    multiplier = 1e33; //1000000000000000000000000000000000
                }
                else if (value >= 11579208923731619542357098500868790785326998466564 && value < 1157920892373161954235709850086879078532699846656405640) {
                    //11579208923731619542357098500868790785326998466564 x 1157920892373161954235709850086879078532699846656405640
                    multiplier = 1e28; //10000000000000000000000000000
                }
                else {
                    //1157920892373161954235709850086879078532699846656405640 x 115792089237316195423570985008687907853269984665640564039457
                    multiplier = 1e23; //100000000000000000000000
                }                
            }
            else {
                if (value < 11579208923731619542357098500868790785326998466564056403945758400) {
                    //115792089237316195423570985008687907853269984665640564039457 x 11579208923731619542357098500868790785326998466564056403945758400
                    multiplier = 1e18; //1000000000000000000
                }
                else if (value >= 11579208923731619542357098500868790785326998466564056403945758400 && value < 1157920892373161954235709850086879078532699846656405640394575840079131) {
                    //11579208923731619542357098500868790785326998466564056403945758400 x 1157920892373161954235709850086879078532699846656405640394575840079131
                    multiplier = 1e13; //10000000000000
                }
                else {
                    //1157920892373161954235709850086879078532699846656405640394575840079131 x 115792089237316195423570985008687907853269984665640564039457584007913129639935
                    multiplier = 1e8; //100000000
                }
            }
        }
        //
        return multiplier;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}