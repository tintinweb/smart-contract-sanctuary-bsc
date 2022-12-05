/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: Cyrcl/Lobby.sol

// CYRCL - Lobby contract

pragma solidity ^0.8.4;





interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;

    function transfer(address to, uint256 value) external returns (bool);
}

interface IDividendPool {
    function updatePool(address currency, uint256 amount) external;
}

contract Lobby is ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public FEE_MAX_PERCENT = 3000;

    address public immutable wethAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    /**
     * Round Struct
     */
    struct Round {
        uint256 id; // request id.
        RoundStatus status; // status of the round.
        address[20] players; // address of player
        mapping(address => uint256) bets; 
        mapping(address => uint256) betShares;
        uint256 lastJoined;    // timestamp that last player joined
        uint256 remainSeconds; // currently remain seconds to wait new player
        uint256 totalBets; // total bets of this round => One player can bet multiple
        uint256 totalPlayers; // how many players of this round;
        uint256 totalAmount; // total amount of this round
        uint256 startTime;
        uint256 finishTime;
        uint256 winnerSelectedTime;
        uint256 luckyNumber;
        address winner;
        uint256 winningAmount;
    }

    enum RoundStatus { Initial, Running, Finished } // status of this round
    mapping(uint256 => Round) public gameRounds;
 
    uint256 public currentRoundId; //until now, the total round of this lobby.
    uint256 public totalBetCount;
    uint256 public totalBetAmount;

    /**
        Lobby Information
     */
    string public lobbyName;           // Lobby Name
    address public lobbyCurrency;       // Currency Token Address
    uint256 public lobbyPeriod;        // Period in seconds
    uint256 public lobbyFirstPeriod;   // Wait time for first player
    uint256 public lobbyIncSeconds;    // Increaing time when join new player
    uint256 public maxPlayers;         // Max Players per one Round
    uint256 public minBetAmount;
    bool public maintaining = true;
    bool public banned = false;
    bool public isOfficial = false;

    address public factory;
    address public owner;
    address public administrator;
    

    /**
        Address for Fee 
     */
    address public poolAddress;
	address public devAddress;
	address public burnAddress;
	address public courtAddress;

	uint256 public poolPercent;
	uint256 public devPercent;
	uint256 public ownerPercent;
	uint256 public burnPercent;

    uint256 private _salt;

    event NewGameStarted(uint256 roundId, address player, uint256 amount);
    event JoinGame(uint256 roundId, address player, uint256 amount, bool isNewJoin, uint256 totalPlayers, uint256 totalAmount);
    event CancelledGame(uint256 roundId, address player);
    event FinishedGame(uint256 roundId, address winner, uint256 luckyNumber, uint256 winnerAmount);

    event LobbyLocked(bool locked);

    /**
     * Constructor
     * 
     */
    constructor() {
        factory = msg.sender;
    }

    function initialize(string memory _name, 
                address _currency,
                address _owner,
                address[5] memory _addresses,
                uint256[4] memory _percentages,
                bool _official
                ) public onlyFactory {
        
        lobbyName = _name;
        lobbyCurrency = _currency;
        
        owner = _owner;
        poolAddress = _addresses[0];
        devAddress = _addresses[1];
        burnAddress = _addresses[2];
        courtAddress = _addresses[3];
        administrator = _addresses[4];

        poolPercent = _percentages[0];
        devPercent = _percentages[1];
        ownerPercent = _percentages[2];
        burnPercent = _percentages[3];

        lobbyPeriod = 14;
        lobbyFirstPeriod = 60;
        lobbyIncSeconds = 60;
        maxPlayers = 10;
        minBetAmount = 0.00001 * 10 ** 18;
        
        isOfficial = _official;
        banned = false;
        maintaining = false;

         _salt = uint256(keccak256(abi.encodePacked(lobbyName, owner, block.timestamp))).mod(10000);
    }

    /**
        Start New Game or join to Game if game is running now
     */
    function placeBet(uint256 amount) public onlyHuman unbanned payable {
        Round storage currentRound = gameRounds[currentRoundId];

        if(isBNBLobby()) {
            require(amount == msg.value, "Invalid Amount");
        } else {
            require(IERC20(lobbyCurrency).transferFrom(msg.sender, address(this), amount), "Deposit failed");
        }

        if(currentRound.status != RoundStatus.Running) {
            require(startNewGame(msg.sender, amount), "Failed to start new game");
        } else {
            require(joinToGame(msg.sender, amount), "Failed to join to game");
        }
    }

    /**
        Cancle Game: Only Owner or creator of round can cancel Round
     */
    function cancelGame() public onlyHuman unbanned nonReentrant {
        Round storage currentRound = gameRounds[currentRoundId];
        require(currentRound.status == RoundStatus.Running, "Game is not running now");
        address roundCreator = currentRound.players[0];
        require(msg.sender == owner || msg.sender == roundCreator, "Only owner or round creator can cancel round");
        require(currentRound.totalPlayers == 1, "Can not cancel if more than 1 player");
        
        require(_safeTransfer(roundCreator, currentRound.totalAmount), "Failed to refund Bet Amount");

        currentRound.status = RoundStatus.Finished;
        currentRound.remainSeconds = 0;
        currentRound.winner = roundCreator;
        currentRound.winnerSelectedTime = block.timestamp;
        currentRound.finishTime = block.timestamp;
        currentRound.winningAmount = currentRound.totalAmount;
        
        totalBetAmount = totalBetAmount.sub(currentRound.totalAmount);

        emit CancelledGame(currentRoundId, roundCreator);
    }   

    /**
        Create New Round: First Player becomes Creator of Round
     */
    function startNewGame(address player, uint256 amount) internal returns(bool) {
        currentRoundId = currentRoundId.add(1);
        Round storage currentRound = gameRounds[currentRoundId];
        require(currentRound.status != RoundStatus.Running, "Current Round is running already");
        require(amount >= minBetAmount, "Amount is less than minimum limitation");

        currentRound.id = currentRoundId;
        currentRound.status = RoundStatus.Running;
        currentRound.totalPlayers = 1;
        currentRound.players[0] = player;
        currentRound.lastJoined = block.timestamp;
        currentRound.remainSeconds = lobbyFirstPeriod;
        currentRound.totalBets = 1;
        currentRound.totalAmount = amount;
        currentRound.startTime = block.timestamp;
        currentRound.bets[player] = amount; 
        currentRound.betShares[player] = PERCENTS_DIVIDER; 

        totalBetCount = totalBetCount.add(1);
        totalBetAmount  = totalBetAmount.add(amount);

        emit NewGameStarted(currentRoundId, player, amount);
        return true;
    }

    /**
        Join to Game => If Round already created and running now.
     */
    function joinToGame(address player, uint256 amount) internal returns(bool) {
        Round storage currentRound = gameRounds[currentRoundId];
        require(currentRound.status == RoundStatus.Running, "Current Round is not started");
        require(currentRound.lastJoined.add(currentRound.remainSeconds) >= block.timestamp , "Round period is over");

        bool isNewJoin = currentRound.bets[player] == 0;
        if(isNewJoin) {
            require(currentRound.totalPlayers.add(1) <= maxPlayers, "Exceeded max player limit");
        }

        uint256 sumAmount = currentRound.bets[player].add(amount);
        if(isNewJoin) {
            currentRound.totalPlayers = currentRound.totalPlayers.add(1);
            currentRound.players[currentRound.totalPlayers.sub(1)] = player;
        }
        
        currentRound.totalBets = currentRound.totalBets.add(1);
        currentRound.totalAmount = currentRound.totalAmount.add(amount);
        currentRound.bets[player] = sumAmount; 
        currentRound.lastJoined = block.timestamp;
        currentRound.remainSeconds = lobbyIncSeconds;

        updateRoundShares();
        
        _decideCurrentWinner();

        totalBetCount = totalBetCount.add(1);
        totalBetAmount  = totalBetAmount.add(amount);

        emit JoinGame(currentRoundId, player, amount, isNewJoin, currentRound.totalPlayers, currentRound.totalAmount);
        
        return true;
    }


    /**
        Calculate Bet Share percent for all players of Round
     */
    function updateRoundShares() internal returns(bool) {
        Round storage currentRound = gameRounds[currentRoundId];
        for(uint256 i = 0 ; i < currentRound.totalPlayers; i++) {
            address player = currentRound.players[i];
            currentRound.betShares[player] = currentRound.bets[player].mul(PERCENTS_DIVIDER).div(currentRound.totalAmount);
        }
        return true;
    }


    /**
        Finish Round and decide Winner Address
     */
    function finishGame() public onlyCourt nonReentrant {
        Round storage currentRound = gameRounds[currentRoundId];
        require(currentRound.status == RoundStatus.Running, "Game is not running now");
        require(currentRound.winner == address(0x0), "Winner is already decided");
        require(currentRound.totalPlayers >= 2, "Players is less than 2");

        _finishGameEx();
    }

    /**
        Force Finish current Round
     */
    function forceFinishGame() public onlyOwner nonReentrant {
        Round storage currentRound = gameRounds[currentRoundId];
        require(currentRound.status == RoundStatus.Running, "Game is not running now");
        require(currentRound.winner == address(0x0), "Winner is already decided");
        
        if(currentRound.totalPlayers == 1) {
            cancelGame();
        } else {
            _finishGameEx();
        }
    }

    /**
        Finish Game Ex
     */
    function _finishGameEx() internal {
        Round storage currentRound = gameRounds[currentRoundId];
         address winner = currentRound.winner;
        // process winner
        require(winner != address(0x0), "Cannot decide winner");

        uint256 poolAmount = currentRound.totalAmount.mul(poolPercent).div(PERCENTS_DIVIDER);
        uint256 devAmount = currentRound.totalAmount.mul(devPercent).div(PERCENTS_DIVIDER);
        uint256 ownerAmount = currentRound.totalAmount.mul(ownerPercent).div(PERCENTS_DIVIDER);
        uint256 burnAmount = currentRound.totalAmount.mul(burnPercent).div(PERCENTS_DIVIDER);
        uint256 totalFeeAmount = poolAmount.add(devAmount).add(ownerAmount).add(burnAmount);
        uint256 winnerAmount = currentRound.totalAmount.sub(totalFeeAmount);
        
        require(_safeTransfer(winner, winnerAmount), "Failed to transfer to winner");
        require(_safeTransfer(poolAddress, poolAmount), "Failed to transfer to pool");
        require(_safeTransfer(devAddress, devAmount), "Failed to transfer to dev");
        require(_safeTransfer(burnAddress, burnAmount), "Failed to transfer to burn");
        require(_safeTransfer(owner, ownerAmount), "Failed to transfer to owner");
    
        IDividendPool(poolAddress).updatePool(lobbyCurrency, poolAmount);

        currentRound.status = RoundStatus.Finished;
        currentRound.finishTime = block.timestamp;
        currentRound.winningAmount = winnerAmount;

        emit FinishedGame(currentRoundId, winner, currentRound.luckyNumber, winnerAmount);
    }

    function _safeTransfer(address to, uint256 value) internal returns(bool) {
        if(isBNBLobby()) {
            (bool success, ) = to.call{value: value}(new bytes(0));
            if(!success) {
                IWETH(wethAddress).deposit{value: value}();
                return IERC20(wethAddress).transfer(to, value);
            }
            return success;
        } else {
            return IERC20(lobbyCurrency).transfer(to, value);
        }
    }

    function _decideCurrentWinner() internal returns(bool) {
        Round storage currentRound = gameRounds[currentRoundId];
        uint256 totalAmount = currentRound.totalAmount;
        uint256 seed = uint256(keccak256(abi.encode(block.number, currentRound.totalPlayers)));
        uint256 randomResult = _getRandomNumebr(seed, _salt, totalAmount);
        // update random salt.
        _salt = ((randomResult + _salt) * block.timestamp).mod(totalAmount) + 1;
        uint256 result = (randomResult * _salt).mod(totalAmount);

        // decide winner from random number 
        uint256 temp = 0;
        address winner = address(0x0);
        for(uint256 i = 0; i < currentRound.totalPlayers; i++) {
            address player = currentRound.players[i];
            temp = temp.add(currentRound.bets[player]);
            if(result <= temp) {
                winner = player;
                break;
            }   
        }

        currentRound.winner = winner;
        currentRound.winnerSelectedTime = block.timestamp;
        currentRound.luckyNumber = result;

        return true;
    }

    function isBNBLobby() public view returns(bool) {
        return lobbyCurrency == address(0x0);
    }

    /**
        Generate Random Number
     */
    function _getRandomNumebr(uint256 seed, uint256 salt, uint256 mod) view private returns(uint256) {
        return uint256(keccak256(abi.encode(block.timestamp, block.difficulty, block.coinbase, blockhash(block.number + 1), seed, salt, block.number))).mod(mod);
    }

    function getRoundBets(uint256 roundId, address player) public view returns(uint256, uint256) {
        return (gameRounds[roundId].bets[player], gameRounds[roundId].betShares[player]);
    }

    function getRound(uint256 roundId) public view returns(
        address[20] memory, uint256[20] memory, uint256[20] memory
    ){
        Round storage round = gameRounds[roundId];
        uint256[20] memory bets;
        uint256[20] memory betShares;

        for(uint i = 0; i < 20; i++) {
            if(round.players[i] != address(0x0)) {
                address player = round.players[i];
                bets[i] = round.bets[player];
                betShares[i] = round.betShares[player];
            }
        }
        return (
            round.players,
            bets,
            betShares
        );
    }

    function unlockLobby() public onlyOwner {  
        require(maintaining == true, 'lobby is unlocked now'); 
        maintaining = false;
        emit LobbyLocked(maintaining);
    }

    function lockLobby() public onlyOwner {
        require(maintaining == false, 'lobby is locked now');
        maintaining = true;
        emit LobbyLocked(maintaining);
    }

    function transferOwner(address account) public onlyOwner {
        require(account != address(0), "Ownable: new owner is zero address");
        owner = account;
    }

    function removeOwnership() public onlyOwner {
        owner = address(0x0);
    }

    function banThisLobby() public onlyOwner {
        require(banned == false, 'lobby is banned now'); 
        banned = true;
    }

    function unbanThisLobby() public onlyOwner {
        require(banned == false, 'lobby is unbanned now'); 
        banned = false;
    }

    function changeLobbyName(string memory name) public onlyOwner {
        lobbyName = name;
    }

    function changeLobbyCurrency(address currency) public onlyOwner {
        lobbyCurrency = currency;
    }

    function changeLobbySetting(uint256 _lobbyPeriod, uint256 _maxPlayers, uint256 _minBet) public onlyOwner {
        lobbyPeriod = _lobbyPeriod;
        maxPlayers = _maxPlayers;
        minBetAmount = _minBet;
    }

    // *****************************
    // For Admin Account ***********
    // *****************************
    function changeFeePercent(uint256 _poolPercent, uint256 _devPercent, uint256 _ownerPercent, uint256 _burnPercent) public onlyAdministrator {
        require(_poolPercent <= FEE_MAX_PERCENT, "too big pool percent");
        require(_devPercent <= FEE_MAX_PERCENT, "too big dev percent");
        require(_ownerPercent <= FEE_MAX_PERCENT, "too big owner percent");
        require(_burnPercent <= FEE_MAX_PERCENT, "too big burn percent");
        poolPercent = _poolPercent;
        devPercent = _devPercent;
        ownerPercent = _ownerPercent;
        burnPercent = _burnPercent;
    }

    function changeFeeAddress(address _dev, address _burn) external onlyAdministrator {
        require(_dev != address(0x0), "Dev address cannot Zero address");
        devAddress = _dev;
        burnAddress = _burn;
    }

	function changePoolAddress(address _pool) external onlyAdministrator {
        require(_pool != address(0x0), "Pool address cannot Zero address");
        poolAddress = _pool;
    }
	
	function changeCourtAddress(address _court) external onlyAdministrator {
        require(_court != address(0x0), "Court address cannot Zero address");
       
        courtAddress = _court;
    }

	function changeAdminAddress(address _admin) external onlyAdministrator {
        require(_admin != address(0x0), "Court address cannot Zero address");
       
        administrator = _admin;
    }


    receive() external payable {}

    function isContract(address _addr) view private returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    // Modifiers
    modifier onlyHuman() {
        require(!isContract(address(msg.sender)) && tx.origin == msg.sender, "Only for human.");
        _;
    }

    modifier onlyFactory() {
        require(address(msg.sender) == factory, "Only for factory.");
        _;
    }

    modifier onlyOwner() {
        require(address(msg.sender) == owner || address(msg.sender) == administrator,  "Only for owner.");
        _;
    }

    modifier onlyCourt() {
        require(address(msg.sender) == courtAddress,  "Only for court.");
        _;
    }

    modifier onlyAdministrator() {
        require(address(msg.sender) == administrator,  "Only for administrator.");
        _;
    }

    modifier unbanned() {
        require(!banned, "This lobby is banned.");
        _;
    }
}