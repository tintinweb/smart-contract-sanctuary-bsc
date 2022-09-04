/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File contracts/util/SafeMathInt.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

// File contracts/util/SafeMathUint.sol

pragma solidity ^0.8.0;

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

// File @openzeppelin/contracts/utils/[email protected]

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File contracts/dex/interfaces/IFactory.sol

pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File contracts/dex/interfaces/IPancakePair.sol

pragma solidity ^0.8.0;

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File contracts/dex/interfaces/IRouter.sol

pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File contracts/dex/common/PancakeLibrary.sol

pragma solidity ^0.8.0;

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            // hex"cf86802e4bacc35c7b9e68c15ec90dae433edfef136b1d11cdfb9fc3156c3e03" // local env
                            // hex"7d95f7d5757fb6b5ee8e8c6b769978f26d7d9c6e35238f552805269314e8ff00" // home local env
                            // hex"ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074" // test net
                            hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5" // pro
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(998);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File contracts/token/tbe/ImportDex.sol

pragma solidity ^0.8.0;

abstract contract ImportDex is Ownable, ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // constants
    uint256 public constant PRICE_MULTIP = 1e6;
    // configs
    address public dexRouter;
    address public usdt;

    function _swapTokensForUsdt(uint256 amount_, address to_)
        internal
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _approve(address(this), dexRouter, amount_);
        uint256 usdtBalance = IERC20(usdt).balanceOf(to_);
        IPancakeRouter02(dexRouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount_,
                0,
                path,
                to_,
                block.timestamp
            );
        return IERC20(usdt).balanceOf(to_).sub(usdtBalance);
    }

    // function _initDex(address router, address usdt) internal {
    //     addressOfDexRouter = router;
    //     addressOfUsdt = usdt;
    // }

    // function getPriceThrowWnbnByUsdt(address coin)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     if (
    //         addressOfDexRouter == address(0) ||
    //         addressOfUsdt == address(0) ||
    //         coin == address(0)
    //     ) {
    //         return 0;
    //     }
    //     if (coin == addressOfUsdt) {
    //         return PRICE_MULTIP;
    //     }
    //     address wbnb = IPancakeRouter02(addressOfDexRouter).WETH();
    //     address dexFactory = IPancakeRouter02(addressOfDexRouter).factory();
    //     (uint256 reserveBnb, uint256 reserveU) = PancakeLibrary.getReserves(
    //         dexFactory,
    //         wbnb,
    //         addressOfUsdt
    //     );
    //     (uint256 reserveBnb2, uint256 reserveC) = PancakeLibrary.getReserves(
    //         dexFactory,
    //         wbnb,
    //         coin
    //     );
    //     if (reserveC == 0 || reserveBnb == 0) {
    //         return 0;
    //     }
    //     uint256 bnbPerC = reserveBnb2.mul(1e6).div(reserveC);
    //     uint256 uPerBnb = reserveU.mul(1e6).div(reserveBnb);
    //     return bnbPerC.mul(uPerBnb).div(1e6);
    // }

    function getPriceByUsdt(address coin) public view returns (uint256) {
        if (
            dexRouter == address(0) || usdt == address(0) || coin == address(0)
        ) {
            return 0;
        }
        if (coin == usdt) {
            return PRICE_MULTIP;
        }
        address dexFactory = IPancakeRouter02(dexRouter).factory();
        (uint256 reserveC, uint256 reserveU) = PancakeLibrary.getReserves(
            dexFactory,
            coin,
            usdt
        );
        if (reserveC == 0) {
            return 0;
        }
        return reserveU.mul(PRICE_MULTIP).div(reserveC);
    }
}

// File contracts/token/tbe/ImportInvite.sol

pragma solidity ^0.8.0;

abstract contract ImportInvite is ImportDex {
    using SafeMath for uint256;

    uint256 public immutable BIPS_BASE = 10000;
    // invite relation
    mapping(address => address) public inviteFroms;
    mapping(address => mapping(uint256 => address)) public inviteTos;
    // count
    mapping(address => uint256) public inviteToCountDirects;
    mapping(address => uint256) public inviteToCountIndirects;
    // revard config
    uint256 public revardGenerates = 5; // parent get reward from child>child>child
    uint256[] public revardBipsPerGen = [400, 100, 100, 100, 100];
    mapping(address => uint256) public inviteRewardsByUsdt;
    mapping(address => uint256) public inviteRewardsByXsg;

    // exclude from invite
    mapping(address => bool) public excludeFromInvites;

    address public inviteUsdtRewardPool;

    // invite reward record
    // Counters.Counter public currentInviteRewardRecordId;
    // Counters.Counter public currentProcessingInviteRewardRecordId;
    // struct InviteRewardRecord {
    //     uint256 id;
    //     address buyer;
    //     uint256 amount;
    // }
    // mapping(uint256=>InviteRewardRecord) public inviteRewardRecords;

    // base
    // function _inviteAddRewardRecord(address buyer_,uint256 amount)

    // admin api

    function setExcludeFromInvite(address addr_, bool isExclude_)
        public
        onlyOwner
    {
        if (excludeFromInvites[addr_] == isExclude_) {
            return;
        }
        excludeFromInvites[addr_] = isExclude_;
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    function _getEffectRateBase() internal view returns (uint256) {
        uint256 gen = _min(revardGenerates, revardBipsPerGen.length);
        uint256 sum;
        for (uint256 i = 0; i < gen; i++) {
            sum = sum.add(revardBipsPerGen[i]);
        }
        return sum;
    }

    function _setInviteFrom(address to, address from) internal {
        require(to != address(0), "invite from or to zero");
        if (from == address(0) || from == to || _isInviteFromChild(to, from)) {
            return;
        }
        if (excludeFromInvites[to] || excludeFromInvites[from]) {
            return;
        }

        // console.log(to, from, inviteFroms[to]);
        if (inviteFroms[to] == address(0)) {
            inviteFroms[to] = from;
            _addInviteCountIter(to, from);
        } else {
            //ignore, had accept others invite
            return;
        }
    }

    function _isInviteFromChild(address to, address from)
        internal
        returns (bool)
    {
        if (inviteToCountDirects[to] == 0) return false;
        for (uint256 i = 0; i < inviteToCountDirects[to]; i++) {
            if (inviteTos[to][i] == from) return true;
            if (_isInviteFromChild(inviteTos[to][i], from)) return true;
        }
        return false;
    }

    function _addInviteCountIter(address to, address from) internal {
        if (from == address(0)) {
            return;
        }
        _addInviteCount(to, from, true);
        address ff = from;
        address tt = to;
        for (uint256 i = 0; i < revardGenerates; i++) {
            tt = ff;
            ff = inviteFroms[ff];
            if (ff == address(0)) {
                break;
            }
            _addInviteCount(tt, ff, false);
        }
    }

    function _addInviteCount(
        address to,
        address from,
        bool isDirect
    ) internal {
        // console.log(to, from, isDirect);
        if (isDirect) {
            inviteTos[from][inviteToCountDirects[from]] = to;
            inviteToCountDirects[from] = inviteToCountDirects[from].add(1);
        } else {
            inviteToCountIndirects[from] = inviteToCountIndirects[from].add(1);
        }
    }
}

// File contracts/token/tbe/holder/HolderStore.sol

pragma solidity ^0.8.0;

abstract contract HolderStore is ImportInvite {
    uint256 public constant MAGNITUDE = 2**128; // multiple for small value to calcurate dividend
    // dividend per share : total reward / total amount
    uint256 public magnifiedDividendPerShare; // dividendPerShare * GAGNITUDE
    // correct dividends when send:+ or receiver:- coin
    mapping(address => int256) public magnifiedDividendCorrections;
    // had got dividends
    mapping(address => uint256) public withdrawnDividends;
    uint256 public totalDividendsDistributed;

    // holder balanceOf
    mapping(address => uint256) public hBalanceOf;
    uint256 public hTotalSupply;

    // enum holders
    Counters.Counter public hCurrentHolderIndex;
    mapping(uint256 => address) public hHolderIndexs;
    mapping(address => bool) public hHolderExists;

    // process/auto batch withdraw dividend config & state
    uint256 public hGasLimiteForProcess = 300000;
    Counters.Counter public hCurrentProcessingHolderIndex;
    uint256 public hWithdrawInterval = 3600;
    mapping(address => uint256) public hLastWithdrawTime;

    // admin
    mapping(address => bool) public hExcludeFromDividends;
    uint256 public swapTokensAtAmount;

    address public hHolderRewardPool;
}

// File contracts/token/tbe/holder/HolderBase.sol

pragma solidity ^0.8.0;

abstract contract HolderBase is HolderStore {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;
    using Counters for Counters.Counter;

    // set
    function _hProcess() internal {
        // iter limit : gas ;total address; interval time;
        uint256 gasUsed = 0;
        uint256 gasLeftAtStart = gasleft();
        uint256 gasLeftAtEnd = 0;
        uint256 processTimes = 0;
        while (
            gasUsed < hGasLimiteForProcess &&
            processTimes <= hCurrentHolderIndex.current()
        ) {
            processTimes++;
            hCurrentProcessingHolderIndex.increment();
            if (
                hCurrentProcessingHolderIndex.current() >
                hCurrentHolderIndex.current()
            ) {
                hCurrentProcessingHolderIndex.reset();
                hCurrentProcessingHolderIndex.increment();
            }
            _hWithdrawDividend(
                hHolderIndexs[hCurrentProcessingHolderIndex.current()]
            );

            gasLeftAtEnd = gasleft();
            gasUsed = gasUsed.add(gasLeftAtStart.sub(gasLeftAtEnd));
            gasLeftAtStart = gasLeftAtEnd;
        }
    }

    function _hAddHolderIndex(address addr_) internal {
        if (!hHolderExists[addr_]) {
            hHolderExists[addr_] = true;
            hCurrentHolderIndex.increment();
            hHolderIndexs[hCurrentHolderIndex.current()] = addr_;
        }
    }

    // get/withdraw dividend
    function _hWithdrawDividend(address addr_) internal returns (uint256) {
        if (addr_ == address(0)) {
            return 0;
        }
        if (hLastWithdrawTime[addr_] > block.timestamp) {
            return 0;
        }
        hLastWithdrawTime[addr_] = block.timestamp;

        uint256 amountOfWithdrawable = _hGetWithdrawableDividendOf(addr_);
        if (amountOfWithdrawable > 0) {
            withdrawnDividends[addr_] = withdrawnDividends[addr_].add(
                amountOfWithdrawable
            );
            // tx usdt to addr_
            bool success = IERC20(usdt).transferFrom(
                hHolderRewardPool,
                addr_,
                amountOfWithdrawable
            );
            if (!success) {
                withdrawnDividends[addr_] = withdrawnDividends[addr_].sub(
                    amountOfWithdrawable
                );
                return 0;
            }
            return amountOfWithdrawable;
        }
        return 0;
    }

    // distribute reward
    function _hDistributeDividends(uint256 amount_) internal {
        require(hTotalSupply > 0, "holder total zero");
        require(amount_ > 0, "distribute dividend zero");
        magnifiedDividendPerShare = magnifiedDividendPerShare.add(
            amount_.mul(MAGNITUDE).div(hTotalSupply)
        );
    }

    // modify holder balance

    function _hMint(address addr_, uint256 amount_) internal {
        require(amount_ > 0, "amount zero");
        require(addr_ != address(0), "address zero");
        // effect
        hBalanceOf[addr_] = hBalanceOf[addr_].add(amount_);
        _hAddHolderIndex(addr_);
        hTotalSupply = hTotalSupply.add(amount_);
        magnifiedDividendCorrections[addr_] = magnifiedDividendCorrections[
            addr_
        ].sub((magnifiedDividendPerShare.mul(amount_)).toInt256Safe());
    }

    function _hBurn(address addr_, uint256 amount_) internal {
        require(amount_ > 0, "amount zero");
        require(addr_ != address(0), "address zero");
        if (hBalanceOf[addr_] == 0) {
            return;
        }
        require(hBalanceOf[addr_] >= amount_, "burn over balance");
        // effect
        hBalanceOf[addr_] = hBalanceOf[addr_].sub(amount_);
        hTotalSupply = hTotalSupply.sub(amount_);
        magnifiedDividendCorrections[addr_] = magnifiedDividendCorrections[
            addr_
        ].add((magnifiedDividendPerShare.mul(amount_)).toInt256Safe());
    }

    // get
    function _hGetWithdrawableDividendOf(address addr_)
        internal
        view
        returns (uint256)
    {
        return
            _hGetAccumulativeDividendOf(addr_).sub(withdrawnDividends[addr_]);
    }

    function _hGetAccumulativeDividendOf(address addr_)
        internal
        view
        returns (uint256)
    {
        return
            magnifiedDividendPerShare
                .mul(hBalanceOf[addr_])
                .toInt256Safe()
                .add(magnifiedDividendCorrections[addr_])
                .toUint256Safe()
                .div(MAGNITUDE);
    }
}

// File contracts/token/tbe/holder/HolderAdmin.sol

pragma solidity ^0.8.0;

abstract contract HolderAdmin is HolderBase {
    // auto withdraw dividend with limit gas
    // set
    function setExcludeFromDividends(address addr_, bool isExclude_)
        public
        onlyOwner
    {
        if (hExcludeFromDividends[addr_] == isExclude_) {
            return;
        }
        if (isExclude_) {
            hExcludeFromDividends[addr_] = true;
            if (hBalanceOf[addr_] > 0) {
                _hBurn(addr_, hBalanceOf[addr_]);
            }
        } else {
            hExcludeFromDividends[addr_] = false;
        }
    }

    function setWithdrawDividendsInterval(uint256 intervalSeconds_)
        public
        onlyOwner
    {
        hWithdrawInterval = intervalSeconds_;
    }

    function setGasLimiteForProcess(uint256 gasLimit_) public onlyOwner {
        hGasLimiteForProcess = gasLimit_;
    }

    function setHolderRewardCoin(address coin_) public onlyOwner {
        usdt = coin_;
    }

    function setSwapTokensAtAmount(uint256 amount_) public onlyOwner {
        swapTokensAtAmount = amount_;
    }
}

// File contracts/token/tbe/holder/Holder.sol

pragma solidity ^0.8.0;

abstract contract Holder is HolderAdmin {
    using Counters for Counters.Counter;

    // set
    // mint ; burn; add reward; process;
    function hMint(address addr_, uint256 amount_) internal {
        _hMint(addr_, amount_);
    }

    function hBurn(address addr_, uint256 amount_) internal {
        _hBurn(addr_, amount_);
    }

    function hAddReward(uint256 amount_) internal {
        _hDistributeDividends(amount_);
    }

    function hProcess() internal {
        _hProcess();
    }

    // get
    // withdrawableAmount, totalHolders; currentProcessHolder
    function hGetAmountOfWithdrawableDividend(address addr_)
        public
        view
        returns (uint256)
    {
        return _hGetWithdrawableDividendOf(addr_);
    }

    function hGetAccumulativeDividend(address addr_)
        public
        view
        returns (uint256)
    {
        return _hGetAccumulativeDividendOf(addr_);
    }

    function hGetAmountOfHadWithdrawnDividend(address addr_)
        public
        view
        returns (uint256)
    {
        return withdrawnDividends[addr_];
    }

    function hGetTotalHolders() public view returns (uint256) {
        return hCurrentHolderIndex.current();
    }

    function hGetLastProcessedHolderIndex() public view returns (uint256) {
        return hCurrentProcessingHolderIndex.current();
    }
}

// File contracts/token/tbe/TbeTokenStore.sol

pragma solidity ^0.8.0;

abstract contract TbeTokenStore is Holder {
    // dex
    // address public dexRouter;
    address public dexPair;
    // address public usdt;

    // fee
    uint256 public feeToMarketOnBuyRate = 200;
    uint256 public feeToInvitorOnBuyRate = 800;
    uint256 public feeToMarketOnSellRate = 200;
    uint256 public feeToHolderOnSellRate = 800;

    // fee receiver:
    address public feeToMarketReceiver;
    // fee excluders
    mapping(address => bool) public excludeFromFees;

    // market & invite & hold get Usdt
    uint256 public amountOfMarket; // fee type 1
    uint256 public amountOfInvitePool; //fee type 2
    uint256 public amountOfHoldPool; // fee type 3
    // invite :
    // horlder :
    // dex:
}

// File contracts/token/tbe/TbeTokenBase.sol

pragma solidity ^0.8.0;

abstract contract TbeTokenBase is TbeTokenStore {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //transferState
    bool public transferState = false;

    function setTransferStateChange() public onlyOwner {
        transferState = !transferState;
    }

    function _transferRouter(
        address from_,
        address to_,
        uint256 amount_
    ) internal returns (bool) {
        require(from_ != address(0) && to_ != address(0), "address zero");
        require(amount_ > 0, "amount zero");

        if (excludeFromFees[from_] || excludeFromFees[to_]) {
            super._transfer(from_, to_, amount_);
            _setInviteFrom(to_, from_);
            _setHolderBalance(from_, to_, amount_);
            return true;
        }

        if (from_ == dexPair) {
            // swap buy mensa or remove lp
            _transferTakeFee(from_, to_, amount_, true);
        } else if (to_ == dexPair) {
            // swap sell mensa or add lp
            _transferTakeFee(from_, to_, amount_, false);
        } else {
            // normal tx
            super._transfer(from_, to_, amount_);
            _setInviteFrom(to_, from_);
            _setHolderBalance(from_, to_, amount_);
            _swapAndSendToFeeReceiver();
        }
        return true;
    }

    function _transferTakeFee(
        address from_,
        address to_,
        uint256 amount_,
        bool isBuy_
    ) internal returns (bool) {
        require(amount_ > 0, "amount zero");
        require(from_ != address(0), "address zero");
        require(transferState, "swap off");
        uint256 amountRemain = amount_;
        if (isBuy_) {
            // buy fee to market
            uint256 feeMarket = amount_.mul(_getRate(true, true)).div(
                BIPS_BASE
            );
            if (feeMarket > 0 && feeToMarketReceiver != address(0)) {
                amountRemain = amountRemain.sub(feeMarket);
                super._transfer(from_, address(this), feeMarket);
                _feeMint(1, feeMarket);
            }
            // buy fee to invitor
            uint256 feeInvitor = amount_.mul(_getRate(true, false)).div(
                BIPS_BASE
            );
            if (feeInvitor > 0) {
                amountRemain = amountRemain.sub(feeInvitor);
                // todo: swap usdt & send to parent
                // error: in swaping  , can't swap
                // solution: record buyer => invitorFee, process at normal tx
                super._transfer(from_, address(this), feeInvitor);
                _feeMint(2, feeInvitor);
                uint256 amountUsdt = feeInvitor
                    .mul(getPriceByUsdt(address(this)))
                    .div(PRICE_MULTIP);
                _sendRewardToInvitor(to_, amountUsdt);
            }
        } else {
            // sell fee to market
            uint256 feeMarket = amount_.mul(_getRate(false, true)).div(
                BIPS_BASE
            );
            if (feeMarket > 0 && feeToMarketReceiver != address(0)) {
                amountRemain = amountRemain.sub(feeMarket);
                super._transfer(from_, address(this), feeMarket);
                _feeMint(1, feeMarket);
            }
            // sell fee to holder
            uint256 amountOfFeeToHolder = amount_
                .mul(_getRate(false, false))
                .div(BIPS_BASE);
            if (amountOfFeeToHolder > 0) {
                amountRemain = amountRemain.sub(amountOfFeeToHolder);
                // todo: swap usdt & add reward to holders & process holders
                super._transfer(from_, address(this), amountOfFeeToHolder);
                _feeMint(3, amountOfFeeToHolder);
                // _swapAndSendToHolder();
            }
        }
        // to to_
        if (amountRemain > 0) {
            super._transfer(from_, to_, amountRemain);
            _setInviteFrom(to_, from_);
            _setHolderBalance(from_, to_, amountRemain);
        }
        return true;
    }

    // function _swapAndSendToHolder() internal {
    //     uint256 b = balanceOf(address(this));
    //     if (b < swapTokensAtAmount) return;
    //     uint256 amountUsdt = _swapTokensForUsdt(b, hHolderRewardPool);
    //     hAddReward(amountUsdt);
    //     hProcess();
    // }

    function _sendRewardToInvitor(address addr_, uint256 amount_) internal {
        address currNode = addr_;
        address p;
        uint256 amountRemain = amount_;
        uint256 gen = _min(revardGenerates, revardBipsPerGen.length);
        uint256 effectRateBase = _getEffectRateBase();
        for (uint256 i = 0; i < gen; i++) {
            p = inviteFroms[currNode];
            if (p == address(0)) break;
            if (p == address(this)) break;
            if (p == inviteUsdtRewardPool) break;
            uint256 amountToParent = amount_.mul(revardBipsPerGen[i]).div(
                effectRateBase
            );
            if (amountToParent == 0) break;

            uint256 balanceOfPool = IERC20(usdt).balanceOf(
                inviteUsdtRewardPool
            );
            if (amountToParent > balanceOfPool) {
                revert("invite pool: usdt not enough");
            }

            // effect
            IERC20(usdt).safeTransferFrom(
                inviteUsdtRewardPool,
                p,
                amountToParent
            );
            amountRemain = amountRemain.sub(amountToParent);
            currNode = p;
        }
        // if (amountRemain > 0) {
        // send remain invite reward usdt to market
        // IERC20(usdt).safeTransferFrom(inviteUsdtRewardPool,feeToMarketReceiver, amountRemain);
        // }
    }

    function _setHolderBalance(
        address from_,
        address to_,
        uint256 amount_
    ) internal {
        if (!hExcludeFromDividends[from_]) {
            hBurn(from_, amount_);
        }
        if (!hExcludeFromDividends[to_]) {
            hMint(to_, amount_);
        }
    }

    function _getRate(bool isBuy_, bool isMarket_)
        internal
        view
        returns (uint256)
    {
        if (isBuy_ && !isMarket_) {
            return feeToInvitorOnBuyRate;
        } else if (!isBuy_ && isMarket_) {
            return feeToMarketOnSellRate;
        } else if (!isBuy_ && !isMarket_) {
            return feeToHolderOnSellRate;
        } else {
            return feeToMarketOnBuyRate;
        }
    }

    function _swapAndSendToFeeReceiver() internal {
        if (amountOfMarket > swapTokensAtAmount) {
            if (feeToMarketReceiver != address(0)) {
                _swapTokensForUsdt(amountOfMarket, feeToMarketReceiver);
                _feeBurn(1, amountOfMarket);
            }
        }
        if (amountOfInvitePool > swapTokensAtAmount) {
            if (inviteUsdtRewardPool != address(0)) {
                _swapTokensForUsdt(amountOfInvitePool, inviteUsdtRewardPool);
                _feeBurn(2, amountOfInvitePool);
            }
        }
        if (amountOfHoldPool > swapTokensAtAmount) {
            if (hHolderRewardPool != address(0)) {
                uint256 amountOfUsdt = _swapTokensForUsdt(
                    amountOfHoldPool,
                    hHolderRewardPool
                );
                _feeBurn(3, amountOfHoldPool);
                hAddReward(amountOfUsdt);
                hProcess();
            }
        }
    }

    function _feeMint(uint256 feeType_, uint256 amount_) internal {
        if (feeType_ == 1) {
            amountOfMarket = amountOfMarket.add(amount_);
        } else if (feeType_ == 2) {
            amountOfInvitePool = amountOfInvitePool.add(amount_);
        } else if (feeType_ == 3) {
            amountOfHoldPool = amountOfHoldPool.add(amount_);
        } else {
            revert("not support fee type");
        }
    }

    function _feeBurn(uint256 feeType_, uint256 amount_) internal {
        if (feeType_ == 1) {
            amountOfMarket = amountOfMarket.sub(amount_);
        } else if (feeType_ == 2) {
            amountOfInvitePool = amountOfInvitePool.sub(amount_);
        } else if (feeType_ == 3) {
            amountOfHoldPool = amountOfHoldPool.sub(amount_);
        } else {
            revert("burn:not support fee type");
        }
    }
}

// File contracts/token/tbe/TbeTokenAdmin.sol

pragma solidity ^0.8.0;

abstract contract TbeTokenAdmin is TbeTokenBase {
    using SafeMath for uint256;

    // set
    // dex
    function setDexRouter(address addr_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        dexRouter = addr_;
        setExcludeFromFees(dexRouter, true);
        setExcludeFromDividends(dexRouter, true);
        setExcludeFromInvite(dexRouter, true);
        fetchDexPair();
    }

    function setUsdt(address addr_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        usdt = addr_;
        setExcludeFromFees(usdt, true);
        setExcludeFromDividends(usdt, true);
        setExcludeFromInvite(usdt, true);
        fetchDexPair();
    }

    function fetchDexPair() internal {
        if (dexRouter == address(0) || usdt == address(0)) return;
        address factory = IPancakeRouter02(dexRouter).factory();
        address lp = IPancakeFactory(factory).getPair(address(this), usdt);
        if (lp == address(0)) {
            lp = IPancakeFactory(factory).createPair(address(this), usdt);
        }
        setDexPair(lp);
    }

    function setDexPair(address addr_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        dexPair = addr_;
        setExcludeFromDividends(dexPair, true);
        setExcludeFromInvite(dexPair, true);
    }

    // fee
    function setFeeToMarketOnBuyRate(uint256 rate_) public onlyOwner {
        require(feeToInvitorOnBuyRate.add(rate_) <= BIPS_BASE, "too large");
        feeToMarketOnBuyRate = rate_;
    }

    function setFeeToInvitorOnBuyRate(uint256 rate_) public onlyOwner {
        require(feeToMarketOnBuyRate.add(rate_) <= BIPS_BASE, "too large");
        feeToInvitorOnBuyRate = rate_;
    }

    function setFeeToMarketOnSellRate(uint256 rate_) public onlyOwner {
        require(feeToHolderOnSellRate.add(rate_) <= BIPS_BASE, "too large");
        feeToMarketOnSellRate = rate_;
    }

    function setFeeToHolderOnSellRate(uint256 rate_) public onlyOwner {
        require(feeToMarketOnSellRate.add(rate_) <= BIPS_BASE, "too large");
        feeToHolderOnSellRate = rate_;
    }

    function setFeeToMarketReceiver(address addr_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        feeToMarketReceiver = addr_;
        setExcludeFromFees(feeToMarketReceiver, true);
        setExcludeFromDividends(feeToMarketReceiver, true);
        setExcludeFromInvite(feeToMarketReceiver, true);
    }

    function setInviteUsdtRewardPool(address addr_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        inviteUsdtRewardPool = addr_;
        setExcludeFromFees(inviteUsdtRewardPool, true);
        setExcludeFromDividends(inviteUsdtRewardPool, true);
        setExcludeFromInvite(inviteUsdtRewardPool, true);
    }

    function setHolderUsdtRewardPool(address addr_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        hHolderRewardPool = addr_;
        setExcludeFromFees(hHolderRewardPool, true);
        setExcludeFromDividends(hHolderRewardPool, true);
        setExcludeFromInvite(hHolderRewardPool, true);
    }

    function setExcludeFromFees(address addr_, bool isExclude_)
        public
        onlyOwner
    {
        if (excludeFromFees[addr_] != isExclude_) {
            excludeFromFees[addr_] = isExclude_;
        }
    }

    function setExcludeMultipleAccountsFromFees(
        address[] calldata addrs_,
        bool isExclude_
    ) public onlyOwner {
        for (uint256 i = 0; i < addrs_.length; i++) {
            excludeFromFees[addrs_[i]] = isExclude_;
        }
    }
    // swap buy fee
    // swap sell fee
    // effect
    // 1. airdrop tx got reward from child swap buy fee
    // 2. holder earn usdt from others swap sell fee
}

// File contracts/token/tbe/TbeToken.sol

pragma solidity ^0.8.0;

contract TbeToken is TbeTokenAdmin {
    using SafeMath for uint256;

    constructor() ERC20("TBE", "TBE") {
        _mint(_msgSender(), 10**(8 + decimals()));
        setSwapTokensAtAmount(totalSupply().mul(2).div(1e6));
        setDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        setUsdt(0x55d398326f99059fF775485246999027B3197955);
        setFeeToMarketReceiver(0x105b383050Ac62A71B343447be7369f59CEe352a);
        setInviteUsdtRewardPool(0x8E631cc5C6d58260c4791083623258F5F4F175Ab);
        setHolderUsdtRewardPool(0xFC27BcEDe65E7001af94FFe31E5AA96707Fc30Ea);

        setExcludeFromFees(_msgSender(), true);
        setExcludeFromDividends(_msgSender(), true);

        setExcludeFromFees(address(this), true);
        setExcludeFromDividends(address(this), true);
        setExcludeFromInvite(address(this), true);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        return _transferRouter(_msgSender(), to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        return _transferRouter(from, to, amount);
    }
    // swap buy fee
    // swap sell fee
    // effect
    // 1. airdrop tx got reward from child swap buy fee
    // 2. holder earn usdt from others swap sell fee
}