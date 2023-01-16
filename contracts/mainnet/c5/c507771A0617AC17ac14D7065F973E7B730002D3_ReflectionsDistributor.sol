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

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReflectionsDistributor is Ownable {
    /// @notice Info of each user
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        /**
         * @notice We do some fancy math here. Basically, any point in time, the amount of STAKE_TOKENs
         * entitled to a user but is pending to be distributed is:
         *
         *   pending reward = (user.amount * accRewardPerShare) - user.rewardDebt
         *
         * Whenever a user deposits or withdraws STAKE_TOKEN. Here's what happens:
         *   1. accRewardPerShare (and `lastRewardBalance`) gets updated
         *   2. User receives the pending reward sent to his/her address
         *   3. User's `amount` gets updated
         *   4. User's `rewardDebt` gets updated
         */
    }

    IERC20 public immutable stakeToken;
    address public treasury;
    uint256 public minAmountReflection = 1000 * 10**9;

    /// @notice The precision of `accRewardPerShare`
    uint256 public immutable ACC_REWARD_PER_SHARE_PRECISION;

    /// @dev Internal balance of STAKE_TOKEN, this gets updated on user deposits / withdrawals
    /// this allows to reward users with STAKE_TOKEN
    uint256 public internalTeletreonBalance;

    /// @notice Last reward balance
    uint256 public lastRewardBalance;

    /// @notice Accumulated rewards per share, scaled to `ACC_REWARD_PER_SHARE_PRECISION`
    uint256 public accRewardPerShare;

    /// @dev Info of each user that stakes STAKE_TOKEN
    mapping(address => UserInfo) private userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    event LogSetTreasury(address treasury);
    event LogSetMinAmountReflection(uint256 minAmountReflection);

    /**
     * @param _stakeToken The address of the STAKE_TOKEN token
     */
    constructor(IERC20 _stakeToken, address _treasury) {
        stakeToken = _stakeToken;
        treasury = _treasury;

        ACC_REWARD_PER_SHARE_PRECISION = 1e24;
    }

    modifier onlyTreasury() {
        require(
            _msgSender() == treasury,
            "ReflectionsDistributor: caller is not the treasury"
        );
        _;
    }

    /**
     * @notice Deposit STAKE_TOKEN for reward token allocation
     * @param _amount The amount of STAKE_TOKEN to deposit
     */
    function deposit(address _user, uint256 _amount) external onlyTreasury {
        UserInfo storage user = userInfo[_user];

        uint256 _previousAmount = user.amount;
        uint256 _newAmount = user.amount + _amount;
        user.amount = _newAmount;

        updateReward();
        uint256 _previousRewardDebt = user.rewardDebt;
        user.rewardDebt =
            (_newAmount * accRewardPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION;
        if (_previousAmount != 0) {
            uint256 _pending = (_previousAmount * accRewardPerShare) /
                ACC_REWARD_PER_SHARE_PRECISION -
                _previousRewardDebt;
            if (_pending > 0) {
                safeTokenTransfer(_user, _pending);
                emit ClaimReward(_user, _pending);
            }
        }

        internalTeletreonBalance += _amount;
        emit Deposit(_user, _amount);
    }

    /**
     * @notice Withdraw STAKE_TOKEN and harvest the rewards
     * @param _amount The amount of STAKE_TOKEN to withdraw
     */
    function withdraw(address _user, uint256 _amount) external onlyTreasury {
        UserInfo storage user = userInfo[_user];

        uint256 _previousAmount = user.amount;
        uint256 _newAmount = user.amount - _amount;
        user.amount = _newAmount;

        updateReward();
        uint256 _pending = (_previousAmount * accRewardPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION -
            user.rewardDebt;
        user.rewardDebt =
            (_newAmount * accRewardPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION;
        if (_pending > 0) {
            safeTokenTransfer(_user, _pending);
            emit ClaimReward(_user, _pending);
        }

        internalTeletreonBalance -= _amount;

        emit Withdraw(_user, _amount);
    }

    /**
     * @notice Update reward variables
     * @dev Needs to be called before any deposit or withdrawal
     */
    function updateReward() internal {
        uint256 _totalTeletreon = internalTeletreonBalance;

        uint256 _currRewardBalance = stakeToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        // Did ReflectionsDistributor receive any token
        if (
            _rewardBalance >= lastRewardBalance + minAmountReflection &&
            _totalTeletreon > 0
        ) {
            uint256 _accruedReward = _rewardBalance - lastRewardBalance;

            accRewardPerShare =
                accRewardPerShare +
                (_accruedReward * ACC_REWARD_PER_SHARE_PRECISION) /
                _totalTeletreon;
            lastRewardBalance = _rewardBalance;
        }
    }

    /**
     * @notice Safe token transfer function, just in case if rounding error
     * causes pool to not have enough reward tokens
     * @param _to The address that will receive `_amount` `rewardToken`
     * @param _amount The amount to send to `_to`
     */
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 _currRewardBalance = stakeToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        if (_amount > _rewardBalance) {
            lastRewardBalance = lastRewardBalance - _rewardBalance;
            require(stakeToken.transfer(_to, _rewardBalance), "Transfer fail");
        } else {
            lastRewardBalance = lastRewardBalance - _amount;
            require(stakeToken.transfer(_to, _amount), "Transfer fail");
        }
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
        emit LogSetTreasury(treasury);
    }

    function setMinAmountReflection(uint256 _minAmountReflection)
        external
        onlyOwner
    {
        minAmountReflection = _minAmountReflection;
        emit LogSetMinAmountReflection(minAmountReflection);
    }

    /**
     * @notice Get user info
     * @param _user The address of the user
     * @return The amount of STAKE_TOKEN user has deposited
     * @return The reward debt for the chosen token
     */
    function getUserInfo(address _user)
        external
        view
        returns (uint256, uint256)
    {
        UserInfo storage user = userInfo[_user];
        return (user.amount, user.rewardDebt);
    }

    /**
     * @notice View function to see pending reward token on frontend
     * @param _user The address of the user
     * @return `_user`'s pending reward token
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _totalTeletreon = internalTeletreonBalance;
        uint256 _accRewardTokenPerShare = accRewardPerShare;

        uint256 _currRewardBalance = stakeToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        if (
            _rewardBalance >= lastRewardBalance + minAmountReflection &&
            _totalTeletreon > 0
        ) {
            uint256 _accruedReward = _rewardBalance - lastRewardBalance;
            _accRewardTokenPerShare =
                _accRewardTokenPerShare +
                (_accruedReward * ACC_REWARD_PER_SHARE_PRECISION) /
                _totalTeletreon;
        }
        return
            (user.amount * _accRewardTokenPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION -
            user.rewardDebt;
    }
}