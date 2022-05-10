// SPDX-License-Identifier: None
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IStaking {
    function userInfo(address user) external view returns (uint256 amount, uint256 rewardDebt, uint256 lastStakedAt);
}

contract StakingV2 is ReentrancyGuard, Ownable {
    address private STAKING = 0xa446D5503a0A3d97dFAdFDf1b741C72f08558212;

    address public STAKED_TOKEN = 0x1FC8d426cDF51062E818A2c55c64dC4af209b272;
    address public REWARD_TOKEN = 0x1FC8d426cDF51062E818A2c55c64dC4af209b272;

    uint256 public TOTAL_WITHDRAW_AMOUNT;
    uint256 public TOTAL_STAKED_AMOUNT = 3000000000000000000000;

    uint256 public FINISHED_AT = 1652092500;
    uint256 public FIXED_APR = 200;
    uint256 public constant ONE_YEAR_SEC = 365 * 24 * 60 * 60;

    event ClaimStakedToken(address indexed user, uint256 indexed amount, uint256 indexed performanceFee);
    event ClaimRewardToken(address indexed user, uint256 indexed amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    mapping(address => bool) public isClaimedReward;
    mapping(address => bool) public isWithdraw;

    function setStakingAddress(address stakingV1, address stakedToken, address rewardToken) external onlyOwner {
        STAKING = stakingV1;
        STAKED_TOKEN = stakedToken;
        REWARD_TOKEN = rewardToken;
    }

    function setTotalStakedAmount(uint256 _total, uint256 _finishedAt, uint256 _apr) external onlyOwner {
        TOTAL_STAKED_AMOUNT = _total;
        FINISHED_AT = FINISHED_AT;
        FIXED_APR = _apr;
    }

    function _unClaimedReward(address _user) internal virtual view returns (uint256) {
        if (isWithdraw[_user] || isClaimedReward[_user]) {
            return 0;
        }

        (uint256 amount, uint256 rewardDebt, uint256 lastStakedAt) = IStaking(STAKING).userInfo(_user);
        if (amount == 0) {
            return 0;
        } else {
            if (lastStakedAt < FINISHED_AT) {
                uint256 newReward = (amount * FIXED_APR * (FINISHED_AT - lastStakedAt)) / (ONE_YEAR_SEC * 100);
                return rewardDebt + newReward;
            } else {
                return 0;
            }
        }
    }

    function unClaimedReward(address _user) public view returns (uint256) {
        return _unClaimedReward(_user);
    }

    function claimReward() external nonReentrant {
        uint256 amountToTransfer = _unClaimedReward(_msgSender());

        if (amountToTransfer > 0) {
            require(
                IERC20(REWARD_TOKEN).transfer(_msgSender(), amountToTransfer),
                "Transfer reward token to address error"
            );

            isClaimedReward[_msgSender()] = true;
            emit ClaimRewardToken(_msgSender(), amountToTransfer);
        }
    }

    function withdraw() external nonReentrant {
        require(!isWithdraw[_msgSender()], "Amount to withdraw too low");

        (uint256 amount, uint256 rewardDebt, uint256 lastStakedAt) = IStaking(STAKING).userInfo(_msgSender());
        require(amount > 0, "Amount to withdraw too low");

        uint256 rw = _unClaimedReward(_msgSender());
        uint256 amountToTransfer = amount + rw;

        require(
            IERC20(REWARD_TOKEN).transfer(_msgSender(), amountToTransfer),
            "Transfer reward token to address error"
        );
        TOTAL_WITHDRAW_AMOUNT = TOTAL_WITHDRAW_AMOUNT + amount;
        TOTAL_STAKED_AMOUNT = TOTAL_STAKED_AMOUNT - amount;

        isWithdraw[_msgSender()] = true;
        isClaimedReward[_msgSender()] = true;


        emit ClaimStakedToken(_msgSender(), amount, 0);
        emit ClaimRewardToken(_msgSender(), rw);
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        IERC20(REWARD_TOKEN).transfer(owner(), _amount);
    }

    function transferAnyBEP20Token(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(owner(), _amount);
    }

    function userInfo(address _user) external view returns (uint256, uint256, uint256) {
        if (isWithdraw[_user]) {
            return (0,0,0);
        } else {
            (uint256 amount, uint256 rewardDebt, uint256 lastStakedAt) = IStaking(STAKING).userInfo(_user);
            return (amount, rewardDebt, lastStakedAt);
        }
    }
}

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

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