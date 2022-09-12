// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleStakingV2 is Ownable {

    uint256 public constant MIN_STAKING_VALUE = 1 * 10 ** 18;
    uint256 public constant CALCULATION_PERIOD = 300;
    uint256 private constant PERIODS_PER_YEAR = 365 days / CALCULATION_PERIOD;
    
    struct Staking {
        uint256 lastReward;
        uint256 amount;
        uint256 rewarded;
        uint256 pendingReward;
        bool isUnstaked;
        bool isInitialized;
    }

    mapping(address => Staking) public stakers;  
    uint256 public maxApr = 5000000; //500.0000%
    bool public stakingEnabled = false;   
    bool public claimEnabled = false;  
    uint256 public totalStaked;
    IERC20 private taleToken;

    event Stake(address indexed staker, uint256 addedAmount, uint totalStaked);
    event Reward(address indexed staker, uint256 rewards);
    event UnStake(address indexed staker, uint256 amount);
    
    constructor(address _taleToken) {
        taleToken = IERC20(_taleToken);
    }

    /**
    * @notice Starts a new staking or adds tokens to the active staking.
    *         If staking is active, withdraws the rewards and 
    *         adds the received tokens to active staking.  
    *
    * @param amount Amount of tokens to stake.
    */
    function stake(uint256 amount) external {
        require(stakingEnabled, "TaleStaking: Staking disabled");
        require(amount >= MIN_STAKING_VALUE, "TaleStaking: Minimum staking amount 1TALE");
        address staker = _msgSender();

        //check erc20 balance and allowance
        require(taleToken.balanceOf(staker) >= amount, "TaleStaking: Insufficient tokens");
        require(taleToken.allowance(staker, address(this)) >= amount, "TaleStaking: Not enough tokens allowed");

        if (stakers[staker].isInitialized && !stakers[staker].isUnstaked) {
            stakers[staker].pendingReward = _getStakingReward(stakers[staker]);
            stakers[staker].amount += amount;            
            stakers[staker].lastReward = block.timestamp;
        } else {
            stakers[staker] = Staking(block.timestamp, amount, 0, 0, false, true);
        }  
        
        totalStaked += amount;
        taleToken.transferFrom(staker, address(this), amount);  

        emit Stake(staker, amount, stakers[staker].amount);
    }

    /**
    * @notice Pays rewards and withdraws the specified amount of tokens from staking. 
    *
    * @param amount Amount of tokens to stake.
    */
    function unstake(uint256 amount) external {
        address staker = _msgSender();
        Staking storage staking = stakers[staker];        
        require(amount <= staking.amount, "TaleStaking: Not enough tokens in staking");
        _claim(staker);

        if (staking.amount == amount) {
            staking.isUnstaked = true;
        }

        staking.amount -= amount;
        totalStaked -= amount;
        taleToken.transfer(staker, amount);

        emit UnStake(staker, amount);
    }

    /**
    * @notice Pays rewards.
    */
    function claim() external {
        address staker = _msgSender();
        _claim(staker);
    }

    /**
    * @notice Withdraws tokens from the pool. 
    *         Available only to the owner of the contract.
    *
    * @param to Address where tokens will be withdrawn
    * @param amount Amount of tokens to withdraw.
    */
    function withdraw(address to, uint256 amount) external onlyOwner {
        taleToken.transfer(to, amount);
    }

    /**
    * @notice Sets the maximum APR 
    *         Available only to the owner of the contract.
    */
    function setMaxApr(uint256 apr) external onlyOwner {
        maxApr = apr;
    }

    function setStakingEnabled(bool isEnabled) external onlyOwner {
        stakingEnabled = isEnabled;
    }

    function setClaimEnabled(bool isEnabled) external onlyOwner {
        claimEnabled = isEnabled;
    }

    function addStaking(
        address staker,
        uint256 lastReward, 
        uint256 amount, 
        uint256 rewarded, 
        uint256 pendingReward
        ) external onlyOwner {
        stakers[staker] = Staking(lastReward, amount, rewarded, pendingReward, false, true);
        totalStaked += amount;
        taleToken.transferFrom(msg.sender, address(this), amount); 
        emit Stake(staker, amount, stakers[staker].pendingReward); 
    }

    /**
    * @notice Returns the available amount of the reward for the specified address.
    *
    * @param staker Address of the staker for which the reward will be calculated
    */
    function getStakingReward(address staker) public view returns(uint256) {
        return _getStakingReward(stakers[staker]);
    }

    /**
    * @notice Returns current APR
    */
    function getCurrentApr() public view returns(uint256) {
        if (totalStaked == 0) {
            return maxApr;
        }
        uint256 apr = getPoolSize() * 1000000 / totalStaked;
        if (apr > maxApr) {
            return maxApr;
        } else {
            return apr;
        }
    }

    /**
    * @notice Returns the current number of tokens in the pool
    */
    function getPoolSize() public view returns(uint256) {
        uint256 balance = taleToken.balanceOf(address(this));
        return balance - totalStaked;
    }
    
    function _claim(address staker) private {        
        require(claimEnabled, "TaleStaking: Claim disabled");       
        Staking storage staking = stakers[staker];
        uint256 reward = _getStakingReward(staking);
        staking.lastReward = block.timestamp;
        staking.rewarded += reward;
        staking.pendingReward = 0;
        taleToken.transfer(staker, reward);

        emit Reward(staker, reward);
    }

    function _getStakingReward(Staking storage staking) private view returns(uint256) {
        require(staking.isInitialized, "TaleStaking: Staking is not exists");
        require(!staking.isUnstaked, "TaleStaking: Staking is unstaked");
        require(block.timestamp >= staking.lastReward, "TaleStaking: Invalid block timestamp");

        uint256 currentApr = getCurrentApr();        
        uint256 period = block.timestamp - staking.lastReward;
        uint256 periods = period / CALCULATION_PERIOD;
        uint256 reward = staking.amount * currentApr * periods / 1000000 / PERIODS_PER_YEAR;
        return staking.pendingReward + reward;
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