/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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

contract Referral is Ownable {
    using SafeMath for uint256;

    IERC20 public immutable token;

    struct Referrer {
        address invitedBy;
        address userAddress;
        uint stakeComission;
        uint stakedAmount;
        uint APR;
        uint staking_days;
        uint timestamp;
    }

    address[] public Referrees;

    mapping(address => Referrer) public RQ;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function stake(uint _amount, uint _staking_days) public {
        require(_amount >= 1 * 10 ** 18, "Stake amount must be at least 1");
        require(RQ[msg.sender].staking_days <= 0, "You have staked already");
        if (
            _staking_days == 30 ||
            _staking_days == 90 ||
            _staking_days == 180 ||
            _staking_days == 365
        ) {
            // 86400 is per day seconds
            RQ[msg.sender].timestamp =
                (86400 * _staking_days) +
                block.timestamp;
            RQ[msg.sender].stakedAmount = _amount;
            RQ[msg.sender].staking_days = _staking_days;
            RQ[msg.sender].APR = _staking_days == 30 ? 3 : _staking_days == 90
                ? 10
                : _staking_days == 180
                ? 20
                : 45;
            token.transferFrom(msg.sender, address(this), _amount);
        } else {
            revert("Invalid days");
        }
        RQ[msg.sender].userAddress = msg.sender;
        Referrees.push(msg.sender);
    }

    function referredStake(
        address _friend,
        uint _amount,
        uint _staking_days
    ) public {
        require(
            RQ[_friend].stakedAmount > 0,
            "Referral address must have staked"
        );
        require(_amount >= 1 * 10 ** 18, "Stake amount must be at least 1");
        require(RQ[msg.sender].staking_days <= 0, "You have staked already");
        if (
            _staking_days == 30 ||
            _staking_days == 90 ||
            _staking_days == 180 ||
            _staking_days == 365
        ) {
            // 86400 is per day seconds
            RQ[msg.sender].timestamp =
                (86400 * _staking_days) +
                block.timestamp;
            RQ[msg.sender].stakedAmount = _amount;
            RQ[msg.sender].staking_days = _staking_days;
            RQ[msg.sender].APR = _staking_days == 30 ? 3 : _staking_days == 90
                ? 10
                : _staking_days == 180
                ? 20
                : 45;
            token.transferFrom(msg.sender, address(this), _amount);
        } else {
            revert("Invalid days");
        }

        RQ[msg.sender].userAddress = msg.sender;
        RQ[msg.sender].invitedBy = _friend;
        Referrees.push(msg.sender);

        for (uint i = 0; i < Referrees.length; i++) {
            address L1 = RQ[_friend].userAddress;
            address L2 = RQ[_friend].invitedBy;
            address L3 = RQ[L2].invitedBy;
            address L4 = RQ[L3].invitedBy;
            address L5 = RQ[L4].invitedBy;

            if (Referrees[i] == _friend) {
                RQ[L1].stakeComission += (RQ[L1].stakedAmount * 2) / 100;
            }
            if (Referrees[i] == RQ[L1].invitedBy) {
                RQ[L2].stakeComission += (RQ[L2].stakedAmount * 1) / 100;
            }
            if (Referrees[i] == RQ[L2].invitedBy) {
                RQ[L3].stakeComission += (RQ[L3].stakedAmount * 1) / 100;
            }
            if (Referrees[i] == RQ[L3].invitedBy) {
                RQ[L4].stakeComission += (RQ[L4].stakedAmount * 1) / 200;
            }
            if (Referrees[i] == RQ[L4].invitedBy) {
                RQ[L5].stakeComission += (RQ[L5].stakedAmount * 1) / 200;
            }
        }
    }

    function claimRewards() public {
        require(
            RQ[msg.sender].stakeComission > 0,
            "stake comission must be greater than 0"
        );
        uint comission = RQ[msg.sender].stakeComission;
        token.transfer(msg.sender, comission);
        RQ[msg.sender].stakeComission = 0;
    }

    function UnStaking() public {
        Referrer storage user = RQ[msg.sender];
        if (user.staking_days < 1) revert("Please stake first");
        if (user.timestamp > block.timestamp)
            revert("you can't unstake until time limit is complete");
        uint values = (user.stakedAmount * user.APR) / 100;
        uint result = (values) / (user.staking_days);

        token.transfer(msg.sender, result + user.stakedAmount);
        RQ[msg.sender].stakedAmount = 0;
        RQ[msg.sender].staking_days = 0;
        RQ[msg.sender].timestamp = 0;
        RQ[msg.sender].APR = 0;
        if (RQ[msg.sender].stakeComission > 0) {
            token.transfer(msg.sender, RQ[msg.sender].stakeComission);
            RQ[msg.sender].stakeComission = 0;
        }

        uint256 indexToRemove;
        for (uint256 i = 0; i < Referrees.length; i++) {
            if (Referrees[i] == RQ[msg.sender].userAddress) {
                indexToRemove = i;
                break;
            }
        }
        if (indexToRemove >= Referrees.length) {
            return;
        }
        uint256 length = Referrees.length;
        address[] memory newReferrees = new address[](length - 1);
        for (uint256 i = 0; i < indexToRemove; i++) {
            newReferrees[i] = Referrees[i];
        }
        for (uint256 i = indexToRemove + 1; i < length; i++) {
            newReferrees[i - 1] = Referrees[i];
        }
        Referrees = newReferrees;
    }

    function deposit(uint amount) external onlyOwner {
        require(amount > 0, "Depost value must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount * 1 * 10 ** 18);
    }

    function withdraw(uint amount) external onlyOwner {
        require(
            token.balanceOf(address(this)) > 0,
            "There is not enough token in contract"
        );
        token.transferFrom(address(this), msg.sender, amount * 1 * 10 ** 18);
    }

    function checkAmount() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}