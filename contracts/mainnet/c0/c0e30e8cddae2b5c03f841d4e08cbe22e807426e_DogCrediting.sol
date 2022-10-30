// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DogCrediting is Ownable, ReentrancyGuard {

    uint256 public payoutRate = 2;
    uint256 public APY = 35;
    uint256 public rewardRatio;

    IERC20 public RewardToken;
    IERC20 public StakedToken;

    bool public isCreditingActive = false;

    uint256 public rewardStartTime;

    // Info of each user.
    struct UserCreditingInfo {
        uint256 amount;
        bool hasCredited;
    }

    struct UserStakedInfo {
        uint256 claimed;
        uint256 staked;
        uint256 reward_time_counter;
        uint256 last_reward_time;
        uint256 last_lp_claim_time;
    }

    mapping(address => UserCreditingInfo) public userCreditInfo;
    mapping(address => UserStakedInfo) public userStakeInfo;

    // EVENTS
    event CreditedLP(address indexed user, uint256 percentage, uint256 amount);
    event EarnRewards(address indexed user, uint256 amount);
    event ClaimedLP(address indexed user, uint256 amount);

    constructor(uint256 _rewardRatio, uint256 _rewardStartTime, IERC20 _rewardToken, IERC20 _stakedToken){
        rewardRatio = _rewardRatio;
        require(_rewardStartTime > block.timestamp, 'must be in future');
        rewardStartTime = _rewardStartTime;
        RewardToken = _rewardToken;
        StakedToken = _stakedToken;
    }

    function creditLPToStaking(uint256 _percentageVested) external nonReentrant {
        require(isCreditingActive, 'not active yet');
        require(_percentageVested <= 100, 'invalid percentage');

        UserCreditingInfo storage user = userCreditInfo[msg.sender];
        require(user.amount > 0, 'nothing to credit');

        uint256 amountToVest = user.amount * _percentageVested / 100;

        userStakeInfo[msg.sender].staked = amountToVest;

        uint256 initialTime = block.timestamp < rewardStartTime ? rewardStartTime : block.timestamp;
        userStakeInfo[msg.sender].last_reward_time = initialTime;
        userStakeInfo[msg.sender].last_lp_claim_time = initialTime;

        uint256 amountRemaining = user.amount - amountToVest;
        if (amountRemaining > 0){
            payoutInstantRewards(msg.sender, amountRemaining);
        }

        user.amount = 0;
        user.hasCredited = true;
        emit CreditedLP(msg.sender, _percentageVested, amountToVest);
    }

    function claimRewards() external nonReentrant {
        require(isCreditingActive, 'not active yet');
        require(block.timestamp > rewardStartTime, 'rewards not active yet');
        UserStakedInfo storage user = userStakeInfo[msg.sender];
        require(user.staked > 0, 'nothing staked');

        payPendingRewards(msg.sender);

    }

    function claimLP() external nonReentrant {
        require(isCreditingActive, 'not active yet');
        require(block.timestamp > rewardStartTime, 'rewards not active yet');
        UserStakedInfo storage user = userStakeInfo[msg.sender];
        require(user.staked > 0, 'nothing staked');

        payPendingRewards(msg.sender);
        payPendingLP(msg.sender);

    }

    function payoutInstantRewards(address user, uint256 _amountStakeToken) internal {
        RewardToken.transfer(user, (_amountStakeToken * rewardRatio * 2) / 1e4);
    }

    function payPendingRewards(address _userAddress) internal {
        UserStakedInfo storage user = userStakeInfo[_userAddress];

        uint256 rewardPayout = pendingRewards(_userAddress);

        uint256 timePassed = block.timestamp - userStakeInfo[_userAddress].last_reward_time;
        user.reward_time_counter += timePassed;
        if (user.reward_time_counter > 50 days){
            user.reward_time_counter = 50 days;
        }

        user.last_reward_time = block.timestamp;

        RewardToken.transfer(msg.sender, rewardPayout);
        emit EarnRewards(_userAddress, rewardPayout);
    }

    function payPendingLP(address _userAddress) internal {
        UserStakedInfo storage user = userStakeInfo[_userAddress];

        uint256 payout = pendingLP(_userAddress);
        user.claimed += payout;
        user.last_lp_claim_time = block.timestamp;

        StakedToken.transfer(msg.sender, payout);
        emit ClaimedLP(_userAddress, payout);
    }

    // VIEW FUNCTIONS
    function pendingRewards(address _user) public view returns(uint256){
        if (block.timestamp < rewardStartTime){
            return 0;
        }

        uint256 stakedRewards = (userStakeInfo[_user].staked - userStakeInfo[_user].claimed) * rewardRatio;
        uint256 rewardsPerYear = stakedRewards * APY / 100;
        uint256 rewardsPerSecond = rewardsPerYear / 365 days;

        uint256 lastTime = userStakeInfo[_user].last_reward_time < rewardStartTime ? rewardStartTime : userStakeInfo[_user].last_reward_time;
        uint256 timePassed = block.timestamp - lastTime;

        if (timePassed + userStakeInfo[_user].reward_time_counter > 50 days){
            timePassed = 50 days - userStakeInfo[_user].reward_time_counter;
        }

        uint256 earnedTotal = (rewardsPerSecond * timePassed) / 1e4;

        return earnedTotal;
    }

    function pendingLP(address _addr) public view returns(uint256 payout) {
        if (block.timestamp < rewardStartTime){
            return 0;
        }

        uint256 share = userStakeInfo[_addr].staked * (payoutRate * 1e18) / (100e18) / (24 hours); //divide the profit by payout rate and seconds in the day
        uint256 lastTime = userStakeInfo[_addr].last_lp_claim_time < rewardStartTime ? rewardStartTime : userStakeInfo[_addr].last_lp_claim_time;
        payout = share * (block.timestamp - lastTime);

        if (userStakeInfo[_addr].claimed + payout > userStakeInfo[_addr].staked) {
            payout = userStakeInfo[_addr].staked - userStakeInfo[_addr].claimed;
        }

        return payout;

    }

    function dogsInLp(address _user) public view returns(uint256){
        return userStakeInfo[_user].staked * rewardRatio;
    }

    // Admin Functions
    function setUserCreditInfo(address[] memory _users, UserCreditingInfo[] memory _usersCreditingData) external onlyOwner {
        require(_users.length == _usersCreditingData.length);
        for (uint256 i = 0; i < _users.length; i++) {
            UserCreditingInfo storage user = userCreditInfo[_users[i]];
            user.amount = _usersCreditingData[i].amount;
        }
    }

    function toggleCreditingActive(bool _isActive) external onlyOwner {
        isCreditingActive = _isActive;
    }

    function updatePayoutRate(uint256 _payoutRate) external onlyOwner {
        payoutRate = _payoutRate;
    }

    function updateRewardStartTime(uint256 _rewardStartTime) external onlyOwner {
        rewardStartTime = _rewardStartTime;
    }

    function updateApy(uint256 _APY) external onlyOwner {
        APY = _APY;
    }

    function updateRewardRatio(uint256 _rewardRatio) external onlyOwner {
        rewardRatio = _rewardRatio;
    }

    function updateRewardToken(IERC20 _rewardToken) external onlyOwner {
        RewardToken = _rewardToken;
    }

    function updateStakedToken(IERC20 _stakedToken) external onlyOwner {
        StakedToken = _stakedToken;
    }

    function unstuckTokens(address _token, uint256 _amount, address _to) external onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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