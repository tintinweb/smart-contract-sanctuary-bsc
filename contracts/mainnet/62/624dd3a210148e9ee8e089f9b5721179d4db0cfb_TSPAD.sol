/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function insert(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function insert(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function insert(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: @openzeppelin\contracts\utils\ReentrancyGuard.sol
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Referrable {
    using EnumerableSet for EnumerableSet.AddressSet;

    event ReferralCreated(address creator);
    event ReferralUsed(address referrer, address referred);
    event ReferralPrizeRedeemed(address referrer);

    struct Referral {
        uint256 referrerPrize;
        uint256 referredPrize;
        uint256 prize;
    }

    mapping(address => Referral) public referrals;

    EnumerableSet.AddressSet private alreadyReferred;
    uint256 public baseReferral;
    uint256 public baseReferralDecimals;

    /**
		@param _baseReferral Maximum referral prize that will be splitted between the referrer
				and the referred
		@param _baseReferralDecimals Number of decimal under the base (18) the referral value is.
				This values allow for decimal values like 0.5%, the minimum is 0.[0 x 17 times]1 
	 */
    constructor(uint256 _baseReferral, uint256 _baseReferralDecimals) {
        baseReferralDecimals = 18;

        // high precision (18 decimals) the base referral is already in the normalized form
        // 1_[0 x 18 times] = 1%
        // 5_[0 x 17 times] = 0.5%
        baseReferral = _baseReferral * 10**(18 - _baseReferralDecimals);
    }

    /**
		@param _referrerPercent Percentage of baseReferral that is destinated to the referrer,
				18 decimal position needed for the unit
		@param _referredPercent Percentage of baseReferral that is destinated to the referred,
				18 decimal position needed for the unit
	 */
    function createReferral(uint256 _referrerPercent, uint256 _referredPercent)
        public
    {
        require(
            _referrerPercent + _referredPercent == 100 * 10**18,
            "All the referral percentage must be distributedAmount (100%)"
        );
        require(
            referrals[msg.sender].referrerPrize == 0 &&
                referrals[msg.sender].referredPrize == 0,
            "Referral already initialized, unable to edit it"
        );
        require(
            referrals[msg.sender].prize == 0,
            "Referral has already been used, unable to edit it"
        );

        uint256 referrerPrize = (baseReferral * _referrerPercent) / 10**20; // 18 decimals + transposition from integer to percentage
        uint256 referredPrize = (baseReferral * _referredPercent) / 10**20; // 18 decimals + transposition from integer to percentage

        referrals[msg.sender] = Referral({
            referrerPrize: referrerPrize,
            referredPrize: referredPrize,
            prize: 0
        });

        emit ReferralCreated(msg.sender);
    }

    function setReferralRate(
        uint256 _baseReferral,
        uint256 _baseReferralDecimals
    ) internal {
        baseReferralDecimals = 18;

        // high precision (18 decimals) the base referral is already in the normalized form
        // 1_[0 x 18 times] = 1%
        // 5_[0 x 17 times] = 0.5%
        baseReferral = _baseReferral * 10**(18 - _baseReferralDecimals);
    }

    /**
		@param _referrerAddr Referrer address
		@param _value Value of the currency whose bonus should be computed
		@return (
			Referred bonus based on the submitted _value,
			Total value of the bonus, may be used for minting calculations
		)
	 */
    function computeReferralPrize(address _referrerAddr, uint256 _value)
        internal
        returns (uint256, uint256)
    {
        if (
            // check if the referrer address is active and compute the referral if it is
            referrals[_referrerAddr].referrerPrize +
                referrals[_referrerAddr].referredPrize ==
            baseReferral &&
            // check that no other referral have veen used before, if any referral have been used
            // any new ref-code will not be considered
            !alreadyReferred.contains(msg.sender)
        ) {
            // insert the sender in the list of the referred user locking it from any other call
            alreadyReferred.insert(msg.sender);

            uint256 referrerBonus = (_value *
                referrals[_referrerAddr].referrerPrize) / 10**20; // 18 decimals + transposition from integer to percentage
            uint256 referredBonus = (_value *
                referrals[_referrerAddr].referredPrize) / 10**20; // 18 decimals + transposition from integer to percentage

            referrals[_referrerAddr].prize += referrerBonus;

            emit ReferralUsed(_referrerAddr, msg.sender);
            return (referredBonus, referrerBonus + referredBonus);
        }
        // fallback to no bonus if the ref code is not active or already used a ref code
        return (0, 0);
    }

    function redeemReferralPrize() public virtual;

    function getReferrals() public view returns (Referral memory) {
        return referrals[msg.sender];
    }
}

//--------------------------CROWD SALE------------------------

contract TSPAD is Ownable, Referrable, ReentrancyGuard {
    using SafeMath for uint256;

    // events
    event Buy(address indexed from, uint256 amount);
    event Locked(address indexed account, uint256 amount);
    event Released(address indexed account, uint256 amount);

    // constants
    uint256 private YEAR = 356 * 24 * 60 * 60;
    uint256 private MONTH = YEAR.div(12);
    uint256 private DAY = 24 * 60 * 60;

    uint256 private MONTH_PERCENT = 10000; // User can claim the 10.00% tokens per month
    uint256 private DENOMINATOR = 10000; // 100.00%
    uint8 private LOCKED_MONTHS = 1; // User can withdraw all his tokens after 10 months
    uint256 private RELEASE_PERCENT = 10000; // 10.00 % token will be released after buying.

    // structure
    struct PaymentTier {
        uint256 rate;
        uint256 lowerLimit;
        uint256 upperLimit;
    }

    struct Lock {
        uint256[] amounts; // the amount token released for each month
        uint256 depositTime; // the timestamp that token deposit
        bool finished; // user can widthdraw all tokens.
    }

    // variables
    IBEP20 public token;

    // the total number of token for sale
    uint256 public supply;

    // the sale info for each round
    PaymentTier[] public paymentTiers;

    // tracking the locked tokens of user
    mapping(address => Lock[]) private userLocks;

    // start time and end time of sale
    uint256 public saleStart;
    uint256 public saleEnd;

    // the total tokens distributed.
    uint256 public distributedAmount = 0;

    // the total BNB deposited.
    uint256 public totalBndAmount = 0;

    // the total token locked.
    uint256 public totalLockedAmount = 0;

    mapping(address => uint256) public latestDepositTime;

    constructor(address tokenAddress) Referrable(5, 1) {
        token = IBEP20(tokenAddress);

        // round 1
        paymentTiers.push(
            PaymentTier({
                rate: 800,
                lowerLimit: 0,
                upperLimit: 2_500_000_000000000000000000
            })
        );

        // round 2
        paymentTiers.push(
            PaymentTier({
                rate: 650,
                lowerLimit: 8_500_000000000000000000,
                upperLimit: 12_500_000000000000000000
            })
        );

        // round 3
        paymentTiers.push(
            PaymentTier({
                rate: 500,
                lowerLimit: 12_500_000000000000000000,
                upperLimit: 22_500_000000000000000000
            })
        );

        // round 4
        paymentTiers.push(
            PaymentTier({
                rate: 500,
                lowerLimit: 22_500_000000000000000000,
                upperLimit: 32_500_000000000000000000
            })
        );

        // round 5
        paymentTiers.push(
            PaymentTier({
                rate: 500,
                lowerLimit: 32_500_000000000000000000,
                upperLimit: 35_000_000000000000000000
            })
        );
    }

    receive() external payable {
        // revert("Direct funds receiving not enabled, call 'buy' directly");
    }

    function adminAddTokenAmount(uint256 amount) public onlyOwner {
        require(amount > 0, "adminAddTokenAmount: amount must greater than 0");
        uint256 oldBalance = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), amount);
        uint256 delta = token.balanceOf(address(this)).sub(oldBalance);
        supply = supply.add(delta);
    }

    function adminSetSaleTime(uint256 start, uint256 end) public onlyOwner {
        require(start > 0, "adminSetSaleTime: start time must greater than 0");
        require(
            start < end,
            "adminSetSaleTime: end time must greater than start time"
        );
        saleStart = start;
        saleEnd = end;
    }

    function adminSetReferralRate(uint256 referralRate, uint256 perci)
        public
        onlyOwner
    {
        require(
            referralRate >= 0,
            "adminSetReferralRate: referral Rate greate than or equal 0"
        );

        require(
            perci >= 0,
            "adminSetReferralRate: percision greate than or equal 0"
        );

        setReferralRate(referralRate, perci);
    }

    function adminSetExchangeRate(uint256 roundIdx, uint256 _rate)
        public
        onlyOwner
    {
        require(
            roundIdx >= 0 && roundIdx < paymentTiers.length,
            "adminSetExchangeRate: round index is invalid"
        );

        require(_rate > 0, "adminSetExchangeRate: rate must greater than 0");

        paymentTiers[roundIdx].rate = _rate;
    }

    function adminSetAmountLimits(
        uint256 roundIdx,
        uint256 _lowLimit,
        uint256 _highLimit
    ) public onlyOwner {
        require(
            roundIdx >= 0 && roundIdx < paymentTiers.length,
            "adminSetAmountLimits: round index is invalid"
        );

        require(
            _lowLimit > 0,
            "adminSetAmountLimits: lower limit must greater than 0"
        );

        require(
            _lowLimit < _highLimit,
            "adminSetAmountLimits: higher limit must greater than lower limit"
        );

        paymentTiers[roundIdx].lowerLimit = _lowLimit;
        paymentTiers[roundIdx].upperLimit = _highLimit;
    }

    function adminWithdrawBNB() public onlyOwner {
        require(
            block.timestamp > saleEnd,
            "adminWithdrawBNB: Sale haven't finished yet"
        );

        require(address(this).balance > 0, "adminWithdrawBNB: empty");

        payable(msg.sender).transfer(address(this).balance);
        totalBndAmount = 0;
    }

    function adminWithdrawToken() public onlyOwner {
        require(
            block.timestamp > saleEnd,
            "adminWithdrawToken: Sale haven't finished yet"
        );

        require(supply > 0, "adminWithdrawToken: empty");

        token.transfer(msg.sender, supply);
        supply = 0;
    }

    function buyToken(address referrerAddr) public payable nonReentrant {
        require(
            block.timestamp >= saleStart && block.timestamp <= saleEnd,
            "buyToken: Sale is not active this time"
        );

        require(supply > 0, "buyToken: sale ended, everything was sold");

        // compute the amount of token to buy based on the current rate
        (uint256 tokensToBuy, uint256 exceedingEther) = computeTokensAmount(
            msg.value
        );

        require(exceedingEther == 0, "buyToken: not enough token to sell");

        payable(address(this)).transfer(msg.value);

        totalBndAmount = totalBndAmount.add(msg.value);

        (uint256 referredPrize, uint256 totalPrize) = computeReferralPrize(
            referrerAddr,
            tokensToBuy
        );

        // update the number
        distributedAmount = distributedAmount.add(tokensToBuy).add(totalPrize);
        supply = supply.sub(tokensToBuy).sub(totalPrize);

        // add the number of prize for buyer.
        tokensToBuy = tokensToBuy.add(referredPrize);

        // if user bought before
        if (latestDepositTime[msg.sender] > 0) {
            migrateData(msg.sender);
        } else {
            latestDepositTime[msg.sender] = block.timestamp;
        }

        // Mint new tokens for each submission
        saleLock(msg.sender, tokensToBuy);

        emit Buy(msg.sender, tokensToBuy);
    }

    /**
     * withdraw (mint) the amount of token locked
     */
    function withdrawToken(uint8 month) external {
        require(
            month > 0 && month <= LOCKED_MONTHS,
            "withdrawToken: month between 1 and 10"
        );

        require(
            latestDepositTime[msg.sender] > 0,
            "withdrawToken: user not exist"
        );

        // calculate time from desposit to this time (month)
        uint256 timeCutOff = latestDepositTime[msg.sender].add(month * MONTH);

        require(
            block.timestamp > timeCutOff,
            "withdrawToken: not enough time to widthdaw token"
        );

        // accumulate the amout of token can widthdraw
        uint256 withdawnAmount = 0;

        for (
            uint256 lockIdx = 0;
            lockIdx < userLocks[msg.sender].length;
            lockIdx++
        ) {
            // has finished yet?
            bool finished = userLocks[msg.sender][lockIdx].finished;
            if (finished) {
                continue;
            }

            uint256 amount = userLocks[msg.sender][lockIdx].amounts[month];
            if (amount > 0) {
                withdawnAmount = withdawnAmount.add(amount);

                // update amount
                userLocks[msg.sender][lockIdx].amounts[month] = 0;

                if (month == LOCKED_MONTHS) {
                    // finished
                    userLocks[msg.sender][lockIdx].finished = true;
                }
            }
        }

        require(withdawnAmount > 0, "withdrawToken: You can't withdraw now");

        require(
            totalLockedAmount >= withdawnAmount,
            "withdrawToken: not enough token to widthdraw"
        );

        totalLockedAmount = totalLockedAmount.sub(withdawnAmount);

        // mint the tokens to the sender
        mintToken(msg.sender, withdawnAmount);
        emit Released(msg.sender, withdawnAmount);
    }

    function computeTokenWidthdraw(address sender, uint256 month)
        public
        view
        returns (uint256)
    {
        require(
            month > 0 && month <= LOCKED_MONTHS,
            "computeTokenWidthdraw: month between 1 and 10"
        );

        require(
            latestDepositTime[sender] > 0,
            "computeTokenWidthdraw: user not exist"
        );

        // accumulate the amout of token can widthdraw
        uint256 withdawnAmount = 0;

        for (
            uint256 lockIdx = 0;
            lockIdx < userLocks[sender].length;
            lockIdx++
        ) {
            // has finished yet?
            bool finished = userLocks[sender][lockIdx].finished;
            if (finished) {
                continue;
            }

            withdawnAmount = withdawnAmount.add(
                userLocks[sender][lockIdx].amounts[month]
            );
        }

        return withdawnAmount;
    }

    function computeTokensAmount(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 tokensMinted = distributedAmount;
        uint256 tokensToBuy;
        uint256 currentRoundTokens;
        uint256 etherAmount = amount;
        uint256 futureRound;
        uint256 rateRound;
        uint256 upperLimit;

        for (uint256 i = 0; i < paymentTiers.length; i++) {
            upperLimit = paymentTiers[i].upperLimit;
            if (
                etherAmount > 0 && // Check if there are still some funds in the request
                tokensMinted >= paymentTiers[i].lowerLimit && // Check if the current rate can be applied with the lowerLimit
                tokensMinted < upperLimit // Check if the current rate can be applied with the upperLimit
            ) {
                rateRound = paymentTiers[i].rate;

                currentRoundTokens = etherAmount.mul(1e18).div(1 ether).mul(
                    rateRound
                );

                futureRound = tokensMinted.add(currentRoundTokens);

                // If the tokens to mint exceed the upper limit of the tier reduce the number of token bounght in this round
                if (futureRound >= upperLimit) {
                    currentRoundTokens = currentRoundTokens.sub(
                        futureRound.sub(upperLimit)
                    );
                }

                // Update the tokensMinted counter with the currentRoundTokens
                tokensMinted = tokensMinted.add(currentRoundTokens);

                // Recomputhe the available funds (exceeding ether)
                etherAmount = etherAmount.sub(
                    currentRoundTokens.mul(1 ether).div(rateRound).div(1e18)
                );

                // And add the funds to the total calculation
                tokensToBuy = tokensToBuy.add(currentRoundTokens);
            }
        }

        uint256 new_minted = distributedAmount.add(tokensToBuy);
        uint256 exceedingEther;

        // Check if we have reached and exceeded the funding goal to refund the exceeding ether
        if (new_minted >= supply) {
            uint256 exceedingTokens = new_minted.sub(supply);

            // Convert the exceedingTokens to ether and refund that ether
            exceedingEther = etherAmount.add(
                exceedingTokens.mul(1 ether).div(rateRound).div(1e18)
            );

            // Change the tokens to buy to the new number
            tokensToBuy = tokensToBuy.sub(exceedingTokens);
        }

        return (tokensToBuy, exceedingEther);
    }

    function saleLock(address _account, uint256 _amount) private {
        uint256 releaseAmount = _amount.mul(RELEASE_PERCENT).div(DENOMINATOR);

        uint256 lockupAmount = _amount.sub(releaseAmount);

        // release 10% immediately.
        if (releaseAmount > 0) {
            mintToken(_account, releaseAmount);
            emit Released(_account, releaseAmount);
        }

        if (lockupAmount > 0) {
            // update the counter
            totalLockedAmount = totalLockedAmount.add(lockupAmount);

            uint256[] memory releaseMonth = new uint256[](LOCKED_MONTHS + 1);

            // calulate amount of release for each month
            for (uint8 month = 1; month <= LOCKED_MONTHS; month++) {
                releaseMonth[month] = lockupAmount.mul(MONTH_PERCENT).div(
                    DENOMINATOR
                );
            }

            Lock memory lock = Lock({
                amounts: releaseMonth,
                depositTime: block.timestamp,
                finished: false
            });

            userLocks[_account].push(lock);
            emit Locked(_account, lockupAmount);
        }
    }

    /**
     * Retrieve the locks state for the account
     */
    function userLockInfo(address account) public view returns (Lock[] memory) {
        return userLocks[account];
    }

    /**
     * Get the number of locks for an account
     */
    function getuserLockNumber(address account) public view returns (uint256) {
        return userLocks[account].length;
    }

    // the referrers only receive the prize after the end of sale
    function redeemReferralPrize() public override {
        require(
            referrals[msg.sender].prize != 0,
            "redeemReferralPrize: No referral prize to redeem"
        );

        require(
            block.timestamp > saleEnd,
            "redeemReferralPrize: Referral prize can be redeemed only after the end of the ICO"
        );

        uint256 prize = referrals[msg.sender].prize;
        referrals[msg.sender].prize = 0;

        mintToken(msg.sender, prize);
        emit ReferralPrizeRedeemed(msg.sender);
    }

    function mintToken(address _account, uint256 amount) private {
        token.transfer(_account, amount);
    }

    function migrateData(address sender) private {
        // get the current time
        uint256 currentTime = block.timestamp;

        for (
            uint256 lockIdx = 0;
            lockIdx < userLocks[sender].length;
            lockIdx++
        ) {
            // user withdrew all tokens for this buying, nothing to withdraw this time.
            bool finished = userLocks[sender][lockIdx].finished;
            if (finished) {
                continue;
            }

            // how many months passed from buying token.
            uint8 passMonths = uint8(
                currentTime.sub(userLocks[sender][lockIdx].depositTime).div(
                    MONTH
                )
            );

            // this buying hasn't reached 1 month yet.
            if (passMonths < 1) {
                continue;
            }

            // this buying happened more 10 months ago. User can withdraw all tokens.
            if (passMonths > LOCKED_MONTHS) {
                passMonths = LOCKED_MONTHS;
            }

            uint256 accumulate = 0;

            for (uint8 i = 1; i <= LOCKED_MONTHS; i++) {
                uint256 amount = userLocks[sender][lockIdx].amounts[i];

                // user hasn't withdraw token for this month yet.
                if (amount > 0) {
                    // enough time to withdraw all tokens
                    if (passMonths == LOCKED_MONTHS) {
                        accumulate = accumulate.add(amount);
                        userLocks[sender][lockIdx].amounts[i] = 0;

                        if (i == LOCKED_MONTHS) {
                            // user will widthdraw all token at the 1st month
                            userLocks[sender][lockIdx].amounts[1] = accumulate;
                        }
                    } else {
                        if (i < (passMonths + 1)) {
                            // withdraw all tokens in the months passed.
                            accumulate = accumulate.add(amount);
                            userLocks[sender][lockIdx].amounts[i] = 0;
                        } else if (i == (passMonths + 1)) {
                            // user will widthdraw token at the current month
                            accumulate = accumulate.add(amount);
                            userLocks[sender][lockIdx].amounts[i] = 0;

                            userLocks[sender][lockIdx].amounts[
                                i - passMonths
                            ] = accumulate;
                        } else {
                            // update for the next month
                            userLocks[sender][lockIdx].amounts[
                                i - passMonths
                            ] = amount;
                            userLocks[sender][lockIdx].amounts[i] = 0;
                        }
                    }
                }
            }
            // update deposit time
            userLocks[sender][lockIdx].depositTime = currentTime;
        }

        latestDepositTime[sender] = currentTime;
    }
}