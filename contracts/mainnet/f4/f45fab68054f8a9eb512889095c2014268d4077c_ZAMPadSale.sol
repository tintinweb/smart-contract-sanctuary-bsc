/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

// License-Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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


// File contracts/mocks/ZamMock.sol

// License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZamMock is ERC20 {
    constructor() ERC20("ZamToken", "ZAM") {

    }

    function mint(address to, uint256 amount) external {
      _mint(to, amount);
    }
}


// File contracts/interfaces/IAdmin.sol

//License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAdmin {
    function isAdmin(address user) external view returns (bool);
}


// File contracts/interfaces/IZAMStaking.sol

//License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IZamStaking {
    function userInfo(address user) external view returns (uint256, uint256);
}


// File @openzeppelin/contracts/utils/[email protected]

// License-Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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


// File @openzeppelin/contracts/utils/introspection/[email protected]

// License-Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC721/[email protected]

// License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}


// File contracts/sales/ZAMPadSale.sol

// License-Identifier: MIT
pragma solidity ^0.8.0;




contract ZAMPadSale {
    using SafeERC20 for IERC20;

    enum Belts { WHITE, YELLOW, ORANGE, GREEN, BLUE, BROWN, BLACK, RED, COUNT }
    enum Rounds { PREPARATION, WHITELIST, ROUND1, ROUND2, DISTRIBUTION, COUNT }

    struct Sale {
        // token to buy allocations
        IERC20 token;
        // is sale created
        bool isInitialized;
        // allocation total
        uint256 allocationTotal;
        // Total allocation being sold
        uint256 allocationSold;
    }

    // Round structure
    struct Round {
        // round start datetime
        uint256 startTime;
        // round end datetime
        uint256 endTime;
    }

    struct BeltPool {
        // ZAM needed to get belt
        uint256 minStakedZAM;
        // allocation total available by belt
        uint256 allocationTotal;
        // allocation sold by belt
        uint256 allocationSold;
        // registered users
        uint256 usersWithoutNft;
        // registered users with nft
        uint256 usersWithNft;
        // maximum guaranteed allocation wthout nft
        uint256 maxAllocationGuaranteedWithoutNft;
        // maximum guaranteed allocation wth nft
        uint256 maxAllocationGuaranteedWithNft;
    }

    // struct user detail
    struct RegisteredUser {
        Belts belt;
        uint256 stakedZAM;
        uint256 NFT;
        uint256 allocationBoughtAtRound1;
        uint256 allocationBoughtAtRound2;
    }

    // Sale
    Sale public sale;
    // Rounds
    Round[] public rounds;
    // Belts pools
    BeltPool[] public pools;
    // User details
    mapping(address => RegisteredUser) public registeredUsers;
    address[] private users;
    // Admin contract
    IAdmin public admin;
    // ZamStaking address
    IZamStaking public zamStaking;

    modifier onlyAdmin() {
        require(admin.isAdmin(msg.sender), "ZAMPadSale: Only admin can call this function");
        _;
    }

    modifier onlyAtPreparationTime() {
        require(rounds.length == 0 || block.timestamp < rounds[uint256(Rounds.PREPARATION)].endTime, "ZAMPadSale: Only preparation time");
        _;
    }

    modifier onlyAtWhitelistTime() {
        require(rounds.length == uint256(Rounds.COUNT), "ZAMPadSale: Rounds not set");
        require(block.timestamp >= rounds[uint256(Rounds.WHITELIST)].startTime &&
            block.timestamp < rounds[uint256(Rounds.WHITELIST)].endTime, "ZAMPadSale: Only whitelist time");
        _;
    }

    modifier onlyBetweenWhitelistAndRound1Time() {
        require(rounds.length == uint256(Rounds.COUNT), "ZAMPadSale: Rounds not set");
        require(block.timestamp >= rounds[uint256(Rounds.WHITELIST)].endTime &&
            block.timestamp < rounds[uint256(Rounds.ROUND1)].startTime, "ZAMPadSale: Only public sale time");
        _;
    }

    modifier onlyAtRound1Round2Time() {
        require(rounds.length == uint256(Rounds.COUNT), "ZAMPadSale: Rounds not set");
        require(block.timestamp >= rounds[uint256(Rounds.ROUND1)].startTime &&
            block.timestamp < rounds[uint256(Rounds.ROUND2)].endTime, "ZAMPadSale: Only public sale time");
        _;
    }

    modifier onlyAtDistributionTime() {
        require(rounds.length == uint256(Rounds.COUNT), "ZAMPadSale: Rounds not set");
        require(block.timestamp >= rounds[uint256(Rounds.DISTRIBUTION)].startTime, "ZAMPadSale: Only distribution time");
        _;
    }

    // Constructor, always initialized through SalesFactory
    constructor (address _admin) {
        require(_admin != address(0), "ZAMPadSale: Address incorrect");
        admin = IAdmin(_admin);
    }

    function setZamStaking(address _address) external onlyAdmin {
        require(_address != address(0), "ZAMPadSale: Address incorrect");
        zamStaking = IZamStaking(_address);
    }

    // Admin function to set sale parameters
    function initSale(address _token, uint256 _allocationTotal) external onlyAdmin {
        require(address(zamStaking) != address(0), "ZAMPadSale: zamStaking not set");
        require(!sale.isInitialized, "ZAMPadSale: Sale is already created");
        require(_allocationTotal != 0, "ZAMPadSale: Wrong allocation");

        // Set params
        sale.token = IERC20(_token);
        sale.isInitialized = true;
        sale.allocationTotal = _allocationTotal;
    }

    // Five rounds total:
    // 1. Preparation: The project is being under preparation. 
    // 2. Whitelist: Users can join the whitelist after completing the tasks to get Guaranteed Allocation.
    // 3. ROUND 1: Guaranteed registeredUsers can participate in the token sale. 
    // 4. ROUND 2: Sale of unredeemed tokens in the first round for 4–8 belts by model FCFS. 
    // 5. Distribution and Сlaim: Tokens are distributed among the participants of the sale.
    function setRounds(uint256[] calldata startTimes, uint256[] calldata endTimes) external onlyAdmin onlyAtPreparationTime {
        require(sale.isInitialized, "ZAMPadSale: Sale not initialized");
        require(startTimes.length == endTimes.length, "ZAMPadSale: Wrong params");
        require(startTimes.length == uint256(Rounds.COUNT), "ZAMPadSale: Wrong rounds count");
        require(startTimes.length > 0, "ZAMPadSale: Rounds count is not correct");

        delete rounds;
        
        for (uint256 i = 0; i < startTimes.length; i++) {
            require(startTimes[i] >= block.timestamp, "ZAMPadSale: start time can't be in past");
            require(startTimes[i] < endTimes[i], "ZAMPadSale: start time can't be less than end time");
            if (i >= 1)
                require(startTimes[i] >= endTimes[i - 1], "ZAMPadSale: start time has to be greater than prev round end time");

            Round memory round = Round(startTimes[i], endTimes[i]);

            rounds.push(round);
        }
    }

    function setPools(uint256[] calldata _minRates, uint256[] calldata _poolWeights) external onlyAdmin onlyAtPreparationTime {
        require(_minRates.length == uint256(Belts.COUNT), "ZAMPadSale: Wrong belts count");
        require(_minRates.length == _poolWeights.length, "ZAMPadSale: Bad input");

        delete pools;

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < _poolWeights.length; i++) {
            BeltPool memory pool = BeltPool(_minRates[i], (sale.allocationTotal * _poolWeights[i]) / 100, 0, 0, 0, 0, 0);

            pools.push(pool);

            totalWeight += _poolWeights[i];
        }
        require(totalWeight == 100, "ZAMPadSale: Wrong weights");
    }

    // Registration for sale
    function joinWhitelist(uint256 nftBalance) external onlyAtWhitelistTime {
        require(pools.length != 0, "ZAMPadSale: Pools not set");
        require(registeredUsers[msg.sender].stakedZAM == 0, "ZAMPadSale: User can't join whitelist twice");

        (uint256 staked,) = zamStaking.userInfo(msg.sender);

        Belts belt = getBeltByStaked(staked);
        require(belt != Belts.COUNT, "ZAMPadSale: Stake not enough to assign belt");

        if (nftBalance > 0)
            pools[uint256(belt)].usersWithNft += 1;
        else
            pools[uint256(belt)].usersWithoutNft += 1;

        registeredUsers[msg.sender].stakedZAM = staked;
        registeredUsers[msg.sender].NFT = nftBalance;
        registeredUsers[msg.sender].belt = belt;

        users.push(msg.sender);
    }

    function setNfts(address[] calldata _users, uint256[] calldata _counts) external onlyAdmin onlyBetweenWhitelistAndRound1Time {
        require(_users.length > 0 && _users.length == _counts.length, "ZamPadSale: Wrong data");
        for (uint256 i = 0; i < _users.length; i++) {
            registeredUsers[_users[i]].NFT = _counts[i];
        }
    }

    function calculateMaxAllocations(uint256[] memory guaranteedWithoutNft, uint256[] memory guaranteedWithNft) external onlyAdmin onlyBetweenWhitelistAndRound1Time {
        require(guaranteedWithoutNft.length == guaranteedWithNft.length, "ZamPadSale: Wrong data");
        require(guaranteedWithoutNft.length == uint256(Belts.COUNT), "ZamPadSale: Wrong length");

        for (uint256 i = 0; i < pools.length; i++) {
            BeltPool storage pool = pools[i];
            uint256 neededAllocation = (guaranteedWithoutNft[i] * pool.usersWithoutNft) + (guaranteedWithNft[i] * pool.usersWithNft);
            if (neededAllocation > pool.allocationTotal) {
                uint256 multiplier = pool.allocationTotal / neededAllocation;
                pool.maxAllocationGuaranteedWithoutNft = guaranteedWithoutNft[i] * multiplier;
                pool.maxAllocationGuaranteedWithNft = guaranteedWithNft[i] * multiplier;
            } else {
                pool.maxAllocationGuaranteedWithoutNft = guaranteedWithoutNft[i];
                pool.maxAllocationGuaranteedWithNft = guaranteedWithNft[i];
            }
        }
    }

    // Function to participate in the sales
    function participate(uint256 amount) external onlyAtRound1Round2Time {
        require(pools.length != 0, "ZAMPadSale: Pools not set");
        require(amount > 0, "ZAMPadSale: Wrong amount");
        // Check available allocations
        require((sale.allocationSold + amount) <= sale.allocationTotal, "ZAMPadSale: Not enough allocation");
        // Check token available
        require(sale.token.allowance(msg.sender, address(this)) >= amount, "ZAMPadSale: Wrong allowance");
        // User must have registered for the
        require(registeredUsers[msg.sender].stakedZAM > 0, "ZAMPadSale: Not registered for thih white list");

        uint256 maxAvailableAllocationAtRound1 = registeredUsers[msg.sender].NFT > 0
            ? pools[uint256(registeredUsers[msg.sender].belt)].maxAllocationGuaranteedWithNft
            : pools[uint256(registeredUsers[msg.sender].belt)].maxAllocationGuaranteedWithoutNft;

        if (block.timestamp < rounds[uint256(Rounds.ROUND1)].endTime) {
            require(registeredUsers[msg.sender].allocationBoughtAtRound1 + amount <= maxAvailableAllocationAtRound1,
                "ZAMPadSale: Incorrect number of allocations to participate in this round");
            pools[uint256(registeredUsers[msg.sender].belt)].allocationSold = pools[uint256(registeredUsers[msg.sender].belt)].allocationSold + amount;
            registeredUsers[msg.sender].allocationBoughtAtRound1 = registeredUsers[msg.sender].allocationBoughtAtRound1 + amount;
        } else if (block.timestamp >= rounds[uint256(Rounds.ROUND2)].startTime) {
            require(registeredUsers[msg.sender].allocationBoughtAtRound1 == maxAvailableAllocationAtRound1,
                "ZAMPadSale: User can't participate at round");
            (uint256 i, uint256 sz) = getAvailablePoolsId(msg.sender);
            uint256 notFilled = amount;
            // WHITE, YELLOW, ORANGE, GREEN can buy not bought BLUE, BROWN, BLACK, RED, COUNT allocation and vice versa  
            for (i; i < i + sz; ++i) {
                pools[i].allocationSold = pools[i].allocationSold + notFilled;
                if (pools[i].allocationSold > pools[i].allocationTotal) {
                    notFilled = pools[i].allocationSold - pools[i].allocationTotal;
                    pools[i].allocationSold = pools[i].allocationTotal;
                } else {
                    notFilled = 0;
                    break;
                }
            }
            require(notFilled == 0, "ZAMPadSale: Not enough allocation");
            registeredUsers[msg.sender].allocationBoughtAtRound2 = registeredUsers[msg.sender].allocationBoughtAtRound2 + amount;
        } else {
            revert("ZAMPadSale: Round not started");
        }

        // Increase amount of sold tokens
        sale.allocationSold = sale.allocationSold + amount;

        sale.token.safeTransferFrom(msg.sender, address(this), amount);
    }

    // TODO onlyAdmin???
    function withdraw(address creator) external onlyAdmin onlyAtDistributionTime {
        sale.token.safeTransfer(creator, sale.allocationSold);
    }

    function getAvailableAllocationAtRound2(address participant) external view returns (uint256) {
        (uint256 i, uint256 sz) = getAvailablePoolsId(participant);
        uint256 availableAllocationAtRound2;
        // WHITE, YELLOW, ORANGE, GREEN can buy not bought BLUE, BROWN, BLACK, RED, COUNT allocation and vice versa  
        for (i; i < i + sz; ++i) {
            availableAllocationAtRound2 += pools[i].allocationTotal - pools[i].allocationSold;
        }
        return availableAllocationAtRound2;
    }

    function getRounds() external view returns (Round[] memory) {
        return rounds;
    }

    function getRoundsCount() external view returns (uint256) {
        return rounds.length;
    }

    function getCurrentRound() external view returns (uint256 roundId) {
        roundId = uint256(Rounds.COUNT);
        for (uint256 i = 0; i < rounds.length; ++i) {
            if (block.timestamp >= rounds[i].startTime && block.timestamp < rounds[i].endTime) {
                roundId = i;
                break;
            }
        }
    }

    function getPools() external view returns (BeltPool[] memory) {
        return pools;
    }

    function getPoolsCount() external view returns (uint256) {
        return pools.length;
    }

    function getRegisteredUsers(uint256 start, uint256 count) external onlyAdmin view returns (RegisteredUser[] memory) {
        RegisteredUser[] memory _users =  new RegisteredUser[](count);
        for (uint256 i = start; start <= start + count; ++i) {
            RegisteredUser memory d = registeredUsers[users[i]];
            _users[i] = d;
        }
        return _users;
    }

    function getRegisteredUsersCount() external view returns (uint256) {
        return users.length;
    }

    function getBelt(address user) external view returns (Belts belt) {
        (uint256 staked,) = zamStaking.userInfo(user);
        belt = getBeltByStaked(staked);
    }

    function getBeltByStaked(uint256 staked) internal view returns (Belts belt) {
        belt = Belts.COUNT;
        for(uint256 i = 0; i < uint256(Belts.COUNT); i++) {
            if (staked >= pools[i].minStakedZAM) {
                belt = Belts(i);
            } else {
                break;
            }
        }
    }

    function getAvailablePoolsId(address participant) internal view returns (uint256 i, uint256 count) {
        count = (uint256(Belts.COUNT) / 2);
        i = uint256(registeredUsers[participant].belt) < count ? count : 0;
    }

}


// File contracts/sales/SalesFactory.sol

// "License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;


contract SalesFactory {

    IAdmin public admin;

    mapping(address => bool) public isSaleCreatedByFactory;

    address[] public sales;

    event SaleDeployed(address saleContract);

    modifier onlyAdmin {
        require(admin.isAdmin(msg.sender), "SalesFactory: Only Admin can deploy sales");
        _;
    }

    constructor (address _adminContract) {
        admin = IAdmin(_adminContract);
    }

    function createSale() external onlyAdmin {
        ZAMPadSale sale = new ZAMPadSale(address(admin));
        isSaleCreatedByFactory[address(sale)] = true;
        sales.push(address(sale));
        emit SaleDeployed(address(sale));
    }

    // Function to return number of pools deployed
    function getSalesCount() external view returns (uint) {
        return sales.length;
    }

}


// File contracts/Admin.sol

//License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Admin {

    uint256 public possibleAdminsCount = 2;

    // Listing all admins
    address[] public admins;

    mapping(address => bool) public isAdmin;

    // Modifier restricting access to only admin
    modifier onlyAdmin {
        require(isAdmin[msg.sender], "Admin: Only admin can call");
        _;
    }

    // Constructor to set initial admins during deployment
    constructor (address[] memory _admins) {
        require(_admins.length <= possibleAdminsCount, "Admin: not possible admins count");
        for(uint i = 0; i < _admins.length; i++) {
            admins.push(_admins[i]);
            isAdmin[_admins[i]] = true;
        }
    }

    function addAdmin(address _address) external onlyAdmin {
        require(admins.length < possibleAdminsCount, "Admin: max admins count reached");
        // Can't add 0x address as an admin
        require(_address != address(0x0), "Admin: Zero address given");
        // Can't add existing admin
        require(!isAdmin[_address], "Admin: Admin already exists");
        // Add admin to array of admins
        admins.push(_address);
        // Set mapping
        isAdmin[_address] = true;
    }

    function removeAdmin(address _address) external onlyAdmin {
        require(isAdmin[_address], "Admin: admin is not exist");
        require(admins.length > 1, "Admin: Can't remove all admins since contract becomes unusable");

        for (uint256 i = 0; i < admins.length; ++i) {
            if (admins[i] == _address) {
                isAdmin[_address] = false;
                admins[i] = admins[admins.length - 1];
                admins.pop();
                break;
            }
        }
    }

    function getAdminsCount() external view returns (uint256) {
        return admins.length;
    }

    // Fetch all admins
    function getAllAdmins() external view returns (address [] memory) {
        return admins;
    }

}


// File contracts/mocks/ZamStakingMock.sol

// License-Identifier: MIT
pragma solidity ^0.8.0;


contract ZamStakingMock {

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => UserInfo) public userInfo;

    constructor () {

    }

    function deposit(uint256 _amount) external {
        userInfo[msg.sender].amount = _amount;
    }

}