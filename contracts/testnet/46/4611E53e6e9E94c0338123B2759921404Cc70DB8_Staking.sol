/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

/** 
 *  SourceUnit: /home/abc/Documents/ObortechStaking/contracts/Staking.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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




/** 
 *  SourceUnit: /home/abc/Documents/ObortechStaking/contracts/Staking.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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
}




/** 
 *  SourceUnit: /home/abc/Documents/ObortechStaking/contracts/Staking.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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


/** 
 *  SourceUnit: /home/abc/Documents/ObortechStaking/contracts/Staking.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: GPL-3.0
pragma solidity ^0.8.0;
////import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
////import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    /// @title Staking pool creator and a Staking contract.
    /// @notice You can use this contract for making staking pools,staking tokens and getting rewards while unstaking them

    struct stakingPoolInfo {
        uint256 poolId;
        uint256 totalAmountStaked;
        uint256 duration;
        uint256 creationTime;
        uint256 rewardRate;
        bool isStakingAllowed;
    }

    struct stake {
        uint256 amount;
        uint256 lastInteractedTime;
        uint256 stakeStartTime;
        uint256 stakeEndTime;
        address stakingWallet;
        uint256 poolId;
    }
    //Staking pools
    stakingPoolInfo[] public stakingPools;

    //user address to staking pool(poolId) to stake data
    //sender => stakingPoolId => stakeDetails
    mapping(address => mapping(uint256 => stake)) public stakes;

    //Mapping of rewardRate to poolId
    //rewardRate => staking pool(poolId)
    mapping(uint256 => uint256) public getPoolId; //Remove while deploying

    //Staking and Reward Token
    IERC20 public Token;

    //User address to staking pool(poolId) to reward data
    //sender => stakingPoolId => rewardDetails
    mapping(address => mapping(uint256 => uint256)) internal rewards;

    constructor(address _tokenAddress) {
        Token = IERC20(_tokenAddress);
    }

    /// @notice Returns the accumulated reward for a particaular stake
    /// @param _poolId Id of the pool of which rewards amount is requested
    /// @return The exact reward accumulated till now for the partucular stake passed in
    function viewReward(uint256 _poolId) external view returns (uint256) {
        stake memory currentStake = stakes[msg.sender][_poolId];
        if (currentStake.stakingWallet != address(0)) {
            stakingPoolInfo memory currentStakingPool = stakingPools[
                currentStake.poolId
            ];
            uint256 currentStakeTime;

            if (block.timestamp > currentStake.stakeEndTime) {
                currentStakeTime =
                    currentStake.stakeEndTime -
                    currentStake.lastInteractedTime;
            } else {
                currentStakeTime =
                    block.timestamp -
                    currentStake.lastInteractedTime;
            }

            uint256 _rewards = (currentStake.amount *
                currentStakeTime *
                currentStakingPool.rewardRate *
                1e18) /
                (10000 * 31536000) /
                1e18;
            _rewards += rewards[currentStake.stakingWallet][
                currentStake.poolId
            ];
            return _rewards;
        } else return 0;
    }

    function _calculateReward(stake memory currentStake)
        internal
        returns (uint256)
    {
        stakingPoolInfo memory currentStakingPool = stakingPools[
            currentStake.poolId
        ];
        uint256 currentStakeTime;

        if (block.timestamp > currentStake.stakeEndTime) {
            currentStakeTime =
                currentStake.stakeEndTime -
                currentStake.lastInteractedTime;
        } else {
            currentStakeTime =
                block.timestamp -
                currentStake.lastInteractedTime;
        }

        uint256 _rewards = (currentStake.amount *
            currentStakeTime *
            currentStakingPool.rewardRate *
            1e18) /
            (10000 * 31536000) /
            1e18;
        return rewards[msg.sender][currentStake.poolId] += _rewards;
    }

    /// @notice To stake tokens
    /// @param _poolId The Id of the pool in which you want to stake
    /// @param _amount The amount of tokens that you want to stake
    /// @return True if successfully staked
    function stakeToken(uint256 _poolId, uint256 _amount)
        external
        returns (bool)
    {
        //approve the token the user want to stake to address(this)
        stakingPoolInfo memory currentStakingPool = stakingPools[_poolId];
        require(currentStakingPool.isStakingAllowed, "Staking paused");
        if (stakes[msg.sender][_poolId].stakingWallet == address(0)) {
            uint256 currentReward = (_amount *
                currentStakingPool.duration *
                currentStakingPool.rewardRate *
                1e18) /
                (10000 * 31536000) /
                1e18;
            require(
                Token.balanceOf(address(this)) >
                    totalSupply() + totalRewardslocked() + currentReward,
                "All rewards are allotted"
            );
            stake memory newStake = stake({
                amount: _amount,
                lastInteractedTime: block.timestamp,
                stakeStartTime: block.timestamp,
                stakeEndTime: block.timestamp + currentStakingPool.duration,
                stakingWallet: msg.sender,
                poolId: _poolId
            });
            stakes[msg.sender][_poolId] = newStake;
        } else {
            stake memory currentStake = stakes[msg.sender][_poolId];
            require(
                currentStake.stakeEndTime > block.timestamp,
                "Time completed , claim rewards"
            );
            uint256 currentReward = (_amount *
                (currentStake.stakeEndTime - block.timestamp) *
                currentStakingPool.rewardRate *
                1e18) /
                (10000 * 31536000) /
                1e18;
            require(
                Token.balanceOf(address(this)) >
                    totalSupply() + totalRewardslocked() + currentReward,
                "All rewards are allotted"
            );
            _calculateReward(currentStake);
            stakes[msg.sender][_poolId].amount = currentStake.amount + _amount;
            stakes[msg.sender][_poolId].lastInteractedTime = block.timestamp;
            // stakes[msg.sender][_poolId].isUnstaked = false;
        }
        stakingPools[_poolId].totalAmountStaked += _amount;
        Token.transferFrom(msg.sender, address(this), _amount);
        return true;
    }

    /// @notice To unstake tokens
    /// @param _poolId The Id of the pool from which you want to unstake
    /// @return True if successfully unstaked
    function unstakeToken(uint256 _poolId) external returns (bool) {
        stake memory currentStake = stakes[msg.sender][_poolId];
        require(
            currentStake.stakingWallet != address(0),
            "Tokens already unstaked"
        );
        stakingPools[_poolId].totalAmountStaked -= currentStake.amount;
        stakes[msg.sender][_poolId].amount = 0;
        stakes[msg.sender][_poolId].lastInteractedTime = 0;
        stakes[msg.sender][_poolId].stakingWallet = address(0);
        if (block.timestamp < currentStake.stakeEndTime)
            rewards[msg.sender][_poolId] = 0;
        else claimReward(_poolId, currentStake);
        Token.transfer(msg.sender, currentStake.amount);
        return true;
    }

    function claimReward(uint256 _poolId, stake memory currentStake)
        internal
        returns (bool)
    {
        uint256 currentReward = _calculateReward(currentStake);
        rewards[msg.sender][_poolId] = 0;
        Token.transfer(msg.sender, currentReward);
        return true;
    }

    /// @notice Only for the owner
    /// @notice To make a new staking pool
    /// @param _duration The duration for which the staking pool should be live
    /// @param _rewardRate The reward rate in multiple of 100(e.g. for 12% input 1200 , for 36% input 3600) of the new staking pool that you want to make
    /// @return It returns poolId of the pool that was just made
    function makeStakingPool(uint256 _duration, uint256 _rewardRate)
        external
        onlyOwner
        returns (uint256)
    {
        stakingPoolInfo memory currentStakingPool = stakingPoolInfo({
            poolId: stakingPools.length,
            totalAmountStaked: 0,
            duration: _duration,
            creationTime: block.timestamp,
            rewardRate: _rewardRate,
            isStakingAllowed: true
        });
        getPoolId[_rewardRate] = stakingPools.length; //Remove while deploying
        stakingPools.push(currentStakingPool);
        return stakingPools.length - 1;
    }

    /// @notice Only for the owner
    /// @notice To pause staking in a staking pool
    /// @param _poolId The Id of the pool that you want to pause or unpause
    /// @param _isAllowed To allow staking ,so input true to unpause staking and false to pause staking
    /// @return True if a pool is paused or unpaused successfully
    function pauseStaking(uint256 _poolId, bool _isAllowed)
        external
        onlyOwner
        returns (bool)
    {
        stakingPools[_poolId].isStakingAllowed = _isAllowed;
        return true;
    }

    /// @notice Total staked tokens, every pool is included
    /// @return Total amount of staked tokens in every pool
    function totalSupply() public view returns (uint256) {
        uint256 _totalSupply;
        for (uint256 i = 0; i < stakingPools.length; i++)
            _totalSupply += stakingPools[i].totalAmountStaked;
        return _totalSupply;
    }

    /// @notice Only for the owner
    /// @notice To transfer remaining reward tokens that are stuck in the contract back to the owner
    /// @param _recipient The address at which the remaining reward tokens should be transferred
    /// @param _amount The amount of the unused reward tokens to be transferred from Staking contract address(address(this)) to owner
    function removeRewardTokens(address _recipient, uint256 _amount)
        external
        onlyOwner
    {
        require(
            _amount <= checkReleasableTokens(),
            "Amount exceeds releasable tokens"
        );
        Token.transfer(_recipient, _amount);
    }

    /// @notice Returns how much rewards tokens can be taken out without including the tokens staked by users
    /// @return The amount of tokens that can be taken out without including the tokens staked by users
    function checkReleasableTokens() public view returns (uint256) {
        require(
            Token.balanceOf(address(this)) -
                (totalSupply() + totalRewardslocked()) >=
                0,
            "0 releasable, add rewards"
        );
        return
            Token.balanceOf(address(this)) -
            (totalSupply() + totalRewardslocked());
    }

    /// @notice Use this function to view details of every pool
    /// @return Returns the details of every pool
    function viewAllPools() external view returns (stakingPoolInfo[] memory) {
        return stakingPools;
    }

    /// @notice Use this function to view the total number of rewards that are locked
    /// @return totalRewardsLocked - Returns the total number of rewards that are locked
    function totalRewardslocked()
        public
        view
        returns (uint256 totalRewardsLocked)
    {
        stakingPoolInfo[] memory _stakingPools = stakingPools;
        for (uint256 i = 0; i < _stakingPools.length; i++) {
            uint256 amount = _stakingPools[i].totalAmountStaked;
            uint256 reward = (amount *
                _stakingPools[i].duration *
                _stakingPools[i].rewardRate *
                1e18) /
                (10000 * 31536000) /
                1e18;
            totalRewardsLocked += reward;
        }
        return totalRewardsLocked;
    }

    /// @notice Use this function to view the total number of rewards currently inside of the contract
    /// @return totalRewards - Returns the total number of rewards that are locked
    function totalRewards() external view returns (uint256) {
        return Token.balanceOf(address(this)) - totalSupply();
    }
}