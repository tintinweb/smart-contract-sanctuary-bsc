/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/// @title WOLFPACKStakingManager
/// @author LONEWOLF
///
/// Staking contract for WOLFPACK tokens. 
///
/// Accounts may stake WOLFPACK tokens and be 
/// rewarded with fee-generated market currency tokens.
/// Rewards are weighted by proportional stake and time staked.

contract WOLFPACKStakingManager is Ownable, ReentrancyGuard {

    struct StakeData {
        uint256 storedRewards;
        uint256 timestamp;
    }

    mapping(address => uint256) balances;
    mapping(address => StakeData) userStake;

    uint256 public totalStaked;
    uint256 public period;
    uint256 rewards;

    address[] private authorizedCallers;

    IERC20 public rewardsToken;
    IERC20 public wolfpackToken;
    
    constructor(address _wolfpack, address _rewardsToken, uint256 _period) {
        wolfpackToken = IERC20(_wolfpack);
        rewardsToken = IERC20(_rewardsToken);
        period = _period;
    }

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 reward);
    event NotificationReceived(address indexed rewardee);

    function addAuthorizedCaller(address _caller) external onlyOwner {
        authorizedCallers.push(_caller);
    }

    // market decommission
    function removeAuthorizedCaller(address _caller) external onlyOwner {
        uint256 len = authorizedCallers.length;
        for (uint256 i; i < len - 1; i++) {
            while (authorizedCallers[i] == _caller) {
                // shift index, pop. 
                authorizedCallers[i] = authorizedCallers[i + 1];   
            }
        }
        authorizedCallers.pop();
    }

    function modifyToken(address newToken) external onlyOwner {
        rewardsToken = IERC20(newToken);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "invalid amount");
        balances[msg.sender] += amount;
        userStake[msg.sender].storedRewards = rewards;
        userStake[msg.sender].timestamp = block.timestamp;
        totalStaked += amount;
        require(wolfpackToken.transferFrom(msg.sender, address(this), amount), "ERC20: transfer failed");       
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(amount > 0 && amount <= balances[msg.sender], "withdraw: invalid amount");
        totalStaked -= amount;
        balances[msg.sender] -= amount;
        require(wolfpackToken.transfer(msg.sender, amount), "ERC20: transfer failed");
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards(bool isExit) public nonReentrant {
        uint256 rew = earned();
        require(rew > 0, "no reward earned");
        require(rew < rewards, "too many rewards");
        if (!isExit) {
            userStake[msg.sender].timestamp = block.timestamp; 
        }
        require(rewardsToken.transfer(msg.sender, rew), "ERC20: transfer failed");
        emit RewardClaimed(msg.sender, rew);
    }

    function exit() external {
        claimRewards(true);
        withdraw(balances[msg.sender]);
    }

    function earned() public view returns (uint256) {
        uint256 share = totalStaked / balances[msg.sender];
        uint256 rate = getRate();
        uint256 duration = block.timestamp - userStake[msg.sender].timestamp;
        uint256 earn = (share * rate * duration) / 100;
        return earn;
    }

    function getRate() private view returns (uint256) {
        uint256 average;
        uint256 r0 = userStake[msg.sender].storedRewards;
        uint256 r1 = rewards;
        if (r0 > r1) {
            average = (r0 - r1) / 2;
        }
        else if (r1 > r0) {
            average = (r1 -r0) / 2;
        }
        else if (r0 == r1) {
            average = r0;
        }
        return (average / period);
    }

    function notifyReward(uint256 amount) public nonReentrant {
        require(checkNotificationSource(msg.sender), "unauthorized caller");
        rewards += amount;
    }

    function checkNotificationSource(address caller) private view returns (bool) {
        bool auth;
        uint256 len = authorizedCallers.length;
        for (uint256 i; i < len; i++) {
            address authCaller = authorizedCallers[i];
            if (caller == authCaller) {
                auth = true;
            }
        }
        return auth;
    }

    function contractRewardBalance() external view returns (uint256) {
        return rewardsToken.balanceOf(address(this));
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

}