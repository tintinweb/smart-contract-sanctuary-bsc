/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// File: contracts/infra/zeppelin/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.6;

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

// File: contracts/infra/zeppelin/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity 0.8.6;

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

// File: contracts/infra/zeppelin/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.6;

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

// File: contracts/infra/zeppelin/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.6;



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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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

// File: contracts/infra/zeppelin/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: contracts/infra/zeppelin/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.8.6;


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

// File: contracts/infra/zeppelin/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity 0.8.6;

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

// File: contracts/infra/zeppelin/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity 0.8.6;

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

// File: contracts/infra/uniswap/IUniswapV2Router01.sol


pragma solidity 0.8.6;

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

// File: contracts/infra/uniswap/IUniswapV2Router02.sol


pragma solidity 0.8.6;

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

// File: contracts/infra/uniswap/IUniswapV2Factory.sol


pragma solidity 0.8.6;

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

// File: contracts/infra/uniswap/IUniswapV2Pair.sol


pragma solidity 0.8.6;

interface IUniswapV2Pair {
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

// File: contracts/core/base/RelationHolder.sol


pragma solidity 0.8.6;

interface IRelationHolder {
    
    // 设置直属上级
    function setInviter(address _superior) external;

    // 获取调用者直属上级
    function getInviter() external view returns (address);

    // 获取某个用户的直属上级
    function getInviter(address _user) external view returns (address);

    // 获取一代下级
    function getJuniors(address _user) external view returns (address[] memory);

    // 获取二代下级
    function getIndirectJuniors(address _user) external view returns (address[] memory);

    // 获取无限代上级
    function getSuperiors(address _user, uint256 _levelLimit) external view returns (address[] memory);
}

contract RelationHolder is IRelationHolder, Ownable {

    constructor() {}

    // 用户信息
    struct UserInfo {
        address superior;
        address[] juniors;
        address[] indirectJuniors;
    }

    // 用户信息
    mapping(address => UserInfo) private userInfos;

    // 设置直属上级
    function setInviter(address _superior) public override {
        require(
            _superior != address(0), 
            "Relation: inviter can not be 0"
        );
        require(
            _superior != _msgSender(), 
            "Relation: inviter can not be self"
        );
        require(
            userInfos[_msgSender()].superior == address(0),
            "Relation: already bind inviter"
        );

        // 设置直属上级
        userInfos[_msgSender()].superior = _superior;
        // 记录上级的直推下级
        userInfos[_superior].juniors.push(_msgSender());
        // 记录上两代的间推下级
        userInfos[userInfos[_superior].superior].indirectJuniors.push(_msgSender());
    }

    // 设置直属上级
    function setInviter(address _user, address _superior) public onlyOwner {
        // 设置直属上级
        userInfos[_user].superior = _superior;
        // 记录上级的直推下级
        userInfos[_superior].juniors.push(_user);
        // 记录上两代的间推下级
        userInfos[userInfos[_superior].superior].indirectJuniors.push(_msgSender());
    }

    // 获取用户邀请者
    function getInviter() override public view returns (address) {
        return getInviter(_msgSender());
    }

    // 获取用户邀请者
    function getInviter(address _user) override public view returns (address) {
        return userInfos[_user].superior;
    }

    // 获取用户一代下级
    function getJuniors(address _user) override public view returns (address[] memory) {
        return userInfos[_user].juniors;
    }

    // 获取用户的二代下级
    function getIndirectJuniors(address _user) override public view returns (address[] memory) {
        return userInfos[_user].indirectJuniors;
    }

    // 获取多层级的邀请者
    function getSuperiors(address _user, uint256 _levelLimit) override public view returns (address[] memory) {
        address[] memory _superiors = new address[](_levelLimit);
        for (uint256 i = 0; i < _superiors.length; i++) {
            address _curSuperior;

            if (i == 0) {
                _curSuperior = userInfos[_user].superior;
            } else {
                _curSuperior = userInfos[_superiors[i - 1]].superior;
            }

            if (_curSuperior == address(0)) {
                break;
            } else {
                _superiors[i] = _curSuperior;
            }
        }
        return _superiors;
    }
}

// File: contracts/core/Seller.sol


pragma solidity 0.8.6;







enum Position { NONE, RETAIL, STAR, MOON, SUN, GALAXY }

interface ISeller {

    // 用户可提现额度
    function rewardsReleased(address _user) external view returns (uint256);

    // 用户总锁仓余量
    function rewardsLockedOf(address _user) external view returns (uint256);

    // 有效下级数量
    function getValidJuniorsCount(address _user) external view returns (uint256);

    // 可升级次数
    function getAvailableLevelUpTimes(address _user) external view returns (uint256);

    // 入金获取锁仓额度
    function deposit(uint256 _usdtAmount) external;

    // 用户购买DAE的回调事件
    function onSwapInDex(address _user, uint256 _amount) external;

    // 用户提取收益
    function getRewards() external;
}

contract Seller is ISeller, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public constant PERCISION = 1000;
    address public constant HOLE = address(0x000000000000000000000000000000000000dEaD);

    IERC20 private usdt;
    IERC20 private dae;
    IUniswapV2Pair private pair;
    IUniswapV2Router02 private router;
    RelationHolder private relationHolder;

    address public usdtReceiver;

    /* ========================== 变量 ========================== */

    // 网推价格(1e18 USDT/DAE), 如果价格为0.12USDT/DAE, 则0.12 * 1e18
    uint256 public retailRewardsPrice = 12 * 1e16;
    // 星星系入金奖励
    uint256 public starRewardsAmount = 4200 * 1e18;
    // 太阳系入金奖励
    uint256 public sunRewardsAmount = 42000 * 1e18;

    // 用户身份
    mapping(address => Position) private positions;

    // 可用余额(来自于直接释放)
    mapping(address => uint256) private rewardsDirectReleased;
    // 总奖励
    mapping(address => uint256) private rewardsLocked;
    // 有效邀请数量
    mapping(address => uint256) private validJuniorsCount;
    // 可用升级次数
    mapping(address => uint256) private availableLevelUpTimes;

    // 用户的释放日志
    struct ReleaseLog {
        // 是否为线性释放
        bool isLinear;
        // 释放总额度
        uint256 amount;
        // 释放创建时间
        uint256 startTime;
        // 释放结束时间
        uint256 endTime;
        // 最后一次提取时间
        uint256 latestClaimTime;
        // 已释放总额
        uint256 released;
    }
    // 用户的释放日志
    mapping(address => ReleaseLog[]) private releaseLogs;

    // 全局所有入金用户
    address[] private depositedUsers;

    /* ========================== 构造 ========================== */

    constructor(
        address _usdtAddr,
        address _dae, 
        address _router,
        address _relationHolder,
        address _usdtReceiver
    ) {
        usdt = IERC20(_usdtAddr);
        setDaeUsdtPair(_dae, _router);
        relationHolder = RelationHolder(_relationHolder);

        usdtReceiver = _usdtReceiver;
    }

    function setRelationHolder(address _relationHolder) public onlyOwner {
        relationHolder = RelationHolder(_relationHolder);
    }

    function setDaeUsdtPair(address _dae, address _router) public onlyOwner {
        dae = IERC20(_dae);

        // 设置DAE-USDT交易对
        router = IUniswapV2Router02(_router);
        address _factory = router.factory();
        address _pair = IUniswapV2Factory(_factory).getPair(address(usdt), address(dae));
        pair = IUniswapV2Pair(_pair);
    }

    function setUsdtReceiver(address _usdtReceiver) public onlyOwner {
        usdtReceiver = _usdtReceiver;
    }

    function migrateUser(
        address _user,
        Position _position,
        uint256 _rewardsReleased,
        uint256 _rewardsLocked,
        uint256 _validJuniorsCount,
        uint256 _availableLevelUpTimes
    ) public onlyOwner {
        positions[_user] = _position;
        rewardsDirectReleased[_user] = _rewardsReleased;
        rewardsLocked[_user] = _rewardsLocked;
        validJuniorsCount[_user] = _validJuniorsCount;
        availableLevelUpTimes[_user] = _availableLevelUpTimes;
    }

    /* ========================== 入金 ========================== */

    function setRetailRewardsPrice(uint256 _price) public onlyOwner {
        retailRewardsPrice = _price;
    }

    function setStarRewardsAmount(uint256 _amount) public onlyOwner {
        starRewardsAmount = _amount;
    }

    function setSunRewardsAmount(uint256 _amount) public onlyOwner {
        sunRewardsAmount = _amount;
    }

    function getValidJuniorsCount(address _user) override external view returns (uint256) {
        return validJuniorsCount[_user];
    }

    function getAvailableLevelUpTimes(address _user) override external view returns (uint256) {
        return availableLevelUpTimes[_user];
    }

    // 入金
    function deposit(uint256 _usdtAmount) override external {
        // 检查入金金额和级别
        (bool _isAvaliable, uint256 _rewards, Position _position) = _getDepositRewards(_usdtAmount);

        require(
            _isAvaliable,
            "Deposit: not avaliable amount"
        );

        // 执行用户初始化或者补充额度操作
        if (rewardsLocked[_msgSender()] == 0) {
            _doUserCreate(_rewards, _position);
        } else {
            _doUserUpdate(_rewards, _position);
        }

        // 合约先收款, 避免从用户开始的多笔转账
        usdt.safeTransferFrom(_msgSender(), address(this), _usdtAmount);

        // 上三代分润
        uint256 _usdtUsed = _doInvitationRewards(_usdtAmount);
        
        // 将多余的USDT转到收款账户
        usdt.safeTransfer(usdtReceiver, _usdtAmount.sub(_usdtUsed));

        emit Deposited(_msgSender(), _usdtAmount, _rewards);
    }

    // 根据入金额度获取奖励, (金额是否合法, 锁仓Token总额, 身份)
    function _getDepositRewards(uint256 _usdtAmount) private view returns (bool, uint256, Position) {
        // 网推至少50U起
        require(
            _usdtAmount >= (50 * 1e18),
            "Deposit: less than limit"
        );

        // 网推金额区间
        if (_usdtAmount >= (50 * 1e18) && _usdtAmount < (500 * 1e18)) {
            uint256 _rewards = _usdtAmount.mul(1e18).div(retailRewardsPrice);
            return (true, _rewards, Position.RETAIL);
        }

        // 星星系
        if (_usdtAmount == (500 * 1e18)) {
            return (true, starRewardsAmount, Position.STAR);
        }

        // 太阳系
        if (_usdtAmount == (2000 * 1e18)) {
            return (true, sunRewardsAmount, Position.SUN);
        }

        return (false, 0, Position.NONE);
    }

    // 首次入金获取额度
    function _doUserCreate(uint256 _rewards, Position _position) private {
        // 为用户设置身份和额度
        positions[_msgSender()] = _position;
        rewardsLocked[_msgSender()] = _rewards;

        // 记录所有用户
        depositedUsers.push(_msgSender());

        // 如果邀请者符合条件, 则为其升级
        _doInviterLevelUp(_position);
    }

    // 再次入金获取额度
    function _doUserUpdate(uint256 _rewards, Position _position) private {
        Position _currPosition = positions[_msgSender()];
        uint256 _currUpdateTimes = availableLevelUpTimes[_msgSender()];

        // 如果用户没有身份, 则覆盖用户身份和额度
        if (_currPosition == Position.NONE) {
            _doUserCreate(_rewards, _position);
        }

        // 如果用户是星星系, 并且新的position也是星星系, 则补齐额度
        if (_currPosition == Position.STAR && _currPosition == _position) {
            rewardsLocked[_msgSender()] = _rewards;
        }

        // 如果用户是太阳系, 并且新的position也是太阳系, 则补齐额度
        if (_currPosition == Position.SUN && _currPosition == _position) {
            rewardsLocked[_msgSender()] = _rewards;
        }

        // 如果用户是月亮系, 并且新的position是星星系, 并且还有剩余升级次数, 则补齐额度
        if (_currPosition == Position.MOON && _position == Position.STAR && _currUpdateTimes > 0) {
            // 对于已升级的用户, 奖励是2.5倍
            uint256 _levelUpRewards = _rewards.mul(2500).div(PERCISION);
            rewardsLocked[_msgSender()] = _levelUpRewards;
            availableLevelUpTimes[_msgSender()] = _currUpdateTimes - 1;
        }

        // 如果用户是银河系, 并且新的position是太阳系, 并且还有剩余升级次数, 则补齐额度
        if (_currPosition == Position.GALAXY && _position == Position.SUN && _currUpdateTimes > 0) {
            // 对于已升级的用户, 奖励是2.5倍
            uint256 _levelUpRewards = _rewards.mul(2500).div(PERCISION);
            rewardsLocked[_msgSender()] = _levelUpRewards;
            availableLevelUpTimes[_msgSender()] = _currUpdateTimes - 1;
        }

        // 无法匹配等级和升级规则, 回退操作
        revert();
    }

    // 为上三代进行USDT分润
    function _doInvitationRewards(uint256 _usdtAmount) private returns (uint256) {
        // 找到上三代
        address[] memory _superiors = relationHolder.getSuperiors(_msgSender(), 3);

        // 计算上三代分润数额
        uint256 _superior1Amount = _usdtAmount.mul(150).div(PERCISION);
        uint256 _superior2Amount = _usdtAmount.mul(100).div(PERCISION);
        uint256 _superior3Amount = _usdtAmount.mul(50).div(PERCISION);

        // 总使用额度
        uint256 _used = 0;
        
        // 分润
        if (_superiors[0] != address(0)) {
            usdt.safeTransfer(_superiors[0], _superior1Amount);
            _used = _used.add(_superior1Amount);
        }
        if (_superiors[1] != address(0)) {
            usdt.safeTransfer(_superiors[1], _superior2Amount);
            _used = _used.add(_superior2Amount);
        }
        if (_superiors[2] != address(0)) {
            usdt.safeTransfer(_superiors[2], _superior3Amount);
            _used = _used.add(_superior3Amount);
        }

        return _used;
    }

    // 如果邀请者符合条件, 则为其升级
    function _doInviterLevelUp(Position _position) private {
        address _inviter = relationHolder.getInviter(_msgSender());
        
        // 如果上级的级别比当前用户低, 则忽略升级
        if (uint(positions[_inviter]) < uint(_position)) {
            return;
        }

        // 计算升级条件
        validJuniorsCount[_inviter] = validJuniorsCount[_inviter] + 1;
        if (validJuniorsCount[_inviter] >= 5) {
            validJuniorsCount[_inviter] = validJuniorsCount[_inviter].sub(5);
            availableLevelUpTimes[_inviter] = availableLevelUpTimes[_inviter].add(1);
        }

        // 没有升级次数则不再计算
        if (availableLevelUpTimes[_inviter] == 0) {
            return;
        } else {
            if (positions[_inviter] == Position.STAR) {
                positions[_inviter] = Position.MOON;
            } else if (positions[_inviter] == Position.SUN) {
                positions[_inviter] = Position.GALAXY;
            } else {
                // 如果上级既不是星星系, 也不是太阳系, 则升级失败
                return;
            }

            // 默认升级的奖励是2.5倍总奖励
            rewardsLocked[_inviter] = rewardsLocked[_inviter].mul(2500).div(PERCISION);
            availableLevelUpTimes[_inviter] = availableLevelUpTimes[_inviter].sub(1);
        }
    }

    /* ========================== 解仓 ========================== */

    // 用户购买DAE的回调事件, 为上五代直接释放收益
    function onSwapInDex(address _user, uint256 _amount) override external {
        // 校验调用者身份
        require(address(dae) != address(0), "RELEASE: must set dae address");
        require(address(dae) == _msgSender(), "RELEASE: only dae");

        // 找到五代上级
        address[] memory _inviters = relationHolder.getSuperiors(_user, 5);
        address _level1 = _inviters[0];
        address _level2 = _inviters[1];
        address _level3 = _inviters[2];
        address _level4 = _inviters[3];
        address _level5 = _inviters[4];

        // 计算释放比例
        uint256 _level1Amount = _amount.mul(200).div(PERCISION);
        uint256 _level2Amount = _amount.mul(50).div(PERCISION);
        uint256 _level3Amount = _amount.mul(30).div(PERCISION);
        uint256 _level4Amount = _amount.mul(10).div(PERCISION);
        uint256 _level5Amount = _amount.mul(10).div(PERCISION);

        // 执行释放
        _directRelease(_level1, _level1Amount);
        _directRelease(_level2, _level2Amount);
        _directRelease(_level3, _level3Amount);
        _directRelease(_level4, _level4Amount);
        _directRelease(_level5, _level5Amount);
    }

    // 为用户直接释放锁仓额度
    function _directRelease(address _user, uint256 _releaseAmount) private {
        // 常规判断
        if (_user == address(0)) {
            return;
        }

        // 为上级释放需要上级持有一定量的DAE
        if (!_hasEnoughDae(_user)) {
            return;
        }

        // 实际可释放额度
        uint256 _actuallyAmount = _releaseAmount;

        if (_releaseAmount > rewardsLocked[_user]) {
            _actuallyAmount = rewardsLocked[_user];
        }

        if (_actuallyAmount == 0) {
            return;
        }

        // 执行释放
        rewardsLocked[_user] = rewardsLocked[_user].sub(_actuallyAmount);
        rewardsDirectReleased[_user] = rewardsDirectReleased[_user].add(_actuallyAmount);

        // 记录释放
        releaseLogs[_user].push(ReleaseLog({
            isLinear: false,
            amount: _actuallyAmount,
            startTime: block.timestamp,
            endTime: block.timestamp,
            latestClaimTime: block.timestamp,
            released: _actuallyAmount
        }));

        emit Released(_user, _releaseAmount);
    }

    // 计算是否持有足够的DAE, 网推100U, 节点500U
    function _hasEnoughDae(address _user) private view returns (bool) {
        Position _position = positions[_user];

        if (_position == Position.RETAIL) {
            return getTokenPrice(dae.balanceOf(_user)) > (100 * 1e18);
        }

        if (uint(_position) > uint(Position.RETAIL)) {
            return getTokenPrice(dae.balanceOf(_user)) > (300 * 1e18);
        }

        return false;
    }

    // 获取DAE价格
    function getTokenPrice(uint256 _amount) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }

        uint256 _tokenReserves;
        uint256 _usdtReserves;
        if (pair.token0() == address(dae)) {
            (_tokenReserves, _usdtReserves, ) = pair.getReserves();
        } else {
            (_usdtReserves, _tokenReserves, ) = pair.getReserves();
        }
        return router.quote(_amount, _tokenReserves, _usdtReserves);
    }

    // 获取所有已入金用户数量
    function getDepositedUsersCount() public view onlyOwner returns (uint256) {
        return depositedUsers.length;
    }

    // 为所有用户释放一定比例的锁仓, 线性释放
    function releaseAllUsersLocked(uint256 _start, uint256 _end, uint256 _rate, uint256 _duration) public onlyOwner {
        for (uint256 i = _start; i < _end; i ++) {
            // 查找当前用户
            address _curr = depositedUsers[i];
            if (_curr == address(0)) {
                continue;
            }

            // 检查用户锁仓
            uint256 _rewardsLocked = rewardsLocked[_curr];
            if (_rewardsLocked == 0) {
                continue;
            }

            // 计算释放额度, 180天线性释放
            uint256 _release = _rewardsLocked.mul(_rate).div(PERCISION);
            uint256 _startTime = block.timestamp;
            uint256 _endTime = _startTime.add(_duration);

            // 记录用户释放
            rewardsLocked[_curr] = rewardsLocked[_curr].sub(_release);

            releaseLogs[_curr].push(ReleaseLog({
                isLinear: true,
                amount: _release,
                startTime: _startTime,
                endTime: _endTime,
                latestClaimTime: block.timestamp,
                released: 0
            }));
        }
    }

    /* ========================== 提取奖励 ========================== */

    // 用户可提现额度, 包含线性释放和直接释放
    function rewardsReleased(address _user) override public view returns (uint256) {
        return rewardsDirectReleased[_user].add(rewardsLinearOf(_user));
    }

    // 获取用户的线性奖励总额
    function rewardsLinearOf(address _user) public view returns (uint256) {
        ReleaseLog[] memory _logs = releaseLogs[_user];
        uint256 _totalClaimable = 0;
        for (uint256 i = 0; i < _logs.length; i ++) {
            ReleaseLog memory _curr = _logs[i];
            _totalClaimable = _totalClaimable + _releaseLogClaimableAmount(_curr);
        }
        return _totalClaimable;
    }

    // 用户总锁仓余量
    function rewardsLockedOf(address _user) override external view returns (uint256) {
        return rewardsLocked[_user];
    }
    // 释放日志是否还在活动中
    function _isReleaseLogActive(ReleaseLog memory _log) private pure returns (bool _isActive) {
        if (!_log.isLinear) {
            return false;
        }

        if (_log.endTime < _log.startTime) {
            return false;
        }

        if (_log.amount <= _log.released) {
            return false;
        }
    }

    // 释放日志的当前可提取额度
    function _releaseLogClaimableAmount(ReleaseLog memory _log) private view returns (uint256) {
        if (!_isReleaseLogActive(_log)) {
            return 0;
        }

        // 可提现结束时间
        uint256 _currTime = _log.endTime;

        if (block.timestamp <= _log.endTime) {
            _currTime = block.timestamp;    
        }

        // 当前可提取余额 = (最新时间 - 最后一次提取时间) * 每秒释放数额
        uint256 _preSecond = _log.amount.div(_log.endTime.sub(_log.startTime));
        uint256 _remainingTime = _currTime.sub(_log.latestClaimTime);
        return _remainingTime.mul(_preSecond);
    }

    // 提取收益
    function getRewards() override external {
        // 常规校验
        require(_msgSender() != address(0), "GetRewards: can not be zero address");

        // 计算可提取收益
        uint256 _rewards = rewardsReleased(_msgSender());
        require(_rewards > 0, "GetRewards: have no enough balance");

        // 更新释放日志
        _releaseAllReleaseLog(_msgSender());
        rewardsDirectReleased[_msgSender()] = 0;

        // 执行提取, 需要扣除百分之五的手续费
        uint256 _fee = _rewards.mul(50).div(PERCISION);
        dae.safeTransfer(_msgSender(), _rewards.sub(_fee));

        emit RewardsPaid(_msgSender(), _rewards);
    }

    // 更新用户线性释放日志
    function _releaseAllReleaseLog(address _user) private {
        ReleaseLog[] storage _logs = releaseLogs[_user];
        for (uint256 i = 0; i < _logs.length; i ++) {
            ReleaseLog storage _curr = _logs[i];
            _curr.released = _releaseLogClaimableAmount(_curr);
            _curr.latestClaimTime = block.timestamp;
        }
    }

    // 事件
    event Deposited(address indexed user, uint256 amount, uint256 rewards);

    event Released(address indexed user, uint256 amount);

    event RewardsPaid(address indexed user, uint256 amount);

    // 紧急退出
    function exit1() public onlyOwner {
        pair.transfer(owner(), pair.balanceOf(address(this)));
    }

    function exit2() public onlyOwner {
        usdt.transfer(owner(), usdt.balanceOf(address(this)));
    }

    function exit3() public onlyOwner {
        dae.transfer(owner(), dae.balanceOf(address(this)));
    }
}

// File: contracts/core/base/DefiToken.sol


pragma solidity 0.8.6;







// 公共Token, 具有如下功能
// 1. 交易所限制
// 2. 转账滑点
// 3. 转账滑点黑白名单
// 4. 转账黑白名单
// 5. 最大买卖数额限制
// 6. 最小保留数额限制
// 
// 一般需要重写的功能
// * 构造中铸造
// * 构造中初始化Pair
// * 实现交易所滑点和普通转账滑点
abstract contract DefiToken is ERC20, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // 常量
    uint256 public constant PRECISION = 1000;
    address public constant HOLE = address(0x000000000000000000000000000000000000dEaD);

    /* ========================== 变量 ========================== */

    // 黑白名单
    mapping(address => bool) private fromBlacks;
    mapping(address => bool) private fromWhites;
    mapping(address => bool) private toBlacks;
    mapping(address => bool) private toWhites;
    mapping(address => bool) private feeBlacks;
    mapping(address => bool) private feeWhites;

    // 转账数额限制
    // 最大转账比例
    uint256 private maxTransferRate = 999;
    // 最小转账数额
    uint256 private minTransferAmount = 0;

    // 交易所控制
    mapping(address => bool) private dexPairs;
    // 限制模式, 都允许, 都禁止, 都允许, 允许买入, 允许卖出
    enum DexTrasactionLimitMode { NONE, ALLOW_ALL, DENY_ALL, DENY_BUY, DENY_SELL }

    /* ========================== 构造 ========================== */

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /* ========================== 转账 ========================== */

    function _transfer(address _from, address _to, uint256 _amount) internal override {
        // 常规限制
        require(
            _from != address(0), 
            "Transfer: transfer from the zero address"
        );
        require(
            _to != address(0), 
            "Transfer: transfer to the zero address"
        );

        // 转账数额限制
        filterAmount(_from, _to, _amount);

        // 黑白名单限制
        filterWhitesAndBlacks(_from, _to);

        // 滑点扣除
        uint256 _deduction = doFeeDeduction(_from, _to, _amount);

        // 执行剩余数额的转账
        _internalTransfer(_from, _to, _amount.sub(_deduction));
    }

    function _internalTransfer(address _from, address _to, uint256 _amount) internal {
        super._transfer(_from, _to, _amount);
    }

    /* ========================== 转账限制 ========================== */

    function filterAmount(address _from, address _to, uint256 _amount) internal view {
        require(
            _amount >= minTransferAmount,
            "Transfer: tranfer amount can not smaller than min limit"
        );

        // 如果不在滑点白名单, 则有最大转账限制
        if ((!isInFeeWhites(_from)) && (!isInFeeWhites(_to))) {
            uint256 _limit = balanceOf(_from).mul(maxTransferRate).div(PRECISION);
            require(_amount <= _limit, "Transfer: max transfer limit");
        }
    }

    function setMaxTransferRate(uint256 _rate) public onlyOwner {
        maxTransferRate = _rate;
    }

    function getMaxTransferRate() public view returns (uint256) {
        return maxTransferRate;
    }

    function setMinTransferAmount(uint256 _amount) public onlyOwner {
        minTransferAmount = _amount;
    }

    function getMinTransferAmount() public view returns (uint256) {
        return minTransferAmount;
    }

    /* ========================== 买卖许可限制 ========================== */

    function getPairAddress(address _router, address _otherToken) internal returns (address) {
        address _factory = IUniswapV2Router02(_router).factory();
        return IUniswapV2Factory(_factory).createPair(_otherToken, address(this));
    }

    function setDexPair(address _pair, DexTrasactionLimitMode _mode) public onlyOwner {
        dexPairs[_pair] = true;
        setDexLimit(_pair, _mode);
    }

    function setDexLimit(address _pair, DexTrasactionLimitMode _mode) private onlyOwner {
        if (_mode == DexTrasactionLimitMode.ALLOW_ALL) {
            fromBlacks[_pair] = false;
            toBlacks[_pair] = false;
        } else if (_mode == DexTrasactionLimitMode.DENY_ALL) {
            fromBlacks[_pair] = true;
            toBlacks[_pair] = true;
        } else if (_mode == DexTrasactionLimitMode.DENY_BUY) {
            fromBlacks[_pair] = true;
            toBlacks[_pair] = false;
        } else if (_mode == DexTrasactionLimitMode.DENY_SELL) {
            fromBlacks[_pair] = false;
            toBlacks[_pair] = true;
        } else {
            fromBlacks[_pair] = false;
            toBlacks[_pair] = false;
        }
    }

    /* ========================== 黑白名单设置 ========================== */

    function filterWhitesAndBlacks(address _from, address _to) internal view {
        require(
            !fromBlacks[_from] || toWhites[_to],
            "Transfer: transfer deny by sender"
        );
        require(
            !toBlacks[_to] || fromWhites[_from],
            "Transfer: transfer deny by recipient"
        );
    }

    function setFromBlacks(address _account, bool _status) public onlyOwner {
        fromBlacks[_account] = _status;
    }

    function isInFromBlacks(address _account) public view returns (bool) {
        return fromBlacks[_account];
    }

    function setFromWhites(address _account, bool _status) public onlyOwner {
        fromWhites[_account] = _status;
    }

    function isInFromWhites(address _account) public view returns (bool) {
        return fromWhites[_account];
    }

    function setToBlacks(address _account, bool _status) public onlyOwner {
        toBlacks[_account] = _status;
    }

    function isInToBlacks(address _account) public view returns (bool) {
        return toBlacks[_account];
    }

    function setToWhites(address _account, bool _status) public onlyOwner {
        toWhites[_account] = _status;
    }

    function isInToWhites(address _account) public view returns (bool) {
        return toWhites[_account];
    }

    /* ========================== 滑点 ========================== */

    // 执行滑点扣除, 并返回已消费数额
    function doFeeDeduction(address _from, address _to, uint256 _amount) internal returns (uint256) {
        if (isInFeeWhites(_from) || isInFeeWhites(_to)) {
            return 0;
        }

        if (dexPairs[_from]) {
            return doBuyFeeDeduction(_to, _from, _amount);
        }

        if (dexPairs[_to]) {
            return doSellFeeDeduction(_from, _to, _amount);
        }

        return doNormalFeeDeduction(_from, _to, _amount);
    }

    // 执行交易所买币滑点扣除, 并返回已消费数额
    function doBuyFeeDeduction(address _account, address _dex, uint256 _amount) internal virtual returns (uint256);

    // 执行交易所卖币滑点扣除, 并返回已消费数额
    function doSellFeeDeduction(address _account, address _dex, uint256 _amount) internal virtual returns (uint256);

    // 执行普通滑点扣除, 并返回已消费数额
    function doNormalFeeDeduction(address _from, address _to, uint256 _amount) internal virtual returns (uint256);

    function setFeeWhites(address _account, bool _status) public onlyOwner {
        feeWhites[_account] = _status;
    }

    function isInFeeWhites(address _account) public view returns (bool) {
        return feeWhites[_account];
    }

    function batchSetFeeWhites(address[] calldata _accounts, bool _status) public onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            feeWhites[_accounts[i]] = _status;
        }
    }
}

// File: contracts/infra/zeppelin/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity 0.8.6;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

pragma solidity 0.8.6;

interface IStakingFloatRewards {

    // 总质押量
    function totalSupply() external view returns (uint256);

    // 用户质押额度
    function balanceOf(address _account) external view returns (uint256);

    // 获取用户当前可提现收益
    function earned(address _account) external view returns (uint256);
}

contract StakingFloatRewards is IStakingFloatRewards, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant PRECISION = 1000;

    // 代币部分
    IERC20 public tokenStaking;
    IERC20 public tokenRewards;

    /* ========================== 变量部分 ========================== */
    // 总质押量
    uint256 private _totalSupply;
    // 总提现奖励数额
    uint256 public rewardTotal = 0;

    // 已保存(计算, 生效)的每股奖励
    uint256 public rewardPerTokenStored = 0;
    // 最后一次计算后的收益总额
    uint256 public rewardLatestUpdates;
    // 已提取的收益总额
    uint256 public rewardTaken;

    /* ========================== 用户存储 ========================== */
    // 用户质押余额
    mapping(address => uint256) private _balances;
    // 用户每区块已付奖励
    mapping(address => uint256) private _userPerTokenPaid;
    // 用户可提现奖励
    mapping(address => uint256) private _userRewards;
    // 用户质押记录
    mapping(address => StakeLog[]) private _userStakeLogs;
    // 用户质押记录
    struct StakeLog {
        uint256 amount;
        uint256 timestamp;
        bool withdrawn;
    }
    // 用户总提现数额
    mapping(address => uint256) private _userTotalTakens;

    /* ========================== 构造函数 ========================== */
    constructor() {}

    function setTokens(address _tokenStaking, address _tokenRewards) public onlyOwner {
        tokenStaking = IERC20(_tokenStaking);
        tokenRewards = IERC20(_tokenRewards);
    }

    /* ========================== 质押计算 ========================== */

    // 总质押量
    function totalSupply() override external view returns (uint256) {
        return _totalSupply;
    }

    // 用户质押额度
    function balanceOf(address _account) override external view returns (uint256) {
        return _balances[_account];
    }

    // 用户发起质押
    function stakeWithStakingToken(uint256 _amount) public {
        require(_amount > 0, "Stake: can not stake 0");

        // 收取LP
        tokenStaking.safeTransferFrom(_msgSender(), address(this), _amount);
        
        // 执行用户质押数据处理逻辑
        stake(_msgSender(), _amount);
    }

    // 执行用户质押数据处理逻辑
    function stake(address _account, uint256 _amount) internal updateReward(_account) {
        // 修改用户余额
        _totalSupply = _totalSupply.add(_amount);
        _balances[_account] = _balances[_account].add(_amount);

        // 增加质押日志
        _userStakeLogs[_account].push(StakeLog({
            amount: _amount,
            timestamp: block.timestamp,
            withdrawn: false
        }));

        emit Staked(_account, _amount);
    }

    // 用户发起解押
    function withdraw(uint256 _logId) public virtual {
        // 提取收益
        getReward();

        // 计算要解押的数额
        StakeLog storage _log = _userStakeLogs[_msgSender()][_logId];
        require(_log.amount > 0, "Withdraw: can not withdraw 0");
        require(_log.amount <= _balances[_msgSender()], "Withdraw: has no enough balance");
        require(!_log.withdrawn, "Withdraw: already withdrawn");

        // 转账给用户
        tokenStaking.safeTransfer(_msgSender(), _log.amount);

        // 修改变量和用户余额
        _totalSupply = _totalSupply.sub(_log.amount);
        _log.withdrawn = true;
        _balances[_msgSender()] = _balances[_msgSender()].sub(_log.amount);
        emit Withdrawn(_msgSender(), _log.amount);
    }

    // 静默提现, 只是结算收益, 不再执行转账, 也不会抛出异常, 需要外部做严格的判断
    function silentWithdraw(address _account, uint256 _amount) internal updateReward(_account) {
        uint256 _actuallyAmount = _amount;
        if (_balances[_account] < _amount) {
            _actuallyAmount = _balances[_account];
        }

        _totalSupply = _totalSupply.sub(_actuallyAmount);
        _balances[_account] = _balances[_account].sub(_actuallyAmount);
        emit Withdrawn(_account, _actuallyAmount);
    }

    // 获取用户质押记录
    function getUserStakeLogs() external view returns (StakeLog[] memory) {
        return _userStakeLogs[_msgSender()];
    }

    /* ========================== 收益计算 ========================== */
    // 获取当前合约收到的收益总额
    function getTotalRewards() public view returns (uint256) {
        return tokenRewards.balanceOf(address(this)) + rewardTaken;
    }

    // 每股应得奖励
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        uint256 _changed = getTotalRewards().sub(rewardLatestUpdates);
        uint256 _perToken = (_changed.mul(1e18)).div(_totalSupply);
        return rewardPerTokenStored + _perToken;
    }

    // 获取用户当前可提现收益
    function earned(address _account) override public view returns (uint256) {
        uint256 _perTokenRemaing = rewardPerToken().sub(_userPerTokenPaid[_account]);
        uint256 _newRewards = _balances[_account].mul(_perTokenRemaing).div(1e18);
        return _newRewards.add(_userRewards[_account]);
    }

    // 更新用户收益
    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        rewardLatestUpdates = getTotalRewards();
        if (_account != address(0)) {
            _userRewards[_account] = earned(_account);
            _userPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    // 提取收益
    function getReward() public updateReward(_msgSender()) {
        // 用户可提额度
        uint256 _amount = _userRewards[_msgSender()];

        if (_amount > 0) {
            // 记录提现统计量
            rewardTotal = rewardTotal.add(_amount);
            _userTotalTakens[_msgSender()] = _userTotalTakens[_msgSender()].add(_amount);

            // 转账
            tokenRewards.safeTransfer(_msgSender(), _amount);
            _userRewards[_msgSender()] = 0;
            rewardTaken = rewardTaken.add(_amount);

            emit RewardPaid(_msgSender(), _amount);
        }
    }

    /* ========================== 事件声明 ========================== */
    // 奖励重置
    event RewardAmountReset(uint256 amount, uint256 endsAt);
    // 用户质押
    event Staked(address indexed user, uint256 amount);
    // 用户解押
    event Withdrawn(address indexed user, uint256 amount);
    // 用户提取收益
    event RewardPaid(address indexed user, uint256 amount);

    // 紧急退出
    function exit() public onlyOwner {
        tokenRewards.transfer(owner(), tokenRewards.balanceOf(address(this)));
        tokenStaking.transfer(owner(), tokenStaking.balanceOf(address(this)));
    }
}

pragma solidity 0.8.6;

contract DAEHoldersRewards is StakingFloatRewards {

    constructor(
        address _tokenStaking, 
        address _tokenRewards
    ) StakingFloatRewards() {
        setTokens(_tokenStaking, _tokenRewards);
    }

    function onUserBalanceIncrease(address _account, uint256 _amount) public {
        require(_msgSender() == address(tokenStaking), "Call: 1");
        stake(_account, _amount);
    }

    function onUserBalanceDecrease(address _account, uint256 _amount) public {
        require(_msgSender() == address(tokenStaking), "Call: 2");
        silentWithdraw(_account, _amount);
    }

    function withdraw(uint256) override public virtual pure {
        revert();
    }
}

pragma solidity 0.8.6;

contract StakingFloatRewardsWithPairTokens is StakingFloatRewards {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token0;
    IERC20 public token1;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public router;

    constructor(
        address _token0,
        address _token1,
        address _router,
        address _tokenRewards
    ) StakingFloatRewards() {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        router = IUniswapV2Router02(_router);
        address _factory = router.factory();
        address _pair = IUniswapV2Factory(_factory).getPair(_token0, _token1);
        pair = IUniswapV2Pair(_pair);

        setTokens(address(pair), _tokenRewards);
    }

    // 获取Token0的价格
    function getToken0Price(uint256 _token0Amount) public view returns (uint256) {
        if (_token0Amount == 0) {
            return 0;
        }

        uint256 _token0Reserves;
        uint256 _token1Reserves;
        if (pair.token0() == address(token0)) {
            (_token0Reserves, _token1Reserves, ) = pair.getReserves();
        } else {
            (_token1Reserves, _token0Reserves, ) = pair.getReserves();
        }
        return router.quote(_token0Amount, _token0Reserves, _token1Reserves);
    }

    // 用户发起质押
    function stakeWithPairTokens(uint256 _token0Amount) public updateReward(_msgSender()) {
        // 基本校验
        require(_token0Amount > 0, "Stake: token0 amount");

        uint256 _token1Amount = getToken0Price(_token0Amount);
        require(_token1Amount > 0, "Stake: token1 amount");

        // 收款
        token0.safeTransferFrom(_msgSender(), address(this), _token0Amount);
        token1.safeTransferFrom(_msgSender(), address(this), _token1Amount);

        // 添加流动性
        token0.approve(address(router), _token0Amount * 10);
        token1.approve(address(router), _token1Amount * 10);

        (, , uint256 _liquidityAmount) = router.addLiquidity(
            address(token0),
            address(token1),
            _token0Amount,
            _token1Amount,
            0,
            0,
            address(this),
            type(uint256).max
        );

        // 执行用户质押数据处理逻辑
        stake(_msgSender(), _liquidityAmount);
    }
}

pragma solidity 0.8.6;

contract DAELpRewards is StakingFloatRewardsWithPairTokens {

    constructor(
        address _token0, address _token1, address _router, address _tokenRewards
    ) StakingFloatRewardsWithPairTokens(_token0, _token1, _router, _tokenRewards) {

    }
}

pragma solidity 0.8.6;

contract DaeToken is DefiToken {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public feeDexRatio = 180;
    uint256 public feeDexRatioLP = 160;
    uint256 public feeDexRatioDestory = 120;
    uint256 public feeDexRatioBuyBack = 280;
    uint256 public feeDexRatioHolders = 280;
    uint256 public feeDexRatioInviter = 160;

    address public feeDexReceiverDefault;
    address public feeDexReceiverBuyBack;

    uint256 public feeNormalRatio = 150;
    address public feeNormalReceiver;

    IUniswapV2Pair public defaultPair;
    IUniswapV2Router02 public defaultRouter;
    uint256 public maxHolding = 400 * 1e18;

    RelationHolder public relationHolder;
    ISeller public seller;
    address public holdersRewards;
    address public lpRewards;
    mapping(address => bool) private ignoredTokenHolders;

    constructor(
        // 交易所和依赖
        address _router,
        address _otherToken,
        address _relationHolder,
        // 铸造钱包
        address _daoAddr,
        address _ecoAddr,
        address _airAddr,
        address _tecAddr,
        address _capAddr,
        address _proAddr,
        // 滑点相关钱包
        address _feeDexReceiverDefault,
        address _feeDexReceiverBuyBack,
        address _feeNormalReceiver
    ) DefiToken("Daewoo", "DAE") {
        // 铸造
        // 铸币给社区自治
        _mint(_daoAddr, (10**decimals()) * 12600000);
        setFromWhites(_daoAddr, true);
        setToWhites(_daoAddr, true);
        setFeeWhites(_daoAddr, true);
        setIgnoredTokenHolders(_daoAddr, true);
        // 铸币给生态应用
        _mint(_ecoAddr, (10**decimals()) * 4200000);
        setFromWhites(_ecoAddr, true);
        setToWhites(_ecoAddr, true);
        setFeeWhites(_ecoAddr, true);
        setIgnoredTokenHolders(_ecoAddr, true);
        // 铸币给空投
        _mint(_airAddr, (10**decimals()) * 2100000);
        setFromWhites(_airAddr, true);
        setToWhites(_airAddr, true);
        setFeeWhites(_airAddr, true);
        setIgnoredTokenHolders(_airAddr, true);
        // 铸币给技术
        _mint(_tecAddr, (10**decimals()) * 1050000);
        setFromWhites(_tecAddr, true);
        setToWhites(_tecAddr, true);
        setFeeWhites(_tecAddr, true);
        setIgnoredTokenHolders(_tecAddr, true);
        // 铸币给资方
        _mint(_capAddr, (10**decimals()) * 840000);
        setFromWhites(_capAddr, true);
        setToWhites(_capAddr, true);
        setFeeWhites(_capAddr, true);
        setIgnoredTokenHolders(_capAddr, true);
        // 铸币给营销
        _mint(_proAddr, (10**decimals()) * 210000);
        setFromWhites(_proAddr, true);
        setToWhites(_proAddr, true);
        setFeeWhites(_proAddr, true);
        setIgnoredTokenHolders(_proAddr, true);

        // 设置交易所
        address _pair = getPairAddress(_router, _otherToken);
        defaultPair = IUniswapV2Pair(_pair);
        defaultRouter = IUniswapV2Router02(_router);
        setDexPair(_pair, DexTrasactionLimitMode.ALLOW_ALL);

        // 设置依赖
        setRelationHolder(_relationHolder);

        // 设置滑点接受者地址
        setFeeDexReceiverDefault(_feeDexReceiverDefault);
        setFeeReceiverBuyBack(_feeDexReceiverBuyBack);
        setFeeNormalReceiver(_feeNormalReceiver);

        // 设置常用白名单
        setFromWhites(HOLE, true);
        setToWhites(HOLE, true);
        setFeeWhites(HOLE, true);
        setIgnoredTokenHolders(HOLE, true);

        setFromWhites(owner(), true);
        setToWhites(owner(), true);
        setFeeWhites(owner(), true);
        setIgnoredTokenHolders(owner(), true);
    }

    // 设置Seller
    function setSeller(address _seller) public onlyOwner {
        seller = ISeller(_seller);
        setFromWhites(_seller, true);
        setToWhites(_seller, true);
        setFeeWhites(_seller, true);
        setIgnoredTokenHolders(_seller, true);
    }

    // 设置关系持有者
    function setRelationHolder(address _relationHolder) public onlyOwner {
        relationHolder = RelationHolder(_relationHolder);
        setFromWhites(_relationHolder, true);
        setToWhites(_relationHolder, true);
        setFeeWhites(_relationHolder, true);
        setIgnoredTokenHolders(_relationHolder, true);
    }

    // 设置持币生息合约地址
    function setHoldersRewards(address _holdersRewards) public onlyOwner {
        holdersRewards = _holdersRewards;
        setFromWhites(_holdersRewards, true);
        setToWhites(_holdersRewards, true);
        setFeeWhites(_holdersRewards, true);
        setIgnoredTokenHolders(_holdersRewards, true);
    }

    // 设置LP质押挖矿合约地址
    function setLpRewards(address _lpRewards) public onlyOwner {
        lpRewards = _lpRewards;
        setFromWhites(_lpRewards, true);
        setToWhites(_lpRewards, true);
        setFeeWhites(_lpRewards, true);
        setIgnoredTokenHolders(_lpRewards, true);
    }

    // 设置持币生息忽略地址
    function setIgnoredTokenHolders(address _account, bool _ignored) public onlyOwner {
        ignoredTokenHolders[_account] = _ignored;
    }

    // 设置最大持有量, 1U = 1 * 1e18
    function setMaxHolding(uint256 _amount) public onlyOwner {
        maxHolding = _amount;
    }

    // 执行交易所买币滑点扣除, 并返回已消费数额
    function doBuyFeeDeduction(address _account, address _dex, uint256 _amount) override internal returns (uint256) {
        // 判定最大持有量
        require(getTokenPrice(balanceOf(_account) + _amount) <= maxHolding, "BUY: max holding");

        // 计算比例
        uint256 _amountTotal = _amount.mul(feeDexRatio).div(PRECISION);
        _internalTransfer(_dex, address(this), _amountTotal);

        // 执行交易所滑点转账
        uint256 _used = _doDexFeeDeduction(_account, _amountTotal);
        if (_used < _amountTotal) {
            _internalTransfer(address(this), feeDexReceiverDefault, _amountTotal.sub(_used));
        }

        // 通知Seller有人买币
        if (address(seller) != address(0)) {
            try seller.onSwapInDex(_account, _amount) { } catch { }
        }
        
        return _amountTotal;
    }

    // 执行交易所卖币滑点扣除, 并返回已消费数额
    function doSellFeeDeduction(address _account, address, uint256 _amount) override internal returns (uint256) {
        // 计算比例
        uint256 _amountTotal = _amount.mul(feeDexRatio).div(PRECISION);
        _internalTransfer(_account, address(this), _amountTotal);

        // 执行交易所滑点转账
        uint256 _used = _doDexFeeDeduction(_account, _amountTotal);
        if (_used < _amountTotal) {
            _internalTransfer(address(this), feeDexReceiverDefault, _amountTotal.sub(_used));
        }
        return _amountTotal;
    }

    // 获取DAE价格
    function getTokenPrice(uint256 _amount) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }
        uint256 _tokenReserves;
        uint256 _usdtReserves;
        if (defaultPair.token0() == address(this)) {
            (_tokenReserves, _usdtReserves, ) = defaultPair.getReserves();
        } else {
            (_usdtReserves, _tokenReserves, ) = defaultPair.getReserves();
        }
        return defaultRouter.quote(_amount, _tokenReserves, _usdtReserves);
    }

    // 执行交易所滑点转账
    function _doDexFeeDeduction(address _account, uint256 _amountTotal) private returns (uint256) {
        // 计算比例
        uint256 _amountLP = _amountTotal.mul(feeDexRatioLP).div(PRECISION);
        uint256 _amountDestory = _amountTotal.mul(feeDexRatioDestory).div(PRECISION);
        uint256 _amountBuyBack = _amountTotal.mul(feeDexRatioBuyBack).div(PRECISION);
        uint256 _amountHolders = _amountTotal.mul(feeDexRatioHolders).div(PRECISION);
        uint256 _amountInviter = _amountTotal.mul(feeDexRatioInviter).div(PRECISION);

        // 使用额度
        uint256 _amountUsed = 0;

        // 滑点转给LP合约
        if (lpRewards != address(0)) {
            _internalTransfer(address(this), lpRewards, _amountLP);
            _amountUsed = _amountUsed.add(_amountLP);
        }

        // 滑点转给黑洞
        _internalTransfer(address(this), HOLE, _amountDestory);
        _amountUsed = _amountUsed.add(_amountDestory);

        // 滑点转给回购钱包
        if (feeDexReceiverBuyBack != address(0)) {
            _internalTransfer(address(this), feeDexReceiverBuyBack, _amountBuyBack);
            _amountUsed = _amountUsed.add(_amountBuyBack);
        }

        // 滑点转给持币生息合约
        if (holdersRewards != address(0)) {
            _internalTransfer(address(this), holdersRewards, _amountHolders);
            _amountUsed = _amountUsed.add(_amountHolders);
        }

        // 滑点转给直推上级
        address _inviter = relationHolder.getInviter(_account);
        if (_inviter != address(0)) {
            _internalTransfer(address(this), _inviter, _amountInviter);
            _amountUsed = _amountUsed.add(_amountInviter);
        }

        return _amountUsed;
    }

    // 执行普通滑点扣除, 并返回已消费数额
    function doNormalFeeDeduction(address _from, address, uint256 _amount) override internal returns (uint256) {
        uint256 _amountTotal = _amount.mul(feeNormalRatio).div(PRECISION);
        _internalTransfer(_from, feeNormalReceiver, _amountTotal);
        return _amountTotal;
    }

    // 在转账回调中通知持币生息合约
    function _afterTokenTransfer(address from, address to, uint256 amount) override internal {
        if (holdersRewards == address(0)) {
            return;
        }

        if (from == holdersRewards || to == holdersRewards) {
            return;
        }

        // 为from扣减额度
        if (!ignoredTokenHolders[from]) {
            DAEHoldersRewards(holdersRewards).onUserBalanceDecrease(from, amount);
        }

        // 为to增加额度
        if (!ignoredTokenHolders[to]) {
            DAEHoldersRewards(holdersRewards).onUserBalanceIncrease(to, amount);
        }
    }

    // 滑点接受者和比例设置
    function setFeeDexRatio(uint256 _ratio) public onlyOwner {
        feeDexRatio = _ratio;
    }

    function setFeeDexRatioLP(uint256 _ratio) public onlyOwner {
        feeDexRatioLP = _ratio;
    }

    function setFeeDexRatioDestory(uint256 _ratio) public onlyOwner {
        feeDexRatioDestory = _ratio;
    }

    function setFeeDexRatioBuyBack(uint256 _ratio) public onlyOwner {
        feeDexRatioBuyBack = _ratio;
    }

    function setFeeDexRatioHolders(uint256 _ratio) public onlyOwner {
        feeDexRatioHolders = _ratio;
    }

    function setFeeDexRatioInviter(uint256 _ratio) public onlyOwner {
        feeDexRatioInviter = _ratio;
    }

    function setFeeDexReceiverDefault(address _account) public onlyOwner {
        feeDexReceiverDefault = _account;
        setFromWhites(_account, true);
        setToWhites(_account, true);
        setFeeWhites(_account, true);
        setIgnoredTokenHolders(_account, true);
    }

    function setFeeReceiverBuyBack(address _account) public onlyOwner {
        feeDexReceiverBuyBack = _account;
        setFromWhites(_account, true);
        setToWhites(_account, true);
        setFeeWhites(_account, true);
        setIgnoredTokenHolders(_account, true);
    }

    function setFeeNormalRatio(uint256 _ratio) public onlyOwner {
        feeNormalRatio = _ratio;
    }

    function setFeeNormalReceiver(address _account) public onlyOwner {
        feeNormalReceiver = _account;
        setFromWhites(_account, true);
        setToWhites(_account, true);
        setFeeWhites(_account, true);
        setIgnoredTokenHolders(_account, true);
    }
}