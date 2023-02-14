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

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Snapshot.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Arrays.sol";
import "../../../utils/Counters.sol";

/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * NOTE: Snapshot policy can be customized by overriding the {_getCurrentSnapshotId} method. For example, having it
 * return `block.number` will trigger the creation of snapshot at the begining of each new block. When overridding this
 * function, be careful about the monotonicity of its result. Non-monotonic snapshot ids will break the contract.
 *
 * Implementing snapshots for every block using this method will incur significant gas costs. For a gas-efficient
 * alternative consider {ERC20Votes}.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */

abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // burn
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Arrays.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

uint256 constant YEAR = 1 days * 365;

uint256 constant PERCENTAGE_100 = 10 ** 27;
uint256 constant PRECISION = 10 ** 25;
uint256 constant DECIMALS = 10 ** 18;

uint256 constant MAX_UINT = type(uint256).max;

address constant ETHEREUM_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/gov/validators/IGovValidators.sol";

import "./GovValidatorsToken.sol";

import "../../libs/math/MathHelper.sol";
import "../../core/Globals.sol";

contract GovValidators is IGovValidators, OwnableUpgradeable {
    using Math for uint256;
    using MathHelper for uint256;

    GovValidatorsToken public govValidatorsToken;

    InternalProposalSettings public internalProposalSettings;

    uint256 public override latestInternalProposalId;
    uint256 public validatorsCount;

    mapping(uint256 => InternalProposal) internal _internalProposals; // proposalId => info
    mapping(uint256 => ExternalProposal) internal _externalProposals; // proposalId => info

    mapping(uint256 => mapping(bool => mapping(address => uint256))) public addressVoted; // proposalId => isInternal => user => voted amount

    event ExternalProposalCreated(uint256 proposalId, uint256 quorum);
    event InternalProposalCreated(
        uint256 proposalId,
        string proposalDescription,
        uint256 quorum,
        address sender
    );
    event InternalProposalExecuted(uint256 proposalId, address executor);

    event Voted(uint256 proposalId, address sender, uint256 vote, bool isInternal);
    event ChangedValidatorsBalances(address[] validators, uint256[] newBalance);

    /// @dev Access only for addresses that have validator tokens
    modifier onlyValidator() {
        _onlyValidator();
        _;
    }

    function __GovValidators_init(
        string calldata name,
        string calldata symbol,
        uint64 duration,
        uint128 quorum,
        address[] calldata validators,
        uint256[] calldata balances
    ) external initializer {
        __Ownable_init();

        require(validators.length == balances.length, "Validators: invalid array length");
        require(duration > 0, "Validators: duration is zero");
        require(quorum <= PERCENTAGE_100, "Validators: invalid quorum value");

        govValidatorsToken = new GovValidatorsToken(name, symbol);

        internalProposalSettings.duration = duration;
        internalProposalSettings.quorum = quorum;

        _changeBalances(balances, validators);
    }

    function createInternalProposal(
        ProposalType proposalType,
        string calldata descriptionURL,
        uint256[] calldata newValues,
        address[] calldata users
    ) external override onlyValidator {
        if (proposalType == ProposalType.ChangeInternalDuration) {
            require(newValues[0] > 0, "Validators: invalid duration value");
        } else if (proposalType == ProposalType.ChangeInternalQuorum) {
            require(newValues[0] <= PERCENTAGE_100, "Validators: invalid quorum value");
        } else if (proposalType == ProposalType.ChangeInternalDurationAndQuorum) {
            require(
                newValues[0] > 0 && newValues[1] <= PERCENTAGE_100,
                "Validators: invalid duration or quorum values"
            );
        } else {
            require(newValues.length == users.length, "Validators: invalid length");

            for (uint256 i = 0; i < users.length; i++) {
                require(users[i] != address(0), "Validators: invalid address");
            }
        }

        _internalProposals[++latestInternalProposalId] = InternalProposal({
            proposalType: proposalType,
            core: ProposalCore({
                voteEnd: uint64(block.timestamp + internalProposalSettings.duration),
                executed: false,
                quorum: internalProposalSettings.quorum,
                votesFor: 0,
                snapshotId: uint32(govValidatorsToken.snapshot())
            }),
            descriptionURL: descriptionURL,
            newValues: newValues,
            userAddresses: users
        });

        emit InternalProposalCreated(
            latestInternalProposalId,
            descriptionURL,
            internalProposalSettings.quorum,
            msg.sender
        );
    }

    function createExternalProposal(
        uint256 proposalId,
        uint64 duration,
        uint128 quorum
    ) external override onlyOwner {
        require(!_proposalExists(proposalId, false), "Validators: proposal already exists");

        _externalProposals[proposalId] = ExternalProposal({
            core: ProposalCore({
                voteEnd: uint64(block.timestamp + duration),
                executed: false,
                quorum: quorum,
                votesFor: 0,
                snapshotId: uint32(govValidatorsToken.snapshot())
            })
        });

        emit ExternalProposalCreated(proposalId, quorum);
    }

    function changeBalances(
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external override onlyOwner {
        _changeBalances(newValues, userAddresses);
    }

    function vote(
        uint256 proposalId,
        uint256 amount,
        bool isInternal
    ) external override onlyValidator {
        require(_proposalExists(proposalId, isInternal), "Validators: proposal does not exist");

        ProposalCore storage core = isInternal
            ? _internalProposals[proposalId].core
            : _externalProposals[proposalId].core;

        require(_getProposalState(core) == ProposalState.Voting, "Validators: not Voting state");

        uint256 balanceAt = govValidatorsToken.balanceOfAt(msg.sender, core.snapshotId);
        uint256 voted = addressVoted[proposalId][isInternal][msg.sender];

        require(amount + voted <= balanceAt, "Validators: excessive vote amount");

        addressVoted[proposalId][isInternal][msg.sender] += amount;

        core.votesFor += amount;

        emit Voted(proposalId, msg.sender, amount, isInternal);
    }

    function execute(uint256 proposalId) external override {
        require(_proposalExists(proposalId, true), "Validators: proposal does not exist");

        InternalProposal storage proposal = _internalProposals[proposalId];

        require(
            _getProposalState(proposal.core) == ProposalState.Succeeded,
            "Validators: not Succeeded state"
        );

        proposal.core.executed = true;

        ProposalType proposalType = proposal.proposalType;

        if (proposalType == ProposalType.ChangeInternalDuration) {
            internalProposalSettings.duration = uint64(proposal.newValues[0]);
        } else if (proposalType == ProposalType.ChangeInternalQuorum) {
            internalProposalSettings.quorum = uint128(proposal.newValues[0]);
        } else if (proposalType == ProposalType.ChangeInternalDurationAndQuorum) {
            internalProposalSettings.duration = uint64(proposal.newValues[0]);
            internalProposalSettings.quorum = uint128(proposal.newValues[1]);
        } else {
            _changeBalances(proposal.newValues, proposal.userAddresses);
        }

        emit InternalProposalExecuted(proposalId, msg.sender);
    }

    function getExternalProposal(
        uint256 index
    ) external view override returns (ExternalProposal memory) {
        return _externalProposals[index];
    }

    function getInternalProposals(
        uint256 offset,
        uint256 limit
    ) external view override returns (InternalProposalView[] memory internalProposals) {
        uint256 to = (offset + limit).min(latestInternalProposalId).max(offset);

        internalProposals = new InternalProposalView[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            internalProposals[i - offset] = InternalProposalView({
                proposal: _internalProposals[i + 1],
                proposalState: getProposalState(i + 1, true),
                requiredQuorum: getProposalRequiredQuorum(i + 1, true)
            });
        }
    }

    function getProposalState(
        uint256 proposalId,
        bool isInternal
    ) public view override returns (ProposalState) {
        if (!_proposalExists(proposalId, isInternal)) {
            return ProposalState.Undefined;
        }

        return
            isInternal
                ? _getProposalState(_internalProposals[proposalId].core)
                : _getProposalState(_externalProposals[proposalId].core);
    }

    function getProposalRequiredQuorum(
        uint256 proposalId,
        bool isInternal
    ) public view override returns (uint256) {
        ProposalCore storage core = isInternal
            ? _internalProposals[proposalId].core
            : _externalProposals[proposalId].core;

        if (core.voteEnd == 0) {
            return 0;
        }

        return
            govValidatorsToken.totalSupplyAt(core.snapshotId).ratio(core.quorum, PERCENTAGE_100);
    }

    function isValidator(address user) public view override returns (bool) {
        return govValidatorsToken.balanceOf(user) > 0;
    }

    function _getProposalState(ProposalCore storage core) internal view returns (ProposalState) {
        if (core.executed) {
            return ProposalState.Executed;
        }

        if (_isQuorumReached(core)) {
            return ProposalState.Succeeded;
        }

        if (core.voteEnd < block.timestamp) {
            return ProposalState.Defeated;
        }

        return ProposalState.Voting;
    }

    function _isQuorumReached(ProposalCore storage core) internal view returns (bool) {
        uint256 totalSupply = govValidatorsToken.totalSupplyAt(core.snapshotId);
        uint256 currentQuorum = PERCENTAGE_100.ratio(core.votesFor, totalSupply);

        return currentQuorum >= core.quorum;
    }

    function _proposalExists(uint256 proposalId, bool isInternal) internal view returns (bool) {
        return
            isInternal
                ? _internalProposals[proposalId].core.voteEnd != 0
                : _externalProposals[proposalId].core.voteEnd != 0;
    }

    function _changeBalances(uint256[] memory newValues, address[] memory userAddresses) internal {
        GovValidatorsToken validatorsToken = govValidatorsToken;
        uint256 length = newValues.length;

        uint256 validatorsCount_ = validatorsCount;

        for (uint256 i = 0; i < length; i++) {
            address user = userAddresses[i];
            uint256 newBalance = newValues[i];
            uint256 balance = validatorsToken.balanceOf(user);

            if (balance < newBalance) {
                validatorsToken.mint(user, newBalance - balance);

                if (balance == 0) {
                    validatorsCount_++;
                }
            } else if (balance > newBalance) {
                validatorsToken.burn(user, balance - newBalance);

                if (newBalance == 0) {
                    validatorsCount_--;
                }
            }
        }

        validatorsCount = validatorsCount_;

        emit ChangedValidatorsBalances(userAddresses, newValues);
    }

    function _onlyValidator() internal view {
        require(isValidator(msg.sender), "Validators: caller is not the validator");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

import "../../interfaces/gov/validators/IGovValidatorsToken.sol";

contract GovValidatorsToken is IGovValidatorsToken, ERC20Snapshot {
    address public immutable validator;

    modifier onlyValidator() {
        _onlyValidator();
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        validator = msg.sender;
    }

    function mint(address account, uint256 amount) external override onlyValidator {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external override onlyValidator {
        _burn(account, amount);
    }

    function snapshot() external override onlyValidator returns (uint256) {
        return _snapshot();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override onlyValidator {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _onlyValidator() internal view {
        require(validator == msg.sender, "ValidatorsToken: caller is not the validator");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the voting contract that is queried on the proposal's second voting stage
 */
interface IGovValidators {
    enum ProposalState {
        Voting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    enum ProposalType {
        ChangeInternalDuration,
        ChangeInternalQuorum,
        ChangeInternalDurationAndQuorum,
        ChangeBalances
    }

    /// @notice The struct holds information about settings for internal validators proposal
    /// @param duration the duration of voting
    /// @param quorum the percentage of validators token supply to confirm the proposal
    struct InternalProposalSettings {
        uint64 duration;
        uint128 quorum;
    }

    /// @notice The struct holds core properties of a proposal
    /// @param executed the boolean flag that indicated whether the proposal is executed or not
    /// @param snapshotId the id of snapshot
    /// @param voteEnd the timestamp of voting end of the proposal
    /// @param quorum the percentage of validators token supply to confirm the proposal
    /// @param votesFor the total number of votes in proposal from all voters
    struct ProposalCore {
        bool executed;
        uint32 snapshotId;
        uint64 voteEnd;
        uint128 quorum;
        uint256 votesFor;
    }

    /// @notice The struct holds information about the internal proposal
    /// @param proposalType the `ProposalType` enum
    /// @param core the struct that holds information about core properties of the proposal
    /// @param descriptionURL the string with link to IPFS doc with proposal description
    /// @param newValues the array of new values. Usage varies by proposal type
    /// @param userAddresses the array of user addresses
    struct InternalProposal {
        ProposalType proposalType;
        ProposalCore core;
        string descriptionURL;
        uint256[] newValues;
        address[] userAddresses;
    }

    /// @notice The struct holds information about the external proposal
    /// @param core the struct that holds information about core properties of a proposal
    struct ExternalProposal {
        ProposalCore core;
    }

    /// @notice The struct that is used in view functions of contract as a return argument
    /// @param proposal the `InternalProposal` struct
    /// @param proposalState the `ProposalState` enum
    /// @param requiredQuorum the percentage of validators token supply to confirm the proposal
    struct InternalProposalView {
        InternalProposal proposal;
        ProposalState proposalState;
        uint256 requiredQuorum;
    }

    /// @notice The function for getting the latest id of the internal proposal
    /// @return `id` of latest internal proposal
    function latestInternalProposalId() external view returns (uint256);

    /// @notice The function for getting current number of validators
    /// @return `number` of validators
    function validatorsCount() external view returns (uint256);

    /// @notice Create internal proposal for changing validators balances, base quorum, base duration
    /// @param proposalType `ProposalType`
    /// 0 - `ChangeInternalDuration`, change base duration
    /// 1 - `ChangeInternalQuorum`, change base quorum
    /// 2 - `ChangeInternalDurationAndQuorum`, change base duration and quorum
    /// 3 - `ChangeBalances`, change address balance
    /// @param newValues New values (tokens amounts array, quorum or duration or both)
    /// @param userAddresses Validators addresses, set it if `proposalType` == `ChangeBalances`
    function createInternalProposal(
        ProposalType proposalType,
        string calldata descriptionURL,
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external;

    /// @notice Create external proposal. This function can call only `Gov` contract
    /// @param proposalId Proposal ID from `Gov` contract
    /// @param duration Duration from `Gov` contract
    /// @param quorum Quorum from `Gov` contract
    function createExternalProposal(uint256 proposalId, uint64 duration, uint128 quorum) external;

    /// @notice The function for changing validators balances
    /// @param newValues the array of new balances
    /// @param userAddresses the array validators addresses
    function changeBalances(
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external;

    /// @notice Vote in proposal
    /// @param proposalId Proposal ID, internal or external
    /// @param amount Amount of tokens to vote
    /// @param isInternal If `true`, you will vote in internal proposal
    function vote(uint256 proposalId, uint256 amount, bool isInternal) external;

    /// @notice Only for internal proposals. External proposals should be executed from governance.
    /// @param proposalId Internal proposal ID
    function execute(uint256 proposalId) external;

    /// @notice The function for getting information about the external proposals
    /// @param index the index of proposal
    /// @return `ExternalProposal` struct
    function getExternalProposal(uint256 index) external view returns (ExternalProposal memory);

    /// @notice The function for getting information about internal proposals
    /// @param offset the starting proposal index
    /// @param limit the length of the observed proposals
    /// @return `InternalProposalView` struct array
    function getInternalProposals(
        uint256 offset,
        uint256 limit
    ) external view returns (InternalProposalView[] memory);

    /// @notice Return proposal state
    /// @dev Options:
    /// `Voting` - proposal where addresses can vote.
    /// `Defeated` - proposal where voting time is over and proposal defeated.
    /// `Succeeded` - proposal with the required number of votes.
    /// `Executed` - executed proposal (only for internal proposal).
    /// `Undefined` - nonexistent proposal.
    function getProposalState(
        uint256 proposalId,
        bool isInternal
    ) external view returns (ProposalState);

    /// @notice The function for getting proposal required quorum
    /// @param proposalId the id of proposal
    /// @param isInternal the boolean flag, if true then proposal is internal
    /// @return the number of votes to reach the quorum
    function getProposalRequiredQuorum(
        uint256 proposalId,
        bool isInternal
    ) external view returns (uint256);

    /// @notice The function that checks if a user is a validator
    /// @param user the address of a user
    /// @return `flag`, if true, than user is a validator
    function isValidator(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * This is the contract that determines the validators
 */
interface IGovValidatorsToken is IERC20 {
    /// @notice Mint new tokens, available only from `Validators` contract
    /// @param account Address
    /// @param amount Token amount to mint. Wei
    function mint(address account, uint256 amount) external;

    /// @notice Burn tokens, available only from `Validators` contract
    /// @param account Address
    /// @param amount Token amount to burn. Wei
    function burn(address account, uint256 amount) external;

    /// @notice Create tokens snapshot
    /// @return Snapshot ID
    function snapshot() external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../core/Globals.sol";

library MathHelper {
    /// @notice percent has to be multiplied by PRECISION
    function percentage(uint256 num, uint256 percent) internal pure returns (uint256) {
        return (num * percent) / PERCENTAGE_100;
    }

    function ratio(uint256 base, uint256 num, uint256 denom) internal pure returns (uint256) {
        return (base * num) / denom;
    }
}