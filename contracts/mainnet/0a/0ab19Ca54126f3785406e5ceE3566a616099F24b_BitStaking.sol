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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TimeVolumeRegistery.sol";

pragma solidity 0.8.8;

contract DSMath {
  function add(uint x, uint y) internal pure returns (uint z) {
    require((z = x + y) >= x, "ds-math-add-overflow");
  }

  function sub(uint x, uint y) internal pure returns (uint z) {
    require((z = x - y) <= x, "ds-math-sub-underflow");
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
  }

  function min(uint x, uint y) internal pure returns (uint z) {
    return x <= y ? x : y;
  }

  function max(uint x, uint y) internal pure returns (uint z) {
    return x >= y ? x : y;
  }

  function imin(int x, int y) internal pure returns (int z) {
    return x <= y ? x : y;
  }

  function imax(int x, int y) internal pure returns (int z) {
    return x >= y ? x : y;
  }

  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, y), WAD / 2) / WAD;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, y), RAY / 2) / RAY;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, RAY), y / 2) / y;
  }

  function rpow(uint x, uint n) internal pure returns (uint z) {
    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rmul(x, x);

      if (n % 2 != 0) {
        z = rmul(z, x);
      }
    }
  }
}

interface ICreditFacility {
  function getBorrowerStatus(
    address _borrower,
    uint256 _index
  ) external view returns (uint256);

  function getBorrowTime(address _borrower) external view returns (uint256);

  function getTotalBorrowedBUSD(
    address _borrower,
    uint256 _borrowTime
  ) external view returns (uint256);

  function getTotalRepaidBUSD(
    address _borrower,
    uint256 _borrowTime
  ) external view returns (uint256);

  function getTotalCollateraled8Bit(
    address _borrower,
    uint256 _borrowTime
  ) external view returns (uint256);

  function getBorrowStartTime(
    address _borrower,
    uint256 _borrowTime
  ) external view returns (uint256);

  function getRepaidTime(
    address _borrower,
    uint256 _borrowTime
  ) external view returns (uint256);

  function resetBorrower(address _staker) external;
}

contract BitStaking is DSMath, Ownable {
  using SafeERC20 for IERC20;

  struct StakingPool {
    bool Locked;
    uint256 LockTime;
    uint256 APY;
    uint256 fee;
    uint256 minToStake;
  }

  //Each staker has a StakeProfile for each pool, this profiles are stored in "stakers" mapping
  struct StakeProfile {
    uint256 totalStaked;
    uint256 unlockTime;
    uint256 lastClaimTime;
    uint256 stakingStart;
    uint256 totalClaimed;
  }

  struct APYCheckPoint {
    uint256[3] APYs;
    uint256 startTime;
  }

  //Staking token, pools and stakers
  uint256 public totalStaked;
  IERC20 public stakingToken;
  ICreditFacility public creditFacility;
  mapping(uint256 => StakingPool) Pools;
  mapping(address => mapping(uint256 => StakeProfile)) stakers;
  mapping(uint256 => uint256) poolStaked;
  APYCheckPoint[] apyCheckpoints;

  //NFT Contracts, To Check If Someone holds NFT or not
  address[] public NFTs;
  uint256 public stakingStart = 0;
  address public RewardsFeeReceiver =
    0x5236925F1a6d86c5819Cf25AFa41B979620d3eC2;
  uint256 public tokenDecimals;
  address public stakingVault;
  TimeVolumeRegistery public timeVolumeRegistery;

  //events
  event StakingStarted(uint256 indexed startTime);
  event Staked(
    address indexed staker,
    uint256 indexed amount,
    uint256 indexed poolid
  );
  event Unstaked(
    address indexed staker,
    uint256 indexed amount,
    uint256 indexed poolId
  );
  event Penaltied(address indexed staker, uint256 indexed penaltyAmount);
  event EmergencyWithdrawed(address indexed staker, uint256 indexed poolId);
  event Claimed(address indexed staker, uint256 indexed amount);

  constructor(address _stakingToken) {
    /**
     * Pools:
     * Id-0 : Standard pool 30 days period
     * Id-1 : NFT pool 30 days period
     * Id-2 : Credit Pool
     */
    stakingToken = IERC20(_stakingToken);
    uint256 decimals = 18;
    tokenDecimals = decimals;

    //Standard Pools => not locked, 30days, 12% APY, 20% fee for early unstake, 5, 000 8Bit minimum for staking
    Pools[0] = StakingPool(false, 30 days, 12, 200, 5000 * 10 ** decimals);

    //NFT Pools => not locked, 30 days, 36% APY, 20% fee for early unstake, 25, 000 8Bit minimum for staking
    Pools[1] = StakingPool(false, 30 days, 36, 200, 25000 * 10 ** decimals);

    //Credit Pool => locked, 90 days period, 36% APY, 0 Fee as its locked, 150, 000 8Bit minimum for staking
    Pools[2] = StakingPool(true, 90 days, 36, 0, 150000 * 10 ** decimals);

    timeVolumeRegistery = new TimeVolumeRegistery();
  }

  function setCreditFacility(address facility) public onlyOwner {
    creditFacility = ICreditFacility(facility);
  }

  function setStakingToken(address _stakingToken) public onlyOwner {
    stakingToken = ERC20(_stakingToken);
  }

  function setStakingVault(address _valut) external onlyOwner {
    stakingVault = _valut;
  }

  function StartStaking() external onlyOwner {
    require(stakingStart == 0, "Staking already started!");
    stakingStart = block.timestamp;

    uint256[3] memory APYs = [uint256(12), uint256(36), uint256(36)];
    apyCheckpoints.push(APYCheckPoint(APYs, block.timestamp));

    emit StakingStarted(block.timestamp);
  }

  function changeAPY(uint256 _poolId, uint256 _newAPY) external onlyOwner {
    Pools[_poolId].APY = _newAPY;
    APYCheckPoint memory lastPoint = apyCheckpoints[apyCheckpoints.length - 1];
    lastPoint.APYs[_poolId] = _newAPY;
    lastPoint.startTime = block.timestamp;
    apyCheckpoints.push(lastPoint);
  }

  function changeMinTokensToEnter(
    uint256 _poolId,
    uint256 _newMin
  ) external onlyOwner {
    Pools[_poolId].minToStake = _newMin;
  }

  function AddNFT(address _newNFT) external onlyOwner {
    NFTs.push(_newNFT);
  }

  function removeNFT(address _NFT) external onlyOwner {
    address[] memory nfts = NFTs;
    for (uint256 i = 0; i < nfts.length; i++) {
      if (nfts[i] == _NFT) {
        NFTs[i] = nfts[nfts.length - 1];
        NFTs.pop();
        break;
      }
    }
  }

  function StakeTokens(uint256 poolId, uint256 toStake) external {
    //Saving our target pool in memory to save gas!
    StakingPool memory targetPool = Pools[poolId];
    //Getting balance of holder to make sure he is not staking all of his tokens! (more than 90%)
    uint256 balance = stakingToken.balanceOf(msg.sender);

    //Validating Here
    require(poolId < 3, "Invalid Pool!");
    require(stakingStart > 0, "Staking not started yet!");
    require(
      toStake >= targetPool.minToStake,
      "You cant stake less than minimum!"
    );
    require(
      (toStake * 10000) / balance <= 9999,
      "You cant stake more than 99% of your holdings!"
    );

    //For NFT pools we want to make sure that staker is nft holder or not, so we will check his balance across all of
    //NFT contracts
    if (poolId == 1) {
      require(
        checkIfHoldsNFT(msg.sender) == true,
        "You cant stake in nft pool, since you dont have any nfts!"
      );
    }

    //Updating staker profile
    //first we save staker profile in memory to save a huge amount of gas!
    StakeProfile memory profile = stakers[msg.sender][poolId];

    //Updating total staked and also lock time
    profile.totalStaked += toStake;
    profile.unlockTime = block.timestamp + targetPool.LockTime;
    if (profile.stakingStart == 0) {
      profile.stakingStart = block.timestamp;
      profile.lastClaimTime = block.timestamp;
    }

    //Saving profile back to storage!
    stakers[msg.sender][poolId] = profile;
    poolStaked[poolId] += toStake;

    //finally we transfer the tokens to the pool
    totalStaked += toStake;
    stakingToken.safeTransferFrom(msg.sender, address(this), toStake);

    timeVolumeRegistery.submitNewVolume(getPoolStakedTokens(2));

    emit Staked(msg.sender, toStake, poolId);
  }

  function Unstake(uint256 _poolId, uint256 _toUnstake) public {
    StakingPool memory targetPool = Pools[_poolId];
    StakeProfile memory profile = stakers[msg.sender][_poolId];

    require(profile.totalStaked > 0, "You did not stake any 8Bit!");
    require(_poolId < 3, "Invalid Pool!");
    require(_toUnstake <= profile.totalStaked, "Insufficient staking balance!");

    if (_poolId == 2) {
      require(
        profile.unlockTime <= block.timestamp,
        "You can not unstake now!"
      );
      uint256 borrowIndex = creditFacility.getBorrowTime(msg.sender);
      uint256 borrowStatus = creditFacility.getBorrowerStatus(
        msg.sender,
        borrowIndex
      );
      require(
        borrowStatus != 1 && borrowStatus != 2,
        "You are in delay for repaying BUSD, so you can not unstake!"
      );
    }

    uint256 earlyFee = targetPool.fee;
    uint256 rewards = getRewards(msg.sender, _poolId);
    if (rewards > 0 && earlyFee > 0) {
      if (profile.unlockTime >= block.timestamp) {
        stakingToken.safeTransferFrom(
          stakingVault,
          RewardsFeeReceiver,
          (rewards * earlyFee) / 1000
        );
        rewards -= (rewards * earlyFee) / 1000;
      }
    }

    profile.totalStaked -= _toUnstake;
    profile.lastClaimTime = block.timestamp;
    profile.totalClaimed += rewards;
    if (profile.totalStaked == 0) {
      profile.unlockTime = 0;
      profile.stakingStart = 0;
      profile.lastClaimTime = 0;
      if (_poolId == 2) {
        creditFacility.resetBorrower(msg.sender);
      }
    }
    totalStaked -= _toUnstake;

    stakers[msg.sender][_poolId] = profile;
    poolStaked[_poolId] -= _toUnstake;

    stakingToken.safeTransfer(msg.sender, _toUnstake);

    if (rewards > 0) {
      stakingToken.safeTransferFrom(stakingVault, msg.sender, rewards);
    }

    timeVolumeRegistery.submitNewVolume(getPoolStakedTokens(2));
    emit Unstaked(msg.sender, _toUnstake, _poolId);
  }

  function claimRewards(uint256 _poolId) public {
    StakeProfile memory profile = stakers[msg.sender][_poolId];
    require(profile.totalStaked > 0, "You did not stake any 8Bit!");

    if (_poolId == 2) {
      uint256 borrowIndex = creditFacility.getBorrowTime(msg.sender);
      uint256 borrowStatus = creditFacility.getBorrowerStatus(
        msg.sender,
        borrowIndex
      );
      require(
        borrowStatus != 1 && borrowStatus != 2,
        "You cant claim rewards!"
      );
    }

    uint256 rewards = getRewards(msg.sender, _poolId);
    profile.lastClaimTime = block.timestamp;
    profile.totalClaimed += rewards;
    stakers[msg.sender][_poolId] = profile;

    stakingToken.safeTransferFrom(stakingVault, msg.sender, rewards);

    timeVolumeRegistery.submitNewVolume(getPoolStakedTokens(2));
    emit Claimed(msg.sender, rewards);
  }

  //Emergency withdraw only for standard and nft pools
  function emergencyWithdraw(uint256 _poolId) public {
    //Saving our target pool & staker profile in memory to save gas!
    StakeProfile memory profile = stakers[msg.sender][_poolId];

    require(profile.totalStaked > 0, "You did not stake any 8Bit!");

    if (_poolId == 2) {
      require(
        profile.unlockTime <= block.timestamp,
        "You can not unstake now!"
      );
      uint256 borrowIndex = creditFacility.getBorrowTime(msg.sender);
      uint256 borrowStatus = creditFacility.getBorrowerStatus(
        msg.sender,
        borrowIndex
      );
      require(
        borrowStatus != 1 && borrowStatus != 2,
        "You are in delay for repaying BUSD, so you can not unstake!"
      );
    }

    uint256 amountStaked = profile.totalStaked;
    profile.totalStaked -= amountStaked;
    totalStaked -= amountStaked;
    profile.unlockTime = 0;
    profile.stakingStart = 0;
    profile.lastClaimTime = 0;
    stakers[msg.sender][_poolId] = profile;
    stakingToken.safeTransfer(msg.sender, amountStaked);
    poolStaked[_poolId] -= amountStaked;
    timeVolumeRegistery.submitNewVolume(getPoolStakedTokens(2));
    emit EmergencyWithdrawed(msg.sender, _poolId);
  }

  function penaltyCreditPoolStaker(
    address _creditPoolStaker,
    address _to
  ) external onlyOwner {
    //Getting Stake Profile
    StakeProfile memory profile = stakers[_creditPoolStaker][2];
    uint256 rewards = getRewards(_creditPoolStaker, 2);
    uint256 staked = profile.totalStaked;
    uint256 borrowIndex = creditFacility.getBorrowTime(_creditPoolStaker);
    uint256 borrowStatus = creditFacility.getBorrowerStatus(
      _creditPoolStaker,
      borrowIndex
    );
    require(borrowStatus == 2, "You can not penalty this staker yet!");
    creditFacility.resetBorrower(_creditPoolStaker);
    profile.totalStaked = 0;
    profile.unlockTime = 0;
    profile.stakingStart = 0;
    profile.lastClaimTime = 0;
    totalStaked -= staked;
    stakingToken.safeTransfer(_to, staked);
    stakingToken.safeTransferFrom(stakingVault, _to, rewards);
    stakers[_creditPoolStaker][2] = profile;
    poolStaked[2] -= staked;
    timeVolumeRegistery.submitNewVolume(getPoolStakedTokens(2));
    emit Penaltied(_creditPoolStaker, staked);
  }

  function massPenaltyCreditPoolStakers(
    address[] memory _creditPoolStakers,
    address _to
  ) external onlyOwner {
    //Getting Stake Profile
    uint256 borrowIndex;
    uint256 borrowStatus;
    uint256 rewards;
    uint256 staked;
    address staker;
    uint256 totalStakePenaltied = 0;
    uint256 totalRewardsPenaltied = 0;
    StakeProfile memory profile;
    for (uint256 i = 0; i < _creditPoolStakers.length; i++) {
      staker = _creditPoolStakers[i];
      profile = stakers[staker][2];
      borrowIndex = creditFacility.getBorrowTime(staker);
      borrowStatus = creditFacility.getBorrowerStatus(staker, borrowIndex);
      if (borrowStatus == 2) {
        rewards = getRewards(staker, 2);
        creditFacility.resetBorrower(staker);
        staked = profile.totalStaked;
        profile.totalStaked = 0;
        profile.unlockTime = 0;
        profile.stakingStart = 0;
        profile.lastClaimTime = 0;
        totalStaked -= staked;
        totalStakePenaltied += staked;
        totalRewardsPenaltied += rewards;
        poolStaked[2] -= staked;
        emit Penaltied(staker, staked);
        stakers[staker][2] = profile;
      } else {
        continue;
      }
    }
    stakingToken.safeTransfer(_to, totalStakePenaltied);
    stakingToken.safeTransferFrom(stakingVault, _to, totalRewardsPenaltied);
    timeVolumeRegistery.submitNewVolume(getPoolStakedTokens(2));
  }

  function getRewards(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    require(_poolId < 3, "Invalid Pool!");

    StakeProfile memory profile = stakers[_staker][_poolId];
    uint256 startTime = profile.lastClaimTime;
    uint256 endTime = block.timestamp;
    uint256 totalRewards;

    if (profile.totalStaked == 0) {
      return 0;
    }
    if (startTime == endTime) {
      return 0;
    }

    if (_poolId == 2) {
      uint256 borrowIndex = creditFacility.getBorrowTime(_staker);
      uint256 borrowStatus = creditFacility.getBorrowerStatus(
        _staker,
        borrowIndex
      );
      if (borrowStatus == 1 || borrowStatus == 2) {
        startTime = profile.lastClaimTime;
        endTime = profile.stakingStart + 30 days;
      } else if (borrowStatus == 3) {
        if (profile.lastClaimTime < profile.stakingStart + 30 days) {
          uint256 repaidTime = creditFacility.getRepaidTime(
            _staker,
            borrowIndex
          );
          totalRewards += _calculateRewardsTimeRange(
            _staker,
            _poolId,
            profile.lastClaimTime,
            profile.stakingStart + 30 days
          );
          startTime = repaidTime;
          endTime = block.timestamp;
        }
      }
    }

    totalRewards += _calculateRewardsTimeRange(
      _staker,
      _poolId,
      startTime,
      endTime
    );
    return totalRewards;
  }

  function _calculateRewardsTimeRange(
    address _staker,
    uint256 _poolId,
    uint256 _startTime,
    uint256 _endTime
  ) internal view returns (uint256) {
    StakeProfile memory profile = stakers[_staker][_poolId];
    if (_poolId == 1) {
      if (profile.totalStaked > 0) {
        if (checkIfHoldsNFT(_staker) == false) {
          _poolId = 0;
        }
      }
    }
    APYCheckPoint[] memory array = apyCheckpoints;
    uint256 startCheckPoint = findAPYAtTimestamp(_startTime);
    uint256 endCheckPoint = findAPYAtTimestamp(_endTime);
    uint256 endTime;
    uint256 totalRewards;
    if (startCheckPoint == endCheckPoint) {
      return
        calculateInteresetInSeconds(
          profile.totalStaked,
          array[startCheckPoint].APYs[_poolId],
          _endTime - _startTime
        ) - profile.totalStaked;
    }
    for (uint256 i = startCheckPoint; i <= endCheckPoint; i++) {
      if (i == endCheckPoint) {
        //if we are at last checkpoint
        endTime = _endTime;
      } else {
        //if we are not at last checkpoint
        endTime = array[i + 1].startTime;
      }
      totalRewards +=
        calculateInteresetInSeconds(
          profile.totalStaked,
          array[i].APYs[_poolId],
          endTime - _startTime
        ) -
        profile.totalStaked;
      if (i < endCheckPoint) {
        _startTime = array[i + 1].startTime;
      }
    }
    return totalRewards;
  }

  function calculateInteresetInSeconds(
    uint256 principal,
    uint256 apy,
    uint256 _seconds
  ) internal pure returns (uint256) {
    //Calculating the ratio per second
    //ratio per seconds
    uint256 _ratio = ratio(apy);
    //Interest after _seconds
    return accrueInterest(principal, _ratio, _seconds);
  }

  function ratio(uint256 n) internal pure returns (uint256) {
    uint256 numerator = n * 10 ** 25;
    uint256 denominator = 365 * 86400;
    uint256 result = uint256(10 ** 27) + uint256(numerator / denominator);
    return result;
  }

  function accrueInterest(
    uint _principal,
    uint _rate,
    uint _age
  ) internal pure returns (uint) {
    return rmul(_principal, rpow(_rate, _age));
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a & b) + (a ^ b) / 2;
  }

  function findAPYAtTimestamp(uint256 element) internal view returns (uint256) {
    APYCheckPoint[] memory array = apyCheckpoints;
    if (array.length == 0) {
      return 0;
    }
    uint256 low = 0;
    uint256 high = array.length;
    while (low < high) {
      uint256 mid = average(low, high);
      // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
      // because Math.average rounds down (it does integer division with truncation).
      if (array[mid].startTime > element) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    if (low > 0) {
      return low - 1;
    }
    return low;
  }

  function checkIfHoldsNFT(address _staker) public view returns (bool) {
    //Saving Array To Memory To Save A Huge Amount Of Gas!
    address[] memory nfts = NFTs;
    if (nfts.length == 0) {
      return false;
    }

    for (uint256 i = 0; i < nfts.length; i++) {
      if (IERC721(nfts[i]).balanceOf(_staker) > 0) {
        return true;
      }
    }
    return false;
  }

  function getVolumeAtTimeStamp(uint256 ts) external view returns (uint256) {
    return timeVolumeRegistery.getVolume(ts);
  }

  function getLastWeekVolume() external view returns (uint256[] memory) {
    return timeVolumeRegistery.getlastWeekVolume();
  }

  //Getters
  function getPoolStakedTokens(uint256 _poolId) public view returns (uint256) {
    return poolStaked[_poolId];
  }

  function getTotalStaked(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    return stakers[_staker][_poolId].totalStaked;
  }

  function getStakerEndTime(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    return stakers[_staker][_poolId].unlockTime;
  }

  function getStakerStartTime(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    return stakers[_staker][_poolId].stakingStart;
  }

  function getRemainingStakeTime(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    if (block.timestamp >= getStakerEndTime(_staker, _poolId)) {
      return 0;
    }
    return getStakerEndTime(_staker, _poolId) - block.timestamp;
  }

  function getStakerLastClaimTime(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    return stakers[_staker][_poolId].lastClaimTime;
  }

  function getAPYCheckPoint(
    uint256 index
  ) public view returns (APYCheckPoint memory) {
    return apyCheckpoints[index];
  }

  function getTotalClaimed(
    address _staker,
    uint256 _poolId
  ) public view returns (uint256) {
    return stakers[_staker][_poolId].totalClaimed;
  }

  function getPoolAPY(uint256 _poolId) public view returns (uint256) {
    return Pools[_poolId].APY;
  }

  function getPoolMinToEnter(uint256 _poolId) public view returns (uint256) {
    return Pools[_poolId].minToStake;
  }
}

//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity 0.8.8;

contract dateTime {

    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            int256 __days = int256(_days);

            int256 L = __days + 68569 + OFFSET19700101;
            int256 N = (4 * L) / 146097;
            L = L - (146097 * N + 3) / 4;
            int256 _year = (4000 * (L + 1)) / 1461001;
            L = L - (1461 * _year) / 4 + 31;
            int256 _month = (80 * L) / 2447;
            int256 _day = L - (2447 * _month) / 80;
            L = _month / 11;
            _month = _month + 2 - 12 * L;
            _year = 100 * (N - 49) + _year + L;

            year = uint256(_year);
            month = uint256(_month);
            day = uint256(_day);
        }
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) public pure returns (uint256 month) {
        (, month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) public pure returns (uint256 day) {
        (,, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) public pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp) public pure returns (uint256 minute) {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp) public pure returns (uint256 second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }
}

contract TimeVolumeRegistery is Ownable, dateTime{

    mapping(uint256=>mapping(uint256=>mapping(uint256=>uint256))) timeVolume;
    mapping(uint256=>mapping(uint256=>mapping(uint256=>bool))) isZero;

    uint256 public lastSubmissionYear;
    uint256 public lastSubmissionMonth;
    uint256 public lastSubmissionDay;
    uint256 public lastSubmitedVolume;
    uint256 public firstNonZeroSubmission;
    

    function submitNewVolume(uint256 volume) external onlyOwner{
        uint256 submitedyear = getYear(block.timestamp);
        uint256 submitedMonth = getMonth(block.timestamp);
        uint256 submitedDay = getDay(block.timestamp); 
        if(submitedyear > lastSubmissionYear){
            lastSubmissionYear = submitedyear;
            lastSubmissionMonth = submitedMonth;
            lastSubmissionDay = submitedDay;
        }
        if(submitedMonth > lastSubmissionMonth){
            lastSubmissionMonth = submitedMonth;
            lastSubmissionDay = submitedDay;
        }
        if(submitedDay > lastSubmissionDay){
            lastSubmissionDay = submitedDay;
        }

        submitedyear = lastSubmissionYear;
        submitedMonth = lastSubmissionMonth;
        submitedDay = lastSubmissionDay;

        timeVolume[submitedyear][submitedMonth][submitedDay] = volume;

        if(volume == 0){
            isZero[submitedyear][submitedMonth][submitedDay] = true;
        }else{
            isZero[submitedyear][submitedMonth][submitedDay] = false;
            if(firstNonZeroSubmission == 0){
                firstNonZeroSubmission = block.timestamp;
            }
        }

        lastSubmitedVolume = volume;
    }


    function getVolume(uint256 ts) external view returns(uint256) {
        uint256 year = getYear(ts);
        uint256 month = getMonth(ts);
        uint256 day = getDay(ts);        
        return timeVolume[year][month][day];
    }

    function getlastWeekVolume() external view returns(uint256[] memory) {
        uint256 currentTime = block.timestamp;
        uint256 year;
        uint256 month;
        uint256 day;
        uint256 dayVolume;
        bool isZeroVolume;
        uint256 lastVolume = lastSubmitedVolume;
        uint256[] memory volumes = new uint256[](7);
        for(uint i = 0; i < 7; i++){
            year = getYear(currentTime);
            month = getMonth(currentTime);
            day = getDay(currentTime);
            dayVolume = timeVolume[year][month][day];
            isZeroVolume = isZero[year][month][day]; 
            if(dayVolume != lastVolume){
                if(dayVolume == 0){
                    if(isZeroVolume){
                        lastVolume = dayVolume;
                    }else if(firstNonZeroSubmission > currentTime) {
                        volumes[i] = dayVolume;
                    }else{
                        volumes[i] = lastVolume;
                    }
                }else{
                    volumes[i] = dayVolume;
                    lastVolume = dayVolume;
                } 
            }else{
                volumes[i] = lastVolume; 
            }
            currentTime -= 1 days; //going back by 1 day
        }
        return volumes;
    } 

}