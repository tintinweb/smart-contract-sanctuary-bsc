// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MetooIDO is Ownable {
    using SafeMath for uint256;

    IERC20 public currency;
    IERC20 public token;
    uint256 public price;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public firstVestingTime;
    uint256 public secondVestingTime;

    bool public isFinalized;
    bool public isCanceled;
    uint256 public currentCap;

    struct PurchaseDetail {
        address purchaser;
        uint256 amount;
        uint256 claimedAmount;
        bool isDone;
    }

    mapping(address => PurchaseDetail) public purchaseDetails;
    address[] public purchasers;

    event Purchased(address indexed purchaser, uint256 amount);
    event Claimed(address indexed purchaser, uint256 claimedAmount);
    event Refunded(address indexed purchaser, uint256 amount);
    event FinalizedSale();
    event CanceledSale();

    constructor(
        address _currency,
        address _token,
        uint256 _price,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _firstVestingTime,
        uint256 _secondVestingTime
    ) {
        currency = IERC20(_currency);
        token = IERC20(_token);
        price = _price;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        startTime = _startTime;
        endTime = _endTime;
        firstVestingTime = _firstVestingTime;
        secondVestingTime = _secondVestingTime;
    }

    modifier occurring() {
        require(
            block.timestamp >= startTime &&
                block.timestamp <= endTime &&
                !isFinalized,
            "NOT_OCCURRING"
        );
        _;
    }

    modifier validAmount(uint256 amount) {
        require(amount >= minAmount && amount <= maxAmount, "INVALID_AMOUNT");
        _;
    }

    modifier finalized() {
        require(isFinalized, "NOT_FINALIZED_YET");
        _;
    }

    modifier canceled() {
        require(isCanceled, "NOT_CANCELED");
        _;
    }

    function setTime(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _firstVestingTime,
        uint256 _secondVestingTime
    ) external onlyOwner {
        require(_firstVestingTime < _secondVestingTime, "INVALID_TIME");

        startTime = _startTime;
        endTime = _endTime;
        firstVestingTime = _firstVestingTime;
        secondVestingTime = _secondVestingTime;
    }

    function getAllPurchasers() public view returns (PurchaseDetail[] memory) {
        uint256 length = purchasers.length;
        PurchaseDetail[] memory allPurchasers = new PurchaseDetail[](length);

        for (uint8 i = 0; i < length; i++) {
            allPurchasers[i] = purchaseDetails[purchasers[i]];
        }

        return allPurchasers;
    }

    function calcClaimAmount(address purchaser) public view returns (uint256) {
        if (block.timestamp < firstVestingTime) return 0;
        PurchaseDetail memory purchaseDetail = purchaseDetails[purchaser];
        uint256 fullClaimAmount = purchaseDetail.amount.div(price).mul(1 ether);

        if (block.timestamp < secondVestingTime)
            return fullClaimAmount.div(2).sub(purchaseDetail.claimedAmount);
        else return fullClaimAmount.sub(purchaseDetail.claimedAmount);
    }

    function calcTotalTokenAmount() public view returns (uint256) {
        return currentCap.div(price).mul(1 ether);
    }

    function purchase(uint256 amount) external occurring validAmount(amount) {
        currency.transferFrom(msg.sender, address(this), amount);

        PurchaseDetail memory purchaseDetail = purchaseDetails[msg.sender];
        currentCap = currentCap.add(amount);
        if (purchaseDetail.purchaser == address(0)) {
            purchaseDetails[msg.sender].purchaser = msg.sender;
            purchasers.push(msg.sender);
        }
        purchaseDetails[msg.sender].amount = purchaseDetail.amount.add(amount);

        emit Purchased(msg.sender, amount);
    }

    function finalize(address _to) external onlyOwner {
        require(!isCanceled, "ALREADY_CANCELED");
        require(!isFinalized, "ALREADY_FINALIZED");
        isFinalized = true;

        // for project
        currency.transfer(_to, currentCap);

        emit FinalizedSale();
    }

    function cancelSale() external onlyOwner {
        require(!isFinalized, "ALREADY_FINALIZED");
        require(!isCanceled, "ALREADY_CANCELED");
        isCanceled = true;

        emit CanceledSale();
    }

    function refund() external canceled {
        PurchaseDetail memory purchaseDetail = purchaseDetails[msg.sender];
        require(
            purchaseDetail.amount > 0 && !purchaseDetail.isDone,
            "INVALID_ACTION"
        );

        purchaseDetails[msg.sender].isDone = true;
        currency.transfer(msg.sender, purchaseDetail.amount);

        emit Refunded(msg.sender, purchaseDetail.amount);
    }

    function claim() external finalized {
        PurchaseDetail memory purchaseDetail = purchaseDetails[msg.sender];
        require(
            purchaseDetail.amount > 0 && !purchaseDetail.isDone,
            "INVALID_ACTION"
        );

        uint256 claimAmount = calcClaimAmount(purchaseDetail.purchaser);
        token.transfer(msg.sender, claimAmount);
        purchaseDetails[msg.sender].claimedAmount = purchaseDetail
            .claimedAmount
            .add(claimAmount);

        if (block.timestamp >= secondVestingTime)
            purchaseDetails[msg.sender].isDone = true;

        emit Claimed(msg.sender, claimAmount);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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