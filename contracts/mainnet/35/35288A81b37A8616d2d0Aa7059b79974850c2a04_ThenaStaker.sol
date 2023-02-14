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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

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
}

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
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

pragma solidity 0.8.13;

interface IFeeConfig {
    struct FeeCategory {
        uint256 total;
        uint256 peanut;
        uint256 call;
        uint256 strategist;
        string label;
        bool active;
    }
    function getFees(address strategy) external view returns (FeeCategory memory);
    function stratFeeId(address strategy) external view returns (uint256);
    function setStratFeeId(uint256 feeId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IMinter {
    function _rewards_distributor() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IRewardPool {
    function notifyRewardAmount() external;

    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getReward() external;

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ISolidlyGauge {
    function getReward(uint256 tokenId, address[] memory rewards) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ISolidlyRouter {
    // Routes
    struct Routes {
        address from;
        address to;
        bool stable;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        bool stable, 
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable, 
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        bool stable,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokensSimple(
        uint amountIn, 
        uint amountOutMin, 
        address tokenFrom, 
        address tokenTo,
        bool stable, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        Routes[] memory route, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountOut(uint amountIn, address tokenIn, address tokenOut) external view returns (uint amount, bool stable);

    function getAmountsOut(uint amountIn, Routes[] memory routes) external view returns (uint[] memory amounts);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired
    ) external view returns (uint amountA, uint amountB, uint liquidity);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IVeDist {
    function claim(uint256 tokenId) external returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IVeToken {
    function create_lock(uint256 _value, uint256 _lockDuration) external returns (uint256 _tokenId);
    function increase_amount(uint256 tokenId, uint256 value) external;
    function increase_unlock_time(uint256 tokenId, uint256 duration) external;
    function withdraw(uint256 tokenId) external;
    function balanceOfNFT(uint256 tokenId) external view returns (uint256 balance);
    function locked(uint256 tokenId) external view returns (uint256 amount, uint256 endTime);
    function token() external view returns (address);
    function merge(uint _from, uint _to) external;
    function transferFrom(address _from, address _to, uint _tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IVoter {
    function vote(uint256 tokenId, address[] calldata poolVote, uint256[] calldata weights) external;
    function whitelist(address token, uint256 tokenId) external;
    function reset(uint256 tokenId) external;
    function gauges(address lp) external view returns (address);
    function _ve() external view returns (address);
    function minter() external view returns (address);
    function external_bribes(address _lp) external view returns (address);
    function internal_bribes(address _lp) external view returns (address);
    function votes(uint256 id, address lp) external view returns (uint256);
    function poolVote(uint256 id, uint256 index) external view returns (address);
    function lastVoted(uint256 id) external view returns (uint256);
    function weights(address lp) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IWrappedBribeFactory {
    function oldBribeToNew(address _gauge) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChamTHESolidManager is Ownable, Pausable {
    using SafeERC20 for IERC20;

    /**
     * @dev Peanutfi Contracts:
     * {keeper} - Address to manage a few lower risk features of the strat..
     */
    address public keeper;
    address public voter;
    address public taxWallet;

    event NewKeeper(address oldKeeper, address newKeeper);
    event NewVoter(address oldVoter, address newVoter);
    event NewTaxWallet(address oldTaxWallet, address newTaxWallet);

    /**
     * @dev Initializes the base strategy.
     * @param _keeper address to use as alternative owner.
     */
    constructor(
        address _keeper,
        address _voter,
        address _taxWallet
    ) {
        keeper = _keeper;
        voter = _voter;
        taxWallet = _taxWallet;
    }

    // Checks that caller is either owner or keeper.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "ChamTHESolidManager: MANAGER_ONLY");
        _;
    }

    // Checks that caller is either owner or keeper.
    modifier onlyVoter() {
        require(msg.sender == voter, "ChamTHESolidManager: VOTER_ONLY");
        _;
    }

    /**
     * @dev Updates address of the strat keeper.
     * @param _keeper new keeper address.
     */
    function setKeeper(address _keeper) external onlyManager {
        emit NewKeeper( keeper, _keeper);
        keeper = _keeper;
    }

    function setVoter(address _voter) external onlyManager {
        emit NewVoter(voter, _voter);
        voter = _voter;
    }

    function setTaxWallet(address _taxWallet) external onlyManager {
        emit NewTaxWallet(taxWallet, _taxWallet);
        taxWallet = _taxWallet;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ChamTHESolidManager.sol";
import "../interfaces/IVoter.sol";
import "../interfaces/IVeToken.sol";
import "../interfaces/IVeDist.sol";
import "../interfaces/IMinter.sol";

contract ChamTHESolidStaker is ERC20, ChamTHESolidManager, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Addresses used
    IVoter public solidVoter;
    IVeToken public ve;
    IVeDist public veDist;

    // Want token and our NFT Token ID
    IERC20 public want;
    uint256 public tokenId;

    // Max Lock time, Max variable used for reserve split and the reserve rate.
    uint16 public constant MAX = 10000;
    uint256 public constant MAX_RATE = 1e18;
    // Vote weight decays linearly over time. Lock time cannot be more than `MAX_LOCK` (2 years).
    uint256 public constant MAX_LOCK = 365 days * 2;
    uint256 public reserveRate;
    bool public isAutoIncreaseLock = true;

    bool public enabledPenaltyFee = false;
    uint256 public penaltyRate = 0.5e18; // 0.5
    uint256 public maxBurnRate = 50; // 0.5%
    uint256 public maxPegReserve = 0.8e18;

    // Our on chain events.
    event CreateLock(
        address indexed user,
        uint256 veTokenId,
        uint256 amount,
        uint256 unlockTime
    );
    event Release(address indexed user, uint256 veTokenId, uint256 amount);
    event AutoIncreaseLock(bool _enabled);
    event EnabledPenaltyFee(bool _enabled);
    event IncreaseTime(
        address indexed user,
        uint256 veTokenId,
        uint256 unlockTime
    );
    event DepositWant(uint256 amount);
    event Withdraw(uint256 amount);
    event ClaimVeEmissions(
        address indexed user,
        uint256 veTokenId,
        uint256 amount
    );
    event UpdatedReserveRate(uint256 newRate);
    event SetMaxBurnRate(uint256 oldRate, uint256 newRate);
    event SetMaxPegReserve(uint256 oldValue, uint256 newValue);
    event SetPenaltyRate(uint256 oldValue, uint256 newValue);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reserveRate,
        address _solidVoter,
        address _keeper,
        address _voter,
        address _taxWallet
    ) ERC20(_name, _symbol) ChamTHESolidManager(_keeper, _voter, _taxWallet) {
        reserveRate = _reserveRate;
        solidVoter = IVoter(_solidVoter);
        ve = IVeToken(solidVoter._ve());
        want = IERC20(ve.token());
        IMinter _minter = IMinter(solidVoter.minter());
        veDist = IVeDist(_minter._rewards_distributor());
        want.safeApprove(address(ve), type(uint256).max);
    }

    // Deposit all want for a user.
    function depositAll() external {
        _deposit(want.balanceOf(msg.sender));
    }

    // Deposit an amount of want.
    function deposit(uint256 _amount) external {
        _deposit(_amount);
    }

    // Internal: Deposits Want and mint CeWant, checks for ve increase opportunities first.
    function _deposit(uint256 _amount) internal nonReentrant whenNotPaused {
        lock();
        uint256 _balanceBefore = balanceOfWant();
        want.safeTransferFrom(msg.sender, address(this), _amount);
        _amount = balanceOfWant() - _balanceBefore; // Additional check for deflationary tokens.

        if (_amount > 0) {
            _mint(msg.sender, _amount);
            emit DepositWant(totalWant());
        }
    }

    // Deposit more in ve and up lock_time.
    function lock() public {
        if (totalWant() > 0) {
            (, , bool shouldIncreaseLock) = lockInfo();
            if (balanceOfWant() > requiredReserve()) {
                uint256 availableBalance = balanceOfWant() - requiredReserve();
                ve.increase_amount(tokenId, availableBalance);
            }
            // Extend max lock
            if (shouldIncreaseLock) ve.increase_unlock_time(tokenId, MAX_LOCK);
        }
    }

    // Withdraw capable if we have enough Want in the contract.
    function withdraw(uint256 _amount) external {
        require(
            _amount <= withdrawableBalance(),
            "ChamTHEStaker: INSUFFICIENCY_AMOUNT_OUT"
        );

        _burn(msg.sender, _amount);
        if (enabledPenaltyFee) {
            uint256 maxAmountBurning = ((totalSupply() + _amount) *
                maxBurnRate) / MAX;
            require(
                _amount <= maxAmountBurning,
                "ChamTHEStaker: Over max burning amount"
            );

            uint256 penaltyAmount = calculatePenaltyFee(_amount);
            if (penaltyAmount > 0) {
                _amount = _amount - penaltyAmount;

                // tax
                uint256 taxAmount = penaltyAmount / 2;
                if (taxAmount > 0) _mint(taxWallet, taxAmount);

                // transfer into a dead address
                uint256 burnAmount = penaltyAmount - taxAmount;
                if (burnAmount > 0) _mint(0x000000000000000000000000000000000000dEaD, burnAmount);
            }
        }

        want.safeTransfer(msg.sender, _amount);
        emit Withdraw(totalWant());
    }

    // Total Want in ve contract and CeVe contract.
    function totalWant() public view returns (uint256) {
        return balanceOfWant() + balanceOfWantInVe();
    }

    // Our required Want held in the contract to enable withdraw capabilities.
    function requiredReserve() public view returns (uint256 reqReserve) {
        // We calculate allocation for reserve of the total staked in Ve.
        reqReserve = (balanceOfWantInVe() * reserveRate) / MAX;
    }

    // Calculate how much 'want' is held by this contract
    function balanceOfWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    // What is our end lock and seconds remaining in lock?
    function lockInfo()
        public
        view
        returns (
            uint256 endTime,
            uint256 secondsRemaining,
            bool shouldIncreaseLock
        )
    {
        (, endTime) = ve.locked(tokenId);
        uint256 unlockTime = ((block.timestamp + MAX_LOCK) / 1 weeks) * 1 weeks;
        secondsRemaining = endTime > block.timestamp
            ? endTime - block.timestamp
            : 0;
        shouldIncreaseLock = isAutoIncreaseLock && unlockTime > endTime;
    }

    // Withdrawable Balance for users
    function withdrawableBalance() public view returns (uint256) {
        return balanceOfWant();
    }

    // How many want we got earning?
    function balanceOfWantInVe() public view returns (uint256 wants) {
        (wants, ) = ve.locked(tokenId);
    }

    // Claim veToken emissions and increases locked amount in veToken
    function claimVeEmissions() public virtual {
        uint256 _amount = veDist.claim(tokenId);
        emit ClaimVeEmissions(msg.sender, tokenId, _amount);
    }

    // Reset current votes
    function resetVote() external onlyVoter {
        solidVoter.reset(tokenId);
    }

    // Create a new veToken if none is assigned to this address
    function createLock(
        uint256 _amount,
        uint256 _lock_duration
    ) external onlyManager {
        require(tokenId == 0, "ChamTHEStaker: ASSIGNED");
        require(_amount > 0, "ChamTHEStaker: ZERO_AMOUNT");

        want.safeTransferFrom(address(msg.sender), address(this), _amount);
        tokenId = ve.create_lock(_amount, _lock_duration);
        _mint(msg.sender, _amount);

        emit CreateLock(msg.sender, tokenId, _amount, _lock_duration);
    }

    // Release expired lock of a veToken owned by this address
    function release() external onlyOwner {
        (uint endTime, , ) = lockInfo();
        require(endTime <= block.timestamp, "ChamTHEStaker: LOCKED");
        ve.withdraw(tokenId);

        emit Release(msg.sender, tokenId, balanceOfWant());
    }

    // Whitelist new token
    function whitelist(address _token) external onlyManager {
        solidVoter.whitelist(_token, tokenId);
    }

    // Adjust reserve rate
    function adjustReserve(uint256 _rate) external onlyOwner {
        // validation from 15-50%
        require(
            _rate >= 1500 && _rate <= 5000,
            "ChamTHEStaker: RATE_OUT_OF_RANGE"
        );
        reserveRate = _rate;
        emit UpdatedReserveRate(_rate);
    }

    // Enable/Disable Penalty Fee
    function setEnabledPenaltyFee(bool _enabled) external onlyOwner {
        enabledPenaltyFee = _enabled;
        emit EnabledPenaltyFee(_enabled);
    }

    function setPenaltyRate(uint256 _rate) external onlyOwner {
        // validation from 0-0.5
        require(_rate <= MAX_RATE / 2, "ChamTHEStaker: RATE_OUT_OF_RANGE");
        emit SetPenaltyRate(penaltyRate, _rate);
        penaltyRate = _rate;
    }

    // Enable/Disable auto increase lock
    function setAutoIncreaseLock(bool _enabled) external onlyOwner {
        isAutoIncreaseLock = _enabled;
        emit AutoIncreaseLock(_enabled);
    }

    function setMaxBurnRate(uint256 _rate) external onlyOwner {
        // validation from 0.5-100%
        require(
            _rate >= 50 && _rate <= MAX,
            "ChamTHEStaker: RATE_OUT_OF_RANGE"
        );
        emit SetMaxBurnRate(maxBurnRate, _rate);
        maxBurnRate = _rate;
    }

    function setMaxPegReserve(uint256 _value) external onlyOwner {
        // validation from 0.6-1
        require(
            _value >= 0.6e18 && _value <= 1e18,
            "ChamTHEStaker: VALUE_OUT_OF_RANGE"
        );
        emit SetMaxPegReserve(maxPegReserve, _value);
        maxPegReserve = _value;
    }

    // Pause deposits
    function pause() public onlyManager {
        _pause();
        want.safeApprove(address(ve), 0);
    }

    // Unpause deposits
    function unpause() external onlyManager {
        _unpause();
        want.safeApprove(address(ve), type(uint256).max);
    }

    // Confirmation required for receiving veToken to smart contract
    function onERC721Received(
        address operator,
        address from,
        uint _tokenId,
        bytes calldata data
    ) external view returns (bytes4) {
        operator;
        from;
        _tokenId;
        data;
        require(msg.sender == address(ve), "ChamTHEStaker: VE_ONLY");
        return
            bytes4(keccak256("onERC721Received(address,address,uint,bytes)"));
    }

    function calculatePenaltyFee(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 pegReserve = (balanceOfWant() * MAX_RATE) / requiredReserve();
        uint256 penaltyAmount = 0;
        if (pegReserve < maxPegReserve) {
            // penaltyPercent = 0.5 x (1 - pegReserve) * 100%
            penaltyAmount = (_amount * penaltyRate * (MAX_RATE - pegReserve)) / (MAX_RATE * MAX_RATE);
        }
        return penaltyAmount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ChamTHESolidStaker.sol";
import "../interfaces/IRewardPool.sol";
import "../interfaces/IWrappedBribeFactory.sol";
import "../interfaces/ISolidlyRouter.sol";
import "../interfaces/IFeeConfig.sol";
import "../interfaces/ISolidlyGauge.sol";

contract ThenaStaker is ERC20, ChamTHESolidStaker {
    using SafeERC20 for IERC20;

    // Needed addresses
    IRewardPool public chamTHERewardPool;
    address[] public activeVoteLps;
    ISolidlyRouter public router;
    address public coFeeRecipient;
    IFeeConfig public coFeeConfig;
    address public native;

    // Voted Gauges
    struct Gauges {
        address bribeGauge;
        address feeGauge;
        address[] bribeTokens;
        address[] feeTokens;
    }

    // Mapping our `reward token` to `want token` in routes for Router
    ISolidlyRouter.Routes[] public thenaToNativeRoute;
    mapping(address => ISolidlyRouter.Routes[]) public routes;
    mapping(address => bool) public lpInitialized;
    mapping(address => Gauges) public gauges;

    // Events
    event SetChamTHERewardPool(address oldPool, address newPool);
    event SetRouter(address oldRouter, address newRouter);
    event SetBribeFactory(address oldFactory, address newFactory);
    event SetFeeRecipient(address oldRecipient, address newRecipient);
    event SetFeeId(uint256 id);
    event AddedGauge(
        address gauge,
        address feeGauge,
        address[] bribeTokens,
        address[] feeTokens
    );
    event AddedRewardToken(address token);
    event RewardsHarvested(uint256 amount);
    event Voted(address[] votes, uint256[] weights);
    event ChargedFees(uint256 callFees, uint256 coFees, uint256 strategistFees);
    event MergeVe(address indexed user, uint256 veTokenId, uint256 amount);
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reserveRate,
        address _solidVoter,
        address[] memory _manager,
        address _chamTHERewardPool,
        address _coFeeRecipient,
        address _coFeeConfig,
        address _router,
        ISolidlyRouter.Routes[] memory _thenaToNativeRoute
    )
        ChamTHESolidStaker(
            _name,
            _symbol,
            _reserveRate,
            _solidVoter,
            _manager[0],
            _manager[1],
            _manager[2]
        )
    {
        chamTHERewardPool = IRewardPool(_chamTHERewardPool);
        router = ISolidlyRouter(_router);
        coFeeRecipient = _coFeeRecipient;
        coFeeConfig = IFeeConfig(_coFeeConfig);

        native = _thenaToNativeRoute[_thenaToNativeRoute.length - 1].to;
        for (uint i; i < _thenaToNativeRoute.length; i++) {
            thenaToNativeRoute.push(_thenaToNativeRoute[i]);
        }
    }

    // Vote information
    function voteInfo()
        external
        view
        returns (
            address[] memory lpsVoted,
            uint256[] memory votes,
            uint256 lastVoted
        )
    {
        uint256 len = activeVoteLps.length;
        lpsVoted = new address[](len);
        votes = new uint256[](len);
        for (uint i; i < len; i++) {
            lpsVoted[i] = solidVoter.poolVote(tokenId, i);
            votes[i] = solidVoter.votes(tokenId, lpsVoted[i]);
        }
        lastVoted = solidVoter.lastVoted(tokenId);
    }

    // Claim veToken emissions and increases locked amount in veToken
    function claimVeEmissions() public override {
        uint256 _amount = veDist.claim(tokenId);
        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(chamTHERewardPool), gap);
            chamTHERewardPool.notifyRewardAmount();
        }
        emit ClaimVeEmissions(msg.sender, tokenId, _amount);
    }

    // vote for emission weights
    function vote(
        address[] calldata _tokenVote,
        uint256[] calldata _weights,
        bool _withHarvest
    ) external onlyVoter {
        // Check to make sure we set up our rewards
        for (uint i; i < _tokenVote.length; i++) {
            require(lpInitialized[_tokenVote[i]], "Staker: TOKEN_VOTE_INVALID");
        }

        if (_withHarvest) harvest();

        activeVoteLps = _tokenVote;
        // We claim first to maximize our voting power.
        claimVeEmissions();
        solidVoter.vote(tokenId, _tokenVote, _weights);
        emit Voted(_tokenVote, _weights);
    }

    // Add gauge
    function addGauge(
        address _lp,
        address[] calldata _bribeTokens,
        address[] calldata _feeTokens
    ) external onlyManager {
        address gauge = solidVoter.gauges(_lp);
        gauges[_lp] = Gauges(
            solidVoter.external_bribes(gauge),
            solidVoter.internal_bribes(gauge),
            _bribeTokens,
            _feeTokens
        );
        lpInitialized[_lp] = true;
        emit AddedGauge(
            solidVoter.external_bribes(_lp),
            solidVoter.internal_bribes(_lp),
            _bribeTokens,
            _feeTokens
        );
    }

    // Delete a reward token
    function deleteRewardToken(address _token) external onlyManager {
        delete routes[_token];
    }

    // Add multiple reward tokens
    function addMultipleRewardTokens(
        ISolidlyRouter.Routes[][] calldata _routes
    ) external onlyManager {
        for (uint i; i < _routes.length; i++) {
            addRewardToken(_routes[i]);
        }
    }

    // Add a reward token
    function addRewardToken(
        ISolidlyRouter.Routes[] calldata _route
    ) public onlyManager {
        require(
            _route[0].from != address(want),
            "Staker: ROUTE_FROM_IS_TOKEN_WANT"
        );
        require(
            _route[_route.length - 1].to == address(want),
            "Staker: ROUTE_TO_NOT_TOKEN_WANT"
        );
        for (uint i; i < _route.length; i++) {
            routes[_route[0].from].push(_route[i]);
        }
        IERC20(_route[0].from).safeApprove(address(router), 0);
        IERC20(_route[0].from).safeApprove(address(router), type(uint256).max);
        emit AddedRewardToken(_route[0].from);
    }

    function getRewards(
        address _bribe,
        address[] calldata _tokens,
        ISolidlyRouter.Routes[][] calldata _routes
    ) external nonReentrant onlyManager {
        uint256 before = balanceOfWant();
        ISolidlyGauge(_bribe).getReward(tokenId, _tokens);
        for (uint i; i < _routes.length; i++) {
            address tokenFrom = _routes[i][0].from;
            require(
                _routes[i][_routes[i].length - 1].to == address(want),
                "Staker: ROUTE_TO_NOT_TOKEN_WANT"
            );
            require(
                tokenFrom != address(want),
                "Staker: ROUTE_FROM_IS_TOKEN_WANT"
            );
            uint256 tokenBal = IERC20(tokenFrom).balanceOf(address(this));
            if (tokenBal > 0) {
                IERC20(tokenFrom).safeApprove(address(router), 0);
                IERC20(tokenFrom).safeApprove(
                    address(router),
                    type(uint256).max
                );
                router.swapExactTokensForTokens(
                    tokenBal,
                    0,
                    _routes[i],
                    address(this),
                    block.timestamp
                );
            }
        }
        uint256 rewardBal = balanceOfWant() - before;
        _chargeFeesAndMint(rewardBal);
    }

    // claim owner rewards such as trading fees and bribes from gauges swap to thena, notify reward pool
    function harvest() public {
        uint256 before = balanceOfWant();
        for (uint i; i < activeVoteLps.length; i++) {
            Gauges memory _gauges = gauges[activeVoteLps[i]];
            ISolidlyGauge(_gauges.bribeGauge).getReward(
                tokenId,
                _gauges.bribeTokens
            );
            ISolidlyGauge(_gauges.feeGauge).getReward(
                tokenId,
                _gauges.feeTokens
            );

            for (uint j; j < _gauges.bribeTokens.length; ++j) {
                address bribeToken = _gauges.bribeTokens[j];
                uint256 tokenBal = IERC20(bribeToken).balanceOf(address(this));
                if (tokenBal > 0 && bribeToken != address(want))
                    router.swapExactTokensForTokens(
                        tokenBal,
                        0,
                        routes[bribeToken],
                        address(this),
                        block.timestamp
                    );
            }

            for (uint k; k < _gauges.feeTokens.length; ++k) {
                address feeToken = _gauges.feeTokens[k];
                uint256 tokenBal = IERC20(feeToken).balanceOf(address(this));
                if (tokenBal > 0 && feeToken != address(want))
                    router.swapExactTokensForTokens(
                        tokenBal,
                        0,
                        routes[feeToken],
                        address(this),
                        block.timestamp
                    );
            }
        }
        uint256 rewardBal = balanceOfWant() - before;
        _chargeFeesAndMint(rewardBal);
    }

    function _chargeFeesAndMint(uint256 _rewardBal) internal {
        // Charge our fees here since we send CeThena to reward pool
        IFeeConfig.FeeCategory memory fees = coFeeConfig.getFees(address(this));
        uint256 feeBal = (_rewardBal * fees.total) / 1e18;
        if (feeBal > 0) {
            IERC20(want).safeApprove(address(router), feeBal);
            uint256[] memory amounts = router.swapExactTokensForTokens(
                feeBal,
                0,
                thenaToNativeRoute,
                address(coFeeRecipient),
                block.timestamp
            );
            IERC20(want).safeApprove(address(router), 0);
            emit ChargedFees(0, amounts[amounts.length - 1], 0);
        }

        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(chamTHERewardPool), gap);
            chamTHERewardPool.notifyRewardAmount();
            emit RewardsHarvested(gap);
        }
    }

    // Set our reward Pool to send our earned chamTHE
    function setChamTHERewardPool(address _rewardPool) external onlyOwner {
        emit SetChamTHERewardPool(address(chamTHERewardPool), _rewardPool);
        chamTHERewardPool = IRewardPool(_rewardPool);
    }

    // Set fee id on fee config
    function setFeeId(uint256 id) external onlyManager {
        emit SetFeeId(id);
        coFeeConfig.setStratFeeId(id);
    }

    // Set fee recipient
    function setCoFeeRecipient(address _feeRecipient) external onlyOwner {
        emit SetFeeRecipient(address(coFeeRecipient), _feeRecipient);
        coFeeRecipient = _feeRecipient;
    }

    // Set our router to exchange our rewards, also update new thenaToNative route.
    function setRouterAndRoute(
        address _router,
        ISolidlyRouter.Routes[] calldata _route
    ) external onlyOwner {
        emit SetRouter(address(router), _router);
        for (uint i; i < _route.length; i++) thenaToNativeRoute.pop();
        for (uint i; i < _route.length; i++) thenaToNativeRoute.push(_route[i]);
        router = ISolidlyRouter(_router);
    }

    function mergeVe(uint256 _tokenId) external {
        ve.merge(_tokenId, tokenId);
        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(chamTHERewardPool), gap);
            chamTHERewardPool.notifyRewardAmount();
        }
        emit MergeVe(msg.sender, _tokenId, gap);
    }
}