//SPDX-License-Identifier: mit
pragma solidity ^0.8.0;

import "Ownable.sol";
import "IERC20.sol";
import "Counters.sol";
import "SafeMath.sol";
import "AggregatorV3Interface.sol";
import "ReentrancyGuard.sol";

contract voucherFast is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenVoucherId;
    Counters.Counter private _nativeVoucherId;

    mapping(string => uint256) private voucherBalance;
    mapping(uint256 => TokenVoucherItem) tokenVouchers;
    mapping(uint256 => NativeVoucherItem) nativeVouchers;

    address[] public allowedTokens;
    address public voucherFastTaskAddress;

    uint256 payableTaskPercentage;

    bool isChargesActive;

    struct TokenVoucherItem {
        string ref;
        address payable owner;
        address payable redeemedBy;
        address token;
        uint256 amount;
        bool status;
        bool isRedeemed;
    }

    event TokenVoucherItemCreated(
        string ref,
        address payable owner,
        address payable redeemedBy,
        address token,
        uint256 amount,
        bool status,
        bool isRedeemed
    );

    struct NativeVoucherItem {
        string ref;
        address payable owner;
        address payable redeemedBy;
        uint256 amount;
        bool status;
        bool isRedeemed;
    }

    event NativeVoucherItemCreated(
        string ref,
        address payable owner,
        address payable redeemedBy,
        uint256 amount,
        bool status,
        bool isRedeemed
    );

    constructor(address _taskAddress) {
        voucherFastTaskAddress = _taskAddress;
    }

    function addSupportedToken(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function updateVoucherFastTaskAccount(address _taskAddress)
        public
        onlyOwner
    {
        voucherFastTaskAddress = _taskAddress;
    }

    function addTaskPercentage(uint256 _percentage) public onlyOwner {
        payableTaskPercentage = _percentage;
    }

    function activateCharges(bool _isActive) public onlyOwner {
        isChargesActive = _isActive;
    }

    function createTokenVoucher(
        string memory _ref,
        uint256 _amount,
        address _token
    ) public payable nonReentrant {
        require(_amount > 0, "Amount must be more than 0");
        require(tokenIsAllowed(_token), "Token is currently not allowed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        _tokenVoucherId.increment();
        uint256 newPTokenVoucherId = _tokenVoucherId.current();
        tokenVouchers[newPTokenVoucherId] = TokenVoucherItem(
            _ref,
            payable(msg.sender),
            payable(address(0)),
            _token,
            _amount,
            false,
            false
        );

        emit TokenVoucherItemCreated(
            _ref,
            payable(msg.sender),
            payable(address(0)),
            _token,
            _amount,
            false,
            false
        );
    }

    function fetchMyTokenVouchers()
        public
        view
        returns (TokenVoucherItem[] memory)
    {
        uint256 totalVoucherCount = _tokenVoucherId.current();

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (tokenVouchers[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        TokenVoucherItem[] memory items = new TokenVoucherItem[](itemCount);

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (tokenVouchers[i + 1].owner == msg.sender) {
                uint256 currentID = i + 1;
                TokenVoucherItem storage currentItem = tokenVouchers[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNativeVouchers()
        public
        view
        returns (NativeVoucherItem[] memory)
    {
        uint256 totalVoucherCount = _nativeVoucherId.current();

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (nativeVouchers[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        NativeVoucherItem[] memory items = new NativeVoucherItem[](itemCount);

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (nativeVouchers[i + 1].owner == msg.sender) {
                uint256 currentID = i + 1;
                NativeVoucherItem storage currentItem = nativeVouchers[
                    currentID
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyRedeemedNativeVouchers()
        public
        view
        returns (NativeVoucherItem[] memory)
    {
        uint256 totalVoucherCount = _nativeVoucherId.current();

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (nativeVouchers[i + 1].redeemedBy == msg.sender) {
                itemCount += 1;
            }
        }

        NativeVoucherItem[] memory items = new NativeVoucherItem[](itemCount);

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (nativeVouchers[i + 1].redeemedBy == msg.sender) {
                uint256 currentID = i + 1;
                NativeVoucherItem storage currentItem = nativeVouchers[
                    currentID
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyRedemedTokenVouchers()
        public
        view
        returns (TokenVoucherItem[] memory)
    {
        uint256 totalVoucherCount = _tokenVoucherId.current();

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (tokenVouchers[i + 1].redeemedBy == msg.sender) {
                itemCount += 1;
            }
        }

        TokenVoucherItem[] memory items = new TokenVoucherItem[](itemCount);

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (tokenVouchers[i + 1].redeemedBy == msg.sender) {
                uint256 currentID = i + 1;
                TokenVoucherItem storage currentItem = tokenVouchers[currentID];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function createNativeVoucher(string memory _ref)
        public
        payable
        nonReentrant
    {
        require(msg.value > 0, "Amount must be more than 0");

        _nativeVoucherId.increment();
        uint256 newNativeVoucherId = _nativeVoucherId.current();

        nativeVouchers[newNativeVoucherId] = NativeVoucherItem(
            _ref,
            payable(msg.sender),
            payable(address(0)),
            msg.value,
            false,
            false
        );

        emit NativeVoucherItemCreated(
            _ref,
            payable(msg.sender),
            payable(address(0)),
            msg.value,
            false,
            false
        );
    }

    function redeemNativeVoucher(string memory _ref)
        public
        payable
        nonReentrant
    {
        uint256 totalVoucherCount = _nativeVoucherId.current();

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (
                (keccak256(abi.encodePacked((nativeVouchers[i + 1].ref))) ==
                    keccak256(abi.encodePacked((_ref))))
            ) {
                require(
                    !isNativeVoucherValid(i + 1),
                    "Voucher is used Already"
                );
                uint256 voucherAmount = nativeVouchers[i + 1].amount;
                if (isChargesActive == true) {
                    uint256 task = voucherAmount.mul(payableTaskPercentage).div(
                        10**2
                    );

                    uint256 balanceAfterTask = voucherAmount.sub(task);
                    transferNativeAssettoAddress(
                        payable(voucherFastTaskAddress),
                        task
                    );
                    transferNativeAssettoAddress(
                        payable(msg.sender),
                        balanceAfterTask
                    );
                } else {
                    transferNativeAssettoAddress(
                        payable(msg.sender),
                        nativeVouchers[i + 1].amount
                    );
                }

                nativeVouchers[i + 1].redeemedBy = payable(msg.sender);
                nativeVouchers[i + 1].status = true;
                nativeVouchers[i + 1].isRedeemed = true;
            }
        }
    }

    function redeemTokenVoucher(string memory _ref, address _token)
        public
        payable
        nonReentrant
    {
        require(tokenIsAllowed(_token), "Token is currently not allowed");
        uint256 totalVoucherCount = _tokenVoucherId.current();

        for (uint256 i = 0; i < totalVoucherCount; i++) {
            if (
                (keccak256(abi.encodePacked((tokenVouchers[i + 1].ref))) ==
                    keccak256(abi.encodePacked((_ref)))) &&
                tokenVouchers[i + 1].token == _token
            ) {
                require(isTokenVoucherValid(i + 1), "Voucher is used Already");
                uint256 voucherAmount = tokenVouchers[i + 1].amount;
                if (isChargesActive == true) {
                    uint256 task = voucherAmount.mul(payableTaskPercentage).div(
                        10**2
                    );
                    uint256 balanceAfterTask = voucherAmount.sub(task);
                    IERC20(_token).transfer(voucherFastTaskAddress, task);
                    IERC20(_token).transfer(msg.sender, balanceAfterTask);
                } else {
                    IERC20(_token).transfer(
                        msg.sender,
                        tokenVouchers[i + 1].amount
                    );
                }

                tokenVouchers[i + 1].redeemedBy = payable(msg.sender);
                tokenVouchers[i + 1].status = true;
                tokenVouchers[i + 1].isRedeemed = true;
            }
        }
    }

    function tokenIsAllowed(address _token) public view returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function isTokenVoucherValid(uint256 _voucherId)
        public
        view
        returns (bool)
    {
        return tokenVouchers[_voucherId].isRedeemed;
    }

    function isNativeVoucherValid(uint256 _voucherId)
        public
        view
        returns (bool)
    {
        return nativeVouchers[_voucherId].isRedeemed;
    }

    function calculateTask(uint256 _amount) public view returns (uint256) {
        if (isChargesActive == true) {
            uint256 task = _amount.mul(payableTaskPercentage).div(10**2);

            return task;
        }

        return 0;
    }

    function transferNativeAssettoAddress(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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

    constructor () {
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