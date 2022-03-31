/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// Sources flattened with hardhat v2.9.2 https://hardhat.org

// File @openzeppelin/contracts/security/[email protected]

// SPDX-License-Identifier: GPL-3.0-only

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
     * by making the `nonReentrant` function external, and make it call a
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


// File @openzeppelin/contracts/token/ERC20/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]



pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]



pragma solidity ^0.8.0;


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


// File @openzeppelin/contracts/utils/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity ^0.8.0;



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


// File contracts/interfaces/IOSWAP_HybridRouter2.sol


pragma solidity =0.8.6;

interface IOSWAP_HybridRouter2 {

    function registry() external view returns (address);
    function WETH() external view returns (address);

    function getPathIn(address[] calldata pair, address tokenIn) external view returns (address[] memory path);
    function getPathOut(address[] calldata pair, address tokenOut) external view returns (address[] memory path);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata pair,
        address tokenIn,
        address to,
        uint deadline,
        bytes calldata data
    ) external returns (address[] memory path, uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata pair,
        address tokenOut,
        address to,
        uint deadline,
        bytes calldata data
    ) external returns (address[] memory path, uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata pair, address to, uint deadline, bytes calldata data)
        external
        payable
        returns (address[] memory path, uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata pair, address to, uint deadline, bytes calldata data)
        external
        returns (address[] memory path, uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata pair, address to, uint deadline, bytes calldata data)
        external
        returns (address[] memory path, uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata pair, address to, uint deadline, bytes calldata data)
        external
        payable
        returns (address[] memory path, uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address tokenIn,
        address to,
        uint deadline,
        bytes calldata data
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        bytes calldata data
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        bytes calldata data
    ) external;

    function getAmountsInStartsWith(uint amountOut, address[] calldata pair, address tokenIn, bytes calldata data) external view returns (uint[] memory amounts);
    function getAmountsInEndsWith(uint amountOut, address[] calldata pair, address tokenOut, bytes calldata data) external view returns (uint[] memory amounts);
    function getAmountsOutStartsWith(uint amountIn, address[] calldata pair, address tokenIn, bytes calldata data) external view returns (uint[] memory amounts);
    function getAmountsOutEndsWith(uint amountIn, address[] calldata pair, address tokenOut, bytes calldata data) external view returns (uint[] memory amounts);
}


// File contracts/interfaces/IOSWAP_VotingExecutorManager.sol


pragma solidity 0.8.6;

interface IOSWAP_VotingExecutorManager {
    event ParamSet(bytes32 indexed name, bytes32 value);
    event ParamSet2(bytes32 name, bytes32 value1, bytes32 value2);

    function govToken() external view returns (IERC20 govToken);
    function votingExecutor(uint256 index) external view returns (address);
    function votingExecutorInv(address) external view returns (uint256 votingExecutorInv);
    function isVotingExecutor(address) external view returns (bool isVotingExecutor);
    function trollRegistry() external view returns (address trollRegistry);
    function newVotingExecutorManager() external view returns (IOSWAP_VotingExecutorManager newVotingExecutorManager);

    function votingExecutorLength() external view returns (uint256);
    function setVotingExecutor(address _votingExecutor, bool _bool) external;
}


// File contracts/interfaces/IOSWAP_ConfigStore.sol


pragma solidity 0.8.6;


interface IOSWAP_ConfigStore {

    event ParamSet1(bytes32 indexed name, bytes32 value1);
    event ParamSet2(bytes32 indexed name, bytes32 value1, bytes32 value2);
    event UpdateVotingExecutorManager(IOSWAP_VotingExecutorManager newVotingExecutorManager);
    event Upgrade(IOSWAP_ConfigStore newConfigStore);

    function priceOracle(IERC20 token) external view returns (address priceOracle); // priceOracle[token] = oracle
    function isApprovedProxy(address proxy) external view returns (bool isApprovedProxy);
    function govToken() external view returns (IERC20 govToken);
    function votingExecutorManager() external view returns (IOSWAP_VotingExecutorManager votingExecutorManager);
    function lpWithdrawlDelay() external view returns (uint256 lpWithdrawlDelay);
    function minStakePeriod() external view returns (uint256 minStakePeriod); // main chain
    function transactionsGap() external view returns (uint256 transactionsGap); // side chain
    function superTrollMinCount() external view returns (uint256 superTrollMinCount); // side chain
    function generalTrollMinCount() external view returns (uint256 generalTrollMinCount); // side chain
    function baseFee(IERC20 asset) external view returns (uint256 baseFee);
    function transactionFee() external view returns (uint256 transactionFee);
    function router() external view returns (address router);
    function rebalancer() external view returns (address rebalancer);
    function newConfigStore() external view returns (IOSWAP_ConfigStore newConfigStore);
    function feeTo() external view returns (address feeTo);
    struct Params {
        IOSWAP_VotingExecutorManager votingExecutorManager;
        uint256 lpWithdrawlDelay;
        uint256 transactioinsGap;
        uint256 superTrollMinCount;
        uint256 generalTrollMinCount;
        uint256 minStakePeriod;
        uint256 transactionFee;
        address router;
        address rebalancer;
        address wrapper;
        IERC20[] asset;
        uint256[] baseFee;
    }

    function upgrade(IOSWAP_ConfigStore _configStore) external;
    function updateVotingExecutorManager() external;
    function setMinStakePeriod(uint256 _minStakePeriod) external;
    function setConfigAddress(bytes32 name, bytes32 _value) external;
    function setConfig(bytes32 name, bytes32 _value) external;
    function setConfig2(bytes32 name, bytes32 value1, bytes32 value2) external;
    function setOracle(IERC20 asset, address oracle) external;
    function getSignatureVerificationParams() external view returns (uint256,uint256,uint256);
    function getBridgeParams(IERC20 asset) external view returns (address,address,address,uint256,uint256);
}


// File contracts/interfaces/IAuthorization.sol


pragma solidity 0.8.6;

interface IAuthorization {
    function owner() external view returns (address owner);
    function newOwner() external view returns (address newOwner);

    function isPermitted(address) external view returns (bool isPermitted);

    event Authorize(address user);
    event Deauthorize(address user);
    event StartOwnershipTransfer(address user);
    event TransferOwnership(address user);

    function transferOwnership(address newOwner_) external;
    function takeOwnership() external;
    function permit(address user) external;
    function deny(address user) external;
}


// File contracts/interfaces/IOSWAP_SideChainTrollRegistry.sol


pragma solidity 0.8.6;



interface IOSWAP_SideChainTrollRegistry is IAuthorization {

    event Shutdown(address indexed account);
    event Resume();

    event AddTroll(address indexed troll, uint256 indexed trollProfileIndex, bool isSuperTroll);
    event UpdateTroll(uint256 indexed trollProfileIndex, address indexed troll);
    event RemoveTroll(uint256 indexed trollProfileIndex);
    event DelistTroll(uint256 indexed trollProfileIndex);
    event LockSuperTroll(uint256 indexed trollProfileIndex, address lockedBy);
    event LockGeneralTroll(uint256 indexed trollProfileIndex, address lockedBy);
    event UnlockSuperTroll(uint256 indexed trollProfileIndex, bool unlock, address bridgeVault, uint256 penalty);
    event UnlockGeneralTroll(uint256 indexed trollProfileIndex);
    event UpdateConfigStore(IOSWAP_ConfigStore newConfigStore);
    event SetVotingExecutor(address newVotingExecutor, bool isActive);
    event Upgrade(address newTrollRegistry);

    enum TrollType {NotSpecified, SuperTroll, GeneralTroll, BlockedSuperTroll, BlockedGeneralTroll}

    struct TrollProfile {
        address troll;
        TrollType trollType;
    }
    function govToken() external view returns (IERC20 govToken);
    function configStore() external view returns (IOSWAP_ConfigStore configStore);
    function votingExecutor(uint256 index) external view returns (address);
    function votingExecutorInv(address) external view returns (uint256 votingExecutorInv);
    function isVotingExecutor(address) external view returns (bool isVotingExecutor);
    function trollProfiles(uint256 trollProfileIndex) external view returns (TrollProfile memory trollProfiles); // trollProfiles[trollProfileIndex] = {troll, trollType}
    function trollProfileInv(address troll) external view returns (uint256 trollProfileInv); // trollProfileInv[troll] = trollProfileIndex
    function superTrollCount() external view returns (uint256 superTrollCount);
    function generalTrollCount() external view returns (uint256 generalTrollCount);
    function transactionsCount() external view returns (uint256 transactionsCount);
    function lastTrollTxCount(address troll) external view returns (uint256 lastTrollTxCount); // lastTrollTxCount[troll]
    function usedNonce(uint256) external view returns (bool usedNonce);

    function newTrollRegistry() external view returns (address newTrollRegistry);

    function initAddress(address _votingExecutor, IOSWAP_ConfigStore _configStore) external;

    /*
     * upgrade
     */
    function updateConfigStore() external;
    function upgrade(address _trollRegistry) external;
    function upgradeByAdmin(address _trollRegistry) external;

    /*
     * pause / resume
     */
    function paused() external view returns (bool);
    function shutdownByAdmin() external;
    function shutdownByVoting() external;
    function resume() external;

    function votingExecutorLength() external view returns (uint256);
    function setVotingExecutor(address _votingExecutor, bool _bool) external;

    function isSuperTroll(address troll, bool returnFalseIfBlocked) external view returns (bool);
    function isSuperTrollByIndex(uint256 trollProfileIndex, bool returnFalseIfBlocked) external view returns (bool);
    function isGeneralTroll(address troll, bool returnFalseIfBlocked) external view returns (bool);
    function isGeneralTrollByIndex(uint256 trollProfileIndex, bool returnFalseIfBlocked) external view returns (bool);

    function verifySignatures(address msgSender, bytes[] calldata signatures, bytes32 paramsHash, uint256 _nonce) external;
    function hashAddTroll(uint256 trollProfileIndex, address troll, bool _isSuperTroll, uint256 _nonce) external view returns (bytes32);
    function hashUpdateTroll(uint256 trollProfileIndex, address newTroll, uint256 _nonce) external view returns (bytes32);
    function hashRemoveTroll(uint256 trollProfileIndex, uint256 _nonce) external view returns (bytes32);
     function hashUnlockTroll(uint256 trollProfileIndex, bool unlock, address[] memory vaultRegistry, uint256[] memory penalty, uint256 _nonce) external view returns (bytes32);

    function addTroll(bytes[] calldata signatures, uint256 trollProfileIndex, address troll, bool _isSuperTroll, uint256 _nonce) external;
    function updateTroll(bytes[] calldata signatures, uint256 trollProfileIndex, address newTroll, uint256 _nonce) external;
    function removeTroll(bytes[] calldata signatures, uint256 trollProfileIndex, uint256 _nonce) external;

    function lockSuperTroll(uint256 trollProfileIndex) external;
    function unlockSuperTroll(bytes[] calldata signatures, uint256 trollProfileIndex, bool unlock, address[] calldata vaultRegistry, uint256[] calldata penalty, uint256 nonce) external;
    function lockGeneralTroll(uint256 trollProfileIndex) external;
    function unlockGeneralTroll(bytes[] calldata signatures, uint256 trollProfileIndex, uint256 nonce) external;
}


// File contracts/interfaces/IOSWAP_BridgeVaultTrollRegistry.sol


pragma solidity 0.8.6;



interface IOSWAP_BridgeVaultTrollRegistry {

    event Stake(address indexed backer, uint256 indexed trollProfileIndex, uint256 amount, uint256 shares, uint256 backerBalance, uint256 trollBalance);
    event UnstakeRequest(address indexed backer, uint256 indexed trollProfileIndex, uint256 shares, uint256 backerBalance);
    event Unstake(address indexed backer, uint256 indexed trollProfileIndex, uint256 amount, uint256 shares, uint256 trollBalance);
    event UnstakeApproval(address indexed backer, address indexed msgSender, uint256[] signers, uint256 shares);
    event UpdateConfigStore(IOSWAP_ConfigStore newConfigStore);
    event UpdateTrollRegistry(IOSWAP_SideChainTrollRegistry newTrollRegistry);
    event Penalty(uint256 indexed trollProfileIndex, uint256 amount);

    struct Stakes{
        uint256 trollProfileIndex;
        uint256 shares;
        uint256 pendingWithdrawal;
        uint256 approvedWithdrawal;
    }
    // struct StakedBy{
    //     address backer;
    //     uint256 index;
    // }
    function govToken() external view returns (IERC20 govToken);
    function configStore() external view returns (IOSWAP_ConfigStore configStore);
    function trollRegistry() external view returns (IOSWAP_SideChainTrollRegistry trollRegistry);
    function bridgeVault() external view returns (address bridgeVault);
    function backerStakes(address backer) external view returns (Stakes memory backerStakes); // backerStakes[bakcer] = Stakes;
    function stakedBy(uint256 trollProfileIndex, uint256 index) external view returns (address stakedBy); // stakedBy[trollProfileIndex][idx] = backer;
    function stakedByInv(uint256 trollProfileIndex, address backer) external view returns (uint256 stakedByInv); // stakedByInv[trollProfileIndex][backer] = stakedBy_idx;
    function trollStakesBalances(uint256 trollProfileIndex) external view returns (uint256 trollStakesBalances); // trollStakesBalances[trollProfileIndex] = balance
    function trollStakesTotalShares(uint256 trollProfileIndex) external view returns (uint256 trollStakesTotalShares); // trollStakesTotalShares[trollProfileIndex] = shares
    function transactionsCount() external view returns (uint256 transactionsCount);
    function lastTrollTxCount(address troll) external view returns (uint256 lastTrollTxCount); // lastTrollTxCount[troll]
    function usedNonce(uint256 nonce) external view returns (bool used);

    function initAddress(address _bridgeVault) external;
    function updateConfigStore() external;
    function updateTrollRegistry() external;

    function getBackers(uint256 trollProfileIndex) external view returns (address[] memory backers);
    function stakedByLength(uint256 trollProfileIndex) external view returns (uint256 length);

    function stake(uint256 trollProfileIndex, uint256 amount) external returns (uint256 shares);

    function maxWithdrawal(address backer) external view returns (uint256 amount);
    function hashUnstakeRequest(address backer, uint256 trollProfileIndex, uint256 shares, uint256 _nonce) external view returns (bytes32 hash);
    function unstakeRequest(uint256 shares) external;
    function unstakeApprove(bytes[] calldata signatures, address backer, uint256 trollProfileIndex, uint256 shares, uint256 _nonce) external;
    function unstake(address backer, uint256 shares) external;

    function verifyStakedValue(address msgSender, bytes[] calldata signatures, bytes32 paramsHash) external returns (uint256 superTrollCount, uint totalStake, uint256[] memory signers);

    function verifyMinimumSignaturesAndNonce(address msgSender, bytes[] calldata signatures, bytes32 paramsHash, uint256 _nonce) external returns (uint256 totalStake, uint256[] memory signers);
    function penalizeSuperTroll(uint256 trollProfileIndex, uint256 amount) external;
}


// File contracts/OSWAP_BridgeVault.sol


pragma solidity 0.8.6;









interface PriceOracle {
    function latestAnswer() external view returns (int256);
}

/*
From the Whitepaper:
There are 5 types of fee mechanisms:

Chain Fee:  This is a flat fee that will be collected and given to the troll assigned to be the Trx Creator to compensate for gas fees
Bridge Trx Fee:  This is a % of the transaction amount and it is this fee that will be split amongst the liquidity providers, trolls and the protocol
Balancer Fee:  The portion of a transaction that negatively unbalances a vault will be subjected to a balancer fee
Order Cancel & Withdraw Fee:  This is a fee that will be charged when an interchain user decides to cancel and withdraw funds from the order
LP Interchain Withdraw Fee:  This fee is for a phase 2 feature that will enable a Liquidity provider to withdraw their liquidity from a blockchain different from the one they staked on
*/

/*
                   -ve   |   +ve
       <-----------------|-------------->------------------> (lpAssetBalance + totalPendingWithdrawal)
         removeLiquidity | addLiquidity   swap(bridge_fee)
                  <------|---------->                        (imbalance)
                    swap | newOrder
     <-------------------|----------------->                 (protocolFeeBalance)
       withdrawlTrollFee | swap(troll_fee)

*/

contract OSWAP_BridgeVault is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "value < 0");
        return uint256(value);
    }
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "value > int256.max");
        return int256(value);
    }
    function _transferAssetFrom(address from, uint amount) internal returns (uint256 balance) {
        balance = asset.balanceOf(address(this));
        asset.safeTransferFrom(from, address(this), amount);
        balance = asset.balanceOf(address(this)) - balance;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier whenNotPaused() {
        require(address(trollRegistry)==address(0)||(!trollRegistry.paused()), "PAUSED!");
        _;
    }

    event AddLiquidity(address indexed provider, uint256 amount, uint256 mintAmount, uint256 newBalance, uint256 newLpAssetBalance);
    event RemoveLiquidityRequest(address indexed provider, uint256 amount, uint256 burnAmount, uint256 newBalance, uint256 newLpAssetBalance, uint256 newPendingWithdrawal);
    event RemoveLiquidity(address indexed provider, uint256 amount, uint256 newPendingWithdrawal);
    event NewOrder(uint256 indexed orderId, address indexed owner, Order order, int256 newImbalance);
    event WithdrawUnexecutedOrder(address indexed owner, uint256 orderId, int256 newImbalance);
    event AmendOrderRequest(uint256 indexed orderId, uint256 indexed amendment, Order order, int256 newImbalance);
    event RequestCancelOrder(address indexed owner, uint256 indexed sourceChainId, uint256 indexed orderId, bytes32 hashedOrderId);
    event OrderCanceled(uint256 indexed orderId, address indexed sender, uint256[] signers, bool canceledByOrderOwner, uint256 fee);
    event Swap(uint256 indexed orderId, address indexed sender, uint256[] signers, address owner, uint256 amendment, Order order, uint256 outAmount, int256 newImbalance);
    event VoidOrder(bytes32 indexed orderId, address indexed sender, uint256[] signers);
    event UpdateConfigStore(IOSWAP_ConfigStore newConfigStore);
    event UpdateTrollRegistry(IOSWAP_SideChainTrollRegistry newTrollRegistry);
    event Rebalance(address who, int256 amount, int256 newImbalance);
    event WithdrawlTrollFee(address feeTo, uint256 amount);
    event Sync(uint256 excess, uint256 newLpAssetBalance);

    address owner;

    IOSWAP_SideChainTrollRegistry public trollRegistry;
    IERC20 public immutable govToken;
    IERC20 public immutable asset;
    int8 public immutable assetDecimalsScale;
    IOSWAP_ConfigStore public configStore;
    IOSWAP_BridgeVaultTrollRegistry public vaultRegistry;

    int256 public imbalance;
    uint256 public lpAssetBalance;
    uint256 public totalPendingWithdrawal;
    // protocol fee will be distributed off-chain
    uint256 public protocolFeeBalance;

    mapping(address => uint256) public pendingWithdrawalAmount; // pendingWithdrawalAmount[lp] = amount
    mapping(address => uint256) public pendingWithdrawalTimeout; // pendingWithdrawalTimeout[lp] = timeout

    // pending must be the init status which have value of 0
    enum OrderStatus{NotSpecified, Pending, Executed, RequestCancel, RefundApproved, Cancelled, RequestAmend}

    // source chain
    struct Order {
        uint256 peerChain;
        uint256 inAmount;
        address outToken;
        uint256 minOutAmount;
        address to;
        uint256 expire;
    }
    Order[] public orders;
    mapping(uint256 => Order[]) public orderAmendments;
    mapping(uint256 => address) public orderOwner;
    mapping(uint256 => OrderStatus) public orderStatus;
    mapping(uint256 => uint256) public orderRefunds;
    // target chain
    mapping(bytes32 => OrderStatus) public swapOrderStatus;

    constructor(IOSWAP_BridgeVaultTrollRegistry _vaultRegistry, IOSWAP_ConfigStore _configStore, IERC20 _asset) ERC20("OSWAP Bridge Vault", "OSWAP-VAULT") {
        // if vaultRegistry is not passed in, save msg.sender as the owner and set it afterwards
        if (address(_vaultRegistry) == address(0)) {
            owner = msg.sender;
        } else {
            vaultRegistry = _vaultRegistry;
            trollRegistry = vaultRegistry.trollRegistry();
        }
        IERC20 _govToken = _configStore.govToken();
        govToken = _govToken;
        uint8 govTokenDecimals = IERC20Metadata(address(_govToken)).decimals();
        asset = _asset;
        uint8 assetDecimals = IERC20Metadata(address(_asset)).decimals();
        assetDecimalsScale = int8(assetDecimals) - int8(govTokenDecimals);
        configStore = _configStore;
    }
    function initAddress(IOSWAP_BridgeVaultTrollRegistry _vaultRegistry) external onlyOwner {
        require(address(_vaultRegistry) != address(0), "null address");
        require(address(vaultRegistry) == address(0), "already init");
        vaultRegistry = _vaultRegistry;
        trollRegistry = vaultRegistry.trollRegistry();
        owner = address(0);
    }

    function updateConfigStore() external {
        IOSWAP_ConfigStore _configStore = configStore.newConfigStore();
        require(address(_configStore) != address(0), "Invalid config store");
        configStore = _configStore;
        emit UpdateConfigStore(configStore);
    }
    function updateTrollRegistry() external {
        address _trollRegistry = trollRegistry.newTrollRegistry();
        require(_trollRegistry != address(0), "Invalid config store");
        trollRegistry = IOSWAP_SideChainTrollRegistry(_trollRegistry);
        emit UpdateTrollRegistry(trollRegistry);
    }

    function ordersLength() external view returns (uint256 length) {
        length = orders.length;
    }
    function orderAmendmentsLength(uint256 orderId) external view returns (uint256 length) {
        length = orderAmendments[orderId].length;
    }

    function getOrders(uint256 start, uint256 length) external view returns (Order[] memory list) {
        Order[] memory accountOrders = orders;
        if (start < accountOrders.length) {
            if (start + length > accountOrders.length) {
                length = accountOrders.length - start;
            }
            list = new Order[](length);
            for (uint256 i = 0 ; i < length ; i++) {
                list[i] = accountOrders[i+start];
            }
        }
        return list;
    }

    function lastKnownBalance() public view returns (uint256 balance) {
        balance = toUint256(toInt256(lpAssetBalance + totalPendingWithdrawal + protocolFeeBalance) + imbalance);
    }

    /*
     * signatures related functions
     */
    function getChainId() public view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
    // Do not reuse the (chain,address,owner,orderId) combinations for other purpose
    // the order status should be checked and updated before and after applying the signatures respectively
    // otherwise a nonce should be added to the signature
    function hashCancelOrderParams(uint256 orderId, bool canceledByOrderOwner, uint256 protocolFee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            getChainId(),
            address(this),
            orderId,
            canceledByOrderOwner,
            protocolFee
        ));
    }
    function hashVoidOrderParams(bytes32 orderId) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            getChainId(),
            address(this),
            orderId
        ));
    }
    function hashSwapParams(
        bytes32 orderId,
        uint256 amendment,
        Order calldata order,
        uint256 protocolFee,
        address[] calldata pair
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            getChainId(),
            address(this),
            orderId,
            amendment,
            order.inAmount,
            order.outToken,
            order.minOutAmount,
            protocolFee,
            pair,
            order.to,
            order.expire
        ));
    }
    function hashWithdrawParams(address _owner, uint256 amount, uint256 _nonce) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            getChainId(),
            address(this),
            _owner,
            amount,
            _nonce
        ));
    }
    function hashOrder(address _owner, uint256 sourceChainId, uint256 orderId) public view returns (bytes32){
        return keccak256(abi.encodePacked(_owner, getChainId(), address(this), sourceChainId, orderId));
    }

    /*
     * functions called by LP
     */
    function addLiquidity(uint256 amount) external nonReentrant whenNotPaused {
        require(amount != 0, "amount must greater than zero");
        amount = _transferAssetFrom(msg.sender, amount);
        uint256 mintAmount = lpAssetBalance == 0 ? amount : (amount * totalSupply() / lpAssetBalance);
        lpAssetBalance += amount;
        _mint(msg.sender, mintAmount);
        emit AddLiquidity(msg.sender, amount, mintAmount, balanceOf(msg.sender), lpAssetBalance);
    }
    function removeLiquidityRequest(uint256 lpTokenAmount) external nonReentrant {
        uint256 assetAmount = lpTokenAmount * lpAssetBalance / totalSupply();
        require(lpAssetBalance >= assetAmount, "not enough fund");
        lpAssetBalance -= assetAmount;
        _burn(msg.sender, lpTokenAmount);

        uint256 delay = configStore.lpWithdrawlDelay();
        // if LP balance + imbalance (could be negative) enough to cover the withdrawal,
        // do the withdrawal right away
        if (delay == 0 && (toInt256(lpAssetBalance) + imbalance >= 0)) {
            asset.safeTransfer(msg.sender, assetAmount);
            emit RemoveLiquidity(msg.sender, assetAmount, totalPendingWithdrawal);
        } else {
            pendingWithdrawalAmount[msg.sender] += assetAmount;
            pendingWithdrawalTimeout[msg.sender] = block.timestamp + delay;
            totalPendingWithdrawal += assetAmount;
        }
        emit RemoveLiquidityRequest(msg.sender, assetAmount, lpTokenAmount, balanceOf(msg.sender), lpAssetBalance, totalPendingWithdrawal);
    }
    // can do remove withdrawal for others
    function removeLiquidity(address provider, uint256 assetAmount) public nonReentrant {
        //check withdrawal timeout, burn vault token, return assets
        require(pendingWithdrawalTimeout[provider] <= block.timestamp, "BridgeVault: please wait");
        require(pendingWithdrawalAmount[provider] >= assetAmount, "BridgeVault: withdraw amount exceeded requested amount");
        pendingWithdrawalAmount[provider] -= assetAmount;
        totalPendingWithdrawal -= assetAmount;
        asset.safeTransfer(provider, assetAmount);
        emit RemoveLiquidity(provider, assetAmount, totalPendingWithdrawal);
    }

    /*
     *  new order on source chain
     */
    function _newOrder(Order memory order) internal returns (uint256 orderId) {
        orderId = orders.length;
        orders.push(order);
        orderStatus[orderId] = OrderStatus.Pending;
        imbalance += toInt256(order.inAmount);
        emit NewOrder(orderId, msg.sender, order, imbalance);
    }

    /*
     *  functions called by proxy on source chain
     */
    function newOrderFromRouter(Order calldata order, address trader) external whenNotPaused returns (uint256 orderId) {
        require(configStore.isApprovedProxy(msg.sender), "Not from approved address");
        require((asset.balanceOf(address(this))) >= order.inAmount + lastKnownBalance(), "insufficient amount");

        orderId = _newOrder(order);
        orderOwner[orderId] = trader;
    }

    /*
     *  functions called by traders on source chain
     */
    function newOrder(Order memory order) external nonReentrant whenNotPaused returns (uint256 orderId) {
        require(order.inAmount > 0, "input amount must greater then zero");
        order.inAmount = _transferAssetFrom(msg.sender, order.inAmount);

        orderId = _newOrder(order);
        orderOwner[orderId] = msg.sender;
    }
    function withdrawUnexecutedOrder(uint256 orderId) external nonReentrant whenNotPaused {
        Order memory order = orders[orderId];
        require(orderOwner[orderId] == msg.sender,  "BridgeVault: not from owner");
        require(orderStatus[orderId] == OrderStatus.RefundApproved, "BridgeVault: cancellation not approved");
        orderStatus[orderId] = OrderStatus.Cancelled;
        imbalance -= toInt256(order.inAmount);
        asset.safeTransfer(msg.sender, orderRefunds[orderId]);
        emit WithdrawUnexecutedOrder(msg.sender, orderId, imbalance);
    }
    function requestAmendOrder(uint256 orderId, Order calldata order) external nonReentrant whenNotPaused {
        require(orderOwner[orderId] == msg.sender, "BridgeVault: not from owner");
        require(orderStatus[orderId] == OrderStatus.Pending || orderStatus[orderId] == OrderStatus.RequestAmend, "BridgeVault: not a pending order");
        require(order.peerChain == orders[orderId].peerChain, "Invalid in amount");
        require(order.inAmount == orders[orderId].inAmount, "Invalid in amount");

        if (orderAmendments[orderId].length == 0) {
            orderAmendments[orderId].push(orders[orderId]);
        }
        orderAmendments[orderId].push(order);
        orderStatus[orderId] = OrderStatus.RequestAmend;
        emit AmendOrderRequest(orderId, orderAmendments[orderId].length-1, order, imbalance);
    }

    /*
     *  functions called by traders on target chain
     */
    function requestCancelOrder(uint256 sourceChainId, uint256 orderId) external whenNotPaused {
        // order not exists on target chain !
        bytes32 _orderId = hashOrder(msg.sender, sourceChainId, orderId);
        require(swapOrderStatus[_orderId] == OrderStatus.NotSpecified, "BridgeVault: not a pending order");
        swapOrderStatus[_orderId] = OrderStatus.RequestCancel;
        emit RequestCancelOrder(msg.sender, sourceChainId, orderId, _orderId);
    }

    /*
     * troll helper functions
     */
    function assetPriceAgainstGovToken(address govTokenOracle, address assetTokenOracle) public view returns (uint256 price) {
        uint256 govTokenPrice = toUint256(PriceOracle(govTokenOracle).latestAnswer());
        require(govTokenPrice != 0, "govToken has price of 0");
        uint256 _assetPrice =  toUint256(PriceOracle(assetTokenOracle).latestAnswer());
        require(_assetPrice != 0, "asset has price of 0");
        price = govTokenPrice * 1e18 / _assetPrice;
        if (assetDecimalsScale != 0) {
            price = assetDecimalsScale > 0 ? (price * (10**uint8(assetDecimalsScale))) : (price / (10**uint8(-assetDecimalsScale)));
        }
    }
    // for the (withdrawal) actions that require enough govToken to be staked, find all the trolls and their combined staked balance
    function _verifyStakedValue(bytes[] calldata signatures, bytes32 paramsHash, uint256 stakeRequired) internal returns (uint256[] memory signers, uint256 totalStake) {
        uint256 superTrollCount;
        (superTrollCount, totalStake, signers) = vaultRegistry.verifyStakedValue(msg.sender, signatures, paramsHash);
        require(totalStake >= stakeRequired || superTrollCount == trollRegistry.superTrollCount(), "BridgeVault: not enough stakes");
    }

    /*
     *  functions called by trolls on source chain
     */
    function cancelOrder(bytes[] calldata signatures, uint256 orderId, bool canceledByOrderOwner, uint256 protocolFee) external whenNotPaused {
        Order storage order = orders[orderId];
        require(orderStatus[orderId] == OrderStatus.Pending || orderStatus[orderId] == OrderStatus.RequestAmend, "BridgeVault: cancel not requested");

        (/*router*/,address govTokenOracle, address assetTokenOracle, uint256 baseFee,/*transactionFee*/) = configStore.getBridgeParams(asset);
        uint256 price = assetPriceAgainstGovToken(govTokenOracle, assetTokenOracle);
        (uint256[] memory signers, /*uint256 totalStake*/) = _verifyStakedValue(signatures, hashCancelOrderParams(orderId, canceledByOrderOwner, protocolFee), order.inAmount * 1e18 / price);

        uint256 refundAmount = orders[orderId].inAmount;

        // charge user
        uint256 fee;
        if (canceledByOrderOwner) {
            fee = baseFee + protocolFee;
            refundAmount -= fee;
            imbalance -= toInt256(fee);
            protocolFeeBalance += fee;
        }

        orderRefunds[orderId] = refundAmount;
        orderStatus[orderId] = OrderStatus.RefundApproved;

        emit OrderCanceled(orderId, msg.sender, signers, canceledByOrderOwner, fee);
    }

    /*
     *  functions called by trolls on target chain
     */
    function swap(
        bytes[] calldata signatures,
        address _owner,
        uint256 _orderId,
        uint256 amendment,
        uint256 protocolFee,
        address[] calldata pair,
        Order calldata order
    ) external nonReentrant whenNotPaused returns (uint256 amount) {
        address router;
        // (router, amount) = _validateOnSwap(signatures, _owner, _orderId, amendment, protocolFee, pair, order);

        bytes32 orderId = hashOrder(_owner, order.peerChain, _orderId);
        amount = order.inAmount;

        // swapOrderStatus[orderId] should not exist on target chain yet
        require(swapOrderStatus[orderId] == OrderStatus.NotSpecified,"BridgeVault: Order already processed");
        require(trollRegistry.isSuperTroll(msg.sender, true), "not a super troll");
        require(lastKnownBalance() >= amount, "BridgeVault: insufficient balance");

        uint256 price;
        {
            uint256 fee;
            address govTokenOracle;
            address assetTokenOracle;
            uint256 baseFee;
            uint256 transactionFee; // lp's shares only
            (router, govTokenOracle, assetTokenOracle, baseFee, transactionFee) = configStore.getBridgeParams(asset);

            transactionFee = amount * transactionFee / 1e18;
            fee = transactionFee + baseFee + protocolFee;
            require(amount > fee, "Input amount too small");
            imbalance -= toInt256(amount);
            lpAssetBalance += transactionFee;
            protocolFeeBalance += baseFee + protocolFee;
            price = assetPriceAgainstGovToken(govTokenOracle, assetTokenOracle);
            amount = amount - fee;
        }
        (uint256[] memory signers, /*uint256 totalStake*/) = _verifyStakedValue(signatures, hashSwapParams(orderId, amendment, order, protocolFee, pair), amount * 1e18 / price);

        swapOrderStatus[orderId] = OrderStatus.Executed;

        if (pair.length == 0) {
            require(address(asset) == order.outToken, "Invalid token");
            require(amount >= order.minOutAmount, "INSUFFICIENT_OUTPUT_AMOUNT");
            IERC20(order.outToken).safeTransfer(order.to, amount);
        } else {
            address[] memory paths = IOSWAP_HybridRouter2(router).getPathIn(pair, address(asset));
            asset.safeIncreaseAllowance(address(router), amount);
            uint[] memory amounts;
            if (order.outToken == address(0)) {
                address WETH = IOSWAP_HybridRouter2(router).WETH();
                require(paths[paths.length-1] == WETH,"BridgeVault: Token out not match");
                (/*address[] memory path*/, amounts) = IOSWAP_HybridRouter2(router).swapExactTokensForETH(amount, order.minOutAmount, pair, order.to, order.expire, "0x00");
            } else {
                require(paths[paths.length-1] == order.outToken,"BridgeVault: Token out not match");
                (/*address[] memory path*/, amounts) = IOSWAP_HybridRouter2(router).swapExactTokensForTokens(amount, order.minOutAmount, pair, address(asset), order.to, order.expire, "0x00");
            }
            amount = amounts[amounts.length-1];
        }

        emit Swap(_orderId, msg.sender, signers, _owner, amendment, order, amount, imbalance);
    }

    function voidOrder(bytes[] calldata signatures, bytes32 orderId) external {
        require(swapOrderStatus[orderId] == OrderStatus.NotSpecified,"BridgeVault: Order already processed");
        (uint256[] memory signers, /*uint256 totalStake*/) = _verifyStakedValue(signatures, hashVoidOrderParams(orderId), 0);
        swapOrderStatus[orderId] == OrderStatus.Cancelled;
        emit VoidOrder(orderId, msg.sender, signers);
    }

    /*
     * rebalancing
     */
    function rebalancerDeposit(uint256 assetAmount) external nonReentrant {
        imbalance += toInt256(assetAmount);
        assetAmount = _transferAssetFrom(msg.sender, assetAmount);

        emit Rebalance(msg.sender, toInt256(assetAmount), imbalance);
    }
    function rebalancerWithdraw(bytes[] calldata signatures, uint256 assetAmount, uint256 _nonce) external nonReentrant {
        address rebalancer = configStore.rebalancer();
        vaultRegistry.verifyMinimumSignaturesAndNonce(msg.sender, signatures, hashWithdrawParams(rebalancer, assetAmount, _nonce), _nonce);
        imbalance -= toInt256(assetAmount);
        asset.safeTransfer(rebalancer, assetAmount);
        emit Rebalance(rebalancer, -toInt256(assetAmount), imbalance);
    }

    /*
     * anyone can call
     */
    function withdrawlTrollFee(uint256 amount) external nonReentrant whenNotPaused {
        require(amount <= protocolFeeBalance, "amount exceeded fee total");
        protocolFeeBalance -= amount;
        address feeTo = configStore.feeTo();
        asset.safeTransfer(feeTo, amount);
        emit WithdrawlTrollFee(feeTo, amount);
    }
    function sync() external {
        uint256 excess = asset.balanceOf(address(this)) - lastKnownBalance();
        protocolFeeBalance += excess;
        emit Sync(excess, protocolFeeBalance);
    }
}