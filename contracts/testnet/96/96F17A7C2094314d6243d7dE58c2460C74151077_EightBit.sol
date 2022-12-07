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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

pragma solidity ^0.8.17;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function getUnpaidEarnings(address shareHolder) external view returns(uint256);
    function getClaimedDividends(address shareHolder) external view returns(uint256); 
    function claimDividend(address shareHolder) external;
    function setRewardToken(address newToken) external;
    function getCurrentIndex() external view returns(uint256);
    function getShareHolderIndex(address shareHolder) external view returns(uint256);
    
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;
    IERC20 public rewardToken;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _rewardToken, address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
        rewardToken = IERC20(_rewardToken);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() public payable override onlyToken {
        if(msg.value == 0){
            return;
        }
        address[] memory path = new address[](2);
        path[0] = IDEXRouter(router).WETH();
        path[1] = address(rewardToken);
        uint256 beforeBalance = rewardToken.balanceOf(address(this));
        IDEXRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value : msg.value}(
            0,
            path,
            address(this),
            block.timestamp            
        );
        uint256 receivedTokens = rewardToken.balanceOf(address(this)) - beforeBalance;
        totalDividends = totalDividends.add(receivedTokens);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(receivedTokens).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 maxIteration = shareholderCount > 5 ? 5 : shareholderCount;
        
        while(gasUsed < gas && iterations < maxIteration) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            distributeDividend(shareholders[currentIndex]);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend(address shareHolder) external {
        distributeDividend(shareHolder);
    }

    function getClaimedDividends(address shareHolder) external view returns(uint256) {
        return shares[shareHolder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function setRewardToken(address _newToken) public onlyToken{
        rewardToken = IERC20(_newToken);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function getCurrentIndex() external view returns(uint256){
        return currentIndex;
    }

    function getShareHolderIndex(address shareHolder) external view returns(uint256){
        return shareholderIndexes[shareHolder];
    }
    
    receive() external payable{
        deposit();
    }
}

//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./Cashier.sol";

pragma solidity ^0.8.17;

interface DexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface DexRouter {
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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}


contract EightBit is ERC20, Ownable {
    using Address for address;

    struct Tax {
        uint256 marketingTax;
        uint256 devTax;
        uint256 lpTax;
        uint256 refTax;
        uint256 buybackTax;
    }
    
    // what % each one gets?
    struct taxShares{
        uint256 marketingShare;
        uint256 devShare;
        uint256 lpShare;
        uint256 refShare;
        uint256 buybackShare;
    }

    //pairToRouter returns the router address that belong to the pair address
    mapping(address=>address) pairToRouter;

    //dexBuyTotalTaxes/dexSellTotalTaxes = total tax for each router, to reduce storage access, we store total tax in a mapping to only access it one time
    //during calculations  
    mapping(address=>uint256) dexBuyTotalTaxes;
    mapping(address=>uint256) dexSellTotalTaxes;

    //dexBuyTaxes/dexSellTaxes are different taxes for different routers
    mapping(address=>Tax) dexBuyTaxes;
    mapping(address=>Tax) dexSellTaxes; 

    //Transfer tax, since its not between pair and holders, we can not specify it to a router
    Tax public transferTax;
    uint256 public totalTransferTax = 5;

    //dexAccumolatedTaxes = total taxes that got accumulated in buys/sells/transfers for each dex (router)   
    mapping(address=>uint256) dexAccumolatedTaxes;

    /**
     * tax share for each router, each router (Dex) accumolates its taxes seperately from otehr dexes, hence we also consider different tax distributions for
     * each one
     */
    mapping(address=>taxShares) dexTaxShares;
    
    uint256 private constant _totalSupply = 1e8 * 1e18;

    /**
     * defaultRouter : default router that is used in the contract (pancakeswap v1 is choosed because it has the most volume on the bsc)
     * defaultPair : the default pancakeswap pair
     * isPair : checkign whether an address is a pair or not
     */
    DexRouter public defaultRouter;
    address public defaultPair;
    mapping(address=>bool) isPair;
    
    /**
     * whitelisted => wallets are excluded from every limit
     * pairBuyTaxExcludes => wallets are excluded from buy taxes for a specifiec pair
     * pairSellTaxExcludes => wallets are excluded from sell taxes for a specifiec pair
     * transferTaxExcluded => wallets are excluded from transfer taxes ( no specifiec pair )
     * dividendExcluded => wallets are excluded from receiving rewards (BTC)
     * maxWalletExcludes => wallets are exluced from max wallet
     */
    mapping(address=>bool) whitelisted;
    mapping(address=>mapping(address=>bool)) pairBuyTaxExcludes; 
    mapping(address=>mapping(address=>bool)) pairSellTaxExcludes; 
    mapping(address=>bool) transferTaxExcludes; 
    mapping(address=>bool) dividendExcludes;
    mapping(address=>bool) maxWalletExcludes;

    //swapAndLiquifyEnabled => when set to true, auto liquidity works
    bool public swapAndLiquifyEnabled = true;

    //isSwapping => to lock the swapps when we are swapping taxes to ether
    bool public isSwapping = false;

    //max wallet, its set to 1% by default, and can not be less than 1%
    uint256 public maxWallet = (_totalSupply * 1) / 100;

    //trading status, its set to false by default, after enabling the trade can not be disabled
    bool public tradingStatus = false;

    //Wallets, taxes are sent to this wallets in ether shape using a low level call, we made sure that this wallets can not be a contract, so that they can not
    //revert receiving ether in their receive function
    address public MarketingWallet = 0x179a9CB9C80B0d05B131325090F00D8Ca5113679;
    address public devWallet = 0x9AB074d242acA64544Ebbe9212F6e8BadB6dC366;
    address public buyBackWallet = 0xb9309c0D8313eE46E9747309b6414390633666f3;

    //dividend tracker that is responsible for BTC reflectins, ether is instantly swapped to BTC after reachign the contract either throught the deposit functino
    //or receive()
    DividendDistributor public cashier;

    //processGas for dividend tracker to divide BTC reflections, this value can not be more than 750, 000
    uint256 public processGas;

    /**
     * antiDump => set to off by default
     * when antiDump is on, non-exlucded wallets are not able to sell/transfer more than antiDumpLimit, if they do, they can not sell/transfer for next 
     * (antiDumpCooldown) seconds
     */
    bool public antiDump;
    uint256 public antiDumpLimit;
    uint256 public antiDumpCoolDown;
    mapping(address=>uint256) lastTradeTime;

    constructor(address _rewardToken, address _router) ERC20("8BitEARN", "8Bit") {
        //0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 test
        //0x10ED43C718714eb63d5aA57B78B54704E256024E Pancakeswap on mainnet
        //LFT swap on ETH 0x4f381d5fF61ad1D0eC355fEd2Ac4000eA1e67854
        //UniswapV2 on ETHMain net 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        defaultRouter = DexRouter(_router);
        defaultPair = DexFactory(defaultRouter.factory())
            .createPair(address(this), defaultRouter.WETH());
        pairToRouter[defaultPair] = _router;
        isPair[defaultPair] = true;

        cashier = new DividendDistributor(_rewardToken, _router);
        // do not whitelist liquidity pool, otherwise there wont be any taxes

        whitelisted[msg.sender] = true;
        whitelisted[_router] = true;
        whitelisted[address(cashier)] = true;
        whitelisted[address(this)] = true;
        whitelisted[MarketingWallet] = true;
        whitelisted[devWallet] = true;
        whitelisted[buyBackWallet] = true;
        whitelisted[address(0)] = true;

        dividendExcludes[msg.sender] = true;
        dividendExcludes[defaultPair] = true;
        dividendExcludes[address(defaultRouter)] = true;
        dividendExcludes[address(cashier)] = true;
        dividendExcludes[address(0)] = true;

        _mint(msg.sender, _totalSupply);
    }

    /**
     * functions used to set process gas 
     */
    function setProcessGas(uint256 gas) external onlyOwner{
        require(gas < 750000, "can not set process gas more than 750000");
        processGas = gas;
    }


    //addPair is used to add a new pair for the token, pair should be added alongside its router
    function addPair(address _pair, address _router) external onlyOwner{
       require(isPair[_pair] == false, "pair is already added");
       isPair[_pair] = true; 
       pairToRouter[_pair] = _router;
       dividendExcludes[_pair] = true;
       dividendExcludes[_router] = true;
    }


    //removePair is used to delete a pair from the token
    function removePair(address _pair) external onlyOwner{
        //transferring accumolated taxes to default router before deleting the pair
        require(isPair[_pair], "address is not a pair");
        address router = pairToRouter[_pair];
        if(address(router) != address(defaultRouter)){
            dexAccumolatedTaxes[address(defaultRouter)] += dexAccumolatedTaxes[router];
            dexAccumolatedTaxes[router] = 0;
        } 
        isPair[_pair] = false;
        pairToRouter[_pair] = address(0);
    }


    //used to set a default pair for our token, default pair is set to pancakeswap v2 by default 
    function setDefaultPair(address _pair, address _router) external onlyOwner{
        require(isPair[_pair], "address is not a pair, add it to pairs using addPair function");

        //transferring accumolated taxes to new router
        uint256 accTaxes = dexAccumolatedTaxes[address(defaultRouter)];
        dexAccumolatedTaxes[address(defaultRouter)] = 0;
        dexAccumolatedTaxes[_router] = accTaxes;

        //setting default pair
        defaultPair = _pair;
        defaultRouter = DexRouter(_router);
    }


    //used to set sell taxes for each pair
    function setPairSellTax(address _router, uint256 _refTax, uint256 _marTax, uint256 _devTax, uint256 _lpTax, uint256 _bbTax) external onlyOwner{
        Tax memory tax = dexSellTaxes[_router];
        tax.buybackTax = _bbTax;
        tax.lpTax = _lpTax;
        tax.devTax = _devTax;
        tax.marketingTax = _marTax;
        tax.refTax = _refTax;
        require(_refTax + _marTax + _devTax + _lpTax + _bbTax <= 10, "can not set taxes over 10%");
        dexSellTotalTaxes[_router] = _refTax + _marTax + _devTax + _lpTax + _bbTax;
        dexSellTaxes[_router] = tax;
    }
    
    //used to set buy taxes for each pair
    function setPairBuyTaxes(address _router, uint256 _refTax, uint256 _marTax, uint256 _devTax, uint256 _lpTax, uint256 _bbTax) external onlyOwner{
        Tax memory tax = dexBuyTaxes[_router];
        tax.buybackTax = _bbTax;
        tax.lpTax = _lpTax;
        tax.devTax = _devTax;
        tax.marketingTax = _marTax;
        tax.refTax = _refTax;
        require(_refTax + _marTax + _devTax + _lpTax + _bbTax <= 10, "can not set taxes over 10%");
        dexBuyTotalTaxes[_router] = _refTax + _marTax + _devTax + _lpTax + _bbTax;
        dexBuyTaxes[_router] = tax;
    }

    //used to set transfer taxes, transfer taxes are added to default router taxex
    function setTransferTaxes(uint256 _refTax, uint256 _marTax, uint256 _devTax, uint256 _lpTax, uint256 _bbTax) external onlyOwner{
        Tax memory tax = transferTax;
        tax.buybackTax = _bbTax;
        tax.lpTax = _lpTax;
        tax.devTax = _devTax;
        tax.marketingTax = _marTax;
        tax.refTax = _refTax;
        require(_refTax + _marTax + _devTax + _lpTax + _bbTax <= 10, "can not set taxes over 10%");
        transferTax = tax; 
    }

    //used to set tax distribution for each dex
    function setTaxShares(address _router, uint256 _refShare, uint256 _marShare, uint256 _devShare, uint256 _lpShare, uint256 _bbShare) external onlyOwner{
        uint256 shareSum = _refShare + _marShare + _devShare + _lpShare + _bbShare;
        require(shareSum == 100, "sum of taxes should be dividable by 100");
        dexTaxShares[_router].buybackShare = _bbShare;
        dexTaxShares[_router].devShare = _devShare;
        dexTaxShares[_router].marketingShare = _marShare;
        dexTaxShares[_router].refShare = _refShare;
        dexTaxShares[_router].lpShare = _lpShare;
    }

    //setting marketing wallet, but can not be a contract,
    function setMarketingWallet(address _newMarketing) external onlyOwner {
        require(_newMarketing.isContract() == false, "Cant set marketing wallet to a contract");
        require(MarketingWallet != address(0), "new marketing wallet can not be dead address!");
        MarketingWallet = _newMarketing;
    }

    //setting development wallet, but can not be a contract
    function setDevelopmentWallet(address _devWallet) external onlyOwner{
        require(_devWallet.isContract() == false, "Cant set developement wallet to a contract");
        devWallet = _devWallet;
    }

    //setting buyback wallet, but can not be a contract
    function setBuyBackWallet(address _buybackWallet) external onlyOwner{
        require(_buybackWallet.isContract() == false, "Cant set buyback wallet to a contract");
        buyBackWallet = _buybackWallet;
    }

    //setting max wallet, but can not be less than 0.5% of totalSupply
    function setMaxWallet(uint256 tokensCount) external onlyOwner {
        require(tokensCount * 1000 / totalSupply() >= 5, "can not set max wallet less than 0.5 of total supply");
        maxWallet = tokensCount;
    }
    
    //on and off autoliquidity
    function toggleSwapping() external onlyOwner {
        swapAndLiquifyEnabled = (swapAndLiquifyEnabled == true) ? false : true;
    }

    //whitelisting an address from every limit and tax
    function setWhitelistedStatus(address _holder, bool _status) external onlyOwner{
        whitelisted[_holder] = _status;
    }

    //whitelisting a wallet from sell taxes for a dex
    function excludeFromSellTaxes(address _router, address _holder, bool _status) external onlyOwner{
        pairSellTaxExcludes[_router][_holder] = _status;
    }

    //whitelisting a wallet from buy taxes for a dex
    function excludeFromBuyTaxes(address _router, address _holder, bool _status) external onlyOwner{
        pairBuyTaxExcludes[_router][_holder] = _status;
    }

    function excludeFromTransferTaxes(address _holder, bool _status) external onlyOwner{
       transferTaxExcludes[_holder] = _status; 
    }

    function excludeFromMaxWallet(address _holder, bool _status) external onlyOwner{
        maxWalletExcludes[_holder] = _status;
    }

    function setExcludedFromDividend(address _holder, bool _status) external onlyOwner{
        dividendExcludes[_holder] = _status;
    }

    function setAntiDumpStatus(bool status) external onlyOwner{
        antiDump = status;
    }
    
    function setAntiDumpLimit(uint256 newLimit) external onlyOwner{
        require(newLimit >= 250000 * 1e18, "can not set limit less than 250, 000 tokesn");
        antiDumpLimit = newLimit;
    }

    function setAntiDumpCooldown(uint256 coolDown) external onlyOwner{
        require(coolDown <= 86400, "can not set cooldown more than 24 hours");
        antiDumpCoolDown = coolDown;
    }

    //remaining addresses that are remaining untill _shareHodler receive its reflections in automatically manner
    function getRemainingToAutoClaim(address _shareHolder) external view returns(uint256){
        uint256 cindex = cashier.getCurrentIndex();
        uint256 hindex = cashier.getShareHolderIndex(_shareHolder);
        uint256 remaining = cindex > hindex ? cindex - hindex : hindex - cindex;
        return remaining;
    }

    //used to claim rewards
    function claimRewards() public{
        cashier.claimDividend(msg.sender);        
    }

    //getting pending rewards
    function getPendingRewards(address _holder) external view returns(uint256){
        return cashier.getUnpaidEarnings(_holder);
    }

    //getting claimed rewards
    function getClaimedRewards(address _holder) external view returns(uint256){
        return cashier.getClaimedDividends(_holder);
    }

    //enable trading, can not disable trades again
    function enableTrading() external onlyOwner{
        require(tradingStatus == false, "trading is already enabled");
        tradingStatus = true;
    }


    function _takeTax(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        if (whitelisted[_from] || whitelisted[_to]) {
            return _amount;
        }
        require(tradingStatus, "Trading is not enabled yet!");
        bool isBuy = false;
        bool isSell = false;
        uint256 totalTax = totalTransferTax;
        address _router = address(defaultRouter);

        if (isPair[_to] == true) {
            _router = pairToRouter[_to];
            totalTax = dexSellTotalTaxes[_router];             
            if(pairSellTaxExcludes[_router][_from] == true) {
                totalTax = 0;
            }
            isSell = true;
        } else if (isPair[_from] == true) {
            _router = pairToRouter[_from];
            totalTax = dexBuyTotalTaxes[_router];
            if(pairBuyTaxExcludes[_router][_to] == true) {
                totalTax = 0;
            }
            isBuy = true;
        }else{
            if(transferTaxExcludes[_to] || transferTaxExcludes[_from]){
                return _amount;
            } 
        }
        if(!isSell){ //max wallet
           if(maxWalletExcludes[_to] == false) {
            require(balanceOf(_to) + _amount <= maxWallet, "can not hold more than max wallet");
           }   
        }
        if(!isBuy){
            if(antiDump){
                require(_amount < antiDumpLimit, "Anti Dump Limit");
                require(block.timestamp - lastTradeTime[_from] >= antiDumpCoolDown, "AntiDump Cooldown, please wait!");
            }
            lastTradeTime[_from] = block.timestamp;
        }
        uint256 tax = (_amount * totalTax) / 100;
        //taxes are added for each router seperatlty 
        if(_router != address(0)){
            dexAccumolatedTaxes[_router] += tax;
        } 
        if(tax > 0) {
            super._transfer(_from, address(this), tax);
        }
        return (_amount - tax);
    }


    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        require(_from != address(0), "transfer from address zero");
        require(_to != address(0), "transfer to address zero");
        uint256 toTransfer = _takeTax(_from, _to, _amount);
        if (
            isPair[_to] &&
            !whitelisted[_from] &&
            !whitelisted[_to] &&
            !isSwapping
        ) {
            isSwapping = true;
            uint256 beforeBalane = balanceOf(address(this));
            manageTaxes(pairToRouter[_to]);
            isSwapping = false; 
            //used = amount of tokens that were used in manageTaxes function, we deduct this amount from dexAccumolatedTaxes
            uint256 used = beforeBalane > balanceOf(address(this))? beforeBalane - balanceOf(address(this)) : 0 ;
            dexAccumolatedTaxes[pairToRouter[_to]] -= used;
        }
        super._transfer(_from, _to, toTransfer);

        if(dividendExcludes[_from] == false) {
            try cashier.setShare(_from, balanceOf(_from)){} catch{}
        }

        if(dividendExcludes[_to] == false) {
            try cashier.setShare(_to, balanceOf(_to)){} catch  {}
        }

        try cashier.process(processGas) {} catch  {}
    }


    function manageTaxes(address _router) internal {
        if(_router == address(0)) {
            return;
        }
        uint256 taxAmount = dexAccumolatedTaxes[_router];
        if(taxAmount > 0){
            taxShares memory dexTaxShare = dexTaxShares[_router];
            uint256 totalShares = 100;
            uint256 lpTokens = (taxAmount * dexTaxShare.lpShare) / totalShares;

            if(swapAndLiquifyEnabled && lpTokens > 0){
                swapAndLiquify(_router, lpTokens);
            } 
            totalShares -= dexTaxShare.lpShare;
            taxAmount -= lpTokens;

            if(taxAmount == 0 || totalShares == 0){
                return;
            }

            uint256 beforeBalance = address(this).balance;
            swapToETH(_router, taxAmount);
            uint256 received = address(this).balance - beforeBalance;
            
            if(received == 0){
                return;
            }

            //Marketing wallet
            if(dexTaxShare.marketingShare > 0){
                (bool success, ) = MarketingWallet.call{value : (received * dexTaxShare.marketingShare) / totalShares }(""); 
            }

            //dev wallet
            if(dexTaxShare.devShare > 0){
                (bool success, ) = devWallet.call{value : (received * dexTaxShare.devShare) / totalShares }(""); 
            }

            //buyBackWallet
            if(dexTaxShare.buybackShare > 0) {
                (bool success, ) = buyBackWallet.call{value : (received * dexTaxShare.buybackShare) / totalShares }(""); 
            }

            //reflections
            if(dexTaxShare.refShare > 0) {
                (bool success, ) = address(cashier).call{value : (received * dexTaxShare.refShare) / totalShares }(""); 
            }
        }
    }


    function swapAndLiquify(address _router, uint256 _amount) internal {
        uint256 firstHalf = _amount / 2;
        uint256 otherHalf = _amount - firstHalf;
        uint256 initialETHBalance = address(this).balance;

        //Swapping first half to ETH
        swapToETH(_router, firstHalf);
        uint256 received = address(this).balance - initialETHBalance;
        addLiquidity(_router, otherHalf, received);
    }


    function addLiquidity(address _router, uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(_router), tokenAmount);
        DexRouter(_router).addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }
 

    function swapToETH(address _router, uint256 _amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = DexRouter(_router).WETH();
        _approve(address(this), address(DexRouter(_router)), _amount);
        DexRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function withdrawStuckETH() external onlyOwner {
        (bool success, ) = address(msg.sender).call{value: address(this).balance}("");
        require(success, "transfering ETH failed");
    }


    function withdrawStuckTokens(address erc20_token) external onlyOwner {
        bool success = IERC20(erc20_token).transfer(
            msg.sender,
            IERC20(erc20_token).balanceOf(address(this))
        );
        require(success, "trasfering tokens failed!");
    }

    function burn(address _from, uint256 _amount, bool reduceSupply) external onlyOwner{
        require(allowance(_from, msg.sender) >= _amount, "you dont have enough allowance");
        if(reduceSupply){
            _burn(_from, _amount);
        }else{
            _transfer(_from, address(0), _amount);
        }
    }

    receive() external payable {}
}