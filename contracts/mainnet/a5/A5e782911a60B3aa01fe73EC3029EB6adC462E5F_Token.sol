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

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IDividendTracker.sol";
import "./interfaces/IToken.sol";
import "./interfaces/IOwnable.sol";
import "./libs/IterableMapping.sol";

contract DividendTracker is ERC20, IDividendTracker {
    using SafeERC20 for IERC20;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    
    address public token;
    address public payOutToken;
    bool public dividendsPaused;
        
    uint256 private minBalanceForDividends;
    uint256 public lastProcessedIndex;
    uint256 public totalDividendsDistributed;

    uint256 internal constant magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
    
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;
    
    mapping(address => bool) public excludedFromDividends;
    mapping(address => bool) public autoReinvest;   
    mapping(address => uint256) public lastClaimTimes;    

    // -------------------------------------- CONSTRUCT ----------------------------------------

    constructor(
        address token_,
        address payOutToken_,
        uint256 minBalanceForDividends_,        
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        token = token_;
        
        payOutToken = payOutToken_;
        minBalanceForDividends = minBalanceForDividends_; 
        
        excludedFromDividends[tx.origin] = true;
        excludedFromDividends[msg.sender] = true;
        excludedFromDividends[address(0)] = true;
        excludedFromDividends[address(this)] = true;       
    }

    // -------------------------------------- ADMIN -----------------------------------------

    // set payout token, if zero address provided payout will be in eth
    function setPayoutToken(address payOutToken_) public onlyOwner {
        payOutToken = payOutToken_;
        emit SetPayoutToken(payOutToken);
    }
    
    // set min balance of tokens for account for receiving dividends
    function setMinBalanceForDividends(uint256 minBalanceForDividends_) public onlyOwner {
        minBalanceForDividends = minBalanceForDividends_;
        emit SetMinBalanceForDividends(minBalanceForDividends_);
    }

    // pause dividends distribution
    function setDividendsPaused(bool state_) external onlyOwner {
        require(dividendsPaused != state_);
        dividendsPaused = state_;
        emit DividendsPaused(state_);
    }

    // -------------------------------------- VIEWS -----------------------------------------

    // aggregated data for contract and account (by defauld provide ZERO address to get only contract data)
    // use it on UI to get all data in single request
    function aggregatedData(address account_) public view returns (
            // contract data 
            uint256 _minBalanceForDividends,
            address _payOutToken,  
            bool _dividendsPaused,              
            uint256 _holdersCount, 
            uint256 _totalDividendsDistributed,
            // account data 
            uint256 _total,
            uint256 _withdrawable,
            uint256 _withdrawn,
            bool _excluded,
            bool _autoReinvest,  
            int256 _currentIndex,
            int256 _iterationsUntil,
            uint256 _lastClaimTime            
        ) {
        // contract data 
        _minBalanceForDividends = minBalanceForDividends;    
        _payOutToken = payOutToken;
        _dividendsPaused = dividendsPaused;       
        _holdersCount = getHoldersCount();
        _totalDividendsDistributed = totalDividendsDistributed;

        // account data 
        _total = _accumulativeDividends(account_);
        _withdrawable = _withdrawableDividends(account_);
        _withdrawn = withdrawnDividends[account_];
        _excluded = excludedFromDividends[account_];
        _autoReinvest = autoReinvest[account_];
        _currentIndex = tokenHoldersMap.getIndexOfKey(account_);
        _iterationsUntil = -1;
        
        if (_currentIndex >= 0) {
            if (uint256(_currentIndex) > lastProcessedIndex) {
                _iterationsUntil = _currentIndex - int256(lastProcessedIndex);
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length - lastProcessedIndex : 0;
                _iterationsUntil = _currentIndex + int256(processesUntilEndOfArray);
            }
        }        
        _lastClaimTime = lastClaimTimes[account_];
    }

    // total number of dividends recipients 
    function getHoldersCount() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    // get holder account at specified 
    function getAccountAtIndex(uint256 index_) public view returns (address) {
        return tokenHoldersMap.getKeyAtIndex(index_);
    }

    // -------------------------------------- PUBLIC -----------------------------------------

    // withdraw user dividends
    function withdraw() public notPaused {
        _claim(payable(msg.sender), false);
    }

    // reinvest user dividends
    function reinvest() public notPaused {
        _claim(payable(msg.sender), true);
    }

    // set user auto reinvest, if enabled dividends will be converted to tokens on process, otherwise user will receive eth or payout tokens
    function setAutoReinvest(bool state_) external {
        require(autoReinvest[msg.sender] != state_, "Already set");
        autoReinvest[msg.sender] = state_;        
        emit SetAutoReinvest(msg.sender, state_);    
    }

    // process users dividends with max provided gas
    function process(uint256 gas) public returns (uint256 iterations_, uint256 claims_, uint256 lastProcessedIndex_) {
        uint256 holdersCount = getHoldersCount();

        if (holdersCount == 0 || dividendsPaused) {
            return (0, 0, lastProcessedIndex);
        }

        lastProcessedIndex_ = lastProcessedIndex;
        uint256 gasUsed;
        uint256 gasLeft = gasleft();       

        while (gasUsed < gas && iterations_ < holdersCount) {
            lastProcessedIndex_++;

            if (lastProcessedIndex_ >= holdersCount) {
                lastProcessedIndex_ = 0;
            }                 
            
            address account = tokenHoldersMap.keys[lastProcessedIndex_];            
            
            if (_claim(account, autoReinvest[account]) != 0) {
                claims_++;
            }                       

            iterations_++;

            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed += gasLeft - newGasLeft;
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndex = lastProcessedIndex_;
        
        emit Processed(iterations_, claims_, lastProcessedIndex_, tx.origin );
    }
    
    receive() external payable {
        require(totalSupply() != 0, "Not allowed");

        if (msg.value != 0) {
            magnifiedDividendPerShare += msg.value * magnitude / totalSupply();
            totalDividendsDistributed += msg.value;
            emit DividendsDistributed(msg.sender, msg.value);            
        }
    }
         
    // -------------------------------------- RESTRICTED ----------------------------------------
    
    function setExcludedFromDividends(address account_, bool state_) external onlyToken {
        if (state_) {
            excludedFromDividends[account_] = true;
            _setBalance(account_, 0);
            tokenHoldersMap.remove(account_);
        } else {
            excludedFromDividends[account_] = false;              
        }        
        emit ExcludedFromDividends(account_, state_);    
    }

    function setBalance(address account, uint256 newBalance) external onlyToken {
        if (excludedFromDividends[account]) return;
        
        if (newBalance >= minBalanceForDividends) {
            tokenHoldersMap.set(account, newBalance);
            _setBalance(account, newBalance);            
        } else {            
            tokenHoldersMap.remove(account);
            _setBalance(account, 0);
        }        
    }

    // -------------------------------------- INTERNAL ----------------------------------------

    function _withdrawableDividends(address account_) public view returns (uint256) {
        return _accumulativeDividends(account_) - withdrawnDividends[account_];
    }

    function _accumulativeDividends(address account_) internal view returns (uint256) {
        return uint256(int256(magnifiedDividendPerShare * balanceOf(account_)) + magnifiedDividendCorrections[account_]) / magnitude;            
    }

    function _claim(address account_, bool reinvest_) internal returns (uint256 _amount) {        
        _amount = _withdrawableDividends(account_);                
        if (_amount == 0) return 0;

        IUniswapV2Router02 uniswapV2Router = IToken(token).uniswapV2Router();
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        
        // reinvest
        if (reinvest_) {
            path[1] = token;
            try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amount }(0, path, account_, block.timestamp) {                
            } catch {
                return 0;
            }
            emit Reinvested(account_, _amount);  
        } 
        // withdraw
        else {
            if (payOutToken == address(0)) {
                (bool success,) = payable(account_).call{ value: _amount, gas: 3000 }("");
                if (!success) return 0;
            } else {  
                path[1] = payOutToken;
                try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amount }(0, path, account_, block.timestamp) {                
                } catch {
                    return 0;
                }
            } 
            emit Withdrawn(account_, _amount);             
        }
        
        withdrawnDividends[account_] += _amount;                       
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);
        magnifiedDividendCorrections[account] -= int256(magnifiedDividendPerShare * value);
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);
        magnifiedDividendCorrections[account] += int256(magnifiedDividendPerShare * value);
    }

    function _setBalance(address account, uint256 newBalance) internal {        
        uint256 currentBalance = balanceOf(account);
        if (newBalance > currentBalance) {
            _mint(account, newBalance - currentBalance);
        } else if (newBalance < currentBalance) {
            _burn(account, currentBalance - newBalance);
        }        
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "DT: Not allowed");
    }

    // -------------------------------------- MODIFIERS ----------------------------------------

    modifier onlyToken() {
        require(msg.sender == token, "DT: Not token");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == IOwnable(token).owner(), "DT: Not owner");
        _;
    }

    modifier notPaused() {
        require(!dividendsPaused, "DT: Paused");
        _;
    }

    // -------------------------------------- EVENTS ----------------------------------------
    
    event DividendsDistributed(address indexed account, uint256 amount);
    event SetPayoutToken(address account);
    event SetMinBalanceForDividends(uint256 amount);
    event ExcludedFromDividends(address indexed account, bool state);    
    event DividendsPaused(bool state);
    event SetReinvestAllowed(bool state);
    event SetAutoReinvest(address account, bool state);
    event Processed(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, address processor);
    event Reinvested(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount); 
}

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

interface IDividendTracker {
    function setExcludedFromDividends(address account, bool state) external;
    function setBalance(address account, uint256 amount) external;
    function process(uint256 gas) external returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex);   
}

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

interface IFeeDistributor {
    //function setExcludedFromDividends(address account_, bool state) external;    
}

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

interface IOwnable {
    function owner() external returns (address);
}

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;
import "./IUniswapV2Router02.sol"; 

interface IToken {
    function uniswapV2Router() external returns (IUniswapV2Router02 uniswapV2Router);
}

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

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

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

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

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

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

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./DividendTracker.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IDividendTracker.sol";
import "./interfaces/IFeeDistributor.sol";
import "./interfaces/IToken.sol";

contract Token is IToken, ERC20, Ownable {
    IUniswapV2Router02 private _uniswapV2Router;    
    IDividendTracker public dividendTracker;    
    address public feeDistributor;
    address public uniswapV2Pair; 

    bool private swapping;   
    bool public tradingEnabled; 
    uint256 public launchBlock;     
    uint256 constant feeBase = 1000; 

    Fees public fees;
    Config public config;
    FeesCollected public feesCollected;

    // exlcude from fees and max transaction amount
    mapping(address => bool) public excludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    // staking variables
    mapping(address => uint256) public stakingBonus;
    mapping(address => uint256) public stakingUntilDate;
    mapping(uint256 => uint256) public stakingAmounts;

    //for allowing specific address to trade while trading has not been enabled yet 
    mapping(address => bool) private canTransferBeforeTradingEnabled;

    mapping(address => uint256) private holderLastTransferBlock; // for 1 tx per block
    mapping(address => uint256) private holderLastTransferTimestamp; // for sell cooldown timer
        
    struct Config { 
        bool swapAndLiquifyEnabled;  
        bool stakingEnabled;              
        bool botsProtection;
        uint16 coolDownTimer;
        uint64 gasPriceLimit; 
        uint32 gasForProcessing;
        uint256 maxWallet;
        uint256 swapTokensAtAmount;
    }

    struct Fees {  
        uint8 buyLiquidity;
        uint8 sellLiquidity; 
        uint8 buyRewards;
        uint8 sellRewards; 
        uint8 buyDistribution;  
        uint8 sellDistribution;
        uint8 buyBurn;
        uint8 sellBurn; 
        uint8 transfer;
    }

    struct FeesCollected {
        uint256 liquidity; 
        uint256 rewards; 
        uint256 distribution;
    }

    // -------------------------------------- CONSTRUCT ----------------------------------------

    constructor(
        string memory name_, 
        string memory symbol_, 
        uint256 initialSupply_, 
        IUniswapV2Router02 uniswapV2Router_,        
        Fees memory fees_,
        Config memory config_,
        address dtPayOutToken_,
        uint256 dtMinBalanceForDividends_        
        ) ERC20(name_, symbol_) {
                
        dividendTracker = new DividendTracker(
            address(this),
            dtPayOutToken_,
            dtMinBalanceForDividends_,
            string.concat(name_, 'DT'),
            string.concat(symbol_, 'DT')
        );

        _uniswapV2Router = uniswapV2Router_;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        setAutomatedMarketMakerPair(uniswapV2Pair, true);        
        dividendTracker.setExcludedFromDividends(address(_uniswapV2Router), true);        
        
        // exclude from paying fees or having max transaction amount
        excludedFromFees[address(this)] = true;
        excludedFromFees[address(dividendTracker)] = true;        
        excludedFromFees[msg.sender] = true;
        
        canTransferBeforeTradingEnabled[msg.sender] = true;
        canTransferBeforeTradingEnabled[address(this)] = true;
        
        _mint(msg.sender, initialSupply_); // only time internal mint function is ever called is to create supply
                 
        setFees(fees_);
        setConfig(config_);
    }

    // -------------------------------------- ADMIN -----------------------------------------

    // main contract config
    function setConfig(Config memory config_) public onlyOwner {
        config = config_;
        require(config.gasPriceLimit >= 5 gwei, "Must be >= 5 gwei");
        require(config.coolDownTimer <= 300, "Cooldown timer <= 300 seconds");
        require(config.maxWallet >= totalSupply() / 2000, "Max wallet cannot be < 0.05%");
        require(config.gasForProcessing >= 200000 && config.gasForProcessing <= 1000000, "Bad gas value");
        require(config.swapTokensAtAmount <= totalSupply() / 100 * 3, "Swap Tokens At cannot be > 3%");
        emit UpdateConfig(config);
    }

    // transfer/buy/sell fees
    function setFees(Fees memory fees_) public onlyOwner {
        fees = fees_;
        require(fees_.transfer + fees_.buyLiquidity + fees_.buyRewards + fees_.buyDistribution + fees_.buyBurn <= 150, "Wrong total buy fees");
        require(fees_.transfer + fees_.sellLiquidity + fees_.sellRewards + fees_.sellDistribution + fees_.sellBurn <= 150, "Wrong total sell fees");
        require(fees_.transfer <= 50, "Wrong transfer fees");
        require(fees_.buyBurn != 0  && fees_.buyBurn <= 50, "Wrong buy burn fees"); //5
        require(fees_.sellBurn != 0  && fees_.sellBurn <= 50, "Wrong sell burn fees");
        emit UpdateFees(fees);
    }

    // can only enable, trading can never be disabled
    function setTradingEnabled() external onlyOwner {
        require(!tradingEnabled, "Already set");
        tradingEnabled = true;
        launchBlock = block.number;
        emit TradingEnabled();
    }
    
    // set staking duration and bonus 
    function setStakingAmounts(uint256 duration_, uint256 bonus_) public onlyOwner {
        require(stakingAmounts[duration_] != bonus_);
        require(bonus_ <= 100, "Staking bonus can't exceed 100");
        stakingAmounts[duration_] = bonus_;
        emit SetStakingAmounts(duration_, bonus_);
    }
    
    // use for pre sale wallet, adds all exclusions to it
    function setPresaleWallet(address account_) external onlyOwner {
        canTransferBeforeTradingEnabled[account_] = true;
        excludedFromFees[account_] = true;
        dividendTracker.setExcludedFromDividends(account_, true);
        emit SetPreSaleWallet(account_);
    }

    // use for pre sale wallet, adds all exclusions to it
    function setFeeDistributor(address feeDistributor_) external onlyOwner {
        require(feeDistributor != feeDistributor_, "Already set");
        feeDistributor = feeDistributor_;
        emit SetFeeDistributor(feeDistributor_);
    }
    
    // exclude a wallet from fees 
    function setExcludedFromFees(address account_, bool state_) public onlyOwner {
        require(excludedFromFees[account_] != state_, "Already set");
        excludedFromFees[account_] = state_;
        emit SetExcludedFromFees(account_, state_);
    }

    // exclude / include from dividends (rewards)
    function setExcludedFromDividends(address account_, bool state_) public onlyOwner {
        dividendTracker.setExcludedFromDividends(account_, state_);        
        if (!state_) {
            dividendTracker.setBalance(account_, _getStakingBalance(account_));
        }       
    }

    // allow a wallet to trade before trading enabled
    function setCanTransferBeforeTradingEnabled(address account_, bool state_) external onlyOwner {
        require(canTransferBeforeTradingEnabled[account_] != state_, "Already set");
        canTransferBeforeTradingEnabled[account_] = state_;
        emit SetCanTransferBeforeTradingEnabled(account_, state_);
    }

    // add account to amm to determine buys/sells
    function setAutomatedMarketMakerPair(address account_, bool state_) public onlyOwner {
        require(automatedMarketMakerPairs[account_] != state_, "Already set");
        automatedMarketMakerPairs[account_] = state_;
        dividendTracker.setExcludedFromDividends(account_, state_);       
        emit SetAutomatedMarketMakerPair(account_, state_);
    }

    // change admin
    function transferOwnership(address account_) public override onlyOwner {
        dividendTracker.setExcludedFromDividends(owner(), false);
        dividendTracker.setExcludedFromDividends(account_, true);
        excludedFromFees[owner()] = false;
        excludedFromFees[account_] = true;
        super.transferOwnership(account_);
    }

    // airdrop to max 100 wallets at once
    function airdrop(address[] memory accounts_, uint256[] memory amounts_) external onlyOwner {
        require(accounts_.length == amounts_.length, "Listss must be the same length");
        require(accounts_.length <= 100, "List length must be <= 100");
        
        for (uint256 i = 0; i < accounts_.length; i++) {
            address account = accounts_[i];                    
            super._transfer(msg.sender, account, amounts_[i]);        
            dividendTracker.setBalance(account, _getStakingBalance(account));
        }
    }

    // manual swap and send dividends
    function forceSwapAndSendDividends() public onlyOwner {
        _swapAndSendDividends();
    }

    // adding initial liquidity 
    function addLiquidity(uint256 tokenAmount) public payable onlyOwner {
        this.transferFrom(msg.sender, address(this), tokenAmount);
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.addLiquidityETH{ value: msg.value }(address(this), tokenAmount, 0, 0, msg.sender, block.timestamp);
    }

    // -------------------------------------- VIEWS -----------------------------------------

    // aggregated data for contract and account (by defauld provide ZERO address to get only contract data)
    // use it on UI to get all data in single request
    function aggregatedData(address account_) public view returns (
        // contract
        uint256 _totalSupply,
        Fees memory _fees,
        Config memory _config,
        address _uniswapV2Pair,
        bool _tradingEnabled,
        // account
        uint256 _stakingBalance,
        uint256 _stakingBonus,
        uint256 _stakingUntilDate,
        bool _canTransferBeforeTradingEnabled,
        bool _excludedFromFees
    ) {
        // contract
        _totalSupply = totalSupply();
        _fees = fees;
        _config = config;
        _uniswapV2Pair = uniswapV2Pair;
        _tradingEnabled = tradingEnabled;
        // account        
        _stakingBalance = _getStakingBalance(account_);
        _stakingBonus = stakingBonus[account_];
        _stakingUntilDate = stakingUntilDate[account_];
        _canTransferBeforeTradingEnabled = canTransferBeforeTradingEnabled[account_];
        _excludedFromFees = excludedFromFees[account_];
    } 

    function uniswapV2Router() public view returns (IUniswapV2Router02) {
        return _uniswapV2Router;
    }
    
    // -------------------------------------- PUBLIC -----------------------------------------

    // stake all user tokens for predefined duration to get bonuses
    function stake(uint256 duration_) public {
        require(config.stakingEnabled, "Staking is not enabled");
        require(stakingAmounts[duration_] != 0, "Invalid staking duration");
        require(stakingUntilDate[_msgSender()] < block.timestamp + duration_, "Already staked for a longer");
        
        stakingBonus[_msgSender()] = stakingAmounts[duration_];
        stakingUntilDate[_msgSender()] = block.timestamp + duration_;
       
        dividendTracker.setBalance(_msgSender(), _getStakingBalance(_msgSender()));
        
        emit SetAccountStaking(_msgSender(), duration_);
    }

    // -------------------------------------- INTERNAL ----------------------------------------

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        
        if (!canTransferBeforeTradingEnabled[from]) {
            require(tradingEnabled, "Trading not enabled");
        }

        if (amount == 0) return;   
        
        if (!swapping && !excludedFromFees[from] && !excludedFromFees[to] && !excludedFromFees[tx.origin]) {
            uint256 rewardsAmount;                       
            uint256 liquidityAmount;
            uint256 distributionAmount;     
            uint256 burnAmount;

            bool isSelling = automatedMarketMakerPairs[to];
            bool isBuying = automatedMarketMakerPairs[from];
            
            // if not buy and not sell incure transfer tax
            if (!isBuying && !isSelling) { 
                // calc fees 
                rewardsAmount = amount * fees.transfer / feeBase;                 
            } 
            // if sell and staking enabled
            else if (!isBuying && config.stakingEnabled) {
                // staking check
                require(stakingUntilDate[from] <= block.timestamp, "Tokens are staked and locked" );
                if (stakingUntilDate[from] != 0) {
                    stakingUntilDate[from] = 0;
                    stakingBonus[from] = 0;
                }
            } 
            // if sell
            else if (isSelling) {  
                // calc fees
                rewardsAmount = amount * fees.buyRewards / feeBase;                            
                liquidityAmount = amount * fees.buyLiquidity / feeBase; 
                distributionAmount = amount * fees.buyDistribution / feeBase; 
                burnAmount = amount * fees.buyBurn / feeBase;              
                // bots protection
                if (config.botsProtection) {
                    require(block.timestamp >= holderLastTransferTimestamp[tx.origin] + config.coolDownTimer, "Cooldown period active");
                    holderLastTransferTimestamp[tx.origin] = block.timestamp;
                }
            } 
            // if buy
            else if (isBuying) {
                // calc fees
                rewardsAmount = amount * fees.buyRewards / feeBase;                            
                liquidityAmount = amount * fees.buyLiquidity / feeBase; 
                distributionAmount = amount * fees.buyDistribution / feeBase; 
                burnAmount = amount * fees.buyBurn / feeBase;               
                // bots protection
                if (config.botsProtection) {
                    require(block.number > launchBlock + 2, "No early entry");                    
                    require(tx.gasprice <= config.gasPriceLimit, "Gas price exceeds limit.");
                    require(holderLastTransferBlock[tx.origin] != block.number, "Too many TX in block");
                    holderLastTransferBlock[tx.origin] = block.number;
                }
                // max wallet token amount
                require(balanceOf(to) + amount <= config.maxWallet, "Exceeds max wallet amount" );                
            }
                        
            // process fees
            uint256 totalFeesAmount = rewardsAmount + liquidityAmount + distributionAmount;
            if (totalFeesAmount != 0) {
                super._transfer(from, address(this), totalFeesAmount);
                feesCollected.rewards += rewardsAmount;
                feesCollected.liquidity += liquidityAmount;
                feesCollected.distribution += distributionAmount;    
                amount -= totalFeesAmount;        
            }

            // process burn
            if (burnAmount != 0) {
                _burn(from, burnAmount);                  
                amount -= burnAmount;    
            }

            // liquify and send dividends
            if (isSelling && balanceOf(address(this)) >= config.swapTokensAtAmount) {
                swapping = true;
                _swapAndLiquify();
                _swapAndSendDividends();  
                swapping = false;
            } 

            // if buy or sell process dividends
            if (isBuying || isSelling) {  
                try dividendTracker.process(config.gasForProcessing) {} catch {}            
            }
        }

        super._transfer(from, to, amount);
        
        dividendTracker.setBalance(from, _getStakingBalance(from));
        dividendTracker.setBalance(to, _getStakingBalance(to));
    }

    function _getStakingBalance(address account_) internal view returns (uint256) {
        return config.stakingEnabled ? balanceOf(account_) * (stakingBonus[account_] + 100) / 100 : balanceOf(account_);
    }

    function _swapAndLiquify() internal {
        if (config.swapAndLiquifyEnabled && feesCollected.liquidity != 0) {
            uint256 half = feesCollected.liquidity / 2;
            uint256 otherHalf = feesCollected.liquidity - half;
            feesCollected.liquidity = 0;

            uint256 initialBalance = address(this).balance;
            
            _swapTokensForEth(half, address(this));
            
            uint256 newBalance = address(this).balance - initialBalance;
            _addLiquidity(otherHalf, newBalance);
            
            emit SwapAndLiquify(half, newBalance, otherHalf);    
        }
    }
    
    function _swapAndSendDividends() internal {
        if (feesCollected.rewards != 0) {
            _swapTokensForEth(feesCollected.rewards, address(dividendTracker));
            emit SendDividends(feesCollected.rewards);
            feesCollected.rewards = 0;        
        }

        if (feesCollected.distribution != 0) {            
            _swapTokensForEth(feesCollected.distribution, feeDistributor);  
            emit SendFees(feesCollected.distribution);  
            feesCollected.distribution = 0;         
        }
    }

    function _swapTokensForEth(uint256 tokenAmount, address recipient) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, recipient, block.timestamp);        
    }   
    
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.addLiquidityETH{ value: ethAmount }(address(this), tokenAmount, 0, 0, owner(), block.timestamp);
    }

    receive() external payable {}
        
    // -------------------------------------- EVENTS -----------------------------------------

    event UpdateFees(Fees fees);
    event UpdateConfig(Config config);
    event SetAccountStaking(address account, uint256 duration);
    event SetStakingAmounts(uint256 duration, uint256 amount);    
    event TradingEnabled();    
    event SetPreSaleWallet(address wallet);
    event SetFeeDistributor(address account);
    event SetExcludedFromFees(address account, bool state);
    event SetAutomatedMarketMakerPair(address account, bool state);
    event SetCanTransferBeforeTradingEnabled(address account, bool state); 
    event Airdrop(address account, uint256 amount);        
    event SwapAndLiquify(uint256 tokens, uint256 eth, uint256 tokensIntoLiqudity);   
    event SendFees(uint256 amount);
    event SendDividends(uint256 amount);    
}