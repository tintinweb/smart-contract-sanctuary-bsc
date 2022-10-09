/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity 0.8.17;

// SPDX-License-Identifier: neuraless.com AND MIT

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
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

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)
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

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)
/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
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

// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)
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

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)
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

/*
 * literally constant values
 */
address constant ADDRESS_NULL = address(0);

address constant ADDRESS_DEAD = 0x000000000000000000000000000000000000dEaD;

address constant ADDRESS_PANCAKE_ROUTER_TEST = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

// Binance TestNet
address constant ADDRESS_PANCAKE_ROUTER_PROD = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

// Binance MainNet
address constant WALLET_NULL = ADDRESS_NULL;

string constant ERROR_WITHIN_LIQUIDITY_LOCK = "Still within Liquidity and Withdrawal lock time.";

string constant ERROR_TAXRATE_OUT_OF_BOUNDS = "Tax rate must be between bounds.";

string constant ERROR_DISTRATES_MUST_NOT_EXCEED_100 = "Distribution values must not exceed 100%.";

string constant ERROR_DISTRATE_OUT_OF_BOUNDS = "Distribution rate must be between bounds.";

string constant ERROR_LENGTHS_MUST_MATCH = "Lenghts of given arrays must must match.";

string constant ERROR_DISTRIBUTION_COUNT_OVERFLOW = "The maximum count of distribution wallets exceeded.";

string constant ERROR_NOTRANSFER_FROM_NULL = "Cannot transfer from null.";

string constant ERROR_NOTRANSFER_TO_NULL = "Cannot transfer to null.";

string constant ERROR_TRANSFER_SAME_ADDRESS = "Same sender and receiver address.";

string constant ERROR_SELLER_LOCKED = "Seller is locked.";

string constant ERROR_BUYER_LOCKED = "Buyer is locked.";

string constant ERROR_TRANSFERRER_LOCKED = "Transferrer is locked.";

string constant ERROR_SALE_LIMIT_REACHED = "Sale limit reached.";

string constant ERROR_BUY_LIMIT_REACHED = "Buy limit reached.";

string constant ERROR_TRANSFER_EXCEEDS_BALANCE = "Transfer exceeds balance.";

string constant ERROR_BALANCE_LIMIT_REACHED = "Target balance limit reached.";

string constant ERROR_INVALID_TOKEN_STATE_EXEC = "Invalid Token State for this Operation.";

string constant ERROR_INVALID_TOKEN_STATE = "Invalid Token State.";

string constant ERROR_INVALID_TOKEN_TRANSITION = "State must not be entered again.";

string constant ERROR_INVALID_TOKEN_STATE_MIGRATE = "Status Migration was explicitly disabled.";

string constant ERROR_MUTEX_ENTERED_TWICE = "Mutex entered multiple Times.";

string constant ERROR_REDUCTION_RATE_OUT_OF_BOUNDS = "Reduction Rate must be between 0 and 100.";

string constant ERROR_FALLBACK_MUST_NOT_TAKE_DATA = "Illegal use of Fallback function.";

string constant ERROR_BNB_TRANSFER_FAILED = "Transferral of BNB failed.";

abstract contract Mutex {
  mapping(uint8 => bool) internal _mutexMap;

  modifier mutex(uint8 id, bool requireCheck) {
    if (requireCheck) {
      require(_mutexMap[id] != true, ERROR_MUTEX_ENTERED_TWICE);
    }
    _mutexMap[id] = true;
    _;
    _mutexMap[id] = false;
  }

  function isInsideMutex(uint8 id) public view returns(bool) {
    return _mutexMap[id];
  }
}

uint8 constant STATE_LAUNCH = 0x01;

uint8 constant STATE_PRESALE = 0x02;

uint8 constant STATE_PUBLIC = 0x04;

uint8 constant STATE_MIGRATE = 0x64;

uint8 constant ALL_STATES = STATE_LAUNCH | STATE_PRESALE | STATE_PUBLIC | STATE_MIGRATE;

contract StateVerified {
  event StateChange(uint8 from, uint8 to);

  uint8 internal _state;
  bool internal _migrateDisabled = false;

  modifier allowStates(uint8 states) {
    require(states & _state == _state, ERROR_INVALID_TOKEN_STATE_EXEC);
    _;
  }

  function setState(uint8 state) public virtual {
    // check for well known states
    require(ALL_STATES & state == state, ERROR_INVALID_TOKEN_STATE);

    // check for not moving back to STATE_LAUNCH or STATE_PRESALE
    // they are one time use only
    require(!(state == STATE_LAUNCH && _state > STATE_LAUNCH), ERROR_INVALID_TOKEN_TRANSITION);
    require(!(state == STATE_PRESALE && _state > STATE_PRESALE), ERROR_INVALID_TOKEN_TRANSITION);

    // check if migration mode was entirely disabled
    require(!(state == STATE_MIGRATE && _migrateDisabled == true), ERROR_INVALID_TOKEN_STATE_MIGRATE);

    emit StateChange(_state, state);
    _state = state;
  }

  function getState() public view returns (uint8) {
    return _state;
  }

  function disableMigrateState() public virtual {
    _migrateDisabled = true;
  }
}

enum RatesIndex {
  CIRCULATION,
  TAX_BUY,
  TAX_SALE,
  TAX_TRANSFER,
  SWAP,
  DIST_BURN,
  DIST_LIQUIDITY
}

/// @custom:security-contact [email protected]
abstract contract TaxableToken is
  ERC20,
  ERC20Burnable,
  Ownable,
  ReentrancyGuard,
  Mutex,
  StateVerified
{
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeMath for uint256;

// public constants
  uint8 public constant BALANCE_LIMIT_PERCENTAGE = 3;
  uint8 public constant SALE_LIMIT_PERCENTAGE = 1;
  uint8 public constant BUY_LIMIT_PERCENTAGE = 1;

// private constants
  uint8 private constant MUTEX_SWAP = 0;
  uint256 private constant DISTRIBUTION_MULTIPLIER = 2**64;

// immutables
  uint256 private immutable _amountSwapLimit;
  uint256 private immutable _amountInitialSupply;

  IUniswapV2Router02 internal immutable router;

  address payable internal immutable walletThis;
  address payable internal immutable walletRouter;
  address payable internal immutable walletRouterPair;

  uint256 public immutable balanceLimit;
  uint256 public immutable saleLimit;
  uint256 public immutable buyLimit;

  uint256 public saleLockDuration = 0;
  uint256 public buyLockDuration = 0;

  uint256 public claimedLiquidity = 0;

  // tax rate values
  uint8[2] public taxBounds = [0, 25];
  uint8 public taxRateBuy = 10;
  uint8 public taxRateSale = 15;
  uint8 public taxRateTransfer = 10;

  // tax distribution values
  uint8[2] public distBounds = [0, 50];
  uint8 public distRateBurn = 40;
  uint8 public distRateLiquidity = 20;
  uint8[] public distRates;
  address payable[] public distWallets;

  uint256 public totalWithdrawn;

  bool private _skipLengthCheck = false;

  EnumerableSet.AddressSet private _exclusionsTax;
  EnumerableSet.AddressSet private _exclusionsSaleLock;
  EnumerableSet.AddressSet private _exclusionsBuyLock;

  uint256 public totalAddedLiquidityETH = 0;
  bool public autoLiquidity = true;

  mapping(address => uint256) private _saleLock;
  mapping(address => uint256) private _buyLock;

  event ClaimedForLiquidity(address indexed from, uint256 value);
  event Received(address indexed sender);
  event SetAutoLiquidity(bool value);
  event SetRate(string identifier, uint8 value);
  event SwappedAndLiquidified(
    uint256 swapped,
    uint256 liquidity,
    uint256 amountBNB
  );
  event TaxedBuy(
    uint8 tax,
    address indexed from,
    address indexed to,
    uint value
  );
  event TaxedSale(
    uint8 tax,
    address indexed from,
    address indexed to,
    uint value
  );
  event TaxedTransfer(
    uint8 tax,
    address indexed from,
    address indexed to,
    uint value
  );
  event TokenCreated(address indexed owner, address indexed token);
  event TransferredDistributedValue(address indexed to, uint256 value);
  event WithdrawnBNB(address indexed wallet, uint256 amount);
 
  receive() external payable {
    emit Received(msg.sender);
  }

  fallback() external payable {
    // give callers a hint that he uses contract API not properly
    require(msg.data.length == 0, ERROR_FALLBACK_MUST_NOT_TAKE_DATA);
  }

  /*----------------------------------------------------------------
   * Constructor for the Taxable Token Contract
   */
  constructor(
    string memory tokenname,
    string memory tokensymbol,
    uint256 supplyInitial,
    address _owner,
    uint8[] memory _rates,
    uint8[] memory _distRates,
    address payable[] memory _distWallets,
    address swapRouter
  ) ERC20(tokenname, tokensymbol) {
    _mint(msg.sender, supplyInitial.mul(10**decimals()));

    taxRateBuy = _rates[uint(RatesIndex.TAX_BUY)];
    taxRateSale = _rates[uint(RatesIndex.TAX_SALE)];
    taxRateTransfer = _rates[uint(RatesIndex.TAX_TRANSFER)];
    distRateBurn = _rates[uint(RatesIndex.DIST_BURN)];
    distRateLiquidity = _rates[uint(RatesIndex.DIST_LIQUIDITY)];
    distRates = _distRates;
    distWallets = _distWallets;

    uint256 initialSupply = totalSupply();

    IUniswapV2Router02 r = IUniswapV2Router02(swapRouter);
    IUniswapV2Factory pcFactory = IUniswapV2Factory(r.factory());

    balanceLimit = initialSupply.mul(BALANCE_LIMIT_PERCENTAGE).div(10**2);
    saleLimit = initialSupply.mul(SALE_LIMIT_PERCENTAGE).div(10**2);
    buyLimit = initialSupply.mul(BUY_LIMIT_PERCENTAGE).div(10**2);

    // init immutables
    _amountInitialSupply = initialSupply;
    _amountSwapLimit = _amountInitialSupply
      .mul(_rates[uint(RatesIndex.SWAP)])
      .div(10**4);

    router = r;

    address wthis = payable(address(this));
    walletThis = payable(wthis);
    walletRouter = payable(address(r));
    walletRouterPair = payable(pcFactory.createPair(wthis, r.WETH()));

    _exclusionsTax.add(wthis);
    _exclusionsTax.add(owner());
    _exclusionsTax.add(msg.sender);
    _excludeTaxDistributionWallets();

    transfer(
      wthis,
      totalSupply().mul(_rates[uint(RatesIndex.CIRCULATION)]).div(10**2)
    );

    setState(STATE_LAUNCH);

    emit TokenCreated(owner(), wthis);

    transferOwnership(_owner);
  }

  /*----------------------------------------------------------------*/

  /*----------------------------------------------------------------
   * Public Token API
   */

  /**
   * Transfers ownership and adapts tax exclusions
   */
  function transferOwnership(address newOwner)
    public
    override
    onlyOwner
    allowStates(STATE_LAUNCH | STATE_MIGRATE)
  {
    _exclusionsTax.remove(owner());
    _exclusionsTax.add(newOwner);
    super.transferOwnership(newOwner);
  }

  /*----------------------------------------------------------------*/

  /*----------------------------------------------------------------
   * transferring details
   */

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override allowStates(STATE_PRESALE | STATE_PUBLIC) {
    require(from != ADDRESS_NULL, ERROR_NOTRANSFER_FROM_NULL);
    require(to != ADDRESS_NULL, ERROR_NOTRANSFER_TO_NULL);
    require(balanceOf(from) >= amount, ERROR_TRANSFER_EXCEEDS_BALANCE);

    if (_isUntaxedTransfer(from, to) || _state == STATE_PRESALE) {
      _transferUntaxed(from, to, amount);
    } else {
      _transferTaxed(from, to, amount);
    }
  }

  /**
   * this function does a transfer between 2 wallets
   *
   * first the configured burnRate is burnt
   *
   * second the correlating tax amount is dispatched to the configured
   * tax dispatch wallets
   *
   * the remaining value is then transferred to the target wallet
   */
  function _transferTaxed(
    address from,
    address to,
    uint256 value
  ) internal {
    bool isSale = _isSale(to);
    bool isBuy = _isBuy(from);

    // check if we hit the defined limits
    _checkLimits(from, to, value, isSale, isBuy);

    // check for and update locks
    _handleTransferLocks(from, to, isSale, isBuy);

    uint8 taxRate = _getTargetTaxRate(from, to);

    if (isBuy) {
      emit TaxedBuy(taxRate, from, to, value);
    } else if (isSale) {
      emit TaxedSale(taxRate, from, to, value);
    } else {
      emit TaxedTransfer(taxRate, from, to, value);
    }

    if (
      (from != walletRouterPair) &&
      (autoLiquidity) &&
      (!isInsideMutex(MUTEX_SWAP)) &&
      isSale
    ) {
      _swapAndLiquify();
    }

    uint256 netAmount = value;
    uint256 taxAmount = 0;
    (netAmount, taxAmount) = _reduceAmount(netAmount, taxRate);

    _distributeTaxValues(from, taxAmount);

    super._transfer(from, to, netAmount);
  }

  function _checkLimits(
    address from,
    address to,
    uint256 value,
    bool isSale,
    bool isBuy
  ) internal view {
    uint256 toBalance = balanceOf(to);
    uint256 fromBalance = balanceOf(from);

    require(fromBalance >= value, ERROR_TRANSFER_EXCEEDS_BALANCE);

    if (isSale) {
      require(value <= saleLimit, ERROR_SALE_LIMIT_REACHED);
    } else if (isBuy) {
      require(value <= buyLimit, ERROR_BUY_LIMIT_REACHED);
      require(
        toBalance.add(value) <= balanceLimit,
        ERROR_BALANCE_LIMIT_REACHED
      );
    } else {
      // transfer
      require(
        toBalance.add(value) <= balanceLimit,
        ERROR_BALANCE_LIMIT_REACHED
      );
    }
  }

  function _handleTransferLocks(
    address from,
    address to,
    bool isSale,
    bool isBuy
  ) internal {
    if (isBuy) {
      // check for and update sale lock state if enabled and buyer not excluded
      if (buyLockDuration > 0 && !isExcludedFromBuyLock(to)) {
        require(_buyLock[to] <= block.timestamp, ERROR_BUYER_LOCKED);
        _buyLock[to] = block.timestamp.add(buyLockDuration);
      }
    } else {
      // check for and update sale lock state if enabled and seller not excluded
      // for sales and transfers
      if (saleLockDuration > 0 && !isExcludedFromSaleLock(from)) {
        require(_saleLock[from] <= block.timestamp, ERROR_SELLER_LOCKED);

        // update sale lock state only for sales not for transfers
        if (isSale) {
          _saleLock[from] = block.timestamp.add(saleLockDuration);
        }
      }
    }
  }

  function _transferUntaxed(
    address from,
    address to,
    uint256 value
  ) internal {
    super._transfer(from, to, value);
  }

  /*----------------------------------------------------------------*/
  function getInitialSupply() external view returns (uint256) {
    return _amountInitialSupply;
  }

  function getCirculationAmount() public view returns (uint256) {
    return balanceOf(walletThis).sub(claimedLiquidity);
  }

  function getCirculationRate() external view returns (uint256) {
    return getCirculationAmount().mul(10**2).div(totalSupply());
  }

  function setSaleLockDuration(uint256 duration) external onlyOwner {
    saleLockDuration = duration;
  }

  function setBuyLockDuration(uint256 duration) external onlyOwner {
    buyLockDuration = duration;
  }

  /*----------------------------------------------------------------
   * liquidity handlings
   */
  function setAutoLiquidity(bool _autoLiquidity) external onlyOwner {
    autoLiquidity = _autoLiquidity;
    emit SetAutoLiquidity(autoLiquidity);
  }

  function claimLiquidity(uint256 value) external onlyOwner {
    super._transfer(_msgSender(), walletThis, value);
    claimedLiquidity = claimedLiquidity.add(value);
    emit ClaimedForLiquidity(_msgSender(), value);
  }

  function _swapAndLiquify() internal mutex(MUTEX_SWAP, true) {
    // only execute batched swaps in limit-sized-chunks
    // and even liquidity percentage is > 0
    if (claimedLiquidity < _amountSwapLimit || distRateLiquidity == 0) {
      return;
    }

    //split the amount in 2 halves
    uint256 half4Liq = _amountSwapLimit.div(2);
    uint256 half4BNB = _amountSwapLimit.sub(half4Liq);

    // capture BNB balance before swap
    uint256 initialBNBBalance = walletThis.balance;

    // do the swap with the BNB half of tokens
    _swapTokenForETH(half4BNB);

    // calculate delta on BNB balance
    uint256 deltaBNB = (walletThis.balance.sub(initialBNBBalance));

    _addLiquidity(half4Liq, deltaBNB);

    claimedLiquidity = claimedLiquidity.sub(_amountSwapLimit);

    emit SwappedAndLiquidified(half4BNB, half4Liq, deltaBNB);
  }

  /**
   * used internally to swap tokens for ETH (BNB)
   */
  function _swapTokenForETH(uint256 tokenAmount) internal {
    address[] memory path = new address[](2);
    path[0] = walletThis;
    path[1] = router.WETH();

    // approve the transfer to cover all possible scenarios
    _approve(walletThis, walletRouter, tokenAmount);

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      walletThis,
      block.timestamp
    );
  }

  /**
   * Used internally to transfer Liquidity to the pool
   */
  function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
    totalAddedLiquidityETH += ethAmount;

    // approve the transfer to cover all possible scenarios
    _approve(walletThis, walletRouter, tokenAmount);

    // do the liquidity transfer
    router.addLiquidityETH{value: ethAmount}(
      walletThis,
      tokenAmount,
      0,
      0,
      walletThis,
      block.timestamp
    );
  }

  /*----------------------------------------------------------------*/

  /*----------------------------------------------------------------
   * tax rate setters
   */
  /* buy -----------------------------------------------------------*/
  function setTaxRateBuy(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    // sale and buy rates added must be lower than upper tax bound
    require(
      value >= taxBounds[0] && (taxRateSale + value) <= taxBounds[1],
      ERROR_TAXRATE_OUT_OF_BOUNDS
    );
    taxRateBuy = value;
    emit SetRate("TaxBuy", value);
  }

  /* sale ----------------------------------------------------------*/
  function setTaxRateSale(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    // sale and buy rates added must be lower than upper tax bound
    require(
      value >= taxBounds[0] && (taxRateBuy + value) <= taxBounds[1],
      ERROR_TAXRATE_OUT_OF_BOUNDS
    );
    taxRateSale = value;
    emit SetRate("TaxSale", value);
  }

  /* transfer ------------------------------------------------------*/
  function setTaxRateTransfer(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(
      value >= taxBounds[0] && value <= taxBounds[1],
      ERROR_TAXRATE_OUT_OF_BOUNDS
    );
    taxRateTransfer = value;
    emit SetRate("TaxTransfer", value);
  }

  /* burn ----------------------------------------------------------*/
  function setDistRateBurn(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(
      value >= distBounds[0] && value <= distBounds[1],
      ERROR_DISTRATE_OUT_OF_BOUNDS
    );
    distRateBurn = value;
    _requireDistRatesLimit();
    emit SetRate("DistBurn", value);
  }

  /* liquidity -----------------------------------------------------*/
  function setDistRateLiquidity(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(
      value >= distBounds[0] && value <= distBounds[1],
      ERROR_DISTRATE_OUT_OF_BOUNDS
    );
    distRateLiquidity = value;
    _requireDistRatesLimit();
    emit SetRate("DistLiquidity", value);
  }

  /* distribution --------------------------------------------------*/
  function setDistRates(uint8[] memory rates)
    public
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(rates.length <= 10, ERROR_DISTRIBUTION_COUNT_OVERFLOW);
    if (!_skipLengthCheck) {
      require(distWallets.length == rates.length, ERROR_LENGTHS_MUST_MATCH);
    }
    distRates = rates;
    _requireDistRatesLimit();
    for (uint8 i = 0; i < rates.length; i++) {
      emit SetRate("DistTeamWallet", rates[i]);
    }
  }

  function _requireDistRatesLimit() private view {
    // UIN16 is important to suppress an overflow attack
    uint16 total = 0;
    for (uint8 i = 0; i < distRates.length; i++) {
      total += distRates[i];
    }

    total += (distRateBurn + distRateLiquidity);

    require(total <= 100, ERROR_DISTRATES_MUST_NOT_EXCEED_100);
  }

  function getDistributedValue(address wallet) public view returns (uint256) {
    return allowance(walletThis, wallet);
  }

  /* wallet --------------------------------------------------------*/
  function addTaxExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsTax.add(wallet);
  }

  function removeTaxExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsTax.remove(wallet);
  }

  function addSaleLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsSaleLock.add(wallet);
  }

  function removeSaleLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsSaleLock.remove(wallet);
  }

  function addBuyLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsBuyLock.add(wallet);
  }

  function removeBuyLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsBuyLock.remove(wallet);
  }

  function setTaxDistributionWallets(address payable[] memory wallets)
    public
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(wallets.length <= 10, ERROR_DISTRIBUTION_COUNT_OVERFLOW);
    if (!_skipLengthCheck) {
      require(distRates.length == wallets.length, ERROR_LENGTHS_MUST_MATCH);
    }
    _removeTaxDistributionWalletExclusions();
    distWallets = wallets;
    _excludeTaxDistributionWallets();
  }

  function setTaxDistributions(
    address payable[] memory wallets,
    uint8[] memory rates
  ) external onlyOwner allowStates(STATE_PUBLIC) {
    require(wallets.length == rates.length, ERROR_LENGTHS_MUST_MATCH);

    _skipLengthCheck = true;
    setTaxDistributionWallets(wallets);
    setDistRates(rates);
    _skipLengthCheck = false;
  }

  function getRouterWallet() external view returns (address) {
    return walletRouter;
  }

  function getRouterPairWallet() external view returns (address) {
    return walletRouterPair;
  }

  /* state ---------------------------------------------------------*/
  function setState(uint8 state) public override onlyOwner {
    super.setState(state);
  }

  function disableMigrateState() public override onlyOwner {
    super.disableMigrateState();
  }

  /*----------------------------------------------------------------*/

  /*----------------------------------------------------------------
   * decision and calculation helper functions
   */
  function _isUntaxedTransfer(address from, address to)
    internal
    view
    returns (bool)
  {
    // determine if we have a tax-free transfer
    // this is:
    // * from/to team-wallet
    // * from/to contract itself
    // * liquidity

    bool isExcluded = (isExcludedFromTax(from) || isExcludedFromTax(to));
    bool isLiquidityTx = ((to == walletRouterPair && from == walletRouter) ||
      (to == walletRouterPair && from == walletRouter));

    if (isExcluded || isLiquidityTx) {
      return true;
    }

    return false;
  }

  function withdrawBNB(address payable wallet) external onlyOwner {
    uint256 valueBNB = walletThis.balance;

    (bool sent,) = wallet.call{value: valueBNB}("");

    require(sent, ERROR_BNB_TRANSFER_FAILED);

    totalWithdrawn = totalWithdrawn.add(valueBNB);

    emit WithdrawnBNB(wallet, valueBNB);
  }

  function transferDistributedValues() external onlyOwner {
    for (uint8 i = 0; i < distWallets.length; i++) {
      address distWallet = distWallets[i];
      uint256 value = getDistributedValue(distWallet);
      _transfer(walletThis, distWallet, value);
      _approve(walletThis, distWallet, 0);
      emit TransferredDistributedValue(distWallet, value);
    }
  }

  function isExcludedFromTax(address wallet) public view returns (bool) {
    return _exclusionsTax.contains(wallet);
  }

  function isExcludedFromBuyLock(address wallet) public view returns (bool) {
    return _exclusionsBuyLock.contains(wallet);
  }

  function isExcludedFromSaleLock(address wallet) public view returns (bool) {
    return _exclusionsSaleLock.contains(wallet);
  }

  function _isBuy(address from) internal view returns (bool) {
    return (from == walletRouterPair || from == walletRouter);
  }

  function _isSale(address to) internal view returns (bool) {
    return (to == walletRouterPair || to == walletRouter);
  }

  /**
   * This function determines the right target tax rate that is to use
   * in a transfer between the two given wallets
   * In the special case STATE_PRESALE we disable taxing
   */
  function _getTargetTaxRate(address from, address to)
    internal
    view
    returns (uint8)
  {
    require(from != to, ERROR_TRANSFER_SAME_ADDRESS);
    require(from != ADDRESS_NULL, ERROR_NOTRANSFER_FROM_NULL);
    require(to != ADDRESS_NULL, ERROR_NOTRANSFER_TO_NULL);

    uint8 state = getState();
    if (
      state == STATE_PRESALE || isExcludedFromTax(from) || isExcludedFromTax(to)
    ) {
      return 0;
    }

    if (_isBuy(from)) {
      return taxRateBuy;
    } else if (_isSale(to)) {
      return taxRateSale;
    } else {
      return taxRateTransfer;
    }
  }

  /**
   * this function reduces the given amount by the given reductionRate
   * and returns the resulting value and the value it was reduced
   * as a tupel
   *
   * the resulted value is always calculated by ignoring the remainder
   * and the reduced amount is always the difference to the given value
   */
  function _reduceAmount(uint256 amount, uint8 reductionRate)
    internal
    pure
    returns (uint256 reducedAmount, uint256 reductionAmount)
  {
    require(
      amount >= 0 && reductionRate >= 0 && reductionRate <= 100,
      ERROR_REDUCTION_RATE_OUT_OF_BOUNDS
    );

    if (reductionRate > 0) {
      reducedAmount = amount.mul(100 - reductionRate).div(100);
      reductionAmount = amount.sub(reducedAmount);
    } else {
      reducedAmount = amount;
      reductionAmount = 0;
    }
  }

  /**
   * this function distributes the given value according to the configured rules
   * 1. burn desired value
   * 2. transfer liquidity
   * 3. transfer net amount
   * 4. claim distribution wallet values by adding allowance to self-transfer
   */
  function _distributeTaxValues(address from, uint256 taxValue) internal {
    uint256 transferValue = taxValue;

    // burn
    uint256 burnValue = 0;
    (, burnValue) = _reduceAmount(taxValue, distRateBurn);
    super._burn(from, burnValue);
    transferValue -= burnValue;

    // transfer liquidity
    uint256 liqValue = 0;
    (, liqValue) = _reduceAmount(taxValue, distRateLiquidity);
    _claimLiquidity(from, liqValue);
    transferValue -= liqValue;

    // transfer remaining amount
    super._transfer(from, walletThis, transferValue);

    // allow split wallets to do transfer of desired amounts
    for (uint i = 0; i < distWallets.length; i++) {
      uint256 part = 0;
      (, part) = _reduceAmount(taxValue, distRates[i]);
      _approve(
        walletThis,
        distWallets[i],
        allowance(walletThis, distWallets[i]).add(part)
      );
    }
  }

  function _claimLiquidity(address from, uint256 value) internal {
    _transfer(from, walletThis, value);
    claimedLiquidity = claimedLiquidity.add(value);

    emit ClaimedForLiquidity(from, value);
  }

  function _excludeTaxDistributionWallets() internal {
    for (uint256 i = 0; i < distWallets.length; i++) {
      _exclusionsTax.add(distWallets[i]);
    }
  }

  function _removeTaxDistributionWalletExclusions() internal {
    for (uint256 i = 0; i < distWallets.length; i++) {
      _exclusionsTax.remove(distWallets[i]);
    }
  }

  /*----------------------------------------------------------------*/
}

uint256 constant SUPPLY_INITIAL = 100000000000;

uint8 constant TAX_RATE_BUY = 10;

uint8 constant TAX_RATE_SALE = 15;

uint8 constant TAX_RATE_TRANSFER = 10;

uint8 constant RATE_SWAP = 25;

// 0.25 %
uint8 constant DIST_RATE_BURN = 40;

uint8 constant DIST_RATE_LIQUIDITY = 20;

uint8 constant DIST_RATE_1 = 20;

uint8 constant DIST_RATE_2 = 10;

uint8 constant DIST_RATE_3 = 5;

uint8 constant DIST_RATE_4 = 5;

uint8 constant RATE_CIRCULATION = 30;

string constant TOKENNAME = "Neuraless Token";

string constant TOKENSYMBOL = "NRLS";

address constant WALLET_OWNER = 0xdEd4918ffBA8de9E02d7022a4C8f483680116dAC;

address constant WALLET_DEVELOPMENT = 0x984B025D584D581D5da497353E3484e577C0cBc0;

address constant WALLET_MARKETING = 0x1FCED0A5b5267D1EF6b7FC4619f2715bc250FE78;

address constant WALLET_PROJECTDEVELOPMENT = 0xA05E1E1C853a5B74A3740e053c51cA6e1aDA7136;

address constant WALLET_RESERVES = 0x32EEBE4510C5A7fc62ea3F4E69cAb7BF0EF90960;

address constant WALLET_TEAM = 0x6B8178D017e5207e667F680481d41c8429F8471d;

/// @custom:security-contact [email protected]
contract NRLS is TaxableToken {
  uint8[] private RATES = [RATE_CIRCULATION, TAX_RATE_BUY, TAX_RATE_SALE, TAX_RATE_TRANSFER, RATE_SWAP, DIST_RATE_BURN, DIST_RATE_LIQUIDITY];
  uint8[] private DIST_RATES = [DIST_RATE_1, DIST_RATE_2, DIST_RATE_3, DIST_RATE_4];

  address payable[] private DIST_WALLETS = [
    payable(WALLET_MARKETING),
    payable(WALLET_PROJECTDEVELOPMENT),
    payable(WALLET_TEAM),
    payable(WALLET_RESERVES)
  ];

  constructor()
    TaxableToken(
      TOKENNAME,
      TOKENSYMBOL,
      SUPPLY_INITIAL,
      WALLET_OWNER,
      RATES,
      DIST_RATES,
      DIST_WALLETS,
      ADDRESS_PANCAKE_ROUTER_PROD
    )
  {}
}