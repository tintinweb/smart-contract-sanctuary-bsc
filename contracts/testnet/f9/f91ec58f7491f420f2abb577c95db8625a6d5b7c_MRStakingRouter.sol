/**
 *Submitted for verification at BscScan.com on 2022-02-17
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
        _previousOwner = _owner;
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
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

    function getTokenInfo() public view returns(address, address){
        return (address(_token), address(_rewardToken));
    }

    function updateTokens(IERC20 token_, IERC20 rewardToken_) public onlyOwner {
        _token = token_;
        _rewardToken = rewardToken_;
    }

    function myRewardTokenReward(address account) public view returns(uint256){
       return _claimableRewardToken(account);
    }

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

    function deposit(address account, uint256 amount, uint256 apyTime, bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) public onlyOwner {
        require(verifyMessage(_hashedMessage, _v, _r, _s, account), "Signed message does not match");
        if(pool.stakeSize > 0) {
            require(stakerSize.length < pool.stakeSize, "Pool size reached.");
        }
        require(amount >= pool.minStake, "Can not be less than minimum staking size.");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");
        _token.transferFrom(_msgSender(), address(this), amount);
        uint256 rAmount = calculateReturn(account);
        amount = amount.add(rAmount);
        stakers[account].wallet = account;
        stakers[account].poolNo = poolNo;
        stakers[account].amount += amount;
        stakers[account].apyTime = apyTime;
        stakers[account].timeStakedFor = _stakeTimes(apyTime);
        stakers[account].stakeTime = block.timestamp;

        if(!isStaker[account]){
            stakerSize.push(stakers[account]);
        } else {
            _updateStakerSize(account, stakers[account]);
        }
        
        isStaker[account] = true;
        emit Deposit(account, poolNo, amount);
    }

    function _stakeTimes(uint256 apyTime) internal view returns(uint256){
        uint256 stakeTimes;
        if(apyTime == 0) {stakeTimes = block.timestamp;}
        if(apyTime == 1) {stakeTimes = block.timestamp.add(15 days);}
        if(apyTime == 2) {stakeTimes = block.timestamp.add(30 days);}
        return stakeTimes;
    }

    function calculateReturn(address account) public view returns(uint256){
        if(stakers[account].amount == 0) {
            return 0;
        }
        uint256 apy;
        uint256 returnAmount;
        uint256 timeSpan = block.timestamp.sub(stakers[account].stakeTime);
        if(stakers[account].apyTime == 0) {apy = pool.apyNoLock;}
        if(stakers[account].apyTime == 1) {apy = pool.apy15Day;}
        if(stakers[account].apyTime == 2) {apy = pool.apy30Day;}
        returnAmount = stakers[account].amount.mul(apy).mul(timeSpan).div(calculationTime).div(10**2);
        return returnAmount;
    }

    function claimStaking(address account) public onlyOwner {
        uint256 returnAmount = calculateReturn(account);
        require(stakers[account].amount > 0, "Sorry! you have not staked anything.");
        require(block.timestamp >= stakers[account].timeStakedFor, "Sorry!, staking perioud not finished.");
        uint256 amountToWithdraw = returnAmount.add(stakers[account].amount);
        stakers[account].amount = 0;
        _token.transfer(account, amountToWithdraw);
        _claimableRewardToken(account);
        _updateStakerSize(account, stakers[account]);
        _deleteStakerFromSize(account);
        isStaker[account] = false;
        emit WithdrawStaking(account, poolNo, amountToWithdraw);
    }

    function claimReturn(address account) public onlyOwner {
        uint256 returnAmount = calculateReturn(account);
        require(stakers[account].amount > 0, "Sorry! you have not staked anything.");
        stakers[account].stakeTime = block.timestamp;
        _token.transfer(account, returnAmount);
        totalTokenClaimed = totalTokenClaimed.add(returnAmount);
        emit WithdrawReturn(account, poolNo, returnAmount);
    }

    function reinvestReturn(address account) public onlyOwner {
        uint256 returnAmount = calculateReturn(account);
        require(stakers[account].amount > 0, "Sorry! you have not staked anything.");
        stakers[account].amount += returnAmount;
        stakers[account].stakeTime = block.timestamp;
        _updateStakerSize(account, stakers[account]);
        totalReinvested = totalReinvested.add(returnAmount);
        emit ReinvestReturn(account, poolNo, returnAmount);
    }

    function updatePool(uint8 poolNo_, string memory rarity_, uint256 stakeSize_, uint256 minStake_, uint256 apyNoLock_, uint256 apy15Day_, uint256 apy30Day_) public onlyOwner {
        poolNo = poolNo_;
        pool.pool = poolNo_;
        pool.rarity = rarity_;
        pool.stakeSize = stakeSize_;
        pool.minStake = minStake_;
        pool.apyNoLock = apyNoLock_;
        pool.apy15Day = apy15Day_;
        pool.apy30Day = apy30Day_;
        emit PoolUpdated(poolNo, block.timestamp);
    }

    function totalStakers() public view returns(uint256){
        return stakerSize.length;
    }

    function _updateStakerSize(address account, Staker memory staker) internal {
        uint256 index;
        for(uint256 i; i < stakerSize.length; i++){
            if(stakerSize[i].wallet == account){
                index = i;
                break;
            }
        }
        stakerSize[index].amount = staker.amount;
        stakerSize[index].apyTime = staker.apyTime;
        stakerSize[index].timeStakedFor = staker.timeStakedFor;
        stakerSize[index].stakeTime = staker.stakeTime;
    }

    function _deleteStakerFromSize(address account) internal {
        uint256 index;
        for(uint256 i; i < stakerSize.length; i++){
            if(stakerSize[i].wallet == account){
                index = i;
                break;
            }
        }

        for(uint256 i = index; i < stakerSize.length - 1; i++){
            stakerSize[i] = stakerSize[i+1];
        }

        delete(stakerSize[stakerSize.length -1]);
        stakerSize.pop();
    }

    
    function sendToken(address recipient, uint256 amount) public onlyOwner {
        _token.transfer(recipient, amount);
    }

    function sendRewardToken(address recipient, uint256 amount) public onlyOwner {
        _rewardToken.transfer(recipient, amount);
    }

    function claimBNB(address payable account) public onlyOwner {
        account.transfer(address(this).balance);
    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s, address owner_) internal pure returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return (signer == owner_);
    }
}


contract MRStakingRouter is Context, Ownable {

    IERC20 public token;

    mapping(uint8 => MRStaking) public pools;

    constructor(IERC20 token_) {
        token = token_;
    }

    function deployNewStakingPool(IERC20 token_, IERC20 rewardToken_, uint8 poolNo_, string memory name, uint256 minStake_, uint256 apyNoLock, uint256 apy15Day, uint256 apy30Day, uint256 minStakeSize_) public onlyOwner {
        require(address(pools[poolNo_]) == address(0), "Address already present.");
        pools[poolNo_] = new MRStaking(token_,rewardToken_, poolNo_, name, minStake_,apyNoLock,apy15Day, apy30Day, minStakeSize_);
    }

    function stakers(address account, uint8 pool_) public view returns(address, uint8, uint256, uint256, uint256, uint256) {
        return pools[pool_].stakers(account);
    }

    function pool(uint8 poolNo_) public view returns(uint8, string memory, uint256, uint256, uint256, uint256, uint256) {
        return pools[poolNo_].pool();
    }

    function isStaker(address account, uint8 pool_) public view returns(bool) {
        return pools[pool_].isStaker(account);
    }

    function walletClaimed(address account, uint8 pool_) public view returns(uint256){
        return pools[pool_].walletClaimed(account);
    }

    function totalTokenClaimed(uint8 pool_) public view returns(uint256){
        return pools[pool_].totalTokenClaimed();
    }

    function totalRewardTokenClaimed(uint8 pool_) public view returns(uint256) {
        return pools[pool_].totalRewardTokenClaimed();
    }

    function totalReinvested(uint8 pool_) public view returns(uint256){
        return pools[pool_].totalReinvested();
    }

    function getTokenInfo(uint8 pool_) public view returns(address, address){
        return pools[pool_].getTokenInfo();
    }

    function updateTokens(IERC20 token_, IERC20 rewardToken_, uint8 pool_) public onlyOwner {
       pools[pool_].updateTokens(token_, rewardToken_);
    }

    function myRewardTokenReward(address account, uint8 pool_) public view returns(uint256){
       return pools[pool_].myRewardTokenReward(account);
    }


    function claimRewardToken(uint8 pool_) public {
        pools[pool_].claimRewardToken(_msgSender());
    }

    function claimDividend(uint8 pool_) public onlyOwner {
        pools[pool_].claimDividend();
    }

    function totalRewardTokenInPool(uint8 pool_) public view returns(uint256){
        return pools[pool_].totalRewardTokenInPool();
    }

    function deposit(uint8 pool_, uint256 amount, uint256 apyTime, bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) public {
        require(address(pools[pool_]) != address(0), "Pool is not set yet.");
        require(token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");
        token.transferFrom(_msgSender(), address(this), amount);
        token.approve(address(pools[pool_]), amount);
        pools[pool_].deposit(_msgSender(), amount, apyTime, _hashedMessage,  _v,  _r,  _s);
    }


    function calculateReturn(address account, uint8 pool_) public view returns(uint256){
        return pools[pool_].calculateReturn(account);
    }

    function claimStaking(uint8 pool_) public {
        pools[pool_].claimStaking(_msgSender());
    }

    function claimReturn(uint8 pool_) public {
        pools[pool_].claimReturn(_msgSender());
    }

    function reinvestReturn(uint8 pool_) public {
        pools[pool_].reinvestReturn(_msgSender());
    }

    function updatePool(uint8 poolNo_, string memory name, uint256 stakeSize_, uint256 minStake_, uint256 apyNoLock_, uint256 apy15Day_, uint256 apy30Day_) public onlyOwner {
       pools[poolNo_].updatePool(poolNo_,name, stakeSize_, minStake_, apyNoLock_, apy15Day_, apy30Day_);
    }

    function totalStakers(uint8 pool_) public view returns(uint256){
        return pools[pool_].totalStakers();
    }

    
    function sendToken(uint8 pool_, uint256 amount) public onlyOwner {
        pools[pool_].sendToken(_msgSender(), amount);
    }

    function sendRewardToken(uint8 pool_, uint256 amount) public onlyOwner {
        pools[pool_].sendRewardToken(_msgSender(), amount);
    }

    function claimBNB(uint8 pool_) public onlyOwner {
        pools[pool_].claimBNB(_msgSender());
    }

    function updatePool(uint8 poolNo, address payable poolAddress) public onlyOwner {
        pools[poolNo] = MRStaking(poolAddress);
    }

    function updateToken(IERC20 tokenAddress) public onlyOwner {
        token = tokenAddress;
    }

    receive() external payable{}
}