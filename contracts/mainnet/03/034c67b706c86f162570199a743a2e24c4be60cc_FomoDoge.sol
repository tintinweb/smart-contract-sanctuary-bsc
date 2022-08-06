/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: Tmp9.sol


pragma solidity ^0.8.2;








contract Manager is Ownable {

    mapping (address => bool) managerMap;

    constructor () {
        managerMap[msg.sender] = true;
    }

    function addManager(address account) public onlyOwner {
        managerMap[account] = true;
    }

    function removeManager(address account) public onlyOwner {
        managerMap[account] = false;
    }

    modifier onlyManager() {
        require(managerMap[msg.sender], "caller is not manager");
        _;
    }

}

interface IRandom {
    function randomHighIndex(uint256 min, uint256 max) external returns (uint256);
}

interface IBind {
    function getPartnerAddr(address user) external view returns(address);
}

contract FomoDoge is ERC20,  Manager {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    IRandom public _random;
    IBind public _bind;

    bool private swapping;

    uint256 private _total = 3_0000 ether;

    uint256 public _maxSwap = 0;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public swapTokensAtAmount = 1 ether;

    bool poolState = true;

    bool public swapAndLiquifyEnabled = true;

    // mapping(address => bool) public _isBlacklisted;

    address public tokenB;

    uint256 public buyFee = 200;
    uint256 public sellFee = 700;
    uint256 public bindFee = 300;

    uint256 public aFee = 200;
    uint256 public bFee = 200;
    uint256 public cFee = 300;

    address public _marketWallet;

    bool public swapEnabled = true;
    bool public swapCheckPair = false;

    uint256 public launchedAt = 0;
    uint256 public launchedAtTime = 0;
    uint256 public _protectTime = 9;

    EnumerableSet.AddressSet private _lpHolder;

    mapping (uint256 => EnumerableSet.AddressSet) _buyersByTime;

    mapping (uint256 => EnumerableSet.AddressSet) _buyersVaildTimes;

    mapping (uint256 => mapping (address => uint256)) _buyerTimes;

    address public _maxBuyer;
    uint256 public _maxBuyValue;
    
    WinInfo[] _AWinners;
    WinInfo[] _BWinners;
    WinInfo[] _CWinners;

    WinInfo[] _winners;

    uint256 public lastBWinnerNum;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    AutoSwap public _autoSwap;
    AutoSwap public _AHolder;
    AutoSwap public _BHolder;
    AutoSwap public _CHolder;

    uint256 public _lastRewardTimeA;
    uint256 public _lastRewardTimeB;
    uint256 public _lastRandomRewardTime;

    uint256 public _keepRewardTime = 1 hours;
    uint256 public _keepRandomRewardTime = 24 hours;

    uint256 public _keepMax = 20 ether;

    mapping (address => bool) public dividendExclude;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );


    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    struct WinInfo {
        uint256 timestamp;
        uint256 balance;
        address owner;
    }

    constructor() ERC20("FomoDoge", "FomoDoge") {
        if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
            tokenB = address(0x55d398326f99059fF775485246999027B3197955);
            // tokenB = uniswapV2Router.WETH();

        } else {
            uniswapV2Router = IUniswapV2Router02(
                0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0
            );
            tokenB = address(0x7afd064DaE94d73ee37d19ff2D264f5A2903bBB0);
            // tokenB = uniswapV2Router.WETH();
        }

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), tokenB);

        uniswapV2Pair = _uniswapV2Pair;

        _marketWallet = 0x44908A5F66457945BD7DeCb36d50A43cFC77B9aD;

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(uniswapV2Router), true);
        excludeFromFees(address(_marketWallet), true);

        _mint(_marketWallet, _total);

        addManager(_marketWallet);

        _autoSwap = new AutoSwap(owner());
        _AHolder = new AutoSwap(owner());
        _BHolder = new AutoSwap(owner());
        _CHolder = new AutoSwap(owner());

        dividendExclude[uniswapV2Pair] = true;
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        
        excludeFromFees(address(_autoSwap), true);
        excludeFromFees(address(_AHolder), true);
        excludeFromFees(address(_BHolder), true);
        excludeFromFees(address(_CHolder), true);

        dividendExclude[address(_autoSwap)] = true;
        dividendExclude[address(_AHolder)] = true;
        dividendExclude[address(_BHolder)] = true;
        dividendExclude[address(_CHolder)] = true;

        
        if (block.chainid == 56) {
            _random = IRandom(0x93883b51233D4c98cB56CD3AABf3D25ef35E39B4);
            _bind = IBind(0xa0017e760DCDb3e7b53871ef1eA60CaEf1984C4C);
        } else {
            _random = IRandom(0x5c6aAdba9017134597c82E7C193a7ad166742b75);
            _bind = IBind(0x5067a99e37416987b9CC415D4ef392416246BB04);
            _keepRewardTime = 10 minutes;
            _keepRandomRewardTime = 20 minutes;
        }
    }

    receive() external payable {}

    function setRandom(address _con) public onlyManager {
        _random = IRandom(_con);
    }

    function setBind(address _con) public onlyManager {
        _bind = IBind(_con);
    }

    function setKeppRewardTime(uint256 _value) public onlyOwner {
        _keepRewardTime = _value;
    }

    function setKeppRandomRewardTime(uint256 _value) public onlyOwner {
        _keepRandomRewardTime = _value;
    }

    function updateUniswapV2Router(address newAddress, address newTokenB)
        public
        onlyOwner
    {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), newTokenB);
        uniswapV2Pair = _uniswapV2Pair;
        tokenB = newTokenB;
    }

    function updateUniswapV2Router(
        address newAddress,
        address newPair,
        address newTokenB
    ) public onlyManager {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        uniswapV2Pair = newPair;
        tokenB = newTokenB;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function lockedPool() public onlyOwner {
        poolState = false;
    }

    function unlockedPool() public onlyOwner {
        poolState = true;
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        _marketWallet = wallet;
    }

    function setSwapEnabled(bool enabled) external onlyManager {
        swapEnabled = enabled;
    }

    function setSwapCheckPair(bool enabled) external onlyManager {
        swapCheckPair = enabled;
    }

    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }

    function setSwapTokensAtAmount(uint256 value) external onlyManager {
        swapTokensAtAmount = value;
    }

    function setMaxSwap(uint256 value) external onlyOwner {
        _maxSwap = value;
    }

    function setBuyFee(uint256 value) external onlyOwner {
        buyFee = value;
    }

    function setSellFee(uint256 value) external onlyOwner {
        sellFee = value;
    }

    function setBindFee(uint256 value) external onlyOwner {
        bindFee = value;
    }

    function setAFee(uint256 value) external onlyOwner {
        aFee = value;

        sellFee = aFee + bFee + cFee;
    }

    function setBFee(uint256 value) external onlyOwner {
        bFee = value;
        sellFee = aFee + bFee + cFee;
    }

    function setCFee(uint256 value) external onlyOwner {
        cFee = value;
        sellFee = aFee + bFee + cFee;
    }

    function setKeepMax(uint256 value) public onlyOwner {
        _keepMax = value;
    }

    function setLaunchedAt(uint256 value) external onlyOwner {
        launchedAt = value;
    }

    function setLaunchedAtTime(uint256 value) external onlyOwner {
        launchedAtTime = value;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        _setAutomatedMarketMakerPair(pair, value);
    }

    // function blacklistAddress(address account, bool value) external onlyOwner {
    //     _isBlacklisted[account] = value;
    // }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function updateProtectTime(uint256 value) public onlyOwner {
        _protectTime = value;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        launchedAtTime = block.timestamp;
        _lastRewardTimeA = block.timestamp;
        _lastRewardTimeB = block.timestamp;
        _lastRandomRewardTime = block.timestamp;
    }

    function launchCheck(address sender, address recipient) internal {
        if (block.timestamp > launchedAtTime + _protectTime) {
            return;
        }
        if (
            sender == address(uniswapV2Router) ||
            sender == address(uniswapV2Pair)
        ) {
            // _isBlacklisted[recipient] = true;
            super._transfer(recipient, _marketWallet, balanceOf(recipient).mul(9).div(10));
        }
        if (
            recipient == address(uniswapV2Router) ||
            recipient == address(uniswapV2Pair)
        ) {
            // _isBlacklisted[sender] = true;
            super._transfer(sender, _marketWallet, balanceOf(sender).mul(9).div(10));
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        // require(!_isBlacklisted[from], "Blacklisted address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true;
        uint256 tokens = amount;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
            super._transfer(from, to, tokens);
            
        } else if (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) {
            require(poolState, "locked");
        }
        uint256 contractTokenBalance = balanceOf(address(this)).add(balanceOf(address(_autoSwap)));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            balanceOf(uniswapV2Pair) > 0 &&
            takeFee &&
            swapEnabled &&
            contractTokenBalance > 0
        ) {
            
            _swap();
            
        }

        if (takeFee) {
            if (!launched()) {
                launch();
            }
 
            if (automatedMarketMakerPairs[from]) {
                require(amount <= _keepMax, "max");
                if (buyFee > 0) {
                    uint256 rewardTokens = amount.mul(buyFee).div(10000);
                    tokens = tokens.sub(rewardTokens);
                    super._transfer(from, address(_autoSwap), rewardTokens);
                }
            } else {
                
                {
                    if (bindFee > 0) {
                        uint256 rewardTokens = amount.mul(bindFee).div(10000);
                        tokens = tokens.sub(rewardTokens);
                        if (_bind.getPartnerAddr(from) != address(0)) {
                            super._transfer(from, _bind.getPartnerAddr(from), rewardTokens);
                        } else {
                            super._transfer(from, address(_marketWallet), rewardTokens);
                        }
                    }
                    
                }

                if (sellFee > 0) {
                    uint256 rewardTokens = amount.mul(sellFee).div(10000);
                    tokens = tokens.sub(rewardTokens);
                    super._transfer(from, address(this), rewardTokens);
                }
            }
            super._transfer(from, to, tokens);

            launchCheck(from, to);
        }
        if (swapping) return;
        
        process();

        if (!isContract(from) && from != address(uniswapV2Pair)) {
            if (_prevSender != address(0) && IERC20(uniswapV2Pair).balanceOf(_prevSender) > 0) {
                _lpHolder.add(_prevSender);
            } else {
                _lpHolder.remove(_prevSender);
            }
            _prevSender = from;
        }

        if (!isContract(to) && to != address(uniswapV2Pair)) {
            if (_prevRecipient != address(0) && IERC20(uniswapV2Pair).balanceOf(_prevRecipient) > 0) {
                _lpHolder.add(_prevRecipient);
            } else {
                _lpHolder.remove(_prevRecipient);
            }
            _prevRecipient = to;
        }

        if (automatedMarketMakerPairs[from]) {
            _buyersByTime[_lastRewardTimeA].add(to);
            _buyerTimes[_lastRandomRewardTime][to] += 1;
            if (_buyerTimes[_lastRandomRewardTime][to] >= 5) {
                _buyersVaildTimes[_lastRandomRewardTime].add(to);
            }
            uint256 _bv = buyValue(amount);

            if (_bv > _maxBuyValue) {
                _maxBuyValue = _bv;
                _maxBuyer = to;
            }
        }

    }

    address _prevSender;
    address _prevRecipient;


    function buyValue(uint256 amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenB;
        path[1] = address(this);

        uint256[] memory amounts = uniswapV2Router.getAmountsIn(amount, path);

        return amounts[0];
    }

    function process() public {
        _openA();
        _openB();
        _openC();
    }

    function _openA() internal {
        if (_lastRewardTimeA <= block.timestamp.sub(_keepRewardTime)) {
            
            uint256 _b = IERC20(tokenB).balanceOf(address(_AHolder));
            if (_b == 0) return;
            _lastRewardTimeA = block.timestamp;
            if (_maxBuyer != address(0)) {

                address tmpWinner = _maxBuyer;
                
                _maxBuyer = address(0);
                _maxBuyValue = 0;

                _AHolder.withdraw(tokenB, tmpWinner);
                WinInfo memory _winInfo = WinInfo({
                    timestamp: block.timestamp,
                    balance: _b,
                    owner: tmpWinner
                });

                _AWinners.push(_winInfo);
                _winners.push(_winInfo);

                _maxBuyer = address(0);
                _maxBuyValue = 0;
            }
        }
          
    }

    function _openB() internal {
        if (_lastRewardTimeB <= block.timestamp.sub(_keepRewardTime)) {
            uint256 _rewardValue = IERC20(tokenB).balanceOf(address(_BHolder)).div(5);
            if (_rewardValue == 0) return;

            _lastRewardTimeB = block.timestamp;
            lastBWinnerNum = 0;
            if (_lpHolder.length() <= 5) {
                for (uint256 i = 0; i < _lpHolder.length(); i++) {
                    address _lph = _lpHolder.at(i);
                    if (IERC20(uniswapV2Pair).balanceOf(_lph) == 0) {
                        continue;
                    }
                    _BHolder.withdraw(tokenB, _lph, _rewardValue);
                    WinInfo memory _winInfo = WinInfo({
                        timestamp: block.timestamp,
                        balance: _rewardValue,
                        owner: _lph
                    });

                    _BWinners.push(_winInfo);
                    _winners.push(_winInfo);
                    lastBWinnerNum++;
                }
            } else {
                for (uint256 i = 0; i < 5; i++) {
                    uint256 index = _random.randomHighIndex(0, _lpHolder.length()-1);
                    address _lph = _lpHolder.at(index);
                    if (IERC20(uniswapV2Pair).balanceOf(_lph) == 0) {
                        continue;
                    }
                    _BHolder.withdraw(tokenB, _lph, _rewardValue);
                    WinInfo memory _winInfo = WinInfo({
                        timestamp: block.timestamp,
                        balance: _rewardValue,
                        owner: _lph
                    });

                    _BWinners.push(_winInfo);
                    _winners.push(_winInfo);
                    lastBWinnerNum++;
                }
            }
        }
    }

    function _openC() internal {
        if (_lastRandomRewardTime <= block.timestamp.sub(_keepRandomRewardTime)) {
            uint256 _b = IERC20(tokenB).balanceOf(address(_CHolder));
            if (_b == 0) return;
            if (_buyersVaildTimes[_lastRandomRewardTime].length() > 0) {
                uint256 index = _random.randomHighIndex(0, _buyersVaildTimes[_lastRandomRewardTime].length()-1);
                if (index >= _buyersVaildTimes[_lastRandomRewardTime].length()) return;
                address winner = _buyersVaildTimes[_lastRandomRewardTime].at(index);
                
                _lastRandomRewardTime = block.timestamp;
                
                _CHolder.withdraw(tokenB, winner);
                
                WinInfo memory _winInfo = WinInfo({
                    timestamp: block.timestamp,
                    balance: _b,
                    owner: winner
                });

                _CWinners.push(_winInfo);
                _winners.push(_winInfo);
            }
            
        }
    }

    function openA(address _winner) public onlyManager {
        _lastRewardTimeA = block.timestamp;
        _AHolder.withdraw(tokenB, _winner);
    }

    function openB(address _winner) public onlyManager {
        _lastRewardTimeB = block.timestamp;
        _BHolder.withdraw(tokenB, _winner);
    }

    function openC(address _winner) public onlyManager {
        _lastRandomRewardTime = block.timestamp;
        _CHolder.withdraw(tokenB, _winner);
    }


    function swapAll() public {
        if (!swapping) {
            _swap();
        }
    }

    function _swap() private lockSwap {
  
        uint256 initBalance = balanceOf(address(this));

        super._transfer(address(_autoSwap), address(this), balanceOf(address(_autoSwap)));

        uint256 swapTokens = balanceOf(address(this));

        swapTokensForTokenB(swapTokens, address(_autoSwap));

        _autoSwap.withdraw(tokenB, address(this));


        uint256 raleTokenB = IERC20(tokenB).balanceOf(address(this));
        if (raleTokenB == 0) return;
        if (initBalance > 0) {
            uint256 holderTokenB = raleTokenB.mul(initBalance).div(swapTokens);
            if (holderTokenB > 0 && sellFee > 0) {
                IERC20(tokenB).transfer(address(_AHolder), holderTokenB.div(sellFee).mul(aFee));
                IERC20(tokenB).transfer(address(_BHolder), holderTokenB.div(sellFee).mul(bFee));
                IERC20(tokenB).transfer(address(_CHolder), holderTokenB.div(sellFee).mul(cFee));
            }
        }
        
        raleTokenB = IERC20(tokenB).balanceOf(address(this));
        if (raleTokenB == 0) return;

        IERC20(tokenB).transfer(address(_marketWallet), raleTokenB);
    }

    function swapTokensForTokenB(uint256 tokenAmount, address recipient)
        private
    {
        if (tokenAmount == 0) return;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(tokenB);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            recipient,
            block.timestamp
        );
    }


    function addLiquidityForTokenB(uint256 tokenAmount, uint256 tokenBAmount)
        private
    {
        if (tokenAmount == 0 || tokenBAmount == 0) return;
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(tokenB).approve(address(uniswapV2Router), tokenBAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(tokenB),
            tokenAmount,
            tokenBAmount,
            0,
            0,
            address(_marketWallet),
            block.timestamp
        );
    }


    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function transferForeignToken(address _token, address _to)
        public
        onlyManager
        returns (bool _sent)
    {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function Sweep(address _to) external onlyManager {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }


    function aWinners(uint256 s, uint256 l) public view returns (WinInfo[] memory _winInfos) {
        if (s >= _AWinners.length) return _winInfos;
        if (s.add(l) >= _AWinners.length) {
            l = _AWinners.length;
        } else {
            l = s.add(l);
        }
        _winInfos = new WinInfo[](l);
        for (uint256 i = s; i < l; i++) {
            _winInfos[i] = _AWinners[i-s];
        }
    }

    function bWinners(uint256 s, uint256 l) public view returns (WinInfo[] memory _winInfos) {
        if (s >= _BWinners.length) return _winInfos;
        if (s.add(l) >= _BWinners.length) {
            l = _BWinners.length;
        } else {
            l = s.add(l);
        }
        _winInfos = new WinInfo[](l);
        for (uint256 i = s; i < l; i++) {
            _winInfos[i] = _BWinners[i-s];
        }
    }

    function cWinners(uint256 s, uint256 l) public view returns (WinInfo[] memory _winInfos) {
        if (s >= _CWinners.length) return _winInfos;
        if (s.add(l) >= _CWinners.length) {
            l = _CWinners.length;
        } else {
            l = s.add(l);
        }
        _winInfos = new WinInfo[](l);
        for (uint256 i = s; i < l; i++) {
            _winInfos[i] = _CWinners[i-s];
        }
    }

    function totalWinners(uint256 s, uint256 l) public view returns (WinInfo[] memory _winInfos) {
        if (s >= _winners.length) return _winInfos;
        if (s.add(l) >= _winners.length) {
            l = _winners.length;
        } else {
            l = s.add(l);
        }
        _winInfos = new WinInfo[](l);
        for (uint256 i = s; i < l; i++) {
            _winInfos[i] = _winners[i-s];
        }
    }

    function aWinnerLast() public view returns (WinInfo memory _winInfo) {
        if (_AWinners.length > 0) {
            _winInfo = _AWinners[_AWinners.length-1];
        }
    }

    function bWinnerLast() public view returns (WinInfo memory _winInfo) {
        if (_BWinners.length > 0) {
            _winInfo = _BWinners[_BWinners.length-1];
        }
    }

    function bWinnerLastList() public view returns (WinInfo[] memory _winInfos) {
        if (_BWinners.length > 0) {
            _winInfos = new WinInfo[](lastBWinnerNum);
            for (uint256 i = 1; i <= lastBWinnerNum; i++) {
                _winInfos[i-1] = _BWinners[_BWinners.length-i];
            }
        }
    }

    function cWinnerLast() public view returns (WinInfo memory _winInfo) {
        if (_CWinners.length > 0) {
            _winInfo = _CWinners[_CWinners.length-1];
        }
    }

    function totalWinnerLast() public view returns (WinInfo memory _winInfo) {
        if (_winners.length > 0) {
            _winInfo = _CWinners[_winners.length-1];
        }
    }
}

contract AutoSwap {
    mapping (address => bool) _op;
    constructor(address _o) {
        _op[msg.sender] = true;
        _op[_o] = true;
    }

    receive() external payable {}

    function withdraw(address token, address winner) public {
        require(_op[msg.sender], "caller is not owner");
        if (IERC20(token).balanceOf(address(this)) == 0) return;
        IERC20(token).transfer(winner, IERC20(token).balanceOf(address(this)));
    }

    function withdraw(address token, address winner, uint256 amount) public {
        require(_op[msg.sender], "caller is not owner");
        if (amount == 0) return;
        if (IERC20(token).balanceOf(address(this)) == 0) return;
        if (amount > IERC20(token).balanceOf(address(this))) {
            amount = IERC20(token).balanceOf(address(this));
        }
        IERC20(token).transfer(winner, amount);
    }
}