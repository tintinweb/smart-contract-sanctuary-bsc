/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: Yuri
// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/utils/math/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/utils/structs/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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

        assembly {
            result := store
        }

        return result;
    }
}


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File contracts/Pegasus_presale/Presale1.sol

pragma solidity ^0.8.0;
// import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract PegasusPresale is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public minimumDepositETHAmount = 0.1 ether; // Minimum deposit is 1 ETH
    uint256 public maximumDepositETHAmount = 3 ether; // Maximum deposit is 10 ETH


    uint256 public mininumbDepoistUSDTAmount = 40 ether;
    uint256 public maximumDepositUSDTAmount = 1200 ether;

    uint256 public tokensPerETH = 1000; // token amount is 1000,
    uint public presaleTokenAmount = 500_000 ether; // pre sale token amount is 500K

    uint256 public presaleStartTime ; //    Wed Mar 16 2022 15:00:00 GMT+0000
    uint256 public presaleEndTime ; //  Sat Mar 26 2022 15:00:00 GMT+0000

    uint256 public firstReleaseTime ; 
    uint256 public secondReleaseTime ; 
    uint256 public thirdReleaseTime;

    uint public firstReleaseRate = 30;
    uint public secondReleaseRate = 30;  // accumulated rate 30 + 30
    uint public thirdReleaseRate = 40;

    address public erc20ContractAddress; // External erc20 contract

    uint256 public totalSaleAmount; // Total addresses' deposit amount
    uint256 public referalRate;
    uint256 public whiteListRate;

    EnumerableSet.AddressSet tokenBuyers;
    EnumerableSet.AddressSet whiteList;
    EnumerableSet.AddressSet secondReleasedSet;
    EnumerableSet.AddressSet thirdReleasedSet;
    //0x55d398326f99059fF775485246999027B3197955
    address public usdtAddress = address(0x55d398326f99059fF775485246999027B3197955); // usdt adddress in binance smart chain
    uint256 public tokensPerUsdt = 25; // here decimal is 1

    uint256 public minimumDepositUsdtAmount = 120 ether; // 120 usdt
    uint256 public maximumDepositUsdtAmount = 1200 ether; // Maximum 1200 usdt



    mapping(address => uint256) public depositAddressesETHAmount; // Address' deposit amount

    mapping(address => uint256)
    public depositAddressesAwardedTotalErc20CoinAmount; // Total awarded ERC20 coin amount for an address
    //   mapping(address => uint) public _depositAddressesAwardedDistribution1Erc20CoinAmount; // Awarded 1st distribution ERC20 coin amount for an address
    //   mapping(address => uint) public _depositAddressesAwardedDistribution2Erc20CoinAmount; // Awarded 2nd distribution ERC20 coin amount for an address
    mapping(address => uint256) public releasedAmount;
    mapping(address => uint256) public referalBonus;
    mapping(address => uint) public lastReleaseTime;


    // Deposit event
    event Deposit(address indexed _from, uint256 _value, address _referal);
    event DepositWithUSDT(address indexed _from, uint256 _value, address _referal);

    //release token
    event ReleaseToken(address releaseAddress, uint256 value);

    //distribute token (by admin)
    event DistributeSecond(uint _timeStamp);
    event DistributeThird(uint _timeStamp);

    event PresaleEndTimeChanged(uint _endTime);


    constructor(address _tokenAddress) {
        //0x181fd6e17715e2a817b0e7420e3b895bef6db3b1
        erc20ContractAddress = _tokenAddress;
    }


    // token transfer
    function initialize() public  {
        IERC20 tokenContract = IERC20(erc20ContractAddress);
        require(tokenContract.balanceOf(address(this)) >= presaleTokenAmount, "Insufficient token amount in presale contract");
        presaleStartTime = block.timestamp;  // set the presale start time
        presaleEndTime = presaleStartTime + 1 days; // set the presale end time
        firstReleaseTime = block.timestamp;
        secondReleaseTime = firstReleaseTime + 20 days;
        thirdReleaseTime = secondReleaseTime + 20 days;
        referalRate = 5;
        whiteListRate = 10;
    }

    
    // Receive ETH deposit
    function deposit(address _referal) public payable {
        require(
            block.timestamp >= presaleStartTime &&
                block.timestamp <= presaleEndTime,
            "Deposit rejected, presale has either not yet started or not yet overed"
        );

        require(tokenBuyers.contains(msg.sender) == false, "This address has bought the token before");

        
        require(
            msg.value >= minimumDepositETHAmount,
            "Deposit rejected, it is lesser than minimum amount"
        );

        require(
            msg.value <= maximumDepositETHAmount,
            "Deposit rejected, it is more than maximum amount"
        );

        uint tokenForBuyer = msg.value.mul(tokensPerETH);
        uint tokenForReferal = 0;
        if (tokenBuyers.contains(_referal)) {
            tokenForReferal = tokenForBuyer.mul(referalRate).div(100); // referal tokens
        }
        if (whiteList.contains(_referal)) {
            tokenForReferal = tokenForBuyer.mul(whiteListRate).div(100); // referal tokens
        }

        if (totalSaleAmount.add(tokenForBuyer).add(tokenForReferal) > presaleTokenAmount) {
            // if remaining token is less than the tokens for buyer
            uint256 newTokenForBuyer;
            uint256 newTokenForReferal;
            uint256 tokenRemaining = presaleTokenAmount.sub(totalSaleAmount);
            newTokenForBuyer = tokenRemaining.mul(tokenForBuyer).div(tokenForBuyer + tokenForReferal);
            newTokenForReferal = tokenRemaining.mul(tokenForReferal).div(tokenForBuyer + tokenForReferal);
            
            tokenForBuyer = newTokenForBuyer;
            tokenForReferal = newTokenForReferal;

            //send the remaining value
            uint priceToBuyRemain = tokenForBuyer.div(tokensPerETH);
            if (priceToBuyRemain < msg.value) payable(msg.sender).transfer(msg.value.sub(priceToBuyRemain));
        }

        depositAddressesAwardedTotalErc20CoinAmount[msg.sender] = tokenForBuyer;
        if (tokenBuyers.contains(_referal)) {
            // depositAddressesAwardedTotalErc20CoinAmount[_referal] += tokenForReferal;
            referalBonus[_referal] += tokenForReferal;
        }

        //calculate totalSaleAmount
        totalSaleAmount = totalSaleAmount.add(tokenForBuyer).add(tokenForReferal);

        //add msg.sender to token buyers
        tokenBuyers.add(msg.sender);

        //send the 30 % of the token
        IERC20 tokenContract = IERC20(erc20ContractAddress);
        uint releaseTokenCount = tokenForBuyer.mul(firstReleaseRate).div(100);

        releasedAmount[msg.sender] += releaseTokenCount;

        tokenContract.transfer(msg.sender, releaseTokenCount);
       
        emit Deposit(msg.sender, msg.value, _referal);
        emit ReleaseToken(msg.sender, releaseTokenCount);
    }

    function buyTokenWithUsdt(uint256 _usdtAmount, address _referal) public {

        require(
            block.timestamp >= presaleStartTime &&
                block.timestamp <= presaleEndTime,
            "Deposit rejected, presale has either not yet started or not yet overed"
        );

        require(tokenBuyers.contains(msg.sender) == false, "This address has bought the token before");

        require(
            _usdtAmount >= mininumbDepoistUSDTAmount,
            "Deposit rejected, it is lesser than minimum amount"
        );

        require(
            _usdtAmount <= maximumDepositUSDTAmount,
            "Deposit rejected, it is more than maximum amount"
        );

        IERC20 usdtContract = IERC20(usdtAddress);
        require(usdtContract.allowance(msg.sender, address(this)) >= _usdtAmount, "Contract is not allowed to transfer token");

        uint tokenForBuyer = _usdtAmount.mul(tokensPerUsdt).div(10); // here decimal is 1
        uint tokenForReferal = 0;

        if (tokenBuyers.contains(_referal)) {
            tokenForReferal = tokenForBuyer.mul(referalRate).div(100); // referal tokens
        }
        if (whiteList.contains(_referal)) {
            tokenForReferal = tokenForBuyer.mul(whiteListRate).div(100); // referal tokens
        }

        if (totalSaleAmount.add(tokenForBuyer).add(tokenForReferal) > presaleTokenAmount) {
            // if remaining token is less than the tokens for buyer
            uint256 newTokenForBuyer;
            uint256 newTokenForReferal;
            uint256 tokenRemaining = presaleTokenAmount.sub(totalSaleAmount);
            newTokenForBuyer = tokenRemaining.mul(tokenForBuyer).div(tokenForBuyer + tokenForReferal);
            newTokenForReferal = tokenRemaining.mul(tokenForReferal).div(tokenForBuyer + tokenForReferal);
            
            tokenForBuyer = newTokenForBuyer;
            tokenForReferal = newTokenForReferal;

            //send the remaining value
            uint priceToBuyRemain = tokenForBuyer.div(tokensPerUsdt).mul(10); // here decimal is 1
            //change _usdtAmount
            _usdtAmount = priceToBuyRemain;

            // if (priceToBuyRemain < msg.value) payable(msg.sender).transfer(msg.value.sub(priceToBuyRemain));
        }

        depositAddressesAwardedTotalErc20CoinAmount[msg.sender] = tokenForBuyer;
        if (tokenBuyers.contains(_referal)) {
            // depositAddressesAwardedTotalErc20CoinAmount[_referal] += tokenForReferal;
            referalBonus[_referal] += tokenForReferal;
        }

        //calculate totalSaleAmount
        totalSaleAmount = totalSaleAmount.add(tokenForBuyer).add(tokenForReferal);

        //add msg.sender to token buyers
        tokenBuyers.add(msg.sender);

        //send the 30 % of the token
        IERC20 tokenContract = IERC20(erc20ContractAddress);
        uint releaseTokenCount = tokenForBuyer.mul(firstReleaseRate).div(100);

        releasedAmount[msg.sender] += releaseTokenCount;

        tokenContract.transfer(msg.sender, releaseTokenCount);

        //send the usdt
        usdtContract.transferFrom(msg.sender, owner(), _usdtAmount);
        //withdrawUsdt();
        emit DepositWithUSDT(msg.sender, _usdtAmount, _referal);
        emit ReleaseToken(msg.sender, releaseTokenCount);
    }

    function claimTokenSecond() public {
        require(tokenBuyers.contains(msg.sender), "Address is not in the buyer list");
        require(!secondReleasedSet.contains(msg.sender), "Second release already done");
        require(block.timestamp > secondReleaseTime, "Not yet for second release");

        IERC20 tokenContract = IERC20(erc20ContractAddress);
        uint releaseTokenCount = depositAddressesAwardedTotalErc20CoinAmount[msg.sender].mul(secondReleaseRate).div(100);
        releasedAmount[msg.sender] += releaseTokenCount;

        // add msg.sender to the address set
        secondReleasedSet.add(msg.sender);


        tokenContract.transfer(msg.sender, releaseTokenCount);
        emit ReleaseToken(msg.sender, releaseTokenCount);
    }

    function distributeSecond() public {
        require(block.timestamp > secondReleaseTime, "Not yet for second release");

        uint buyerCount = tokenBuyers.length();
        IERC20 tokenContract = IERC20(erc20ContractAddress);

        for (uint i = 0; i < buyerCount; i ++) {
            address buyerAddress = tokenBuyers.at(i);
            if (secondReleasedSet.contains(buyerAddress)) continue;
            secondReleasedSet.add(buyerAddress);

            uint releaseTokenCount = depositAddressesAwardedTotalErc20CoinAmount[buyerAddress].mul(secondReleaseRate).div(100);
            releasedAmount[buyerAddress] += releaseTokenCount;
            tokenContract.transfer(msg.sender, releaseTokenCount);            
        }
        emit DistributeSecond(block.timestamp);
    }

    function claimTokenThird() public {
        require(tokenBuyers.contains(msg.sender), "Address is not in the buyer list");
        require(!thirdReleasedSet.contains(msg.sender), "Third release already done");
        require(block.timestamp > thirdReleaseTime, "Not yet for third release");


        IERC20 tokenContract = IERC20(erc20ContractAddress);
        //release amount is 40 % + referal bonus
        uint releaseTokenCount = depositAddressesAwardedTotalErc20CoinAmount[msg.sender].mul(thirdReleaseRate).div(100) + referalBonus[msg.sender];
        releasedAmount[msg.sender] += releaseTokenCount;

        // add msg.sender to the address set
        thirdReleasedSet.add(msg.sender);

        tokenContract.transfer(msg.sender, releaseTokenCount);
        emit ReleaseToken(msg.sender, releaseTokenCount);
    }

    function distributeThird() public {
        require(block.timestamp > thirdReleaseTime, "Not yet for third release");

        uint buyerCount = tokenBuyers.length();
        IERC20 tokenContract = IERC20(erc20ContractAddress);

        for (uint i = 0; i < buyerCount; i ++) {
            address buyerAddress = tokenBuyers.at(i);

            if (thirdReleasedSet.contains(buyerAddress)) continue;
            thirdReleasedSet.add(buyerAddress);

            uint releaseTokenCount = depositAddressesAwardedTotalErc20CoinAmount[buyerAddress].mul(thirdReleaseRate).div(100) + referalBonus[buyerAddress];
            releasedAmount[buyerAddress] += releaseTokenCount;
            tokenContract.transfer(msg.sender, releaseTokenCount);            
        }
        emit DistributeThird(block.timestamp);
    }



    // Allow admin to withdraw all the deposited ETH
    function withdrawAll() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    function withdrawUsdt() public onlyOwner{
        IERC20 usdtContract = IERC20(usdtAddress);
        usdtContract.transfer(owner(),usdtContract.balanceOf(address(this)));

    }

    // withdraw remaining tokes 
    function withdrawPegasusToken() public onlyOwner {
        IERC20 tokenContract = IERC20(erc20ContractAddress);
        tokenContract.transfer(owner(), tokenContract.balanceOf(address(this)));
    }

    function getPresaleAmount(address _address) public view returns(uint256) {
        return depositAddressesAwardedTotalErc20CoinAmount[_address] + referalBonus[_address];
    }

    function getReleasedAmount(address _address) public view returns(uint256) {
        return releasedAmount[_address];
    }
    function addWhiteListMember(address _address) public onlyOwner {
        whiteList.add(_address);
    }
    function removeWhiteListMember(address _address) public onlyOwner {
        whiteList.remove(_address);
    }
    function changeReferalRate(uint256 _amount) public onlyOwner {
        referalRate =  _amount;
    }
    function changeWhiteListRate(uint256 _amount) public onlyOwner {
        whiteListRate =  _amount;
    }
    function changeEndTime(uint256 _endTimestamp) public onlyOwner {
        presaleEndTime = _endTimestamp;
        emit PresaleEndTimeChanged(_endTimestamp);
    }
    function getRemainTokenAnmount() public view returns(uint256) {
        IERC20 tokenContract = IERC20(erc20ContractAddress);
        return tokenContract.balanceOf(address(this));
    }
    
}