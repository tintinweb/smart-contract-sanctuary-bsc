// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "../utils/Ownable.sol";
import "../interfaces/IERC20.sol";

contract ReflectionsDistributor is Ownable {
    IERC20 public stakeToken;
    address public treasury;
    uint256 public minAmountReflection = 1000 * 10**9;

    /// @notice The precision of `accRewardPerShare`
    uint256 public immutable ACC_REWARD_PER_SHARE_PRECISION;

    /// @dev Internal balance of STAKE_TOKEN, this gets updated on user deposits / withdrawals
    /// this allows to reward users with STAKE_TOKEN
    uint256 public internalEmpireBalance;

    /// @notice Last reward balance
    uint256 public lastRewardBalance;

    /// @notice Accumulated rewards per share, scaled to `ACC_REWARD_PER_SHARE_PRECISION`
    uint256 public accRewardPerShare;

    /**
     * @notice We do some fancy math here. Basically, any point in time, the amount of STAKE_TOKENs
     * entitled to a user but is pending to be distributed is:
     *
     *   pending reward = (_userAmount * accRewardPerShare) - rewardDebt[_user]
     *
     * Whenever a user deposits or withdraws STAKE_TOKEN. Here's what happens:
     *   1. accRewardPerShare (and `lastRewardBalance`) gets updated
     *   2. User receives the pending reward sent to his/her address
     *   3. User's `rewardDebt` gets updated
     */
    mapping(address => uint256) public rewardDebt;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    event LogSetStakeToken(address indexed stakeToken);
    event LogSetTreasury(address treasury);
    event LogSetMinAmountReflection(uint256 minAmountReflection);

    /**
     * @param _stakeToken The address of the STAKE_TOKEN token
     */
    constructor(IERC20 _stakeToken, address _treasury) {
        require(
            address(_stakeToken) != address(0) && 
            _treasury != address(0), 
            "ZERO_ADDRESS"
        );
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
     * @param _userAmount The previous staked amount of STAKE_TOKEN
     */
    function deposit(address _user, uint256 _amount, uint256 _userAmount) external onlyTreasury {
        uint256 _previousAmount = _userAmount;
        uint256 _newAmount = _userAmount + _amount;

        updateReward();
        uint256 _previousRewardDebt = rewardDebt[_user];
        rewardDebt[_user] =
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

        internalEmpireBalance += _amount;
        emit Deposit(_user, _amount);
    }

    /**
     * @notice Withdraw STAKE_TOKEN and harvest the rewards
     * @param _amount The amount of STAKE_TOKEN to withdraw
     * @param _userAmount The new staked amount of STAKE_TOKEN
     */
    function withdraw(address _user, uint256 _amount, uint256 _userAmount) external onlyTreasury {
        uint256 _previousAmount = _userAmount + _amount;
        uint256 _newAmount = _userAmount;

        updateReward();
        uint256 _pending = (_previousAmount * accRewardPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION -
            rewardDebt[_user];
        rewardDebt[_user] =
            (_newAmount * accRewardPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION;
        if (_pending > 0) {
            safeTokenTransfer(_user, _pending);
            emit ClaimReward(_user, _pending);
        }

        internalEmpireBalance -= _amount;

        emit Withdraw(_user, _amount);
    }

    /**
     * @notice Update reward variables
     * @dev Needs to be called before any deposit or withdrawal
     */
    function updateReward() internal {
        uint256 _totalEmpire = internalEmpireBalance;

        uint256 _currRewardBalance = stakeToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        // Did ReflectionsDistributor receive any token
        if (
            _rewardBalance >= lastRewardBalance + minAmountReflection &&
            _totalEmpire > 0
        ) {
            uint256 _accruedReward = _rewardBalance - lastRewardBalance;

            accRewardPerShare =
                accRewardPerShare +
                (_accruedReward * ACC_REWARD_PER_SHARE_PRECISION) /
                _totalEmpire;
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
    
    function setStakeToken(address _stakeToken) external onlyMultiSig {
        require(_stakeToken != address(0), "ZERO_ADDRESS");
        require(_stakeToken != address(stakeToken), "SAME_ADDRESS");
        stakeToken = IERC20(_stakeToken);

        emit LogSetStakeToken(_stakeToken);
    }

    function setTreasury(address _treasury) external onlyMultiSig {
        require(address(0) != _treasury, "ZERO_ADDRESS");
        require(treasury != _treasury, "SAME_ADDRESS");
        treasury = _treasury;
        emit LogSetTreasury(treasury);
    }

    function setMinAmountReflection(uint256 _minAmountReflection)
        external
        onlyMultiSig
    {
        require(minAmountReflection != _minAmountReflection, "SAME_VALUE");
        minAmountReflection = _minAmountReflection;
        emit LogSetMinAmountReflection(minAmountReflection);
    }

    /**
     * @notice View function to see pending reward token on frontend
     * @param _user The address of the user
     * @param _userAmount The staked amount of STAKE_TOKEN
     * @return uint256 `_user`'s pending reward token
     */
    function pendingReward(address _user, uint256 _userAmount ) external view returns (uint256) {
        uint256 _totalEmpire = internalEmpireBalance;
        uint256 _accRewardTokenPerShare = accRewardPerShare;

        uint256 _currRewardBalance = stakeToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        if (
            _rewardBalance >= lastRewardBalance + minAmountReflection &&
            _totalEmpire > 0
        ) {
            uint256 _accruedReward = _rewardBalance - lastRewardBalance;
            _accRewardTokenPerShare =
                _accRewardTokenPerShare +
                (_accruedReward * ACC_REWARD_PER_SHARE_PRECISION) /
                _totalEmpire;
        }
        return
            (_userAmount * _accRewardTokenPerShare) /
            ACC_REWARD_PER_SHARE_PRECISION -
            rewardDebt[_user];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.7;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyMultiSig`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address private _multiSigOwner;

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
    modifier onlyMultiSig() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _multiSigOwner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyMultiSig` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyMultiSig {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyMultiSig {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _multiSigOwner;
        _multiSigOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.7;

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

pragma solidity 0.8.7;

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
}