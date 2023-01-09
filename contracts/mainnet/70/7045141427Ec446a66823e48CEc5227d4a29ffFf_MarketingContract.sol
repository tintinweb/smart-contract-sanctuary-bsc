// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MarketingNFTStaking.sol";

contract MarketingContract is Ownable {
    using SafeMath for uint256;

    IERC20 public busd;
    MarketingNFTStaking public nftStaking;

    Pool[4] public LOTTERY_POOLS;
    uint256[] public INCOME_PERCENTS = [
    10, // 1%,
    11, // 1.1%
    12, // 1.2%;
    13, // 1.3;
    14, // 1.4%;
    15  // 1.5%;
    ];
    uint256[] public REF_LEVEL_PERCENT = [
    60, // 6%
    30, // 3%
    15, // 1.5%
    10, // 1%
    5, // 0.5%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3, // 0.3%
    3 // 0.3%
    ];
    uint256[] public DAILY_BONUS_PERCENT = [
    200, // 20%
    70, // 7%
    70, // 7%
    70, // 7%
    70, // 7%
    50, // 5%
    50, // 5%
    50, // 5%
    50, // 5%
    50, // 5%
    30, // 3%
    30, // 3%
    30, // 3%
    30, // 3%
    30, // 3%
    20, // 2%
    20, // 2%
    20, // 2%
    20, // 2%
    20 // 2%
    ];

    uint256 public ONE_DAY = 86400;
    uint256 public ONE_WEEK = 604800;
    uint256 public MIN_DEPOSIT = 20 ether;
    uint256 public MAX_START_DEPOSIT = 2000 ether;
    uint256 public MAX_DEPOSIT = 1000000 ether;
    uint256 public MIN_WITHDRAW = 1 ether;
    uint256 public MIN_WITHDRAW_LIMIT = 100 ether;
    uint256 public MAX_REF_LEVEL = REF_LEVEL_PERCENT.length;
    uint256 public TOTAL_REF_PERCENT = 150; // 15%
    uint256 public PERCENT_MULTIPLIER = 10;
    uint256 public REWARD_EPOCH_SECONDS = ONE_DAY;
    uint256 public TOP_USERS_DISTRIBUTION_PERCENT = 10; // 1%
    uint256 public MAX_DAILY_BONUS_LEVEL = DAILY_BONUS_PERCENT.length;
    uint256 public TOTAL_DAILY_BONUS_PERCENT = 980; // 98%
    uint256 public POOL_WINNERS_AMOUNT = 10;
    uint256 public POOL_DISTRIBUTION_PERC = 10;
    uint256 public POOL_ENTER_FEE = 1 ether;
    uint256 public DEPOSIT_FEE_PERCENT = 50; // 5%

    struct RoundUserStats {
        uint256 amount;
    }
    struct Pool {
        uint8 usersAmount;
        uint8 maxUsersAmount;
        uint32 gambleRound;
        uint256 liquidity;
        uint256 totalPrize;
        uint256 extraLiquidity;
        uint256 minDeposit;
    }
    struct User {
        address _address;
        address inviter;
        uint256 deposit;
        uint256 lastDeposit;
        uint256 totalDeposit;
        uint256 totalRefs;
        uint256 totalRefIncome;
        uint256 rewards;
        uint256 claimedRewards;
        uint256 claimedNftRewards;
        uint256 lastClaim;
        uint256 missedRewards;
    }

    uint256 private nonce = 1;
    address[] private uniqueUserAddresses;

    uint256 public distributionRound;
    bool public initialized = false;
    uint256 public initializedAt;
    address public top;
    address public devAddress;
    uint256 public usersTotal = 0;

    mapping (address => mapping(uint256 => uint256)) private referralsIncome;
    mapping (address => mapping(uint256 => uint256)) private referralsCount;
    mapping (uint256 => mapping(address => RoundUserStats)) private roundDeposits;
    mapping (uint256 => address[5]) private topRoundAddresses;
    mapping (uint256 => uint256) private totalRoundDeposits;
    //mapping(poolIndex => poolUsers)
    mapping(uint256 => address[]) private poolUsers;

    mapping (address => User) public users;
    //mapping(poolIndex => mapping(gambleRound => mapping(userAddress => bool));
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public poolGambleRoundUsers;

    modifier whenInitialized() {
        require(initialized, "NOT INITIALIZED");
        _;
    }

    event Deposit(address indexed _address, uint256 amount, address indexed inviter);
    event Withdraw(address indexed _address, uint256 amount);
    event RefReward(address indexed _address, uint256 amount, uint256 level, address sender);
    event RefRewardMiss(address indexed _address, uint256 amount, uint256 level, address sender);
    event DailyBonusReward(address indexed _address, uint256 amount, uint256 level, address sender);
    event DailyBonusRewardMiss(address indexed _address, uint256 amount, uint256 level, address sender);
    event DailyDistributionRewards(address indexed _address, uint256 amount);
    event DailyDistributionRewardMiss(address indexed _address, uint256 amount);
    event PoolGamblingWinners(uint256 round, uint256 poolIndex, address[] winners);
    event PoolGamblingReward(address indexed winner, uint256 amount, uint256 round, uint256 poolIndex);
    event PoolGamblingRewardMiss(address indexed winner, uint256 amount, uint256 round, uint256 poolIndex);
    event IncomeMiss(address indexed _address, uint256 amount);

    constructor(address _devAddress, address busdAddress) {
        devAddress = _devAddress;
        busd = IERC20(busdAddress);
        LOTTERY_POOLS[0] = Pool(0, 200, 0, 0, 50 ether, 0, 0);
        LOTTERY_POOLS[1] = Pool(0, 100, 0, 0, 100 ether, 0, 200 ether);
        LOTTERY_POOLS[2] = Pool(0, 50, 0, 0, 500 ether, 0, 1000 ether);
        LOTTERY_POOLS[3] = Pool(0, 50, 0, 0, 1000 ether, 0, 2000 ether);
    }

    fallback() external payable {
        // custom function code
        payable (msg.sender).transfer(msg.value);
    }

    receive() external payable {
        // custom function code
        payable (msg.sender).transfer(msg.value);
    }

    // set nft distribution rewards
    function setNftStaking(address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "EMPTY ADDRESS");
        nftStaking = MarketingNFTStaking(contractAddress);
    }

    /**
    * @param inviter - address of a person who sent invitation
    * @param amount - deposit amount. Contract uses erc20 for rewards
    * @dev this function increments user deposit, totalDeposit and distributes
    * all extra rewards: referral, top users, nft staking
    */
    function deposit(address inviter, uint256 amount) external whenInitialized {
        User storage user = users[msg.sender];

        if (users[msg.sender].inviter != address(0) || msg.sender == top) {
            inviter = users[msg.sender].inviter;
        }

        if (msg.sender != top) {
            require(users[inviter]._address != address(0), "INVITER MUST EXIST");
        }


        uint256 withdrawLimit = getWithdrawLimit(msg.sender);
        require(user.claimedRewards == withdrawLimit, "CANT PROCEED TO NEXT ROUND");
        
        require(amount >= getMinDeposit(msg.sender), "DEPOSIT MINIMUM VALUE");
        require(amount <= getMaxDeposit(msg.sender), "DEPOSIT IS HIGHER THAN MAX DEPOSIT");

        busd.transferFrom(msg.sender, address(this), amount);

        bool isFirstDeposit = !(user.totalDeposit > 0);

        if(isFirstDeposit) {
            uniqueUserAddresses.push(msg.sender);
            user._address = msg.sender;
            usersTotal++;
            user.inviter = inviter;
        }

        distributeRefFees(amount, inviter, isFirstDeposit);

        user.lastClaim = 0;
        user.lastDeposit = block.timestamp;
        user.deposit = amount;
        user.totalDeposit = SafeMath.add(user.totalDeposit, amount);
        user.claimedRewards = 0;

        emit Deposit(msg.sender, amount, inviter);

        uint256 depositFee = getPercentFromNumber(amount, DEPOSIT_FEE_PERCENT, PERCENT_MULTIPLIER);
        busd.transfer(devAddress, depositFee);
        distributeRewards(amount, 0);
    }

    /**
    * @dev withdraw users rewards
    * withdraw amount should be more than MIN_WITHDRAW and less than withdrawLimit
    * all extra rewards accounted: referral, top users, nft staking
    *
    * @dev distributes fee to devAddress
    */
    function withdraw() external whenInitialized {
        User storage user = users[msg.sender];

        (
            uint256 incomeValue,
            uint256 nftValue,
            uint256 withdrawLimit,
            uint256 missedIncome
        ) = getIncomeSinceLastClaim(msg.sender);
        require(incomeValue > MIN_WITHDRAW, "REWARDS TOO LOW");
        require(user.claimedRewards < withdrawLimit, "WITHDRAW LIMIT REACHED");

        require(getBalance() >= incomeValue, "NOT ENOUGH BALANCE");
        
        uint256 withdrawFee = getPercentFromNumber(incomeValue, getWithdrawPercent(msg.sender), PERCENT_MULTIPLIER);
        uint256 restAmount = incomeValue.sub(withdrawFee);
        
        user.claimedRewards = SafeMath.add(user.claimedRewards, incomeValue);
        user.claimedNftRewards = SafeMath.add(user.claimedNftRewards, nftValue);
        user.rewards = 0;
        user.lastClaim = block.timestamp;

        busd.transfer(devAddress, withdrawFee);
        busd.transfer(msg.sender, restAmount);
        
        emit Withdraw(msg.sender, restAmount);

        if (missedIncome > 0) {
            emit IncomeMiss(msg.sender, missedIncome);
        }

        distributeDailyMatchingBonus(restAmount, msg.sender);

        distributeRewards(0, restAmount);
    }

    /**
    * @dev logs msg.sender address to pool with index poolIndex
    * @dev gamble will starts when
    * pool.liquidity == pool.totalPrize && pool.usersAmount == pool.maxUsersAmount
    */
    function takePartInPool(uint256 poolIndex) external {
        require(poolIndex < LOTTERY_POOLS.length, "ONLY 4 POOLS EXIST");
        User memory user = users[msg.sender];
        Pool storage pool = LOTTERY_POOLS[poolIndex];
        require(user.deposit >= pool.minDeposit, "DEPOSIT TOO SMALL");
        require(pool.usersAmount < pool.maxUsersAmount, "ALREADY FULL USER PACK");
        require(user.totalDeposit > 0, "TOTAL DEPOSIT 0");
        //mapping(poolIndex => mapping(gambleRound => mapping(userAddress => bool));
        require(!poolGambleRoundUsers[poolIndex][pool.gambleRound][user._address], "ALREADY PARTICIPATING");
        if (getPoolEntersAmount(user._address, poolIndex) > 10) {
            busd.transfer(devAddress, POOL_ENTER_FEE);
        }
        if (pool.gambleRound == 0) {
            poolUsers[poolIndex].push(user._address);
        } else {
            poolUsers[poolIndex][pool.usersAmount] = user._address;
        }
        pool.usersAmount++;
        poolGambleRoundUsers[poolIndex][pool.gambleRound][user._address] = true;
        if(pool.liquidity == pool.totalPrize && pool.usersAmount == pool.maxUsersAmount) {
            handleLottery(poolIndex);
        }
    }

    function distributeRewards(uint256 depositAmount, uint256 withdrawAmount) internal {
        distributeRewardsByTopDeposits(depositAmount);
        fillLotteryPools(depositAmount > withdrawAmount ? depositAmount : withdrawAmount);
    }

    /**
    * @dev distributes reward to addresses which exist in topRoundAddresses mapping.
    * @dev if depositAmount > 0 checks whether depositAmount is larger
    * than deposits of users in topRoundAddresses. If so, place msg.sender to topRoundAddresses
    * @dev increment round if initializedAt + distributionRound.mul(ONE_DAY) < block.timestamp
    */
    function distributeRewardsByTopDeposits(uint256 depositAmount) internal {
        if(initializedAt + distributionRound.mul(ONE_DAY) < block.timestamp) {
            increaseDailyDistributionRound();
        }

        if (depositAmount > 0) {
            roundDeposits[distributionRound][msg.sender].amount += depositAmount;
            totalRoundDeposits[distributionRound] += depositAmount;
            replaceTopUsers();
        }
    }

    /**
    * @dev replace top users if msg.sender's deposit is large enough
    */
    function replaceTopUsers() private {
        uint256 index = 5;
        address[5] memory currentTopRoundAddresses = topRoundAddresses[distributionRound];
        while(index > 0) {
            if (
                roundDeposits[distributionRound][msg.sender].amount >
                roundDeposits[distributionRound][currentTopRoundAddresses[index - 1]].amount
            ) {
                index--;
            } else {
                break;
            }
        }
        if (index < 5) {
            for (uint256 i = 4; i > index; i--) {
                topRoundAddresses[distributionRound][i] = topRoundAddresses[distributionRound][i - 1];
            }
            topRoundAddresses[distributionRound][index] = msg.sender;
        }
    }

    /**
    * @dev distributes reward to addresses which exist in topRoundAddresses mapping.
    * @dev increment round if initializedAt + distributionRound.mul(ONE_DAY) < block.timestamp
    */
    function increaseDailyDistributionRound() private {
        require(initializedAt + SafeMath.mul(distributionRound, ONE_DAY) < block.timestamp, "TOO EARLY FOR STARTING NEW ROUND");
        distributeRoundIncentivesToTopUsers();
        distributionRound++;
    }

    /**
    * @dev distributes reward to addresses which exist in topRoundAddresses mapping.
    */
    function distributeRoundIncentivesToTopUsers() private {
        address[5] memory _topRoundAddresses = topRoundAddresses[distributionRound];
        uint256 rewardsAmount = getPercentFromNumber(
            totalRoundDeposits[distributionRound],
                TOP_USERS_DISTRIBUTION_PERCENT,
                PERCENT_MULTIPLIER
        );
        for (uint256 i = 0; i < _topRoundAddresses.length; i++) {
            if (_topRoundAddresses[i] != address(0)) {
                (uint256 safeRewardAmount, uint256 missedRewards) = safeRewardTransfer(
                    _topRoundAddresses[i],
                    rewardsAmount
                );
                if (safeRewardAmount > 0) {
                    emit DailyDistributionRewards(_topRoundAddresses[i], safeRewardAmount);
                }
                if (missedRewards > 0) {
                    emit DailyDistributionRewardMiss(_topRoundAddresses[i], missedRewards);
                    users[_topRoundAddresses[i]].missedRewards = users[_topRoundAddresses[i]]
                    .missedRewards
                    .add(missedRewards);
                }
            }
        }
    }

    /**
    * @dev fill all pools with equal proportion from amount value
    * @dev start lottery if newLiquidity == pool.totalPrize && pool.usersAmount == pool.maxUsersAmount
    */
    function fillLotteryPools(uint256 amount) private {
        uint256 poolsAmount = LOTTERY_POOLS.length;
        uint256 poolDepAmount = amount.mul(POOL_DISTRIBUTION_PERC).div(poolsAmount).div(100).div(PERCENT_MULTIPLIER);
        for (uint i = 0; i < poolsAmount; i++) {
            Pool storage pool = LOTTERY_POOLS[i];
            uint256 newLiquidity = pool.liquidity.add(poolDepAmount);
            if (newLiquidity >= pool.totalPrize) {
                pool.extraLiquidity = pool.extraLiquidity.add(newLiquidity.sub(pool.totalPrize));
                newLiquidity = pool.totalPrize;
            }
            pool.liquidity = newLiquidity;
            if(newLiquidity == pool.totalPrize && pool.usersAmount == pool.maxUsersAmount) {
                handleLottery(i);
            }
        }
    }

    /**
    * @dev selects randomly (almost) 10 winners and distributes prize to them
    * @dev if pool got extraLiquidity than fill pool.liquidity field with it.
    */
    function handleLottery(uint256 poolIndex) private {
        Pool storage pool = LOTTERY_POOLS[poolIndex];
        runGamble(poolIndex);

        uint256 newLiquidity = 0;
        if (pool.extraLiquidity > 0) {
            if (pool.extraLiquidity > pool.totalPrize) {
                newLiquidity = pool.totalPrize;
                pool.extraLiquidity = pool.extraLiquidity.sub(pool.totalPrize);
            } else {
                newLiquidity = pool.extraLiquidity;
                pool.extraLiquidity = 0;
            }
        }
        pool.liquidity = newLiquidity;
    }

    /**
    * @dev selects randomly (almost) 10 winners and distributes prize to them
    */
    function runGamble(uint256 poolIndex) private {
        Pool storage pool = LOTTERY_POOLS[poolIndex];
        uint256 _nonce = nonce + 1;
        uint256 winnerIndex = 0;
        uint256 userReward = pool.liquidity.div(POOL_WINNERS_AMOUNT);
        address[] memory winners = new address[](POOL_WINNERS_AMOUNT);
        while(winnerIndex < POOL_WINNERS_AMOUNT) {
            uint256 winner = getRandomNumber(0, pool.usersAmount - 1);
            address winnerAddress = poolUsers[poolIndex][winner];
            (uint256 safeRewardAmount, uint256 missedRewards) = safeRewardTransfer(winnerAddress, userReward);
            winners[winnerIndex] = winnerAddress;
            winnerIndex++;
            _nonce++;
            if (safeRewardAmount > 0) {
                emit PoolGamblingReward(winnerAddress, safeRewardAmount, pool.gambleRound, poolIndex);
            }
            if (missedRewards > 0) {
                emit PoolGamblingRewardMiss(winnerAddress, missedRewards, pool.gambleRound, poolIndex);
                users[winnerAddress].missedRewards = users[winnerAddress].missedRewards.add(missedRewards);
            }
        }
        nonce = _nonce;
        emit PoolGamblingWinners(pool.gambleRound, poolIndex, winners);
        pool.gambleRound++;
        pool.usersAmount = 0;
    }


    /**
    * @dev distributes referral rewards. Latter depends from level of the ref and amount of
    * refs in 1 level.
    * Deeper levels open if there are enough users at first level: 1 user = 1 deeper level
    * @dev call this method from deposit one
    */
    function distributeRefFees(uint256 amount, address inviter, bool isFirstDeposit) internal {
        address currentInviter = inviter;
        uint256 currentLevel = 1;
        bool isTopReached = inviter == address(0);
        while(!isTopReached && currentLevel <= MAX_REF_LEVEL) {
            isTopReached = currentInviter == top;
            uint256 refAmount = getPercentFromNumber(amount, getRefLevelPercent(currentLevel), PERCENT_MULTIPLIER);
            User storage _currentInviterUser = users[currentInviter];

            if (isFirstDeposit) {
                // increment referrals count only on first deposit
                // by level
                referralsCount[currentInviter][currentLevel] = referralsCount[currentInviter][currentLevel].add(1);
                // global
                _currentInviterUser.totalRefs = _currentInviterUser.totalRefs.add(1);
            }

            // Level 1 referrals count must be higher or equal to current level
            if (referralsCount[currentInviter][1] >= currentLevel) {
                (uint256 rewardAmount, uint256 missedRewards) = safeRewardTransfer(
                    _currentInviterUser._address,
                    refAmount
                );
                // save referral income statistic by level
                // save global income referral statistic
                _currentInviterUser.totalRefIncome = _currentInviterUser.totalRefIncome.add(rewardAmount);
                if (rewardAmount > 0) {
                    emit RefReward(currentInviter, rewardAmount, currentLevel, msg.sender);
                    referralsIncome[currentInviter][currentLevel] = referralsIncome[currentInviter][currentLevel]
                    .add(rewardAmount);
                }
                if (missedRewards > 0) {
                    emit RefRewardMiss(currentInviter, missedRewards, currentLevel, msg.sender);
                    _currentInviterUser.missedRewards = _currentInviterUser.missedRewards.add(missedRewards);
                }
            } else {
                emit RefRewardMiss(currentInviter, refAmount, currentLevel, msg.sender);
                _currentInviterUser.missedRewards = _currentInviterUser.missedRewards.add(refAmount);
            }

            currentInviter = users[currentInviter].inviter;

            currentLevel++;
        }
    }

    /**
    * @dev distributes referral rewards. Latter depends from level of the ref and amount of
    * refs in 1 level.
    * Deeper levels open if there are enough users at first level: 1 user = 1 deeper level
    * @dev call this method from withdraw one
    */
    function distributeDailyMatchingBonus(uint256 amount, address withdrawer) internal {
        address currentInviter = users[withdrawer].inviter;
        uint256 currentLevel = 1;
        bool isTopReached = currentInviter == address(0);
        while(!isTopReached && currentLevel <= MAX_DAILY_BONUS_LEVEL) {
            isTopReached = currentInviter == top;
            uint256 refAmount = getPercentFromNumber(
                amount,
                getDailyBonusLevelPercent(currentLevel),
                PERCENT_MULTIPLIER
            );
            User storage currentInviterUser = users[currentInviter];
            // Level 1 referrals count must be higher or equal to current level
            if (referralsCount[currentInviter][1] >= currentLevel) {
                (uint256 rewardAmount, uint256 missedRewards) = safeRewardTransfer(
                    currentInviterUser._address,
                    refAmount
                );
                if (rewardAmount > 0) {
                    emit DailyBonusReward(currentInviter, rewardAmount, currentLevel, msg.sender);
                }
                if (missedRewards > 0) {
                    emit DailyBonusRewardMiss(currentInviter, missedRewards, currentLevel, msg.sender);
                    currentInviterUser.missedRewards = currentInviterUser.missedRewards.add(missedRewards);
                }
            } else {
                emit DailyBonusRewardMiss(currentInviter, refAmount, currentLevel, msg.sender);
                currentInviterUser.missedRewards = currentInviterUser.missedRewards.add(refAmount);
            }

            currentInviter = users[currentInviter].inviter;

            currentLevel++;
        }
    }

    function initialize(uint256 amount) external onlyOwner {
        require(!initialized, "initialized");
        require(amount >= getMinDeposit(msg.sender), "DEPOSIT MINIMUM VALUE");
        require(amount <= getMaxDeposit(msg.sender), "DEPOSIT IS HIGHER THAN MAX DEPOSIT");

        busd.transferFrom(msg.sender, address(this), amount);
        
        User storage user = users[msg.sender];
        
        user._address = msg.sender;
        user.deposit = amount;
        user.lastDeposit = block.timestamp;
        user.totalDeposit = amount;

        emit Deposit(msg.sender, amount, address(0));

        uniqueUserAddresses.push(msg.sender);
        top = msg.sender;

        initialized = true;
        initializedAt = block.timestamp;
        distributionRound = 1;
    }

    /* getters */

    /**
    * @dev returns users withdraw limit
    */
    function getWithdrawLimit(address _address) public view returns (uint256) {
        uint256 userDeposit = users[_address].deposit;
        if (userDeposit >= 100000 ether) return userDeposit.mul(2);

        return userDeposit.mul(3);
    }

    /**
    * @dev returns fee percent of users withdraw
    */
    function getWithdrawPercent(address _address) public view returns (uint256) {
        User memory user = users[_address];
        (uint256 income,, uint256 withdrawLimit,) = getIncomeSinceLastClaim(_address);

        if (income.add(user.claimedRewards) == withdrawLimit) return SafeMath.mul(3, PERCENT_MULTIPLIER);
        
        uint256 lastClaim = user.lastClaim > 0 ? user.lastClaim : user.lastDeposit;
        uint256 timestamp = block.timestamp;

        if (timestamp - lastClaim > 3 * ONE_WEEK) return SafeMath.mul(3, PERCENT_MULTIPLIER); // 3%
        if (timestamp - lastClaim > 2 * ONE_WEEK) return SafeMath.mul(4, PERCENT_MULTIPLIER); // 4%
        if (timestamp - lastClaim > ONE_WEEK) return SafeMath.mul(7, PERCENT_MULTIPLIER); // 7%

        return SafeMath.mul(10, PERCENT_MULTIPLIER); // 10%
    }

    /**
    * @dev returns users level which used for accumulate rewards from passive deposit income
    */
    function getUserLevel(address _address) public view returns (uint256) {
        uint256 userDeposit = users[_address].deposit;
        
        if (userDeposit > 50000 ether) return 5;
        if (userDeposit > 10000 ether) return 4;
        if (userDeposit > 5000 ether) return 3;   
        if (userDeposit > 1000 ether) return 2;      
        if (userDeposit > 500 ether) return 1;

        return 0;
    }

    /**
    * @dev min deposit with which user can enter
    */
    function getMinDeposit(address _address) public view returns (uint256) {
        if (users[_address].deposit > 0) return users[_address].deposit.mul(2); 
        return MIN_DEPOSIT;
    }

    /**
    * @dev max deposit with which user can enter
    */
    function getMaxDeposit(address _address) public view returns (uint256) {
        if (users[_address].deposit > 0) return MAX_DEPOSIT;
        return MAX_START_DEPOSIT;
    }

    function getBalance() public view returns(uint256) {
        return busd.balanceOf(address(this));
    }

    /**
    * @return amount of referrals of user _address at selected level
    */
    function getReferralsCount(address _address, uint256 level) public view returns(uint256) {
        return referralsCount[_address][level];
    }

    /**
    * @return income from referrals of user _address at selected level
    */
    function getReferralsIncome(address _address, uint256 level) public view returns(uint256) {
        return referralsIncome[_address][level];
    }

    /**
    * @dev percent that user obtain from ref deposit on exact level (distributeRefFees)
    */
    function getRefLevelPercent(uint level) public view returns(uint256) {
        return REF_LEVEL_PERCENT[level - 1];
    }

    /**
    * @dev percent that user obtain from ref deposit on exact level (distributeDailyMatchingBonus)
    */
    function getDailyBonusLevelPercent(uint level) public view returns(uint256) {
        return DAILY_BONUS_PERCENT[level - 1];
    }

    /**
    * @return user income since last collection of rewards with withdraw()
    * totalIncome - total income since last claim (totalIncome = 0 if limit reached)
    * nftIncome - income from nft staking
    * withdrawLimit - maximum amount user can fetch from contract
    */
    function getIncomeSinceLastClaim(address _address) public view returns(uint256, uint256, uint256, uint256) {
        User memory user = users[_address];

        uint256 withdrawLimit = getWithdrawLimit(_address);

        uint256 secondsPassed = user.lastClaim > 0 ?
            SafeMath.sub(block.timestamp, user.lastClaim) :
            SafeMath.sub(block.timestamp, user.lastDeposit);
        uint256 incomeMultiplier = getUserIncomeMultiplier(_address, secondsPassed);
        uint256 nftIncomeMultiplier;
        uint256 nftIncome;
        if (address(nftStaking) != address(0)) {
            nftIncomeMultiplier = nftStaking.getRewardMultiplier(_address);
            nftIncome = user.deposit
            .mul(nftIncomeMultiplier)
            .div(REWARD_EPOCH_SECONDS)
            .div(PERCENT_MULTIPLIER)
            .div(100)
            .sub(user.claimedNftRewards);
        }
        uint256 passiveIncome = user.deposit.mul(incomeMultiplier).div(PERCENT_MULTIPLIER).div(100);
        uint256 totalIncome = passiveIncome.add(user.rewards).add(nftIncome);
        uint256 rawBalance = user.claimedRewards.add(totalIncome);

        //if raw income more than 100% from deposit than cut passive income by 2
        if (rawBalance.sub(passiveIncome) >= user.deposit) {
            passiveIncome = passiveIncome.div(2);
            totalIncome = passiveIncome.add(user.rewards).add(nftIncome);
            rawBalance = user.claimedRewards.add(totalIncome);
        } else if (rawBalance > user.deposit) {
            uint256 regPassive = user.deposit.sub(rawBalance.sub(passiveIncome));
            passiveIncome = passiveIncome.add(regPassive).div(2);
            totalIncome = passiveIncome.add(user.rewards).add(nftIncome);
            rawBalance = user.claimedRewards.add(totalIncome);
        }


        uint256 missedIncome;
        if (rawBalance > withdrawLimit) {
            totalIncome = withdrawLimit.sub(user.claimedRewards);
            missedIncome = rawBalance.sub(withdrawLimit);
        }

        return (totalIncome, nftIncome, withdrawLimit, missedIncome);
    }


    /**
    * @return total _distributionRound deposit
    */
    function getTotalRoundDeposit(uint256 _distributionRound) external view returns(uint256) {
        return totalRoundDeposits[_distributionRound];
    }

    /**
    * @return users with top deposits in current round
    */
    function getTopRoundUsers(uint256 _distributionRound) external view returns(address[5] memory) {
        return topRoundAddresses[_distributionRound];
    }

    /**
    * @return users deposit in current round
    */
    function getUserRoundDeposit(address userAddress, uint256 _distributionRound) external view returns(uint256) {
        return roundDeposits[_distributionRound][userAddress].amount;
    }

    /**
    * @return users passive income percent
    */
    function getUserIncomeMultiplier(address userAddress, uint256 secondsPassed) public view returns(uint256) {
        uint256 userLevel = getUserLevel(userAddress);
        uint256 epochesPassed = SafeMath.mul(secondsPassed, 100).div(REWARD_EPOCH_SECONDS).div(100);
        return SafeMath.mul(epochesPassed, INCOME_PERCENTS[userLevel]);
    }

    /* helpers */

    function getPercentFromNumber(uint256 number, uint256 modifiedPercent, uint256 percentModifier)
        private
        pure
        returns(uint256)
    {
        return number.mul(modifiedPercent).div(100).div(percentModifier);
    }

    // transfer reward with limit check
    function safeRewardTransfer(address _address, uint256 revAmount) private returns(uint256, uint256) {
        uint256 userRewards = users[_address].rewards;
        (uint256 totalIncome,,uint256 withdrawLimit,) = getIncomeSinceLastClaim(_address);
        uint256 accRews = SafeMath.add(totalIncome, users[_address].claimedRewards);
        uint256 revSafeTransferAmount = revAmount;
        uint256 missedRewards;
        if (SafeMath.add(revAmount, accRews) > withdrawLimit) {
            revSafeTransferAmount = SafeMath.sub(withdrawLimit, accRews);
            missedRewards = SafeMath.sub(revAmount, revSafeTransferAmount);
        }
        users[_address].rewards = SafeMath.add(userRewards, revSafeTransferAmount);
        return (revSafeTransferAmount, missedRewards);
    }

    function setDevAddress(address _newDevAddress) external onlyOwner {
        require(_newDevAddress != address(0), "ZERO ADDRESS");

        devAddress = _newDevAddress;
    }

    function setMinWithdraw(uint256 amount) external onlyOwner {
        require(amount < MIN_WITHDRAW_LIMIT, "MIN WITHDRAW LIMIT");
        require(amount > 0, "WRONG AMOUNT");

        MIN_WITHDRAW = amount;
    }

    /**
    * @return returns users from pool with index poolIndex from current gamble round
    */
    function getPoolUsers(uint256 poolIndex) external view returns(address[] memory) {
        require(poolIndex < LOTTERY_POOLS.length, "ONLY 4 POOLS EXIST");
        address[] memory poolUsersByIndex = new address[](LOTTERY_POOLS[poolIndex].usersAmount);
        for (uint256 i = 0; i < poolUsersByIndex.length; i++) {
            poolUsersByIndex[i] = poolUsers[poolIndex][i];
        }
        return poolUsersByIndex;
    }

    function getUniqueUsers(uint256 startIndex) external view returns (User[] memory) {
        uint256 length = uniqueUserAddresses.length > startIndex
            ? uniqueUserAddresses.length - startIndex
            : 0;
        User[] memory uniqueUsers = new User[](length);
        uint256 i = 0;
        while (i < length) {
            uniqueUsers[i] = users[uniqueUserAddresses[startIndex + i]];
            ++i;
        }
        return uniqueUsers;
    }

    /**
    * @return total users enters amount in pool with index poolIndex
    */
    function getPoolEntersAmount(address _address, uint256 poolIndex) public view returns(uint256) {
        uint256 lastGambleRound = LOTTERY_POOLS[poolIndex].gambleRound;
        uint256 round = 0;
        uint256 entersAmount = 0;
        while (round <= lastGambleRound) {
            bool userInRound = poolGambleRoundUsers[poolIndex][round][_address];
            if (userInRound) ++entersAmount;
            ++round;
        }
        return entersAmount;
    }

    function getRandomNumber(uint minNumber, uint maxNumber) internal returns (uint) {
        nonce++;
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) %
            (maxNumber - minNumber);
        randomNumber = randomNumber + minNumber;
        return randomNumber;
    }


}

pragma solidity 0.8.12;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./MarketingNFT.sol";

contract MarketingNFTStaking is IERC721Receiver {
    MarketingNFT nft;
    using SafeMath for uint256;

    uint256 constant ONE_DAY = 86400;
    uint256 constant ONE_WEEK = 604800;
    uint256 constant REWARD_EPOCH_SECONDS = ONE_DAY;
    uint256[4] public COOLDOWN = [
        SafeMath.mul(REWARD_EPOCH_SECONDS, 3),   // common
        SafeMath.mul(REWARD_EPOCH_SECONDS, 5),   // uncommon
        SafeMath.mul(REWARD_EPOCH_SECONDS, 7),   // rare
        SafeMath.mul(REWARD_EPOCH_SECONDS, 14)   // legendary
    ];

    uint256[4] public INCOME_PERCENT = [
    1,   // 0.1 %
    2,   //  0.2 %
    3,   //  0.3 %
    6   // legendary 0.6 %
    ];

    uint256 public stakedTotal;
    uint256 public stakingStartTime;
    uint256 constant stakingTime = 180 seconds;


    /**
    * Stake represents staked nft token
    * @param startStaking - last staking start timestamp
    * @param cooldown - represents timestamp when cooldown finish
    */
    struct Stake {
        uint256 startStaking;
        address owner;
    }

    //mapping(address => Stake)
    mapping(address => Stake) public stakes;
    // mapping(tokenId => cooldown)
    mapping(uint256 => uint256) public tokenCooldown;
    //mapping(address => rewardMultiplier)
    mapping(address => uint256) public rewardMultiplier;

    event Staked(address indexed owner, uint256 tokenId);
    event Unstaked(address indexed owner, uint256 tokenId);
    event EmergencyUnstake(address indexed owner, uint256 tokenId);

    constructor(MarketingNFT _marketingNFT) {
        nft = _marketingNFT;
    }

    function stake(uint256 tokenId) public {
        _stake(msg.sender, tokenId);
    }

    function _stake(address _user, uint256 _tokenId) internal {
        require(nft.ownerOf(_tokenId) == _user, "not owner");
        Stake storage userStake = stakes[_user];
        require(userStake.startStaking == 0, "already staked");
        require(block.timestamp > tokenCooldown[_tokenId], 'token on cooldown');

        userStake.startStaking = block.timestamp;
        userStake.owner = _user;
        nft.safeTransferFrom(_user, address(this), _tokenId);
        emit Staked(_user, _tokenId);
        stakedTotal++;
    }

    function unstake(uint256 _tokenId) public {
        _unstake(msg.sender, _tokenId);
    }

    function _unstake(address _user, uint256 _tokenId) internal {
        Stake storage userStake = stakes[_user];
        require(userStake.owner == _user, "not owner");
        require(userStake.startStaking + stakingTime < block.timestamp, "not ready");

        uint256 nftRarity = nft.getNftRarity(_tokenId);
        uint256 multiplier = calcRewardMultiplier(nftRarity, userStake.startStaking);
        rewardMultiplier[_user] += multiplier;
        tokenCooldown[_tokenId] = block.timestamp + COOLDOWN[nftRarity];

        nft.safeTransferFrom(address(this), _user, _tokenId);
        
        emit Unstaked(_user, _tokenId);
        userStake.startStaking = 0;
        stakedTotal--;
    }

    function emergencyUnstake(uint256 _tokenId) public {
        _emergencyUnstake(msg.sender, _tokenId);
    }

    function _emergencyUnstake(address _user, uint256 _tokenId) internal {
        Stake storage userStake = stakes[_user];
        require(userStake.owner == _user, "not owner");
        // unstake without saving staking period rewards somewhere
        nft.safeTransferFrom(address(this), _user, _tokenId);
        emit EmergencyUnstake(_user, _tokenId);
        userStake.startStaking = 0;
        stakedTotal--;
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // need to by normilized by (REWARD_EPOCH_SECONDS * 100 * PERCENT_MULTIPLIER)
    function calcRewardMultiplier(uint256 nftRarity, uint256 startStaking) public view returns(uint256) {
        uint256 secondPassed = min(REWARD_EPOCH_SECONDS, SafeMath.sub(block.timestamp, startStaking));
        return SafeMath.mul(secondPassed, INCOME_PERCENT[nftRarity]);
    }

    function getRewardMultiplier(address _address) external view returns (uint256) {
        return rewardMultiplier[_address];
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MarketingNFT is ERC721Enumerable, Ownable, Pausable, ReentrancyGuard {
    using Math for uint256;

    uint256 private nonce = 1; //for random function

    uint256 public constant MINT_PER_TRANSACTION = 5;       // max amount to mint in tx
    uint256 public constant MINT_PER_ADDRESS = 20;          // max amount each address can mint
    uint256 public constant CAPPED_SUPPLY = 10000;          // max amount for minting
    uint256 public constant SALE_ROUND_SUPPLY = 1000;       // 1000 nft in sale round
    uint256 public constant INCREMENT_PRICE_PERCENT = 100;  // 10 %
    uint256 public constant PERCENT_MULTIPLIER = 10;
    uint256[4] CHANCE = [230, 66, 4];
    enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }

    string public baseTokenURI;                             // IPFS base link

    uint256 public pricePerTokenERC20;                      // start 49 ERC20 tokens

    address public paymentToken;                            // payment ERC20 token

    uint256 public currentlyMinted;                         // minted amount
    uint256 public saleRoundMinted;
    mapping(address => uint256) public mintedPerAddress;

    //Mapping represents rarity of nft: tokenId => (0 - common, 1 - uncommon, 2 - rare, 3 - legendary)
    mapping(uint256 => uint256) nftRarity;


    event BaseTokenURIUpdate(string oldURI, string newURI);
    event Mint(address minter, address indexed to, uint256 tokenId);
    event SetPricePerTokenERC20(uint256 newPrice);

    constructor(
        string memory _baseTokenURI,
        address _paymentToken,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        pricePerTokenERC20 = 49 ether;
        baseTokenURI = _baseTokenURI;
        paymentToken = _paymentToken;

        _pause();
    }

    function getMintPrice(uint256 amount) external view returns (uint256) {
        return _getMintPrice(amount, pricePerTokenERC20);
    }


    function _getMintPrice(uint256 amount, uint256 price) internal view returns (uint256) {
        uint256 limitedAmount = _getMaxMintAvailable(amount, _msgSender());
        return price * limitedAmount;
    }

    function _getMaxMintAvailable(uint256 amount, address user)
        internal
        view
        returns (uint256) {

        uint256 mintForSender = amount.min(MINT_PER_TRANSACTION);
        mintForSender =  mintForSender.min(MINT_PER_ADDRESS - mintedPerAddress[user]);
        return mintForSender.min(SALE_ROUND_SUPPLY - saleRoundMinted);
    }

    function mint(uint256 amount) public whenNotPaused {
        require(mintedPerAddress[msg.sender] < MINT_PER_ADDRESS, "MINT LIMIT REACHED");
        address tokenAddress = paymentToken;
        _mintForERC20(msg.sender, amount, tokenAddress);
    }

    function _mintForERC20(
        address to,
        uint256 amount,
        address tokenAddress
    ) internal {
        uint256 howManyToMint = _getMaxMintAvailable(amount, to);
        uint256 mintPrice = pricePerTokenERC20 * howManyToMint;
        IERC20(tokenAddress).transferFrom(_msgSender(), owner(), mintPrice);
        _mint(howManyToMint, to);
    }

    function _mint(uint256 howManyToMint, address to) internal {
        uint256 minted = currentlyMinted;
        uint256 roundMinted = saleRoundMinted;

        for (uint256 i = 0; i < howManyToMint; i++) {
            _safeMint(to, ++minted);
            ++roundMinted;
            uint256 rarity = generateNftRarity();
            nftRarity[minted] = rarity;
            emit Mint(msg.sender, to, minted);
        }

        currentlyMinted = minted;
        saleRoundMinted = roundMinted;
        mintedPerAddress[to] += howManyToMint;
        if (saleRoundMinted == SALE_ROUND_SUPPLY) {
            switchSaleRound();
        }
    }

    function switchSaleRound() private {
        _pause();
        pricePerTokenERC20 += (pricePerTokenERC20 * INCREMENT_PRICE_PERCENT) / (100 * PERCENT_MULTIPLIER);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function startSale() external onlyOwner whenPaused {
        _unpause();
    }

    function stopSale() external onlyOwner whenNotPaused {
        _pause();
    }

    function setBaseTokenURI(string calldata URI) external onlyOwner {
        string memory oldURI = baseTokenURI;
        baseTokenURI = URI;
        emit BaseTokenURIUpdate(oldURI, URI);
    }


    function setPricePerTokenERC20(uint256 newPrice) external onlyOwner {
        pricePerTokenERC20 = newPrice;
        emit SetPricePerTokenERC20(newPrice);
    }

    function getNftRarity(uint256 tokenId) external view returns(uint256) {
        return nftRarity[tokenId];
    }

    function generateNftRarity() internal returns(uint256) {
        uint256 randNum = getRandomNumber(0, 1000);
        if (randNum < CHANCE[2]) return uint(Rarity.LEGENDARY);
        if (randNum < CHANCE[1]) return uint(Rarity.RARE);
        if (randNum < CHANCE[0]) return uint(Rarity.UNCOMMON);
        return uint(Rarity.COMMON);
    }

    function getRandomNumber(uint minNumber, uint maxNumber) internal returns (uint) {
        nonce++;
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % (maxNumber - minNumber);
        randomNumber = randomNumber + minNumber;
        return randomNumber;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Receiver.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}