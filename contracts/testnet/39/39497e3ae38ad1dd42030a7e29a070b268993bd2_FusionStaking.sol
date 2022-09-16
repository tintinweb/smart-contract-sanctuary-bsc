/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



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


contract FusionStaking is Ownable{
    IERC20 public rewardsToken;// Contract address of reward token
    IERC20 public stakingToken;// Contract address of staking token

    struct poolType{
        string poolName;
        uint stakingDuration;
        uint APY; // is in % (e.g 40%)
        uint minimumDeposit; // passed in as wei
        uint totalStaked;
        mapping(address => uint256) userStakedBalance;
        mapping(address => bool) hasStaked;
        mapping(address => uint) lastTimeUserStaked;
        address[] stakers;
        bool stakingIsPaused;
        bool poolIsInitialized;
    }

    address public feeReceiver; // address to send early unstaking fee

    mapping(uint => poolType) public pool;
    uint poolIndex;
    uint[] public poolIndexArray;

    constructor(address _stakingToken, address _rewardsToken, address administratorAddress, address _feeReceiver) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        _transferOwnership(administratorAddress);
        feeReceiver = _feeReceiver;
        poolIndex = 0;
    }

    function createPool(
        string memory _poolName,
        uint _stakingDuration,
        uint _APY,
        uint _minimumDeposit
    ) external onlyOwner returns(uint _createdPoolIndex){

        pool[poolIndex].poolName = _poolName;
        pool[poolIndex].stakingDuration = _stakingDuration;
        pool[poolIndex].APY = _APY;
        pool[poolIndex].minimumDeposit = _minimumDeposit;
        pool[poolIndex].poolIsInitialized = true;

        poolIndexArray.push(poolIndex);
        poolIndex += 1;

        return (poolIndex - 1);
    }


    /**
    *   Function to stake the token
    *
    *   @dev Approval should first be granted to this contract to pull
    *   "_amount" of Fusion tokens from the caller's wallet, before the
    *   aller can call this function
    *
    *   "_amount" should be passed in as wei
    *
     */
    function stake(uint _amount, uint poolID) public {
        require(pool[poolID].poolIsInitialized == true, "Pool does not exist");
        require(pool[poolID].stakingIsPaused == false, "Staking in this pool is currently Paused. Please contact admin");
        require(pool[poolID].hasStaked[msg.sender] == false, "You currently have a stake in this pool. You have to Unstake.");
        require(_amount >= pool[poolID].minimumDeposit, "stake(): You are trying to stake below the minimum for this pool");

        pool[poolID].totalStaked += _amount;

        pool[poolID].userStakedBalance[msg.sender] += _amount;

        stakingToken.transferFrom(msg.sender, address(this), _amount);

        pool[poolID].stakers.push(msg.sender);
        pool[poolID].hasStaked[msg.sender] = true;
        pool[poolID].lastTimeUserStaked[msg.sender] = block.timestamp;


    }

    function calculateUserRewards(address userAddress, uint poolID) public view returns(uint){

        if(pool[poolID].hasStaked[userAddress] == true){
            uint lastTimeStaked = pool[poolID].lastTimeUserStaked[userAddress];
            uint periodSpentStaking = block.timestamp - lastTimeStaked;

            uint userStake_wei = pool[poolID].userStakedBalance[userAddress];
            uint userStake_notWei = userStake_wei / 1e6; //remove SIX zeroes.
            uint userReward_inWei = userStake_notWei * pool[poolID].APY * ((periodSpentStaking * 1e4) / 365 days); // reward period is yearly

            return userReward_inWei;
        }else{
            return 0;
        }
    }

    // Function to claim rewards & unstake tokens
    function claimReward(uint _poolID) external {
        require(pool[_poolID].hasStaked[msg.sender] == true, "You currently have no stake in this pool.");

        uint stakeTime = pool[_poolID].lastTimeUserStaked[msg.sender];

        uint claimerStakedBalance = pool[_poolID].userStakedBalance[msg.sender];

        /**
        * If claiming before duration, deduct 20% and send to projectOwner
        *
        * */
        if((block.timestamp - stakeTime) < pool[_poolID].stakingDuration){

            uint stakedBalance_notWei = claimerStakedBalance / 1e6;
            uint twentyPercentFee_wei = (stakedBalance_notWei * 20) * 1e4;

            // deduct 20% from stake balance
            claimerStakedBalance -= twentyPercentFee_wei;
            pool[_poolID].userStakedBalance[msg.sender] -= twentyPercentFee_wei;

            // send 20% to receiver
            stakingToken.transfer(feeReceiver, twentyPercentFee_wei);

            // send claimer his remaining 80%
            pool[_poolID].userStakedBalance[msg.sender] = 0;
            stakingToken.transfer(msg.sender, claimerStakedBalance);

            pool[_poolID].totalStaked -= (claimerStakedBalance + twentyPercentFee_wei);
            pool[_poolID].hasStaked[msg.sender] = false;

        }else{

            uint reward = calculateUserRewards(msg.sender, _poolID);
            require(reward > 0, "Rewards is too small to be claimed");

            rewardsToken.transfer(msg.sender, reward);

            // decrease balance before transfer to prevent re-entrancy

            pool[_poolID].userStakedBalance[msg.sender] = 0;
            stakingToken.transfer(msg.sender, claimerStakedBalance);

            pool[_poolID].totalStaked -= claimerStakedBalance;
            pool[_poolID].hasStaked[msg.sender] = false;

        }
    }

    function togglePausePool(uint _poolID) external onlyOwner{
        pool[_poolID].stakingIsPaused = !pool[_poolID].stakingIsPaused;

        getPoolState(_poolID);
    }

    function getPoolState(uint _poolID) public view returns(bool _stakingIsPaused){
        return pool[_poolID].stakingIsPaused;
    }

    function adjustAPY(uint _poolID, uint _newAPY) public onlyOwner{

        pool[_poolID].APY = _newAPY;
    }

    function getAPY(uint _poolID) public view returns (uint){
        return pool[_poolID].APY;
    }

    function getTotalStaked() public view returns(uint){
        uint totalStakedInAllPools;
        for (uint256 i = 0; i < poolIndexArray.length; i++) {
            totalStakedInAllPools += pool[i].totalStaked;
        }

        return totalStakedInAllPools;
    }

    function getUserStakingBalance(uint poolID, address userAddress) public view returns (uint){
        return pool[poolID].userStakedBalance[userAddress];
    }


}