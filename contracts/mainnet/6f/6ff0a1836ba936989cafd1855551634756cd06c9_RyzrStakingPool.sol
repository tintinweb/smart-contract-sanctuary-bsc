/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

contract Administration is Context {
    address private _admin;
    address private _previousAdmin;
    uint256 private _lockTime;

    event ChangeAdministrator(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @dev Initializes the contract setting the deployer as the initial admin.
     */
    constructor () {
        address msgSender = _msgSender();
        _admin = msgSender;
        _previousAdmin = msgSender;
        emit ChangeAdministrator(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current admin.
     */
    function admin() public view returns (address) {
        return _admin;
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Administration: caller is not the admin");
        _;
    }

     /**
     * @dev Leaves the contract without admin. It will not be possible to call
     * `onlyAdmin` functions anymore. Can only be called by the current admin.
     *
     * NOTE: Renouncing admin role will leave the contract without an admin,
     * thereby removing any functionality that is only available to the admin.
     */
    function renounceAdminRole() public virtual onlyAdmin {
        emit ChangeAdministrator(_admin, address(0));
        _admin = address(0);
    }

    /**
     * @dev Transfers admin role of the contract to a new account (`newAdmin`).
     * Can only be called by the current admin.
     */
    function changeAdmin(address newAdmin) public virtual onlyAdmin {
        require(newAdmin != address(0), "Administration: new admin is the zero address");
        emit ChangeAdministrator(_admin, newAdmin);
        _admin = newAdmin;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
}

contract RyzrStakingPool is Context, Administration {
    using SafeMath for uint256;

    struct Pool {
        uint8 pool;
        string rarity;
        uint256 amountPooled;
        uint256 minStake;
        uint256 APY;
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
        uint256 noLockTotal;
        uint256 totalInPool;
    }

    IERC20 private _token;
    mapping(uint => uint256) public poolShare;
    mapping(address => mapping(uint => uint256)) private walletClaimed;
    mapping(uint => uint256) public totalTokenClaimed;
    mapping(uint => uint256) public totalReinvested;
    mapping(address => mapping(uint => bool)) public hasMigrated;
    mapping(address => bool) public isExcludedFromTax;
    mapping(uint => LockCount) lockCounts;

    uint256 public calculationTime = 365 days;
    uint256 public taxPayable = 0;

    bool public isTaxPayable = true;

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

    address public migrator;

    bool public openStaking = false;
    bool public canReinvest = false;

    modifier onlyStakingIsOpen() {
        require(openStaking, "Staking: staking is not open yet.");
        _;
    }

    modifier onlyMigrator() {
        require(_msgSender() == migrator, "Migrator: caller is not the migrator.");
        _;
    }

    constructor(IERC20 token_) {
        _token = token_;
        isExcludedFromTax[_msgSender()] = true;      
    }

    function deployNewPool(uint8 poolNo_, string memory name, uint256 amountPooled, uint256 minStake_, uint256 APY) public onlyAdmin {
        require(pools[poolNo_].pool == 0, "Pool already present.");
        pools[poolNo_] = Pool(poolNo_, name, amountPooled, minStake_, APY);
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

    function getTokenInfo() public view returns(address){
        return (address(_token));
    }

    function updateTokens(IERC20 token_) public onlyAdmin {
        _token = token_;
    }

    function claimDividend() public onlyAdmin {
        _token.claim();
    }

    function random() internal view returns (uint) {
        uint randomness = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.timestamp))) % 100000;
        uint randomnumber = randomness % activePoolsArray.length;
        return randomnumber;
    }

    function deposit(uint256 amount, uint256 apyTime, uint poolNumber_) public onlyStakingIsOpen{
        uint poolNo = poolNumber_;
        uint ran;
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;
        
        if(poolNo != 1 && _msgSender() != admin()) {
            require(activePoolsArray.length > 0, "Sorry, all the pools are filled.");
            ran = random();
            poolNo = activePoolsArray[ran]; 
        }

        require(pools[poolNo].pool != 0,"Sorry, pool is not set yet.");

        LockCount memory lockCount = lockCounts[poolNo];
        require(amount >= pools[poolNo].minStake, "Can not be less than minimum staking size.");
        require(pools[poolNo].amountPooled >= (amount + lockCount.totalInPool), "Sorry, this pool is filled.");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve this staking contract to spend your tokens first.");
        
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
        emit Deposit(_msgSender(), poolNo, amount);
    }

    function _stakeTimes(uint256 apyTime) internal view returns(uint256){
        uint256 stakeTimes;
        if(apyTime == 0) {stakeTimes = block.timestamp;}
        return stakeTimes;
    }

    function calculateReturn(address account, uint poolNo) public view returns(uint256 amount){
        
        Staker memory staker = stakers[account][poolNo];
        
        Pool memory pool = pools[poolNo];

        if(staker.amount == 0) return 0;
        
        uint256 apyTime = (block.timestamp >= staker.timeStakedFor) ? 0 : staker.apyTime;
        
        uint256 apy;
        
        uint256 timeSpan = block.timestamp.sub(staker.stakeTime);

        if(apyTime == 0) {apy = pool.APY;}
        amount = staker.amount.mul(apy).mul(timeSpan).div(calculationTime).div(10**2);
    }

    function claimStaking(uint poolNo) external {
        Staker memory staker = stakers[_msgSender()][poolNo];
        require(staker.amount > 0, "Sorry, you have not staked anything.");
        require(block.timestamp >= staker.timeStakedFor, "Sorry, staking period not finished.");
        require(isStaker[_msgSender()][poolNo], "Caller is not a staker.");
        uint256 amountToWithdraw = staker.amount;

        if(poolShare[poolNo] >= amountToWithdraw) {
            poolShare[poolNo] = poolShare[poolNo].sub(amountToWithdraw);
        } else {
            poolShare[poolNo] = 0;
        }
    
        _token.transfer(_msgSender(), amountToWithdraw);
        
        _claimReturn(_msgSender(), poolNo);

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

        emit WithdrawReturn(account, poolNo, returnAmount);
    }

    function reinvestReturn(uint poolNo) public  {
        require(canReinvest, "RYZRStaking: Reinvesting is disabled.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo);
        require(stakers[_msgSender()][poolNo].amount > 0, "Sorry, you have not staked anything.");
        stakers[_msgSender()][poolNo].amount += returnAmount;
        stakers[_msgSender()][poolNo].stakeTime = block.timestamp;
        _updateStakerSize(_msgSender(), stakers[_msgSender()][poolNo], poolNo);
        poolShare[poolNo] += returnAmount;

        totalReinvested[poolNo] = totalReinvested[poolNo].add(returnAmount);
        emit ReinvestReturn(_msgSender(), poolNo, returnAmount);
    }

    function updatePool(uint8 poolNo_, string memory rarity_, uint256 minStake_, uint256 APY_) public onlyAdmin {
        Pool memory pool = pools[poolNo_];
        
        pool.pool = poolNo_;
        pool.rarity = rarity_;
        pool.minStake = minStake_;
        pool.APY = APY_;        
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
    
    function sendToken(address recipient, uint256 amount) public onlyAdmin {
        _token.transfer(recipient, amount);
    }

    function claimNativeToken(address payable account) public onlyAdmin {
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

    function updateTaxPayable(uint256 newTax) public onlyAdmin {
        taxPayable = newTax;
    }

    function updateIsTaxPayable(bool payable_) public onlyAdmin {
        isTaxPayable = payable_;
    }

    function activePoolsCount() public view returns(uint256){
        return activePoolsArray.length;
    }

    function addLockCount(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount += 1; lockCount.noLockTotal += amount;}
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
        lockCount.totalInPool = (lockCount.totalInPool >= amount) ? lockCount.totalInPool.sub(amount) : 0;
        lockCounts[poolNo] = lockCount;
    }

    function getTotalLockCount() public view returns(LockCount memory lockCountTotal) {
        
        for(uint i = 1; i <= 5; i++) {
            LockCount memory lockCount = lockCounts[i];
            lockCountTotal.noLockCount += lockCount.noLockCount;
            lockCountTotal.noLockTotal += lockCount.noLockTotal;
            lockCountTotal.totalInPool += lockCount.totalInPool;
        }
    }

    function getLockCounts(uint poolNo) public view returns(LockCount memory) {
        return lockCounts[poolNo];
    }

    function excludeFromTax(address account, bool takeTax) public onlyAdmin {
        isExcludedFromTax[account] = takeTax;
    }

    function updateMigrator(address newMigrator) public onlyAdmin {
        migrator = newMigrator;
    }

    function migrate(address toStaker, uint256 amount, uint256 apyTime, uint poolNumber_, uint256 timeStakedFor) public onlyMigrator {
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;
        if(poolNumber_ != 5 && toStaker != admin()) {
            poolNumber_ += 1;
        }


        uint poolNo = poolNumber_;

        require(pools[poolNumber_].pool != 0,"Migration: Sorry pool is not set yet.");

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
        staker.stakeTime = block.timestamp;

        stakers[toStaker][poolNo] = staker;
        
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

    function updateStakingOpenStatus(bool status_) public onlyAdmin {
        openStaking = status_;
    }

    function enableReinvest(bool canReinvest_) public onlyAdmin {
        canReinvest = canReinvest_;
    }

    function relock(uint256 apyTime_, uint poolNo_) public {
        Staker memory staker = stakers[_msgSender()][poolNo_];
        require(staker.amount != 0, "RYZRStaking: caller has no staking in this pool");
        require(apyTime_ != 0, "RYZRStaking: no lock apy passed");
        require(block.timestamp >= staker.timeStakedFor, "RYZRStaking: lock time is not over yet.");
        staker.apyTime = apyTime_;
        staker.timeStakedFor = _stakeTimes(apyTime_);
        staker.stakeTime = block.timestamp;
        stakers[_msgSender()][poolNo_] = staker;
    }

    function approveToken(address spender, uint256 amount) public onlyAdmin {
        _token.approve(spender, amount);
    }

    receive() external payable{}
}