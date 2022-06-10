/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

pragma solidity =0.8.4;


// SPDX-License-Identifier: MIT
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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


// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)
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


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
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


interface IFairlaunchPool {

  function initialize(
    address[4] memory _addrs,
    uint256 _softCap,
    uint256 _maxOwnerReceive,
    address _currency,
    uint256 _totalSellingAmount,
    uint256[3] memory _timeSettings,
    uint256[2] memory _feeSettings,
    uint256 _liquidityPercent,
    string memory _poolDetails
    ) external;

  function initializeVesting(
    uint256 _totalVestingTokens,
    uint256 _tgeLockDuration,
    uint256 _tgeTokenRelease,
    uint256 _cycle,
    uint256 _tokenReleaseEachCycle
    ) external;

  function cancel() external;

  function claim() external;

  function contribute() payable external;

  function contribute(uint256 _amount) external;

  function finalize() external;

  function version() external view returns(uint8);

  function state() external view returns(uint8);

}


interface IFairlaunchPoolFactory {
	
    function createPool(
        address[3] memory addrs,
        uint256 softCap,
        uint256 maxOwnerReceive,
        address currency,
        uint256 totalSellingAmount,
        uint256[3] memory timeSettings,
        uint256[5] memory vestingSettings,
        uint256 liquidityPercentage,
        string memory poolDetails
    ) external payable returns(address pool);

    function feeTo() external view returns(address);

    function manager() external view returns(address);

    function governance() external view returns(address);

}


interface IFairlaunchPoolManager {
  
  function registerPool(address pool, address token, address owner, uint8 version) external;

  function recordContribution(address user, address pool) external;

  function removePoolForToken(address token, address pool) external;

  function isPoolGenerated(address pool) external returns(bool);

  function poolForToken(address token) external view returns(address[] memory);

}


interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}


interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}


interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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


library FairlaunchPoolStorage {
    struct PoolSettings {
        uint8 state;
        address router;
        address token;
        address currency;
        uint256 startTime;
        uint256 endTime;
        uint256 rate;
        uint256 softCap;
        uint256 maxOwnerReceive;
        uint256 totalSellingAmount;
        uint256 liquidityLockDays;
        uint256 liquidityPercent;
        uint256 ethFeePercent;
        uint256 tokenFeePercent;
        string poolDetails;
        string kycDetails;
        string auditDetails;
    }

    struct OwnerVestingSettings {
        uint256 totalVestingTokens;
        uint256 tgeLockDuration;
        uint256 cycle;
        uint256 tgeReleaseTokens;
        uint256 cycleReleaseTokens;
    }
}


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
// Subject to the MIT license.
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}


contract FairlaunchPool is IFairlaunchPool, Ownable, ReentrancyGuard {
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint8 public constant VERSION = 1;
  uint256 public constant PENALTYRATE = 10;

  enum PoolState { 
    Upcoming,
    Inprogress,
    Ended,
    Cancelled
  }
  PoolState public poolState;

  uint256 public ethFeePercent;
  uint256 public tokenFeePercent;

  IFairlaunchPoolFactory public factory;
  IFairlaunchPoolManager public manager;
  IUniswapV2Router02 public router;
  address public pair;

  address public governance;
  address public token; 
  //比例 1bnb可以兑换的token 精度放大 10 ** （18 - decimal），注意 默认currency的decimal是18
  uint256 public rate;

  uint256 public softCap;
  uint256 public maxOwnerReceive;
  address public currency;
  address private weth;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public totalSellingAmount;
  uint256 public finalizeTime;
  bool public completedKyc;
  string public kycDetails;
  bool public completedAudit;
  string public auditDetails;

  string public poolDetails;

  EnumerableSet.AddressSet private contributors;
  mapping(address => uint256) public claimedOf;
  mapping(address => uint256) public contributionOf;
  mapping(address => uint256) public refundedOf;

  uint256 public liquidityBalance; //todo 是啥值 token amount 还是lp amount
  uint256 public liquidityLockTime;
  uint256 public liquidityPercent;
  uint256 public liquidityUnlockTime;
  uint256 public minimumLockTime;

  uint256 public totalClaimed;
  uint256 public totalRaised;
  uint256 public totalRefunded;

  // team vesting config
  bool public isTeamVesting = false;
  uint256 public totalVestingTokens;
  uint256 public tgeLockDuration;
  uint256 public tgeTokensRelease;
  uint256 public cycle;
  uint256 public tokensReleaseEachCycle;
  uint256 public tgeTime;
  uint256 public totalVestedTokens;
  uint256 public cycleCount;


  event Cancelled(uint256 timestamp);
  event Claimed(
    address indexed user, 
    uint256 volum, 
    uint256 total
  );
  event Contributed(
    address indexed user, 
    uint256 amount, 
    uint256 total, 
    uint256 timestamp
  );
  event Finalized(uint256 liquidity, uint256 timestamp);
  event KycUpdated(bool completed,uint256 timestamp);
  event AuditUpdated(bool completed,uint256 timestamp);
  event LiquidityWithdrawn(uint256 amount, uint256 timestamp);
  event VestingTokenWithdrawn(uint256 amount, uint256 timestamp);
  event WithdrawnContribution(address user, uint256 amount);
  event PoolDetailsUpdated(string details, uint256 timestamp);

  modifier _onlyFactory() {
    require(address(factory) == msg.sender, "Not factory!");
    _;
  }

  modifier _onlyGovernance() {
    require(address(factory.governance()) == msg.sender, "Not governance!");
    _;
  }

  modifier _pooIsOngoing() {
    require(startTime < block.timestamp, "Pool not started yet!");
    require(endTime > block.timestamp, "pool endDate passed!");
    _;
  }

  modifier _isFinalize() {
    require(endTime <= block.timestamp, "pool not end!");
    require(poolState == PoolState.Ended, "pool not end");
    _;
  }

  constructor() {}

  receive() external payable {
    revert("Call contribute()");
  }

  function initialize(
    address[4] memory _addrs, // owner,router,token,factory
    uint256 _softCap,
    uint256 _maxOwnerReceive,
    address _currency,
    uint256 _totalSellingAmount,
    uint256[3] memory _timeSettings,
    uint256[2] memory _feeSettings,
    uint256 _liquidityPercent,
    string memory _poolDetails
  ) 
  external 
  override 
  {
    require(totalSellingAmount == 0, "initialized");
    
    address _owner = _addrs[0];
    token = _addrs[2];

    router = IUniswapV2Router02(_addrs[1]);
    weth = router.WETH();

    address _pair = IUniswapV2Factory(router.factory()).getPair(token, _currency);
    if(_pair == address(0)) {
      pair = IUniswapV2Factory(router.factory()).createPair(token, _currency);
    } else {
      pair = _pair;
    }

    factory = IFairlaunchPoolFactory(_addrs[3]);
    manager = IFairlaunchPoolManager(factory.manager());

    softCap = _softCap;
    maxOwnerReceive = _maxOwnerReceive;
    currency = _currency;
    totalSellingAmount = _totalSellingAmount;

    startTime = _timeSettings[0];
    require(startTime > block.timestamp,"startTime config err");
    endTime = _timeSettings[1];
    require(endTime > startTime,"endTime config err");
    liquidityLockTime = _timeSettings[2];

    ethFeePercent = _feeSettings[0];
    tokenFeePercent = _feeSettings[1];

    liquidityPercent = _liquidityPercent;
    poolDetails = _poolDetails;
    emit PoolDetailsUpdated(poolDetails, block.timestamp);
    poolState = PoolState.Upcoming;
    governance = factory.governance();
    super._transferOwnership(_owner);

    manager.registerPool(
      address(this),
      token,
      _owner, 
      VERSION
    );

  }

  function initializeVesting(
    uint256 _totalVestingTokens,
    uint256 _tgeLockDuration,
    uint256 _tgeTokenRelease,
    uint256 _cycle,
    uint256 _tokenReleaseEachCycle
  ) external override _onlyFactory {
    require(totalVestingTokens == 0, "only setting one time"); //只能用一次
    require(poolState == PoolState.Upcoming, "not Upcoming");
    require(_tgeTokenRelease >= 0, "config err");
    require(_cycle >= 0, "config err");
    require(_tokenReleaseEachCycle >= 0, "config err");

    isTeamVesting = true;

    totalVestingTokens = _totalVestingTokens;
    tgeLockDuration = _tgeLockDuration;
    tgeTokensRelease = _tgeTokenRelease;
    cycle = _cycle;
    tokensReleaseEachCycle = _tokenReleaseEachCycle;

    tgeTime = endTime;
    cycleCount = _totalVestingTokens.sub(_tgeTokenRelease).divCeil(tokensReleaseEachCycle);
  }

  function cancel() external override onlyOwner {
    require(poolState != PoolState.Ended, "pool ended");
    poolState = PoolState.Cancelled;
    emit Cancelled(block.timestamp);
  }

  function claim() external override nonReentrant _isFinalize {
    require(contributionOf[msg.sender] > 0, "no contribution");
    require(claimedOf[msg.sender] == 0, "calaimed");
    uint8 decimalsToken= IERC20(token).decimals();
    uint256 claimingAmount = contributionOf[msg.sender].mul(10**decimalsToken).div(10**18).mul(rate);
    claimedOf[msg.sender] = claimingAmount;
    IERC20(token).transfer(msg.sender, claimingAmount);
    emit Claimed(msg.sender, claimingAmount, claimingAmount);
  }

  // 预售使用BNB
  function contribute() 
  payable 
  external 
  override
  nonReentrant 
  _pooIsOngoing 
  {
    uint256 _amount = msg.value;
    address _sender = msg.sender;
    require(_amount > 0, "No WEI found!");
    uint256 _totalBeforeRaised = totalRaised;
    totalRaised += _amount;
    assert(totalRaised > _totalBeforeRaised); 
    //精度放大 10 ** （18 - decimal）
    rate = totalSellingAmount.mul(10 ** (18 - IERC20(token).decimals())).div(totalRaised);

    if(contributors.contains(_sender)) {
      contributionOf[_sender] = contributionOf[_sender].add(_amount);
    } else {
      contributors.add(_sender);
      contributionOf[_sender] = _amount;
      manager.recordContribution(_sender, address(this));
    }

    emit Contributed(_sender, _amount, contributionOf[_sender], block.timestamp);
  }

  // 使用稳定币作为currency
  function contribute(uint256 _amount) 
  external 
  override
  nonReentrant 
  _pooIsOngoing 
  {
    address _sender = msg.sender;
    safeTransferFromEnsureExactAmount(currency, _sender, address(this), _amount);

    totalRaised = totalRaised.add(_amount);
    //精度放大10 ** （18 - decimal）
    rate = totalSellingAmount.mul(10 ** (18 - IERC20(token).decimals())).div(totalRaised);

    if(contributors.contains(_sender)) {
      contributionOf[_sender] = contributionOf[_sender].add(_amount);
    } else {
      contributors.add(_sender);
      contributionOf[_sender] = _amount;
      manager.recordContribution(_sender, address(this));
    }

    emit Contributed(_sender, _amount, contributionOf[_sender], block.timestamp);
  }

  function finalize() external override onlyOwner {
    require(endTime <= block.timestamp, "pool not end!");
    require(totalRaised >= softCap, "softCap not pass");
    poolState = PoolState.Ended;

    tgeTime = block.timestamp;
    finalizeTime = block.timestamp;
    // 付费 token
    uint256 tokenFee = totalSellingAmount.mul(tokenFeePercent).div(100);
    IERC20(token).transfer(factory.feeTo(), tokenFee);
    // 付费 bnb
    uint256 currencyFee = totalRaised.mul(ethFeePercent).div(100);
    if(currency == weth) {
      payable(factory.feeTo()).transfer(currencyFee);
    } else {
      IERC20(currency).transfer(factory.feeTo(), currencyFee);
    }

    // addLiquidity 付完2%的手续费以后，在按照liquidityPercent算 添加LP的数量
    uint256 actualTokenAmount = totalSellingAmount.sub(tokenFee);
    uint256 actualCurrencyAmount = totalRaised.sub(currencyFee);

    uint256 lpTokenAmount = actualTokenAmount.mul(liquidityPercent).div(100);
    uint256 lpCurrencyAmount = actualCurrencyAmount.mul(liquidityPercent).div(100);
    uint256 liquidity = addLiquidity(lpTokenAmount, lpCurrencyAmount);

    // 将剩下的募集到的bnb转给项目方
    uint256 projectAmount = actualCurrencyAmount.sub(lpCurrencyAmount);
    if(currency == weth) {
      payable(msg.sender).transfer(projectAmount);
    } else {
      IERC20(currency).transfer(msg.sender, projectAmount);
    }

    emit Finalized(liquidity, block.timestamp);
  }

  // todo
  function getUpdatedState() external view returns(uint256, uint8, bool, string memory) { 
    uint256 a =100;
    return (a, uint8(poolState), completedKyc, poolDetails);
  }

  function purchasedVolumeOf(address user) external view returns(uint256) {
    return contributionOf[user];
  }


  function updateCompletedAudit(bool completed_) external _onlyGovernance {
    completedAudit = completed_;
    emit AuditUpdated(completedAudit, block.timestamp);
  }

  function updateAuditDetails(string memory auditDetails_) external _onlyGovernance {
    auditDetails = auditDetails_;
    emit AuditUpdated(true, block.timestamp);
  }

  function updateCompletedKyc(bool completed_) external _onlyGovernance {
    completedKyc = completed_;
    emit KycUpdated(completedKyc, block.timestamp);
  }

  function updateKycDetails(string memory kycDetails_) external _onlyGovernance {
    kycDetails = kycDetails_;
    emit KycUpdated(true, block.timestamp);
  }

  function updatePoolDetails(string memory details_) external onlyOwner {
    poolDetails = details_;
    emit PoolDetailsUpdated(poolDetails, block.timestamp);
  }

  function emergencyWithdraw(
    address payable to_, 
    uint256 amount_
  ) external _onlyGovernance {
    uint256 amount = address(this).balance;
    if(amount_ > amount){
      amount_ = amount;
    }
    to_.transfer(amount_);
  }

  function emergencyWithdrawToken(
    address token_,
    address to_, 
    uint256 amount_
  ) external _onlyGovernance {
    uint256 poolAmount = IERC20(token_).balanceOf(address(this));
    if(amount_ > poolAmount){
      amount_ = poolAmount;
    }
    IERC20(token).transfer(to_, amount_);
  }

   // 用户参与的bnb 未结束之前提回，扣除10%的bnb,扣除的罚款转到feeTo
  function withdrawContribution() external {
    require(poolState != PoolState.Ended, "pool finalized");
    uint256 _amount = contributionOf[msg.sender];
    require(_amount > 0, "No contribution");
    contributionOf[msg.sender] = 0;
    // contributors.remove(msg.sender);
    totalRaised = totalRaised.sub(_amount);
    if(totalRaised==0){
      rate=0;
    }else{
      rate = totalSellingAmount.mul(10 ** (18-IERC20(token).decimals())).div(totalRaised);
    } 

    // 未结束且未取消
    if(block.timestamp < endTime && poolState != PoolState.Cancelled) {
      uint256 punishment = _amount.mul(PENALTYRATE).div(100);
      uint256 amount = _amount.sub(punishment);
      if(currency == weth) {
        payable(factory.feeTo()).transfer(punishment);
        payable(msg.sender).transfer(amount);
      } else {
        IERC20(currency).transfer(factory.feeTo(), punishment);
        IERC20(currency).transfer(msg.sender, amount);
      }
      emit WithdrawnContribution(msg.sender, amount);
    } else {
      //时间到后,需要取消了且未达到软顶才能提现
      if(poolState != PoolState.Cancelled) {      
        require(totalRaised < softCap, "wait to finalize!!!");
      }

      if(currency == weth) {
        payable(msg.sender).transfer(_amount);
      } else {
        IERC20(currency).transfer(msg.sender, _amount);
      }
      emit WithdrawnContribution(msg.sender, _amount);
    }

  }

  // owner 取消launch后取回token
  function withdrawCancelledTokens() external onlyOwner {
    require(poolState == PoolState.Cancelled, "not cancelled");
    uint256 poolAmount = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(msg.sender, poolAmount);
  }

  function withdrawLeftovers() 
  external 
  onlyOwner  
  {
    require(poolState == PoolState.Cancelled || poolState == PoolState.Ended, "pool not withdraw");
    if(poolState == PoolState.Ended){
      require(endTime <= block.timestamp, "pool not end!");
    }

    uint256 _tokenAmount = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(msg.sender, _tokenAmount);
  }

  function withdrawCurrency() 
  external 
  onlyOwner
  _isFinalize  
  {

    if(currency == weth) {
      uint256 _ethAmount = address(this).balance;
      payable(msg.sender).transfer(_ethAmount);
    } else {
      uint256 _tokenAmount = IERC20(currency).balanceOf(address(this));
      IERC20(currency).transfer(msg.sender, _tokenAmount);
    }

  }

  function withdrawLiquidity() 
  external 
  onlyOwner 
  _isFinalize 
  {
    //LP 解锁后 提取LP //要按finalized后的时间算
    uint256 duration = block.timestamp.sub(finalizeTime);
    require(duration > liquidityLockTime, "liquidityLockTime err");
    uint256 _amount = IERC20(pair).balanceOf(address(this));
    require(_amount > 0, "liquidity_zero");
    IERC20(pair).transfer(msg.sender, _amount);
    emit LiquidityWithdrawn(_amount, block.timestamp);
  }

  function withdrawVestingToken() 
  external 
  onlyOwner 
  _isFinalize 
  {
    uint256 withdrawableAmounts = withdrawableVestingToken();
    if(withdrawableAmounts > 0) {
      totalVestedTokens = totalVestedTokens.add(withdrawableAmounts);
      IERC20(token).transfer(msg.sender, withdrawableAmounts);

      emit VestingTokenWithdrawn(withdrawableAmounts, block.timestamp);
    }

  }

  function withdrawableVestingToken() public view returns(uint256) {
    if(poolState != PoolState.Ended) {
      return 0;
    }

    if(!isTeamVesting) {
      return 0;
    }

    uint256 claimableVestingAmount = 0;  
    uint256 duration = block.timestamp.sub(tgeTime);
    if(duration <= tgeLockDuration) {
      return 0;
    }

    claimableVestingAmount = claimableVestingAmount.add(tgeTokensRelease); // 第一次释放的token

    uint256 cycleDuration = duration.sub(tgeLockDuration);
    uint256 count = cycleDuration.div(cycle);
    if(count > cycleCount) {
      claimableVestingAmount = totalVestingTokens; // 所有的team vesting token
    } else if(count > 0) {
      uint256 cycleAmounts = count.mul(tokensReleaseEachCycle);
      claimableVestingAmount = claimableVestingAmount.add(cycleAmounts);
    }

    if(claimableVestingAmount > totalVestingTokens) {
      claimableVestingAmount = totalVestingTokens;
    }

    uint256 claimableVestingAmountByNow = claimableVestingAmount.sub(totalVestedTokens);
    return claimableVestingAmountByNow;
  }

  // 只有owner取消后会出现refund
  function distributeRefund(uint256 start, uint256 end) external onlyOwner {
    require(poolState == PoolState.Cancelled, "not cancelled");
    require(start <= end, "index err");

    if (end >= contributors.length()) {
      end = contributors.length() - 1;
    }

    for(uint256 i = start; i < end; i++) {

      address user = contributors.at(i);
      refundedOf[user] = contributionOf[user] - refundedOf[user];
      if(refundedOf[user] > 0) {
        if(currency == weth) {
          payable(user).transfer(refundedOf[user]);
        } else {
          IERC20(currency).transfer(user, refundedOf[user]);
        }
      }

    }

  }

  function safeTransferFromEnsureExactAmount(
    address _token,
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    uint256 oldRecipientBalance = IERC20(_token).balanceOf(recipient);
    IERC20(_token).safeTransferFrom(sender, recipient, amount);
    uint256 newRecipientBalance = IERC20(_token).balanceOf(recipient);
    require(
      newRecipientBalance - oldRecipientBalance == amount,
      "Not enough token was transfered"
    );
  }

  function version() external pure override returns(uint8){
      return VERSION;
  }

  function state() external view override returns(uint8){
      return uint8(poolState);
  }

  function withdrawableTokens() external view returns(uint256){
    if (poolState != PoolState.Ended) {
      return 0;
    }
    if (contributionOf[msg.sender] == 0) {
      return 0;
    }
    uint256 amount = contributionOf[msg.sender].mul(rate);
    return amount;
  }

  function addLiquidity(
    uint256 tokenAmount, 
    uint256 currencyAmount
  ) private returns(uint256 liquidity) {
    // approve token transfer to cover all possible scenarios
    IERC20(token).approve(address(router), tokenAmount);

    // add the liquidity
    if(currency == weth) {
      ( , , liquidity ) = router.addLiquidityETH{value: currencyAmount}(
          token,
          tokenAmount,
          0, // slippage is unavoidable
          0, // slippage is unavoidable
          address(this),
          block.timestamp
      );
    } else {
      // approve currency transfer to cover all possible scenarios
      IERC20(currency).approve(address(router), currencyAmount);

      ( , , liquidity )= router.addLiquidity(
          token,
          currency,
          tokenAmount,
          currencyAmount,
          0, // slippage is unavoidable
          0, // slippage is unavoidable
          address(this),
          block.timestamp
      );
    }

  }

  function getContributorCount() public view returns(uint256) {
    return contributors.length();
  }

  function getContributors(uint256 start, uint256 end) 
  external view
  returns(address[] memory, uint256[] memory) {
    if (end >= contributors.length()) {
      end = contributors.length() - 1;
    }
    uint256 length = end - start + 1;
    address[] memory users = new address[](length);
    uint256[] memory amounts = new uint256[](length);
    uint256 currentIndex = 0;
    for (uint256 i = start; i <= end; i++) {
      address user = contributors.at(i);
      users[currentIndex] = user;
      amounts[currentIndex] = contributionOf[user];
      currentIndex++;
    }
    return (users, amounts);
  }

  function getPoolSettings() 
  external view returns(FairlaunchPoolStorage.PoolSettings memory poolSettings) {
    poolSettings.state = uint8(poolState);
    poolSettings.router = address(router);
    poolSettings.token = token;
    poolSettings.currency = currency;
    poolSettings.startTime = startTime;
    poolSettings.endTime = endTime;
    poolSettings.rate = rate;
    poolSettings.softCap = softCap;
    poolSettings.maxOwnerReceive = maxOwnerReceive;
    poolSettings.totalSellingAmount = totalSellingAmount;
    poolSettings.liquidityLockDays = liquidityLockTime;
    poolSettings.liquidityPercent = liquidityPercent;
    poolSettings.ethFeePercent = ethFeePercent;
    poolSettings.tokenFeePercent = tokenFeePercent;
    poolSettings.poolDetails = poolDetails;
    poolSettings.kycDetails = kycDetails;
    poolSettings.auditDetails = auditDetails;
  }

  function getOwnerVestingSettings()
   external view returns(FairlaunchPoolStorage.OwnerVestingSettings memory ownerVestingSettings) {
    ownerVestingSettings.totalVestingTokens = totalVestingTokens;
    ownerVestingSettings.tgeLockDuration = tgeLockDuration;
    ownerVestingSettings.cycle = cycle;
    ownerVestingSettings.tgeReleaseTokens = tgeTokensRelease;
    ownerVestingSettings.cycleReleaseTokens =tokensReleaseEachCycle;
  }

}