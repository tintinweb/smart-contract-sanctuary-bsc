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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "./interfaces/IPoolInteractor.sol";
import "./interfaces/ISwapper.sol";
import "./interfaces/IUniversalSwap.sol";
import "./interfaces/IWETH.sol";
import "./libraries/UintArray.sol";
import "./libraries/AddressArray.sol";
import "./libraries/SwapFinder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IOracle.sol";
import "./libraries/Conversions.sol";
import "./libraries/UintArray2D.sol";
import "hardhat/console.sol";

contract ProvidedHelper {
    using AddressArray for address[];
    using UintArray for uint256[];

    IUniversalSwap public parent;

    constructor() {
        parent = IUniversalSwap(msg.sender);
    }

    ///-------------Internal logic-------------
    function simplifyWithoutWrite(
        Provided memory provided
    ) public view returns (address[] memory simplifiedTokens, uint256[] memory simplifiedAmounts) {
        address[] memory swappers = parent.getSwappers();
        address[] memory poolInteractors = parent.getPoolInteractors();
        address[] memory nftPoolInteractors = parent.getNFTPoolInteractors();

        (simplifiedTokens, simplifiedAmounts) = _simplifyWithoutWriteERC20(
            provided.tokens,
            provided.amounts,
            poolInteractors,
            nftPoolInteractors,
            swappers
        );
        (
            address[] memory simplifiedTokensERC721,
            uint256[] memory simplifiedAmountsERC721
        ) = _simplifyWithoutWriteERC721(provided.nfts, nftPoolInteractors);
        simplifiedTokens = simplifiedTokens.concat(simplifiedTokensERC721);
        simplifiedAmounts = simplifiedAmounts.concat(simplifiedAmountsERC721);
        (simplifiedTokens, simplifiedAmounts) = simplifiedTokens.shrink(simplifiedAmounts);
    }

    ///-------------Internal logic-------------
    function _simplifyWithoutWriteERC20(
        address[] memory tokens,
        uint256[] memory amounts,
        address[] memory poolInteractors,
        address[] memory nftPoolInteractors,
        address[] memory swappers
    ) internal view returns (address[] memory simplifiedTokens, uint256[] memory simplifiedAmounts) {
        address networkToken = parent.networkToken();
        for (uint256 i = 0; i < tokens.length; i++) {
            if (parent.isSimpleToken(tokens[i])) {
                if (tokens[i] != address(0)) {
                    simplifiedTokens = simplifiedTokens.append(tokens[i]);
                } else {
                    simplifiedTokens = simplifiedTokens.append(networkToken);
                }
                simplifiedAmounts = simplifiedAmounts.append(amounts[i]);
                continue;
            }
            for (uint256 j = 0; j < poolInteractors.length; j++) {
                if (IPoolInteractor(poolInteractors[j]).testSupported(tokens[i])) {
                    (address[] memory brokenTokens, uint256[] memory brokenAmounts) = IPoolInteractor(
                        poolInteractors[j]
                    ).getUnderlyingAmount(tokens[i], amounts[i]);
                    (address[] memory simpleTokens, uint256[] memory simpleAmounts) = _simplifyWithoutWriteERC20(
                        brokenTokens,
                        brokenAmounts,
                        poolInteractors,
                        nftPoolInteractors,
                        swappers
                    );
                    simplifiedTokens = simplifiedTokens.concat(simpleTokens);
                    simplifiedAmounts = simplifiedAmounts.concat(simpleAmounts);
                }
            }
        }
    }

    function _simplifyWithoutWriteERC721(
        Asset[] memory nfts,
        address[] memory nftPoolInteractors
    ) internal view returns (address[] memory simplifiedTokens, uint256[] memory simplifiedAmounts) {
        for (uint256 i = 0; i < nfts.length; i++) {
            for (uint256 j = 0; j < nftPoolInteractors.length; j++) {
                if (INFTPoolInteractor(nftPoolInteractors[j]).testSupported(nfts[i].manager)) {
                    (address[] memory tokens, uint256[] memory amounts) = INFTPoolInteractor(nftPoolInteractors[j])
                        .getUnderlyingAmount(nfts[i]);
                    simplifiedTokens = simplifiedTokens.concat(tokens);
                    simplifiedAmounts = simplifiedAmounts.concat(amounts);
                }
            }
        }
    }
}

contract ConversionHelper {
    using UintArray for uint256[];
    using AddressArray for address[];
    using Conversions for Conversion[];

    IUniversalSwap public parent;

    constructor() {
        parent = IUniversalSwap(msg.sender);
    }

    ///-------------Public view functions-------------
    function prepareConversions(
        address[] memory desiredERC20s,
        Asset[] memory desiredERC721s,
        uint256[] memory ratios,
        uint256 totalAvailable
    ) public view returns (Conversion[] memory conversions) {
        ratios = ratios.scale(totalAvailable);
        for (uint256 i = 0; i < desiredERC20s.length; i++) {
            conversions = conversions.concat(_getConversionsERC20(desiredERC20s[i], ratios[i]));
        }
        for (uint256 i = 0; i < desiredERC721s.length; i++) {
            conversions = conversions.concat(
                _getConversionsERC721(desiredERC721s[i], ratios[desiredERC20s.length + i])
            );
        }
    }

    function simulateConversions(
        Conversion[] memory conversions,
        address[] memory outputTokens,
        address[] memory inputTokens,
        uint256[] memory inputAmounts
    ) public view returns (uint256[] memory amounts) {
        amounts = new uint256[](conversions.length);
        uint256 amountsAdded;
        for (uint256 i = 0; i < conversions.length; i++) {
            if (conversions[i].desiredERC721.manager != address(0)) {
                (uint256 liquidity, uint256[] memory newAmounts) = _simulateConversionERC721(
                    conversions[i],
                    inputTokens,
                    inputAmounts
                );
                inputAmounts = newAmounts;
                amounts[amountsAdded] = liquidity;
                amountsAdded += 1;
            } else {
                (uint256 amountObtained, uint256[] memory newAmounts) = _simulateConversionERC20(
                    conversions[i],
                    inputTokens,
                    inputAmounts
                );
                inputAmounts = newAmounts;
                if (outputTokens.exists(conversions[i].desiredERC20) && conversions[i].underlying.length != 0) {
                    amounts[amountsAdded] = amountObtained;
                    amountsAdded += 1;
                } else {
                    inputTokens = inputTokens.append(conversions[i].desiredERC20);
                    inputAmounts.append(amountObtained);
                }
            }
        }
    }

    ///-------------Internal logic-------------
    function _getConversionsERC20(address desired, uint256 valueAllocated) internal view returns (Conversion[] memory) {
        (address[] memory underlying, uint256[] memory ratios) = _getUnderlyingERC20(desired);
        ratios = ratios.scale(valueAllocated);
        Asset memory placeholder;
        Conversion[] memory conversions;
        for (uint256 i = 0; i < underlying.length; i++) {
            if (!parent.isSimpleToken(underlying[i])) {
                Conversion[] memory underlyingConversions = _getConversionsERC20(underlying[i], ratios[i]);
                conversions = conversions.concat(underlyingConversions);
            }
        }
        Conversion memory finalConversion = Conversion(placeholder, desired, valueAllocated, underlying, ratios);
        conversions = conversions.append(finalConversion);
        return conversions;
    }

    function _getConversionsERC721(
        Asset memory nft,
        uint256 valueAllocated
    ) internal view returns (Conversion[] memory) {
        (address[] memory underlying, uint256[] memory ratios) = _getUnderlyingERC721(nft);
        ratios = ratios.scale(valueAllocated);
        Conversion[] memory conversions;
        Conversion memory finalConversion = Conversion(nft, address(0), valueAllocated, underlying, ratios);
        conversions = conversions.append(finalConversion);
        return conversions;
    }

    function _simulateConversionERC20(
        Conversion memory conversion,
        address[] memory inputTokens,
        uint256[] memory inputTokenAmounts
    ) internal view returns (uint256, uint256[] memory) {
        if (
            (conversion.underlying[0] == conversion.desiredERC20 && conversion.underlying.length == 1) ||
            conversion.desiredERC20 == address(0)
        ) {
            uint256 idx = inputTokens.findFirst(conversion.underlying[0]);
            uint256 balance = inputTokenAmounts[idx];
            inputTokenAmounts[idx] -= (balance * conversion.underlyingValues[0]) / 1e18;
            return ((balance * conversion.underlyingValues[0]) / 1e18, inputTokenAmounts);
        } else {
            uint256[] memory amounts = new uint256[](conversion.underlying.length);
            for (uint256 i = 0; i < conversion.underlying.length; i++) {
                uint256 idx = inputTokens.findFirst(conversion.underlying[i]);
                uint256 balance = inputTokenAmounts[idx];
                uint256 amountToUse = (balance * conversion.underlyingValues[i]) / 1e18;
                amounts[i] = amountToUse;
                inputTokenAmounts[idx] -= amountToUse;
            }
            address poolInteractor = parent.getProtocol(conversion.desiredERC20);
            uint256 mintable = IPoolInteractor(poolInteractor).simulateMint(
                conversion.desiredERC20,
                conversion.underlying,
                amounts
            );
            return (mintable, inputTokenAmounts);
        }
    }

    function _simulateConversionERC721(
        Conversion memory conversion,
        address[] memory inputTokens,
        uint256[] memory inputTokenAmounts
    ) internal view returns (uint256, uint256[] memory) {
        uint256[] memory amounts = new uint256[](conversion.underlying.length);
        for (uint256 j = 0; j < conversion.underlying.length; j++) {
            uint256 idx = inputTokens.findFirst(conversion.underlying[j]);
            uint256 balance = inputTokenAmounts[idx];
            uint256 amountToUse = (balance * conversion.underlyingValues[j]) / 1e18;
            inputTokenAmounts[idx] -= amountToUse;
            amounts[j] = amountToUse;
        }
        address poolInteractor = parent.getProtocol(conversion.desiredERC721.manager);
        uint256 liquidityMinted = INFTPoolInteractor(poolInteractor).simulateMint(
            conversion.desiredERC721,
            conversion.underlying,
            amounts
        );
        return (liquidityMinted, inputTokenAmounts);
    }

    function _getUnderlyingERC20(
        address token
    ) internal view returns (address[] memory underlyingTokens, uint256[] memory ratios) {
        if (parent.isSimpleToken(token)) {
            underlyingTokens = new address[](1);
            underlyingTokens[0] = token != address(0) ? token : parent.networkToken();
            ratios = new uint256[](1);
            ratios[0] = 1;
        } else {
            address poolInteractor = parent.getProtocol(token);
            if (poolInteractor != address(0)) {
                IPoolInteractor poolInteractorContract = IPoolInteractor(poolInteractor);
                (underlyingTokens, ratios) = poolInteractorContract.getUnderlyingTokens(token);
            } else {
                revert("UT"); //Unsupported Token
            }
        }
    }

    function _getUnderlyingERC721(
        Asset memory nft
    ) internal view returns (address[] memory underlying, uint256[] memory ratios) {
        address[] memory nftPoolInteractors = parent.getNFTPoolInteractors();
        for (uint256 i = 0; i < nftPoolInteractors.length; i++) {
            if (INFTPoolInteractor(nftPoolInteractors[i]).testSupported(nft.manager)) {
                INFTPoolInteractor poolInteractor = INFTPoolInteractor(nftPoolInteractors[i]);
                underlying = poolInteractor.getUnderlyingTokens(nft.pool);
                ratios = new uint256[](underlying.length);
                (int24 tick0, int24 tick1, , ) = abi.decode(nft.data, (int24, int24, uint256, uint256));
                (uint256 ratio0, uint256 ratio1) = poolInteractor.getRatio(nft.pool, tick0, tick1);
                ratios[0] = ratio0;
                ratios[1] = ratio1;
            }
        }
    }
}

contract SwapHelper is Ownable {
    using UintArray for uint256[];
    using UintArray2D for uint[][];
    using AddressArray for address[];
    using SwapFinder for SwapPoint[];
    using SwapFinder for SwapPoint;
    using Conversions for Conversion[];

    struct FindSwapsBetween {
        address tokenIn;
        address tokenOut;
        uint256 valueNeeded;
        uint256 amountInAvailable;
        uint256 valueInAvailable;
    }

    ConversionHelper public conversionHelper;
    IUniversalSwap public parent;

    constructor(
        ConversionHelper _conversionHelper
    ) {
        parent = IUniversalSwap(msg.sender);
        conversionHelper = _conversionHelper;
    }

    ///-------------Internal logic-------------
    function findMultipleSwaps(
        address[] memory inputTokens,
        uint256[] memory inputAmounts,
        uint256[] memory inputValues,
        address[] memory outputTokens,
        uint256[] memory outputValues
    ) public view returns (SwapPoint[] memory bestSwaps) {
        bestSwaps = new SwapPoint[](inputTokens.length * outputTokens.length);
        for (uint256 i = 0; i < inputTokens.length; i++) {
            for (uint256 j = 0; j < outputTokens.length; j++) {
                bestSwaps[(i * outputTokens.length) + j] = _findBestRoute(
                    FindSwapsBetween(inputTokens[i], outputTokens[j], outputValues[j], inputAmounts[i], inputValues[i])
                );
            }
        }
        bestSwaps = bestSwaps.sort();
        bestSwaps = bestSwaps.findBestSwaps(inputTokens, inputValues, inputAmounts, outputTokens, outputValues);
    }

    function getAmountsOut(
        Provided memory provided,
        Desired memory desired,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions
    ) external view returns (uint256[] memory amounts, uint256[] memory expectedUSDValues) {
        (address[] memory underlyingTokens, ) = conversions.getUnderlying();
        uint256[] memory expectedAmounts;
        (underlyingTokens, expectedAmounts) = simulateSwaps(swaps, provided.tokens, provided.amounts);
        (underlyingTokens, expectedAmounts) = underlyingTokens.shrink(expectedAmounts);
        amounts = conversionHelper.simulateConversions(conversions, desired.outputERC20s, underlyingTokens, expectedAmounts);
        expectedUSDValues = new uint256[](amounts.length);
        for (uint256 i = 0; i < desired.outputERC20s.length; i++) {
            address[] memory token = new address[](1);
            uint256[] memory amount = new uint256[](1);
            token[0] = desired.outputERC20s[i];
            amount[0] = amounts[i];
            uint256 value = parent.estimateValue(Provided(token, amount, new Asset[](0)), parent.stableToken());
            expectedUSDValues[i] = value;
        }
        for (uint256 i = 0; i < desired.outputERC721s.length; i++) {
            desired.outputERC721s[i].liquidity = amounts[desired.outputERC20s.length + i];
            Asset[] memory nft = new Asset[](1);
            nft[0] = desired.outputERC721s[i];
            uint256 value = parent.estimateValue(Provided(new address[](0), new uint256[](0), nft), parent.stableToken());
            expectedUSDValues[desired.outputERC20s.length + i] = value;
        }
    }

    function simulateSwaps(
        SwapPoint[] memory swaps,
        address[] memory tokens,
        uint256[] memory amounts
    ) public view returns (address[] memory tokensOut, uint256[] memory amountsOut) {
        tokensOut = new address[](swaps.length);
        amountsOut = new uint256[](swaps.length);

        SwapPoint[] memory swapsConducted = new SwapPoint[](swaps.length);
        uint[][][] memory amountsForSwaps = new uint[][][](swaps.length);

        for (uint256 i = 0; i < swaps.length; i++) {
            uint256 amount = (swaps[i].amountIn * amounts[tokens.findFirst(swaps[i].tokenIn)]) / 1e18;
            amountsForSwaps[i] = new uint[][](swaps[i].swappers.length);
            for (uint j = 0; j < swaps[i].swappers.length; j++) {
                uint[] memory amountsForSwap = ISwapper(swaps[i].swappers[j]).getAmountsOutWithPath(
                    amount,
                    swaps[i].paths[j],
                    amountsForSwaps,
                    swapsConducted
                );
                amount = amountsForSwap[amountsForSwap.length - 1];
                amountsForSwaps[i][j] = amountsForSwap;
            }
            tokensOut[i] = swaps[i].tokenOut;
            amountsOut[i] = amount;
            swapsConducted[i] = swaps[i];
        }
    }

    ///-------------Internal logic-------------
    function _recommendConnector(
        address tokenIn,
        address tokenOut,
        uint amount
    ) internal view returns (address[4] memory connectors) {
        uint[][] memory scoresIn;
        uint[][] memory scoresOut;
        address[] memory swappers = parent.getSwappers();
        for (uint i = 0; i < swappers.length; i++) {
            ISwapper swapper = ISwapper(swappers[i]);
            address[] memory commonPoolTokens = swapper.getCommonPoolTokens();
            for (uint j = 0; j < commonPoolTokens.length; j++) {
                address[] memory path = new address[](3);
                path[0] = tokenIn;
                path[1] = commonPoolTokens[j];
                path[2] = tokenIn;
                uint amountIn = swapper.getAmountOut(amount, path);
                uint[] memory scoreIn = new uint[](3);
                scoreIn[0] = i;
                scoreIn[1] = j;
                scoreIn[2] = amountIn;
                scoresIn = scoresIn.append(scoreIn);
                path[0] = tokenOut;
                path[2] = tokenOut;
                uint amountOut = swapper.getAmountOut(amount, path);
                uint[] memory scoreOut = new uint[](3);
                scoreOut[0] = i;
                scoreOut[1] = j;
                scoreOut[2] = amountOut;
                scoresOut = scoresOut.append(scoreOut);
            }
        }
        uint maxAmountIn;
        uint maxAmountInIndex;
        uint maxAmountOut;
        uint maxAmountOutIndex;
        for (uint i = 0; i < scoresIn.length; i++) {
            if (scoresIn[i][2] > maxAmountIn) {
                maxAmountIn = scoresIn[i][2];
                maxAmountInIndex = i;
            }
        }
        for (uint i = 0; i < scoresOut.length; i++) {
            if (scoresOut[i][2] > maxAmountOut) {
                maxAmountOut = scoresOut[i][2];
                maxAmountOutIndex = i;
            }
        }
        connectors[0] = swappers[scoresIn[maxAmountInIndex][0]];
        connectors[1] = ISwapper(swappers[scoresIn[maxAmountInIndex][0]]).getCommonPoolTokens()[
            scoresIn[maxAmountInIndex][1]
        ];
        connectors[2] = swappers[scoresOut[maxAmountOutIndex][0]];
        connectors[3] = ISwapper(swappers[scoresOut[maxAmountOutIndex][0]]).getCommonPoolTokens()[
            scoresOut[maxAmountOutIndex][1]
        ];
    }

    function _calculateRouteAmount(
        address[] memory swappersUsed,
        address[][] memory paths,
        uint amount
    ) internal view returns (uint) {
        for (uint i = 0; i < swappersUsed.length; i++) {
            amount = ISwapper(swappersUsed[i]).getAmountOut(amount, paths[i]);
        }
        return amount;
    }

    function _routeHelper(
        address[] memory swappersUsed,
        address[][] memory paths,
        uint amountIn,
        FindSwapsBetween memory swapsBetween,
        uint tokenWorth,
        uint valueIn
    ) internal view returns (SwapPoint memory, uint) {
        uint score = _calculateRouteAmount(swappersUsed, paths, amountIn);
        uint256 valueOut = (tokenWorth * score) / uint256(10) ** ERC20(swapsBetween.tokenOut).decimals();
        int256 slippage = (1e12 * (int256(valueIn) - int256(valueOut))) / int256(valueIn);
        return (
            SwapPoint(
                amountIn,
                valueIn,
                score,
                valueOut,
                slippage,
                swapsBetween.tokenIn,
                swappersUsed,
                swapsBetween.tokenOut,
                paths
            ),
            score
        );
    }

    function _findBestRoute(FindSwapsBetween memory swapsBetween) internal view returns (SwapPoint memory swapPoint) {
        uint256 amountIn = swapsBetween.valueNeeded > swapsBetween.valueInAvailable
            ? swapsBetween.amountInAvailable
            : (swapsBetween.valueNeeded * swapsBetween.amountInAvailable) / swapsBetween.valueInAvailable;
        uint256 valueIn = (amountIn * swapsBetween.valueInAvailable) / swapsBetween.amountInAvailable;
        address[] memory swappers = parent.getSwappers();
        uint256 tokenWorth = IOracle(parent.oracle()).getPrice(swapsBetween.tokenOut, parent.networkToken());
        address[4] memory connectors = _recommendConnector(swapsBetween.tokenIn, swapsBetween.tokenOut, amountIn);
        SwapPoint[] memory swaps = new SwapPoint[](swappers.length + 3);
        uint[] memory scores = new uint[](swappers.length + 3);
        for (uint i = 0; i < swappers.length; i++) {
            address[][] memory paths = new address[][](1);
            paths[0] = new address[](2);
            paths[0][0] = swapsBetween.tokenIn;
            paths[0][1] = swapsBetween.tokenOut;
            address[] memory swappersUsed = new address[](1);
            swappersUsed[0] = swappers[i];
            (swaps[i], scores[i]) = _routeHelper(swappersUsed, paths, amountIn, swapsBetween, tokenWorth, valueIn);
        }
        {
            address[][] memory paths = new address[][](1);
            paths[0] = new address[](3);
            paths[0][0] = swapsBetween.tokenIn;
            paths[0][1] = connectors[1];
            paths[0][2] = swapsBetween.tokenOut;
            address[] memory swappersUsed = new address[](1);
            swappersUsed[0] = connectors[0];
            (swaps[swappers.length], scores[swappers.length]) = _routeHelper(
                swappersUsed,
                paths,
                amountIn,
                swapsBetween,
                tokenWorth,
                valueIn
            );
        }
        {
            address[][] memory paths = new address[][](1);
            paths[0] = new address[](3);
            paths[0][0] = swapsBetween.tokenIn;
            paths[0][1] = connectors[3];
            paths[0][2] = swapsBetween.tokenOut;
            address[] memory swappersUsed = new address[](1);
            swappersUsed[0] = connectors[2];
            (swaps[swappers.length + 1], scores[swappers.length + 1]) = _routeHelper(
                swappersUsed,
                paths,
                amountIn,
                swapsBetween,
                tokenWorth,
                valueIn
            );
        }
        {
            address[][] memory paths;
            address[] memory swappersUsed;
            if (connectors[0] != connectors[2]) {
                paths = new address[][](2);
                swappersUsed = new address[](2);
                paths[0] = new address[](2);
                paths[0][0] = swapsBetween.tokenIn;
                paths[0][1] = connectors[1];
                paths[1] = new address[](3);
                paths[1][0] = connectors[1];
                paths[1][1] = connectors[3];
                paths[1][2] = swapsBetween.tokenOut;
                swappersUsed[0] = connectors[0];
                swappersUsed[1] = connectors[2];
            } else {
                paths = new address[][](1);
                swappersUsed = new address[](1);
                swappersUsed[0] = connectors[0];
                paths[0] = new address[](4);
                paths[0][0] = swapsBetween.tokenIn;
                paths[0][1] = connectors[1];
                paths[0][2] = connectors[3];
                paths[0][3] = swapsBetween.tokenOut;
            }
            (swaps[swappers.length + 2], scores[swappers.length + 2]) = _routeHelper(
                swappersUsed,
                paths,
                amountIn,
                swapsBetween,
                tokenWorth,
                valueIn
            );
        }
        uint maxScore;
        uint bestScoreIndex;
        for (uint i = 0; i < scores.length; i++) {
            if (scores[i] > maxScore) {
                maxScore = scores[i];
                bestScoreIndex = i;
            }
        }
        return swaps[bestScoreIndex];
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/IPoolInteractor.sol";
import "./interfaces/ISwapper.sol";
import "./interfaces/IUniversalSwap.sol";
import "./interfaces/IWETH.sol";
import "./libraries/UintArray.sol";
import "./libraries/AddressArray.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./libraries/Conversions.sol";
import "./libraries/SaferERC20.sol";
import "./SwapHelpers.sol";
import "hardhat/console.sol";

contract UniversalSwap is IUniversalSwap, Ownable {
    using Address for address;
    using UintArray for uint256[];
    using AddressArray for address[];
    using SaferERC20 for IERC20;
    using Conversions for Conversion[];
    using SwapFinder for SwapPoint;

    event NFTMinted(address manager, uint256 tokenId, address pool);
    event AssetsSent(address receiver, address[] tokens, address[] managers, uint256[] amountsAndIds);

    address public networkToken;
    address public stableToken;
    address[] public swappers;
    address[] public poolInteractors;
    address[] public nftPoolInteractors;
    address public oracle;
    ProvidedHelper public providedHelper;
    ConversionHelper public conversionHelper; 
    SwapHelper public swapHelper;

    constructor(
        address[] memory _poolInteractors,
        address[] memory _nftPoolInteractors,
        address _networkToken,
        address _stableToken,
        address[] memory _swappers,
        address _oracle
    ) {
        poolInteractors = _poolInteractors;
        nftPoolInteractors = _nftPoolInteractors;
        swappers = _swappers;
        networkToken = _networkToken;
        stableToken = _stableToken;
        oracle = _oracle;

        providedHelper = new ProvidedHelper();
        conversionHelper = new ConversionHelper();
        swapHelper = new SwapHelper(conversionHelper);
        swapHelper.transferOwnership(msg.sender);
    }

    ///-------------Public view functions-------------

    function getSwappers() external view returns (address[] memory) {
        return swappers;
    }

    function getPoolInteractors() external view returns (address[] memory) {
        return poolInteractors;
    }

    function getNFTPoolInteractors() external view returns (address[] memory) {
        return nftPoolInteractors;
    }

    /// @inheritdoc IUniversalSwap
    function isSimpleToken(address token) public view returns (bool) {
        if (token == networkToken || token == address(0)) return true;
        for (uint256 i = 0; i < swappers.length; i++) {
            if (ISwapper(swappers[i]).checkSwappable(token)) {
                return true;
            }
        }
        return false;
    }

    /// @inheritdoc IUniversalSwap
    function getProtocol(address token) public view returns (address) {
        if (isSimpleToken(token)) return address(0);
        for (uint256 x = 0; x < poolInteractors.length; x++) {
            if (IPoolInteractor(poolInteractors[x]).testSupported(token)) return poolInteractors[x];
        }
        for (uint256 i = 0; i < nftPoolInteractors.length; i++) {
            if (INFTPoolInteractor(nftPoolInteractors[i]).testSupported(token)) return nftPoolInteractors[i];
        }
        return address(0);
    }

    /// @inheritdoc IUniversalSwap
    function getTokenValues(
        address[] memory tokens,
        uint256[] memory tokenAmounts
    ) public view returns (uint256[] memory values, uint256 total) {
        values = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            values[i] = (IOracle(oracle).getPrice(tokens[i], networkToken) * tokenAmounts[i]) / uint256(10) ** ERC20(tokens[i]).decimals();
            total += values[i];
        }
    }

    /// @inheritdoc IUniversalSwap
    function estimateValue(Provided memory assets, address inTermsOf) public view returns (uint256) {
        (address[] memory tokens, uint256[] memory amounts) = providedHelper.simplifyWithoutWrite(assets);
        (, uint256 value) = getTokenValues(tokens, amounts);
        value = (IOracle(oracle).getPrice(networkToken, inTermsOf) * value) / uint256(10) ** ERC20(networkToken).decimals();
        return value;
    }

    /// @inheritdoc IUniversalSwap
    function isSupported(address token) public view returns (bool) {
        if (isSimpleToken(token)) return true;
        if (getProtocol(token) != address(0)) return true;
        return false;
    }

    /// @inheritdoc IUniversalSwap
    function estimateValueERC20(address token, uint256 amount, address inTermsOf) public view returns (uint256) {
        address[] memory tokens = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        tokens[0] = token;
        amounts[0] = amount;
        Provided memory asset = Provided(tokens, amounts, new Asset[](0));
        return estimateValue(asset, inTermsOf);
    }

    /// @inheritdoc IUniversalSwap
    function estimateValueERC721(Asset memory nft, address inTermsOf) public view returns (uint256) {
        Asset[] memory assets = new Asset[](1);
        assets[0] = nft;
        return estimateValue(Provided(new address[](0), new uint256[](0), assets), inTermsOf);
    }

    /// @inheritdoc IUniversalSwap
    function getUnderlying(Provided memory provided) external view returns (address[] memory, uint256[] memory) {
        return providedHelper.simplifyWithoutWrite(provided);
    }

    ///-------------Pre-swap calculations-------------
    function getAmountsOut(
        Provided memory provided,
        Desired memory desired
    )
        external
        view
        returns (
            uint256[] memory amounts,
            SwapPoint[] memory swaps,
            Conversion[] memory conversions,
            uint256[] memory expectedUSDValues
        )
    {
        (swaps, conversions) = preSwapCalculateSwaps(provided, desired);
        (amounts, expectedUSDValues) = SwapHelper(swapHelper).getAmountsOut(provided, desired, swaps, conversions);
    }

    function getAmountsOutWithSwaps(
        Provided memory provided,
        Desired memory desired,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions
    ) external view returns (uint[] memory amounts, uint[] memory expectedUSDValues) {
        for (uint256 i = 0; i < provided.tokens.length; i++) {
            if (provided.tokens[i] == address(0)) {
                provided.tokens[i] = networkToken;
            }
        }
        (provided.tokens, provided.amounts) = providedHelper.simplifyWithoutWrite(provided);
        (amounts, expectedUSDValues) = SwapHelper(swapHelper).getAmountsOut(provided, desired, swaps, conversions);
    }

    function preSwapCalculateUnderlying(
        Provided memory provided,
        Desired memory desired
    )
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            Conversion[] memory,
            address[] memory,
            uint256[] memory
        )
    {
        for (uint256 i = 0; i < provided.tokens.length; i++) {
            if (provided.tokens[i] == address(0)) {
                provided.tokens[i] = networkToken;
            }
        }
        (provided.tokens, provided.amounts) = providedHelper.simplifyWithoutWrite(provided);
        uint256 totalValue;
        uint256[] memory inputTokenValues;
        (inputTokenValues, totalValue) = getTokenValues(provided.tokens, provided.amounts);
        Conversion[] memory conversions = conversionHelper.prepareConversions(
            desired.outputERC20s,
            desired.outputERC721s,
            desired.ratios,
            totalValue
        );
        (address[] memory conversionUnderlying, uint256[] memory conversionUnderlyingValues) = conversions
            .getUnderlying();
        (conversionUnderlying, conversionUnderlyingValues) = conversionUnderlying.shrink(conversionUnderlyingValues);
        conversions = conversions.normalizeRatios();
        return (
            provided.tokens,
            provided.amounts,
            inputTokenValues,
            conversions,
            conversionUnderlying,
            conversionUnderlyingValues
        );
    }

    /// @inheritdoc IUniversalSwap
    function preSwapCalculateSwaps(
        Provided memory provided,
        Desired memory desired
    ) public view returns (SwapPoint[] memory swaps, Conversion[] memory conversions) {
        uint256[] memory inputTokenValues;
        address[] memory conversionUnderlying;
        uint256[] memory conversionUnderlyingValues;
        (
            provided.tokens,
            provided.amounts,
            inputTokenValues,
            conversions,
            conversionUnderlying,
            conversionUnderlyingValues
        ) = preSwapCalculateUnderlying(provided, desired);
        swaps = swapHelper.findMultipleSwaps(
            provided.tokens,
            provided.amounts,
            inputTokenValues,
            conversionUnderlying,
            conversionUnderlyingValues
        );
        return (swaps, conversions);
    }

    ///-------------Core logic-------------
    /// @inheritdoc IUniversalSwap
    function swapAfterTransfer(
        Provided memory provided,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions,
        Desired memory desired,
        address receiver
    ) external payable returns (uint256[] memory) {
        uint addressZeroIndex = provided.tokens.findFirst(address(0));
        if (addressZeroIndex != provided.tokens.length) {
            provided.tokens = provided.tokens.remove(addressZeroIndex);
            provided.amounts = provided.amounts.remove(addressZeroIndex);
        }
        (provided.tokens, provided.amounts) = _break(provided.tokens, provided.amounts, provided.nfts);
        provided.nfts = new Asset[](0);
        return _swap(provided, swaps, conversions, desired, receiver);
    }

    /// @inheritdoc IUniversalSwap
    function swap(
        Provided memory provided,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions,
        Desired memory desired,
        address receiver
    ) external payable returns (uint256[] memory) {
        (provided.tokens, provided.amounts) = _collectAndBreak(provided.tokens, provided.amounts, provided.nfts);
        provided.nfts = new Asset[](0);
        return _swap(provided, swaps, conversions, desired, receiver);
    }

    ///-------------Permissioned functions-------------
    function setSwappers(address[] calldata _swappers) external onlyOwner {
        swappers = _swappers;
    }

    function setOracle(address _oracle) external onlyOwner {
        oracle = _oracle;
    }

    function setPoolInteractors(address[] calldata _poolInteractors) external onlyOwner {
        poolInteractors = _poolInteractors;
    }

    function setNFTPoolInteractors(address[] calldata _nftPoolInteractors) external onlyOwner {
        nftPoolInteractors = _nftPoolInteractors;
    }

    ///-------------Internal logic-------------
    function _addWETH(
        address[] memory tokens,
        uint256[] memory amounts
    ) internal returns (address[] memory, uint256[] memory) {
        uint256 startingBalance = IERC20(networkToken).balanceOf(address(this));
        if (msg.value > 0) {
            IWETH(payable(networkToken)).deposit{value: msg.value}();
        }
        if (address(this).balance > 0) {
            IWETH(payable(networkToken)).deposit{value: address(this).balance}();
        }
        uint256 ethSupplied = IERC20(networkToken).balanceOf(address(this)) - startingBalance;
        if (ethSupplied > 0) {
            tokens = tokens.append(networkToken);
            amounts = amounts.append(ethSupplied);
        }
        uint addressZeroIndex = tokens.findFirst(address(0));
        if (addressZeroIndex != tokens.length) {
            tokens.remove(addressZeroIndex);
            amounts.remove(addressZeroIndex);
        }
        return (tokens, amounts);
    }

    function _burn(
        address token,
        uint256 amount
    ) internal returns (address[] memory underlyingTokens, uint256[] memory underlyingTokenAmounts) {
        address poolInteractor = getProtocol(token);
        bytes memory data = poolInteractor.functionDelegateCall(
            abi.encodeWithSelector(IPoolInteractor(poolInteractor).burn.selector, token, amount, poolInteractor)
        );
        (underlyingTokens, underlyingTokenAmounts) = abi.decode(data, (address[], uint256[]));
    }

    function _mint(
        address toMint,
        address[] memory underlyingTokens,
        uint256[] memory underlyingAmounts,
        address receiver
    ) internal returns (uint256 amountMinted) {
        if (toMint == underlyingTokens[0]) return underlyingAmounts[0];
        if (toMint == address(0)) {
            IWETH(payable(networkToken)).withdraw(underlyingAmounts[0]);
            payable(receiver).transfer(underlyingAmounts[0]);
            return underlyingAmounts[0];
        }
        address poolInteractor = getProtocol(toMint);
        bytes memory returnData = poolInteractor.functionDelegateCall(
            abi.encodeWithSelector(
                IPoolInteractor(poolInteractor).mint.selector,
                toMint,
                underlyingTokens,
                underlyingAmounts,
                receiver,
                poolInteractor
            )
        );
        amountMinted = abi.decode(returnData, (uint256));
    }

    function _simplifyInputTokens(
        address[] memory inputTokens,
        uint256[] memory inputTokenAmounts
    ) internal returns (address[] memory, uint256[] memory) {
        bool allSimiplified = true;
        address[] memory updatedTokens = inputTokens;
        uint256[] memory updatedTokenAmounts = inputTokenAmounts;
        for (uint256 i = 0; i < inputTokens.length; i++) {
            if (!isSimpleToken(inputTokens[i])) {
                allSimiplified = false;
                (address[] memory newTokens, uint256[] memory newTokenAmounts) = _burn(
                    inputTokens[i],
                    inputTokenAmounts[i]
                );
                updatedTokens[i] = newTokens[0];
                updatedTokenAmounts[i] = newTokenAmounts[0];
                address[] memory tempTokens = new address[](updatedTokens.length + newTokens.length - 1);
                uint256[] memory tempTokenAmounts = new uint256[](
                    updatedTokenAmounts.length + newTokenAmounts.length - 1
                );
                uint256 j = 0;
                while (j < updatedTokens.length) {
                    tempTokens[j] = updatedTokens[j];
                    tempTokenAmounts[j] = updatedTokenAmounts[j];
                    j++;
                }
                uint256 k = 0;
                while (k < newTokens.length - 1) {
                    tempTokens[j + k] = newTokens[k + 1];
                    tempTokenAmounts[j + k] = newTokenAmounts[k + 1];
                    k++;
                }
                updatedTokens = tempTokens;
                updatedTokenAmounts = tempTokenAmounts;
            }
        }
        if (allSimiplified) {
            return (inputTokens, inputTokenAmounts);
        } else {
            return _simplifyInputTokens(updatedTokens, updatedTokenAmounts);
        }
    }

    function _collectAndBreak(
        address[] memory inputTokens,
        uint256[] memory inputTokenAmounts,
        Asset[] memory inputNFTs
    ) internal returns (address[] memory, uint256[] memory) {
        for (uint256 i = 0; i < inputTokenAmounts.length; i++) {
            if (inputTokens[i] == address(0)) continue;
            IERC20(inputTokens[i]).safeTransferFrom(msg.sender, address(this), inputTokenAmounts[i]);
        }
        for (uint256 i = 0; i < inputNFTs.length; i++) {
            IERC721(inputNFTs[i].manager).transferFrom(msg.sender, address(this), inputNFTs[i].tokenId);
        }
        return _break(inputTokens, inputTokenAmounts, inputNFTs);
    }

    function _break(
        address[] memory inputTokens,
        uint256[] memory inputTokenAmounts,
        Asset[] memory inputNFTs
    ) internal returns (address[] memory, uint256[] memory) {
        for (uint256 i = 0; i < inputNFTs.length; i++) {
            Asset memory nft = inputNFTs[i];
            address nftPoolInteractor = getProtocol(nft.manager);
            if (nftPoolInteractor == address(0)) revert("UT");
            bytes memory returnData = nftPoolInteractor.functionDelegateCall(
                abi.encodeWithSelector(INFTPoolInteractor(nftPoolInteractor).burn.selector, nft)
            );
            (address[] memory nftTokens, uint256[] memory nftTokenAmounts) = abi.decode(
                returnData,
                (address[], uint256[])
            );
            inputTokens = inputTokens.concat(nftTokens);
            inputTokenAmounts = inputTokenAmounts.concat(nftTokenAmounts);
        }
        (address[] memory simplifiedTokens, uint256[] memory simplifiedTokenAmounts) = _simplifyInputTokens(
            inputTokens,
            inputTokenAmounts
        );
        (simplifiedTokens, simplifiedTokenAmounts) = _addWETH(simplifiedTokens, simplifiedTokenAmounts);
        (simplifiedTokens, simplifiedTokenAmounts) = simplifiedTokens.shrink(simplifiedTokenAmounts);
        return (simplifiedTokens, simplifiedTokenAmounts);
    }

    function _conductERC20Conversion(
        Conversion memory conversion,
        address receiver,
        address[] memory tokensAvailable,
        uint256[] memory amountsAvailable
    ) internal returns (uint256) {
        if ((conversion.underlying[0] == conversion.desiredERC20 && conversion.underlying.length == 1)) {
            uint256 tokenToUseIndex = tokensAvailable.findFirst(conversion.underlying[0]);
            uint256 balance = amountsAvailable[tokenToUseIndex];
            uint256 amountToUse = (balance * conversion.underlyingValues[0]) / 1e18;
            IERC20(conversion.underlying[0]).safeTransfer(receiver, amountToUse);
            amountsAvailable[tokenToUseIndex] -= amountToUse;
            return amountToUse;
        } else {
            uint256[] memory inputTokenAmounts = new uint256[](conversion.underlying.length);
            for (uint256 i = 0; i < conversion.underlying.length; i++) {
                uint256 tokenToUseIndex = tokensAvailable.findFirst(conversion.underlying[i]);
                uint256 balance = amountsAvailable[tokenToUseIndex];
                uint256 amountToUse = (balance * conversion.underlyingValues[i]) / 1e18;
                amountsAvailable[tokenToUseIndex] -= amountToUse;
                inputTokenAmounts[i] = amountToUse;
            }
            return _mint(conversion.desiredERC20, conversion.underlying, inputTokenAmounts, receiver);
        }
    }

    function _conductERC721Conversion(
        Conversion memory conversion,
        address receiver,
        address[] memory tokensAvailable,
        uint256[] memory amountsAvailable
    ) internal returns (uint256) {
        Asset memory nft = conversion.desiredERC721;
        address nftPoolInteractor = getProtocol(nft.manager);
        if (nftPoolInteractor == address(0)) revert("UT");
        uint256[] memory inputTokenAmounts = new uint256[](conversion.underlying.length);
        for (uint256 j = 0; j < conversion.underlying.length; j++) {
            uint256 tokenToUseIndex = tokensAvailable.findFirst(conversion.underlying[j]);
            uint256 balance = amountsAvailable[tokenToUseIndex];
            uint256 amountToUse = (balance * conversion.underlyingValues[j]) / 1e18;
            amountsAvailable[tokenToUseIndex] -= amountToUse;
            // uint balance = IERC20(conversion.underlying[j]).balanceOf(address(this));
            // uint amountToUse = balance*conversion.underlyingValues[j]/1e18;
            inputTokenAmounts[j] = amountToUse;
        }
        bytes memory returnData = nftPoolInteractor.functionDelegateCall(
            abi.encodeWithSelector(
                INFTPoolInteractor(nftPoolInteractor).mint.selector,
                nft,
                conversion.underlying,
                inputTokenAmounts,
                receiver
            )
        );
        uint256 tokenId = abi.decode(returnData, (uint256));
        emit NFTMinted(nft.manager, tokenId, nft.pool);
        return tokenId;
    }

    function _conductConversions(
        Conversion[] memory conversions,
        address[] memory outputTokens,
        uint256[] memory minAmountsOut,
        address receiver,
        address[] memory tokensAvailable,
        uint256[] memory amountsAvailable
    ) internal returns (uint256[] memory amounts) {
        amounts = new uint256[](conversions.length);
        uint256 amountsAdded;
        for (uint256 i = 0; i < conversions.length; i++) {
            if (conversions[i].desiredERC721.manager != address(0)) {
                uint256 tokenId = _conductERC721Conversion(conversions[i], receiver, tokensAvailable, amountsAvailable);
                amounts[amountsAdded] = tokenId;
                amountsAdded += 1;
            } else {
                uint256 amountObtained = _conductERC20Conversion(
                    conversions[i],
                    receiver,
                    tokensAvailable,
                    amountsAvailable
                );
                if (outputTokens.exists(conversions[i].desiredERC20) && conversions[i].underlying.length != 0) {
                    amounts[amountsAdded] = amountObtained;
                    require(amountObtained >= minAmountsOut[amountsAdded], "3");
                    amountsAdded += 1;
                }
            }
        }
    }

    receive() external payable {}

    function _conductSwaps(
        SwapPoint[] memory swaps,
        address[] memory tokens,
        uint256[] memory amounts
    ) internal returns (address[] memory tokensObtained, uint256[] memory amountsObtained) {
        tokensObtained = new address[](swaps.length);
        amountsObtained = new uint256[](swaps.length);
        for (uint256 i = 0; i < swaps.length; i++) {
            uint256 amount = (swaps[i].amountIn * amounts[tokens.findFirst(swaps[i].tokenIn)]) / 1e18;
            for (uint256 j = 0; j < swaps[i].swappers.length; j++) {
                bytes memory returnData = swaps[i].swappers[j].functionDelegateCall(
                    abi.encodeWithSelector(
                        ISwapper(swaps[i].swappers[j]).swap.selector,
                        amount,
                        swaps[i].paths[j],
                        swaps[i].swappers[j]
                    )
                );
                amount = abi.decode(returnData, (uint256));
            }
            tokensObtained[i] = swaps[i].tokenOut;
            amountsObtained[i] = amount;
        }
        (tokensObtained, amountsObtained) = tokensObtained.shrink(amountsObtained);
    }

    function _swap(
        Provided memory provided,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions,
        Desired memory desired,
        address receiver
    ) internal returns (uint256[] memory) {
        if (swaps.length == 0 || conversions.length == 0) {
            (swaps, conversions) = preSwapCalculateSwaps(provided, desired);
        }
        require(provided.tokens.length > 0, "4");
        (address[] memory tokensAfterSwap, uint256[] memory amountsAfterSwap) = _conductSwaps(
            swaps,
            provided.tokens,
            provided.amounts
        );
        uint256[] memory amountsAndIds = _conductConversions(
            conversions,
            desired.outputERC20s,
            desired.minAmountsOut,
            receiver,
            tokensAfterSwap,
            amountsAfterSwap
        );
        address[] memory managers = new address[](desired.outputERC721s.length);
        for (uint256 i = 0; i < managers.length; i++) {
            managers[i] = desired.outputERC721s[i].manager;
        }
        emit AssetsSent(msg.sender, desired.outputERC20s, managers, amountsAndIds);
        return amountsAndIds;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

/// @notice
/// @param pool Address of liquidity pool
/// @param manager NFT manager contract, such as uniswap V3 positions manager
/// @param tokenId ID representing NFT
/// @param liquidity Amount of liquidity, used when converting part of the NFT to some other asset
/// @param data Data used when creating the NFT position, contains int24 tickLower, int24 tickUpper, uint minAmount0 and uint minAmount1
struct Asset {
    address pool;
    address manager;
    uint tokenId;
    uint liquidity;
    bytes data;
}

interface INFTPoolInteractor {
    function burn(
        Asset memory asset
    ) external payable returns (address[] memory receivedTokens, uint256[] memory receivedTokenAmounts);

    function mint(
        Asset memory toMint,
        address[] memory underlyingTokens,
        uint256[] memory underlyingAmounts,
        address receiver
    ) external payable returns (uint256);

    function simulateMint(
        Asset memory toMint,
        address[] memory underlyingTokens,
        uint[] memory underlyingAmounts
    ) external view returns (uint);

    function getRatio(address poolAddress, int24 tick0, int24 tick1) external view returns (uint, uint);

    function testSupported(address token) external view returns (bool);

    function testSupportedPool(address token) external view returns (bool);

    function getUnderlyingAmount(
        Asset memory nft
    ) external view returns (address[] memory underlying, uint[] memory amounts);

    function getUnderlyingTokens(address lpTokenAddress) external view returns (address[] memory);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

interface IOracle {
    /// @notice Gives price of token in terms of another token
    function getPrice(address token, address inTermsOf) external view returns (uint);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/SaferERC20.sol";
import "hardhat/console.sol";

interface IPoolInteractor {
    event Burn(address lpTokenAddress, uint256 amount);

    function burn(
        address lpTokenAddress,
        uint256 amount,
        address self
    ) external payable returns (address[] memory, uint256[] memory);

    function mint(
        address toMint,
        address[] memory underlyingTokens,
        uint256[] memory underlyingAmounts,
        address receiver,
        address self
    ) external payable returns (uint256);

    function simulateMint(
        address toMint,
        address[] memory underlyingTokens,
        uint[] memory underlyingAmounts
    ) external view returns (uint);

    function testSupported(address lpToken) external view returns (bool);

    function getUnderlyingAmount(
        address lpTokenAddress,
        uint amount
    ) external view returns (address[] memory underlying, uint[] memory amounts);

    function getUnderlyingTokens(address poolAddress) external view returns (address[] memory, uint[] memory);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

import "../libraries/SwapFinder.sol";

interface ISwapper {
    event Burn(address holderAddress, uint256 amount);

    function getCommonPoolTokens() external view returns (address[] memory);

    function swap(uint256 amount, address[] memory path, address self) external payable returns (uint256);

    function getAmountOut(uint256 amount, address[] memory path) external view returns (uint256);

    function getAmountsOutWithPath(
        uint256 amount,
        address[] memory path,
        uint[][][] memory amountsForSwaps,
        SwapPoint[] memory priorSwaps
    ) external view returns (uint256[] memory);

    function checkSwappable(address token) external view returns (bool);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

import "./INFTPoolInteractor.sol";
import "../libraries/SwapFinder.sol";
import "../libraries/Conversions.sol";

struct Desired {
    address[] outputERC20s;
    Asset[] outputERC721s;
    uint256[] ratios;
    uint256[] minAmountsOut;
}

struct Provided {
    address[] tokens;
    uint256[] amounts;
    Asset[] nfts;
}

/// @title Interface for UniversalSwap utility
/// @notice UniversalSwap allows trading between pool tokens and tokens tradeable on DEXes
interface IUniversalSwap {
    /// Getters
    function networkToken() external view returns (address tokenAddress);
    function oracle() external view returns (address oracle);
    function stableToken() external view returns (address stableToken);
    function getSwappers() external view returns (address[] memory swappers);
    function getPoolInteractors() external view returns (address[] memory poolInteractors);
    function getNFTPoolInteractors() external view returns (address[] memory nftPoolInteractors);

    /// @notice Checks if a provided token is composed of other underlying tokens or not
    function isSimpleToken(address token) external view returns (bool);

    /// @notice Get the pool interactor for a token
    function getProtocol(address token) external view returns (address);

    /// @notice get values of provided tokens and amounts in terms of network token
    function getTokenValues(
        address[] memory tokens,
        uint256[] memory tokenAmounts
    ) external view returns (uint256[] memory values, uint256 total);

    /// @notice Estimates the combined values of the provided tokens in terms of another token
    /// @param assets ERC20 or ERC721 assets for whom the value needs to be estimated
    /// @param inTermsOf Token whose value equivalent value to the provided tokens needs to be returned
    /// @return value The amount of inTermsOf that is equal in value to the provided tokens
    function estimateValue(Provided memory assets, address inTermsOf) external view returns (uint256 value);

    /// @notice Checks if a provided token is swappable using UniversalSwap
    /// @param token Address of token to be swapped or swapped for
    /// @return supported Wether the provided token is supported or not
    function isSupported(address token) external returns (bool supported);

    /// @notice Estimates the value of a single ERC20 token in terms of another ERC20 token
    function estimateValueERC20(address token, uint256 amount, address inTermsOf) external view returns (uint256 value);

    /// @notice Estimates the value of an ECR721 token in terms of an ERC20 token
    function estimateValueERC721(Asset memory nft, address inTermsOf) external view returns (uint256 value);

    /// @notice Find the underlying tokens and amounts for some complex tokens
    function getUnderlying(
        Provided memory provided
    ) external view returns (address[] memory underlyingTokens, uint256[] memory underlyingAmounts);

    /// @notice Performs the pre swap computation and calculates the approximate amounts and corresponding usd values that can be expected from the swap
    /// @return amounts Amounts of the desired assets that can be expected to be received during the actual swap
    /// @return swaps Swaps that need to be performed with the provided assets
    /// @return conversions List of conversions from simple ERC20 tokens to complex assets such as LP tokens, Uniswap v3 positions, etc
    /// @return expectedUSDValues Expected usd values for the assets that can be expected from the swap
    function getAmountsOut(
        Provided memory provided,
        Desired memory desired
    )
        external
        view
        returns (
            uint256[] memory amounts,
            SwapPoint[] memory swaps,
            Conversion[] memory conversions,
            uint256[] memory expectedUSDValues
        );

    /// @notice The pre swap computations can be performed off-chain much faster, hence this function was created as a faster alternative to getAmountsOut
    /// @notice Calculates the expected amounts and usd values from a swap given the pre swap calculations
    function getAmountsOutWithSwaps(
        Provided memory provided,
        Desired memory desired,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions
    ) external view returns (uint[] memory amounts, uint[] memory expectedUSDValues);

    /// @notice Calculate the underlying tokens, amount and values for provided assets in a swap, as well
    /// as the conversions needed to obtain desired assets along with the conversion underlying and the value that needs to be allocated to each underlying
    /// @param provided List of provided ERC20/ERC721 assets provided to convert into the desired assets
    /// @param desired Assets to convert provided assets into
    /// @return tokens Tokens that can be obtained by breaking down complex assets in provided
    /// @return amounts Amounts of tokens that will be obtained from breaking down provided assetts
    /// @return values Worth of the amounts of tokens, in terms of usd or network token (not relevant which for purpose of swapping)
    /// @return conversions Data structures representing the conversions that need to take place from simple assets to complex assets to obtain the desired assets
    /// @return conversionUnderlying The simplest tokens needed in order to perform the previously mentioned conversions
    /// @return conversionUnderlyingValues The values in terms of usd or network token that need to be allocated to each of the underlying tokens in order to perform the conversions
    function preSwapCalculateUnderlying(
        Provided memory provided,
        Desired memory desired
    )
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory amounts,
            uint256[] memory values,
            Conversion[] memory conversions,
            address[] memory conversionUnderlying,
            uint256[] memory conversionUnderlyingValues
        );

    /// @notice Calculates the swaps and conversions that need to be performed prior to calling swap/swapAfterTransfer
    /// @notice It is recommended to use this function and provide the return values to swap/swapAfterTransfer as that greatly reduces gas consumption
    /// @return swaps Swaps that need to be performed with the provided assets
    /// @return conversions List of conversions from simple ERC20 tokens to complex assets such as LP tokens, Uniswap v3 positions, etc
    function preSwapCalculateSwaps(
        Provided memory provided,
        Desired memory desired
    ) external view returns (SwapPoint[] memory swaps, Conversion[] memory conversions);

    /// @notice Swap provided assets into desired assets
    /// @dev Before calling, make sure UniversalSwap contract has approvals to transfer provided assets
    /// @dev swaps ans conversions can be provided as empty list, in which case the contract will calculate them, but this will result in high gas usage
    /// @param provided List of provided ERC20/ERC721 assets provided to convert into the desired assets
    /// @param swaps Swaps that need to be performed with the provided assets
    /// @param conversions List of conversions from simple ERC20 tokens to complex assets such as LP tokens, Uniswap v3 positions, etc
    /// @param desired Assets to convert provided assets into
    /// @param receiver Address that will receive output desired assets
    /// @return amountsAndIds Amount of outputTokens obtained and Token IDs for output NFTs
    function swap(
        Provided memory provided,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions,
        Desired memory desired,
        address receiver
    ) external payable returns (uint256[] memory amountsAndIds);

    /// @notice Functions just like swap, but assets are transferred to universal swap contract before calling this function rather than using approval
    /// @notice Implemented as a way to save gas by eliminating needless transfers
    /// @dev Before calling, make sure all assets in provided have been transferred to universal swap contract
    /// @param provided List of provided ERC20/ERC721 assets provided to convert into the desired assets
    /// @param swaps Swaps that need to be performed with the provided assets. Can be provided as empty list, in which case it will be calculated by the contract
    /// @param conversions List of conversions from simple ERC20 tokens to complex assets such as LP tokens, Uniswap v3 positions, etc. Can be provided as empty list.
    /// @param desired Assets to convert provided assets into
    /// @param receiver Address that will receive output desired assets
    /// @return amountsAndIds Amount of outputTokens obtained and Token IDs for output NFTs
    function swapAfterTransfer(
        Provided memory provided,
        SwapPoint[] memory swaps,
        Conversion[] memory conversions,
        Desired memory desired,
        address receiver
    ) external payable returns (uint256[] memory amountsAndIds);

    /// Setters
    function setSwappers(address[] calldata _swappers) external;
    function setOracle(address _oracle) external;
    function setPoolInteractors(address[] calldata _poolInteractors) external;
    function setNFTPoolInteractors(address[] calldata _nftPoolInteractors) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

interface IWETH {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    receive() external payable;

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

import "hardhat/console.sol";

library AddressArray {
    function concat(address[] memory self, address[] memory array) internal pure returns (address[] memory) {
        address[] memory newArray = new address[](self.length + array.length);
        for (uint i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        for (uint i = 0; i < array.length; i++) {
            newArray[i + self.length] = array[i];
        }
        return newArray;
    }

    function append(address[] memory self, address element) internal pure returns (address[] memory) {
        address[] memory newArray = new address[](self.length + 1);
        for (uint i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        newArray[self.length] = element;
        return newArray;
    }

    function remove(address[] memory self, uint index) internal pure returns (address[] memory newArray) {
        newArray = new address[](self.length - 1);
        uint elementsAdded;
        for (uint i = 0; i < self.length; i++) {
            if (i != index) {
                newArray[elementsAdded] = self[i];
                elementsAdded += 1;
            }
        }
        return newArray;
    }

    function findAll(address[] memory self, address toFind) internal pure returns (uint[] memory) {
        uint[] memory indices;
        uint numMatching;
        for (uint i = 0; i < self.length; i++) {
            if (self[i] == toFind) {
                numMatching += 1;
            }
        }
        if (numMatching == 0) {
            return indices;
        }
        indices = new uint[](numMatching);
        uint numPushed = 0;
        for (uint i = 0; i < self.length; i++) {
            if (self[i] == toFind) {
                indices[numPushed] = i;
                numPushed += 1;
                if (numPushed == numMatching) {
                    return indices;
                }
            }
        }
        return indices;
    }

    function findFirst(address[] memory self, address toFind) internal pure returns (uint) {
        for (uint i = 0; i < self.length; i++) {
            if (self[i] == toFind) {
                return i;
            }
        }
        return self.length;
    }

    function exists(address[] memory self, address toFind) internal pure returns (bool) {
        for (uint i = 0; i < self.length; i++) {
            if (self[i] == toFind) {
                return true;
            }
        }
        return false;
    }

    function shrink(
        address[] memory self,
        uint[] memory amounts
    ) internal pure returns (address[] memory shrunkTokens, uint[] memory shrunkAmounts) {
        uint[] memory toRemove = new uint[](self.length);
        for (uint i = 0; i < self.length; i++) {
            for (uint j = i; j < self.length; j++) {
                if (j > i && self[i] == self[j]) {
                    amounts[i] = amounts[i] + amounts[j];
                    amounts[j] = 0;
                    toRemove[j] = 1;
                }
            }
        }
        uint shrunkSize;
        for (uint i = 0; i < self.length; i++) {
            if (amounts[i] > 0) {
                shrunkSize += 1;
            }
        }
        shrunkTokens = new address[](shrunkSize);
        shrunkAmounts = new uint[](shrunkSize);
        uint tokensAdded;
        for (uint i = 0; i < self.length; i++) {
            if (amounts[i] > 0) {
                shrunkTokens[tokensAdded] = self[i];
                shrunkAmounts[tokensAdded] = amounts[i];
                tokensAdded += 1;
            }
        }
    }

    function equal(address[] memory array1, address[] memory array2) internal pure returns (bool) {
        if (array1.length != array2.length) return false;
        for (uint i = 0; i < array1.length; i++) {
            bool matchFound = false;
            for (uint j = 0; j < array2.length; j++) {
                if (array1[i] == array2[j]) {
                    matchFound = true;
                    break;
                }
            }
            if (!matchFound) {
                return false;
            }
        }
        return true;
    }

    function copy(address[] memory self) internal pure returns (address[] memory copied) {
        copied = new address[](self.length);
        for (uint i = 0; i < self.length; i++) {
            copied[i] = self[i];
        }
    }

    function log(address[] memory self) internal view {
        console.log("-------------------address array-------------------");
        for (uint i = 0; i < self.length; i++) {
            console.log(i, self[i]);
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "../interfaces/INFTPoolInteractor.sol";
import "./AddressArray.sol";
import "./UintArray.sol";
import "hardhat/console.sol";

struct Conversion {
    Asset desiredERC721;
    address desiredERC20;
    uint256 value;
    address[] underlying;
    uint256[] underlyingValues;
}

library Conversions {
    using AddressArray for address[];
    using UintArray for uint256[];

    function append(
        Conversion[] memory self,
        Conversion memory conversion
    ) internal pure returns (Conversion[] memory) {
        Conversion[] memory newArray = new Conversion[](self.length + 1);
        for (uint256 i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        newArray[self.length] = conversion;
        return newArray;
    }

    function concat(Conversion[] memory self, Conversion[] memory array) internal pure returns (Conversion[] memory) {
        Conversion[] memory newArray = new Conversion[](self.length + array.length);
        for (uint256 i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i + self.length] = array[i];
        }
        return newArray;
    }

    function getUnderlying(
        Conversion[] memory self
    ) internal pure returns (address[] memory underlying, uint256[] memory underlyingValues) {
        for (uint256 i = 0; i < self.length; i++) {
            for (uint256 j = 0; j < self[i].underlying.length; j++) {
                if (_isBasic(self, self[i].underlying[j])) {
                    underlying = underlying.append(self[i].underlying[j]);
                    underlyingValues = underlyingValues.append(self[i].underlyingValues[j]);
                }
            }
        }
    }

    function findAllBasic(Conversion[] memory self, address toFind) internal pure returns (uint256[] memory) {
        uint256[] memory indices;
        uint256 numMatching;
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i].desiredERC20 == toFind && self[i].underlying.length == 0) {
                numMatching += 1;
            }
        }
        if (numMatching == 0) {
            return indices;
        }
        indices = new uint256[](numMatching);
        uint256 numPushed = 0;
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i].desiredERC20 == toFind && self[i].underlying.length == 0) {
                indices[numPushed] = i;
                numPushed += 1;
                if (numPushed == numMatching) {
                    return indices;
                }
            }
        }
        return indices;
    }

    function findAllWithUnderlying(
        Conversion[] memory self,
        address underlying
    ) internal pure returns (uint256[] memory) {
        uint256[] memory indices;
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i].underlying.exists(underlying)) {
                indices = indices.append(i);
            }
        }
        return indices;
    }

    function findUnderlyingOrFinal(Conversion[] memory self, address token) internal pure returns (uint256[] memory) {
        uint256[] memory indices;
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i].underlying.exists(token) || self[i].desiredERC20 == token) {
                indices = indices.append(i);
            }
        }
        return indices;
    }

    function _isBasic(Conversion[] memory conversions, address token) internal pure returns (bool) {
        for (uint256 i = 0; i < conversions.length; i++) {
            if (conversions[i].desiredERC20 == token && conversions[i].underlying[0] != token) return false;
        }
        return true;
    }

    function sumAll(Conversion[] memory conversions, address token) internal pure returns (uint256 sum) {
        for (uint256 i = 0; i < conversions.length; i++) {
            uint256 underlyingIdx = conversions[i].underlying.findFirst(token);
            if (
                underlyingIdx != conversions[i].underlying.length && conversions[i].underlying[underlyingIdx] == token
            ) {
                sum += conversions[i].underlyingValues[underlyingIdx];
            }
        }
    }

    function sumPrior(Conversion[] memory conversions, uint256 idx, address token) internal pure returns (uint256 sum) {
        for (uint256 i = 0; i <= idx; i++) {
            if (conversions[i].desiredERC20 == token) {
                sum += conversions[i].value;
                continue;
            }
            uint256 underlyingIdx = conversions[i].underlying.findFirst(token);
            if (underlyingIdx != conversions[i].underlying.length) {
                sum -= conversions[i].underlyingValues[underlyingIdx];
            }
        }
    }

    function sumAfter(Conversion[] memory conversions, uint256 idx, address token) internal pure returns (uint256 sum) {
        for (uint256 i = idx; i < conversions.length; i++) {
            uint256 underlyingIdx = conversions[i].underlying.findFirst(token);
            if (underlyingIdx != conversions[i].underlying.length) {
                sum += conversions[i].underlyingValues[underlyingIdx];
            }
        }
    }

    function normalizeRatios(Conversion[] memory self) internal pure returns (Conversion[] memory) {
        for (uint256 i = 0; i < self.length; i++) {
            for (uint256 j = 0; j < self[i].underlying.length; j++) {
                if (!_isBasic(self, self[i].underlying[j])) continue;
                uint256 sum = sumAfter(self, i, self[i].underlying[j]);
                self[i].underlyingValues[j] = sum > 0 ? (self[i].underlyingValues[j] * 1e18) / sum : 1e18;
            }
        }
        for (uint256 i = 0; i < self.length; i++) {
            for (uint256 j = 0; j < self[i].underlying.length; j++) {
                if (_isBasic(self, self[i].underlying[j])) continue;
                uint256 sum = sumPrior(self, i, self[i].underlying[j]);
                self[i].underlyingValues[j] = sum > 0 ? (self[i].underlyingValues[j] * 1e18) / sum : 1e18;
            }
        }
        return self;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SaferERC20
 * @dev Wrapper around the safe increase allowance SafeERC20 operation that fails for usdt
 * when the allowance is non zero.
 * To use this library you can add a `using SaferERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SaferERC20 {
    using Address for address;
    using SafeERC20 for IERC20;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        token.safeTransfer(to, value);
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        token.safeTransferFrom(from, to, value);
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        token.safeApprove(spender, value);
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint currentAllowance = token.allowance(address(this), spender);
        uint256 newAllowance = currentAllowance + value;
        (bool success, ) = address(token).call(abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        if (!success) {
            if (currentAllowance > 0) {
                token.safeDecreaseAllowance(spender, currentAllowance);
                token.safeApprove(spender, value);
            }
        }
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        token.safeDecreaseAllowance(spender, value);
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
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "./AddressArray.sol";
import "hardhat/console.sol";

struct SwapPoint {
    uint256 amountIn;
    uint256 valueIn;
    uint256 amountOut;
    uint256 valueOut;
    int256 slippage;
    address tokenIn;
    address[] swappers;
    address tokenOut;
    address[][] paths;
}

library SwapFinder {
    using AddressArray for address[];

    function sort(SwapPoint[] memory self) internal pure returns (SwapPoint[] memory sorted) {
        sorted = new SwapPoint[](self.length);
        for (uint256 i = 0; i < self.length; i++) {
            int256 minSlippage = 2 ** 128 - 1;
            uint256 minSlippageIndex = 0;
            for (uint256 j = 0; j < self.length; j++) {
                if (self[j].slippage < minSlippage) {
                    minSlippageIndex = j;
                    minSlippage = self[j].slippage;
                }
            }
            sorted[i] = self[minSlippageIndex];
            self[minSlippageIndex].slippage = 2 ** 128 - 1;
        }
    }

    function append(
        SwapPoint[] memory self,
        SwapPoint memory swap
    ) internal pure returns (SwapPoint[] memory newSwaps) {
        newSwaps = new SwapPoint[](self.length + 1);
        for (uint i = 0; i < self.length; i++) {
            newSwaps[i] = self[i];
        }
        newSwaps[self.length] = swap;
        return newSwaps;
    }

    struct StackMinimizingStruct {
        uint256 valueIn;
        uint256 toConvertIndex;
        uint256 convertToIndex;
    }

    struct StackMinimizingStruct2 {
        uint256[] valuesUsed;
        uint256[] valuesProvided;
        uint256 swapsAdded;
    }

    function findBestSwaps(
        SwapPoint[] memory self,
        address[] memory toConvert,
        uint256[] memory valuesToConvert,
        uint256[] memory amountsToConvert,
        address[] memory convertTo,
        uint256[] memory wantedValues
    ) internal pure returns (SwapPoint[] memory swaps) {
        SwapPoint[] memory bestSwaps = new SwapPoint[](self.length);
        StackMinimizingStruct2 memory data2 = StackMinimizingStruct2(
            new uint256[](toConvert.length),
            new uint256[](wantedValues.length),
            0
        );
        for (uint256 i = 0; i < self.length; i++) {
            StackMinimizingStruct memory data = StackMinimizingStruct(
                self[i].valueIn,
                toConvert.findFirst(self[i].tokenIn),
                convertTo.findFirst(self[i].tokenOut)
            );
            if (self[i].tokenIn == address(0) || self[i].tokenOut == address(0)) continue;
            if (
                data2.valuesUsed[data.toConvertIndex] < valuesToConvert[data.toConvertIndex] &&
                data2.valuesProvided[data.convertToIndex] < wantedValues[data.convertToIndex]
            ) {
                uint256 valueInAdjusted;
                {
                    uint256 moreValueInAvailable = valuesToConvert[data.toConvertIndex] -
                        data2.valuesUsed[data.toConvertIndex];
                    uint256 moreValueOutNeeded = wantedValues[data.convertToIndex] -
                        data2.valuesProvided[data.convertToIndex];
                    valueInAdjusted = moreValueInAvailable >= data.valueIn ? data.valueIn : moreValueInAvailable;
                    if (valueInAdjusted > moreValueOutNeeded) {
                        valueInAdjusted = moreValueOutNeeded;
                    }
                }
                self[i].amountIn =
                    (valueInAdjusted * amountsToConvert[data.toConvertIndex]) /
                    valuesToConvert[data.toConvertIndex];
                self[i].valueIn = valueInAdjusted;
                self[i].valueOut = (valueInAdjusted * self[i].valueOut) / self[i].valueIn;
                self[i].amountOut = (valueInAdjusted * self[i].amountOut) / self[i].valueIn;
                bestSwaps[data2.swapsAdded] = self[i];
                data2.swapsAdded += 1;
                data2.valuesUsed[data.toConvertIndex] += valueInAdjusted;
                data2.valuesProvided[data.convertToIndex] += valueInAdjusted;
                continue;
            }
        }
        uint256 numSwaps = 0;
        for (uint256 i = 0; i < bestSwaps.length; i++) {
            if (bestSwaps[i].tokenIn != address(0) && bestSwaps[i].amountIn > 0) {
                numSwaps += 1;
            }
        }
        swaps = new SwapPoint[](numSwaps);
        uint256 swapsAdded;
        for (uint256 i = 0; i < bestSwaps.length; i++) {
            if (bestSwaps[i].tokenIn != address(0) && bestSwaps[i].amountIn > 0) {
                swaps[swapsAdded] = bestSwaps[i];
                swapsAdded += 1;
            }
        }
        for (uint256 i = 0; i < swaps.length; i++) {
            swaps[i].amountIn = (1e18 * swaps[i].amountIn) / amountsToConvert[toConvert.findFirst(swaps[i].tokenIn)];
        }
        return swaps;
    }

    function log(SwapPoint memory self) internal view {
        console.log("Swapping ", self.tokenIn, " for ", self.tokenOut);
        console.log("Amount in: ", self.amountIn, " Value in: ", self.valueIn);
        console.log("Amount out: ", self.amountOut, " Value out: ", self.valueOut);
        console.log("Swappers used:");
        for (uint i = 0; i < self.swappers.length; i++) {
            console.log(self.swappers[i]);
            console.log("Path used:");
            for (uint j = 0; j < self.paths[i].length; j++) {
                console.log(self.paths[i][j]);
            }
            console.log("___________________");
        }
    }

    function log(SwapPoint[] memory self) internal view {
        for (uint i = 0; i < self.length; i++) {
            log(self[i]);
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

import "hardhat/console.sol";

library UintArray {
    function concat(uint[] memory self, uint[] memory array) internal pure returns (uint[] memory) {
        uint[] memory newArray = new uint[](self.length + array.length);
        for (uint i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        for (uint i = 0; i < array.length; i++) {
            newArray[i + self.length] = array[i];
        }
        return newArray;
    }

    function append(uint[] memory self, uint element) internal pure returns (uint[] memory) {
        uint[] memory newArray = new uint[](self.length + 1);
        for (uint i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        newArray[self.length] = element;
        return newArray;
    }

    function remove(uint[] memory self, uint index) internal pure returns (uint[] memory newArray) {
        newArray = new uint[](self.length - 1);
        uint elementsAdded;
        for (uint i = 0; i < self.length; i++) {
            if (i != index) {
                newArray[elementsAdded] = self[i];
                elementsAdded += 1;
            }
        }
        return newArray;
    }

    function sum(uint[] memory self) internal pure returns (uint) {
        uint total;
        for (uint i = 0; i < self.length; i++) {
            total += self[i];
        }
        return total;
    }

    function scale(uint[] memory self, uint newTotal) internal pure returns (uint[] memory) {
        uint totalRatios;
        for (uint i = 0; i < self.length; i++) {
            totalRatios += self[i];
        }
        for (uint i = 0; i < self.length; i++) {
            self[i] = (self[i] * newTotal) / totalRatios;
        }
        return self;
    }

    function insert(uint[] memory self, uint idx, uint value) internal pure returns (uint[] memory newArray) {
        newArray = new uint[](self.length + 1);
        for (uint i = 0; i < idx; i++) {
            newArray[i] = self[i];
        }
        newArray[idx] = value;
        for (uint i = idx; i < self.length; i++) {
            newArray[i + 1] = self[i];
        }
    }

    function copy(uint[] memory self) internal pure returns (uint[] memory copied) {
        copied = new uint[](self.length);
        for (uint i = 0; i < self.length; i++) {
            copied[i] = self[i];
        }
    }

    function slice(uint[] memory self, uint start, uint end) internal pure returns (uint[] memory sliced) {
        sliced = new uint[](end - start);
        uint elementsAdded = 0;
        for (uint i = start; i < end; i++) {
            sliced[elementsAdded] = self[i];
            elementsAdded += 1;
        }
    }

    function log(uint[] memory self) internal view {
        console.log("-------------------uint array-------------------");
        for (uint i = 0; i < self.length; i++) {
            console.log(i, self[i]);
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.17;

library UintArray2D {
    function concat(uint[][] memory self, uint[][] memory array) internal pure returns (uint[][] memory) {
        uint[][] memory newArray = new uint[][](self.length + array.length);
        for (uint i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        for (uint i = 0; i < array.length; i++) {
            newArray[i + self.length] = array[i];
        }
        return newArray;
    }

    function append(uint[][] memory self, uint[] memory element) internal pure returns (uint[][] memory) {
        uint[][] memory newArray = new uint[][](self.length + 1);
        for (uint i = 0; i < self.length; i++) {
            newArray[i] = self[i];
        }
        newArray[self.length] = element;
        return newArray;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}