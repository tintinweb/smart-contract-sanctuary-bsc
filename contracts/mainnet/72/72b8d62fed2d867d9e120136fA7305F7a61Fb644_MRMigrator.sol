/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: Unlicense

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
    constructor () {
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
        require(_owner == _msgSender() || _previousOwner == _msgSender(), "Ownable: caller is not the owner");
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

    function geUnlockTime() public view returns (uint256) {
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

contract MRStakingPoolsForMigration is Context, Ownable {
    using SafeMath for uint256;

    struct Pool {
        uint8 pool;
        string rarity;
        uint256 stakeSize;
        uint256 minStake;
        uint256 apyNoLock;
        uint256 apy15Day;
        uint256 apy30Day;
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
        uint256 lockCount15;
        uint256 lockCount30;
        uint256 noLockTotal;
        uint256 lock15Total;
        uint256 lock30Total;
        uint256 totalInPool;
    }

    IERC20 private _token;
    IERC20 private _rewardToken;
    DDStakingPool public dividendDistributor;
    uint256 distributorGas = 500000;

    mapping(uint => uint256) public poolShare;
    mapping(address => mapping(uint => uint256)) private walletClaimed;
    mapping(address => mapping(uint => uint256)) private walletClaimedRewardToken;
    mapping(uint => uint256) public totalTokenClaimed;
    mapping(uint => uint256) public totalRewardTokenClaimed;
    mapping(uint => uint256) public totalReinvested;
    mapping(address => mapping(uint => bool)) public hasMigrated;

    mapping(address => bool) public isExcludedFromTax;

    mapping(uint => LockCount) lockCounts;



    uint256 public calculationTime = 365 days;
    uint256 public taxPayable = 10;
    bool public isTaxPayable = true;
    uint256 public minThreshold = 100 * 10**18; // 6k token


    mapping(address => mapping(uint => Staker)) public stakers;
    mapping(address => mapping(uint => bool)) private isStaker;
    mapping(uint => Pool) public pools;
    mapping(uint => Staker[]) private stakerSize;
    uint[] public activePoolsArray;
    event Deposit(address indexed wallet, uint pool, uint256 amount);
    event WithdrawStaking(address indexed wallet, uint pool, uint256 amount);
    event WithdrawReturn(address indexed wallet, uint pool, uint256 amount);
    event ReinvestReturn(address indexed wallet, uint pool, uint256 amount);
    event PoolUpdated(uint poolNo, uint256 time);
    event RewardTokenWithdraw(address indexed to, uint256 amount);
    address public migrator;
    bool public openStaking;
    bool public canReinvest = false;

    modifier onlyStakingIsOpen() {
        require(openStaking, "MRStaking: staking is not open yet.");
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

    function deployNewPool(uint8 poolNo_, string memory name,  uint256 minStake_, uint256 apyNoLock, uint256 apy15Day, uint256 apy30Day, uint256 maxStakers) public onlyOwner {
        require(pools[poolNo_].pool == 0, "Pool already present.");
        pools[poolNo_] = Pool(poolNo_, name, maxStakers, minStake_, apyNoLock, apy15Day, apy30Day);
        if(!checkIfPoolInArray(poolNo_) && poolNo_ != 1) {
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
        
        if(stakerSize[activePoolsArray[randomnumber]].length >= pools[activePoolsArray[randomnumber]].stakeSize){
            activePoolsArray[randomnumber] = activePoolsArray[activePoolsArray.length - 1];
            activePoolsArray.pop();
            randomnumber = random();
        }

        return randomnumber;
    }

    function deposit(uint256 amount, uint256 apyTime, uint type_) public onlyStakingIsOpen{
        uint poolNo = type_;
        uint ran;
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;
        
        if(poolNo != 1 && _msgSender() != owner()) {
            require(activePoolsArray.length > 0, "Sorry! All the pools are filled.");
            ran = random();
            poolNo = activePoolsArray[ran]; 
        }

        require(pools[poolNo].pool != 0,"Sorry pool is not set yet.");

        if(pools[poolNo].stakeSize != 0 && _msgSender() != owner()) {
            require(stakerSize[poolNo].length < pools[poolNo].stakeSize, "Pool size reached.");
        }

        require(amount >= pools[poolNo].minStake, "Can not be less than minimum staking size.");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");
        
        _token.transferFrom(_msgSender(), address(this), amount);


        if(!isExcludedFromTax[_msgSender()]) {
            uint256 depositTax = amount.mul(taxPayable).div(10**2);
            amount = amount.sub(depositTax);
        }

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
        
        try
            dividendDistributor.setShare(_msgSender(), staker.amount, poolNo)
        {} catch {}

        
        if(!hasStaked){
            addLockCount(poolNo, apyTime, amount);
            stakerSize[poolNo].push(staker);
        } else {
            uint256 tAmount = amount.add(initialAmount).sub(rAmount);
            if(initialApy > apyTime) {
                apyTime = initialApy;
            }
            _updateStakerSize(_msgSender(), staker, poolNo);
            subLockCount(poolNo, initialApy, initialAmount);
            addLockCount(poolNo, apyTime, tAmount);
        }

        isStaker[_msgSender()][poolNo] = true;

        if(poolNo != 1 && stakerSize[poolNo].length >= pools[poolNo].stakeSize){
            activePoolsArray[ran] = activePoolsArray[activePoolsArray.length - 1];
            activePoolsArray.pop();
        }

        emit Deposit(_msgSender(), poolNo, amount);
    }

    function _stakeTimes(uint256 apyTime) internal view returns(uint256){
        uint256 stakeTimes;
        if(apyTime == 0) {stakeTimes = block.timestamp;}
        if(apyTime == 1) {stakeTimes = block.timestamp.add(15 days);}
        if(apyTime == 2) {stakeTimes = block.timestamp.add(30 days);}
        return stakeTimes;
    }

    function calculateReturn(address account, uint poolNo) public view returns(uint256 amount){
        
        Staker memory staker = stakers[account][poolNo];
        
        Pool memory pool = pools[poolNo];

        if(staker.amount == 0) return 0;
        
        uint256 apyTime = (block.timestamp >= staker.timeStakedFor) ? 0 : staker.apyTime;
        
        uint256 apy;
        
        uint256 timeSpan = block.timestamp.sub(staker.stakeTime);

        if(apyTime == 0) {apy = pool.apyNoLock;}
        if(apyTime == 1) {apy = pool.apy15Day;}
        if(apyTime == 2) {apy = pool.apy30Day;}

        amount = staker.amount.mul(apy).mul(timeSpan).div(calculationTime).div(10**2);
    }

    function claimStaking(uint poolNo) external {
        Staker memory staker = stakers[_msgSender()][poolNo];
        require(staker.amount > 0, "Sorry! you have not staked anything.");
        require(block.timestamp >= staker.timeStakedFor, "Sorry!, staking period not finished.");
        require(isStaker[_msgSender()][poolNo], "Caller is not a staker.");
        uint256 amountToWithdraw = staker.amount;

        if(poolShare[poolNo] >= amountToWithdraw) {
            poolShare[poolNo] = poolShare[poolNo].sub(amountToWithdraw);
        } else {
            poolShare[poolNo] = 0;
        }
    
        _token.transfer(_msgSender(), amountToWithdraw);
        
        _claimReturn(_msgSender(), poolNo);

        try
            dividendDistributor.setShare(_msgSender(), 0, poolNo)
        {} catch {}


        _deleteStakerFromSize(_msgSender(), poolNo);
        isStaker[_msgSender()][poolNo] = false;
        delete(stakers[_msgSender()][poolNo]);
        if(!checkIfPoolInArray(poolNo)){
            activePoolsArray.push(poolNo);
        }
        subLockCount(poolNo, staker.apyTime, amountToWithdraw);
        emit WithdrawStaking(_msgSender(), poolNo, amountToWithdraw);
    }

    function claimReturn(uint poolNo) public {
        _claimReturn(_msgSender(), poolNo);
    }

    function _claimReturn(address account, uint poolNo) internal {
        uint256 returnAmount = calculateReturn(account, poolNo);
        stakers[account][poolNo].stakeTime = block.timestamp;

        walletClaimed[account][poolNo] += returnAmount;
        _token.transfer(account, returnAmount);
        poolShare[poolNo] = (poolShare[poolNo] >= returnAmount) ? poolShare[poolNo].sub(returnAmount) : 0;

        totalTokenClaimed[poolNo] = totalTokenClaimed[poolNo].add(returnAmount);

        uint256 rBalance = _rewardToken.balanceOf(address(this));
        
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance);
        }

        emit WithdrawReturn(account, poolNo, returnAmount);
    }

    function reinvestReturn(uint poolNo) public  {
        require(canReinvest, "MRStaking: Reinvesting is disabled.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo);
        require(stakers[_msgSender()][poolNo].amount > 0, "Sorry! you have not staked anything.");
        stakers[_msgSender()][poolNo].amount += returnAmount;
        stakers[_msgSender()][poolNo].stakeTime = block.timestamp;
        _updateStakerSize(_msgSender(), stakers[_msgSender()][poolNo], poolNo);
        poolShare[poolNo] += returnAmount;
        
        uint256 rBalance = _rewardToken.balanceOf(address(this));
        
        try
            dividendDistributor.setShare(_msgSender(), stakers[_msgSender()][poolNo].amount, poolNo)
        {} catch {}
        
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }


        totalReinvested[poolNo] = totalReinvested[poolNo].add(returnAmount);
        emit ReinvestReturn(_msgSender(), poolNo, returnAmount);
    }

    function updatePool(uint8 poolNo_, string memory rarity_, uint256 stakeSize_, uint256 minStake_, uint256 apyNoLock_, uint256 apy15Day_, uint256 apy30Day_) public onlyOwner {
        Pool memory pool = pools[poolNo_];
        
        pool.pool = poolNo_;
        pool.rarity = rarity_;
        pool.stakeSize = stakeSize_;
        pool.minStake = minStake_;
        pool.apyNoLock = apyNoLock_;
        pool.apy15Day = apy15Day_;
        pool.apy30Day = apy30Day_;

        if(poolNo_ != 1 && stakeSize_ > pools[poolNo_].stakeSize) {
            if(!checkIfPoolInArray(poolNo_)){
                activePoolsArray.push(poolNo_);
            }
        }
        
        pools[poolNo_] = pool;
        emit PoolUpdated(poolNo_, block.timestamp);
    }

    function totalStakers(uint poolNo) public view returns(uint256){
        return stakerSize[poolNo].length;
    }

    function _updateStakerSize(address account, Staker memory staker, uint poolNo) internal {
        uint256 index;
        for(uint256 i; i < stakerSize[poolNo].length; i++){
            if(stakerSize[poolNo][i].wallet == account){
                index = i;
                break;
            }
        }
        stakerSize[poolNo][index].amount = staker.amount;
        stakerSize[poolNo][index].apyTime = staker.apyTime;
        stakerSize[poolNo][index].timeStakedFor = staker.timeStakedFor;
        stakerSize[poolNo][index].stakeTime = staker.stakeTime;
    }

    function isWalletStaker(address account, uint poolNo) external view returns(bool) {
        return isStaker[account][poolNo];
    }

    function _deleteStakerFromSize(address account, uint poolNo) internal {
        uint256 index;
        for(uint256 i; i < stakerSize[poolNo].length; i++){
            if(stakerSize[poolNo][i].wallet == account){
                index = i;
                break;
            }
        }

        for(uint256 i = index; i < stakerSize[poolNo].length - 1; i++){
            stakerSize[poolNo][i] = stakerSize[poolNo][i+1];
        }

        delete(stakerSize[poolNo][stakerSize[poolNo].length -1]);
        stakerSize[poolNo].pop();
    }
    
    function sendToken(address recipient, uint256 amount) public onlyOwner {
        _token.transfer(recipient, amount);
    }

    function claimTokens(address recipient, uint256 amount) public onlyOwner {
        _rewardToken.transfer(recipient, amount);
    }

    function claimBNB(address payable account) public onlyOwner {
        account.transfer(address(this).balance);
    }

    function totalPoolStakers(uint poolNo) public view returns(uint256){
        return stakerSize[poolNo].length;
    }

    function totalTokenClaimedByWallet(address account, uint poolNo) public view returns(uint256){
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

    function activePoolsCount() public view returns(uint256){
        return activePoolsArray.length;
    }

    function addLockCount(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount += 1; lockCount.noLockTotal += amount; }
        if(apy == 1) { lockCount.lockCount15 += 1; lockCount.lock15Total += amount;}
        if(apy == 2) { lockCount.lockCount30 += 1; lockCount.lock30Total += amount;}
        lockCount.totalInPool += amount;
        lockCounts[poolNo] = lockCount;
    }

    function updateLockCount(uint poolNo, uint256 initialApy, uint256 apy, uint256 initialAmount, uint256 amount) internal {
        if(initialApy > apy) {
            apy = initialApy;
        }
        subLockCount(poolNo, initialApy, initialAmount);
        addLockCount(poolNo, apy, amount.add(initialAmount));
    }

    function subLockCount(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount = (lockCount.noLockCount != 0) ? lockCount.noLockCount.sub(1): 0; lockCount.noLockTotal = (lockCount.noLockTotal >= amount) ? lockCount.noLockTotal.sub(amount) : 0; }
        if(apy == 1) { lockCount.lockCount15 = (lockCount.lockCount15 != 0) ? lockCount.lockCount15.sub(1): 0; lockCount.lock15Total = (lockCount.lock15Total >= amount) ? lockCount.lock15Total.sub(amount): 0; }
        if(apy == 2) { lockCount.lockCount30 = (lockCount.lockCount30 != 0) ? lockCount.lockCount30.sub(1) : 0; lockCount.lock30Total = (lockCount.lock30Total >= amount) ? lockCount.lock30Total.sub(amount): 0; }
        lockCount.totalInPool = (lockCount.totalInPool >= amount) ? lockCount.totalInPool.sub(amount) : 0;
        lockCounts[poolNo] = lockCount;
    }

    function getTotalLockCount() public view returns(LockCount memory lockCountTotal) {
        
        for(uint i = 1; i <= 5; i++) {
            LockCount memory lockCount = lockCounts[i];
            lockCountTotal.noLockCount += lockCount.noLockCount;
            lockCountTotal.lockCount15 += lockCount.lockCount15;
            lockCountTotal.lockCount30 += lockCount.lockCount30;
            lockCountTotal.noLockTotal += lockCount.noLockTotal;
            lockCountTotal.lock15Total += lockCount.lock15Total;
            lockCountTotal.lock30Total += lockCount.lock30Total;
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

    function migrate(address toStaker, uint256 amount, uint256 apyTime, uint type_, uint256 timeStakedFor, uint256 stakeTime) public onlyMigrator {
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;
        if(type_ != 5 && toStaker != owner()) {
            type_ += 1;
        }


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

        try
            dividendDistributor.setShare(toStaker, staker.amount, poolNo)
        {} catch {}
        
        if(!hasStaked){
            addLockCount(poolNo, apyTime, amount);
            stakerSize[poolNo].push(staker);
        } else {
            uint256 tAmount = amount.add(initialAmount).sub(rAmount);
            if(initialApy > apyTime) {
                apyTime = initialApy;
            }
            _updateStakerSize(toStaker, staker, poolNo);
            subLockCount(poolNo, initialApy, initialAmount);
            addLockCount(poolNo, apyTime, tAmount);
        }
        isStaker[toStaker][poolNo] = true;
        emit Deposit(toStaker, poolNo, amount);

    }

    function updateStakingOpenStatus(bool status_) public onlyOwner {
        openStaking = status_;
    }

    function enableReinvest(bool canReinvest_) public onlyOwner {
        canReinvest = canReinvest_;
    }

    function relock(uint256 apyTime_, uint poolNo_) public {
        Staker memory staker = stakers[_msgSender()][poolNo_];
        require(staker.amount != 0, "MRStaking: caller has no staking in this pool");
        require(staker.apyTime == 0, "MRStaking: caller has alredy locked the staking.");
        staker.apyTime = apyTime_;
        staker.timeStakedFor = _stakeTimes(apyTime_);
        staker.stakeTime = block.timestamp;
        stakers[_msgSender()][poolNo_] = staker;
    }

    receive() external payable{}
}

contract MRStaking is Context, Ownable {
    using SafeMath for uint256;

    IERC20 private _token;
    IERC20 private _rewardToken;

    mapping(address => uint256) public walletClaimed;
    uint256 public totalTokenClaimed;
    uint256 public totalRewardTokenClaimed;
    uint256 public totalReinvested;

    uint256 public calculationTime = 365 days;
    uint8 public poolNo = 1;

    struct Pool {
        uint8 pool;
        string rarity;
        uint256 stakeSize;
        uint256 minStake;
        uint256 apyNoLock;
        uint256 apy15Day;
        uint256 apy30Day;
    }

    struct Staker {
        address wallet;
        uint8 poolNo;
        uint256 amount;
        uint256 apyTime;
        uint256 timeStakedFor;
        uint256 stakeTime; 
    }

    mapping(address => Staker) public stakers;
    mapping(address => bool) public isStaker;
    Staker[] public stakerSize;
    Pool public pool;

    event Deposit(address indexed wallet, uint8 pool, uint256 amount);
    event WithdrawStaking(address indexed wallet, uint8 pool, uint256 amount);
    event WithdrawReturn(address indexed wallet, uint8 pool, uint256 amount);
    event ReinvestReturn(address indexed wallet, uint8 pool, uint256 amount);
    event PoolUpdated(uint8 poolNo, uint256 time);
    event RewardTokenWithdraw(address indexed to, uint256 amount);

    constructor(IERC20 token_, IERC20 rewardToken_, uint8 poolNo_, string memory name,  uint256 minStake_, uint256 apyNoLock, uint256 apy15Day, uint256 apy30Day, uint256 maxStakers){
        _token = token_;
        _rewardToken = rewardToken_;       
        pool = Pool(poolNo_, name, maxStakers, minStake_, apyNoLock, apy15Day, apy30Day);
    }

    receive() external payable{}

    function _claimableRewardToken(address account) internal view returns(uint256){
        if(_token.balanceOf(address(this)) <= 0) {
            return 0;
        }
        uint256 balance = _rewardToken.balanceOf(address(this));
        uint256 grandTotal = balance.add(totalRewardTokenClaimed);
        uint256 myHolding = stakers[_msgSender()].amount.div(_token.balanceOf(address(this))).mul(10**2);
        uint256 withdrawable = grandTotal.mul(myHolding).div(10**2);
        uint256 finalWithdrawable = withdrawable.sub(walletClaimed[account]);
        return finalWithdrawable;
    }


    function claimRewardToken(address account) public onlyOwner {
        require(stakers[account].amount > 0, "You have not staking.");
        uint256 amountToWithdraw = _claimableRewardToken(account);
        require(amountToWithdraw > 0, "Not enough balance to claim.");
        walletClaimed[account] = walletClaimed[account].add(amountToWithdraw);
        totalRewardTokenClaimed = totalRewardTokenClaimed.add(amountToWithdraw);
        _rewardToken.transfer(account, amountToWithdraw);
        emit RewardTokenWithdraw(account, amountToWithdraw);
    }

    function claimDividend() public onlyOwner {
        _token.claim();
    }

    function totalRewardTokenInPool() public view returns(uint256){
        return _rewardToken.balanceOf(address(this));
    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s, address owner_) internal pure returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return (signer == owner_);
    }
}

contract MRMigrator is Context, Ownable{
    using SafeMath for uint256;
    IERC20 public token;
    IERC20 public rewardToken;

    bool public isMigrationOn;
    mapping(address => mapping(uint => bool)) public hasMigrated;
    MRStakingPoolsForMigration public migrateTo;

    mapping(uint => uint256) public totalPoolMigrated;

    address public stakingContract;

    mapping(address => bool) public lockWallet;

    constructor(address migrateTo_, IERC20 token_, IERC20 rewardToken_) {
        token = token_;
        rewardToken = rewardToken_;
        migrateTo = MRStakingPoolsForMigration(payable(migrateTo_));
        stakingContract = 0xddfE6357eB3184AFb8F16C7c8143C37dEFafcD26;

    }


    function openMigration(bool status) public onlyOwner {
        isMigrationOn = status;
    }

    function updateOldStakingContract(address contractAddr) public onlyOwner {
        stakingContract = contractAddr;
    }

    function getWalletInfo(address wallet, uint pool) public view returns(uint256) {
        MRStakingPoolsForMigration staking = MRStakingPoolsForMigration(payable(stakingContract));
        return staking.getStakerInfo(wallet, pool).amount;
    }

    function migration(uint poolNo_) public {
        _checkIfTester(_msgSender(), poolNo_);
        MRStakingPoolsForMigration staking = MRStakingPoolsForMigration(payable(stakingContract));
        uint256 amount = staking.getStakerInfo(_msgSender(), poolNo_).amount;
        uint256 timeStakedFor = staking.getStakerInfo(_msgSender(), poolNo_).timeStakedFor;
        uint256 stakeTime = staking.getStakerInfo(_msgSender(), poolNo_).stakeTime;
        uint256 apyTime = staking.getStakerInfo(_msgSender(), poolNo_).apyTime;
        require(amount != 0, "Migration: caller has no staking in this pool.");
        migrateTo.migrate(_msgSender(), amount, apyTime, poolNo_, timeStakedFor, stakeTime);
    }

    function _checkIfTester(address addr, uint poolNo_) internal {
        require(address(migrateTo) != address(0), "Migration: new migration is not set.");
        require(!lockWallet[addr], "Migration is not possible.");
        require(isMigrationOn, "Migration: migration is not open.");
        require(!hasMigrated[addr][poolNo_], "Migration: caller has already migrated.");
        hasMigrated[addr][poolNo_] = true;
        totalPoolMigrated[poolNo_] += 1;
    }

    function hasWalletMigrated(address account, uint poolNo) public view returns(bool) {
        return hasMigrated[account][poolNo];
    }

    function updateTokens(IERC20 token_, IERC20 rewardToken_) public onlyOwner {
        token = token_;
        rewardToken = rewardToken_;
    }

    function claimTokens(address account, uint256 amount) public onlyOwner {
        token.transfer(account, amount);
    }

    function claimRewardToken(address account, uint256 amount) public onlyOwner {
        rewardToken.transfer(account, amount);
    }

    function updateMigrateTo(address newMigrateTo) public onlyOwner {
        migrateTo = MRStakingPoolsForMigration(payable(newMigrateTo));
    }

    function totalPoolMigration(uint poolNo_) public view returns(uint256){
        return totalPoolMigrated[poolNo_];
    }

    function lockWallets(address walletAddr, bool status_) public onlyOwner{
        lockWallet[walletAddr] = status_;
    }
}