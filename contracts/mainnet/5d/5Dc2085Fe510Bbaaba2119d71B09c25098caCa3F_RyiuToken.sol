// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20Base.sol";

/**
 * @dev allow the owner to block an address
 */
abstract contract AccountValidator is Ownable, ERC20Base {
    mapping(address => bool) private _denied;

    event AddressDenied(address indexed account, bool denied);

    modifier notDenied(address account) {
        require(!_denied[account], "Address denied");
        _;
    }

    function _setIsDenied(address account, bool denied) internal {
        _denied[account] = denied;
        emit AddressDenied(account, denied);
    }

    function isAccountDenied(address account) public view returns (bool) {
        return _denied[account];
    }

    function setIsAccountDenied(address account, bool denied) external onlyOwner {
        require(_denied[account] != denied, "Already set");
        _setIsDenied(account, denied);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override notDenied(from) notDenied(to) {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20Base.sol";

/**
 * @dev limit the maximum number of tokens per wallet
 */
abstract contract AntiWhale is Ownable, ERC20Base {
    uint256 public maxTokenPerWallet;
    mapping(address => bool) private _excluded;

    event ExcludedFromAntiWhale(address indexed account, bool excluded);
    event MaxTokenPerWalletUpdated(uint256 amount);

    constructor(uint256 maxTokenPerWallet_) {
        maxTokenPerWallet = maxTokenPerWallet_;

        _setIsExcludedFromAntiWhale(_msgSender(), true);
        _setIsExcludedFromAntiWhale(address(this), true);
    }

    function _setIsExcludedFromAntiWhale(address account, bool excluded) internal {
        _excluded[account] = excluded;
        emit ExcludedFromAntiWhale(account, excluded);
    }

    function isExcludedFromAntiWhale(address account) public view returns (bool) {
        return _excluded[account];
    }

    function setIsExcludedFromAntiWhale(address account, bool excluded) external onlyOwner {
        require(_excluded[account] != excluded, "Already set");
        _setIsExcludedFromAntiWhale(account, excluded);
    }

    function setMaxTokenPerWallet(uint256 amount) external onlyOwner {
        uint256 supply = totalSupply();

        if (amount == 0) amount = supply; // set to 0 to disable
        require(amount > (supply * 5) / 1000, "Amount too low"); // min 0.5% of supply

        maxTokenPerWallet = amount;
        emit MaxTokenPerWalletUpdated(amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        if (!isExcludedFromAntiWhale(to)) {
            require(balanceOf(to) <= maxTokenPerWallet, "AntiWhale: balance too high");
        }
        super._afterTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev abstract implementation of @openzeppelin's ERC20, without balance/supply management
 */
abstract contract ERC20Base is Context, IERC20, IERC20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balanceOf(from);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        _executeTransfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _executeTransfer(address from, address to, uint256 amount) internal virtual;

    function totalSupply() public view virtual override returns (uint256);

    function balanceOf(address account) public view virtual override returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract FeeDistributor is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _collectors;
    mapping(address => uint256) private _shares;
    uint256 public totalFeeCollectorsShares;

    event FeeCollectorAdded(address indexed account, uint256 share);
    event FeeCollectorUpdated(address indexed account, uint256 oldShare, uint256 newShare);
    event FeeCollectorRemoved(address indexed account);
    event FeeCollected(address indexed receiver, uint256 amount);

    function isFeeCollector(address account) public view returns (bool) {
        return _collectors.contains(account);
    }

    function feeCollectorShare(address account) public view returns (uint256) {
        return _shares[account];
    }

    function _addFeeCollector(address account, uint256 share) internal {
        require(!_collectors.contains(account), "Already fee collector");
        require(share > 0, "Invalid share");

        _collectors.add(account);
        _shares[account] = share;
        totalFeeCollectorsShares += share;

        emit FeeCollectorAdded(account, share);
    }

    function _removeFeeCollector(address account) internal {
        require(_collectors.contains(account), "Not fee collector");
        _collectors.remove(account);
        totalFeeCollectorsShares -= _shares[account];
        delete _shares[account];

        emit FeeCollectorRemoved(account);
    }

    function addFeeCollector(address account, uint256 share) external onlyOwner {
        _addFeeCollector(account, share);
    }

    function removeFeeCollector(address account) external onlyOwner {
        _removeFeeCollector(account);
    }

    function updateFeeCollectorShare(address account, uint256 share) external onlyOwner {
        require(_collectors.contains(account), "Not fee collector");
        require(share > 0, "Invalid share");

        uint256 oldShare = _shares[account];
        totalFeeCollectorsShares -= oldShare;

        _shares[account] = share;
        totalFeeCollectorsShares += share;

        emit FeeCollectorUpdated(account, oldShare, share);
    }

    function _distributeFees(uint256 amount) internal returns (bool) {
        if (amount == 0) return false;
        if (totalFeeCollectorsShares == 0) return false;

        uint256 distributed = 0;
        uint256 len = _collectors.length();
        for (uint256 i = 0; i < len; i++) {
            address collector = _collectors.at(i);
            uint256 share = i == len - 1
                ? amount - distributed
                : (amount * _shares[collector]) / totalFeeCollectorsShares;

            payable(collector).transfer(share);
            emit FeeCollected(collector, share);

            distributed += share;
        }

        return true;
    }

    function distributeFees(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough balance");
        _distributeFees(amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Recover is Ownable {
    event TokenRecovered(address indexed token, uint256 amount);

    function recoverTokens(address token, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");

        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(IERC20(token).transfer(msg.sender, amount));
        }

        emit TokenRecovered(token, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ERC20Base.sol";

abstract contract RewardToken is Ownable, ERC20Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;

    EnumerableSet.AddressSet private _excluded;

    event ExcludedFromRewards(address indexed account, bool excluded);
    event TransferRewards(address indexed from, uint256 amount);

    constructor(uint256 supply_) {
        _tTotal = supply_;
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function totalRewardFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_excluded.contains(account)) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function isExcludedFromRewards(address account) public view returns (bool) {
        return _excluded.contains(account);
    }

    function _setIsExcludedFromRewards(address account, bool excluded) internal {
        require(_excluded.contains(account) != excluded, "Already set");

        if (excluded) {
            if (_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _excluded.add(account);
        } else {
            _tOwned[account] = 0;
            _excluded.remove(account);
        }

        emit ExcludedFromRewards(account, excluded);
    }

    function setIsExcludedFromRewards(address account, bool excluded) external onlyOwner {
        _setIsExcludedFromRewards(account, excluded);
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _executeTransfer(address from, address to, uint256 amount) internal virtual override {
        _executeTokenTransfer(from, to, amount, amount / 100);
    }

    function _executeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint256 rewards
    ) internal {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(
            amount,
            rewards
        );
        require(_rOwned[sender] >= rAmount, "ERC20: transfer amount exceeds balance");

        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount;
        if (_excluded.contains(sender)) {
            require(_tOwned[sender] >= amount, "ERC20: transfer amount exceeds balance");
            _tOwned[sender] -= amount;
        }
        if (_excluded.contains(recipient)) _tOwned[recipient] += tTransferAmount;

        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if (rewards > 0) {
            emit TransferRewards(sender, rewards);
        }
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal -= rFee;
        _tFeeTotal += tFee;
    }

    function _getValues(
        uint256 tAmount,
        uint256 tFee
    ) private view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTransferAmount = rAmount - rFee;
        return (rAmount, rTransferAmount, rFee, tAmount - tFee, tFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length(); i++) {
            address addr = _excluded.at(i);
            if (_rOwned[addr] > rSupply || _tOwned[addr] > tSupply) return (_rTotal, _tTotal);
            rSupply -= _rOwned[addr];
            tSupply -= _tOwned[addr];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./FeeDistributor.sol";
import "./RewardToken.sol";

/*
 * TaxToken
 * Based on the configuration, a part of each transaction (buy, sell, transfer) is burned, added to the liquidity pool , used for yield rewards and sent to the collectors (ie team)
 */
abstract contract TaxToken is Ownable, FeeDistributor, RewardToken {
    struct FeeConfiguration {
        uint16 buyFees; // fees applied during buys, from 0 to 2000 (ie, 100 = 1%)
        uint16 sellFees; // fees applied during sells, from 0 to 2000 (ie, 100 = 1%)
        uint16 transferFees; // fees applied during transfers, from 0 to 2000 (ie, 100 = 1%)
        uint16 burnFeeRatio; // from 0 to 10000 (ie 8000 = 80% of the fee collected are burned)
        uint16 rewardsFeeRatio; // from 0 to 10000 (ie 8000 = 80% of the fee collected are used for passive rewards)
        uint16 liquidityFeeRatio; // from 0 to 10000 (ie 8000 = 80% of the fee collected are added back to liquidity)
        uint16 collectorsFeeRatio; // from 0 to 10000 (ie 8000 = 80% of the fee collected are sent to fee collectors)
    }

    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);
    uint16 public constant MAX_FEE = 2000; // max 20% fees
    uint16 public constant FEE_PRECISION = 10000;

    // swap config
    IUniswapV2Router02 public swapRouter;
    address public swapPair;
    address public liquidityOwner;

    // fees
    bool private _processingFees;
    bool public autoProcessFees;
    uint256 public numTokensToSwap; // amount of tokens to collect before processing fees (default to 0.05% of supply)
    FeeConfiguration public feeConfiguration;

    uint256 public tradeStartBlock;

    mapping(address => bool) private _excludedFromFees;
    mapping(address => bool) private _lpPools;
    mapping(address => bool) private _bots;

    event FeeConfigurationUpdated(FeeConfiguration configuration);
    event SwapRouterUpdated(address indexed router, address indexed pair);
    event ExcludedFromFees(address indexed account, bool excluded);
    event SetLpPool(address indexed pairAddress, bool isLp);
    event SetIsBot(address indexed account, bool isBot);

    modifier lockTheSwap() {
        _processingFees = true;
        _;
        _processingFees = false;
    }

    constructor(
        bool autoProcessFees_,
        uint256 numTokensToSwap_,
        address swapRouter_,
        FeeConfiguration memory feeConfiguration_
    ) {
        numTokensToSwap = numTokensToSwap_;
        autoProcessFees = autoProcessFees_;

        liquidityOwner = _msgSender();

        // Create a uniswap pair for this new token
        swapRouter = IUniswapV2Router02(swapRouter_);
        swapPair = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _lpPools[address(swapPair)] = true;

        // configure addresses excluded from fee
        _setIsExcludedFromFees(_msgSender(), true);
        _setIsExcludedFromFees(address(this), true);

        // configure fees
        _setFeeConfiguration(feeConfiguration_);
    }

    // receive ETH when swaping
    receive() external payable {}

    function isExcludedFromFees(address account) public view returns (bool) {
        return _excludedFromFees[account];
    }

    function _setIsExcludedFromFees(address account, bool excluded) internal {
        require(_excludedFromFees[account] != excluded, "Already set");
        _excludedFromFees[account] = excluded;
        emit ExcludedFromFees(account, excluded);
    }

    function setIsExcludedFromFees(address account, bool excluded) external onlyOwner {
        _setIsExcludedFromFees(account, excluded);
    }

    function isLpPool(address pairAddress) public view returns (bool) {
        return _lpPools[pairAddress];
    }

    function setIsLpPool(address pairAddress, bool isLp) external onlyOwner {
        require(_lpPools[pairAddress] != isLp, "Already set");
        _lpPools[pairAddress] = isLp;
        emit SetLpPool(pairAddress, isLp);
    }

    function isBot(address account) public view returns (bool) {
        return _bots[account];
    }

    function _setIsBot(address account, bool bot) internal {
        require(_bots[account] != bot, "Already set");
        _bots[account] = bot;
        emit SetIsBot(account, bot);
    }

    function setIsBot(address account, bool bot) external onlyOwner {
        _setIsBot(account, bot);
    }

    function updateSwapRouter(address _newRouter) external onlyOwner {
        require(_newRouter != address(0), "Invalid router");

        swapRouter = IUniswapV2Router02(_newRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(swapRouter.factory());
        require(address(factory) != address(0), "Invalid factory");

        address weth = swapRouter.WETH();
        swapPair = factory.getPair(address(this), weth);
        if (swapPair == address(0)) {
            swapPair = factory.createPair(address(this), weth);
        }

        require(swapPair != address(0), "Invalid pair address.");
        emit SwapRouterUpdated(address(swapRouter), swapPair);
    }

    function _setFeeConfiguration(FeeConfiguration memory configuration) private {
        require(configuration.buyFees <= MAX_FEE, "Invalid buy fee");
        require(configuration.sellFees <= MAX_FEE, "Invalid sell fee");
        require(configuration.transferFees <= MAX_FEE, "Invalid transfer fee");

        uint16 totalShare = configuration.burnFeeRatio +
            configuration.rewardsFeeRatio +
            configuration.liquidityFeeRatio +
            configuration.collectorsFeeRatio;
        require(totalShare == 0 || totalShare == FEE_PRECISION, "Invalid fee share");

        feeConfiguration = configuration;
        emit FeeConfigurationUpdated(configuration);
    }

    function setFeeConfiguration(FeeConfiguration calldata configuration) external onlyOwner {
        _setFeeConfiguration(configuration);
    }

    function _processFees(uint256 tokenAmount, uint256 minAmountOut) private lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= tokenAmount) {
            uint256 liquidityAmount = (tokenAmount * feeConfiguration.liquidityFeeRatio) /
                (FEE_PRECISION - feeConfiguration.burnFeeRatio - feeConfiguration.rewardsFeeRatio);
            uint256 liquidityTokens = liquidityAmount / 2;

            uint256 collectorsAmount = tokenAmount - liquidityAmount;
            uint256 liquifyAmount = liquidityAmount - liquidityTokens + collectorsAmount;

            // swap tokens
            if (liquifyAmount > 0) {
                // capture the contract's current balance.
                uint256 initialBalance = address(this).balance;

                _swapTokensForEth(liquifyAmount, minAmountOut);

                // how much did we just swap into?
                uint256 swapBalance = address(this).balance - initialBalance;

                // add liquidity
                uint256 liquidityETH = (swapBalance * liquidityTokens) / liquifyAmount;
                if (liquidityETH > 0) {
                    _addLiquidity(liquidityTokens, liquidityETH);
                }
            }

            // send remaining ETH to fee collectors
            _distributeFees(address(this).balance);
        }
    }

    function processFees(uint256 amount, uint256 minAmountOut) external onlyOwner {
        require(amount <= balanceOf(address(this)), "Amount too high");
        _processFees(amount, minAmountOut);
    }

    function setAutoprocessFees(bool autoProcess) external onlyOwner {
        require(autoProcessFees != autoProcess, "Already set");
        autoProcessFees = autoProcess;
    }

    function setNumTokensToSwap(uint256 amount) external onlyOwner {
        numTokensToSwap = amount;
    }

    function setLiquidityOwner(address newOwner) external onlyOwner {
        liquidityOwner = newOwner;
    }

    /// @dev Swap tokens for eth
    function _swapTokensForEth(uint256 tokenAmount, uint256 minAmountOut) private {
        // generate the swap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            minAmountOut,
            path,
            address(this),
            block.timestamp
        );
    }

    /// @dev Add liquidity
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(swapRouter), tokenAmount);

        // add the liquidity
        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityOwner,
            block.timestamp
        );
    }

    function _executeTransfer(address from, address to, uint256 amount) internal override {
        require(amount > 0, "Transfer <= 0");

        uint256 taxFee = 0;
        bool processFee = !_processingFees && autoProcessFees && tradeStartBlock > 0;
        bool bot = _bots[from] || _bots[to];

        if (!_processingFees) {
            bool fromExcluded = isExcludedFromFees(from);
            bool toExcluded = isExcludedFromFees(to);

            bool fromLP = isLpPool(from);
            bool toLP = isLpPool(to);

            if (toLP && tradeStartBlock == 0) {
                tradeStartBlock = block.number;
            }

            if (fromLP && !toLP && !toExcluded && to != address(swapRouter)) {
                // buy fee
                taxFee = feeConfiguration.buyFees;
                // flag sniper bots when buying in the first 2 blocks
                if (!bot && block.number <= tradeStartBlock + 1) {
                    _setIsBot(to, true);
                    _setIsExcludedFromRewards(to, true);
                    bot = true;
                }
            } else if (toLP && !fromExcluded && !toExcluded) {
                // sell fee
                taxFee = feeConfiguration.sellFees;
            } else if (!fromLP && !toLP && from != address(swapRouter) && !fromExcluded) {
                // transfer fee
                taxFee = feeConfiguration.transferFees;
            }
        }

        // apply max fees to bots
        if (bot) {
            taxFee = MAX_FEE;
        }

        // process fees
        if (processFee && taxFee > 0 && !_lpPools[from]) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= numTokensToSwap) {
                _processFees(numTokensToSwap, 0);
            }
        }

        if (taxFee > 0) {
            uint256 taxAmount = (amount * taxFee) / FEE_PRECISION;
            uint256 sendAmount = amount - taxAmount;
            uint256 burnAmount = (taxAmount * feeConfiguration.burnFeeRatio) / FEE_PRECISION;
            uint256 rewardAmount = (taxAmount * feeConfiguration.rewardsFeeRatio) / FEE_PRECISION;

            if (rewardAmount > 0) {
                taxAmount -= rewardAmount;
                sendAmount += rewardAmount;
            }

            if (burnAmount > 0) {
                taxAmount -= burnAmount;
                _executeTokenTransfer(from, BURN_ADDRESS, burnAmount, 0);
            }

            if (taxAmount > 0) {
                _executeTokenTransfer(from, address(this), taxAmount, 0);
            }

            if (sendAmount > 0) {
                _executeTokenTransfer(from, to, sendAmount, rewardAmount);
            }
        } else {
            _executeTokenTransfer(from, to, amount, 0);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/AccountValidator.sol";
import "./libraries/AntiWhale.sol";
import "./libraries/Recover.sol";
import "./libraries/TaxToken.sol";

contract RyiuToken is Ownable, AccountValidator, Recover, AntiWhale, TaxToken {
    string private constant NAME = "RYIU Token";
    string private constant SYMBOL = "RYIU";
    uint8 private constant DECIMALS = 9;
    uint256 private constant SUPPLY = 20 * 10 ** 6 * 10 ** 9;

    constructor(
        address swapRouter_,
        FeeConfiguration memory feeConfiguration_
    )
        ERC20Base(NAME, SYMBOL, DECIMALS)
        AntiWhale(SUPPLY / 100) /* 1% of supply */
        TaxToken(true, (SUPPLY * 5) / 10000 /* 0.05% of supply */, swapRouter_, feeConfiguration_)
        RewardToken(SUPPLY)
    {
        // configure addresses excluded from rewards
        _setIsExcludedFromRewards(swapPair, true);
        _setIsExcludedFromRewards(BURN_ADDRESS, true);

        // configure addresses excluded from antiwhale
        _setIsExcludedFromAntiWhale(swapPair, true);
        _setIsExcludedFromAntiWhale(BURN_ADDRESS, true);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override (ERC20Base, AccountValidator) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Base, AntiWhale) {
        super._afterTokenTransfer(from, to, amount);
    }
}