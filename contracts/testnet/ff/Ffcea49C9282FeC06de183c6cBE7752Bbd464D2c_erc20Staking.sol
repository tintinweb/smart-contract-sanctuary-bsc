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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract erc20Staking is Ownable, ReentrancyGuard {
    struct SharedData {
        uint256 totalAmount;
        uint256 totalBoostedAmount;
        uint256 rewardPerShareEth;
        uint256 rewardPerShareToken;
    }

    struct Reward {
        uint256 totalExcludedEth; // excluded reward
        uint256 totalExcludedToken;
        uint256 lastClaim;
    }

    struct UserData {
        uint256 amount;
        uint256 boostedAmount;
        uint256 lockedTime;
    }

    IERC20 public rewardToken;
    SharedData public sharedData;

    uint256 public constant ACC_FACTOR = 10 ** 36;

    uint256 public minLockTime = 7 days;
    uint256 public minStakingAmount;
    uint256 public maxBoostAmount = 50; //50%
    uint256 public totalEthClaimed;
    uint256 public totalTokenClaimed;

    bool public claimEnable = false;
    bool public lockEnable = true;

    mapping(address => UserData) public userData;
    mapping(address => Reward) public rewards;

    event NewLock(address user, uint256 amount, uint256 boost);
    event RewardDeposited(bool isEth, uint256 amount, uint256 time);
    event ClaimRewards(uint256 _ethAmount, uint256 _tokenAmount, address recipient);
    event SettingsUpdated(uint256 newLockTime, uint256 newMinStaking, uint256 newMaxBoost);

    function lock(uint256 amount) external {
        require(lockEnable, "lock temporary suspended");
        uint256 totalAmount = amount * 10 ** rewardToken.decimals();
        require(totalAmount >= minStakingAmount, "input less than minimum");
        require(
            rewardToken.transferFrom(_msgSender(), address(this), totalAmount),
            "token transfer failed"
        );

        uint256 boostMultiplier = (totalAmount - minStakingAmount) / minStakingAmount;

        if (boostMultiplier > maxBoostAmount) {
            boostMultiplier = maxBoostAmount;
        }

        uint256 boostedAmount = totalAmount + (totalAmount * boostMultiplier) / 100;

        sharedData.totalAmount += totalAmount;
        sharedData.totalBoostedAmount += boostedAmount;

        userData[_msgSender()].amount += totalAmount;
        userData[_msgSender()].boostedAmount += boostedAmount;
        userData[_msgSender()].lockedTime = block.timestamp;

        (
            rewards[_msgSender()].totalExcludedEth,
            rewards[_msgSender()].totalExcludedToken
        ) = getCumulativeRewards(userData[_msgSender()].boostedAmount);

        emit NewLock(_msgSender(), totalAmount, boostMultiplier);
    }

    function unlock() public nonReentrant {
        require(lockEnable, "unlock temporary suspended");
        require(
            block.timestamp >= userData[_msgSender()].lockedTime + minLockTime,
            "lock not ended"
        );
        sharedData.totalAmount -= userData[_msgSender()].amount;
        sharedData.totalBoostedAmount -= userData[_msgSender()].boostedAmount;

        //claim reward
        (uint256 unclaimedAmountEth, uint256 unclaimedAmountToken) = getUnpaid(
            _msgSender()
        );

        if (unclaimedAmountEth > 0 || unclaimedAmountToken > 0) {
            _claim(_msgSender());
        }

        require(
            rewardToken.transfer(_msgSender(), userData[_msgSender()].amount),
            "token transfer failed"
        );
        delete userData[_msgSender()];
    }

    function depositRewardEth() external payable {
        require(msg.value > 0, "value must be greater than 0");
        require(
            sharedData.totalBoostedAmount > 0,
            "must be shares deposited to be rewarded rewards"
        );
        sharedData.rewardPerShareEth += (msg.value * ACC_FACTOR) / sharedData.totalBoostedAmount;
        emit RewardDeposited(true, msg.value, block.timestamp);
    }

    function depositRewardToken(uint256 amount) external payable {
        require(amount > 0, "value must be greater than 0");
        require(
            sharedData.totalBoostedAmount > 0,
            "must be shares deposited to be rewarded rewards"
        );
        require(
            rewardToken.transferFrom(_msgSender(), address(this), amount),
            "token transfer failed"
        );
        sharedData.rewardPerShareToken += (amount * ACC_FACTOR) / sharedData.totalBoostedAmount;
        emit RewardDeposited(false, amount, block.timestamp);
    }

    function getCumulativeRewards(
        uint256 share
    ) internal view returns (uint256, uint256) {
        return (
        (share * sharedData.rewardPerShareEth) / ACC_FACTOR,
        (share * sharedData.rewardPerShareToken) / ACC_FACTOR
        );
    }

    function getUnpaid(
        address shareholder
    ) public view returns (uint256, uint256) {
        if (userData[shareholder].amount == 0) {
            return (0, 0);
        }

        (
            uint256 earnedRewardsEth,
            uint256 earnedRewardsToken
        ) = getCumulativeRewards(userData[shareholder].boostedAmount);
        uint256 rewardsExcludedEth = rewards[shareholder].totalExcludedEth;
        uint256 rewardsExcludedToken = rewards[shareholder].totalExcludedToken;
        if (
            earnedRewardsEth <= rewardsExcludedEth &&
            earnedRewardsToken <= rewardsExcludedToken
        ) {
            return (0, 0);
        }

        return (
            (earnedRewardsEth - rewardsExcludedEth),
            (earnedRewardsToken - rewardsExcludedToken)
        );
    }

    function claim() external nonReentrant {
        _claim(_msgSender());
    }

    function _claim(address user) internal {
        require(
            block.timestamp > rewards[user].lastClaim,
            "can only claim once per block"
        );
        require(claimEnable, "claim temporary disabled");
        require(userData[user].amount > 0, "no tokens staked");
        (uint256 amountEth, uint256 amountToken) = getUnpaid(user);
        require(amountEth > 0 || amountToken > 0, "nothing to claim");
        if (amountEth > 0) {
            totalEthClaimed += amountEth;
            (rewards[user].totalExcludedEth,) = getCumulativeRewards(
                userData[user].boostedAmount
            );
            _handleEthTransfer(user, amountEth);
        }
        if (amountToken > 0) {
            totalTokenClaimed += amountToken;
            (, rewards[user].totalExcludedToken) = getCumulativeRewards(
                userData[user].boostedAmount
            );
            require(rewardToken.transfer(user, amountToken));
        }

        rewards[user].lastClaim = block.timestamp;
    }

    function setRewardTokenAddress(address tokenAddress) external onlyOwner {
        rewardToken = IERC20(tokenAddress);
    }

    function changeSettings(
        uint256 _newLockTimeInDays,
        uint256 _newMinStakingAmount,
        uint256 _newMaxBoostAmount
    ) external onlyOwner {
        require(
            _newLockTimeInDays > 0 &&
            _newLockTimeInDays < 365 &&
            _newMinStakingAmount > 0,
            "wrong input"
        );
        uint256 decimals = rewardToken.decimals();

        minLockTime = _newLockTimeInDays * 86400;
        minStakingAmount = _newMinStakingAmount * 10 ** decimals;
        maxBoostAmount = _newMaxBoostAmount;

        emit SettingsUpdated(minLockTime, minStakingAmount, maxBoostAmount);
    }

    function flipLockStatus() external onlyOwner {
        lockEnable = !lockEnable;
    }

    function flipClaimStatus() external onlyOwner {
        claimEnable = !claimEnable;
    }

    // Emergency ERC20 withdrawal
    function rescueERC20(address tokenAdd, uint256 amount) external onlyOwner {
        require(
            IERC20(tokenAdd).balanceOf(address(this)) >= amount,
            'Insufficient ERC20 balance'
        );
        IERC20(tokenAdd).transfer(owner(), amount);
    }

    function _handleEthTransfer(address recipient, uint256 amount) internal {
        (bool success,) = payable(recipient).call{value : amount}("");
        require(success, "ETH transfer failed");
    }

    function balanceOf(address user) public view returns (uint256) {
        return userData[user].amount;
    }

    receive() external payable {}
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

    function decimals() external view returns (uint8);
}