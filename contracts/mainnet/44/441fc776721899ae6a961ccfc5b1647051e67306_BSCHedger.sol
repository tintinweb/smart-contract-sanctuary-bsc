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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { ERC20 } from 'openzeppelin-contracts/token/ERC20/ERC20.sol';
// import { console } from 'forge-std/console.sol';

// https://github.com/VenusProtocol/venus-protocol/blob/develop/contracts/VToken.sol
// https://github.com/VenusProtocol/venus-protocol/blob/develop/contracts/Comptroller.sol

import { BSCHedgerBase } from './base/BSCHedgerBase.sol';
import { VBep20Interface, VTokenInterface } from './interfaces/Venus/VTokenInterfaces.sol';

contract BSCHedger is BSCHedgerBase {
	constructor(address _whitelist) BSCHedgerBase(_whitelist) {
		// For minting vToken
		USDC.approve(address(vUSDC), type(uint).max);
		ETH.approve(address(vETH), type(uint).max);

		// For swapping vToken
		USDC.approve(address(router), type(uint).max);
		ETH.approve(address(router), type(uint).max);

		// For Venus
		address[] memory vTokens = new address[](3);
		vTokens[0] = address(vETH);
		vTokens[1] = address(vUSDC);
		vTokens[2] = 0xA07c5b74C9B40447a954e1466938b865b6BBea36; // vBNB
		comptroller.enterMarkets(vTokens);
	}

	/// @dev Deposit USDC directly as the collateral
	function depositCollateral(uint256 amount) public onlyOwner {
		USDC.transferFrom(msg.sender, address(this), amount);
		vUSDC.mint(amount);
	}

	/// @dev Hedge and gives negative delta
	/// @dev Slippage is multiplied by 10^4, e.g. 0.01% => 100 // 0.05% => 500
	function hedge(address vToken, uint256 amount, uint256 slippage)
		public
		onlyOwner
		validVToken(vToken)
	{
		// Collateral check, param: USDC price of vToken (e.g. vETH)
		// decimal division:
		// - Oracle deicmals: 18
		// - ETH to USDC decimals: (18 ETH - 18 USDC) = 0
		// ==> total: 18
		uint amountInUSDC = amount * oracle.getUnderlyingPrice(VTokenInterface(vToken)) / (10 ** 18);
		_manageCollateral(amountInUSDC);

		// Borrow succeed => returns 0
		// console.log("This vToken bal b: ", VBep20Interface(VBep20Interface(vToken).underlying()).balanceOf(address(this)));
    require(VBep20Interface(vToken).borrow(amount) == 0, 'Borrow failed');
		// console.log("This vToken bal a1: ", VBep20Interface(VBep20Interface(vToken).underlying()).balanceOf(address(this)));

		// Swap borrowed token (underlying of vToken) to USDC to short it
		address[] memory path = new address[](2);
		path[0] = VBep20Interface(vToken).underlying();
		path[1] = address(USDC);
		// console.log(ERC20(VBep20Interface(vToken).underlying()).name());
		// console.log(amount, _amountLessSlippage(amountInUSDC, slippage));
		router.swapExactTokensForTokens(
			amount, // amountIn
			_amountLessSlippage(amountInUSDC, slippage), // amountOutMin
			path,
			address(this), // to
			block.timestamp + 60 // 60 seconds deadline
		);
		// console.log("This vToken bal a2: ", VBep20Interface(VBep20Interface(vToken).underlying()).balanceOf(address(this)));
	}

	/// @dev Pay back the hedge
	function payback(address vToken, uint256 amount, uint256 slippage)
		public
		onlyOwner
		validVToken(vToken)
	{
		VBep20Interface vuToken = VBep20Interface(VBep20Interface(vToken).underlying());
		// require(
		// 	vuToken.balanceOf(address(this)) >= amount,
		// 	'Insufficient vToken amount for repayment'
		// );
		require(VBep20Interface(vToken).repayBorrow(amount) == 0, 'Repay borrow failed');
	}

	// function swapDirect(address from, address to, uint256 amountIn, uint256 slippage)
	// 	internal
	// 	returns (uint[] memory amounts)
	// {
	// 	address[] memory path = new address[](2);
	// 	path[0] = from;
	// 	path[1] = to;

	// 	uint om = 0;
	// 	// uint om; // amountOutMin
	// 	// if (from == address(USDC)) {
	// 	// 	// converting from vToken to USDC
	// 	// 	uint price = oracle.getUnderlyingPrice(VTokenInterface(to)); // vToken price in USDC, 18 decimals
	// 	// 	om = _amountLessSlippage(amountIn * price / (10 ** 18), slippage);
	// 	// } else {
	// 	// 	// converting from USDC to vToken (using 10e8 to preserve decimals)
	// 	// 	uint price = oracle.getUnderlyingPrice(VTokenInterface(from));
	// 	// 	om = _amountLessSlippage(amountIn * 10e8 / price * 10e8 / (10 ** 18), slippage);
	// 	// }

	// 	// console.log("amountIn", amountIn);
	// 	// console.log("amountOutMin", om);
	// 	amounts = router.swapExactTokensForTokens(
	// 		amountIn, // amountIn
	// 		om, // amountOutMin
	// 		path,
	// 		address(this), // to
	// 		block.timestamp + 60 // 60 seconds deadline
	// 	);
	// }

	function swapAndPayback(address vToken, uint256 amount, uint256 slippage)
		public
		onlyOwner
		validVToken(vToken)
	{
		VBep20Interface vuToken = VBep20Interface(VBep20Interface(vToken).underlying()); // token underlying vToken

		if (address(vuToken) != address(USDC)) {
			// Swap USDC to vToken.underlying only if there's shortfall to repay `amount` of vToken.underlying
			if (amount > vuToken.balanceOf(address(this))) {
				uint price = oracle.getUnderlyingPrice(VTokenInterface(vToken));
				uint diff = amount - vuToken.balanceOf(address(this));
				uint inMax = _amountMoreSlippage(diff * price / (10 ** 18), slippage);
				// uint buffered = _amountMoreSlippage(diff, slippage); // << errors out without enough buffer amount in wallet
				// swapDirect(address(USDC), address(vuToken), amountInUSDC, slippage);

				address[] memory path = new address[](2);
				path[0] = address(USDC);
				path[1] = address(vuToken);
				// console.log("vUSDC bal: ", vUSDC.balanceOf(address(this)));
				// console.log("USDC bal: ", USDC.balanceOf(address(this)));
				// console.log("vuToken bal: ", vuToken.balanceOf(address(this)));
				// console.log("amount out", diff);
				// console.log("amount inMax", inMax);

				if (inMax > USDC.balanceOf(address(this))) {
					// Not enough USDC in wallet, so redeem just enough vUSDC (to USDC) to cover the difference
					uint buffer = _amountMoreSlippage(inMax - USDC.balanceOf(address(this)), 1000); // 0.1%
					vUSDC.redeemUnderlying(buffer);
				}

				router.swapTokensForExactTokens(
					diff, // amountOut
					inMax, // amountInMax
					path,
					address(this), // to
					block.timestamp + 60 // 60 seconds deadline
				);
			}
		}

		payback(vToken, amount, slippage);
	}

	/// @dev
	/// @param amountUSDC amount to borrow, in USDC
	function _manageCollateral(uint256 amountUSDC) internal {
		// 1. Get how much available collateral
		// uint256 collateral = getVTokenValue(vUSDC, vUSDC.balanceOf(msg.sender));
		(uint err,uint availableCollateral,) = comptroller.getAccountLiquidity(address(this));
		require(err == 0, 'Error in getting account liquidity!');
		
		uint requiredCollateral = amountUSDC * 1e4 / LTV;
		// console.log("Hedge amount USDC: ", amountUSDC);
		// console.log("Available Collateral: ", availableCollateral);
		// console.log("Required Collateral: ", requiredCollateral);
		// console.log("Current USDC bal: ", USDC.balanceOf(msg.sender));
		// console.log("Allowance for USDC: ", USDC.allowance(msg.sender, address(this)));

		// VTokenInterface[] memory tokens = comptroller.getAssetsIn(address(this));
		// for (uint i = 0; i < tokens.length; i++) {
		// 	VTokenInterface token = tokens[i];
		// 	(, uint vTokenBalance, uint borrowBalance,) = token.getAccountSnapshot(address(this));
		// 	console.log("vToken: ", address(token));
		// 	console.log("vTokenBalance: ", vTokenBalance);
		// 	console.log("borrowBalance: ", borrowBalance);
		// }

		// Not enough collateral, need to deposit collateral
		if (requiredCollateral > availableCollateral) {
			uint diff = requiredCollateral - availableCollateral;

			require(USDC.allowance(msg.sender, address(this)) >= diff, "Insufficient USDC allowance");
			require(USDC.balanceOf(msg.sender) >= diff, "Insufficient USDC to transfer");

			USDC.transferFrom(msg.sender, address(this), diff);
			// @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
			require(vUSDC.mint(diff) == 0, 'Mint failed');
		}
	}

	/// @dev Close all hedges and exit immediately
	function exit(address token, uint256 amount) public onlyOwner {
		// USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
		// vUSDC.transfer(msg.sender, vUSDC.balanceOf(address(this)));
		VTokenInterface[] memory vtokens = comptroller.getAssetsIn(address(this));
		for (uint i = 0; i < vtokens.length; i++) {
			VTokenInterface vtoken = vtokens[i];
			(, uint vTokenBalance, uint borrowBalance,) = vtoken.getAccountSnapshot(address(this));
			// console.log("vToken: ", address(vtoken));
			// console.log("vTokenBalance: ", vTokenBalance);
			// console.log("borrowBalance: ", borrowBalance);
			if (borrowBalance > 0) {
				swapAndPayback(address(vtoken), borrowBalance, defaultSlippage);
				VBep20Interface(address(vtoken)).redeemUnderlying(borrowBalance);
				(,vTokenBalance,,) = vtoken.getAccountSnapshot(address(this)); // update vTken balance
			}

			if (vTokenBalance > 0) {
				VBep20Interface(address(vtoken)).redeem(vTokenBalance);
				(,vTokenBalance,,) = vtoken.getAccountSnapshot(address(this)); // update vTken balance
				if (vTokenBalance > 0) VBep20Interface(address(vtoken)).redeemUnderlying(vTokenBalance);
				withdrawERC(VBep20Interface(address(vtoken)).underlying());
			}
		}
	}
	
	function withdrawERC(address token) public onlyOwner {
		ERC20(token).transfer(msg.sender, ERC20(token).balanceOf(address(this)));
	}

	function withdrawVToken(address vtoken) public onlyOwner {
		require(VTokenInterface(vtoken).isVToken(), 'Invalid vToken');
		VBep20Interface(vtoken).transfer(msg.sender, ERC20(vtoken).balanceOf(address(this)));
	}

	function withdrawUnderlying(address vtoken, uint amount) public onlyOwner {
		require(VTokenInterface(vtoken).isVToken(), 'Invalid vToken');
		VBep20Interface(vtoken).redeemUnderlying(amount);
		ERC20(VBep20Interface(vtoken).underlying()).transfer(msg.sender, amount);
	}

	function withdrawUnderlyingAll(address vtoken) public onlyOwner {
		require(VTokenInterface(vtoken).isVToken(), 'Invalid vToken');
		withdrawUnderlying(vtoken, ERC20(VBep20Interface(vtoken).underlying()).balanceOf(address(this)));
	}
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Ownable } from 'openzeppelin-contracts/access/Ownable.sol';
import { EnumerableSet } from 'openzeppelin-contracts/utils/structs/EnumerableSet.sol';
// import { console } from 'forge-std/console.sol';

import { BaseHedger } from './BaseHedger.sol';
import { PriceOracle } from '../interfaces/Venus/PriceOracle.sol';
import { VBep20Interface, VTokenInterface } from '../interfaces/Venus/VTokenInterfaces.sol';
import { EIP20NonStandardInterface } from '../interfaces/Venus/EIP20NonStandardInterface.sol';
import { ComptrollerInterface } from "../interfaces/Venus/ComptrollerInterface.sol";
import { IPancakeRouter01 } from '../interfaces/Venus/PancakeStuff.sol';

contract BSCHedgerBase is BaseHedger, Ownable {
	using EnumerableSet for EnumerableSet.AddressSet;

  VBep20Interface constant internal vUSDC = VBep20Interface(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8);
	EIP20NonStandardInterface immutable internal USDC;

	// /// @dev Native ETH on BSC
	VBep20Interface constant internal ETH = VBep20Interface(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);

	VBep20Interface constant internal vETH = VBep20Interface(0xf508fCD89b8bd15579dc79A6827cB4686A3592c8);

	IPancakeRouter01 constant internal router = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

	address constant internal comptrollerAddress = 0xfD36E2c2a6789Db23113685031d7F16329158384;
	ComptrollerInterface constant internal comptroller = ComptrollerInterface(comptrollerAddress); // Unitroller proxy

	// /// @dev GET PROXY ADDRESS OF THE PRICE ORACLE
	// /// @dev https://github.com/VenusProtocol/venus-protocol/blob/develop/contracts/PriceOracleProxy.sol
	PriceOracle constant internal oracle = PriceOracle(0xd8B6dA2bfEC71D684D3E2a2FC9492dDad5C3787F);

	EnumerableSet.AddressSet internal supportedVTokens;

	uint256 public defaultSlippage = 5000; // 0.5%

	modifier validVToken(address vToken) {
		require(supportedVTokens.contains(vToken), 'Unsupported vToken. Support the token first on the contract');
		_;
	}

  constructor(address _whitelist) BaseHedger(_whitelist) {
		USDC = EIP20NonStandardInterface(address(vUSDC.underlying()));
		supportedVTokens.add(address(vETH));
		supportedVTokens.add(address(vUSDC));
		supportedVTokens.add(0xA07c5b74C9B40447a954e1466938b865b6BBea36); // vBNB
	}

	function supportVToken(VTokenInterface token) public onlyOwner {
		supportedVTokens.add(address(token));
	}

	function unsupportVToken(VTokenInterface token) public onlyOwner {
		supportedVTokens.remove(address(token));
	}

	function getSupportedVTokens() public onlyOwner returns (address[] memory) {
		return supportedVTokens.values();
	}

	function isSupportedVToken(address token) public onlyOwner returns (bool) {
		return supportedVTokens.contains(token);
	}

	/// @dev Converts the input VToken amount to USDC value 
	function getVTokenValue(VTokenInterface token, uint256 amount) public returns (uint256) {
		return token.exchangeRateStored() * amount / 1e18;
	}

	function newDefaultSlippage(uint256 s) public onlyOwner {
		defaultSlippage = s;
	}
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Ownable } from 'openzeppelin-contracts/access/Ownable.sol';

import { IHedgerWhitelist } from '../interfaces/IHedgerWhitelist.sol';

/*

  NOTE: All functions here should be marked internal!

*/
contract BaseHedger {
  // uint256 internal maxSlippage = 10000; // 10^4 or 1% // 100 is 0.01%

  uint256 internal LTV = 0.65e4; // 6500 => 65%

  IHedgerWhitelist internal whitelist;

  constructor(address _whitelist) {
    whitelist = IHedgerWhitelist(_whitelist);
  }

  function depositSynapse() internal {
    
  }

  function withdrawSynapse() internal {

  }

  // function setMaxSlippage(uint16 s) public onlyOwner {
  //   maxSlippage = s;
  // }

  /// @dev Amount - amount * slippage
  /// @param a Amount of token
  /// @param s Desired slippage in 10^4 (e.g. 0.01% => 0.01e4 => 100)
  function _amountLessSlippage(uint256 a, uint256 s) internal pure returns (uint256) {
    return (a * (10 ** 6 - s)) / 10 ** 6;
  }

  /// @dev Amount + amount * slippage
  /// @param a Amount of token
  /// @param s Desired slippage in 10^4 (e.g. 0.01% => 0.01e4 => 100)
  function _amountMoreSlippage(uint256 a, uint256 s) internal pure returns (uint256) {
    // slippage: 0.5e4 (0.5%)
    return (a * (10 ** 6 + s)) / 10 ** 6;
  }

  fallback() external payable {}
	receive() external payable {}
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IHedgerWhitelist {
  function approved(address addr) external returns (bool);
}

pragma solidity ^0.8.17;

import "./VTokenInterfaces.sol";
import "./PriceOracle.sol";

interface IComptrollerInterfaceG1 {
    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata vTokens) external returns (uint[] memory);
    function exitMarket(address vToken) external returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address vToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address vToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address vToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address vToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address vToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address vToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address vToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address vToken, address src, address dst, uint transferTokens) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address vTokenBorrowed,
        address vTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
    function setMintedVAIOf(address owner, uint amount) external returns (uint);
}

contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;
}

interface ComptrollerInterfaceG2 is IComptrollerInterfaceG1 {
    function liquidateVAICalculateSeizeTokens(
        address vTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

interface IComptrollerInterface is ComptrollerInterfaceG2 {
    function markets(address) external view returns (bool, uint);
    function oracle() external view returns (PriceOracle);
    function getAccountLiquidity(address) external view returns (uint, uint, uint);
    function getAssetsIn(address) external view returns (VTokenInterface[] memory);
    function claimVenus(address) external;
    function venusAccrued(address) external view returns (uint);
    function venusSpeeds(address) external view returns (uint);
    function getAllMarkets() external view returns (VTokenInterface[] memory);
    function venusSupplierIndex(address, address) external view returns (uint);
    function venusInitialIndex() external view returns (uint224);
    function venusBorrowerIndex(address, address) external view returns (uint);
    function venusBorrowState(address) external view returns (uint224, uint32);
    function venusSupplyState(address) external view returns (uint224, uint32);
}

abstract contract ComptrollerInterface is IComptrollerInterface {
    bool public constant isComptroller = true;
}

interface IVAIVault {
    function updatePendingRewards() external;
}

interface IComptroller {
    function liquidationIncentiveMantissa() external view returns (uint);
    /*** Treasury Data ***/
    function treasuryAddress() external view returns (address);
    function treasuryPercent() external view returns (uint);
}

pragma solidity ^0.8.17;

/**
 * @title EIP20NonStandardInterface
 * @dev Version of BEP20 with no return values for `transfer` and `transferFrom`
 *  See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */
interface EIP20NonStandardInterface {

    /**
     * @notice Get the total number of tokens in circulation
     * @return The supply of tokens
     */
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transfer` does not return a value, in violation of the BEP-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      */
    function transfer(address dst, uint256 amount) external;

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transferFrom` does not return a value, in violation of the BEP-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      */
    function transferFrom(address src, address dst, uint256 amount) external;

    function approve(address spender, uint256 amount) external returns (bool success);

    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

pragma solidity ^0.8.17;

/**
  * @title Venus's InterestRateModel Interface
  * @author Venus
  */
interface InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    function isInterestRateModel() external returns (bool);

    /**
      * @notice Calculates the current borrow interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
      */
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);

    /**
      * @notice Calculates the current supply interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @param reserveFactorMantissa The current reserve factor the market has
      * @return The supply rate per block (as a percentage, and scaled by 1e18)
      */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
}

pragma solidity ^0.8.17;

interface IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeRouter02.sol

interface IPancakeRouter02 is IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeFactory.sol

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// File: contracts\interfaces\IPancakePair.sol

interface IPancakePair {
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

pragma solidity ^0.8.17;

import "./VTokenInterfaces.sol";

interface PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    // bool public constant isPriceOracle = true;

    /**
      * @notice Get the underlying price of a vToken asset
      * @param vToken The vToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(VTokenInterface vToken) external view returns (uint);
}

pragma solidity ^0.8.17;

import "./ComptrollerInterface.sol";
import "./InterestRateModel.sol";

interface VTokenInterface {
    /**
     * @notice Indicator that this is a VToken contract (for inspection)
     */
    // bool public constant isVToken = true;
    function isVToken() external returns (bool);

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function getCash() external view returns (uint);
    function accrueInterest() external returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);


    /*** Admin Functions ***/

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint);
    function _acceptAdmin() external returns (uint);
    function _setComptroller(ComptrollerInterface newComptroller) external returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _reduceReserves(uint reduceAmount) external returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint);
}

interface VBep20Interface is VTokenInterface {
    /**
     * @notice Underlying asset for this VToken
     */
    function underlying() external returns (address);

        /*** User Interface ***/

    function mint(uint mintAmount) external returns (uint);
    function mintBehalf(address receiver, uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, VTokenInterface vTokenCollateral) external returns (uint);


    /*** Admin Functions ***/

    function _addReserves(uint addAmount) external returns (uint);
}

interface VDelegatorInterface {
    /**
     * @notice Implementation address for this contract
     */
    function implementation() external returns (address);

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation
     */
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) external;

    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @dev Should revert if any issues arise which make it unfit for delegation
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) external;

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() external;
}