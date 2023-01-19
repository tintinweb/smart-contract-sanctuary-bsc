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

interface IUniswapV2Factory
{
	function createPair(address _tokenA, address _tokenB) external returns (address _pair);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

interface IUniswapV2Pair
{
	function sync() external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

interface IUniswapV2Router
{
	function WETH() external view returns (address _WETH);
	function factory() external view returns (address _factory);

	function addLiquidityETH(address _token, uint256 _amountTokenDesired, uint256 _amountTokenMin, uint256 _amountETHMin, address _to, uint256 _deadline) external payable returns (uint256 _amountToken, uint256 _amountETH, uint256 _liquidity);
	function addLiquidity(address _tokenA, address _tokenB, uint256 _amountADesired, uint256 _amountBDesired, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB, uint256 _liquidity);
	function swapExactETHForTokens(uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function swapExactTokensForETH(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external;
	function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { IUniswapV2Router } from "./IUniswapV2Router.sol";
import { IUniswapV2Factory } from "./IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "./IUniswapV2Pair.sol";

contract LevelXToken is Initializable, Ownable, ERC20
{
	using Address for address;
	using SafeERC20 for IERC20;

	struct RewardInfo {
		bool exists; // existence flag
		address bankroll; // receiver of reward cut
		address[] path; // conversion path from BNB
		uint256 rewardBalance; // tracked balance
		mapping(uint256 => uint256) accRewardPerShare; // accumulated reward per share (by week)
	}

	struct AccountInfo {
		bool exists; // existence flag
		uint256 lastWeek; // timestamp of last week sync'ed
		uint256 weekIndex; // index of last week sync'ed
		uint256 lastEpoch; // timestamp of last epoch sync'ed
		uint256 epochIndex; // index of last epoch sync'ed
		uint256 level; // reward level (user's share multiplier for rewards)
		uint256 activeBalance; // 0 or user's balance (if above the minimum for rewards)
		mapping(address => AccountRewardInfo) rewardInfo;
	}

	struct AccountRewardInfo {
		uint256 rewardDebt; // base for reward distribution
		uint256 unclaimedReward; // reward balance available for claim
	}

	uint256 constant WEEK_DURATION = 1 weeks; // interval between automatic level bumps
	uint256 constant EPOCH_DURATION = 15 minutes; // interval between rebases

	uint256 constant INITIAL_SUPPLY = 500_000_000e18; // 500M

	uint256 constant DEFAULT_BUY_FEE = 10e16; // 10%
	uint256 constant DEFAULT_SELL_FEE = 15e16; // 15%

	uint256 constant DEFAULT_FEE_LIQUIDITY_CUT = 20e16; // 20% of fees

	uint256 constant DEFAULT_MINIMUM_FEE_BALANCE_TO_SWAP = 1e18; // 1 LVLX
	uint256 constant DEFAULT_MINIMUM_REWARD_BALANCE_TO_SWAP = 1e18; // 1 BNB

	uint256 constant DEFAULT_BURN_AMOUNT_TO_BUMP_LEVEL = 10_000e18; // 10k LVLX

	uint256 constant DEFAULT_MINIMUM_BALANCE_FOR_REWARDS = 10_000e18; // 10k LVLX

	uint256 constant DEFAULT_REBASE_RATE_PER_EPOCH = 0.01e16; // 0.01% every 15m

	address constant INTERNAL_ADDRESS = address(1); // used internally to record pending rebase balances

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	// token name and symbol
	string private name_;
	string private symbol_;

	// internal flags
	bool private bypass_; // internal flag to bypass all token logic
	bool private inswap_; // internal flag to bypass buy/sell portions of token logic

	address public router; // PCS router
	address public WBNB; // wrapped BNB
	address public pair; // LVLX/BNB PCS liquidity pool

	address[] public pathWBNB; // route from LVLX to WBNB

	uint256 public buyFee; // percentage of LVLX transfer amount taken on buys
	uint256 public sellFee; // percentage of LVLX transfer amount taken on sells

	uint256 public feeLiquidityCut; // percentage of fees to be added as LVLX/BNB liquidity

	address public liquidityRecipient; // LVLX/BNB lp shares are sent to this address

	uint256 public minimumFeeBalanceToSwap; // minimum amount of LVLX to trigger BNB swap and LVLX/BNB liqudity injection
	uint256 public minimumRewardBalanceToSwap; // minimum amount of BNB to trigger rewards swap

	uint256 public burnAmountToBumpLevel; // amount of LVLX to be burned to increase level by one

	uint256 public minimumBalanceForRewards; // amount of LVLX to be hold to participate on rebases and receive rewards

	uint256 public lastWeek; // timestamp of last week sync'ed
	uint256 public weekIndex; // index of last week sync'ed

	uint256 public lastEpoch; // timestamp of last epoch sync'ed
	uint256 public epochIndex; // index of last epoch sync'ed

	uint256 public totalActiveSupply; // sum of active balances for all LVLX holders
	uint256 public totalShares; // sum of share (level * active balance) for all LVLX holders

	uint256 public nextRebaseRatePerEpoch; // rebase rate (per epoch) to apply when the next week boundary is reached
	mapping(uint256 => uint256) public rebaseRatePerEpoch; // rebase rate (per epock) by week

	address[] public rewardIndex; // list of reward tokens
	mapping(address => RewardInfo) public rewardInfo; // reward token attributes

	address[] public accountIndex; // list of all accounts that ever received LVLX
	mapping(address => AccountInfo) public accountInfo; // account attributes

	mapping(address => bool) public excludeFromTransferPenaltyAsSender; // whitelist to avoid 1 level penalty when LVLX is sent
	mapping(address => bool) public excludeFromTransferPenaltyAsReceiver; // whitelist to avoid 1 level penalty when LVLX is received

	mapping(address => bool) public excludeFromTradeFeeAsBuyer; // whitelist to avoid fees on LVLX buys
	mapping(address => bool) public excludeFromTradeFeeAsSeller; // whitelist to avoid fees on LVLX sells

	mapping(address => bool) public excludeFromRewardsDefaultBehavior; // whitelist to turn-off rebasing/rewards for EOA accounts or turn-on rebasing/rewards for contracts

	mapping(uint256 => mapping(uint256 => uint256)) public expCache; // caches exponential computations

	function name() public view override returns (string memory _name)
	{
		return name_;
	}

	function symbol() public view override returns (string memory _symbol)
	{
		return symbol_;
	}

	function rewardIndexLength() external view returns (uint256 _length)
	{
		return rewardIndex.length;
	}

	function rewardPath(address _rewardToken) external view returns (address[] memory _path)
	{
		return rewardInfo[_rewardToken].path;
	}

	function accRewardPerShare(address _rewardToken, uint256 _weekIndex) external view returns (uint256 _accRewardPerShare)
	{
		return rewardInfo[_rewardToken].accRewardPerShare[_weekIndex];
	}

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function accountRewardInfo(address _account, address _rewardToken) external view returns (AccountRewardInfo memory _accountRewardInfo)
	{
		return accountInfo[_account].rewardInfo[_rewardToken];
	}

	function week() public view returns (uint256 _week)
	{
		return (block.timestamp / WEEK_DURATION) * WEEK_DURATION;
	}

	function epoch() public view returns (uint256 _epoch)
	{
		return (block.timestamp / EPOCH_DURATION) * EPOCH_DURATION;
	}

	constructor(string memory _name, string memory _symbol, address _router)
		ERC20("", "")
	{
		initialize(msg.sender, _name, _symbol, _router);
	}

	function initialize(address _owner, string memory _name, string memory _symbol, address _router) public initializer
	{
		require(WEEK_DURATION % EPOCH_DURATION == 0, "misaligned duration");

		_transferOwnership(_owner);

		name_ = _name;
		symbol_ = _symbol;

		bypass_ = false;
		inswap_ = false;

		router = _router;
		WBNB = IUniswapV2Router(router).WETH();
		pair = IUniswapV2Factory(IUniswapV2Router(router).factory()).createPair(WBNB, address(this));

		pathWBNB = new address[](2);
		pathWBNB[0] = address(this);
		pathWBNB[1] = WBNB;

		buyFee = DEFAULT_BUY_FEE;
		sellFee = DEFAULT_SELL_FEE;

		feeLiquidityCut = DEFAULT_FEE_LIQUIDITY_CUT;

		liquidityRecipient = _owner;

		minimumFeeBalanceToSwap = DEFAULT_MINIMUM_FEE_BALANCE_TO_SWAP;
		minimumRewardBalanceToSwap = DEFAULT_MINIMUM_REWARD_BALANCE_TO_SWAP;

		burnAmountToBumpLevel = DEFAULT_BURN_AMOUNT_TO_BUMP_LEVEL;

		minimumBalanceForRewards = DEFAULT_MINIMUM_BALANCE_FOR_REWARDS;

		lastWeek = week();
		weekIndex = 0;

		lastEpoch = epoch();
		epochIndex = 0;

		totalActiveSupply = 0;
		totalShares = 0;

		nextRebaseRatePerEpoch = DEFAULT_REBASE_RATE_PER_EPOCH;
		rebaseRatePerEpoch[weekIndex] = nextRebaseRatePerEpoch;

		excludeFromTransferPenaltyAsSender[pair] = true;
		excludeFromTransferPenaltyAsSender[address(this)] = true;
		excludeFromTransferPenaltyAsReceiver[address(this)] = true;

		excludeFromTradeFeeAsSeller[address(this)] = true;

		excludeFromRewardsDefaultBehavior[pair] = true;
		excludeFromRewardsDefaultBehavior[FURNACE] = true;

		_approve(address(this), router, type(uint256).max);
		IERC20(WBNB).approve(router, type(uint256).max);

		_mint(msg.sender, INITIAL_SUPPLY);
	}

	function updateBuyFee(uint256 _buyFee) external onlyOwner
	{
		require(_buyFee <= 100e16, "invalid rate");
		buyFee = _buyFee;
	}

	function updateSellFee(uint256 _sellFee) external onlyOwner
	{
		require(_sellFee <= 100e16, "invalid rate");
		sellFee = _sellFee;
	}

	function updateFeeLiquidityCut(uint256 _feeLiquidityCut) external onlyOwner
	{
		require(_feeLiquidityCut <= 100e16, "invalid rate");
		feeLiquidityCut = _feeLiquidityCut;
	}

	function updateLiquidityRecipient(address _liquidityRecipient) external onlyOwner
	{
		require(_liquidityRecipient != address(0), "invalid address");
		liquidityRecipient = _liquidityRecipient;
	}

	function updateMinimumFeeBalanceToSwap(uint256 _minimumFeeBalanceToSwap) external onlyOwner
	{
		minimumFeeBalanceToSwap = _minimumFeeBalanceToSwap;
	}

	function updateMinimumRewardBalanceToSwap(uint256 _minimumRewardBalanceToSwap) external onlyOwner
	{
		minimumRewardBalanceToSwap = _minimumRewardBalanceToSwap;
	}

	function addRewardToken(address _rewardToken, address _bankroll, address[] memory _path) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		require(_rewardToken != address(this), "invalid path");
		require(_path.length >= 2 && _path[0] == WBNB && _path[_path.length - 1] == _rewardToken, "invalid path");
		for (uint256 _i = 1; _i <= _path.length - 2; _i++) {
			require(_path[_i] != address(this), "invalid path");
		}
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		require(!_rewardInfo.exists, "already exists");
		_rewardInfo.exists = true;
		_rewardInfo.bankroll = _bankroll;
		_rewardInfo.path = _path;
		rewardIndex.push(_rewardToken);
	}

	function updateRewardBankroll(address _rewardToken, address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		require(_rewardInfo.exists, "unknown reward");
		_rewardInfo.bankroll = _bankroll;
	}

	function updateRewardPath(address _rewardToken, address[] memory _path) external onlyOwner
	{
		require(_path.length >= 2 && _path[0] == WBNB && _path[_path.length - 1] == _rewardToken, "invalid path");
		for (uint256 _i = 1; _i <= _path.length - 2; _i++) {
			require(_path[_i] != address(this), "invalid path");
		}
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		require(_rewardInfo.exists, "unknown reward");
		_rewardInfo.path = _path;
	}

	function updateBurnAmountToBumpLevel(uint256 _burnAmountToBumpLevel) external onlyOwner
	{
		burnAmountToBumpLevel = _burnAmountToBumpLevel;
	}

	function updateMinimumBalanceForRewards(uint256 _minimumBalanceForRewards, bool _forceUpdateAll) external onlyOwner
	{
		require(_minimumBalanceForRewards > 0, "invalid amount");
		minimumBalanceForRewards = _minimumBalanceForRewards;
		if (_forceUpdateAll) {
			// this is a costly operation not designed to be used regularly, should be avoided
			_updateEpoch();
			for (uint256 _i = 0; _i < accountIndex.length; _i++) {
				address _account = accountIndex[_i];
				_updateAccount(_account);
				_postUpdateAccount(_account, 0);
			}
		}
	}

	function updateNextRebaseRatePerEpoch(uint256 _nextRebaseRatePerEpoch) external onlyOwner
	{
		_updateEpoch();
		nextRebaseRatePerEpoch = _nextRebaseRatePerEpoch;
	}

	function updateExcludeFromTransferPenalty(address[] memory _accounts, bool _enabledAsSender, bool _enabledAsReceiver) external onlyOwner
	{
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			require(_account != address(this), "invalid address");
			excludeFromTransferPenaltyAsSender[_account] = _enabledAsSender;
			excludeFromTransferPenaltyAsReceiver[_account] = _enabledAsReceiver;
		}
	}

	function updateExcludeFromTradeFee(address[] memory _accounts, bool _enabledAsBuyer, bool _enabledAsSeller) external onlyOwner
	{
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			require(_account != address(this), "invalid address");
			excludeFromTradeFeeAsBuyer[_account] = _enabledAsBuyer;
			excludeFromTradeFeeAsSeller[_account] = _enabledAsSeller;
		}
	}

	function updateExcludeFromRewardsDefaultBehavior(address[] memory _accounts, bool _enabled) external onlyOwner
	{
		_updateEpoch();
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			require(_account != address(this), "invalid address");
			_updateAccount(_account);
			excludeFromRewardsDefaultBehavior[_account] = _enabled;
			_postUpdateAccount(_account, 0);
		}
	}

	function claimAllForPair() external onlyOwner returns (uint256[] memory _amounts)
	{
		return _claimAll(pair, msg.sender);
	}

	function activeBalanceOf(address _account) public view returns (uint256 _activeBalance)
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		return _accountInfo.activeBalance;
	}

	function levelOf(address _account) public view returns (uint256 _level)
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		return _accountInfo.exists ? _accountInfo.level : 1;
	}

	function stakeOf(address _account) public view returns (uint256 _stake)
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		uint256 _shares = _accountInfo.level * _accountInfo.activeBalance;
		return _shares * 1e18 / totalShares;
	}

	function computeTotalSupply() external returns (uint256 _totalSupply)
	{
		_updateEpoch();
		return totalSupply();
	}

	function computeTotalActiveSupply() external returns (uint256 _totalActiveSupply)
	{
		_updateEpoch();
		return totalActiveSupply;
	}

	function computeBalanceOf(address _account) external returns (uint256 _balance)
	{
		_updateEpoch();
		_updateAccount(_account);
		_postUpdateAccount(_account, 0);
		return balanceOf(_account);
	}

	function computeActiveBalanceOf(address _account) external returns (uint256 _activeBalance)
	{
		_updateEpoch();
		_updateAccount(_account);
		_postUpdateAccount(_account, 0);
		return activeBalanceOf(_account);
	}

	function computeLevelOf(address _account) external returns (uint256 _level)
	{
		_updateEpoch();
		_updateAccount(_account);
		_postUpdateAccount(_account, 0);
		return levelOf(_account);
	}

	function computeStakeOf(address _account) external returns (uint256 _stake)
	{
		_updateEpoch();
		_updateAccount(_account);
		_postUpdateAccount(_account, 0);
		return stakeOf(_account);
	}

	function bumpLevel() external
	{
		_updateEpoch();
		_updateAccount(msg.sender);
		{
			bypass_ = true;
			_burn(msg.sender, burnAmountToBumpLevel);
			bypass_ = false;
		}
		_postUpdateAccount(msg.sender, 1);
		emit BumpLevel(msg.sender);
	}

	function claimAll() external returns (uint256[] memory _amounts)
	{
		return _claimAll(msg.sender, msg.sender);
	}

	function _claimAll(address _account, address _receiver) internal returns (uint256[] memory _amounts)
	{
		_updateEpoch();
		_updateAccount(_account);
		_postUpdateAccount(msg.sender, 0);
		AccountInfo storage _accountInfo = accountInfo[_account];
		_amounts = new uint256[](rewardIndex.length);
		for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
			address _rewardToken = rewardIndex[_i];
			RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
			AccountRewardInfo storage _accountRewardInfo = _accountInfo.rewardInfo[_rewardToken];
			uint256 _amount = _accountRewardInfo.unclaimedReward;
			if (_amount > 0) {
				if (_amount > _rewardInfo.rewardBalance) { // check needed due to precision
					_amount = _rewardInfo.rewardBalance;
				}
				_accountRewardInfo.unclaimedReward = 0;
				_rewardInfo.rewardBalance -= _amount;
				_amounts[_i] = _amount;
			}
		}
		for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
			address _rewardToken = rewardIndex[_i];
			uint256 _amount = _amounts[_i];
			if (_amount > 0) {
				IERC20(_rewardToken).safeTransfer(_receiver, _amount);
			}
			emit Claim(_account, _rewardToken, _amount);
		}
		return _amounts;
	}

	function _updateEpoch() internal
	{
		uint256 _lastEpoch = epoch();

		if (_lastEpoch <= lastEpoch) return;

		uint256 _lastWeek = week();

		uint256 _totalActiveSupply = totalActiveSupply;

		// compute epoch changes along with week changes
		while (_lastWeek > lastWeek) {
			uint256 _nextWeek = lastWeek + WEEK_DURATION;
			uint256 _epochs = (_nextWeek - lastEpoch) / EPOCH_DURATION;
			{
				// perform rebases
				uint256 _rate = _cachedExp(100e16 + rebaseRatePerEpoch[weekIndex], _epochs);
				totalActiveSupply = totalActiveSupply * _rate / 100e16;
				totalShares = totalShares * _rate / 100e16;
				for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
					address _rewardToken = rewardIndex[_i];
					RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
					_rewardInfo.accRewardPerShare[weekIndex] = _rewardInfo.accRewardPerShare[weekIndex] * 100e16 / _rate;
				}
			}
			lastEpoch = _nextWeek;
			epochIndex += _epochs;
			lastWeek = _nextWeek;
			weekIndex++;
			rebaseRatePerEpoch[weekIndex] = nextRebaseRatePerEpoch;
			{
				// accounts for level increments
				// sum((level_i + 1) * balance_i) = sum(level_i * balance_i) + sum(balance_i)
				totalShares += totalActiveSupply;
			}
		}

		// compute epoch changes within the last week
		if (_lastEpoch > lastEpoch) {
			uint256 _epochs = (_lastEpoch - lastEpoch) / EPOCH_DURATION;
			{
				// perform rebases
				uint256 _rate = _cachedExp(100e16 + rebaseRatePerEpoch[weekIndex], _epochs);
				totalActiveSupply = totalActiveSupply * _rate / 100e16;
				totalShares = totalShares * _rate / 100e16;
				for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
					address _rewardToken = rewardIndex[_i];
					RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
					_rewardInfo.accRewardPerShare[weekIndex] = _rewardInfo.accRewardPerShare[weekIndex] * 100e16 / _rate;
				}
			}
			lastEpoch = _lastEpoch;
			epochIndex += _epochs;
		}

		// distribute new rewards
		if (totalShares > 0) {
			for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
				address _rewardToken = rewardIndex[_i];
				RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
				uint256 _rewardBalance = IERC20(_rewardToken).balanceOf(address(this));
				uint256 _rewardAmount = _rewardBalance - _rewardInfo.rewardBalance;
				if (_rewardAmount > 0) {
					_rewardInfo.rewardBalance = _rewardBalance;
					_rewardInfo.accRewardPerShare[weekIndex] += _rewardAmount * 1e18 / totalShares;
				}
			}
		}

		// allocate new supply
		uint256 _newSupply = totalActiveSupply - _totalActiveSupply;
		if (_newSupply > 0) {
			bypass_ = true;
			_mint(INTERNAL_ADDRESS, _newSupply);
			bypass_ = false;
		}
	}

	function _updateAccount(address _account) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];

		if (lastEpoch <= _accountInfo.lastEpoch) return;

		if (!_accountInfo.exists) {
			accountIndex.push(_account);
			_accountInfo.exists = true;
			_accountInfo.lastWeek = lastWeek;
			_accountInfo.weekIndex = weekIndex;
			_accountInfo.lastEpoch = lastEpoch;
			_accountInfo.epochIndex = epochIndex;
			_accountInfo.level = 1;
			_accountInfo.activeBalance = 0;
			return;
		}

		uint256 _activeBalance = _accountInfo.activeBalance;

		if (_activeBalance == 0) {
			// optimized for non active accounts
			uint256 _weeks = (lastWeek - _accountInfo.lastWeek) / WEEK_DURATION;
			uint256 _epochs = (lastEpoch - _accountInfo.lastEpoch) / EPOCH_DURATION;
			_accountInfo.lastWeek = lastWeek;
			_accountInfo.weekIndex += _weeks;
			_accountInfo.lastEpoch = lastEpoch;
			_accountInfo.epochIndex += _epochs;
			return;
		}

		// compute epoch changes along with week changes
		while (lastWeek > _accountInfo.lastWeek) {
			uint256 _nextWeek = _accountInfo.lastWeek + WEEK_DURATION;
			uint256 _epochs = (_nextWeek - _accountInfo.lastEpoch) / EPOCH_DURATION;
			{
				// perform rebases
				uint256 _rate = _cachedExp(100e16 + rebaseRatePerEpoch[_accountInfo.weekIndex], _epochs);
				_accountInfo.activeBalance = _accountInfo.activeBalance * _rate / 100e16;
				for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
					address _rewardToken = rewardIndex[_i];
					RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
					AccountRewardInfo storage _accountRewardInfo = _accountInfo.rewardInfo[_rewardToken];
					uint256 _shares = _accountInfo.level * _accountInfo.activeBalance;
					uint256 _rewardDebt = _shares * _rewardInfo.accRewardPerShare[_accountInfo.weekIndex] / 1e18;
					if (_rewardDebt < _accountRewardInfo.rewardDebt) { // check needed due to precision
						_rewardDebt = _accountRewardInfo.rewardDebt;
					}
					uint256 _rewardAmount = _rewardDebt - _accountRewardInfo.rewardDebt;
					_accountRewardInfo.unclaimedReward += _rewardAmount;
					_accountRewardInfo.rewardDebt = 0; // for the next week
				}
			}
			_accountInfo.lastEpoch = _nextWeek;
			_accountInfo.epochIndex += _epochs;
			_accountInfo.lastWeek = _nextWeek;
			_accountInfo.weekIndex++;
			{
				// accounts for level increments
				_accountInfo.level++;
			}
		}

		// compute epoch changes within the last week
		if (lastEpoch > _accountInfo.lastEpoch) {
			uint256 _epochs = (lastEpoch - _accountInfo.lastEpoch) / EPOCH_DURATION;
			{
				// perform rebases
				uint256 _rate = _cachedExp(100e16 + rebaseRatePerEpoch[_accountInfo.weekIndex], _epochs);
				_accountInfo.activeBalance = _accountInfo.activeBalance * _rate / 100e16;
			}
			_accountInfo.lastEpoch = lastEpoch;
			_accountInfo.epochIndex += _epochs;
		}

		// collect rewards
		for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
			address _rewardToken = rewardIndex[_i];
			RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
			AccountRewardInfo storage _accountRewardInfo = _accountInfo.rewardInfo[_rewardToken];
			uint256 _shares = _accountInfo.level * _accountInfo.activeBalance;
			uint256 _rewardDebt = _shares * _rewardInfo.accRewardPerShare[_accountInfo.weekIndex] / 1e18;
			if (_rewardDebt < _accountRewardInfo.rewardDebt) { // check needed due to precision
				_rewardDebt = _accountRewardInfo.rewardDebt;
			}
			uint256 _rewardAmount = _rewardDebt - _accountRewardInfo.rewardDebt;
			_accountRewardInfo.unclaimedReward += _rewardAmount;
			_accountRewardInfo.rewardDebt = _rewardDebt;
		}

		// transfer new balance
		uint256 _newBalance = _accountInfo.activeBalance - _activeBalance;
		if (_newBalance > 0) {
			uint256 _balance = balanceOf(INTERNAL_ADDRESS);
			if (_newBalance > _balance) { // check needed due to precision loss
				uint256 _excess = _newBalance - _balance;
				_accountInfo.activeBalance -= _excess;
				_newBalance = _balance;
			}
			bypass_ = true;
			_transfer(INTERNAL_ADDRESS, _account, _newBalance);
			bypass_ = false;
			if (_account == pair) {
				// syncs pool reserves with balances if possible
				try IUniswapV2Pair(pair).sync() {} catch {}
			}
		}
	}

	function _postUpdateAccount(address _account, int256 _levelBump) internal
	{
		// adjusts active supply/balance, level and share according to rules
		AccountInfo storage _accountInfo = accountInfo[_account];
		uint256 _balance = balanceOf(_account);
		bool _excludeFromRewards = _account.isContract() != excludeFromRewardsDefaultBehavior[_account];
		uint256 _oldActiveBalance = _accountInfo.activeBalance;
		uint256 _oldLevel = _accountInfo.level;
		uint256 _oldShares = _oldLevel * _oldActiveBalance;
		uint256 _newActiveBalance = _excludeFromRewards || _balance < minimumBalanceForRewards ? 0 : _balance;
		uint256 _newLevel = _levelBump >= 0 ? _oldLevel + uint256(_levelBump) : uint256(-_levelBump) >= _oldLevel ? 1 : _oldLevel - uint256(-_levelBump);
		uint256 _newShares = _newLevel * _newActiveBalance;
		_accountInfo.activeBalance = _newActiveBalance;
		_accountInfo.level = _newLevel;
		if (_newActiveBalance != _oldActiveBalance) {
			totalActiveSupply -= _oldActiveBalance;
			totalActiveSupply += _newActiveBalance;
		}
		if (_newShares != _oldShares) {
			totalShares -= _oldShares;
			totalShares += _newShares;
			for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
				address _rewardToken = rewardIndex[_i];
				RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
				AccountRewardInfo storage _accountRewardInfo = _accountInfo.rewardInfo[_rewardToken];
				_accountRewardInfo.rewardDebt = _newShares * _rewardInfo.accRewardPerShare[weekIndex] / 1e18;
			}
		}
	}

	function _transfer(address _from, address _to, uint256 _amount) internal override
	{
		if (bypass_) {
			// internal transfer
			super._transfer(_from, _to, _amount);
			return;
		}

		if (inswap_) {
			// sell fee transfer
			super._transfer(_from, _to, _amount);
			return;
		}

		if (_from == pair) {
			// buying
			uint256 _feeAmount = excludeFromTradeFeeAsBuyer[_to] ? 0 : _amount * buyFee / 100e16;
			if (_feeAmount > 0) {
				super._transfer(_from, _to, _amount - _feeAmount);
				super._transfer(_from, address(this), _feeAmount);
			} else {
				super._transfer(_from, _to, _amount);
			}
			return;
		}

		if (_to == pair) {
			// selling
			uint256 _feeAmount = excludeFromTradeFeeAsSeller[_from] ? 0 : _amount * sellFee / 100e16;
			if (_feeAmount > 0) {
				super._transfer(_from, _to, _amount - _feeAmount);
				super._transfer(_from, address(this), _feeAmount);
			} else {
				super._transfer(_from, _to, _amount);
			}
			return;
		}

		// regular transfer
		super._transfer(_from, _to, _amount);

		{
			// piggyback operation
			// converts fees to BNB and injects as LVLX/BNB liquidity
			_updateAccount(address(this));
			_postUpdateAccount(address(this), 0);
			uint256 _balance = balanceOf(address(this));
			if (_balance >= minimumFeeBalanceToSwap) {
				inswap_ = true;
				uint256 _halfFeeLiquidityCut = feeLiquidityCut / 2;
				uint256 _swapAmount = _balance * (100e16 - _halfFeeLiquidityCut) / 100e16;
				uint256 _bnbAmount = _swapToBNB(_swapAmount);
				_injectWithBNB(_balance - _swapAmount, _bnbAmount * _halfFeeLiquidityCut / 100e16);
				inswap_ = false;
				return;
			}
		}

		{
			// piggyback operation
			// converts BNB to reward tokens, evenly
			uint256 _bnbAmount = address(this).balance;
			if (_bnbAmount > minimumRewardBalanceToSwap) {
				inswap_ = true;
				uint256 _bnbAmountSplit = _bnbAmount / rewardIndex.length;
				for (uint256 _i = 0; _i < rewardIndex.length; _i++) {
					address _rewardToken = rewardIndex[_i];
					_swapBNBToReward(_rewardToken, _bnbAmountSplit);
				}
				inswap_ = false;
				return;
			}
		}
	}

	function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override
	{
		if (bypass_) return;
		_updateEpoch();
		if (_from != address(0)) {
			_updateAccount(_from);
		}
		if (_to != address(0)) {
			// internal address should never be used
			require(_to != INTERNAL_ADDRESS, "invalid address");
			_updateAccount(_to);
		}
		_amount; // silences warning
	}

	function _afterTokenTransfer(address _from, address _to, uint256 _amount) internal override
	{
		if (bypass_) return;
		if (_amount == 0) return;
		if (_from == _to) return;
		if (_from != address(0)) {
			_postUpdateAccount(_from, excludeFromTransferPenaltyAsSender[_from] || excludeFromTransferPenaltyAsReceiver[_to] ? int256(0) : -1);
		}
		if (_to != address(0)) {
			_postUpdateAccount(_to, 0);
		}
	}

	function _cachedExp(uint256 _x, uint256 _n) internal returns (uint256 _y)
	{
		_y = expCache[_x][_n];
		if (_y == 0) {
			_y = _exp(_x, _n);
			expCache[_x][_n] = _y;
		}
		return _y;
	}

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

	function _swapToBNB(uint256 _amount) internal returns (uint256 _bnbAmount)
	{
		// swaps LVLX to BNB
		uint256 _balance = address(this).balance;
		IUniswapV2Router(router).swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, pathWBNB, address(this), block.timestamp);
		return address(this).balance - _balance;
	}

	function _injectWithBNB(uint256 _amount, uint256 _bnbAmount) internal
	{
		// injects LVLX/BNB into the pool
		IUniswapV2Router(router).addLiquidityETH{value: _bnbAmount}(address(this), _amount, 0, 0, liquidityRecipient, block.timestamp);
	}

	function _swapBNBToReward(address _rewardToken, uint256 _bnbAmount) internal
	{
		// swaps BNB to reward
		// half is reflected, half is sent to bankroll
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		uint256 _balance = IERC20(_rewardToken).balanceOf(address(this));
		IUniswapV2Router(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _bnbAmount}(0, _rewardInfo.path, address(this), block.timestamp);
		uint256 _rewardAmount = IERC20(_rewardToken).balanceOf(address(this)) - _balance;
		IERC20(_rewardToken).safeTransfer(_rewardInfo.bankroll, _rewardAmount / 2);
	}

	receive() external payable {}

	event BumpLevel(address indexed _account);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
}