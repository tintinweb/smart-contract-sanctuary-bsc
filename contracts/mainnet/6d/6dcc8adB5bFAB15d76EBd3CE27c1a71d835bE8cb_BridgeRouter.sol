// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./libraries/ProofParser.sol";
import "./interfaces/ICrossChainBridge.sol";
import "./SimpleTokenProxy.sol";
import "./InternetBondProxy.sol";

contract BridgeRouter {

    function peggedTokenAddress(address bridge, address fromToken) public pure returns (address) {
        return SimpleTokenProxyUtils.simpleTokenProxyAddress(bridge, bytes32(bytes20(fromToken)));
    }

    function peggedBondAddress(address bridge, address fromToken) public pure returns (address) {
        return InternetBondProxyUtils.internetBondProxyAddress(bridge, bytes32(bytes20(fromToken)));
    }

    function factoryPeggedToken(address fromToken, address toToken, ICrossChainBridge.Metadata memory metaData, address bridge) public returns (IERC20Mintable) {
        /* we must use delegate call because we need to deploy new contract from bridge contract to have valid address */
        address targetToken = SimpleTokenProxyUtils.deploySimpleTokenProxy(bridge, bytes32(bytes20(fromToken)), metaData);
        require(targetToken == toToken, "bad chain");
        /* to token is our new pegged token */
        return IERC20Mintable(toToken);
    }

    function factoryPeggedBond(address fromToken, address toToken, ICrossChainBridge.Metadata memory metaData, address bridge, address feed) public returns (IERC20Mintable) {
        /* we must use delegate call because we need to deploy new contract from bridge contract to have valid address */
        address targetToken = InternetBondProxyUtils.deployInternetBondProxy(bridge, bytes32(bytes20(fromToken)), metaData, feed);
        require(targetToken == toToken, "bad chain");
        /* to token is our new pegged token */
        return IERC20Mintable(toToken);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "./interfaces/ICrossChainBridge.sol";

contract InternetBondProxy {

    bytes32 private constant BEACON_SLOT = bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1);

    fallback() external {
        address bridge;
        bytes32 slot = BEACON_SLOT;
        assembly {
            bridge := sload(slot)
        }
        address impl = ICrossChainBridge(bridge).getBondImplementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

    function setBeacon(address newBeacon) external {
        address beacon;
        bytes32 slot = BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
        require(beacon == address(0x00));
        assembly {
            sstore(slot, newBeacon)
        }
    }
}

library InternetBondProxyUtils {

    bytes constant internal INTERNET_BOND_PROXY_BYTECODE = hex"608060405234801561001057600080fd5b50610215806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063d42afb56146100fd575b60008061005960017fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d516101a2565b60001b9050805491506000826001600160a01b0316631626425c6040518163ffffffff1660e01b8152600401602060405180830381600087803b15801561009f57600080fd5b505af11580156100b3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906100d79190610185565b90503660008037600080366000845af43d6000803e8080156100f8573d6000f35b3d6000fd5b61011061010b366004610161565b610112565b005b60008061014060017fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d516101a2565b8054925090506001600160a01b0382161561015a57600080fd5b9190915550565b60006020828403121561017357600080fd5b813561017e816101c7565b9392505050565b60006020828403121561019757600080fd5b815161017e816101c7565b6000828210156101c257634e487b7160e01b600052601160045260246000fd5b500390565b6001600160a01b03811681146101dc57600080fd5b5056fea2646970667358221220d283edebb1e56b63c1cf809c7a7219bbf056c367c289dabb51fdba5f71cdf44c64736f6c63430008060033";

    bytes32 constant internal INTERNET_BOND_PROXY_HASH = keccak256(INTERNET_BOND_PROXY_BYTECODE);

    bytes4 constant internal SET_META_DATA_SIG = bytes4(keccak256("initAndObtainOwnership(bytes32,bytes32,uint256,address,address,bool)"));
    bytes4 constant internal SET_BEACON_SIG = bytes4(keccak256("setBeacon(address)"));

    function deployInternetBondProxy(address bridge, bytes32 salt, ICrossChainBridge.Metadata memory metaData, address ratioFeed) internal returns (address) {
        /* lets concat bytecode with constructor parameters */
        bytes memory bytecode = INTERNET_BOND_PROXY_BYTECODE;
        /* deploy new contract and store contract address in result variable */
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy failed");
        /* setup impl */
        (bool success, bytes memory returnValue) = result.call(abi.encodePacked(SET_BEACON_SIG, abi.encode(bridge)));
        require(success, string(abi.encodePacked("setBeacon failed: ", returnValue)));
        /* setup meta data */
        bytes memory inputData = new bytes(0xc4);
        bool isRebasing = metaData.bondMetadata[1] == bytes1(0x01);
        bytes4 selector = SET_META_DATA_SIG;
        assembly {
            mstore(add(inputData, 0x20), selector)
            mstore(add(inputData, 0x24), mload(metaData))
            mstore(add(inputData, 0x44), mload(add(metaData, 0x20)))
            mstore(add(inputData, 0x64), mload(add(metaData, 0x40)))
            mstore(add(inputData, 0x84), mload(add(metaData, 0x60)))
            mstore(add(inputData, 0xa4), ratioFeed)
            mstore(add(inputData, 0xc4), isRebasing)
        }
        (success, returnValue) = result.call(inputData);
        require(success, string(abi.encodePacked("set metadata failed: ", returnValue)));
        /* return generated contract address */
        return result;
    }

    function internetBondProxyAddress(address deployer, bytes32 salt) internal pure returns (address) {
        bytes32 bytecodeHash = keccak256(INTERNET_BOND_PROXY_BYTECODE);
        bytes32 hash = keccak256(abi.encodePacked(uint8(0xff), address(deployer), salt, bytecodeHash));
        return address(bytes20(hash << 96));
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IERC20.sol";

contract SimpleToken is Context, IERC20, IERC20Mintable, IERC20Pegged {

    // pre-defined state
    bytes32 internal _symbol; // 0
    bytes32 internal _name; // 1
    address public owner; // 2

    // internal state
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    uint256 internal _originChain;
    address internal _originAddress;

    function name() public view returns (string memory) {
        return bytes32ToString(_name);
    }

    function symbol() public view returns (string memory) {
        return bytes32ToString(_symbol);
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        if (_bytes32 == 0) {
            return new string(0);
        }
        uint8 cntNonZero = 0;
        for (uint8 i = 16; i > 0; i >>= 1) {
            if (_bytes32[cntNonZero + i] != 0) cntNonZero += i;
        }
        string memory result = new string(cntNonZero + 1);
        assembly {
            mstore(add(result, 0x20), _bytes32)
        }
        return result;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount, true);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount, true);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public virtual returns (bool) {
        _increaseAllowance(_msgSender(), spender, amount, true);
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public virtual returns (bool) {
        _decreaseAllowance(_msgSender(), spender, amount, true);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount, true);
        _decreaseAllowance(sender, _msgSender(), amount, true);
        return true;
    }

    function _increaseAllowance(address owner, address spender, uint256 amount, bool emitEvent) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] += amount;
        if (emitEvent) {
            emit Approval(owner, spender, _allowances[owner][spender]);
        }
    }

    function _decreaseAllowance(address owner, address spender, uint256 amount, bool emitEvent) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] -= amount;
        if (emitEvent) {
            emit Approval(owner, spender, _allowances[owner][spender]);
        }
    }

    function _approve(address owner, address spender, uint256 amount, bool emitEvent) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        if (emitEvent) {
            emit Approval(owner, spender, amount);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount, bool emitEvent) internal {
        require(sender != address(0));
        require(recipient != address(0));
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        if (emitEvent) {
            emit Transfer(sender, recipient, amount);
        }
    }

    function mint(address account, uint256 amount) public onlyOwner virtual override {
        require(account != address(0));
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner virtual override {
        require(account != address(0));
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    modifier emptyOwner() {
        require(owner == address(0x00));
        _;
    }

    function initAndObtainOwnership(bytes32 symbol, bytes32 name, uint256 originChain, address originAddress) public emptyOwner {
        owner = msg.sender;
        _symbol = symbol;
        _name = name;
        _originChain = originChain;
        _originAddress = originAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getOrigin() public view override returns (uint256, address) {
        return (_originChain, _originAddress);
    }
}

contract SimpleTokenFactory {
    address private _template;
    constructor() {
        _template = SimpleTokenFactoryUtils.deploySimpleTokenTemplate(this);
    }

    function getImplementation() public view returns (address) {
        return _template;
    }
}

library SimpleTokenFactoryUtils {

    bytes32 constant internal SIMPLE_TOKEN_TEMPLATE_SALT = keccak256("SimpleTokenTemplateV1");

    bytes constant internal SIMPLE_TOKEN_TEMPLATE_BYTECODE = hex"608060405234801561001057600080fd5b50610a7f806100206000396000f3fe608060405234801561001057600080fd5b50600436106101005760003560e01c80638da5cb5b11610097578063a457c2d711610066578063a457c2d714610224578063a9059cbb14610237578063dd62ed3e1461024a578063df1f29ee1461028357600080fd5b80638da5cb5b146101cb57806394bfed88146101f657806395d89b41146102095780639dc29fac1461021157600080fd5b8063313ce567116100d3578063313ce5671461016b578063395093511461017a57806340c10f191461018d57806370a08231146101a257600080fd5b806306fdde0314610105578063095ea7b31461012357806318160ddd1461014657806323b872dd14610158575b600080fd5b61010d6102a6565b60405161011a919061095e565b60405180910390f35b6101366101313660046108f5565b6102b8565b604051901515815260200161011a565b6005545b60405190815260200161011a565b6101366101663660046108b9565b6102d0565b6040516012815260200161011a565b6101366101883660046108f5565b6102f6565b6101a061019b3660046108f5565b610305565b005b61014a6101b0366004610864565b6001600160a01b031660009081526003602052604090205490565b6002546101de906001600160a01b031681565b6040516001600160a01b03909116815260200161011a565b6101a061020436600461091f565b6103b9565b61010d61040a565b6101a061021f3660046108f5565b610417565b6101366102323660046108f5565b6104c5565b6101366102453660046108f5565b6104d4565b61014a610258366004610886565b6001600160a01b03918216600090815260046020908152604080832093909416825291909152205490565b600654600754604080519283526001600160a01b0390911660208301520161011a565b60606102b36001546104e3565b905090565b60006102c733848460016105b9565b50600192915050565b60006102df8484846001610661565b6102ec843384600161072c565b5060019392505050565b60006102c733848460016107eb565b6002546001600160a01b0316331461031c57600080fd5b6001600160a01b03821661032f57600080fd5b806005600082825461034191906109b3565b90915550506001600160a01b0382166000908152600360205260408120805483929061036e9084906109b3565b90915550506040518181526001600160a01b038316906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef906020015b60405180910390a35050565b6002546001600160a01b0316156103cf57600080fd5b60028054336001600160a01b031991821617909155600094909455600192909255600655600780549092166001600160a01b03909116179055565b60606102b36000546104e3565b6002546001600160a01b0316331461042e57600080fd5b6001600160a01b03821661044157600080fd5b6001600160a01b038216600090815260036020526040812080548392906104699084906109f0565b92505081905550806005600082825461048291906109f0565b90915550506040518181526000906001600160a01b038416907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef906020016103ad565b60006102c7338484600161072c565b60006102c73384846001610661565b6060816104fe57505060408051600081526020810190915290565b600060105b60ff811615610555578361051782846109cb565b60ff166020811061052a5761052a610a1d565b1a60f81b6001600160f81b0319161561054a5761054781836109cb565b91505b60011c607f16610503565b5060006105638260016109cb565b60ff1667ffffffffffffffff81111561057e5761057e610a33565b6040519080825280601f01601f1916602001820160405280156105a8576020820181803683370190505b506020810194909452509192915050565b6001600160a01b0384166105cc57600080fd5b6001600160a01b0383166105df57600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905220829055801561065b57826001600160a01b0316846001600160a01b03167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b9258460405161065291815260200190565b60405180910390a35b50505050565b6001600160a01b03841661067457600080fd5b6001600160a01b03831661068757600080fd5b6001600160a01b038416600090815260036020526040812080548492906106af9084906109f0565b90915550506001600160a01b038316600090815260036020526040812080548492906106dc9084906109b3565b9091555050801561065b57826001600160a01b0316846001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8460405161065291815260200190565b6001600160a01b03841661073f57600080fd5b6001600160a01b03831661075257600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905290812080548492906107899084906109f0565b9091555050801561065b576001600160a01b038481166000818152600460209081526040808320948816808452948252918290205491519182527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b9259101610652565b6001600160a01b0384166107fe57600080fd5b6001600160a01b03831661081157600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905290812080548492906107899084906109b3565b80356001600160a01b038116811461085f57600080fd5b919050565b60006020828403121561087657600080fd5b61087f82610848565b9392505050565b6000806040838503121561089957600080fd5b6108a283610848565b91506108b060208401610848565b90509250929050565b6000806000606084860312156108ce57600080fd5b6108d784610848565b92506108e560208501610848565b9150604084013590509250925092565b6000806040838503121561090857600080fd5b61091183610848565b946020939093013593505050565b6000806000806080858703121561093557600080fd5b84359350602085013592506040850135915061095360608601610848565b905092959194509250565b600060208083528351808285015260005b8181101561098b5785810183015185820160400152820161096f565b8181111561099d576000604083870101525b50601f01601f1916929092016040019392505050565b600082198211156109c6576109c6610a07565b500190565b600060ff821660ff84168060ff038211156109e8576109e8610a07565b019392505050565b600082821015610a0257610a02610a07565b500390565b634e487b7160e01b600052601160045260246000fd5b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052604160045260246000fdfea2646970667358221220fe9609dd4d099f8ee61d515b2ebf66a53d24e78cf669be48b69b627acefde71564736f6c63430008060033";

    bytes32 constant internal SIMPLE_TOKEN_TEMPLATE_HASH = keccak256(SIMPLE_TOKEN_TEMPLATE_BYTECODE);

    bytes4 constant internal SET_META_DATA_SIG = bytes4(keccak256("obtainOwnership(bytes32,bytes32)"));

    function deploySimpleTokenTemplate(SimpleTokenFactory templateFactory) internal returns (address) {
        /* we can use any deterministic salt here, since we don't care about it */
        bytes32 salt = SIMPLE_TOKEN_TEMPLATE_SALT;
        /* concat bytecode with constructor */
        bytes memory bytecode = SIMPLE_TOKEN_TEMPLATE_BYTECODE;
        /* deploy contract and store result in result variable */
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy failed");
        /* check that generated contract address is correct */
        require(result == simpleTokenTemplateAddress(templateFactory), "address mismatched");
        return result;
    }

    function simpleTokenTemplateAddress(SimpleTokenFactory templateFactory) internal pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(uint8(0xff), address(templateFactory), SIMPLE_TOKEN_TEMPLATE_SALT, SIMPLE_TOKEN_TEMPLATE_HASH));
        return address(bytes20(hash << 96));
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "./interfaces/ICrossChainBridge.sol";

contract SimpleTokenProxy {

    bytes32 private constant BEACON_SLOT = bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1);

    fallback() external {
        address bridge;
        bytes32 slot = BEACON_SLOT;
        assembly {
            bridge := sload(slot)
        }
        address impl = ICrossChainBridge(bridge).getTokenImplementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

    function setBeacon(address newBeacon) external {
        address beacon;
        bytes32 slot = BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
        require(beacon == address(0x00));
        assembly {
            sstore(slot, newBeacon)
        }
    }
}

library SimpleTokenProxyUtils {

    bytes constant internal SIMPLE_TOKEN_PROXY_BYTECODE = hex"608060405234801561001057600080fd5b50610215806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063d42afb56146100fd575b60008061005960017fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d516101a2565b60001b9050805491506000826001600160a01b031663709bc7f36040518163ffffffff1660e01b8152600401602060405180830381600087803b15801561009f57600080fd5b505af11580156100b3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906100d79190610185565b90503660008037600080366000845af43d6000803e8080156100f8573d6000f35b3d6000fd5b61011061010b366004610161565b610112565b005b60008061014060017fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d516101a2565b8054925090506001600160a01b0382161561015a57600080fd5b9190915550565b60006020828403121561017357600080fd5b813561017e816101c7565b9392505050565b60006020828403121561019757600080fd5b815161017e816101c7565b6000828210156101c257634e487b7160e01b600052601160045260246000fd5b500390565b6001600160a01b03811681146101dc57600080fd5b5056fea2646970667358221220e6ae4b3dc2474e43ff609e19eb520ce54b6f38170a43a6f96541360be5efc2b464736f6c63430008060033";

    bytes32 constant internal SIMPLE_TOKEN_PROXY_HASH = keccak256(SIMPLE_TOKEN_PROXY_BYTECODE);

    bytes4 constant internal SET_META_DATA_SIG = bytes4(keccak256("initAndObtainOwnership(bytes32,bytes32,uint256,address)"));
    bytes4 constant internal SET_BEACON_SIG = bytes4(keccak256("setBeacon(address)"));

    function deploySimpleTokenProxy(address bridge, bytes32 salt, ICrossChainBridge.Metadata memory metaData) internal returns (address) {
        /* lets concat bytecode with constructor parameters */
        bytes memory bytecode = SIMPLE_TOKEN_PROXY_BYTECODE;
        /* deploy new contract and store contract address in result variable */
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy failed");
        /* setup impl */
        (bool success,) = result.call(abi.encodePacked(SET_BEACON_SIG, abi.encode(bridge)));
        require(success, "setBeacon failed");
        /* setup meta data */
        (success,) = result.call(abi.encodePacked(SET_META_DATA_SIG, abi.encode(metaData)));
        require(success, "set metadata failed");
        /* return generated contract address */
        return result;
    }

    function simpleTokenProxyAddress(address deployer, bytes32 salt) internal pure returns (address) {
        bytes32 bytecodeHash = keccak256(SIMPLE_TOKEN_PROXY_BYTECODE);
        bytes32 hash = keccak256(abi.encodePacked(uint8(0xff), address(deployer), salt, bytecodeHash));
        return address(bytes20(hash << 96));
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "../interfaces/IERC20.sol";

interface ICrossChainBridge {

    event ContractAllowed(address contractAddress, uint256 toChain);
    event ContractDisallowed(address contractAddress, uint256 toChain);
    event ConsensusChanged(address consensusAddress);
    event TokenImplementationChanged(address consensusAddress);
    event BondImplementationChanged(address consensusAddress);

    struct Metadata {
        bytes32 symbol;
        bytes32 name;
        uint256 originChain;
        address originAddress;
        bytes32 bondMetadata; // encoded metadata version, bond type
    }

    event DepositLocked(
        uint256 chainId,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Metadata metadata
    );
    event DepositBurned(
        uint256 chainId,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Metadata metadata,
        address originToken
    );

    event WithdrawMinted(
        bytes32 receiptHash,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount
    );
    event WithdrawUnlocked(
        bytes32 receiptHash,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount
    );

    enum InternetBondType {
        NOT_BOND,
        REBASING_BOND,
        NONREBASING_BOND
    }

    function isPeggedToken(address toToken) external returns (bool);

    function deposit(uint256 toChain, address toAddress) payable external;

    function deposit(address fromToken, uint256 toChain, address toAddress, uint256 amount) external;

    function withdraw(bytes calldata encodedProof, bytes calldata rawReceipt, bytes calldata receiptRootSignature) external;

    function factoryPeggedToken(uint256 fromChain, Metadata calldata metaData) external;

    function factoryPeggedBond(uint256 fromChain, Metadata calldata metaData) external;

    function getTokenImplementation() external returns (address);

    function getBondImplementation() external returns (address);

}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Mintable {

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

interface IERC20Pegged {

    function getOrigin() external view returns (uint256, address);
}

interface IERC20Extra {

    function name() external returns (string memory);

    function decimals() external returns (uint8);

    function symbol() external returns (string memory);
}

interface IERC20InternetBond {

    function ratio() external view returns (uint256);

    function isRebasing() external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.6;

library CallDataRLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    function beginIteration(uint256 listOffset) internal pure returns (uint256 iter) {
        return listOffset + _payloadOffset(listOffset);
    }

    function next(uint256 iter) internal pure returns (uint256 nextIter) {
        return iter + itemLength(iter);
    }

    function payloadLen(uint256 ptr, uint256 len) internal pure returns (uint256) {
        return len - _payloadOffset(ptr);
    }

    function toAddress(uint256 ptr) internal pure returns (address) {
        return address(uint160(toUint(ptr, 21)));
    }

    function toUint(uint256 ptr, uint256 len) internal pure returns (uint256) {
        require(len > 0 && len <= 33);
        uint256 offset = _payloadOffset(ptr);
        uint256 numLen = len - offset;

        uint256 result;
        assembly {
            result := calldataload(add(ptr, offset))
            // cut off redundant bytes
            result := shr(mul(8, sub(32, numLen)), result)
        }
        return result;
    }

    function toUintStrict(uint256 ptr) internal pure returns (uint256) {
        // one byte prefix
        uint256 result;
        assembly {
            result := calldataload(add(ptr, 1))
        }
        return result;
    }

    function rawDataPtr(uint256 ptr) internal pure returns (uint256) {
        return ptr + _payloadOffset(ptr);
    }

    // @return entire rlp item byte length
    function itemLength(uint callDataPtr) internal pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, calldataload(callDataPtr))
        }

        if (byte0 < STRING_SHORT_START)
            itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                callDataPtr := add(callDataPtr, 1) // skip over the first byte

                /* 32 byte word size */
                let dataLen := shr(mul(8, sub(32, byteLen)), calldataload(callDataPtr))
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }
        else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        }
        else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                callDataPtr := add(callDataPtr, 1)

                let dataLen := shr(mul(8, sub(32, byteLen)), calldataload(callDataPtr))
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 callDataPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, calldataload(callDataPtr))
        }

        if (byte0 < STRING_SHORT_START)
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "./CallDataRLPReader.sol";
import "./Utils.sol";

library ProofParser {

    // Proof is message format signed by the protocol. It contains somewhat redundant information, so only part
    // of the proof could be passed into the contract and other part can be inferred from transaction receipt
    struct Proof {
        uint256 chainId;
        uint256 status;
        bytes32 transactionHash;
        uint256 blockNumber;
        bytes32 blockHash;
        uint256 transactionIndex;
        bytes32 receiptHash;
        uint256 transferAmount;
    }

    function parseProof(uint256 proofOffset) internal pure returns (Proof memory) {
        Proof memory proof;
        uint256 dataOffset = proofOffset + 0x20;
        assembly {
            calldatacopy(proof, dataOffset, 0x20) // 1 field (chainId)
            dataOffset := add(dataOffset, 0x20)
            calldatacopy(add(proof, 0x40), dataOffset, 0x80) // 4 fields * 0x20 = 0x80
            dataOffset := add(dataOffset, 0x80)
            calldatacopy(add(proof, 0xe0), dataOffset, 0x20) // transferAmount
        }
        return proof;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "../SimpleToken.sol";

library Utils {

    function currentChain() internal view returns (uint256) {
        uint256 chain;
        assembly {
            chain := chainid()
        }
        return chain;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function saturatingMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (a == 0) return 0;
            uint256 c = a * b;
            if (c / a != b) return type(uint256).max;
            return c;
        }
    }

    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return type(uint256).max;
            return c;
        }
    }

    // Preconditions:
    //  1. a may be arbitrary (up to 2 ** 256 - 1)
    //  2. b * c < 2 ** 256
    // Returned value: min(floor((a * b) / c), 2 ** 256 - 1)
    function multiplyAndDivideFloor(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        return saturatingAdd(
            saturatingMultiply(a / c, b),
            ((a % c) * b) / c // can't fail because of assumption 2.
        );
    }

    // Preconditions:
    //  1. a may be arbitrary (up to 2 ** 256 - 1)
    //  2. b * c < 2 ** 256
    // Returned value: min(ceil((a * b) / c), 2 ** 256 - 1)
    function multiplyAndDivideCeil(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        return saturatingAdd(
            saturatingMultiply(a / c, b),
            ((a % c) * b + (c - 1)) / c // can't fail because of assumption 2.
        );
    }
}