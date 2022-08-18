// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.9;

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
library LibContext {
    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgData() internal view returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibContext} from "@solarprotocol/libraries/contracts/utils/LibContext.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

/**
 * @dev Collection of helpers for parameter validation.
 */
library LibUtils {
    using Address for address;

    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    error NotOwner(address address_);
    error NotContract(address address_);
    error NotERC20(address address_);

    function validateERC20(address token) internal view {
        if (!token.isContract()) {
            revert NotContract(token);
        }

        (bool successName, ) = token.staticcall(
            abi.encodeWithSignature("name()")
        );
        if (!successName) {
            revert NotERC20(token);
        }

        (bool successBalanceOf, ) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(1))
        );
        if (!successBalanceOf) {
            revert NotERC20(token);
        }
    }

    function enforceIsContractOwner() internal view {
        address address_ = LibContext.msgSender();

        if (address_ != getOwner()) {
            revert NotOwner(address_);
        }
    }

    function getOwner() internal view returns (address adminAddress) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }
}

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibProtocolX} from "../Libraries/LibProtocolX.sol";
import {LibTokenDistributor} from "../Libraries/LibTokenDistributor.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

/**
 * @dev External controller for LibProtocolX exposing the ERC20 related functions.
 */
contract ERC20Controller is IERC20, IERC20Metadata {
    error NotImplemented();

    function name() public view returns (string memory) {
        return LibProtocolX.name();
    }

    function symbol() public view returns (string memory) {
        return LibProtocolX.symbol();
    }

    function decimals() public pure returns (uint8) {
        return uint8(5);
    }

    function totalSupply() external view returns (uint256) {
        return LibProtocolX.totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return LibProtocolX.balanceOf(account);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        return LibProtocolX.transfer(to, value);
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return LibProtocolX.allowance(owner, spender);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        return LibProtocolX.approve(spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        return LibProtocolX.transferFrom(from, to, value);
    }
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibProtocolX} from "./../Libraries/LibProtocolX.sol";
import {LibUtils} from "./../Libraries/LibUtils.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev External controller for LibProtocolX exposing functions for admin interaction.
 */
contract ProtocolXAdminController is Initializable {
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 starttime_,
        address router_,
        uint256 liquiditiyFee,
        uint256 treasuryFee,
        uint256 insuranceFundFee,
        uint256 sellAfterBurnerFee
    ) public initializer {
        LibProtocolX.initialize(name_, symbol_, starttime_, router_,liquiditiyFee,treasuryFee,insuranceFundFee,sellAfterBurnerFee);
    }

    function setAutoRebase(bool _flag) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setAutoRebase(_flag);
    }

    function setAutoAddLiquidity(bool _flag) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setAutoAddLiquidity(_flag);
    }

    function setRebaseRate(uint256 _rebaseRate) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setRebaseRate(_rebaseRate);
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _tytanInsuranceFundReceiver,
        address _afterburner
    ) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setFeeReceivers(
            _autoLiquidityReceiver,
            _treasuryReceiver,
            _tytanInsuranceFundReceiver,
            _afterburner
        );
    }

    function setFeeExempt(address _addr, bool _flag) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setFeeExempt(_addr, _flag);
    }

    function setBlacklisted(address _botAddress, bool _flag) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setBlacklisted(_botAddress, _flag);
    }

    /**
     * @notice Calling IUniswapV2Pair synb function
     * @dev Force reserves to match balances
     */
    function manualSync() external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.manualSync();
    }

    function setAllowedFragments (address pair) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolX.setAllowedFragments(pair);
    }

    function createPair () external returns (address) {
        LibUtils.enforceIsContractOwner();
        return LibProtocolX.createPair();
    }
    
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibProtocolXFeesManager} from "./../Libraries/LibProtocolXFeesManager.sol";
import {LibUtils} from "./../Libraries/LibUtils.sol";
import {ITokenDitributor} from "../Interfaces/ITokenDistributor.sol";

contract ProtocolXFeeManagerAdminController {
    function add(bytes32 feeId, uint256 feeAmount) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolXFeesManager.add(feeId, feeAmount);
    }

    function updateFeeMap(
        bytes32 feeId, uint256 feeAmount
    ) external {
        LibUtils.enforceIsContractOwner();
        LibProtocolXFeesManager.updateFeeMap(feeId, feeAmount);
    }


}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibProtocolXFeesManager} from "./../Libraries/LibProtocolXFeesManager.sol";

contract ProtocolXFeeManagerGetterController {
    function get(bytes32 feeId) external view returns (uint256) {
        return LibProtocolXFeesManager.get(feeId);
    }
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibProtocolX} from "../Libraries/LibProtocolX.sol";
import {LibUtils} from "../Libraries/LibUtils.sol";

/**
 * @dev External controller for ProtocolXGettersController exposing functions for regular interaction.
 */
contract ProtocolXGettersController {
    function index() public view returns (uint256) {
        return LibProtocolX.index();
    }

    function gonsForBalance(uint256 amount) public view returns (uint256) {
        return LibProtocolX.gonsForBalance(amount);
    }

    function balanceForGons(uint256 gons) public view returns (uint256) {
        return LibProtocolX.balanceForGons(gons);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return LibProtocolX.getCirculatingSupply();
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256) {
        return LibProtocolX.getLiquidityBacking(accuracy);
    }

    /**
     * @dev Get the AutoRebase state
     */
    function getAutoRebaseState() external view returns (bool) {
        return  LibProtocolX.getAutoRebaseState();
    }

    /**
     * @dev Get the AutoLiquidity state
     */
    function getAutoLiquidityState() external view returns (bool) {
        return LibProtocolX.getAutoLiquidityState();
    }

    /**
     * @dev Get the rebase State
     */
    function getRebaseRate() external view returns (uint256) {
        return LibProtocolX.getRebaseRate();
    }

    /**
     * @dev Get gons per fragment
     */
    function getGonsPerFragment() external view returns (uint256) {
        return LibProtocolX.getGonsPerFragment();
    }

    /**
     * @dev Check if the address does not have to pay a fee
     * @param _addr address to checks
     */
    function checkFeeExempt(address _addr) external view returns (bool) {
        return LibProtocolX.checkFeeExempt(_addr);
    }

    /**
     * @dev Check if the address is blacklisted
     * @param _addr address to check
     */
    function checkBlacklisted(address _addr) external view returns (bool) {
        return LibProtocolX.checkBlacklisted(_addr);
    }

    /**
     * @dev Check if the address is excluded from rebase
     * @param _addr address to check
     */
    function checkExcludedFromRebase(address _addr) external view returns (bool) {
        return LibProtocolX.checkExcludedFromRebase(_addr);
    }

    /**
     * @dev Get the total gons
     */
    function getTotalGons() external pure returns (uint256) {
        return LibProtocolX.getTotalGons();
    }

}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenDitributor {
    struct Distribution {
        address destination;
        uint256 proportion;
    }

    struct Strategy {
        IERC20 token;
        Distribution[] distributions;
    }

    function getTokenDistributionStrategy(bytes32 strategyId)
        external
        view
        returns (Strategy memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.9;

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
library LibContext {
    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgData() internal view returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibPrototcolXConstants} from "./LibProtocolXConstants.sol";
import {LibTokenDistributor} from "./LibTokenDistributor.sol";
import {LibProtocolXFeesManager} from "./LibProtocolXFeesManager.sol";
import {LibUtils} from "./LibUtils.sol";
import {LibContext} from "./LibContext.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @dev Main presale library handling the investment and redeeming of the rewards.
 */
library LibProtocolX {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    struct Storage {
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 totalFee;
        uint256 rebaseRate;
        uint256 INDEX;
        uint256 lastRebasedTime;
        uint256 lastAddLiquidityTime;
        uint256 gonsPerFragment;
        uint256 autoLiquidityAmount;
        address autoLiquidityReceiver;
        address treasuryReceiver;
        address protocolxInsuranceFundReceiver;
        address afterburner;
        address pair;
        bool swapEnabled;
        bool autoRebase;
        bool autoAddLiquidity;
        bool inSwap;
        mapping(address => bool) isFeeExempt;
        mapping(address => bool) blacklist;
        mapping(address => uint256) gonBalances; // mapping of address to gonBalances
        mapping(address => mapping(address => uint256)) allowedFragments; //amount of ptx an address is allowed
        mapping(address => bool) addressExcludeFromRebase;
        IUniswapV2Router02 router;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("ProtocolX.contracts.Libraries.LibProtocolX");

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    /**
     * @dev ERC20 transfer event. Emitted when issued after investment.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    //events
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapBack(
        uint256 contractTokenBalance,
        uint256 amountETHToTreasuryAndTIF
    );
    event SetRebaseRate(uint256 indexed rebaseRate);
    event UpdateAutoRebaseStatus(bool status);
    event UpdateAutoAddLiquidityStatus(bool status);
    event UpdateFeeReceivers(
        address liquidityReceiver,
        address treasuryReceiver,
        address insuranceFundReceiver,
        address afterburner
    );

    event UpdateAddressBlackListed(address botAddress, bool flag);
    event UpdateFeeExempt(address addr, bool flag);
    event UpdatedExcludeFromRebase(address addr, bool flag);
    event GenericErrorEvent(string reason);

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 starttime_,
        address router_,
        uint256 liquiditiyFee,
        uint256 treasuryFee,
        uint256 insuranceFundFee,
        uint256 sellAfterBurnerFee
    ) internal {
        Storage storage s = _storage();

        s.name = name_;
        s.symbol = symbol_;

        s.router = IUniswapV2Router02(router_);

        s.totalSupply = LibPrototcolXConstants.INITIAL_FRAGMENTS_SUPPLY;
        s.gonBalances[address(this)] = LibPrototcolXConstants.TOTAL_GONS;
        //s.gonBalances[s.treasuryReceiver] = LibPrototcolXConstants.TOTAL_GONS;
        s.gonsPerFragment = LibPrototcolXConstants.TOTAL_GONS.div(
            s.totalSupply
        );

        s.lastRebasedTime = starttime_ > block.timestamp
            ? starttime_
            : block.timestamp;

        s.isFeeExempt[s.treasuryReceiver] = true;
        s.isFeeExempt[address(this)] = true;

        s.router = IUniswapV2Router02(router_); 
        s.pair = IUniswapV2Factory(s.router.factory()).createPair(s.router.WETH(), address(this));

        LibProtocolXFeesManager.add(keccak256("LIQUIDITY_FEE"), liquiditiyFee);
        LibProtocolXFeesManager.add(keccak256("TREASURY_FEE"), treasuryFee);
        LibProtocolXFeesManager.add(keccak256("INSURANCE_FUND_FEE"), insuranceFundFee);
        LibProtocolXFeesManager.add(
            keccak256("SELL_AFTER_BURNER_FEE"),
            sellAfterBurnerFee
        );

        s.totalFee = liquiditiyFee.add(treasuryFee).add(insuranceFundFee).add(
            sellAfterBurnerFee
        );

        s.INDEX = gonsForBalance(10**LibPrototcolXConstants.DECIMALS);

        emit Transfer(address(0x0), s.treasuryReceiver, s.totalSupply);
    }

    /**
     * @notice router and pair addres must exist
     * @dev set the allowed fragments
     * @param pair address of the pair
     */
    function setAllowedFragments(address pair) internal {
        Storage storage s = _storage();
        require(pair != address(0), "router address cannot be empty");

        s.pair = pair;

        s.allowedFragments[address(this)][address(s.router)] = type(uint256).max;
        s.allowedFragments[address(this)][pair] = type(uint256).max;
    }

    //ERC20Controller
    function totalSupply() internal view returns (uint256) {
        Storage storage s = _storage();
        return s.totalSupply;
    }

    function name() internal view returns (string memory) {
        Storage storage s = _storage();
        return s.name;
    }

    function symbol() internal view returns (string memory) {
        Storage storage s = _storage();
        return s.symbol;
    }

    function balanceOf(address account) internal view returns (uint256) {
        Storage storage s = _storage();
        return s.gonBalances[account].div(s.gonsPerFragment);
    }

    function allowance(address owner_, address spender)
        internal
        view
        returns (uint256)
    {
        Storage storage s = _storage();
        return s.allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 value) internal returns (bool) {
        Storage storage s = _storage();
        address sender = LibContext.msgSender();

        require(
            spender != address(0),
            "ProtocolX: spender is the zero address"
        );
        s.allowedFragments[sender][spender] = value;
        emit Approval(sender, spender, value);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        internal
        returns (bool)
    {
        Storage storage s = _storage();
        address sender = LibContext.msgSender();

        uint256 oldValue = s.allowedFragments[sender][spender];
        if (subtractedValue >= oldValue) {
            s.allowedFragments[sender][spender] = 0;
        } else {
            s.allowedFragments[sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(sender, spender, s.allowedFragments[sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        internal
        returns (bool)
    {
        Storage storage s = _storage();
        address sender = LibContext.msgSender();

        s.allowedFragments[sender][spender] = s
        .allowedFragments[sender][spender].add(addedValue);
        emit Approval(sender, spender, s.allowedFragments[sender][spender]);
        return true;
    }

    function transfer(address to, uint256 value) internal returns (bool) {
        enforceValidRecipient(to);

        _transferFrom(LibContext.msgSender(), to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        enforceValidRecipient(to);

        Storage storage s = _storage();
        address sender = LibContext.msgSender();
        if (s.allowedFragments[from][sender] != type(uint256).max) {
            s.allowedFragments[from][sender] = s
            .allowedFragments[from][sender].sub(
                    value,
                    "Insufficient Allowance"
                );
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        Storage storage s = _storage();

        require(
            !s.blacklist[sender] && !s.blacklist[recipient],
            "in_blacklist"
        );

        if (s.inSwap) {
            return basicTransfer(sender, recipient, amount);
        }

        if (!s.addressExcludeFromRebase[sender]) {
            if (shouldRebase()) {
                rebase();
            }
        }

        if (shouldAddLiquidity()) {
            s.inSwap = true;
            addLiquidity();
            s.inSwap = false;
        } else if (shouldSwapBack()) {
            s.inSwap = true;
            swapBack();
            s.inSwap = false;
        }

        uint256 gonAmount = amount.mul(s.gonsPerFragment);
        s.gonBalances[sender] = s.gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        s.gonBalances[recipient] = s.gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(s.gonsPerFragment)
        );

        return true;
    }

    ///ERC20

    /**
     * @dev Transfer function
     */
    function basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        Storage storage s = _storage();

        uint256 gonAmount = amount.mul(s.gonsPerFragment);
        s.gonBalances[from] = s.gonBalances[from].sub(gonAmount);
        s.gonBalances[to] = s.gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    /**
     * @notice calculates the fee amount
     * @return the totaal amount deducting from fees
     */
    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        Storage storage s = _storage();

        uint256 _totalFee = s.totalFee;
        uint256 _afterburnerFee = LibProtocolXFeesManager.get(
            keccak256("AFTER_BURNER_FEE")
        );
        uint256 _sellAfterBurnerFee = LibProtocolXFeesManager.get(
            keccak256("SELL_AFTER_BURNER_FEE")
        );

        if (recipient == s.pair) {
            _totalFee = _totalFee
                .add(LibProtocolXFeesManager.get(keccak256("SELL_FEE")))
                .add(_sellAfterBurnerFee);
            _afterburnerFee = _afterburnerFee.add(_sellAfterBurnerFee);
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(
            LibPrototcolXConstants.feeDenominator
        );
        uint256 afterburnerFeeAmount = gonAmount.mul(_afterburnerFee).div(
            LibPrototcolXConstants.feeDenominator
        );

        s.gonBalances[s.afterburner] = s.gonBalances[s.afterburner].add(
            afterburnerFeeAmount
        );
        s.gonBalances[address(this)] = s.gonBalances[address(this)].add(
            feeAmount.sub(afterburnerFeeAmount)
        );

        s.autoLiquidityAmount = s.autoLiquidityAmount.add(
            gonAmount
                .mul(LibProtocolXFeesManager.get(keccak256("LIQUIDITY_FEE")))
                .div(LibPrototcolXConstants.feeDenominator)
        );

        emit Transfer(sender, address(this), feeAmount.div(s.gonsPerFragment));

        return gonAmount.sub(feeAmount);
    }

    /**
     * @notice rebase, updates the total supply
     * @dev @var inSwap must be true, else will return
     */
    function rebase() internal {
        Storage storage s = _storage();

        if (s.inSwap) return;

        uint256 deltaTime = block.timestamp - s.lastRebasedTime;
        uint256 times = deltaTime.div(30 minutes);
        uint256 epoch = times.mul(30);

        for (uint256 i = 0; i < times; i++) {
            s.totalSupply = s
                .totalSupply
                .mul(
                    (10**LibPrototcolXConstants.RATE_DECIMALS).add(s.rebaseRate)
                )
                .div(10**LibPrototcolXConstants.RATE_DECIMALS);
        }

        if (s.totalSupply > LibPrototcolXConstants.MAX_SUPPLY) {
            s.totalSupply = LibPrototcolXConstants.MAX_SUPPLY;
        }

        s.gonsPerFragment = LibPrototcolXConstants.TOTAL_GONS.div(
            s.totalSupply
        );

        s.lastRebasedTime = s.lastRebasedTime.add(times.mul(30 minutes));

        IUniswapV2Pair(s.pair).sync();

        emit LogRebase(epoch, s.totalSupply);
    }

    /**
     * @notice Adds liquidity to the lp
     * @dev Uses the IUniswapV2Router02 to swap
     */
    function addLiquidity() internal {
        Storage storage s = _storage();

        if (s.autoLiquidityAmount > s.gonBalances[address(this)]) {
            s.autoLiquidityAmount = s.gonBalances[address(this)];
        }

        uint256 autoLiquidityAmount = s.autoLiquidityAmount.div(
            s.gonsPerFragment
        );

        s.autoLiquidityAmount = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if (amountToSwap == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = s.router.WETH();

        uint256 balanceBefore = address(this).balance;

        s.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            s.router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                s.autoLiquidityReceiver,
                block.timestamp
            );
        }
        s.lastAddLiquidityTime = block.timestamp;
    }

    /**
     * @notice Adds liquidity to the lp
     * @dev Uses the IUniswapV2Router02 to swap
     */
    function swapBack() internal {
        Storage storage s = _storage();

        if (s.autoLiquidityAmount > s.gonBalances[address(this)]) {
            s.autoLiquidityAmount = s.gonBalances[address(this)];
        }

        uint256 amountToSwap = (
            s.gonBalances[address(this)].sub(s.autoLiquidityAmount)
        ).div(s.gonsPerFragment);

        if (amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = s.router.WETH();

        s.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToTreasuryAndTIF = address(this).balance.sub(
            balanceBefore
        );

        uint256 mainSellFee = LibProtocolXFeesManager.get(
            keccak256("SELL_FEE")
        );

        uint256 _sellFee = LibProtocolXFeesManager
            .get(keccak256("TREASURY_FEE"))
            .add(LibProtocolXFeesManager.get(keccak256("INSURANCE_FUND_FEE")))
            .add(mainSellFee);
        uint256 _buyFee = LibProtocolXFeesManager
            .get(keccak256("TREASURY_FEE"))
            .add(LibProtocolXFeesManager.get(keccak256("INSURANCE_FUND_FEE")));

        uint256 _tifFee = amountETHToTreasuryAndTIF
            .mul(
                LibProtocolXFeesManager
                    .get(keccak256("INSURANCE_FUND_FEE"))
                    .mul(2)
                    .add(mainSellFee)
            )
            .div(_sellFee.add(_buyFee));

        LibTokenDistributor.transfer(
            keccak256("INSURANCE_FUND_RECEIVER"),
            s.protocolxInsuranceFundReceiver,
            _tifFee
        );

        LibTokenDistributor.transfer(
            keccak256("TREASURY_RECEIVER"),
            s.treasuryReceiver,
            amountETHToTreasuryAndTIF.sub(_tifFee)
        );

        emit SwapBack(amountToSwap, amountETHToTreasuryAndTIF);
    }

    /** Admin Functions */

    /**
     * @notice Calling IUniswapV2Pair sync function
     * @dev Force reserves to match balances
     */
    function manualSync() internal {
        try IUniswapV2Pair(_storage().pair).sync() {} catch Error(
            string memory reason
        ) {
            emit GenericErrorEvent("manualSync(): pair.sync() Failed");
            emit GenericErrorEvent(reason);
        }
    }

    /**
     * @dev  Set the AutoRebase state
     * @param _flag bool
     */
    function setAutoRebase(bool _flag) internal {
        Storage storage s = _storage();

        require(s.autoRebase != _flag, "Not changed");

        if (_flag) {
            s.lastRebasedTime = block.timestamp;
        }
        s.autoRebase = _flag;

        emit UpdateAutoRebaseStatus(_flag);
    }

    /**
     * @dev  Set the Auto add liquidty state
     * @param _flag bool
     */
    function setAutoAddLiquidity(bool _flag) internal {
        Storage storage s = _storage();

        require(s.autoAddLiquidity != _flag, "Not changed");
        if (_flag) {
            s.lastAddLiquidityTime = block.timestamp;
        }
        s.autoAddLiquidity = _flag;

        emit UpdateAutoAddLiquidityStatus(_flag);
    }

    /**
     * @dev Set the rebase rate
     * @param _rebaseRate rebase rate
     */
    function setRebaseRate(uint256 _rebaseRate) internal {
        Storage storage s = _storage();

        require(s.rebaseRate != _rebaseRate, "not changed");
        require(
            _rebaseRate < LibPrototcolXConstants.MAXREBASERATE, 
            "cannot be greater than max"
        );
        require(
            _rebaseRate > LibPrototcolXConstants.MINREBASERATE, 
            "cannot be less than min"
        );
        
        s.rebaseRate = _rebaseRate;

        emit SetRebaseRate(_rebaseRate);
    }

    /**
     * @dev set the addresses of receivers
     *
     */
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _protocolxInsuranceFundReceiver,
        address _afterburner
    ) internal {
        require(
            _autoLiquidityReceiver != address(0x0),
            "Invalid _autoLiquidityReceiver"
        );
        require(_treasuryReceiver != address(0x0), "Invalid _treasuryReceiver");
        require(
            _protocolxInsuranceFundReceiver != address(0x0),
            "Invalid _protocolxInsuranceFundReceiver"
        );
        require(_afterburner != address(0x0), "Invalid _afterburner");

        Storage storage s = _storage();

        s.autoLiquidityReceiver = _autoLiquidityReceiver;
        s.treasuryReceiver = _treasuryReceiver;
        s.protocolxInsuranceFundReceiver = _protocolxInsuranceFundReceiver;
        s.afterburner = _afterburner;

        emit UpdateFeeReceivers(
            _autoLiquidityReceiver,
            _treasuryReceiver,
            _protocolxInsuranceFundReceiver,
            _afterburner
        );
    }

    /**
     * @dev set an address to be excluded from rebase
     * @param _addr address of account
     * @param _flag bool
     */
    function setExcludeFromRebase(address _addr, bool _flag) internal {
        _storage().addressExcludeFromRebase[_addr] = _flag;
        emit UpdatedExcludeFromRebase(_addr, _flag);
    }

    /**
     * @dev set an address to no pay fees
     * @param _addr address of account
     * @param _flag bool
     */
    function setFeeExempt(address _addr, bool _flag) internal {
        _storage().isFeeExempt[_addr] = _flag;
        emit UpdateFeeExempt(_addr, _flag);
    }

    /**
     * @dev set an address as blacklisted
     * @param account address of account
     * @param _flag bool
     */
    function setBlacklisted(address account, bool _flag) internal {
        require(!isContract(account), "only wallet address");
        _storage().blacklist[account] = _flag;

        emit UpdateAddressBlackListed(account, _flag);
    }

    /* VIEW FUNCTIONS */

    function index() internal view returns (uint256) {
        return balanceForGons(_storage().INDEX);
    }

    /**
     * @dev Get the number of fragments per token
     * @param amount token 
     */
    function gonsForBalance(uint256 amount) internal view returns (uint256) {
        return amount.mul(_storage().gonsPerFragment);
    }

    /**
     * @notice Get the number tokens for by fragment
     * @dev The return balance of gonsForBalance() will is the equivalent 
     * @param gons full amount of fragments to equal 1 token
     */
    function balanceForGons(uint256 gons) internal view returns (uint256) {
        return gons.div(_storage().gonsPerFragment);
    }

    /**
     * @dev Get the Circulating Supply of tokens
     *      not including tokens from DEAD/ZERO wallets
     */
    function getCirculatingSupply() internal view returns (uint256) {
        Storage storage s = _storage();
        uint256 circulatingSupply = LibPrototcolXConstants.TOTAL_GONS.sub(s.gonBalances[LibPrototcolXConstants.DEAD]);
         
        return balanceForGons(circulatingSupply);
        //return (LibPrototcolXConstants.TOTAL_GONS.sub(s.gonBalances[LibPrototcolXConstants.DEAD]).sub(s.gonBalances[LibPrototcolXConstants.ZERO])).div(s.gonsPerFragment);
    }

    /**
     * @dev get the liquidity backing 
     */
    function getLiquidityBacking(uint256 accuracy)
        internal
        view
        returns (uint256)
    {
        Storage storage s = _storage();
        uint256 liquidityBalance = balanceOf(s.pair);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    /* HELPER FUNCTIONS */

        /**
     * @dev Get the AutoRebase state
     */
    function getAutoRebaseState() internal view returns (bool) {
        return _storage().autoRebase;
    }

    /**
     * @dev Get the AutoLiquidity state
     */
    function getAutoLiquidityState() internal view returns (bool) {
        return _storage().autoAddLiquidity;
    }

    /**
     * @dev Get the rebase State
     */
    function getRebaseRate() internal view returns (uint256) {
        return _storage().rebaseRate;
    }

    /**
     * @dev Get the rebase State
     */
    function getGonsPerFragment() internal view returns (uint256) {
        return _storage().gonsPerFragment;
    }

    /**
     * @dev Get the total gons State
     */
    function getTotalGons() internal pure returns (uint256) {
        return LibPrototcolXConstants.TOTAL_GONS;
    }

    /**
     * @dev Enforce that the recipient is not zero address
     * @param to address of recipient
     */
    function enforceValidRecipient(address to) internal pure {
        if (to == address(0x0)) {
            revert("invalid address");
        }
    }

    /**
     * @dev Check if the address does not have to pay a fee
     * @param _addr address to checks
     */
    function checkFeeExempt(address _addr) internal view returns (bool) {
        return _storage().isFeeExempt[_addr];
    }

    /**
     * @dev Check if the address is blacklisted
     * @param _addr address to check
     */
    function checkBlacklisted(address _addr) internal view returns (bool) {
        return _storage().blacklist[_addr];
    }

    /**
     * @dev Check if the address is excluded from rebase
     * @param _addr address to check
     */
    function checkExcludedFromRebase(address _addr) internal view returns (bool) {
        return _storage().addressExcludeFromRebase[_addr];
    }

    /**
     * @dev checks if needs to rebase
     */
    function shouldRebase() internal view returns (bool) {
        Storage storage s = _storage();
        return
            s.autoRebase &&
            (s.totalSupply < LibPrototcolXConstants.MAX_SUPPLY) &&
            LibContext.msgSender() != s.pair &&
            !s.inSwap &&
            block.timestamp >= (s.lastRebasedTime + 30 minutes);
    }

    /**
     * @notice checks if needs to add liquidity
     * @dev autoliquidity needs to be true, inSwap needs to be false,
     *      sender address cannot be the pair address, timestamp must be greater than lastAddlLiquidity plus 12 hours
     */
    function shouldAddLiquidity() internal view returns (bool) {
        Storage storage s = _storage();
        return
            s.autoAddLiquidity &&
            !s.inSwap &&
            LibContext.msgSender() != s.pair &&
            block.timestamp >= (s.lastAddLiquidityTime + 12 hours);
    }

    /**
     * @dev checks if needs to swap back
     */
    function shouldSwapBack() internal view returns (bool) {
        Storage storage s = _storage();
        return !s.inSwap && LibContext.msgSender() != s.pair;
    }

    /**
     * @dev checks if needs to take fee
     */
    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        Storage storage s = _storage();

        return (s.pair == from || s.pair == to) && !s.isFeeExempt[from];
    }

    /**
     * @dev checks to see if address is a contract
     * @param @addr address
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /** Create Pair */
    function createPair () internal returns (address) {
        Storage storage s = _storage();
        s.router = IUniswapV2Router02(0x6B45064F128cA5ADdbf79825186F4e3e3c9E7EB5); 
        s.pair = IUniswapV2Factory(s.router.factory()).createPair(s.router.WETH(), address(this));
        return s.pair;
    }
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

/**
 * @dev Library with a set of default roles to use across different other contracts.
 */
library LibPrototcolXConstants {
    uint256 internal constant DECIMALS = 5;
    uint8 internal constant RATE_DECIMALS = 7;

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant ZERO = address(0);

    uint256 internal constant MAXSELLFEE = 100;
    uint256 internal constant MAXREBASERATE = 10000;
    uint256 internal constant MINREBASERATE = 20;

    uint256 internal constant MAX_UINT256 = type(uint256).max;
    uint256 internal constant MAX_SUPPLY = type(uint128).max;
    uint256 internal constant INITIAL_FRAGMENTS_SUPPLY =
        40 * 10**6 * 10**DECIMALS;
    uint256 internal constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 internal constant feeDenominator = 1000;
    
    // LibUtils
    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

library LibProtocolXFeesManager {

    struct Storage {
        mapping(bytes32 => uint256) feeMap;
    }

    bytes32 private constant STORAGE_SLOT =
        keccak256(
            "protocolx.contracts.Libraries.LibProtocolXFeesManager"
        );

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    event FeeAdded(bytes32 id, uint256 feeAmount);

    error FeeAlreadyExists(bytes32 id);
    error FeeNotFound(bytes32 id);

    function add(bytes32 feeId, uint256 feeAmount) internal {
        require(feeId != "" && feeAmount > 0, "Params cannot be empty");

        if (_storage().feeMap[feeId] > 0) {
            revert FeeAlreadyExists(feeId);
        }

        _storage().feeMap[feeId] = feeAmount;
        emit FeeAdded(feeId, feeAmount);
    }

    function updateFeeMap(bytes32 feeId, uint256 feeAmount) internal {
        require(feeId[0] != 0 && feeAmount > 0, "Params cannot be empty");

        if (_storage().feeMap[feeId] == 0) {
            revert FeeNotFound(feeId);
        }

        _storage().feeMap[feeId] = feeAmount;
    }

    function get(bytes32 feeId)
        internal
        view
        returns (uint256 feeAmount)
    {
        feeAmount = _storage().feeMap[feeId];

        if (feeAmount == 0) {
            revert FeeNotFound(feeId);
        }
    }

}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {ITokenDitributor} from "../Interfaces/ITokenDistributor.sol";
import {LibUtils} from "@solarprotocol/presale/contracts/LibUtils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library LibTokenDistributor {
    using SafeERC20 for IERC20;

    struct Storage {
        mapping(bytes32 => ITokenDitributor.Strategy) strategyMap;
    }

    bytes32 private constant STORAGE_SLOT =
        keccak256(
            "protocolx.contracts.Libraries.LibTokenDistributor"
        );

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    error StrategyAlreadyExists(bytes32 id);
    error StrategyHasNoDistributions();
    error StrategyDistributionPortionsNot100();
    error StrategyDistributionsLengthMissmatch();
    error StrategyNotFound(bytes32 id);

    function add(bytes32 strategyId, ITokenDitributor.Strategy memory strategy)
        internal
    {
        if (address(_storage().strategyMap[strategyId].token) != address(0)) {
            revert StrategyAlreadyExists(strategyId);
        }

        if (address(strategy.token) != address(this)) {
            LibUtils.validateERC20(address(strategy.token));
        }

        _storage().strategyMap[strategyId].token = strategy.token;

        if (strategy.distributions.length == 0) {
            revert StrategyHasNoDistributions();
        }

        uint256 sum = 0;
        for (
            uint256 index = 0;
            index < strategy.distributions.length;
            ++index
        ) {
            sum += strategy.distributions[index].proportion;
            _storage().strategyMap[strategyId].distributions.push(
                strategy.distributions[index]
            );
        }

        if (sum != 100) {
            revert StrategyDistributionPortionsNot100();
        }
    }

    function updateDistributions(
        bytes32 strategyId,
        ITokenDitributor.Distribution[] memory distributions
    ) internal {
        ITokenDitributor.Strategy memory strategy = _storage().strategyMap[
            strategyId
        ];

        if (address(strategy.token) == address(0)) {
            revert StrategyNotFound(strategyId);
        }

        if (distributions.length == 0) {
            revert StrategyHasNoDistributions();
        }

        if (strategy.distributions.length != distributions.length) {
            revert StrategyDistributionsLengthMissmatch();
        }

        uint256 sum = 0;
        for (uint256 index = 0; index < distributions.length; ++index) {
            sum += distributions[index].proportion;
            _storage().strategyMap[strategyId].distributions[
                index
            ] = distributions[index];
        }

        if (sum != 100) {
            revert StrategyDistributionPortionsNot100();
        }
    }

    function get(bytes32 strategyId)
        internal
        view
        returns (ITokenDitributor.Strategy memory strategy)
    {
        strategy = _storage().strategyMap[strategyId];

        if (address(strategy.token) == address(0)) {
            revert StrategyNotFound(strategyId);
        }
    }

    function transfer(
        bytes32 strategyId,
        address from,
        uint256 amount
    ) internal {
        ITokenDitributor.Strategy memory strategy = _storage().strategyMap[
            strategyId
        ];
        if (address(strategy.token) == address(0)) {
            revert StrategyNotFound(strategyId);
        }

        for (
            uint256 index = 0;
            index < strategy.distributions.length;
            ++index
        ) {
            ITokenDitributor.Distribution memory distribution = strategy
                .distributions[index];
            sendToken(
                strategy.token,
                from,
                distribution.destination,
                (amount * distribution.proportion) / 100
            );
        }
    }

    function sendToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        token.safeTransferFrom(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {LibPrototcolXConstants} from "./LibProtocolXConstants.sol";
import {LibContext} from "@solarprotocol/libraries/contracts/utils/LibContext.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

/**
 * @dev Collection of helpers for parameter validation.
 */
library LibUtils {
    using Address for address;

    error NotOwner(address address_);
    error NotContract(address address_);
    error NotERC20(address address_);

    function validateERC20(address token) internal view {
        if (!token.isContract()) {
            revert NotContract(token);
        }

        (bool successName, ) = token.staticcall(
            abi.encodeWithSignature("name()")
        );
        if (!successName) {
            revert NotERC20(token);
        }

        (bool successBalanceOf, ) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(1))
        );
        if (!successBalanceOf) {
            revert NotERC20(token);
        }
    }

    function enforceIsContractOwner() internal view {
        address address_ = LibContext.msgSender();

        if (address_ != getOwner()) {
            revert NotOwner(address_);
        }
    }

    function getOwner() internal view returns (address adminAddress) {
        return StorageSlot.getAddressSlot(LibPrototcolXConstants._ADMIN_SLOT).value;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ProtocolXAdminController} from "../contracts/Controllers/ProtocolXAdminController.sol";
import {ProtocolXGettersController} from "../contracts/Controllers/ProtocolXGettersController.sol";
import {ProtocolXFeeManagerAdminController} from "../contracts/Controllers/ProtocolXFeeManagerAdminController.sol";
import {ProtocolXFeeManagerGetterController} from "../contracts/Controllers/ProtocolXFeeManagerGetterController.sol";
import {ERC20Controller} from "../contracts/Controllers/ERC20Controller.sol";

/**
 * @dev Main contract assembling all the controllers.
 *
 * Attention: Initializable is the only contract that does not use the
 * Diamond Storage pattern and MUST be on first possition ALLWAYS!!!
 */
 
 /* tslint:disable:no-empty */ 
contract ProtocolX is
    Initializable,
    ProtocolXFeeManagerAdminController,
    ProtocolXAdminController,
    ProtocolXGettersController,
    ProtocolXFeeManagerGetterController,
    ERC20Controller
{}