//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICactusToken.sol";

contract CactusPrivateSale is Ownable {
    using SafeMath for uint256;

    ICactusToken public cactt;
    address public payableAddress;

    mapping(address => HolderInfo) private _privatesaleInfo;

    bool public openPrivatesale = false;

    address[] private _privatesale;

    uint256 public privatesaleDistributed;
    uint256 private _newPaymentInterval = 2592000;
    uint256 private _privatesaleHoldingCap = 96000 * 10**18;
    uint256 public _minimumPruchaseInBNB = 2 * 10**18; // 2BNB
    uint256 private _cattPerBNB = 9600; // current price as per the time of private sale

    mapping(address => bool) public operators;

    struct HolderInfo {
        uint256 total;
        uint256 monthlyCredit;
        uint256 amountLocked;
        uint256 nextPaymentUntil;
        uint256 initial;
        bool payedInitial;
    }

    constructor(ICactusToken _cactt, address _payableAddress) {
        cactt = _cactt;
        payableAddress = _payableAddress;
        operators[owner()] = true;
        emit OperatorUpdated(owner(), true);
    }

    event PrivatesaleStatusChanged(
        bool indexed previusState,
        bool indexed newState
    );

    function setCACTT(ICactusToken _newCactt) public onlyOwner {
        cactt = _newCactt;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    event OperatorUpdated(address indexed operator, bool indexed status);

    function registerPrivatesale(address _account) external payable {
        require(openPrivatesale, "Sale is not in session.");
        require(msg.value > 0, "Invalid amount of BNB sent!");
        uint256 _cattAmount = msg.value * _cattPerBNB;
        privatesaleDistributed = privatesaleDistributed.add(_cattAmount);
        HolderInfo memory holder = _privatesaleInfo[_account];
        if (holder.total <= 0) {
            _privatesale.push(_account);
        }
        require(
            msg.value >= _minimumPruchaseInBNB,
            "Minimum amount to buy is 2BNB"
        );
        require(
            _cattAmount <= _privatesaleHoldingCap,
            "You cannot hold more than 10BNB worth of DIBA"
        );
        require(
            cactt.WHITELIST_ALLOCATION() >= privatesaleDistributed,
            "Distribution reached its max"
        );
        require(
            _privatesaleHoldingCap >= holder.total.add(_cattAmount),
            "Amount exceeds holding limit!"
        );
        payable(payableAddress).transfer(msg.value);
        uint256 initialPayment = _cattAmount.div(2); // Release 50% of payment
        uint256 credit = _cattAmount.div(2);

        holder.total = holder.total.add(_cattAmount);
        holder.amountLocked = holder.amountLocked.add(credit);
        holder.monthlyCredit = holder.amountLocked.div(5); // divide amount locked to 5 months
        holder.nextPaymentUntil = block.timestamp.add(_newPaymentInterval);
        holder.payedInitial = false;
        holder.initial = initialPayment;
        _privatesaleInfo[_account] = holder;
    }

    function initialPaymentRelease() public onlyOperator {
        for (uint256 i = 0; i < _privatesale.length; i++) {
            HolderInfo memory holder = _privatesaleInfo[_privatesale[i]];
            if (!holder.payedInitial) {
                uint256 amount = holder.initial;
                holder.payedInitial = true;
                holder.initial = 0;
                _privatesaleInfo[_privatesale[i]] = holder;
                cactt.mint(_privatesale[i], amount);
            }
        }
    }

    function timelyPrivatesalePaymentRelease() public onlyOperator {
        for (uint256 i = 0; i < _privatesale.length; i++) {
            HolderInfo memory holder = _privatesaleInfo[_privatesale[i]];
            if (
                holder.amountLocked > 0 &&
                block.timestamp >= holder.nextPaymentUntil
            ) {
                holder.amountLocked = holder.amountLocked.sub(
                    holder.monthlyCredit
                );
                holder.nextPaymentUntil = block.timestamp.add(
                    _newPaymentInterval
                );
                _privatesaleInfo[_privatesale[i]] = holder;
                cactt.mint(_privatesale[i], holder.monthlyCredit);
            }
        }
    }

    function holderInfo(address _holderAddress)
        public
        view
        returns (HolderInfo memory)
    {
        return _privatesaleInfo[_holderAddress];
    }

    function changePayableAddress(address _payableAddress) public onlyOperator {
      payableAddress = _payableAddress;
    }

    function updateOperator(address _operator, bool _status)
        public
        onlyOperator
    {
        operators[_operator] = _status;
        emit OperatorUpdated(_operator, _status);
    }

    function setMinimumCact(uint256 _amount) public onlyOperator {
        _minimumPruchaseInBNB = _amount;
    }

    function enablePrivatesale() public onlyOperator {
        if (!openPrivatesale) {
            emit PrivatesaleStatusChanged(false, true);
            openPrivatesale = true;
            uint256 privatesaleBalance = cactt.WHITELIST_ALLOCATION().sub(
                privatesaleDistributed
            );
            cactt.burn(owner(), privatesaleBalance);
        }
    }

    function closePrivatesale() public onlyOperator {
        emit PrivatesaleStatusChanged(true, false);
        openPrivatesale = false;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ICactusToken {
    function mint(address receiver, uint256 amount) external;

    function burn(address sender, uint256 amount) external;
    function cap() external;
    function teamAddress() external returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address sender,
        address recipient,
        uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

    function TEAM_ALLOCATION() external returns (uint256);
    function AIRDROP_AMOUNT() external returns (uint256);
    function WHITELIST_ALLOCATION() external returns (uint256);

    function MARKETING_RESERVE_AMOUNT() external returns (uint256);
    function STAKING_ALLOCATION() external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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