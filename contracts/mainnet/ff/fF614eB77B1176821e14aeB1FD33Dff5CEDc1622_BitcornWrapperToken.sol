// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { MasterChef } from "./MasterChef.sol";

interface Bitcorn
{
	function rewardToken() external view returns (address _rewardToken);

	function claim() external;
}

contract BitcornWrapperToken is Initializable, ReentrancyGuard, ERC20
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		bool exists;
		uint256 shares;
		uint256 rewardDebt;
		uint256 unclaimedReward;
	}

	address constant MASTER_CHEF = 0x8BAB23A24430E82C9D384F2996e1671f3e64869a;
	address constant WRAPPER_TOKEN_BRIDGE = 0x0DC52B853030E587eb10b11cfF7d5FDdFA594E71;

	address public token;
	address public rewardToken;

	uint256 public totalReward = 0;
	uint256 public accRewardPerShare = 0;

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	uint256 public pid;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	constructor(address _token, uint256 _pid)
		ERC20("", "")
	{
		initialize(_token, _pid);
	}

	function name() public pure override returns (string memory _name)
	{
		return "Bitcorn-Like Wrapper Token";
	}

	function symbol() public pure override returns (string memory _symbol)
	{
		return "BLWT";
	}

	function initialize(address _token, uint256 _pid) public initializer
	{
		totalReward = 0;
		accRewardPerShare = 0;

		token = _token;
		rewardToken = Bitcorn(_token).rewardToken();
		pid = _pid;
	}
/*
	function migrate() external
	{
		require(pid == 0, "invalid state");
		pid = 72; // BITCORN
	}
*/
	function totalReserve() public view returns (uint256 _totalReserve)
	{
		return IERC20(token).balanceOf(address(this));
	}

	function deposit(uint256 _amount) external returns (uint256 _shares)
	{
		return deposit(_amount, msg.sender);
	}

	function deposit(uint256 _amount, address _account) public nonReentrant returns (uint256 _shares)
	{
		require(msg.sender == _account || msg.sender == WRAPPER_TOKEN_BRIDGE, "access denied");
		_claimRewards();
		{
			uint256 _totalSupply = totalSupply();
			uint256 _totalReserve = totalReserve();
			IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
			uint256 _newTotalReserve = totalReserve();
			_amount = _newTotalReserve - _totalReserve;
			_shares = _calcSharesFromAmount(_totalReserve, _totalSupply, _amount);
			_mint(msg.sender, _shares);
		}
		_updateAccount(_account, int256(_shares));
		emit Deposit(_account, _shares);
		return _shares;
	}

	function withdraw(uint256 _shares) external returns (uint256 _amount)
	{
		return withdrawTo(_shares, msg.sender);
	}

	function withdrawTo(uint256 _shares, address _to) public nonReentrant returns (uint256 _amount)
	{
		_claimRewards();
		{
			uint256 _totalSupply = totalSupply();
			uint256 _totalReserve = totalReserve();
			_amount = _calcAmountFromShares(_totalReserve, _totalSupply, _shares);
			_burn(msg.sender, _shares);
			IERC20(token).safeTransfer(_to, _amount);
		}
		_updateAccount(msg.sender, -int256(_shares));
		_sync(msg.sender);
		emit Withdraw(msg.sender, _shares);
		return _amount;
	}

	function withdraw(uint256 _shares, address _account) public nonReentrant returns (uint256 _amount)
	{
		require(msg.sender == _account || msg.sender == WRAPPER_TOKEN_BRIDGE, "access denied");
		_claimRewards();
		{
			uint256 _totalSupply = totalSupply();
			uint256 _totalReserve = totalReserve();
			_amount = _calcAmountFromShares(_totalReserve, _totalSupply, _shares);
			_burn(msg.sender, _shares);
			IERC20(token).safeTransfer(msg.sender, _amount);
		}
		_updateAccount(_account, -int256(_shares));
		_sync(_account);
		emit Withdraw(_account, _shares);
		return _amount;
	}

	function claim() external returns (uint256 _rewardAmount)
	{
		return claim(msg.sender);
	}

	function claim(address _account) public nonReentrant returns (uint256 _rewardAmount)
	{
		require(msg.sender == _account || msg.sender == WRAPPER_TOKEN_BRIDGE, "access denied");
		_claimRewards();
		_updateAccount(_account, 0);
		{
			AccountInfo storage _accountInfo = accountInfo[_account];
			_rewardAmount = _accountInfo.unclaimedReward;
			_accountInfo.unclaimedReward = 0;
		}
		if (_rewardAmount > 0) {
			totalReward -= _rewardAmount;
			IERC20(rewardToken).safeTransfer(_account, _rewardAmount);
		}
		emit Claim(_account, _rewardAmount);
		return _rewardAmount;
	}

	function _beforeTokenTransfer(address _from, address _to, uint256 _shares) internal override
	{
		if (_from == address(0) || _to == address(0)) return;
		if (msg.sender == MASTER_CHEF && (_from == MASTER_CHEF || _to == MASTER_CHEF || _from == WRAPPER_TOKEN_BRIDGE || _to == WRAPPER_TOKEN_BRIDGE)) return;
		_claimRewards();
		_updateAccount(_from, -int256(_shares));
		_updateAccount(_to, int256(_shares));
	}

	function syncAll() external nonReentrant
	{
		_claimRewards();
		for (uint256 _i = 0; _i < accountIndex.length; _i++) {
			_sync(accountIndex[_i]);
		}
	}

	function _sync(address _account) internal
	{
		address _bankroll = MasterChef(MASTER_CHEF).bankroll();
		if (_account == _bankroll) return;
		(address _token,,,,,,,) = MasterChef(MASTER_CHEF).poolInfo(pid);
		require(_token == address(this), "invalid pid");
		uint256 _balance = balanceOf(_account);
		(uint256 _stake,,) = MasterChef(MASTER_CHEF).userInfo(pid, _account);
		uint256 _shares = _balance + _stake;
		if (accountInfo[_account].shares <= _shares) return;
		uint256 _excess = accountInfo[_account].shares - _shares;
		if (_excess == 0) return;
		_updateAccount(_account, -int256(_excess));
		_updateAccount(_bankroll, int256(_excess));
	}

	function _updateAccount(address _account, int256 _shares) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}
		if (_accountInfo.shares > 0) {
			_accountInfo.unclaimedReward += _accountInfo.shares * accRewardPerShare / 1e18 - _accountInfo.rewardDebt;
		}
		if (_shares > 0) {
			_accountInfo.shares += uint256(_shares);
		}
		else
		if (_shares < 0) {
			_accountInfo.shares -= uint256(-_shares);
		}
		_accountInfo.rewardDebt = _accountInfo.shares * accRewardPerShare / 1e18;
	}

	function _calcSharesFromAmount(uint256 _totalReserve, uint256 _totalSupply, uint256 _amount) internal pure virtual returns (uint256 _shares)
	{
		if (_totalReserve == 0) return _amount;
		return _amount * _totalSupply / _totalReserve;
	}

	function _calcAmountFromShares(uint256 _totalReserve, uint256 _totalSupply, uint256 _shares) internal pure virtual returns (uint256 _amount)
	{
		if (_totalSupply == 0) return _totalReserve;
		return _shares * _totalReserve / _totalSupply;
	}

	function _claimRewards() internal
	{
		uint256 _totalSupply = totalSupply();
		if (_totalSupply > 0) {
			Bitcorn(token).claim();
			uint256 _rewardAmount = IERC20(rewardToken).balanceOf(address(this)) - totalReward;
			if (_rewardAmount > 0) {
				totalReward += _rewardAmount;
				accRewardPerShare += _rewardAmount * 1e18 / _totalSupply;
			}
		}
	}

	event Deposit(address indexed _account, uint256 _shares);
	event Withdraw(address indexed _account, uint256 _shares);
	event Claim(address indexed _account, uint256 _rewardToken);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { FarmingVolatile } from "./FarmingVolatile.sol";

/*
 Compound VDC fees are 11% in and 11% out, they are distributed in the following way:
 7% to drip pool
 1% Instant dividends to stakers
 1% xPERPS Bankroll
 1% Burnt
 1% Volatile VDC
 Receives CVDC daily from xPERPS staking
 */
contract FarmingCompound is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		uint256 amount; // xPERPS staked
		uint256 reward; // CVDC reward accumulated but not claimed
		uint256 drip; // xPERPS from drip pool accumulated but not claimed
		uint256 accRewardDebt; // CVDC reward debt from PCS distribution algorithm
		uint256 accDripDebt; // xPERPS reward debt from PCS distribution algorithm
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
		bool exists; // flag to index account
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x392681Eaf8AD9BC65e74BE37Afe7503D92802b7d; // multisig

	uint256 constant DEFAULT_LAUNCH_TIME = 1662573600; // 2022-09-07 6PM UTC
	uint256 constant DEFAULT_DRIP_RATE_PER_DAY = 1e16; // 1% per day

	uint256 constant DAY = 1 days;
	uint256 constant TZ_OFFSET = 22 hours + 30 minutes; // UTC-1.30

	address public reserveToken; // xPERPS
	address public rewardToken; // CVDC

	address public farmingVolatile;

	address public bankroll = DEFAULT_BANKROLL;

	uint256 public launchTime = DEFAULT_LAUNCH_TIME;

	uint256 public dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;

	bool public whitelistAll = false;

	uint256 public totalStaked = 0; // total staked balance

	uint256 public totalDrip = 0; // total drip pool balance
	uint256 public allocDrip = 0; // total drip pool balance allocated

	uint256 public totalReward = 0; // total reward balance

	uint256 public accRewardPerShare = 0; // cumulative reward BUSD per xPERPS staked from PCS distribution algorithm
	uint256 public accDripPerShare = 0; // cumulative drip pool xPERPS per xPERPS staked from PCS distribution algorithm

	uint64 public day = today();

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	modifier hasLaunched()
	{
		require(block.timestamp >= launchTime, "unavailable");
		_;
	}

	constructor(address _reserveToken, address _rewardToken, address _farmingVolatile)
	{
		initialize(msg.sender, _reserveToken, _rewardToken, _farmingVolatile);
	}

	function initialize(address _owner, address _reserveToken, address _rewardToken, address _farmingVolatile) public initializer
	{
		_transferOwnership(_owner);

		bankroll = DEFAULT_BANKROLL;

		launchTime = DEFAULT_LAUNCH_TIME;

		dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;

		whitelistAll = false;

		totalStaked = 0; // total staked balance

		totalDrip = 0; // total drip pool balance
		allocDrip = 0; // total drip pool balance allocated

		totalReward = 0; // total reward balance

		accRewardPerShare = 0; // cumulative reward CVDC per xPERPS staked from PCS distribution algorithm
		accDripPerShare = 0; // cumulative drip pool xPERPS per xPERPS staked from PCS distribution algorithm

		day = today();

		require(_rewardToken != _reserveToken, "invalid token");
		reserveToken = _reserveToken;
		rewardToken = _rewardToken;
		farmingVolatile = _farmingVolatile;
	}

	// updates the reward token address
	function setRewardToken(address _rewardToken) external onlyOwner
	{
		require(_rewardToken != address(0), "invalid address");
		require(totalReward == 0, "invalid state");
		rewardToken = _rewardToken;
	}

	// updates the volatile vdc address
	function setFarmingVolatile(address _farmingVolatile) external onlyOwner
	{
		require(_farmingVolatile != address(0), "invalid address");
		farmingVolatile = _farmingVolatile;
	}

	// updates the bankroll address
	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	// updates the launch time
	function setLaunchTime(uint256 _launchTime) external onlyOwner
	{
		require(block.timestamp < launchTime, "unavailable");
		require(_launchTime >= block.timestamp, "invalid time");
		launchTime = _launchTime;
	}

	// updates the percentual rate of distribution from the drip pool
	function setDripRatePerDay(uint256 _dripRatePerDay) external onlyOwner
	{
		require(_dripRatePerDay <= 100e16, "invalid rate");
		dripRatePerDay = _dripRatePerDay;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == rewardToken) _amount -= totalReward;
		if (_token == reserveToken) _amount -= totalStaked + totalDrip;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

/*
	function resetAndWithdrawReward() external onlyOwner nonReentrant
	{
		for (uint256 _i; _i < accountIndex.length; _i++) {
			AccountInfo storage _accountInfo = accountInfo[accountIndex[_i]];
			_accountInfo.reward = 0;
			_accountInfo.accRewardDebt = 0;
		}

		uint256 _amount = totalReward;

		totalReward = 0;
		accRewardPerShare = 0;

		IERC20(rewardToken).safeTransfer(msg.sender, _amount);
	}
*/

	// stakes xPERPS
	function deposit(uint256 _amount) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, msg.sender);

		emit Deposit(msg.sender, reserveToken, _amount);
	}

	// stakes xPERPS on behalf of another account
	function depositOnBehalfOf(uint256 _amount, address _account) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, _account);

		emit Deposit(_account, reserveToken, _amount);
	}

	function _deposit(address _sender, uint256 _amount, address _account) internal
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		uint256 _1percent = _amount * 1e16 / 100e16;
		uint256 _dripAmount = 8 * _1percent;
		uint256 _netAmount = _amount - (11 * _1percent);

		// 8% accounted for the drip pool
		totalDrip += _dripAmount;

		// 1% instant rewards (only 7% actually go to the drip pool)
		if (totalStaked > 0) {
			accDripPerShare += _1percent * 1e18 / totalStaked;
			allocDrip += _1percent;
		}

		_updateAccount(_account, int256(_netAmount));

		totalStaked += _netAmount;

		if (_sender == address(this)) {
			IERC20(reserveToken).safeTransfer(FURNACE, _1percent);
			IERC20(reserveToken).safeTransfer(bankroll, _1percent);
		} else {
			IERC20(reserveToken).safeTransferFrom(_sender, address(this), _netAmount + _dripAmount + _1percent);
			IERC20(reserveToken).safeTransferFrom(_sender, FURNACE, _1percent);
			IERC20(reserveToken).safeTransferFrom(_sender, bankroll, _1percent);
		}

		// rewards Volatile VDC users
		IERC20(reserveToken).safeApprove(farmingVolatile, _1percent);
		FarmingVolatile(farmingVolatile).rewardAll(_1percent);
	}

	// unstakes xPERPS
	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount));

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(reserveToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _1percent = _amount * 1e16 / 100e16;
			uint256 _dripAmount = 8 * _1percent;
			uint256 _netAmount = _amount - (11 * _1percent);

			// 8% accounted for the drip pool
			totalDrip += _dripAmount;

			// 1% instant rewards (only 7% actually go to the drip pool)
			if (totalStaked > 0) {
				accDripPerShare += _1percent * 1e18 / totalStaked;
				allocDrip += _1percent;
			}

			IERC20(reserveToken).safeTransfer(FURNACE, _1percent);
			IERC20(reserveToken).safeTransfer(bankroll, _1percent);

			// rewards Volatile VDC users
			IERC20(reserveToken).safeApprove(farmingVolatile, _1percent);
			FarmingVolatile(farmingVolatile).rewardAll(_1percent);

			IERC20(reserveToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, reserveToken, _amount);
	}

	// claims rewards only (BUSD)
	function claimReward() external nonReentrant returns (uint256 _rewardAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);

		return _rewardAmount;
	}

	// claims drip only (xPERPS)
	function claimDrip() external nonReentrant returns (uint256 _dripAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _dripAmount);
		}

		emit Claim(msg.sender, reserveToken, _dripAmount);

		return _dripAmount;
	}

	// claims all (CVDC and xPERPS)
	function claimAll() external nonReentrant returns (uint256 _rewardAmount, uint256 _dripAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;
		_dripAmount = _accountInfo.drip;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _dripAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);
		emit Claim(msg.sender, reserveToken, _dripAmount);

		return (_rewardAmount, _dripAmount);
	}

	// compounds drip only (xPERPS)
	function compoundDrip() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			_deposit(address(this), _dripAmount, msg.sender);
		}

		emit Compound(msg.sender, reserveToken, _dripAmount);
	}

	// sends BUSD to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends BUSD to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		accRewardPerShare += _amount * 1e18 / totalStaked;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// sends xPERPS to drip pool
	function donateDrip(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		totalDrip += _amount;

		IERC20(reserveToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit DonateDrip(msg.sender, reserveToken, _amount);
	}

	// performs the daily distribution from staking (CVDC) and the drip pool (xPERPS)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		if (totalStaked > 0) {
			// calculates the percentage of the drip pool and distributes
			{
				// formula: drip_reward = drip_pool_balance * (1 - (1 - drip_rate_per_day) ^ days_ellapsed)
				uint64 _days = _today - day;
				uint256 _rate = 100e16 - _exp(100e16 - dripRatePerDay, _days);
				uint256 _amount = (totalDrip - allocDrip) * _rate / 100e16;
				accDripPerShare += _amount * 1e18 / totalStaked;
				allocDrip += _amount;
			}
		}

		day = _today;
	}

	// updates the account balances while accumulating reward/drip using PCS distribution algorithm
	function _updateAccount(address _account, int256 _amount) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}

		_accountInfo.reward += _accountInfo.amount * accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
		_accountInfo.drip += _accountInfo.amount * accDripPerShare / 1e18 - _accountInfo.accDripDebt;
		if (_amount > 0) {
			_accountInfo.amount += uint256(_amount);
		}
		else
		if (_amount < 0) {
			_accountInfo.amount -= uint256(-_amount);
		}
		_accountInfo.accRewardDebt = _accountInfo.amount * accRewardPerShare / 1e18;
		_accountInfo.accDripDebt = _accountInfo.amount * accDripPerShare / 1e18;
	}

	// exponentiation with integer exponent
	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}

	event Deposit(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Compound(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event DonateDrip(address indexed _account, address indexed _reserveToken, uint256 _amount);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
 Volatile VDC fees are 33% in and 33% out, they are distributed in the following way:
 30% to drip pool
 1% Instant dividends to stakers
 1% xPERPS Bankroll
 1% Burnt
 Does not receive ONE daily but does receive 1% of all XPERPS deposited into COMPOUND VDC
 */
contract FarmingVolatile is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		uint256 amount; // xPERPS staked
		uint256 reward; // xPERPS reward from Volatile VDC accumulated but not claimed
		uint256 drip; // xPERPS from drip pool accumulated but not claimed
		uint256 accRewardDebt; // xPERPS reward debt from PCS distribution algorithm
		uint256 accDripDebt; // xPERPS reward debt from PCS distribution algorithm
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
		bool exists; // flag to index account
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x392681Eaf8AD9BC65e74BE37Afe7503D92802b7d; // multisig

	uint256 constant DEFAULT_LAUNCH_TIME = 1662573600; // 2022-09-07 6PM UTC
	uint256 constant DEFAULT_DRIP_RATE_PER_DAY = 1e16; // 1% per day

	uint256 constant DAY = 1 days;
	uint256 constant TZ_OFFSET = 22 hours + 30 minutes; // UTC-1.30

	address public reserveToken; // xPERPS
	address public rewardToken; // xPERPS

	address public bankroll = DEFAULT_BANKROLL;

	uint256 public launchTime = DEFAULT_LAUNCH_TIME;

	uint256 public dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;

	bool public whitelistAll = false;

	uint256 public totalStaked = 0; // total staked balance

	uint256 public totalDrip = 0; // total drip pool balance
	uint256 public allocDrip = 0; // total drip pool balance allocated

	uint256 public totalReward = 0; // total reward balance

	uint256 public accRewardPerShare = 0; // cumulative reward xPERPS per xPERPS staked from PCS distribution algorithm
	uint256 public accDripPerShare = 0; // cumulative drip pool xPERPS per xPERPS staked from PCS distribution algorithm

	uint64 public day = today();

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	modifier hasLaunched()
	{
		require(block.timestamp >= launchTime, "unavailable");
		_;
	}

	constructor(address _reserveToken)
	{
		initialize(msg.sender, _reserveToken);
	}

	function initialize(address _owner, address _reserveToken) public initializer
	{
		_transferOwnership(_owner);

		bankroll = DEFAULT_BANKROLL;

		launchTime = DEFAULT_LAUNCH_TIME;

		dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;

		whitelistAll = false;

		totalStaked = 0; // total staked balance

		totalDrip = 0; // total drip pool balance
		allocDrip = 0; // total drip pool balance allocated

		totalReward = 0; // total reward balance

		accRewardPerShare = 0; // cumulative reward xPERPS per xPERPS staked from PCS distribution algorithm
		accDripPerShare = 0; // cumulative drip pool xPERPS per xPERPS staked from PCS distribution algorithm

		day = today();

		reserveToken = _reserveToken;
		rewardToken = _reserveToken;
	}

	// updates the bankroll address
	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	// updates the launch time
	function setLaunchTime(uint256 _launchTime) external onlyOwner
	{
		require(block.timestamp < launchTime, "unavailable");
		require(_launchTime >= block.timestamp, "invalid time");
		launchTime = _launchTime;
	}

	// updates the percentual rate of distribution from the drip pool
	function setDripRatePerDay(uint256 _dripRatePerDay) external onlyOwner
	{
		require(_dripRatePerDay <= 100e16, "invalid rate");
		dripRatePerDay = _dripRatePerDay;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == reserveToken) _amount -= totalStaked + totalDrip + totalReward;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	// stakes xPERPS
	function deposit(uint256 _amount) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, msg.sender);

		emit Deposit(msg.sender, reserveToken, _amount);
	}

	// stakes xPERPS on behalf of another account
	function depositOnBehalfOf(uint256 _amount, address _account) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, _account);

		emit Deposit(_account, reserveToken, _amount);
	}

	function _deposit(address _sender, uint256 _amount, address _account) internal
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		uint256 _1percent = _amount * 1e16 / 100e16;
		uint256 _dripAmount = 31 * _1percent;
		uint256 _netAmount = _amount - (33 * _1percent);

		// 31% accounted for the drip pool
		totalDrip += _dripAmount;

		// 1% instant rewards (only 30% actually go to the drip pool)
		if (totalStaked > 0) {
			accDripPerShare += _1percent * 1e18 / totalStaked;
			allocDrip += _1percent;
		}

		_updateAccount(_account, int256(_netAmount));

		totalStaked += _netAmount;

		if (_sender == address(this)) {
			IERC20(reserveToken).safeTransfer(FURNACE, _1percent);
			IERC20(reserveToken).safeTransfer(bankroll, _1percent);
		} else {
			IERC20(reserveToken).safeTransferFrom(_sender, address(this), _netAmount + _dripAmount);
			IERC20(reserveToken).safeTransferFrom(_sender, FURNACE, _1percent);
			IERC20(reserveToken).safeTransferFrom(_sender, bankroll, _1percent);
		}
	}

	// unstakes xPERPS
	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount));

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(reserveToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _1percent = _amount * 1e16 / 100e16;
			uint256 _dripAmount = 31 * _1percent;
			uint256 _netAmount = _amount - (33 * _1percent);

			// 31% accounted for the drip pool
			totalDrip += _dripAmount;

			// 1% instant rewards (only 30% actually go to the drip pool)
			if (totalStaked > 0) {
				accDripPerShare += _1percent * 1e18 / totalStaked;
				allocDrip += _1percent;
			}

			IERC20(reserveToken).safeTransfer(FURNACE, _1percent);
			IERC20(reserveToken).safeTransfer(bankroll, _1percent);

			IERC20(reserveToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, reserveToken, _amount);
	}

	// claims rewards only (xPERPS)
	function claimReward() external nonReentrant returns (uint256 _rewardAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);

		return _rewardAmount;
	}

	// claims drip only (xPERPS)
	function claimDrip() external nonReentrant returns (uint256 _dripAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _dripAmount);
		}

		emit Claim(msg.sender, reserveToken, _dripAmount);

		return _dripAmount;
	}

	// claims all (xPERPS)
	function claimAll() external nonReentrant returns (uint256 _rewardAmount, uint256 _dripAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;
		_dripAmount = _accountInfo.drip;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;
		}

		uint256 _rewardPlusDripAmount = _rewardAmount + _dripAmount;
		if (_rewardPlusDripAmount > 0) {
			IERC20(reserveToken).safeTransfer(msg.sender, _rewardPlusDripAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);
		emit Claim(msg.sender, reserveToken, _dripAmount);

		return (_rewardAmount, _dripAmount);
	}

	// compounds rewards only (xPERPS)
	function compoundReward() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			_deposit(address(this), _rewardAmount, msg.sender);
		}

		emit Compound(msg.sender, rewardToken, _rewardAmount);
	}

	// compounds drip only (xPERPS)
	function compoundDrip() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			_deposit(address(this), _dripAmount, msg.sender);
		}

		emit Compound(msg.sender, reserveToken, _dripAmount);
	}

	// compounds all (xPERPS)
	function compoundAll() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;
		uint256 _dripAmount = _accountInfo.drip;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;
		}

		uint256 _rewardPlusDripAmount = _rewardAmount + _dripAmount;
		if (_rewardPlusDripAmount > 0) {
			_deposit(address(this), _rewardPlusDripAmount, msg.sender);
		}

		emit Compound(msg.sender, rewardToken, _rewardAmount);
		emit Compound(msg.sender, reserveToken, _dripAmount);
	}

	// sends xPERPS to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends xPERPS to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		accRewardPerShare += _amount * 1e18 / totalStaked;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// sends xPERPS to drip pool
	function donateDrip(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		totalDrip += _amount;

		IERC20(reserveToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit DonateDrip(msg.sender, reserveToken, _amount);
	}

	// performs the daily distribution the drip pool (xPERPS)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		if (totalStaked > 0) {
			// calculates the percentage of the drip pool and distributes
			{
				// formula: drip_reward = drip_pool_balance * (1 - (1 - drip_rate_per_day) ^ days_ellapsed)
				uint64 _days = _today - day;
				uint256 _rate = 100e16 - _exp(100e16 - dripRatePerDay, _days);
				uint256 _amount = (totalDrip - allocDrip) * _rate / 100e16;
				accDripPerShare += _amount * 1e18 / totalStaked;
				allocDrip += _amount;
			}
		}

		day = _today;
	}

	// updates the account balances while accumulating reward/drip using PCS distribution algorithm
	function _updateAccount(address _account, int256 _amount) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}

		_accountInfo.reward += _accountInfo.amount * accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
		_accountInfo.drip += _accountInfo.amount * accDripPerShare / 1e18 - _accountInfo.accDripDebt;
		if (_amount > 0) {
			_accountInfo.amount += uint256(_amount);
		}
		else
		if (_amount < 0) {
			_accountInfo.amount -= uint256(-_amount);
		}
		_accountInfo.accRewardDebt = _accountInfo.amount * accRewardPerShare / 1e18;
		_accountInfo.accDripDebt = _accountInfo.amount * accDripPerShare / 1e18;
	}

	// exponentiation with integer exponent
	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}

	event Deposit(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Compound(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event DonateDrip(address indexed _account, address indexed _reserveToken, uint256 _amount);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { FarmingCompound } from "./FarmingCompound.sol";
import { FarmingVolatile } from "./FarmingVolatile.sol";
import { GrowthBonding } from "../growth/GrowthBonding.sol";

contract MasterChef is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct PoolInfo {
		address token;
		uint256 allocPoint;
		uint256 lastRewardTime;
		uint256 accRewardPerShare;
		uint256 amount;
		uint256 depositFee;
		uint256 withdrawalFee;
		uint256 epochAccRewardPerShare;
	}

	struct UserInfo {
		uint256 amount;
		uint256 rewardDebt;
		uint256 unclaimedReward;
	}

	struct ReferralInfo {
		uint256 volume;
		uint256 reward;
	}

	struct AccountInfo {
		bool exists;
		uint256 reserved0;
		uint256 reserved1;
		uint256 reserved2;
		uint256 reserved3;
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_FAUCET = 0x392681Eaf8AD9BC65e74BE37Afe7503D92802b7d; // multisig
	address constant DEFAULT_BANKROLL = 0x392681Eaf8AD9BC65e74BE37Afe7503D92802b7d; // multisig

	uint256 constant DEFAULT_LAUNCH_TIME = 1663776000; // 2022-09-21 4PM UTC

	uint256[4] public defaultFees = [2.5e16, 5e16, 10e16, 20e16];
	uint256[4] public defaultAllocs = [11.25e16, 16.25e16, 26.25e16, 46.25e16];

	uint256 public epochPeriod = 1 weeks;
	uint256[6] public epochLengthPerPeriod = [24 hours, 20 hours, 16 hours, 12 hours, 8 hours, 6 hours];

	address public rewardToken;
	address public tokenBridge;

	address public farmingCompound;
	address public farmingVolatile;

	address public faucet = DEFAULT_FAUCET;
	address public bankroll = DEFAULT_BANKROLL;

	uint256 public launchTime = DEFAULT_LAUNCH_TIME;
	uint256 public nextEpoch = launchTime + epochLengthPerPeriod[0];

	uint256 public rewardPerSec = 0;
	uint256 public totalAllocPoint = 0;

	uint256 public allocReward = 0;

	PoolInfo[] public poolInfo;

	mapping(uint256 => mapping(address => UserInfo)) public userInfo;

	uint256 public epochIndex = 0;

	ReferralInfo[2] public referralInfo;
	mapping(address => mapping(uint256 => uint256)) public userReferralVolume;

	uint256 constant DEFAULT_CLAIM_FEE = 20e16; // 20%

	uint256 public claimFee = DEFAULT_CLAIM_FEE;

	uint256 constant BASE_WEEK_TIME = 1663722000;  // 2022-09-21 01:00 UTC

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	address public tokenBridgeV2;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function getUserByIndex(uint256 _pid, uint256 _index) external view returns (UserInfo memory _userInfo)
	{
		return userInfo[_pid][accountIndex[_index]];
	}

	function indexAccounts(address[] memory _accounts) external onlyOwner
	{
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			_indexAccount(_accounts[_i]);
		}
	}

	function _indexAccount(address _account) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}
	}

	function epochLength(uint256 /*_when*/) public pure returns (uint256 _epochLength)
	{
		return 24 hours;
		/*
		if (_when < BASE_WEEK_TIME) _when = BASE_WEEK_TIME;
		uint256 _i = (_when - BASE_WEEK_TIME) / epochPeriod;
		if (_i > 5) _i = 5;
		return epochLengthPerPeriod[_i];
		*/
	}

	modifier hasLaunched()
	{
		require(block.timestamp >= launchTime, "unavailable");
		_;
	}

	constructor(address _rewardToken, address _tokenBridge, address _farmingCompound, address _farmingVolatile)
	{
		initialize(msg.sender, _rewardToken, _tokenBridge, _farmingCompound, _farmingVolatile);
	}

	function initialize(address _owner, address _rewardToken, address _tokenBridge, address _farmingCompound, address _farmingVolatile) public initializer
	{
		_transferOwnership(_owner);

		defaultFees = [2.5e16, 5e16, 10e16, 20e16];
		defaultAllocs = [11.25e16, 16.25e16, 26.25e16, 46.25e16];

		epochPeriod = 1 weeks;
		epochLengthPerPeriod = [24 hours, 20 hours, 16 hours, 12 hours, 8 hours, 6 hours];

		faucet = DEFAULT_FAUCET;
		bankroll = DEFAULT_BANKROLL;

		launchTime = DEFAULT_LAUNCH_TIME;
		nextEpoch = launchTime + epochLengthPerPeriod[0];

		rewardPerSec = 0;
		totalAllocPoint = 0;

		allocReward = 0;

		epochIndex = 0;

		claimFee = DEFAULT_CLAIM_FEE;

		rewardToken = _rewardToken;
		tokenBridge = _tokenBridge;

		farmingCompound = _farmingCompound;
		farmingVolatile = _farmingVolatile;
	}

	function setFaucet(address _faucet) external onlyOwner
	{
		require(_faucet != address(0), "invalid address");
		faucet = _faucet;
	}

	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}
/*
	function setTokenBridge(address _tokenBridge) external onlyOwner
	{
		tokenBridge = _tokenBridge;
	}

	function setTokenBridgeV2(address _tokenBridgeV2) external onlyOwner
	{
		tokenBridgeV2 = _tokenBridgeV2;
	}
*/
	function setLaunchTime(uint256 _launchTime) external onlyOwner
	{
		require(block.timestamp < launchTime, "unavailable");
		require(_launchTime >= block.timestamp, "invalid time");
		for (uint256 _pid = 0; _pid < poolInfo.length; _pid++) {
			PoolInfo storage _poolInfo = poolInfo[_pid];
			if (_poolInfo.lastRewardTime <= launchTime) {
				_poolInfo.lastRewardTime = _launchTime;
			}
		}
		launchTime = _launchTime;
		nextEpoch = _launchTime + epochLengthPerPeriod[0];
	}

	function updateEpochPeriod(uint256 _period) external onlyOwner
	{
		require(_period > 0, "invalid period");
		epochPeriod = _period;
	}

	function updateEpochLengthPerPeriod(uint256 _i, uint256 _length) external onlyOwner
	{
		require(_i < 6, "invalid index");
		require(_length > 0, "invalid length");
		epochLengthPerPeriod[_i] = _length;
		if (block.timestamp < launchTime && _i == 0) {
			nextEpoch = launchTime + epochLengthPerPeriod[0];
		}
	}

	function updateNextEpoch(uint256 _nextEpoch) external onlyOwner
	{
		require(_nextEpoch > block.timestamp, "invalid time");
		nextEpoch = _nextEpoch;
	}

	function updateRewardPerSec(uint256 _rewardPerSec) external onlyOwner nonReentrant
	{
		_massUpdatePools();
		rewardPerSec = _rewardPerSec;
	}

	function addPool(address _token, uint256 _allocPoint, uint256 _startTime, uint256 _depositFee, uint256 _withdrawalFee) external onlyOwner nonReentrant
	{
		require(_token != address(0), "invalid address");
		require(_startTime >= launchTime && _startTime >= block.timestamp, "invalid timestamp");
		require(_depositFee <= 100e16, "invalid rate");
		require(_withdrawalFee <= 100e16, "invalid rate");
		_massUpdatePools();
		totalAllocPoint += _allocPoint;
		poolInfo.push(PoolInfo({
			token: _token,
			allocPoint: _allocPoint,
			lastRewardTime: _startTime,
			accRewardPerShare: 0,
			amount: 0,
			depositFee: _depositFee,
			withdrawalFee: _withdrawalFee,
			epochAccRewardPerShare: 0
		}));
		for (uint256 _i = 1; _i < 4; _i++) {
			poolInfo.push(PoolInfo({
				token: _token,
				allocPoint: 0,
				lastRewardTime: type(uint256).max,
				accRewardPerShare: 0,
				amount: 0,
				depositFee: 100e16,
				withdrawalFee: 100e16,
				epochAccRewardPerShare: 0
			}));
		}
	}

	function updatePoolAllocPoints(uint256 _pid, uint256 _allocPoint) external onlyOwner nonReentrant
	{
		require(_pid % 4 == 0, "invalid pid");
		_massUpdatePools();
		PoolInfo storage _poolInfo = poolInfo[_pid];
		totalAllocPoint -= _poolInfo.allocPoint;
		_poolInfo.allocPoint = _allocPoint;
		totalAllocPoint += _poolInfo.allocPoint;
	}

	function addCluster(address _token, uint256 _allocPoint, uint256 _startTime) external onlyOwner nonReentrant
	{
		require(_token != address(0), "invalid address");
		require(_startTime >= launchTime && _startTime >= block.timestamp, "invalid timestamp");
		_massUpdatePools();
		totalAllocPoint += _allocPoint;
		for (uint256 _i = 0; _i < 4; _i++) {
			poolInfo.push(PoolInfo({
				token: _token,
				allocPoint: _allocPoint * defaultAllocs[_i] / 100e16,
				lastRewardTime: _startTime,
				accRewardPerShare: 0,
				amount: 0,
				depositFee: defaultFees[_i],
				withdrawalFee: defaultFees[_i],
				epochAccRewardPerShare: 0
			}));
		}
	}

	function updateClusterAllocPoints(uint256 _pid, uint256 _allocPoint) external onlyOwner nonReentrant
	{
		require(_pid % 4 == 0, "invalid pid");
		_massUpdatePools();
		for (uint256 _i = 0; _i < 4; _i++) {
			PoolInfo storage _poolInfo = poolInfo[_pid + _i];
			totalAllocPoint -= _poolInfo.allocPoint;
			_poolInfo.allocPoint = _allocPoint * defaultAllocs[_i] / 100e16;
			totalAllocPoint += _poolInfo.allocPoint;
		}
	}

	function setClaimFee(uint256 _claimFee) external onlyOwner
	{
		require(_claimFee <= 100e16, "invalid rate");
		claimFee = _claimFee;
	}

	function recoverLostFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = 0;
		for (uint256 _pid = 0; _pid < poolInfo.length; _pid++) {
			PoolInfo storage _poolInfo = poolInfo[_pid];
			if (_token == _poolInfo.token) {
				_amount += _poolInfo.amount;
			}
		}
		uint256 _balance = IERC20(_token).balanceOf(address(this));
		IERC20(_token).safeTransfer(msg.sender, _balance - _amount);
	}

	function massUpdatePools() external nonReentrant
	{
		_massUpdatePools();
	}

	function updatePool(uint256 _pid) external nonReentrant
	{
		_updatePool(_pid);
	}

	function updateEpoch() external nonReentrant
	{
		_updateEpoch();
	}

	function pendingReferral(address _account) external nonReentrant returns (uint256 _amount)
	{
		_updateEpoch();
		require(epochIndex > 0, "unavailable");
		uint256 _lastEpoch = epochIndex - 1;
		uint256 _volume = userReferralVolume[_account][_lastEpoch];
		if (_volume == 0) return 0;
		uint256 _index = _lastEpoch % 2;
		uint256 _totalVolume = referralInfo[_index].volume;
		uint256 _totalReward = referralInfo[_index].reward;
		return _volume * _totalReward / _totalVolume;
	}

	function pendingReward(uint256 _pid, address _account) external nonReentrant returns (uint256 _reward)
	{
		PoolInfo storage _poolInfo = poolInfo[_pid];
		UserInfo storage _userInfo = userInfo[_pid][_account];
		_updatePool(_pid);
		{
			uint256 epochRewardDebt = _userInfo.amount * _poolInfo.epochAccRewardPerShare / 1e18;
			if (epochRewardDebt > _userInfo.rewardDebt) _userInfo.rewardDebt = epochRewardDebt;
		}
		return _userInfo.amount * _poolInfo.accRewardPerShare / 1e18 - _userInfo.rewardDebt + _userInfo.unclaimedReward;
	}

	function deposit(uint256 _pid, uint256 _amount) external nonReentrant hasLaunched
	{
		_depositOnBehalfOf(msg.sender, _pid, _amount, msg.sender, address(0));
	}

	function depositOnBehalfOf(uint256 _pid, uint256 _amount, address _account, address _referral) external nonReentrant hasLaunched
	{
		require(msg.sender == _account || msg.sender == tokenBridge || msg.sender == tokenBridgeV2, "access denied");
		_depositOnBehalfOf(msg.sender, _pid, _amount, _account, _referral);
	}

	function _depositOnBehalfOf(address _sender, uint256 _pid, uint256 _amount, address _account, address _referral) internal
	{
		PoolInfo storage _poolInfo = poolInfo[_pid];
		UserInfo storage _userInfo = userInfo[_pid][_account];
		_indexAccount(_account);
		_updatePool(_pid);
		if (_referral != address(0) && _referral != _sender) {
			userReferralVolume[_referral][epochIndex] += _amount;
			uint256 _index = epochIndex % 2;
			referralInfo[_index].volume += _amount;
			emit Referral(_referral, epochIndex, _amount);
		}
		if (_userInfo.amount > 0) {
			{
				uint256 epochRewardDebt = _userInfo.amount * _poolInfo.epochAccRewardPerShare / 1e18;
				if (epochRewardDebt > _userInfo.rewardDebt) _userInfo.rewardDebt = epochRewardDebt;
			}
			uint256 _reward = _userInfo.amount * _poolInfo.accRewardPerShare / 1e18 - _userInfo.rewardDebt;
			if (_reward > 0) {
				allocReward -= _reward;
				_userInfo.unclaimedReward += _reward;
			}
		}
		if (_amount > 0) {
			uint256 _feeAmount = _amount * _poolInfo.depositFee / 1e18;
			uint256 _netAmount = _amount - _feeAmount;
			_userInfo.amount += _netAmount;
			_poolInfo.amount += _netAmount;
			if (_sender != address(this)) {
				IERC20(_poolInfo.token).safeTransferFrom(_sender, address(this), _netAmount);
			}
			if (_feeAmount > 0) {
				if (_sender == address(this)) {
					IERC20(_poolInfo.token).safeTransfer(bankroll, _feeAmount);
				} else {
					IERC20(_poolInfo.token).safeTransferFrom(_sender, bankroll, _feeAmount);
				}
			}
		}
		_userInfo.rewardDebt = _userInfo.amount * _poolInfo.accRewardPerShare / 1e18;
		emit Deposit(_account, _pid, _amount);
	}

	function withdraw(uint256 _pid, uint256 _amount) external
	{
		withdrawOnBehalfOf(_pid, _amount, msg.sender);
	}

	function withdrawOnBehalfOf(uint256 _pid, uint256 _amount, address _account) public nonReentrant
	{
		require(msg.sender == _account || msg.sender == tokenBridge || msg.sender == tokenBridgeV2, "access denied");
		PoolInfo storage _poolInfo = poolInfo[_pid];
		UserInfo storage _userInfo = userInfo[_pid][_account];
		require(_amount <= _userInfo.amount, "insufficient balance");
		_updatePool(_pid);
		{
			{
				uint256 epochRewardDebt = _userInfo.amount * _poolInfo.epochAccRewardPerShare / 1e18;
				if (epochRewardDebt > _userInfo.rewardDebt) _userInfo.rewardDebt = epochRewardDebt;
			}
			uint256 _reward = _userInfo.amount * _poolInfo.accRewardPerShare / 1e18 - _userInfo.rewardDebt;
			if (_reward > 0) {
				allocReward -= _reward;
				_userInfo.unclaimedReward += _reward;
			}
		}
		if (_amount > 0) {
			uint256 _feeAmount = _amount * _poolInfo.withdrawalFee / 1e18;
			uint256 _netAmount = _amount - _feeAmount;
			_userInfo.amount -= _amount;
			_poolInfo.amount -= _amount;
			IERC20(_poolInfo.token).safeTransfer(msg.sender, _netAmount);
			if (_feeAmount > 0) {
				IERC20(_poolInfo.token).safeTransfer(bankroll, _feeAmount);
			}
		}
		_userInfo.rewardDebt = _userInfo.amount * _poolInfo.accRewardPerShare / 1e18;
		emit Withdraw(_account, _pid, _amount);
	}

	function emergencyWithdraw(uint256 _pid) external nonReentrant
	{
		PoolInfo storage _poolInfo = poolInfo[_pid];
		UserInfo storage _userInfo = userInfo[_pid][msg.sender];
		uint256 _amount = _userInfo.amount;
		_userInfo.amount = 0;
		_userInfo.rewardDebt = 0;
		_poolInfo.amount -= _amount;
		uint256 _feeAmount = _amount * _poolInfo.withdrawalFee / 1e18;
		uint256 _netAmount = _amount - _feeAmount;
		IERC20(_poolInfo.token).safeTransfer(msg.sender, _netAmount);
		if (_feeAmount > 0) {
			IERC20(_poolInfo.token).safeTransfer(bankroll, _feeAmount);
		}
		emit EmergencyWithdraw(msg.sender, _pid, _amount);
	}

	function claimReferral() external nonReentrant returns (uint256 _amount)
	{
		_amount = _updateReferral(msg.sender);
		if (_amount > 0) {
			uint256 _feeAmount = _amount * claimFee / 1e18;
			uint256 _netAmount = _amount - _feeAmount;
			allocReward -= _netAmount;
			IERC20(rewardToken).safeTransferFrom(faucet, msg.sender, _netAmount);
		}
		emit ClaimReferral(msg.sender, _amount);
		return _amount;
	}

	function claimReward(uint256 _pid) external nonReentrant returns (uint256 _amount)
	{
		_amount = _updateReward(_pid, msg.sender);
		if (_amount > 0) {
			uint256 _feeAmount = _amount * claimFee / 1e18;
			uint256 _netAmount = _amount - _feeAmount;
			allocReward += _feeAmount;
			IERC20(rewardToken).safeTransferFrom(faucet, msg.sender, _netAmount);
		}
		emit ClaimReward(msg.sender, _pid, _amount);
		return _amount;
	}

	function compoundReferral(uint256 _pid0) external nonReentrant returns (uint256 _amount)
	{
		{
			PoolInfo storage _poolInfo = poolInfo[_pid0];
			require(_pid0 % 4 >= 2 && _poolInfo.token == rewardToken, "invalid pid");
		}
		_amount = _updateReferral(msg.sender);
		if (_amount > 0) {
			allocReward -= _amount;
			IERC20(rewardToken).safeTransferFrom(faucet, address(this), _amount);
			_depositOnBehalfOf(address(this), _pid0, _amount, msg.sender, address(0));
		}
		emit CompoundReferral(msg.sender, _pid0, _amount);
		return _amount;
	}

	function compoundReward(uint256 _pid0, uint256 _pid) external nonReentrant returns (uint256 _amount)
	{

		{
			PoolInfo storage _poolInfo = poolInfo[_pid0];
			require(_pid0 % 4 >= 2 && _poolInfo.token == rewardToken, "invalid pid");
		}
		_amount = _updateReward(_pid, msg.sender);
		if (_amount > 0) {
			IERC20(rewardToken).safeTransferFrom(faucet, address(this), _amount);
			_depositOnBehalfOf(address(this), _pid0, _amount, msg.sender, address(0));
		}
		emit CompoundReward(msg.sender, _pid0, _pid, _amount);
		return _amount;
	}

	function compoundAll(uint256 _pid0, uint256[] memory _pidList) external nonReentrant returns (uint256 _amount)
	{
		{
			PoolInfo storage _poolInfo = poolInfo[_pid0];
			require(_pid0 % 4 >= 2 && _poolInfo.token == rewardToken, "invalid pid");
		}
		_amount = 0;
		for (uint256 _i = 0; _i < _pidList.length; _i++) {
			_amount += _updateReward(_pidList[_i], msg.sender);
		}
		if (_amount > 0) {
			IERC20(rewardToken).safeTransferFrom(faucet, address(this), _amount);
			_depositOnBehalfOf(address(this), _pid0, _amount, msg.sender, address(0));
		}
		emit CompoundAll(msg.sender, _pid0, _amount);
		return _amount;
	}

	function _updateReferral(address _account) internal returns (uint256 _amount)
	{
		_updateEpoch();
		require(epochIndex > 0, "unavailable");
		uint256 _lastEpoch = epochIndex - 1;
		uint256 _volume = userReferralVolume[_account][_lastEpoch];
		if (_volume == 0) return 0;
		userReferralVolume[_account][_lastEpoch] = 0;
		uint256 _index = _lastEpoch % 2;
		uint256 _totalVolume = referralInfo[_index].volume;
		uint256 _totalReward = referralInfo[_index].reward;
		_amount = _volume * _totalReward / _totalVolume;
		referralInfo[_index].volume = _totalVolume - _volume;
		referralInfo[_index].reward = _totalReward - _amount;
		return _amount;
	}

	function _updateReward(uint256 _pid, address _account) internal returns (uint256 _amount)
	{
		PoolInfo storage _poolInfo = poolInfo[_pid];
		UserInfo storage _userInfo = userInfo[_pid][_account];
		_updatePool(_pid);
		if (_userInfo.amount > 0) {
			{
				uint256 epochRewardDebt = _userInfo.amount * _poolInfo.epochAccRewardPerShare / 1e18;
				if (epochRewardDebt > _userInfo.rewardDebt) _userInfo.rewardDebt = epochRewardDebt;
			}
			uint256 _reward = _userInfo.amount * _poolInfo.accRewardPerShare / 1e18 - _userInfo.rewardDebt;
			if (_reward > 0) {
				allocReward -= _reward;
				_userInfo.unclaimedReward += _reward;
			}
		}
		_userInfo.rewardDebt = _userInfo.amount * _poolInfo.accRewardPerShare / 1e18;
		_amount = _userInfo.unclaimedReward;
		_userInfo.unclaimedReward = 0;
		return _amount;
	}

	function _massUpdatePools() internal
	{
		_updateEpoch();
		_massUpdatePools(block.timestamp, false);
	}

	function _updatePool(uint256 _pid) internal
	{
		_updateEpoch();
		_updatePool(_pid, block.timestamp, false);
	}

	function _updateEpoch() internal
	{
		if (block.timestamp < nextEpoch) return;

		uint256 _lastEpoch;
		do {
			_lastEpoch = nextEpoch;
			nextEpoch += epochLength(_lastEpoch);
		} while (nextEpoch <= block.timestamp);

		_massUpdatePools(_lastEpoch, true);

		uint256 _expiredReward = allocReward;

		allocReward = 0;

		epochIndex++;

		{
			uint256 _index = epochIndex % 2;
			referralInfo[_index].volume = 0;
			referralInfo[_index].reward = 0;
		}

		if (_expiredReward > 0) {
			uint256 _10percent = _expiredReward * 10e16 / 100e16;
			uint256 _20percent = _10percent + _10percent;
			uint256 _40percent = _20percent + _20percent;
			uint256 _60percent = _40percent + _20percent;
			uint256 _70percent = _60percent + _10percent;

			{
				uint256 _index = (epochIndex - 1) % 2;
				referralInfo[_index].reward = _10percent;
				allocReward += _20percent;
			}

			IERC20(rewardToken).safeTransferFrom(faucet, FURNACE, _expiredReward - _70percent);
			IERC20(rewardToken).safeTransferFrom(faucet, address(this), _60percent);

			IERC20(rewardToken).approve(farmingCompound, _10percent);
			FarmingCompound(farmingCompound).donateDrip(_10percent);

			IERC20(rewardToken).approve(farmingVolatile, _10percent);
			FarmingVolatile(farmingVolatile).donateDrip(_10percent);

			{
				address BONDS30 = 0x0885D30B594E30062FD8a542842eA1836395e1B3;
				address BONDS60 = 0xC40d78657f605fcEb905e1Be2B8C7F99CADEb360;
				address BONDS90 = 0x80212AcC56e6f49808dE6A597f46a9475311cd7e;
				uint256 _bonds30Amount = _40percent * 15e16 / 100e16; // 15%
				uint256 _bonds60Amount = _bonds30Amount + _bonds30Amount; // 30%
				uint256 _bonds90Amount = _40percent - (_bonds30Amount + _bonds60Amount); // 55%
				IERC20(rewardToken).approve(BONDS30, _bonds30Amount);
				GrowthBonding(BONDS30).reward(_bonds30Amount);
				IERC20(rewardToken).approve(BONDS60, _bonds60Amount);
				GrowthBonding(BONDS60).reward(_bonds60Amount);
				IERC20(rewardToken).approve(BONDS90, _bonds90Amount);
				GrowthBonding(BONDS90).reward(_bonds90Amount);
			}
		}
	}

	function _massUpdatePools(uint256 _when, bool _epochReset) internal
	{
		for (uint256 _pid = 0; _pid < poolInfo.length; _pid++) {
			_updatePool(_pid, _when, _epochReset);
		}
	}

	function _updatePool(uint256 _pid, uint256 _when, bool _epochReset) internal
	{
		PoolInfo storage _poolInfo = poolInfo[_pid];
		if (_when > _poolInfo.lastRewardTime) {
			if (_poolInfo.amount > 0 && _poolInfo.allocPoint > 0) {
				uint256 _reward = (_when - _poolInfo.lastRewardTime) * rewardPerSec * _poolInfo.allocPoint / totalAllocPoint;
				if (_reward > 0) {
					_poolInfo.accRewardPerShare += _reward * 1e18 / _poolInfo.amount;
					allocReward += _reward;
				}
			}
			if (_epochReset) {
				_poolInfo.epochAccRewardPerShare = _poolInfo.accRewardPerShare;
			}
			_poolInfo.lastRewardTime = _when;
		}
	}

	event Referral(address indexed _account, uint256 _epochIndex, uint256 _amount);
	event Deposit(address indexed _account, uint256 indexed _pid, uint256 _amount);
	event Withdraw(address indexed _account, uint256 indexed _pid, uint256 _amount);
	event EmergencyWithdraw(address indexed _account, uint256 indexed _pid, uint256 _amount);
	event ClaimReferral(address indexed _account, uint256 _amount);
	event ClaimReward(address indexed _account, uint256 _pid, uint256 _amount);
	event CompoundReferral(address indexed _account, uint256 indexed _pid0, uint256 _amount);
	event CompoundReward(address indexed _account, uint256 indexed _pid0, uint256 indexed _pid, uint256 _amount);
	event CompoundAll(address indexed _account, uint256 indexed _pid0, uint256 _amount);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
Bonding Deposit Contract xGRO

30/60/90 Day option (pays out in xGRO and xPERPs)
(Mild, Wild, Full throttle)

30 day - 6% deposit fee 6% withdrawal fee of deposited token
1% Mgmt
1% Boosted Stakers
4% Pool
Pool pays out proportionally to stakers at the end of the bond, 30 days in this case.. (if someone withdraws early, they get charged the fee and get nothing at the end of the Bonding period..)

60 day - 16% deposit fee 16% withdrawal fee of deposited token
1.5% Mgmt
1.5% Boosted Stakers
13% Pool
Pool pays out proportionally to stakers at the end of the bond, 60 days in this case.. (if someone withdraws early, they get charged the fee and get nothing at the end of the Bonding period..)

90 day - 33% Deposit fee 33% withdrawal fee of deposited token
3% Mgmt
3% Boosted Stakers
27% Pool
Pool pays out proportionally to stakers at the end of the bond, 90 days in this case.. (if someone withdraws early, they get charged the fee and get nothing at the end of the Bonding period..)

*From the 20% claim tax on xGRO single stake farm: 
*15% of xPERPs goes to 30 day pool
*30% of xPERPs goes to 60 day pool
*55%, of xPERPs goes to 90 day pool

xPERPs Boosted position and sidepot

Deposit xPERPs to gain a boosted position in either the 30,60, or 90 day Bonds. 60% of the deposited xPERPs is burnt, 40% goes to a sidepot, from which positions 1,2, and 3 will split up the Pot at the end of the Bond..

1st Place will receive 55% of the sidepot
2nd Place will receive 30% 
3rd Place will recieve 15%
*/
contract GrowthBonding is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct RoundInfo {
		uint256 startTime;
		uint256 endTime;
		uint256 amount; // total xGRO staked balance
		uint256 boost; // total xGRO accumulated for the extra payout for burners
		uint256 payout; // total xGRO accumulated for the payout
		uint256 reward; // total xPERPS reward balance
		uint256 burned; // total xPERPS burned balance
		uint256 prize; // XPERPS accumulated as prize for top burners
		address[3] top3; // top 3 xPERPS burners
		uint256 weight; // total time-weighted xGRO balance

		uint256 reserved0; // unused
		uint256 reserved1; // unused
		uint256 reserved2; // unused
	}

	struct AccountInfo {
		bool exists; // flag to index account
		uint256 round; // account round
		uint256 amount; // xGRO deposited
		uint256 burned; // xPERPS burned
		uint256 weight; // time-weighted xGRO balance

		uint256 reserved0; // unused
		uint256 reserved1; // unused
		uint256 reserved2; // unused
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x392681Eaf8AD9BC65e74BE37Afe7503D92802b7d; // multisig

	address public reserveToken; // xGRO
	address public rewardToken; // xPERPS
	address public burnToken; // xPERPS

	uint256 public bankrollFee; // percentage of deposits/withdrawals towards the bankroll
	uint256 public boostFee; // percentage of deposits/withdrawals towards the boost pool
	uint256 public payoutFee; // percentage of deposits/withdrawals towards the payout pool

	uint256 public roundLength; // 30 days
	uint256 public roundInterval; // 7 days

	address public bankroll = DEFAULT_BANKROLL;

	uint256 public totalReserve = 0; // total xGRO balance
	uint256 public totalReward = 0; // total xPERPS balance

	RoundInfo[] public roundInfo;

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function roundInfoLength() external view returns (uint256 _roundInfoLength)
	{
		return roundInfo.length;
	}

	function roundInfoTop3(uint256 _index) external view returns (address[3] memory _top3)
	{
		return roundInfo[_index].top3;
	}

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	constructor(address _reserveToken, address _rewardToken, uint256 _bankrollFee, uint256 _boostFee, uint256 _payoutFee, uint256 _launchTime, uint256 _roundLength, uint256 _roundInterval)
	{
		initialize(msg.sender, _reserveToken, _rewardToken, _bankrollFee, _boostFee, _payoutFee, _launchTime, _roundLength, _roundInterval);
	}

	function initialize(address _owner, address _reserveToken, address _rewardToken, uint256 _bankrollFee, uint256 _boostFee, uint256 _payoutFee, uint256 _launchTime, uint256 _roundLength, uint256 _roundInterval) public initializer
	{
		_transferOwnership(_owner);

		bankroll = DEFAULT_BANKROLL;

		totalReserve = 0; // total xGRO balance
		totalReward = 0; // total xPERPS balance

		require(_launchTime >= block.timestamp, "invalid time");
		uint256 _startTime = _launchTime;
		uint256 _endTime = _startTime + _roundLength;
		roundInfo.push(RoundInfo({
			startTime: _startTime,
			endTime: _endTime,
			amount: 0,
			boost: 0,
			payout: 0,
			reward: 0,
			burned: 0,
			prize: 0,
			top3: [address(0), address(0), address(0)],
			weight: 0,

			reserved0: 0,
			reserved1: 0,
			reserved2: 0
		}));

		require(_rewardToken != _reserveToken, "invalid token");
		reserveToken = _reserveToken;
		rewardToken = _rewardToken;
		burnToken = _rewardToken;

		require(_bankrollFee + _boostFee + _payoutFee <= 100e16, "invalid rate");
		bankrollFee = _bankrollFee;
		boostFee = _boostFee;
		payoutFee = _payoutFee;

		require(_roundLength > 0, "invalid length");
		roundLength = _roundLength;
		roundInterval = _roundInterval;
	}

	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	function setStartTime(uint256 _startTime) external onlyOwner
	{
		require(_startTime >= block.timestamp, "invalid time");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		RoundInfo storage _roundInfo = roundInfo[_currentRound];
		require(block.timestamp < _roundInfo.startTime, "not available");

		uint256 _endTime = _startTime + roundLength;

		_roundInfo.startTime = _startTime;
		_roundInfo.endTime = _endTime;
	}

	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == reserveToken) _amount -= totalReserve;
		else
		if (_token == rewardToken) _amount -= totalReward;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	function burn(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(msg.sender);
		}
		if (_accountInfo.amount == 0 && _accountInfo.burned == 0) {
			_accountInfo.round = _currentRound;
		}
		require(_accountInfo.round == _currentRound, "pending redemption");

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];
		require(block.timestamp >= _roundInfo.startTime, "not available");

		uint256 _prizeAmount = _amount * 40e16 / 100e16; // 40%
		uint256 _burnAmount = _amount - _prizeAmount;

		_accountInfo.burned += _amount;

		_roundInfo.burned += _amount;
		_roundInfo.prize += _prizeAmount;

		// updates ranking
		if (msg.sender != _roundInfo.top3[0] && msg.sender != _roundInfo.top3[1] && _accountInfo.burned > accountInfo[_roundInfo.top3[2]].burned) {
			_roundInfo.top3[2] = msg.sender;
		}
		if (accountInfo[_roundInfo.top3[2]].burned > accountInfo[_roundInfo.top3[1]].burned) {
			(_roundInfo.top3[1], _roundInfo.top3[2]) = (_roundInfo.top3[2], _roundInfo.top3[1]);
		}
		if (accountInfo[_roundInfo.top3[1]].burned > accountInfo[_roundInfo.top3[0]].burned) {
			(_roundInfo.top3[0], _roundInfo.top3[1]) = (_roundInfo.top3[1], _roundInfo.top3[0]);
		}

		totalReward += _prizeAmount;

		IERC20(burnToken).safeTransferFrom(msg.sender, FURNACE, _burnAmount);
		IERC20(burnToken).safeTransferFrom(msg.sender, address(this), _prizeAmount);

		emit Burn(msg.sender, burnToken, _amount, _currentRound);
	}

	function deposit(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(msg.sender);
		}
		if (_accountInfo.amount == 0 && _accountInfo.burned == 0) {
			_accountInfo.round = _currentRound;
		}
		require(_accountInfo.round == _currentRound, "pending redemption");

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];
		require(block.timestamp >= _roundInfo.startTime, "not available");
		uint256 _timeLeft = _roundInfo.endTime - block.timestamp;

		uint256 _feeAmount = _amount * bankrollFee / 100e16;
		uint256 _boostedAmount = _amount * boostFee / 100e16;
		uint256 _payoutAmount = _amount * payoutFee / 100e16;
		uint256 _netAmount = _amount - (_feeAmount + _boostedAmount + _payoutAmount);
		uint256 _transferAmount = _netAmount + _payoutAmount + _boostedAmount;

		uint256 _weight = _netAmount * _timeLeft;

		_accountInfo.amount += _netAmount;
		_accountInfo.weight += _weight;

		_roundInfo.amount += _netAmount;
		_roundInfo.boost += _boostedAmount;
		_roundInfo.payout += _payoutAmount;
		_roundInfo.weight += _weight;

		totalReserve += _transferAmount;

		IERC20(reserveToken).safeTransferFrom(msg.sender, bankroll, _feeAmount);
		IERC20(reserveToken).safeTransferFrom(msg.sender, address(this), _transferAmount);

		emit Deposit(msg.sender, reserveToken, _amount, _currentRound);
	}

	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_accountInfo.round == _currentRound, "not available");
		require(_amount <= _accountInfo.amount, "insufficient balance");

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];

		uint256 _feeAmount = _amount * bankrollFee / 100e16;
		uint256 _boostedAmount = _amount * boostFee / 100e16;
		uint256 _payoutAmount = _amount * payoutFee / 100e16;
		uint256 _netAmount = _amount - (_feeAmount + _boostedAmount + _payoutAmount);
		uint256 _transferAmount = _feeAmount + _netAmount;

		uint256 _weight = _amount * _accountInfo.weight / _accountInfo.amount;

		_accountInfo.amount -= _amount;
		_accountInfo.weight -= _weight;

		_roundInfo.amount -= _amount;
		_roundInfo.boost += _boostedAmount;
		_roundInfo.payout += _payoutAmount;
		_roundInfo.weight -= _weight;

		totalReserve -= _transferAmount;

		IERC20(reserveToken).safeTransfer(bankroll, _feeAmount);
		IERC20(reserveToken).safeTransfer(msg.sender, _netAmount);

		emit Withdraw(msg.sender, reserveToken, _amount, _currentRound);
	}

	function estimateRedemption(address _account) public view returns (uint256 _amount, uint256 _boostAmount, uint256 _payoutAmount, uint256 _weightedPayoutAmount, uint256 _divsAmount, uint256 _weightedDivsAmount, uint256 _prizeAmount, bool _available)
	{
		AccountInfo storage _accountInfo = accountInfo[_account];

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];

		uint256 _halfPayout = _roundInfo.payout / 2;
		uint256 _halfReward = _roundInfo.reward / 2;

		_amount = _accountInfo.amount;
		_boostAmount = _accountInfo.burned == 0 ? 0 : _accountInfo.burned * _roundInfo.boost / _roundInfo.burned;
		_payoutAmount = _accountInfo.amount == 0 ? 0 : _accountInfo.amount * _halfPayout / _roundInfo.amount;
		_weightedPayoutAmount = _accountInfo.weight == 0 ? 0 : _accountInfo.weight * _halfPayout / _roundInfo.weight;

		_divsAmount = _accountInfo.amount == 0 ? 0 : _accountInfo.amount * _halfReward / _roundInfo.amount;
		_weightedDivsAmount = _accountInfo.weight == 0 ? 0 : _accountInfo.weight * _halfReward / _roundInfo.weight;
		_prizeAmount = 0;
		if (msg.sender == _roundInfo.top3[0]) {
			_prizeAmount = _roundInfo.prize * 55e16 / 100e16; // 55% 1st place
		}
		else
		if (msg.sender == _roundInfo.top3[1]) {
			_prizeAmount = _roundInfo.prize * 30e16 / 100e16; // 30% 2nd place
		}
		else
		if (msg.sender == _roundInfo.top3[2]) {
			_prizeAmount = _roundInfo.prize * 15e16 / 100e16; // 15% 3rd place
		}
		_available = block.timestamp >= _roundInfo.endTime;

		return (_amount, _boostAmount, _payoutAmount, _weightedPayoutAmount, _divsAmount, _weightedDivsAmount, _prizeAmount, _available);
	}

	function redeem() external nonReentrant
	{
		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_accountInfo.amount > 0 || _accountInfo.burned > 0, "no balance");
		uint256 _accountRound = _accountInfo.round;
		require(_accountRound < _currentRound, "open round");

		(uint256 _amount, uint256 _boostAmount, uint256 _payoutAmount, uint256 _weightedPayoutAmount, uint256 _divsAmount, uint256 _weightedDivsAmount, uint256 _prizeAmount, bool _available) = estimateRedemption(msg.sender);
		require(_available, "not available"); // should never happen

		emit AccountUponRedemption(msg.sender, _accountInfo.round, _accountInfo.amount, _accountInfo.burned, _accountInfo.weight);

		uint256 _reserveAmount = _amount + _boostAmount + _payoutAmount + _weightedPayoutAmount;
		uint256 _rewardAmount = _divsAmount + _weightedDivsAmount + _prizeAmount;

		_accountInfo.round = _currentRound;
		_accountInfo.amount = 0;
		_accountInfo.burned = 0;
		_accountInfo.weight = 0;

		totalReserve -= _reserveAmount;
		totalReward -= _rewardAmount;

		IERC20(reserveToken).safeTransfer(msg.sender, _reserveAmount);
		IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);

		emit Redeem(msg.sender, reserveToken, _reserveAmount, rewardToken, _rewardAmount, _accountRound);
	}

	function reward(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		RoundInfo storage _roundInfo = roundInfo[_currentRound];

		_roundInfo.reward += _amount;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit Reward(msg.sender, rewardToken, _amount, _currentRound);
	}

	function updateRound() external
	{
		_updateRound();
	}

	function _updateRound() internal
	{
		RoundInfo storage _roundInfo = roundInfo[roundInfo.length - 1];
		if (block.timestamp < _roundInfo.endTime) return;
		uint256 _roundIntervalPlusLength = roundInterval + roundLength;
		uint256 _skippedRounds = (block.timestamp - _roundInfo.endTime) / _roundIntervalPlusLength;
		uint256 _startTime = _roundInfo.endTime + _skippedRounds * _roundIntervalPlusLength + roundInterval;
		uint256 _endTime = _startTime + roundLength;
		roundInfo.push(RoundInfo({
			startTime: _startTime,
			endTime: _endTime,
			amount: 0,
			boost: 0,
			payout: 0,
			reward: 0,
			burned: 0,
			prize: 0,
			top3: [address(0), address(0), address(0)],
			weight: 0,

			reserved0: 0,
			reserved1: 0,
			reserved2: 0
		}));
	}

	event Burn(address indexed _account, address _burnToken, uint256 _amount, uint256 indexed _round);
	event Deposit(address indexed _account, address _reserveToken, uint256 _amount, uint256 indexed _round);
	event Withdraw(address indexed _account, address _reserveToken, uint256 _amount, uint256 indexed _round);
	event AccountUponRedemption(address indexed _account, uint256 indexed _round, uint256 _amount, uint256 _burned, uint256 _weight);
	event Redeem(address indexed _account, address _reserveToken, uint256 _reserveAmount, address _rewardToken, uint256 _rewardAmount, uint256 indexed _round);
	event Reward(address indexed _account, address _rewardToken, uint256 _amount, uint256 indexed _round);
}