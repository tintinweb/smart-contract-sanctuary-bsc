// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
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
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
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
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
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
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
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
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
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
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
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
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
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
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
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
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
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
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

contract Ownable is Context {
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
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/** 
██████╗ ███╗   ██╗██████╗ ███████╗ █████╗ ████████╗███████╗   4
██╔══██╗████╗  ██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝ 
██████╔╝██╔██╗ ██║██████╔╝█████╗  ███████║   ██║   ███████╗    
██╔══██╗██║╚██╗██║██╔══██╗██╔══╝  ██╔══██║   ██║   ╚════██║    
██████╔╝██║ ╚████║██████╔╝███████╗██║  ██║   ██║   ███████║   
╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    

BNBeast Farm | earn money until 4% daily | Metaversing 
SPDX-License-Identifier: MIT
*/
import "./bnbBeatsV4_resourses.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


pragma solidity ^0.8.14;


contract BNBStars is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    uint256 private BEATS_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private balanceLimit = 100;

    uint constant private REFERRER_PERCENTS_LENGTH = 3;
    uint[REFERRER_PERCENTS_LENGTH] private REFERRER_PERCENTS = [1000, 300, 200];

    // price whitelist = 0.19 BNB
    // rPercent = 25%
    uint constant private rWhitelistFee = 0.0475 ether;
    // aPercent = 25%
    uint constant private aWhitelistFee = 0.0475 ether;
    // nPercent = 40%
    uint constant private nWhitelistFee = 0.076 ether;
    // jPercent = 5%
    uint constant private jWhitelistFee = 0.0095 ether;
    // devPercent = 5%
    uint constant private devWhitelistFee = 0.0095 ether;

    uint constant private priceWhiteList = rWhitelistFee + nWhitelistFee + jWhitelistFee + devWhitelistFee + aWhitelistFee;// = 0.19 ether

    uint constant private secureToGwallet = 0.15 ether;
    uint constant private secureToRwallet = 0.05 ether;
    uint constant private secureToAwallet = 0.05 ether;
    uint constant private secureToJwallet = 0.025 ether;
    uint constant private secureToDev = 0.025 ether;
    uint constant public priceSecure = secureToGwallet + secureToRwallet + secureToAwallet + secureToJwallet + secureToDev;// = 0.3 ether
    EnumerableSet.AddressSet internal secureUsers;

    uint256 public marketBeats;
    uint256 private players;

    struct User {
        uint256 invest;
        uint256 withdraw;
        uint reinvest;
        uint256 hatcheryMiners;
        uint256 claimedBeats;
        uint256 lastHatch;
        uint256 checkpoint;
        bool originDone;
        address referrals;
        uint[REFERRER_PERCENTS_LENGTH] referrer;
        uint256 amountBNBReferrer;
        uint256 amountBEATSReferrer;
        uint totalRefDeposits;
        uint premiumBonus;
    }

    mapping(address => User) public users;
    mapping(address => bool) public whiteList;

    struct UserWithdrawData {
        address user;
        uint256 amount;
        uint256[REFERRER_PERCENTS_LENGTH] referrer;
    }

    mapping(address => UserWithdrawData) public userWithdrawData;
    mapping(uint => address) public userWithdrawDataIndex;
    uint public userWithdrawDataLength;

    uint256 public totalInvested;
    uint256 internal constant TIME_STEP = 1 days;

    address payable public constant aWallet = payable(
        0x657bAe8697F3cc4C0dc66c74149fA159490138C7
    );

    address payable aWalletWhite = payable(
        0xe3A5BFa3E07815fA1302f01024234Fd3EE05f0aF
    );

    address payable public constant rWallet = payable(
        0x4314e7578C8997d42Ec553a58beC395c88894b22
    );

    address payable public constant rWalletWhite = payable(
        0xF8886dc46D8d0e5706D9D0633A128FCF1Fa93442
    );

    address payable public constant nWallet = payable(
        0xf8db7110f814af8D5116CBae9C37c44015898A36
    );

    // GWallet = marketing wallet
    address payable public constant gWallet = payable(
        0xb9E648a4278E5d633320bd162F24037dD2ef8943
    );

    address payable public jWallet;
    address payable public devWallet;

    uint constant internal PERCENTS_DIVIDER = 10000;
    // 1.5% AWallet:
    uint constant internal AWALLET_FEE = 150;
    // 1.5% RWallet:
    uint constant internal RWALLET_FEE = 150;
    // 1.5% NWallet:
    uint constant internal NWALLET_FEE = 150;
    // 0.25% JWallet:
    uint constant internal JWALLET_FEE = 25;
    // 0.25% Dev:
    uint constant internal DEV_FEE = 25;
    // 1% GWallet:
    uint constant internal GWALLET_FEE = 100;

    uint constant internal BNB_TO_PREMIUM1 = 200 ether;
    uint constant internal BNB_TO_PREMIUM2 = 500 ether;
    uint constant internal BNB_TO_PREMIUM3 = 2000 ether;
    uint constant internal BNB_TO_PREMIUM4 = 4000 ether;
    uint constant internal BNB_TO_PREMIUM5 = 8000 ether;

    EnumerableSet.AddressSet internal premiumUsers1;
    EnumerableSet.AddressSet internal premiumUsers2;
    EnumerableSet.AddressSet internal premiumUsers3;
    EnumerableSet.AddressSet internal premiumUsers4;
    EnumerableSet.AddressSet internal premiumUsers5;

    uint constant internal premium1Bonus = 50;
    uint constant internal premium2Bonus = 100;
    uint constant internal premium3Bonus = 150;
    uint constant internal premium4Bonus = 200;
    uint constant internal premium5Bonus = 250;


    struct FeeStruct {
        address wallet;
        uint256 amount;
    }

    EnumerableSet.AddressSet internal whiteListAdmin;

    event WhiteListSet(address indexed user, bool indexed status);
    event TotalWithdraw(address indexed user, uint256 amount);
    

    // pausable
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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
    //
    constructor(address _dev, address _jWallet) {
        devWallet = payable(_dev);
        jWallet = payable(_jWallet);
        marketBeats = 108000000000;
        whiteListAdmin.add(aWallet);
        whiteListAdmin.add(rWallet);
        whiteListAdmin.add(nWallet);
        whiteListAdmin.add(gWallet);
        whiteListAdmin.add(jWallet);
        whiteListAdmin.add(devWallet);
        whiteListAdmin.add(aWalletWhite);
        whiteListAdmin.add(rWalletWhite);

        whiteListAdmin.add(0x688581F371BA1a43eBBF8e3f3dA30F3BD602C1bd);
        whiteListAdmin.add(0x1a5F8419331841b58Af63ff444209cbcAF86cD66);
        whiteListAdmin.add(0xd3c62125EF49a6FE7b0Fc87ED0ACb202F68972ff);
        whiteListAdmin.add(0x91329308e07a75d3fE18244Cf6FfBaF4627f5224);
        _pause();
    }

    function unpause() public checkOwner_ {
        _unpause();
    }

    modifier checkUser_() {
        require(checkUser(), "try again later 1");
        _;
    }

    modifier checkReinvest_() {
        require(checkReinvest(), "try again later 2 ");
        _;
    }

    modifier checkOwner_() {
        require(checkOwner(), "try again later 3");
        _;
    }

    function checkOwner() public view returns (bool) {
        return msg.sender == devWallet;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return whiteListAdmin.contains(account);
    }

    function getWhitelistAdminis() external view returns (address[] memory) {
        return whiteListAdmin.values();
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function checkUser() public view returns (bool) {
        uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
        if (check > TIME_STEP) {
            return true;
        }
        return false;
    }

    function checkReinvest() public view returns (bool) {
        uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
        if (check > TIME_STEP) {
            return true;
        }
        return false;
    }

    function getDateForSelling(address adr) public view returns (uint256) {
        return SafeMath.add(users[adr].checkpoint, TIME_STEP);
    }

    function reInvest() external checkReinvest_ nonReentrant whenNotPaused {
    calculateReinvest();
    //     User storage user = users[msg.sender];
    //     uint256 beatsUsed = getMyBeats(msg.sender);
    //     hatchBeats(beatsUsed, user);
    //     //send referral beats
    //     address upline = user.referrals;
    //     address old = msg.sender;
    //     for(uint i = 0; i < REFERRER_PERCENTS_LENGTH; i++) {
    //         if(upline != address(0) && upline != old && users[upline].referrals != old) {
    //             User storage referrals_ = users[upline];
    //             uint256 amount = referrerCommission(beatsUsed, i);
    //             referrals_.claimedBeats = SafeMath.add(
    //                 referrals_.claimedBeats,
    //                 amount
    //             );
    //             referrals_.amountBEATSReferrer = SafeMath.add(
    //                 referrals_.amountBEATSReferrer,
    //                 amount
    //             );
    //             old = upline;
    //             upline = users[upline].referrals;
    //         } else break;
    //     }
    }

    function hatchBeats(uint256 beatsUsed, User storage user) private {
        uint256 newMiners = SafeMath.div(beatsUsed, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedBeats = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;
        //boost market to nerf miners hoarding
        marketBeats = SafeMath.add(marketBeats, SafeMath.div(beatsUsed, 5));
    }

    function calculateMyBeats(address adr)
        public
        view
        returns (
            uint256 hasBeats,
            uint256 beatValue,
            uint256 beats
        )
    {
        uint256 beats_ = getMyBeats(adr);
        uint256 hasBeats_ = beats_;// beats for reinvest
        uint256 beatValue_; // beat value for withdraw
        (uint multiplier, uint divider) = getMyBonus(adr);
        beatValue_ = calculateBeatSell(SafeMath.div(SafeMath.mul(hasBeats_, multiplier), divider));
        hasBeats_ -= SafeMath.div(SafeMath.mul(hasBeats_, multiplier), divider);

        hasBeats = hasBeats_;
        beatValue = beatValue_;
        beats = calculateBeatSell(beats_); // beats total value
    }

    function sellStars() external checkUser_ nonReentrant whenNotPaused {
        (uint256 hasBeats, uint256 beatValue, ) = calculateMyBeats(msg.sender);
        (uint256 fee, FeeStruct[6] memory feeStruct) = withdrawFee(beatValue);
        require(
            SafeMath.sub(beatValue, fee) > SafeMath.div(1, 10),
            "Amount don't allowed"
        );
        User storage user = users[msg.sender];
        uint256 beatsUsed = hasBeats;
        uint256 newMiners = SafeMath.div(beatsUsed, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedBeats = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        marketBeats = SafeMath.add(marketBeats, hasBeats);
        user.withdraw += beatValue;
        uint userWithdraw = beatValue;
        if(userWithdrawData[msg.sender].user == address(0)) {
            userWithdrawDataIndex[userWithdrawDataLength] = msg.sender;
            userWithdrawDataLength += 1;
            userWithdrawData[msg.sender].user = msg.sender;
        }
        userWithdrawData[msg.sender].amount += userWithdraw;
        userWithdrawData[msg.sender].referrer = user.referrer;
        premiumUsersHandle(user, getInvestSumReinvest(msg.sender));
        payFees(feeStruct);
        // payable(msg.sender).transfer(SafeMath.sub(beatValue, fee));
        transferHandler(payable(msg.sender), SafeMath.sub(beatValue, fee));
        emit TotalWithdraw(msg.sender, user.withdraw);
    }

     function premiumUsersHandle(User storage user, uint userWithdraw) private {
              if(userWithdraw >= BNB_TO_PREMIUM5 && !premiumUsers5.contains(msg.sender)) {
            premiumUsers5.add(msg.sender);
            if(user.premiumBonus < premium5Bonus) {
                user.premiumBonus = premium5Bonus;
            }
        } else if(userWithdraw >= BNB_TO_PREMIUM4 && !premiumUsers4.contains(msg.sender)) {
            premiumUsers4.add(msg.sender);
            if(user.premiumBonus < premium4Bonus) {
                user.premiumBonus = premium4Bonus;
            }
        } else if(userWithdraw >= BNB_TO_PREMIUM3 && !premiumUsers3.contains(msg.sender)) {
            premiumUsers3.add(msg.sender);
            if(user.premiumBonus < premium3Bonus) {
                user.premiumBonus = premium3Bonus;
            }
        } else if(userWithdraw >= BNB_TO_PREMIUM2 && !premiumUsers2.contains(msg.sender)) {
            premiumUsers2.add(msg.sender);
            if(user.premiumBonus < premium2Bonus) {
                user.premiumBonus = premium2Bonus;
            }
        } else if(userWithdraw >= BNB_TO_PREMIUM1 && !premiumUsers1.contains(msg.sender)) {
            premiumUsers1.add(msg.sender);
            if(user.premiumBonus < premium1Bonus) {
                user.premiumBonus = premium1Bonus;
            }
        }
    }

    function calculateReinvest() private {
        (uint256 hasBeats, uint256 beatValue, ) = calculateMyBeats(msg.sender);
        (uint256 fee, FeeStruct[6] memory feeStruct) = withdrawFee(beatValue);
        require(
            SafeMath.sub(beatValue, fee) > SafeMath.div(1, 10),
            "Amount don't allowed"
        );
        User storage user = users[msg.sender];
        uint256 beatsUsed = hasBeats;
        uint256 newMiners = SafeMath.div(beatsUsed, BEATS_TO_HATCH_1MINERS);
        user.hatcheryMiners = SafeMath.add(user.hatcheryMiners, newMiners);
        user.claimedBeats = 0;
        user.lastHatch = block.timestamp;
        user.checkpoint = block.timestamp;

        marketBeats = SafeMath.add(marketBeats, hasBeats);
        user.reinvest += beatValue;
        uint userWithdraw = beatValue;
        premiumUsersHandle(user,userWithdraw);          
        payFees(feeStruct);
        // payable(msg.sender).transfer(SafeMath.sub(beatValue, fee));
        // transferHandler(payable(msg.sender), SafeMath.sub(beatValue, fee));
        buyHandler(users[msg.sender].referrals, SafeMath.sub(beatValue, fee));
    }

    function beatsRewards(address adr) external view returns (uint256) {
        uint256 hasBeats = getMyBeats(adr);
        uint256 beatValue = calculateBeatSell(hasBeats);
        return beatValue;
    }

    function referrerCommission(uint256 _amount, uint level)
        private
        view
        returns (uint256)
    {
        //return SafeMath.div(SafeMath.mul(_amount, referrerCommissionVal), 100);
        return SafeMath.div(SafeMath.mul(_amount, REFERRER_PERCENTS[level]), PERCENTS_DIVIDER);
    }

    function buyStars(address ref) external payable nonReentrant whenNotPaused {
        buyHandler(ref, msg.value);
    }

    function buyHandler(address ref, uint investAmout) private {
        User storage user = users[msg.sender];
        if(user.referrals == address(0) && msg.sender != nWallet) {
            if (ref == msg.sender || users[ref].referrals == msg.sender || msg.sender == users[ref].referrals) {
                user.referrals = nWallet;
            } else {
                user.referrals = ref;
            }
            if(user.referrals != msg.sender && user.referrals != address(0)) {
                address upline = user.referrals;
                address old = msg.sender;
                for(uint i = 0; i < REFERRER_PERCENTS_LENGTH; i++) {
                    if(upline != address(0) && upline != old && users[upline].referrals != old) {
                        users[upline].referrer[i] += 1;
                        old = upline;
                        upline = users[upline].referrals;
                    } else break;
                }
            }
        }

        uint256 beatsBought = calculateBeatBuy(
            investAmout,
            SafeMath.sub(address(this).balance, investAmout)
        );
        (uint beatsFee,) = devFee(beatsBought);
        beatsBought = SafeMath.sub(beatsBought, beatsFee);

        (, FeeStruct[6] memory feeStruct) = devFee(investAmout);
         payFees(feeStruct);
        if (user.invest == 0) {
            user.checkpoint = block.timestamp;
            players = SafeMath.add(players, 1);
        }
        user.invest += investAmout;
        user.claimedBeats = SafeMath.add(user.claimedBeats, beatsBought);
        hatchBeats(getMyBeats(msg.sender), user);
        payCommision(user, investAmout);
        totalInvested += investAmout;
    }

    function payCommision(User storage user, uint investAmout) private {
        if (user.referrals != msg.sender && user.referrals != address(0)) {
            address upline = user.referrals;
            address old = msg.sender;
            if(upline == address(0)) {
                upline = nWallet;
            }
            for(uint i = 0; i < REFERRER_PERCENTS_LENGTH; i++) {
                if((upline != address(0) && upline != old && users[upline].referrals != old) || upline == nWallet) {
                    uint256 amountReferrer = referrerCommission(investAmout, i);
                    users[upline].amountBNBReferrer = SafeMath.add(
                        users[upline].amountBNBReferrer,
                        amountReferrer
                    );

                    users[upline].totalRefDeposits = SafeMath.add(
                        users[upline].totalRefDeposits,
                        investAmout
                    );
                    // payable(upline).transfer(amountReferrer);
                    transferHandler(payable(upline), amountReferrer);
                    upline = users[upline].referrals;
                    old = user.referrals;
                    if(upline == address(0)) {
                        upline = nWallet;
                    }
                } else break;
            }
        }
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        uint256 a = PSN.mul(bs);
        uint256 b = PSNH;

        uint256 c = PSN.mul(rs);
        uint256 d = PSNH.mul(rt);

        uint256 h = c.add(d).div(rt);
        return a.div(b.add(h));
    }

    function calculateBeatSell(uint256 beats) private view returns (uint256) {
        uint256 _cal = calculateTrade(
            beats,
            marketBeats,
            address(this).balance
        );
        return _cal;
    }

    function calculateBeatBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketBeats);
    }

    function calculateBeatBuySimple(uint256 eth) external view returns (uint256) {
        return calculateBeatBuy(eth, address(this).balance);
    }

    function devFee(uint256 _amount) private view returns (uint256 _totalFee, FeeStruct[6] memory _feeStruct) {
        // return SafeMath.div(SafeMath.mul(_amount, devFeeVal), 100);
        uint aFee = SafeMath.div(SafeMath.mul(_amount, AWALLET_FEE), PERCENTS_DIVIDER);
        uint rFee = SafeMath.div(SafeMath.mul(_amount, RWALLET_FEE), PERCENTS_DIVIDER);
        uint nFee = SafeMath.div(SafeMath.mul(_amount, NWALLET_FEE), PERCENTS_DIVIDER);
        uint jFee = SafeMath.div(SafeMath.mul(_amount, JWALLET_FEE), PERCENTS_DIVIDER);
        uint dFee = SafeMath.div(SafeMath.mul(_amount, DEV_FEE), PERCENTS_DIVIDER);
        uint gFee = SafeMath.div(SafeMath.mul(_amount, GWALLET_FEE), PERCENTS_DIVIDER);

        _feeStruct[0] = FeeStruct(aWallet, aFee);
        _feeStruct[1] = FeeStruct(rWallet, rFee);
        _feeStruct[2] = FeeStruct(nWallet, nFee);
        _feeStruct[3] = FeeStruct(jWallet, jFee);
        _feeStruct[4] = FeeStruct(devWallet, dFee);
        _feeStruct[5] = FeeStruct(gWallet, gFee);

        _totalFee = SafeMath.add(aFee, rFee);
        _totalFee = SafeMath.add(_totalFee, nFee);
        _totalFee = SafeMath.add(_totalFee, jFee);
        _totalFee = SafeMath.add(_totalFee, dFee);
        _totalFee = SafeMath.add(_totalFee, gFee);

        return (_totalFee, _feeStruct);

    }

    function withdrawFee(uint256 _amount) private view returns (uint256 _totalFee, FeeStruct[6] memory _feeStruct) {
        return devFee(_amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) external view returns (uint256) {
        User memory user = users[adr];
        return user.hatcheryMiners;
    }

    function getPlayers() external view returns (uint256) {
        return players;
    }

    function getMyBeats(address adr) public view returns (uint256) {
        User memory user = users[adr];
        return SafeMath.add(user.claimedBeats, getBeatsSinceLastHatch(adr));
    }

    function getBeatsSinceLastHatch(address adr) public view returns (uint256) {
        User memory user = users[adr];
        uint256 secondsPassed = min(
            BEATS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, user.lastHatch)
        );
        return SafeMath.mul(secondsPassed, user.hatcheryMiners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getSellStars(address user_)
        external
        view
        returns (uint256 beatValue)
    {
        uint256 hasBeats = getMyBeats(user_);
        beatValue = calculateBeatSell(hasBeats);
    }

    function getPublicData()
        external
        view
        returns (uint256 _totalInvest, uint256 _balance)
    {
        _totalInvest = totalInvested;
        _balance = address(this).balance;
    }

    function userData(address user_)
        external
        view
        returns (
            uint256 lastHatch_,
            uint256 rewards_,
            uint256 amountAvailableReinvest_,
            uint256 availableWithdraw_,
            uint256 beatsMiners_,
            address referrals_,
            uint256[REFERRER_PERCENTS_LENGTH] memory referrer,
            uint256 checkpoint,
            uint256 referrerBNB,
            uint256 referrerBEATS,
            uint totalRefDeposits
        )
    {
        User memory user = users[user_];
        (, uint256 beatValue, uint256 beats) = calculateMyBeats(user_);
        lastHatch_ = user.lastHatch;
        referrals_ = user.referrals;
        rewards_ = beats;
        amountAvailableReinvest_ = beatValue; // SafeMath.sub(beats, beatValue);
        availableWithdraw_ = beatValue;
        beatsMiners_ = getBeatsSinceLastHatch(user_);
        referrer = user.referrer;
        checkpoint = user.checkpoint;
        referrerBNB = user.amountBNBReferrer;
        referrerBEATS = user.amountBEATSReferrer;
        totalRefDeposits = user.totalRefDeposits;
    }

    function payFees(FeeStruct[6] memory _fees) internal {
        for (uint i = 0; i < _fees.length; i++) {
            if (_fees[i].amount > 0) {
                // payable(_fees[i].wallet).transfer(_fees[i].amount);
                transferHandler(payable(_fees[i].wallet), _fees[i].amount);
            }
        }
    }

    function buyWhiteList() external payable nonReentrant {
        require(msg.value == priceWhiteList, "The price is 0.19 BNB");
        require(!whiteList[_msgSender()], "You already have a whitelist");
        rWalletWhite.transfer(rWhitelistFee);
        nWallet.transfer(nWhitelistFee);
        jWallet.transfer(jWhitelistFee);
        devWallet.transfer(devWhitelistFee);
        aWalletWhite.transfer(aWhitelistFee);
        addWhiteList(_msgSender());
    }

    function addToWhiteList(address adr) external onlyWhitelistAdmin {
        addWhiteList(adr);
    }

    function setWhitelist(address[] memory _whitelist, bool _value)
        external
        onlyWhitelistAdmin
    {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whiteList[_whitelist[i]] = _value;
            emit WhiteListSet(_whitelist[i], _value);
        }
    }

    function addWhiteList(address adr) private {
        whiteList[adr] = true;
        emit WhiteListSet(adr, true);
    }

    function removeToWhiteList(address adr) external onlyWhitelistAdmin {
        whiteList[adr] = false;
        emit WhiteListSet(adr, false);
    }

    function getDate() external view returns (uint256) {
        return block.timestamp;
    }

    function buySecure() external payable nonReentrant {
        require(msg.value == priceSecure, "The price is 0.3 BNB");
        require(!secureUsers.contains(msg.sender), "You already have a secure");
        secureUsers.add(msg.sender);
        gWallet.transfer(secureToGwallet);
        rWallet.transfer(secureToRwallet);
        aWallet.transfer(secureToAwallet);
        jWallet.transfer(secureToJwallet);
        devWallet.transfer(secureToDev);
    }

    function secureUsersLegth() external view returns(uint) {
        return secureUsers.length();
    }

    function secureUsersArray() external view returns (address[] memory) {
        return secureUsers.values();
    }

    function hasBuySecure(address adr) external view returns (bool) {
        return secureUsers.contains(adr);
    }

    function secureUsersInterval(uint256 from, uint256 to) external view returns (address[] memory) {
        uint length = to - from;
        address[] memory result = new address[](length);
        for (uint i = 0; i < length; i++) {
            result[i] = secureUsers.at(from + i);
        }
        return result;
    }

    function getMyBonus(address adr) public view returns (uint multiplier, uint divider) {
        divider = 1000;
        multiplier = 250;
        if (whiteList[adr]) {
            multiplier += 250;
        } else if (address(this).balance < balanceLimit) {
            multiplier /= 2;
        }

        uint256 beats_ = getMyBeats(adr);
        uint beatValue_ = calculateBeatSell(SafeMath.div(SafeMath.mul(beats_, multiplier), divider));
        uint userWithdraw = getInvestSumReinvest(adr);
        beatValue_ += userWithdraw;

        uint bonusPercent = 0;
        if(beatValue_ >= BNB_TO_PREMIUM5) {
            bonusPercent = premium5Bonus;
        } else if(beatValue_ >= BNB_TO_PREMIUM4) {
            bonusPercent = premium4Bonus;
        } else if(beatValue_ >= BNB_TO_PREMIUM3) {
            bonusPercent = premium3Bonus;
        } else if(beatValue_ >= BNB_TO_PREMIUM2) {
            bonusPercent = premium2Bonus;
        } else if(beatValue_ >= BNB_TO_PREMIUM1) {
            bonusPercent = premium1Bonus;
        }

        if(users[adr].premiumBonus > bonusPercent) {
            bonusPercent = users[adr].premiumBonus;
        }

        multiplier = SafeMath.add(multiplier, bonusPercent);

        if(multiplier > divider) {
            multiplier = divider;
        }
    }

    function premiumUsers(uint level) external view returns (address[] memory) {
        if(level == 1) {
            return premiumUsers1.values();
        } else if(level == 2) {
            return premiumUsers2.values();
        } else if(level == 3) {
            return premiumUsers3.values();
        } else if(level == 4) {
            return premiumUsers4.values();
        } else if(level == 5) {
            return premiumUsers5.values();
        } else {
            return new address[](0);
        }
    }

    function getPremiumUsersLength(uint level) external view returns(uint) {
        if(level == 1) {
            return premiumUsers1.length();
        } else if(level == 2) {
            return premiumUsers2.length();
        } else if(level == 3) {
            return premiumUsers3.length();
        } else if(level == 4) {
            return premiumUsers4.length();
        } else if(level == 5) {
            return premiumUsers5.length();
        } else {
            return 0;
        }
    }

    function getPremiumUsersAt(uint level, uint index) external view returns(address) {
        if(level == 1) {
            return premiumUsers1.at(index);
        } else if(level == 2) {
            return premiumUsers2.at(index);
        } else if(level == 3) {
            return premiumUsers3.at(index);
        } else if(level == 4) {
            return premiumUsers4.at(index);
        } else if(level == 5) {
            return premiumUsers5.at(index);
        }
        else {
            return address(0);
        }
    }

    function setWhitelistAdmin(address[] memory adr, bool _add) external checkOwner_ {
        if(_add) {
            for (uint i = 0; i < adr.length; i++) {
                whiteListAdmin.add(adr[i]);
            }
        } else {
            for (uint i = 0; i < adr.length; i++) {
                whiteListAdmin.remove(adr[i]);
            }
        }
    }

    function transferHandler(address payable adr, uint256 amount) private {
        if(amount > getBalance()) {
            amount = getBalance();
        }
        adr.transfer(amount);
    }

    function getUserWithdrawData() external view returns (UserWithdrawData[] memory) {
        UserWithdrawData[] memory result = new UserWithdrawData[](userWithdrawDataLength);
        for (uint i = 0; i < userWithdrawDataLength; i++) {
            result[i] = userWithdrawData[userWithdrawDataIndex[i]];
        }
        return result;
    }

    function UserWithdrawDataRange(uint limit, uint offset) external view returns (UserWithdrawData[] memory) {
        UserWithdrawData[] memory result = new UserWithdrawData[](limit);
        for (uint i = 0; i < limit; i++) {
            result[i] = userWithdrawData[userWithdrawDataIndex[i + offset]];
        }
        return result;
    }

    function getInvestSumReinvest(address adr) public view returns (uint256) {
        return users[adr].withdraw + users[adr].reinvest;
    }

}