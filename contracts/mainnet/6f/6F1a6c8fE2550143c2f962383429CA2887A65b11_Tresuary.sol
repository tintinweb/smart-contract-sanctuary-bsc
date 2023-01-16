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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ITresuary {
    function deposit(address staker, uint256 amount) external ;
    function withdraw(address staker, uint256 amount) external ;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ITresuary.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Tresuary is ITresuary, Ownable { 
    using SafeMath for uint256;

    address public stakingContract;
    address public deployer;

    IERC20 public stakingToken;
    IERC20 public dividendToken;


    /// @notice Info of each user
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        /**
         * @notice We do some fancy math here. Basically, any point in time, the amount of stakingTokens
         * entitled to a user but is pending to be distributed is:
         *
         *   pending reward = (user.amount * accRewardPerShare) - user.rewardDebt
         *
         * Whenever a user deposits or withdraws stakingToken. Here's what happens:
         *   1. accRewardPerShare (and `lastRewardBalance`) gets updated
         *   2. User receives the pending reward sent to his/her address
         *   3. User's `amount` gets updated
         *   4. User's `rewardDebt` gets updated
         */
    }

    /// @dev Internal balance of stakingToken, this gets updated on user deposits / withdrawals
    /// this allows to reward users with stakingToken
    uint256 public internalStakingTokenBalance;

    /// @notice Last reward balance 
    uint256 public lastRewardBalance;

    /// @notice Accumulated rewards per share, scaled to `ACC_REWARD_PER_SHARE_PRECISION`
    uint256 public accRewardPerShare;

    /// @notice The precision of `accRewardPerShare`
    uint256 public ACC_REWARD_PER_SHARE_PRECISION;

    /// @dev Info of each user that stakes stakingToken
    mapping(address => UserInfo) private userInfo;


    event Deposit(address user, uint256 amount);
    event Withdrawal(address user, uint256 amount);
    event LogWithdrawalBNB(address account, uint256 amount);
    event LogWithdrawToken(address token, address account, uint256 amount);
    event LogUpdateDeployerAddress(address newDeployer);

    /// @notice Emitted when a user claims reward
    event ClaimReward(address indexed user, uint256 amount);


    /** 
     * @dev Throws if called by any account other than the owner or deployer.
     */
    modifier onlyDeployer() {
        require(deployer == _msgSender(), "Ownable: caller is not the deployer");
        _;
    }

    constructor(address _stakingContract, address _stakingToken, address _dividendToken){
        require(_stakingContract != address(0), "StakingContract Address 0 validation");
        require(_stakingToken != address(0), "StakingToken Address 0 validation");
        require(_dividendToken != address(0), "DividendToken Address 0 validation");
        deployer = _msgSender();
        stakingContract = _stakingContract;
        stakingToken = IERC20(_stakingToken);
        dividendToken = IERC20(_dividendToken);
        ACC_REWARD_PER_SHARE_PRECISION = 1e24;
        transferOwnership(_stakingContract);
    }

    function deposit(address staker, uint256 amount) external onlyOwner{
        require(stakingToken.allowance(staker, address(this)) >= amount, "Insufficient allowance.");
        UserInfo storage user = userInfo[staker];
        uint256 _previousAmount = user.amount;
        uint256 _newAmount = user.amount.add(amount);
        user.amount = _newAmount;

        updateReward();
        uint256 _previousRewardDebt = user.rewardDebt;
        user.rewardDebt = _newAmount.mul(accRewardPerShare).div(ACC_REWARD_PER_SHARE_PRECISION);
        if (_previousAmount != 0) {
            uint256 _pending = _previousAmount
                .mul(accRewardPerShare)
                .div(ACC_REWARD_PER_SHARE_PRECISION)
                .sub(_previousRewardDebt);
            if (_pending != 0) {
                safeTokenTransfer(staker, _pending);
                emit ClaimReward(staker, _pending);
            }
        }
        
        internalStakingTokenBalance = internalStakingTokenBalance.add(amount);
        stakingToken.transferFrom(staker, address(this), amount);
        emit Deposit(staker, amount);
    }

    /**
     * @notice Get user info
     * @param _user The address of the user
     * @return The amount of stakingToken user has deposited
     * @return The reward debt for the chosen token
     */
    function getUserInfo(address _user) external view returns (uint256, uint256) {
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
        uint256 _totalStakingToken = internalStakingTokenBalance;
        uint256 _accRewardTokenPerShare = accRewardPerShare;

        uint256 _currRewardBalance = dividendToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        if (_rewardBalance != lastRewardBalance && _totalStakingToken != 0) {
            uint256 _accruedReward = _rewardBalance.sub(lastRewardBalance);
            _accRewardTokenPerShare = _accRewardTokenPerShare.add(
                _accruedReward.mul(ACC_REWARD_PER_SHARE_PRECISION).div(_totalStakingToken)
            );
        }
        return
            user.amount.mul(_accRewardTokenPerShare).div(ACC_REWARD_PER_SHARE_PRECISION).sub(user.rewardDebt);
    }

    function withdraw(address staker, uint256 amount) external onlyOwner{
        UserInfo storage user = userInfo[staker];
        uint256 _previousAmount = user.amount;
        require(_previousAmount >= amount, "Insufficient funds");
        uint256 _newAmount = user.amount.sub(amount);
        user.amount = _newAmount;

        if (_previousAmount != 0) { 
            updateReward();   
            uint256 _pending = _previousAmount
                .mul(accRewardPerShare)
                .div(ACC_REWARD_PER_SHARE_PRECISION)
                .sub(user.rewardDebt);
            user.rewardDebt = _newAmount.mul(accRewardPerShare).div(ACC_REWARD_PER_SHARE_PRECISION) ;  
            if (_pending != 0) {
                safeTokenTransfer(staker, _pending);
                emit ClaimReward(staker, _pending);
            }
        }
      

        internalStakingTokenBalance = internalStakingTokenBalance.sub(amount);
        stakingToken.transfer(staker, amount);
        emit Withdrawal(staker, amount);
    }

    function withdrawDividends() external {
        UserInfo storage user = userInfo[msg.sender];
        if (user.amount != 0) { 
            updateReward();   
            uint256 _pending = user.amount
                .mul(accRewardPerShare)
                .div(ACC_REWARD_PER_SHARE_PRECISION)
                .sub(user.rewardDebt);
            user.rewardDebt = user.amount.mul(accRewardPerShare).div(ACC_REWARD_PER_SHARE_PRECISION) ;  
            if (_pending != 0) {
                safeTokenTransfer(msg.sender, _pending);
                emit ClaimReward(msg.sender, _pending);
            }
        }
    }

    /**
     * @notice Update reward variables
     * @dev Needs to be called before any deposit or withdrawal
     */
    function updateReward() public {
        uint256 _totalStakingToken = internalStakingTokenBalance;

        uint256 _currRewardBalance = dividendToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;
    

        // Did  tresuary receive any token
        if (_rewardBalance == lastRewardBalance || _totalStakingToken == 0) {
            return;
        }

        uint256 _accruedReward = _rewardBalance.sub(lastRewardBalance);

        accRewardPerShare = accRewardPerShare.add(
            _accruedReward.mul(ACC_REWARD_PER_SHARE_PRECISION).div(_totalStakingToken)
        );
        lastRewardBalance = _rewardBalance;
    }

    /**
     * @notice Safe token transfer function, just in case if rounding error
     * causes pool to not have enough reward tokens
     * @param _to The address that will receive `_amount` `rewardToken`
     * @param _amount The amount to send to `_to`
     */
    function safeTokenTransfer(
        address _to,
        uint256 _amount
    ) internal {
        uint256 _currRewardBalance = dividendToken.balanceOf(address(this));
        uint256 _rewardBalance = _currRewardBalance;

        if (_amount > _rewardBalance) {
            lastRewardBalance = lastRewardBalance.sub(_rewardBalance);
            dividendToken.transfer(_to, _rewardBalance);
        } else {
            lastRewardBalance = lastRewardBalance.sub(_amount);
            dividendToken.transfer(_to, _amount);
        }
    }

    function withdrawBNB(address payable account, uint256 amount) external onlyDeployer {
      require(amount <= (address(this)).balance, "Incufficient funds");
      safeTransferBNB(account, amount);
      emit LogWithdrawalBNB(account, amount);
    }

    // Internal function to handle safe transfer
    function safeTransferBNB(address to, uint256 value) internal {
       (bool success, ) = to.call{value: value}(new bytes(0));
       require(success);
    }

    /**
     * @notice Should not be withdrawn scam token.
     */
    function withdrawToken(address token, address account, uint256 amount) external onlyDeployer {
        require(amount <= IERC20(token).balanceOf(account), "Incufficient funds");
        require(token != address(dividendToken), "Can't withdraw dividendToken");
        require(token != address(stakingToken), "Can't withdraw stakingToken");
        require(IERC20(token).transfer(account, amount), "Transfer Fail");

        emit LogWithdrawToken(address(token), account, amount);
    }

    function updateDeployerAddress(address newDeployer) external onlyDeployer{
      require(deployer != newDeployer, "The address is already set");
      deployer = newDeployer;
      emit LogUpdateDeployerAddress(newDeployer);
    }
    
}