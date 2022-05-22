/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

//SPDX-License-Identifier: Unlicensed
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

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

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

contract Divident is Ownable {
    using SafeMath for uint256;

    address public velTokenAddress;
    address public usdtTokenAddress;

    struct Reward {
        uint256 velTokenReward;
        uint256 usdtTokenRewad;
        uint256 velTokenPaidAmount;
        uint256 usdtTokenPaidAmount;
    }
    mapping(address => Reward) accountRewards;

    uint256 public totalPaidVelAmount;
    uint256 public totalPaidUsdtAmount;
    uint256 public totalPendingVelAmount;
    uint256 public totalPendingUsdtAmount;

    event GrantAccountVELToken(address indexed account, uint256 velAmount);
    event GrantAccountUSDTToken(address indexed account, uint256 usdtAmount);
    event GrantMultipleVELToken(address[] accounts, uint256[] velAmount);
    event GrantMultipleUSDTToken(address[] accounts, uint256[] usdtAmount);
    event ClaimVELToken(address indexed account, uint256 velAmount);
    event ClaimUSDTToken(address indexed account, uint256 usdtAmount);

    constructor(address _usdtTokenAddress, address _velTokenAddress) {
        velTokenAddress = _velTokenAddress;
        usdtTokenAddress= _usdtTokenAddress;
    }

    function setAssetsAddress(address _velTokenAddress, address _usdtTokenAddress) external onlyOwner {
         velTokenAddress = _velTokenAddress;
         usdtTokenAddress = _usdtTokenAddress;
    }

    function claim() public {
        Reward storage reward = accountRewards[msg.sender];
        require(reward.velTokenReward > 0 || reward.usdtTokenRewad > 0, "You have no amount claim");
        if(reward.velTokenReward > 0) {
            uint256 velReward = reward.velTokenReward;
            IERC20(velTokenAddress).approve(address(this), velReward);
            IERC20(velTokenAddress).transferFrom(address(this), msg.sender, velReward);
            reward.velTokenPaidAmount = reward.velTokenPaidAmount.add(velReward);
            reward.velTokenReward = 0;
            totalPaidVelAmount = totalPaidVelAmount.add(velReward);
            totalPendingVelAmount = totalPendingVelAmount.sub(velReward);
            emit ClaimVELToken(msg.sender, velReward);
        }
        if(reward.usdtTokenRewad > 0) {
            uint256 usdtReward = reward.usdtTokenRewad;
            IERC20(usdtTokenAddress).approve(address(this), usdtReward);
            IERC20(usdtTokenAddress).transferFrom(address(this), msg.sender, usdtReward);
            reward.usdtTokenPaidAmount = reward.usdtTokenPaidAmount.add(usdtReward);
            reward.usdtTokenRewad = 0;
            totalPaidUsdtAmount = totalPaidUsdtAmount.add(usdtReward);
            totalPendingUsdtAmount = totalPendingUsdtAmount.sub(usdtReward);
            emit ClaimUSDTToken(msg.sender, usdtReward);
        }
    }

    function setAccountVELToken(address _account, uint256 _velAmount) external onlyOwner {
        require(_velAmount > 0 , "amount error");
        require(_account != address(0), "zero address");
        Reward storage reward = accountRewards[_account];
        if(reward.velTokenReward > _velAmount) {
            totalPendingVelAmount = totalPendingVelAmount.sub(reward.velTokenReward.sub(_velAmount));
        } else {
            totalPendingVelAmount = totalPendingVelAmount.add(_velAmount.sub(reward.velTokenReward));
        }
        reward.velTokenReward = _velAmount;
        emit GrantAccountVELToken(_account, _velAmount);
    }

    function setAccountUSDTToken(address _account, uint256 _usdtAmount) external onlyOwner {
        require(_usdtAmount > 0 , "amount error");
        require(_account != address(0), "zero address");
        Reward storage reward = accountRewards[_account];
        if(reward.usdtTokenRewad > _usdtAmount) {
            totalPendingUsdtAmount = totalPendingUsdtAmount.sub(reward.usdtTokenRewad.sub(_usdtAmount));
        } else {
            totalPendingUsdtAmount = totalPendingUsdtAmount.add(_usdtAmount.sub(reward.usdtTokenRewad));
        }
        reward.usdtTokenRewad = _usdtAmount;
        emit GrantAccountUSDTToken(_account, _usdtAmount);
    }

    function grantMultipleVELToken(address[] memory _accounts, uint256[] memory _velAmount) external onlyOwner {
        require(_accounts.length == _velAmount.length, "Data error");
        uint256 balance = IERC20(velTokenAddress).balanceOf(address(this));
        for(uint256 i = 0; i < _accounts.length; i++) {
            uint256 amount = _velAmount[i];
            require(balance >= amount, "amount error");
            if(amount <= 0 || _accounts[i] == address(0)) continue;
            Reward storage reward = accountRewards[_accounts[i]];
            reward.velTokenReward = reward.velTokenReward.add(amount);
            totalPendingVelAmount = totalPendingVelAmount.add(amount);
        }
        emit GrantMultipleVELToken(_accounts, _velAmount);
    }

    function grantMultipleUSDTToken(address[] memory _accounts, uint256[] memory _usdtAmount) external onlyOwner {
        require(_accounts.length == _usdtAmount.length, "Data error");
        uint256 balance = IERC20(usdtTokenAddress).balanceOf(address(this));
        for(uint256 i = 0; i < _accounts.length; i++) {
            uint256 amount = _usdtAmount[i];
            require(balance >= amount, "amount error");
            if(amount <= 0 || _accounts[i] == address(0)) continue;
            Reward storage reward = accountRewards[_accounts[i]];
            reward.usdtTokenRewad = reward.usdtTokenRewad.add(amount);
            totalPendingUsdtAmount = totalPendingUsdtAmount.add(amount);
        }
        emit GrantMultipleUSDTToken(_accounts, _usdtAmount);
    }

    function getAccountPendingReward(address _account) public view returns(uint256, uint256) {
        Reward storage reward = accountRewards[_account];
        return(reward.velTokenReward, reward.usdtTokenRewad);
    }

    function getAccountPaidReward(address _account) public view returns(uint256, uint256) {
        Reward storage reward = accountRewards[_account];
        return (reward.velTokenPaidAmount, reward.usdtTokenPaidAmount);
    }
}