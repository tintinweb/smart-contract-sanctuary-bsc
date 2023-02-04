/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// File: ../leveraged/contracts/libraries/Context.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

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

// File: ../leveraged/contracts/access/Ownable.sol



pragma solidity ^0.8.10;


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

// File: ../leveraged/contracts/interfaces/IBEP20.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface of the BEP-20 standard as defined in the EIP.
 */
interface IBEP20 {
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

// File: ../leveraged/contracts/token/BEP20.sol



pragma solidity ^0.8.10;



/**
 * @dev Interface for the optional metadata functions from the BEP-20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
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

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-s-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP-20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, IBEP20Metadata {
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
     * Ether and Wei. This is the value {BEP-20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
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
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
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
     * problems described in {IBEP20-approve}.
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
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
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
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
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
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

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

// File: ../leveraged/contracts/libraries/Address.sol



pragma solidity ^0.8.10;

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

// File: ../leveraged/contracts/libraries/SafeBEP20.sol



pragma solidity ^0.8.10;



/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// File: ../leveraged/contracts/libraries/PRBMath.sol

pragma solidity ^0.8.10;



/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

/// @notice Emitted when one of the inputs is type(int256).min.
error PRBMath__MulDivSignedInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows int256.
error PRBMath__MulDivSignedOverflow(uint256 rAbs);

/// @notice Emitted when the input is MIN_SD59x18.
error PRBMathSD59x18__AbsInputTooSmall();

/// @notice Emitted when ceiling a number overflows SD59x18.
error PRBMathSD59x18__CeilOverflow(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__DivInputTooSmall();

/// @notice Emitted when one of the intermediary unsigned results overflows SD59x18.
error PRBMathSD59x18__DivOverflow(uint256 rAbs);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathSD59x18__ExpInputTooBig(int256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathSD59x18__Exp2InputTooBig(int256 x);

/// @notice Emitted when flooring a number underflows SD59x18.
error PRBMathSD59x18__FloorUnderflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMathSD59x18__FromIntOverflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMathSD59x18__FromIntUnderflow(int256 x);

/// @notice Emitted when the product of the inputs is negative.
error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

/// @notice Emitted when multiplying the inputs overflows SD59x18.
error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

/// @notice Emitted when the input is less than or equal to zero.
error PRBMathSD59x18__LogInputTooSmall(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__MulInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__MulOverflow(uint256 rAbs);

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

/// @notice Emitted when the input is negative.
error PRBMathSD59x18__SqrtNegativeInput(int256 x);

/// @notice Emitted when the calculating the square root overflows SD59x18.
error PRBMathSD59x18__SqrtOverflow(int256 x);

/// @notice Emitted when addition overflows UD60x18.
error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

/// @notice Emitted when ceiling a number overflows UD60x18.
error PRBMathUD60x18__CeilOverflow(uint256 x);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathUD60x18__ExpInputTooBig(uint256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format format overflows UD60x18.
error PRBMathUD60x18__FromUintOverflow(uint256 x);

/// @notice Emitted when multiplying the inputs overflows UD60x18.
error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

/// @notice Emitted when the input is less than 1.
error PRBMathUD60x18__LogInputTooSmall(uint256 x);

/// @notice Emitted when the calculating the square root overflows UD60x18.
error PRBMathUD60x18__SqrtOverflow(uint256 x);

/// @notice Emitted when subtraction underflows UD60x18.
error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

/// @dev Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
/// representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library PRBMath {
    /// STRUCTS ///

    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }

    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    /// @dev Has to use 192.64-bit fixed-point numbers.
    /// See https://ethereum.stackexchange.com/a/96594/24693.
    /// @param x The exponent as an unsigned 192.64-bit fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // Start from 0.5 in the 192.64-bit fixed-point format.
            result = 0x800000000000000000000000000000000000000000000000;

            // Multiply the result by root(2, 2^-i) when the bit at position i is 1. None of the intermediary results overflows
            // because the initial result is 2^191 and all magic factors are less than 2^65.
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            // We're doing two things at the same time:
            //
            //   1. Multiply the result by 2^n + 1, where "2^n" is the integer part and the one is added to account for
            //      the fact that we initially set the result to 0.5. This is accomplished by subtracting from 191
            //      rather than 192.
            //   2. Convert the result to the unsigned 60.18-decimal fixed-point format.
            //
            // This works because 2^(191-ip) = 2^ip / 2^191, where "ip" is the integer part "2^n".
            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    /// @notice Finds the zero-based index of the first one in the binary representation of x.
    /// @dev See the note on msb in the "Find First Set" Wikipedia article https://en.wikipedia.org/wiki/Find_first_set
    /// @param x The uint256 number for which to find the index of the most significant bit.
    /// @return msb The index of the most significant bit as an uint256.
    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number.
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev An extension of "mulDiv" for signed numbers. Works by computing the signs and the absolute values separately.
    ///
    /// Requirements:
    /// - None of the inputs can be type(int256).min.
    /// - The result must fit within int256.
    ///
    /// @param x The multiplicand as an int256.
    /// @param y The multiplier as an int256.
    /// @param denominator The divisor as an int256.
    /// @return result The result as an int256.
    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {
        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        // Get hold of the absolute values of x, y and the denominator.
        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        // Compute the absolute value of (x*y)÷denominator. The result must fit within int256.
        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        // Get the signs of x, y and the denominator.
        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        // XOR over sx, sy and sd. This is checking whether there are one or three negative signs in the inputs.
        // If yes, the result should be negative.
        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the least power of two that is greater than or equal to sqrt(x).
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}

// File: ../leveraged/contracts/interfaces/ILeveragedVault.sol



pragma solidity ^0.8.10;

// the address used to identify BNB
address constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

/**
* @dev Interface for a LeveragedVault contract
 **/

interface ILeveragedVault {
    struct LPPosition {
        address lpToken; // the address of liquidity provider token (liquidity pool address)
        uint256 amount; // the amount of lp tokens
        address borrowedAsset; // the address of the borrowed asset
        uint256 borrowedAmount; // the amount of debt
        uint256 averageInterestRate; // the average interest rate
        uint256 farmingRewardIndex; // the cumulative farming reward index
        address user; // the address of the user
        uint256 timestamp; // last operation timestamp
        uint256 prevLPPositionId; // id of previous LP position
        uint256 prevUserLPPositionId; // id of previous LP position of the user
        uint256 nextLPPositionId; // id of next LP position
        uint256 nextUserLPPositionId; // id of next LP position of the user
        bool isOpen;
    }

    function getAssetDecimals(address _asset) external view returns (uint256);
    function getAssetITokenAddress(address _asset) external view returns (address);
    function getAssetTotalLiquidity(address _asset) external view returns (uint256);
    function getUserAssetBalance(address _asset, address _user) external view returns (uint256);
    function getLPPositionDebt(uint256 _lpPositionId) external view returns (uint256);
    function getLPPositionAmount(uint256 lpPositionId) external view returns (uint256);
    function getLPToken(uint256 lpPositionId) external view returns (address);
    function lpPositionIsOpen(uint256 lpPositionId) external view returns (bool);
    function getLPPositionBorrowedAsset(uint256 lpPositionId) external view returns (address);
    function getLPPosition(uint256 lpPositionId) external view returns (LPPosition memory);
    function getAssetInterestRate(address _asset) external view returns (uint256);
    function getFarmPoolTotalValue(address _asset) external view returns (uint256);
    function getAssets() external view returns (address[] memory);
    function openPosition(address _lpToken, address _borrowedAsset, uint256 _lpPositionAmount, uint256 _borrowedAmount, address _user) external;
    function closePosition(uint256 _lpPositionId, uint256 _lpTokenAmount) external;
    function updateMarginBorrowBalance(uint256 _lpPositionId, uint256 _newBorrowedAmount) external;
    function updateTotalCollateralBalance(address _asset) external;
    function transferToVault(address _asset, address payable _depositor, uint256 _amount) external;
    function transferToUser(address _asset, address payable _user, uint256 _amount) external;
    function transferToRouter(address _asset, uint256 _amount) external;
    function transferFromUserToRouter(address _asset, address payable _user, uint256 _amount) external;
    function updatePlatformProfitAndLiquidityIndexLog2(address _asset) external;
    function cumulatedAmount(address _asset, uint256 _storedAmount) external view returns (uint256);
    function storedAmount(address _asset, uint256 _cumulatedAmount) external view returns (uint256);
    function storedPlatformProfit(address _asset) external view returns (uint256);
    function getFullPlatformProfit(address _asset) external view returns (uint256);

    receive() external payable;
}

// File: ../leveraged/contracts/interfaces/IRouter.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a router contract.
 */
interface IRouter {
    function setMockFarmPoolTotalValueInUSD(uint256 newFarmPoolTotalValueInUSD) external;
    function getFarmPoolTotalValueInUSD(address _lpToken) external view returns (uint256);
    function getTokens(address _lpToken) external view returns (address token0, address token1);
    function transferToVault(address _asset, uint256 _amount) external;
    function transferToUser(address _asset, address payable _user, uint256 _amount) external;
    function swap(address _fromAsset, address _toAsset, uint256 _amount) external returns (uint amountOut);
    function calcMargin(address _fromAsset, address _toAsset, uint256 _amount) external view returns (uint amountOut);
    function addLiquidity(address _lpToken, address _borrowedAsset, uint256 _amount) external returns (uint256 liquidity);
    function withdrawal(address _lpToken, uint256 _amount, address _borrowedAsset) external returns (uint256 withdrawnAmount);
    function getLPPositionInUSD(address _lpToken, uint256 _amount) external view returns (uint256 lpPositionInUSD);

    receive() external payable;
}

// File: ../leveraged/contracts/interfaces/ISwapRouter.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a PancakeRouter.
 * @notice Functions of interaction with the PancakeRouter
 */
interface ISwapRouter {
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

// File: ../leveraged/contracts/interfaces/IPancakePair.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a PancakePair.
 * @notice Functions of interaction with the PancakePair
 */
interface IPancakePair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function approve(address spender, uint256 value) external returns (bool);
    function factory() external view returns (address);
    function kLast() external view returns (uint256);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// File: ../leveraged/contracts/interfaces/IPancakeFactory.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a PancakeFactory.
 * @notice Functions of interaction with the PancakeFactory
 */
interface IPancakeFactory {
    function feeTo() external view returns (address);
}

// File: ../leveraged/contracts/interfaces/IPriceOracle.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a price oracle.
 */
interface IPriceOracle {
    function getPrice(address _asset) external view returns (uint256);
}

// File: ../leveraged/contracts/mocks/MockRouter.sol



pragma solidity ^0.8.10;











/**
* @title Mock Router contract
* @dev Implements functions to transfer assets from Vault contract to external protocols and back.
**/
contract MockRouter is IRouter, Ownable {
    using SafeBEP20 for BEP20;
    using Address for address;

    ILeveragedVault public vault;
    ISwapRouter public swapRouter;
    IPriceOracle public priceOracle;

    uint256 mockFarmPoolTotalValueInUSD;

    mapping(string => address) public tokens;
    mapping(address => bool) public pancakeLPPools;

    address public masterChefContractAddress;

    /**
    * @dev only MasterChef contract can use functions affected by this modifier
    **/
    modifier onlyMasterChefContract {
        require(masterChefContractAddress == msg.sender, "The caller must be a MasterChef contract");
        _;
    }

    constructor(
        address payable _vault,
        address _swapRouter,
        address _priceOracle
    ) {
        vault = ILeveragedVault(_vault);
        swapRouter = ISwapRouter(_swapRouter);
        priceOracle = IPriceOracle(_priceOracle);
        mockFarmPoolTotalValueInUSD = 100000 * 10**8;
    }

    function setMockFarmPoolTotalValueInUSD(uint256 newFarmPoolTotalValueInUSD) external onlyOwner {
        mockFarmPoolTotalValueInUSD = newFarmPoolTotalValueInUSD;
    }

    function getFarmPoolTotalValueInUSD(address _lpToken) external view returns (uint256) {
        return mockFarmPoolTotalValueInUSD;
    }

    function getTokens(address _lpToken) external view
        returns (
            address token0,
            address token1
        )
    {
        if (pancakeLPPools[_lpToken]) {
            IPancakePair pair = IPancakePair(_lpToken);
            token0 = pair.token0();
            token1 = pair.token1();
            token0 = token0 == swapRouter.WETH() ? BNB_ADDRESS : token0;
            token1 = token1 == swapRouter.WETH() ? BNB_ADDRESS : token1;
        } else if (_lpToken == 0x014608E87AF97a054C9a49f81E1473076D51d9a3) { // MATIC-BNB
            token0 = tokens['MATIC'] == address(0) ? 0x96029C3Bc6Ea39601bF086Ce3554c7830205aF91 : tokens['MATIC'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x1CEa83EC5E48D9157fCAe27a19807BeF79195Ce1) { // CAKE-BNB
            token0 = tokens['CAKE'] == address(0) ? 0x9B61855fed421F0BCF49728C2Cf45d62b7dbe3EF : tokens['CAKE'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4) { // CAKE-USDT
            token0 = tokens['CAKE'] == address(0) ? 0x9B61855fed421F0BCF49728C2Cf45d62b7dbe3EF : tokens['CAKE'];
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0xe267018C943E77992e7e515724B07b9CE7938124) { // CAKE-BUSD
            token0 = tokens['CAKE'] == address(0) ? 0x9B61855fed421F0BCF49728C2Cf45d62b7dbe3EF : tokens['CAKE'];
            token1 = tokens['BUSD'] == address(0) ? 0x2184110dd6886cd2B1F1CCD0870DaB819152be30 : tokens['BUSD'];
        } else if (_lpToken == 0xc736cA3d9b1E90Af4230BD8F9626528B3D4e0Ee0) { // GMT-USDT
            token0 = tokens['GMT'] == address(0) ? 0xC6614716abfEBc1179B38730F709E90AE6d25CF6 : tokens['GMT'];
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0x352008bf4319c3B7B8794f1c2115B9Aa18259EBb) { // XRP-BNB
            token0 = tokens['XRP'] == address(0) ? 0x29ba6CaEEF999ffB47afc34d947Dd42b6e659504 : tokens['XRP'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x2407A09D25F8b72c8838A56b4100Ce600fbFA4ed) { // BNB-USDT
            token0 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0xc803790dD1a234b326Cd4E593b05337a0c84a05e) { // FIL-USDT
            token0 = tokens['FIL'] == address(0) ? 0x86366e304Fed8306d83c6F341f1f209097476A44 : tokens['FIL'];
            token1 = tokens['USDT'] == address(0) ? 0x6EE6727b9E04cA1a5E1E45992Cf5FD4345625687 : tokens['USDT'];
        } else if (_lpToken == 0xD254a3C351DAd83F8B369554B420047A1ED60f1C) { // SFP-BNB
            token0 = tokens['SFP'] == address(0) ? 0x9b265f7548735752De4ae0Ae8acD07A9a8224a59 : tokens['SFP'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x51dCAF423FE39F620A13379Cd26821cF8d433308) { // DOGE-BNB
            token0 = tokens['DOGE'] == address(0) ? 0xF7a5fC580C20288dd09Dd3a40D6687053198766C : tokens['DOGE'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0xe7987f07C01B6CA83971E8407D67CAfB3193619c) { // TWT-BNB
            token0 = tokens['TWT'] == address(0) ? 0x9f6FfE5b9d02D57080F373c756cA92aF8eF7Af1D : tokens['TWT'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0xB450CBF17F6723Ef9c1bf3C3f0e0aBA368D09bF5) { // SXP-BNB
            token0 = tokens['SXP'] == address(0) ? 0x6468d3c0D1f18E54591F8D628c0109D8fF1D8829 : tokens['SXP'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0xED2eC734193626282e105A4A44bf39C1F6B44d78) { // DOT-BNB
            token0 = tokens['DOT'] == address(0) ? 0x33DEd922C79E76A116D0cA35C2e328a87E22eEAe : tokens['DOT'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else if (_lpToken == 0x007A5E4e2C6D377852e843a6d624120af450A073) { // BNB-BUSD
            token0 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            token1 = tokens['BUSD'] == address(0) ? 0x2184110dd6886cd2B1F1CCD0870DaB819152be30 : tokens['BUSD'];
        } else if (_lpToken == 0x78B7220f37B8F6e30d03018558B0C8c4430662C7) { // MBOX-BNB
            token0 = tokens['MBOX'] == address(0) ? 0xaA9a8283EAaaFF785aC5658706c3D11DF81Dc6d2 : tokens['MBOX'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        } else { // XVS-BNB
            token0 = tokens['XVS'] == address(0) ? 0x0f950A6ddDC12E3ECa0F0f5d4f16A5D35b3Fa54F : tokens['XVS'];
            token1 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        }
    }

    /**
    * @dev sets the token address
    * @param _tokenName the token name
    * @param _tokenAddress the token address
    **/
    function setToken(
        string memory _tokenName,
        address _tokenAddress
    ) external onlyOwner {
        tokens[_tokenName] = _tokenAddress;
    }

    /**
    * @dev adds the pancake LP pool address
    * @param _lpToken the LP token address
    **/
    function addPancakeLPPool(
        address _lpToken
    ) external onlyOwner {
        pancakeLPPools[_lpToken] = true;
    }

    /**
    * @dev sets masterChefContractAddress
    * @param _newMasterChefContract the address of the MasterChef contract
    **/
    function setMasterChefContract(address _newMasterChefContract) external onlyOwner {
        masterChefContractAddress = _newMasterChefContract;
    }

    /**
    * @dev transfers to the LeveragedVault contract a specific amount of asset from the MockRouter contract.
    * @param _asset the address of the asset
    * @param _amount the amount being transferred
    **/
    function transferToVault(address _asset, uint256 _amount) external onlyMasterChefContract {
        if (_asset == BNB_ADDRESS) {
            payable(address(vault)).transfer(_amount);
        } else {
            BEP20(_asset).safeTransfer(payable(address(vault)), _amount);
        }
    }

    /**
    * @dev transfers to the user a specific amount of asset from the Router contract.
    * @param _asset the address of the asset
    * @param _user the address of the user receiving the transfer
    * @param _amount the amount being transferred
    **/
    function transferToUser(address _asset, address payable _user, uint256 _amount) external onlyMasterChefContract {
        if (_asset == BNB_ADDRESS) {
            _user.transfer(_amount);
        } else {
            BEP20(_asset).safeTransfer(_user, _amount);
        }
    }

    /**
    * @dev fallback function enforces that the caller is a contract
    **/
    receive() external payable {  }

    /**
    * @dev reserve withdraw of assets (remains for the duration of the protocol development)
    * @param _asset the address of the asset
    * @param _amount the asset amount being withdraw
    **/
    function reserveWithdraw(address _asset, uint256 _amount)
        external
        onlyOwner
    {
        if (_asset == BNB_ADDRESS) {
            payable(msg.sender).transfer(_amount);
        } else {
            BEP20(_asset).safeTransfer(msg.sender, _amount);
        }
    }

    /**
    * @dev swaps input asset by PancakeRouter
    * @param _fromAsset the address of the incoming asset
    * @param _toAsset the address of the outgoing asset
    * @param _amount the amount of asset to be swapped
    * @return amountOut the amount of asset received after swap
    **/
    function swap(address _fromAsset, address _toAsset, uint256 _amount)
        public
        onlyMasterChefContract
        returns (uint256 amountOut)
    {
        address[] memory path = new address[](2);
        uint256[] memory amountsOut;

        if (_fromAsset == BNB_ADDRESS) {
            path[0] = swapRouter.WETH();
            path[1] = _toAsset;

            // execute the swap
            amountsOut =  swapRouter.swapExactETHForTokens{value: _amount}(
                0,
                path,
                address(this),
                block.timestamp + 60
            );
        } else if (_toAsset == BNB_ADDRESS) {
            path[0] = _fromAsset;
            path[1] = swapRouter.WETH();

            BEP20(_fromAsset).approve(address(swapRouter), _amount);

            // execute the swap
            amountsOut =  swapRouter.swapExactTokensForETH(
                _amount,
                0,
                path,
                address(this),
                block.timestamp + 60
            );
        } else {
            path[0] = _fromAsset;
            path[1] = _toAsset;

            BEP20(_fromAsset).approve(address(swapRouter), _amount);

            // execute the swap
            amountsOut = swapRouter.swapExactTokensForTokens(
                _amount,
                0,
                path,
                address(this),
                block.timestamp + 60
            );
        }

        amountOut = amountsOut[amountsOut.length - 1];
    }

    /**
    * @dev calculates the amount of outgoing asset after swap by PancakeRouter
    * @param _fromAsset the address of the incoming asset
    * @param _toAsset the address of the outgoing asset
    * @param _amount the amount of asset to be swapped
    * @return amountOut the amount of the asset that can be received after the swap
    **/
    function calcMargin(address _fromAsset, address _toAsset, uint256 _amount)
        external
        view
        returns (uint256 amountOut)
    {
        address[] memory path = new address[](2);
        uint256[] memory amountsOut;

        if (_fromAsset == BNB_ADDRESS) {
            path[0] = swapRouter.WETH();
            path[1] = _toAsset;
        } else if (_toAsset == BNB_ADDRESS) {
            path[0] = _fromAsset;
            path[1] = swapRouter.WETH();
        } else {
            path[0] = _fromAsset;
            path[1] = _toAsset;
        }

        amountsOut = swapRouter.getAmountsOut(
            _amount,
            path
        );

        amountOut = amountsOut[amountsOut.length - 1];
    }

    /**
    * @dev adds liquidity to the LP pool
    * @param _lpToken the address of liquidity provider token
    * @param _borrowedAsset the address of the borrowed asset
    * @param _amount the asset amount being transferred to the LP pool
    * @return liquidity the amount of the liquidity provider token
    **/
    function addLiquidity(address _lpToken, address _borrowedAsset, uint256 _amount)
        external
        onlyMasterChefContract
        returns (uint256 liquidity)
    {
        IPancakePair pair = IPancakePair(_lpToken);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address asset0 = token0 == swapRouter.WETH() ? BNB_ADDRESS : token0;
        address asset1 = token1 == swapRouter.WETH() ? BNB_ADDRESS : token1;

        uint256 amountToken0;
        if (_borrowedAsset != asset0) {
            amountToken0 = swap(_borrowedAsset, token0 == swapRouter.WETH() ? BNB_ADDRESS : token0, _amount / 2);
        } else {
            amountToken0 = _amount / 2;
        }

        uint256 amountToken1;
        if (_borrowedAsset != asset1) {
            amountToken1 = swap(_borrowedAsset, token1 == swapRouter.WETH() ? BNB_ADDRESS : token1, _amount / 2);
        } else {
            amountToken1 = _amount / 2;
        }

        if (token0 != swapRouter.WETH() && token1 != swapRouter.WETH()) {
            BEP20(token0).approve(address(swapRouter), amountToken0);
            BEP20(token1).approve(address(swapRouter), amountToken1);

            (, , liquidity) = swapRouter.addLiquidity(
                token0,
                token1,
                amountToken0,
                amountToken1,
                0,
                0,
                address(this),
                block.timestamp + 60
            );
        } else {
            if (token0 == swapRouter.WETH()) {
                BEP20(token1).approve(address(swapRouter), amountToken1);
            } else {
                BEP20(token0).approve(address(swapRouter), amountToken0);
            }

            (, , liquidity) = swapRouter.addLiquidityETH{value: (token0 == swapRouter.WETH()) ? amountToken0 : amountToken1}(
                token0 == swapRouter.WETH() ? token1 : token0,
                token0 == swapRouter.WETH() ? amountToken1 : amountToken0,
                0,
                0,
                address(this),
                block.timestamp + 60
            );
        }
    }

    /**
    * @dev withdraws borrowed asset from the LP pool to router
    * @param _lpToken the address of liquidity provider token
    * @param _amount the amount of the asset withdrawn from the LP pool
    * @param _borrowedAsset the address of the borrowed asset
    * @return withdrawnAmount the amount of the withdrawn asset
    **/
    function withdrawal(address _lpToken, uint256 _amount, address _borrowedAsset)
        external
        onlyMasterChefContract
        returns (uint256 withdrawnAmount)
    {
        IPancakePair pair = IPancakePair(_lpToken);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address asset0 = token0 == swapRouter.WETH() ? BNB_ADDRESS : token0;
        address asset1 = token1 == swapRouter.WETH() ? BNB_ADDRESS : token1;

        pair.approve(address(swapRouter), _amount);
        if (asset0 != BNB_ADDRESS && asset1 != BNB_ADDRESS) {
            (uint256 amountToken0, uint256 amountToken1) = swapRouter.removeLiquidity(
                token0,
                token1,
                _amount,
                0,
                0,
                address(this),
                block.timestamp + 60
            );

            if (_borrowedAsset != asset0) {
                withdrawnAmount += swap(token0, _borrowedAsset, amountToken0);
            } else {
                withdrawnAmount += amountToken0;
            }

            if (_borrowedAsset != asset1) {
                withdrawnAmount += swap(token1, _borrowedAsset, amountToken1);
            } else {
                withdrawnAmount += amountToken1;
            }
        } else {
            address token = asset0 == BNB_ADDRESS ? token1 : token0;

            (uint256 amountToken, uint256 amountBNB) = swapRouter.removeLiquidityETH(
                token,
                _amount,
                0,
                0,
                address(this),
                block.timestamp + 60
            );

            if (_borrowedAsset != token) {
                withdrawnAmount += swap(token, _borrowedAsset, amountToken);
            } else {
                withdrawnAmount += amountToken;
            }

            if (_borrowedAsset != BNB_ADDRESS) {
                withdrawnAmount += swap(BNB_ADDRESS, _borrowedAsset, amountBNB);
            } else {
                withdrawnAmount += amountBNB;
            }
        }
    }

    /**
    * @dev gets amount of the LP position in USD
    * @param _lpToken the address of liquidity provider token
    * @param _amount the amount of the LP token
    * @return lpPositionInUSD the amount of the LP position in USD
    **/
    function getLPPositionInUSD(address _lpToken, uint256 _amount)
        external
        view
        returns (uint256 lpPositionInUSD)
    {
        IPancakePair pair = IPancakePair(_lpToken);
        address token0 = pair.token0();
        address token1 = pair.token1();

        uint256 _totalSupply = pair.totalSupply(); // gas savings

        // if fee is on, mint liquidity equivalent to 8/25 of the growth in sqrt(k)
        // https://github.com/pancakeswap/pancake-smart-contracts/blob/master/projects/exchange-protocol/contracts/PancakePair.sol#L90
        if (IPancakeFactory(pair.factory()).feeTo() != address(0)) {
            uint256 _kLast = pair.kLast(); // gas savings

            if (_kLast != 0) {
                (uint112 _reserve0, uint112 _reserve1,) = pair.getReserves(); // gas savings
                uint256 rootK = PRBMath.sqrt(uint256(_reserve0) * _reserve1);
                uint256 rootKLast = PRBMath.sqrt(_kLast);

                if (rootK > rootKLast) {
                    uint256 numerator = pair.totalSupply() * (rootK - rootKLast) * 8;
                    uint256 denominator = rootK * 17 + rootKLast * 8;
                    uint256 liquidity = numerator / denominator;

                    if (liquidity > 0) _totalSupply += liquidity;
                }
            }
        }

        uint256 amount0 = (_totalSupply > 0) ? _amount * BEP20(token0).balanceOf(_lpToken) / _totalSupply : 0;
        uint256 amount1 = (_totalSupply > 0) ? _amount * BEP20(token1).balanceOf(_lpToken) / _totalSupply : 0;

        lpPositionInUSD += priceOracle.getPrice((token0 == swapRouter.WETH()) ? BNB_ADDRESS : token0) * amount0 /
            10**((token0 == swapRouter.WETH()) ? 18 : BEP20(token0).decimals());
        lpPositionInUSD += priceOracle.getPrice((token1 == swapRouter.WETH()) ? BNB_ADDRESS : token1) * amount1 /
            10**((token1 == swapRouter.WETH()) ? 18 : BEP20(token1).decimals());
    }
}