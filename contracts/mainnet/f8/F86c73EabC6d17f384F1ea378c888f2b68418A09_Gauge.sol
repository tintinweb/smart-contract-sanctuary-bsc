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
     * @dev This empty reserved space is put in place to allow future versions to add new
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
interface IERC20Upgradeable {
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
pragma solidity 0.8.15;
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4/utils/math/Math.sol";
import "@openzeppelin/contracts-v4/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IBaseGauge.sol";

abstract contract BaseGauge is IBaseGauge, OwnableUpgradeable {
    IERC20 public immutable REWARD_TOKEN;
    //// @notice rewards are distributed over `duration` seconds when queued.
    uint256 public duration;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    /**
    @notice that are queued to be distributed on a `queueNewRewards` call
    @dev rewards are queued when an account `_updateReward`.
    */
    uint256 public queuedRewards;
    uint256 public currentRewards;
    uint256 public historicalRewards;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardsAdded(
        uint256 currentRewards,
        uint256 lastUpdateTime,
        uint256 periodFinish,
        uint256 rewardRate,
        uint256 historicalRewards
    );

    event RewardsQueued(address indexed from, uint256 amount);

    event RewardPaid(address indexed user, uint256 reward);
    event UpdatedRewards(
        address indexed account,
        uint256 rewardPerTokenStored,
        uint256 lastUpdateTime,
        uint256 rewards,
        uint256 userRewardPerTokenPaid
    );
    event Sweep(address indexed token, uint256 amount);

    event DurationUpdated(
        uint256 duration,
        uint256 rewardRate,
        uint256 periodFinish
    );

    function _newEarning(address) internal view virtual returns (uint256);

    function _updateReward(address) internal virtual;

    function _rewardPerToken() internal view virtual returns (uint256);

    modifier updateReward(address account) {
        _updateReward(account);
        _;
    }

    constructor(address _rewardsToken) {
        require(
            address(_rewardsToken) != address(0x0),
            "rewardsToken 0x0 address"
        );
        REWARD_TOKEN = IERC20(_rewardsToken);
    }

    function __initialize(address _owner) internal {
        require(_owner != address(0), "_owner 0x0 address");
        duration = 14 days;
        _transferOwnership(_owner);
    }

    /**
    @notice set the duration of the reward distribution.
    @param _newDuration duration in seconds. 
     */
    function setDuration(
        uint256 _newDuration
    ) external onlyOwner updateReward(address(0)) {
        require(_newDuration != 0, "duration should be greater than zero");
        if (block.timestamp < periodFinish) {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = leftover / _newDuration;
            periodFinish = block.timestamp + _newDuration;
        }
        duration = _newDuration;
        emit DurationUpdated(_newDuration, rewardRate, periodFinish);
    }

    /**
     *  @return timestamp until rewards are distributed
     */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /** @notice reward per token deposited
     *  @dev gives the total amount of rewards distributed since the inception of the pool.
     *  @return rewardPerToken
     */
    function rewardPerToken() external view returns (uint256) {
        return _rewardPerToken();
    }

    function _protectedTokens(
        address _token
    ) internal view virtual returns (bool) {
        return _token == address(REWARD_TOKEN);
    }

    /** @notice sweep tokens that are airdropped/transferred into the gauge.
     *  @dev sweep can only be done on non-protected tokens.
     *  @return _token to sweep
     */
    function sweep(address _token) external onlyOwner returns (bool) {
        require(_protectedTokens(_token) == false, "protected token");
        uint256 amount = IERC20(_token).balanceOf(address(this));

        SafeERC20.safeTransfer(IERC20(_token), owner(), amount);
        emit Sweep(_token, amount);
        return true;
    }

    /** @notice earnings for an account
     *  @dev earnings are based on lock duration and boost
     *  @return amount of tokens earned
     */
    function earned(address _account) external view virtual returns (uint256) {
        return _newEarning(_account);
    }

    /**
     * @notice
     * Add new rewards to be distributed over a week
     * @dev Trigger reward rate recalculation using `_amount` and queue rewards
     * @param _amount token to add to rewards
     * @return true
     */
    function queueNewRewards(uint256 _amount) external override returns (bool) {
        require(_amount != 0, "==0");
        SafeERC20.safeTransferFrom(
            IERC20(REWARD_TOKEN),
            msg.sender,
            address(this),
            _amount
        );
        emit RewardsQueued(msg.sender, _amount);
        _amount = _amount + queuedRewards;

        if (block.timestamp >= periodFinish) {
            _notifyRewardAmount(_amount);
            queuedRewards = 0;
            return true;
        }
        uint256 elapsedSinceBeginingOfPeriod = block.timestamp -
            (periodFinish - duration);
        uint256 distributedSoFar = elapsedSinceBeginingOfPeriod * rewardRate;
        // we only restart a new period if _amount is 120% of distributedSoFar.

        if ((distributedSoFar * 12) / 10 < _amount) {
            _notifyRewardAmount(_amount);
            queuedRewards = 0;
        } else {
            queuedRewards = _amount;
        }
        return true;
    }

    function _notifyRewardAmount(
        uint256 _reward
    ) internal updateReward(address(0)) {
        historicalRewards = historicalRewards + _reward;

        if (block.timestamp >= periodFinish) {
            rewardRate = _reward / duration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            _reward = _reward + leftover;
            rewardRate = _reward / duration;
        }
        currentRewards = _reward;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + duration;
        emit RewardsAdded(
            currentRewards,
            lastUpdateTime,
            periodFinish,
            rewardRate,
            historicalRewards
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./interfaces/IExtraReward.sol";
import "@openzeppelin/contracts-v4/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-v4/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-v4/utils/math/Math.sol";
import "./interfaces/IGauge.sol";
import "./BaseGauge.sol";
import "./interfaces/IVotingYFI.sol";
import "./interfaces/IOYfiRewardPool.sol";

/** @title  Gauge stake vault token get YFI rewards
    @notice Deposit your vault token (one gauge per vault).
    YFI are paid based on the number of vault tokens, the veYFI balance, and the duration of the lock.
    @dev this contract is used behind multiple delegate proxies.
 */

contract Gauge is BaseGauge, ERC20Upgradeable, IGauge {
    using SafeERC20 for IERC20;

    struct Balance {
        uint256 realBalance;
        uint256 boostedBalance;
    }

    struct Approved {
        bool claim;
        bool lock;
    }

    uint256 public constant BOOSTING_FACTOR = 1;
    uint256 public constant BOOST_DENOMINATOR = 10;

    IERC20 public asset;
    //// @notice veYFI
    address public immutable VEYFI;
    //// @notice the veYFI YFI reward pool, penalty are sent to this contract.
    address public immutable VE_YFI_POOL;
    //// @notice a copy of the veYFI max lock duration
    uint256 public constant PRECISION_FACTOR = 10 ** 18;
    //// @notice Penalty does not apply for locks expiring after 3y11m

    mapping(address => uint256) private _boostedBalances;
    mapping(address => address) public recipients;

    event TransferredPenalty(address indexed account, uint256 transfered);
    event BoostedBalanceUpdated(address account, uint256 amount);

    event Initialize(address indexed asset, address indexed owner);

    constructor(
        address _veYfi,
        address _oYfi,
        address _veYfiOYfiPool
    ) BaseGauge(_oYfi) {
        require(_veYfi != address(0x0), "_asset 0x0 address");
        require(_veYfiOYfiPool != address(0x0), "_asset 0x0 address");

        VEYFI = _veYfi;
        VE_YFI_POOL = _veYfiOYfiPool;
    }

    /** @notice initialize the contract
     *  @dev Initialize called after contract is cloned.
     *  @param _asset The vault token to stake
     *  @param _owner owner address
     */
    function initialize(address _asset, address _owner) external initializer {
        __initialize(_owner);
        asset = IERC20(_asset);
        __ERC20_init(
            string.concat("yGauge ", IERC20Metadata(_asset).name()),
            string.concat("yG-", IERC20Metadata(_asset).symbol())
        );
        emit Initialize(_asset, _owner);
    }

    /** @return total of the staked vault token
     */
    function totalAssets() public view returns (uint256) {
        return totalSupply();
    }

    /**
        The amount of shares that the Vault would exchange for the amount of assets provided.
    */
    function convertToShares(uint256 _assets) public view returns (uint256) {
        return _assets;
    }

    /**
        The amount of assets that the Vault would exchange for the amount of shares provided.
    */
    function convertToAssets(uint256 _shares) public view returns (uint256) {
        return _shares;
    }

    /**
    Maximum amount of the underlying asset that can be deposited into the Vault for the receiver, through a deposit call.
    */
    function maxDeposit(address) public view returns (uint256) {
        return type(uint256).max;
    }

    /**
    Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given current on-chain conditions.
    */
    function previewDeposit(uint256 _assets) public view returns (uint256) {
        return _assets;
    }

    /**
    Maximum amount of shares that can be minted from the Vault for the receiver, through a mint call.
    */
    function maxMint(address) public view returns (uint256) {
        return type(uint256).max;
    }

    /**
    Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given current on-chain conditions.
    */
    function previewMint(uint256 _shares) public view returns (uint256) {
        return _shares;
    }

    /** @param _account to look balance for
     *  @return amount of staked token for an account
     */
    function boostedBalanceOf(
        address _account
    ) external view returns (uint256) {
        return _boostedBalances[_account];
    }

    /** @notice
     *   Performs a snapshot of the account's accrued rewards since the previous update.
     *  @dev
     *   The snapshot made by this function depends on:
     *    1. The account's boosted balance
     *    2. The amount of reward emissions that have been added to the gauge since the
     *       account's rewards were last updated.
     *   Any function that mutates an account's balance, boostedBalance, userRewardPerTokenPaid,
     *   or rewards MUST call updateReward before performing the mutation.
     */
    function _updateReward(address _account) internal override {
        rewardPerTokenStored = _rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_account != address(0)) {
            if (_boostedBalances[_account] != 0) {
                uint256 newEarning = _newEarning(_account);
                uint256 maxEarning = _maxEarning(_account);

                rewards[_account] += newEarning;
                uint256 penalty = maxEarning - newEarning;
                _transferVeYfiORewards(penalty);
                emit TransferredPenalty(_account, penalty);
            }
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
            emit UpdatedRewards(
                _account,
                rewardPerTokenStored,
                lastUpdateTime,
                rewards[_account],
                userRewardPerTokenPaid[_account]
            );
        }
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256
    ) internal override {
        if (_from != address(0)) {
            _updateReward(_from);
        }
        if (_to != address(0)) {
            _updateReward(_to);
        }
    }

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256
    ) internal override {
        if (_from != address(0)) {
            _boostedBalances[_from] = _boostedBalanceOf(_from);
            emit BoostedBalanceUpdated(_from, _boostedBalances[_from]);
        }
        if (_to != address(0)) {
            _boostedBalances[_to] = _boostedBalanceOf(_to);
            emit BoostedBalanceUpdated(_to, _boostedBalances[_to]);
        }
    }

    function _rewardPerToken() internal view override returns (uint256) {
        if (totalAssets() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((lastTimeRewardApplicable() - lastUpdateTime) *
                rewardRate *
                PRECISION_FACTOR) / totalAssets());
    }

    /** @notice The total undistributed earnings for an account.
     *  @dev Earnings are based on lock duration and boost
     *  @return
     *   Amount of tokens the account has earned that have yet to be distributed.
     */
    function earned(
        address _account
    ) external view override(BaseGauge, IBaseGauge) returns (uint256) {
        uint256 newEarning = _newEarning(_account);

        return newEarning + rewards[_account];
    }

    /** @notice Calculates an account's earnings based on their boostedBalance.
     *   This function only reflects the accounts earnings since the last time
     *   the account's rewards were calculated via _updateReward.
     */
    function _newEarning(
        address _account
    ) internal view override returns (uint256) {
        return
            (_boostedBalances[_account] *
                (_rewardPerToken() - userRewardPerTokenPaid[_account])) /
            PRECISION_FACTOR;
    }

    /** @notice Calculates an account's potential maximum earnings based on
     *   a maximum boost.
     *   This function only reflects the accounts earnings since the last time
     *   the account's rewards were calculated via _updateReward.
     */
    function _maxEarning(address _account) internal view returns (uint256) {
        return
            (balanceOf(_account) *
                (_rewardPerToken() - userRewardPerTokenPaid[_account])) /
            PRECISION_FACTOR;
    }

    /** @notice
     *   Calculates the boosted balance of based on veYFI balance.
     *  @dev
     *   This function expects this._totalAssets to be up to date.
     *  @return
     *   The account's boosted balance. Always lower than or equal to the
     *   account's real balance.
     */
    function nextBoostedBalanceOf(
        address _account
    ) external view returns (uint256) {
        return _boostedBalanceOf(_account);
    }

    /** @notice
     *   Calculates the boosted balance of based on veYFI balance.
     *  @dev
     *    This function expects the account's _balances[_account].realBalance
     *    to be up to date.
     *  @dev This function expects this._totalAssets to be up to date.
     *  @return
     *   The account's boosted balance. Always lower than or equal to the
     *   account's real balance.
     */
    function _boostedBalanceOf(
        address _account
    ) internal view returns (uint256) {
        return _boostedBalanceOf(_account, balanceOf(_account));
    }

    /** @notice
     *   Calculates the boosted balance of an account based on its gauge stake
     *   proportion & veYFI lock proportion.
     *  @dev This function expects this._totalAssets to be up to date.
     *  @param _account The account whose veYFI lock should be checked.
     *  @param _realBalance The amount of token _account has locked in the gauge.
     *  @return
     *   The account's boosted balance. Always lower than or equal to the
     *   account's real balance.
     */
    function _boostedBalanceOf(
        address _account,
        uint256 _realBalance
    ) internal view returns (uint256) {
        uint256 veTotalSupply = IVotingYFI(VEYFI).totalSupply();
        if (veTotalSupply == 0) {
            return _realBalance;
        }
        return
            Math.min(
                ((_realBalance * BOOSTING_FACTOR) +
                    (((totalSupply() * IVotingYFI(VEYFI).balanceOf(_account)) /
                        veTotalSupply) *
                        (BOOST_DENOMINATOR - BOOSTING_FACTOR))) /
                    BOOST_DENOMINATOR,
                _realBalance
            );
    }

    /** @notice deposit vault tokens into the gauge
     *  @dev a user without a veYFI should not lock.
     *  @dev will deposit the min between user balance and user approval
     *  @dev This call updates claimable rewards
     *  @return amount of assets deposited
     */
    function deposit() external returns (uint256) {
        uint256 balance = Math.min(
            asset.balanceOf(msg.sender),
            asset.allowance(msg.sender, address(this))
        );
        _deposit(balance, msg.sender);
        return balance;
    }

    /** @notice deposit vault tokens into the gauge
     *  @dev a user without a veYFI should not lock.
     *  @dev This call updates claimable rewards
     *  @param _assets of vault token
     *  @return amount  of assets deposited
     */
    function deposit(uint256 _assets) external returns (uint256) {
        _deposit(_assets, msg.sender);
        return _assets;
    }

    /** @notice deposit vault tokens into the gauge for a user
     *   @dev vault token is taken from msg.sender
     *   @dev This call update  `_for` claimable rewards
     *   @param _assets to deposit
     *   @param _receiver the account to deposit to
     *   @return true
     */
    function deposit(
        uint256 _assets,
        address _receiver
    ) external returns (uint256) {
        _deposit(_assets, _receiver);
        return _assets;
    }

    /** @notice deposit vault tokens into the gauge for a user
     *   @dev vault token is taken from msg.sender
     *   @dev This call update  `_for` claimable rewards
     *   @dev shares and
     *   @param _shares to deposit
     *   @param _receiver the account to deposit to
     *   @return amount of shares transfered
     */
    function mint(
        uint256 _shares,
        address _receiver
    ) external returns (uint256) {
        _deposit(_shares, _receiver);
        return _shares;
    }

    function _deposit(uint256 _assets, address _receiver) internal {
        require(_assets != 0, "RewardPool : Cannot deposit 0");

        //take away from sender
        asset.safeTransferFrom(msg.sender, address(this), _assets);

        // mint shares
        _mint(_receiver, _assets);

        emit Deposit(msg.sender, _receiver, _assets, _assets);
    }

    /**
      Maximum amount of the underlying asset that can be withdrawn from the owner balance in the Vault, through a withdraw call.
    */
    function maxWithdraw(address _owner) external view returns (uint256) {
        return balanceOf(_owner);
    }

    function previewWithdraw(uint256 _assets) external view returns (uint256) {
        return _assets;
    }

    /** @notice Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *  @dev This call updates claimable rewards
     *  @param _assets amount to withdraw
     *  @param _receiver account that will recieve the shares
     *  @param _owner shares will be taken from account
     *  @param _claim claim veYFI and additional reward
     *  @return amount of shares withdrawn
     */
    function withdraw(
        uint256 _assets,
        address _receiver,
        address _owner,
        bool _claim
    ) external returns (uint256) {
        return _withdraw(_assets, _receiver, _owner, _claim);
    }

    /** @notice Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *  @dev This call updates claimable rewards
     *  @param _assets amount to withdraw
     *  @param _receiver account that will recieve the shares
     *  @param _owner shares will be taken from account
     *  @return amount of shares withdrawn
     */
    function withdraw(
        uint256 _assets,
        address _receiver,
        address _owner
    ) external returns (uint256) {
        return _withdraw(_assets, _receiver, _owner, false);
    }

    /** @notice withdraw all vault tokens from gauge
     *   @dev This call updates claimable rewards
     *   @param _claim claim veYFI and additional reward
     *  @return amount of shares withdrawn
     */
    function withdraw(bool _claim) external returns (uint256) {
        return _withdraw(balanceOf(msg.sender), msg.sender, msg.sender, _claim);
    }

    /** @notice withdraw all vault token from gauge
     *  @dev This call update claimable rewards
     *  @return amount of shares withdrawn
     */
    function withdraw() external returns (uint256) {
        return _withdraw(balanceOf(msg.sender), msg.sender, msg.sender, false);
    }

    function _withdraw(
        uint256 _assets,
        address _receiver,
        address _owner,
        bool _claim
    ) internal returns (uint256) {
        require(_assets != 0, "RewardPool : Cannot withdraw 0");

        if (msg.sender != _owner) {
            _spendAllowance(_owner, msg.sender, _assets);
        }

        _burn(_owner, _assets);

        if (_claim) {
            _getReward(_owner);
        }

        asset.safeTransfer(_receiver, _assets);
        emit Withdraw(msg.sender, _receiver, _owner, _assets, _assets);

        return _assets;
    }

    function maxRedeem(address _owner) external view returns (uint256) {
        return balanceOf(_owner);
    }

    function previewRedeem(uint256 _assets) external view returns (uint256) {
        return _assets;
    }

    /** @notice Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *  @dev This call updates claimable rewards
     *  @param _assets amount to withdraw
     *  @param _receiver account that will recieve the shares
     *  @param _owner shares will be taken from account
     *  @return amount of shares withdrawn
     */
    function redeem(
        uint256 _assets,
        address _receiver,
        address _owner
    ) external override returns (uint256) {
        return _withdraw(_assets, _receiver, _owner, true);
    }

    /**
     * @notice
     *  Get rewards
     * @return true
     */
    function getReward() external updateReward(msg.sender) returns (bool) {
        _getReward(msg.sender);
        return true;
    }

    /**
     * @notice
     *  Get rewards for an account
     * @dev rewards are transferred to _account
     * @param _account to claim rewards for
     * @return true
     */
    function getReward(
        address _account
    ) external updateReward(_account) returns (bool) {
        _getReward(_account);

        return true;
    }

    /** @notice Distributes the rewards for the specified account.
     *  @dev
     *   This function MUST NOT be called without the caller invoking
     *   updateReward(_account) first.
     */
    function _getReward(address _account) internal {
        uint256 boostedBalance = _boostedBalanceOf(_account);
        _boostedBalances[_account] = boostedBalance;
        emit BoostedBalanceUpdated(_account, boostedBalance);

        uint256 reward = rewards[_account];
        if (reward != 0) {
            rewards[_account] = 0;
            address recipient = recipients[_account];
            if (recipient != address(0x0)) {
                REWARD_TOKEN.safeTransfer(recipient, reward);
            } else {
                REWARD_TOKEN.safeTransfer(_account, reward);
            }
            emit RewardPaid(_account, reward);
        }
    }

    function _transferVeYfiORewards(uint256 _penalty) internal {
        IERC20(REWARD_TOKEN).approve(VE_YFI_POOL, _penalty);
        IOYfiRewardPool(VE_YFI_POOL).burn(_penalty);
    }

    function _protectedTokens(
        address _token
    ) internal view override returns (bool) {
        return _token == address(REWARD_TOKEN) || _token == address(asset);
    }

    /**
    @notice Kick `addr` for abusing their boost
    @param _accounts Addresses to kick
    */
    function kick(address[] calldata _accounts) public {
        for (uint256 i = 0; i < _accounts.length; ++i) {
            _kick(_accounts[i]);
        }
    }

    function _kick(address _account) internal updateReward(_account) {
        uint256 balance = balanceOf(_account);
        require(
            _boostedBalances[_account] >
                (balance * BOOSTING_FACTOR) / BOOST_DENOMINATOR,
            "min boosted balance"
        );
        uint256 boostedBalance = _boostedBalanceOf(_account, balance);
        _boostedBalances[_account] = boostedBalance;
        emit BoostedBalanceUpdated(_account, boostedBalance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";

interface IBaseGauge {
    function queueNewRewards(uint256 _amount) external returns (bool);

    function earned(address _account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";

/**
 * @title EIP 4626 specification
 * @notice Interface of EIP 4626 Interface
 * as defined in https://eips.ethereum.org/EIPS/eip-4626
 */
interface IERC4626 is IERC20Upgradeable {
    /**
     * @notice Event indicating that `caller` exchanged `assets` for `shares`, and transferred those `shares` to `owner`
     * @dev Emitted when tokens are deposited into the vault via {mint} and {deposit} methods
     */
    event Deposit(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @notice Event indicating that `caller` exchanged `shares`, owned by `owner`, for `assets`, and transferred those
     * `assets` to `receiver`
     * @dev Emitted when shares are withdrawn from the vault via {redeem} or {withdraw} methods
     */
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @notice Returns the address of the underlying token used by the Vault
     * @return assetTokenAddress The address of the underlying ERC20 Token
     * @dev MUST be an ERC-20 token contract
     *
     * MUST not revert
     */
    function asset() external view returns (IERC20 assetTokenAddress);

    /**
     * @notice Returns the total amount of the underlying asset managed by the Vault
     * @return totalManagedAssets Amount of the underlying asset
     * @dev Should include any compounding that occurs from yield.
     *
     * Should be inclusive of any fees that are charged against assets in the vault.
     *
     * Must not revert
     *
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     *
     * @notice Returns the amount of shares that, in an ideal scenario, the vault would exchange for the amount of assets
     * provided
     *
     * @param _assets Amount of assets to convert
     * @return shares Amount of shares that would be exchanged for the provided amount of assets
     *
     * @dev MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     *
     * MUST NOT show any variations depending on the caller.
     *
     * MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     *
     * MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     *
     * MUST round down towards 0.
     *
     * This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and from.
     */
    function convertToShares(
        uint256 _assets
    ) external view returns (uint256 shares);

    /**
     *
     * @notice Returns the amount of assets that the vault would exchange for the amount of shares provided
     *
     * @param _shares Amount of vault shares to convert
     * @return assets Amount of assets that would be exchanged for the provided amount of shares
     *
     * @dev MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     *
     * MUST NOT show any variations depending on the caller.
     *
     * MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     *
     * MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     *
     * MUST round down towards 0.
     *
     * This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and from.
     */
    function convertToAssets(
        uint256 _shares
    ) external view returns (uint256 assets);

    /**
     *
     * @notice Returns the maximum amount of the underlying asset that can be deposited into the vault for the `receiver`
     * through a {deposit} call
     *
     * @param _receiver Address whose maximum deposit is being queries
     * @return maxAssets
     *
     * @dev MUST return the maximum amount of assets {deposit} would allow to be deposited for receiver and not cause a
     * revert, which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if
     *necessary). This assumes that the user has infinite assets, i.e. MUST NOT rely on {balanceOf} of asset.
     *
     * MUST factor in both global and user-specific limits, like if deposits are entirely disabled (even temporarily)
     * it MUST return 0.
     *
     * MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     *
     * MUST NOT revert.
     */
    function maxDeposit(
        address _receiver
    ) external view returns (uint256 maxAssets);

    /**
     * @notice Simulate the effects of a user's deposit at the current block, given current on-chain conditions
     * @param _assets Amount of assets
     * @return shares Amount of shares
     * @dev MUST return as close to and no more than the exact amount of Vault shares that would be minted in a {deposit}
     * call in the same transaction. I.e. deposit should return the same or more shares as {previewDeposit} if called in
     * the same transaction. (I.e. {previewDeposit} should underestimate or round-down)
     *
     * MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     * deposit would be accepted, regardless if the user has enough tokens approved, etc.
     *
     * MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause deposit to revert.
     *
     * Note that any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage
     * in share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(
        uint256 _assets
    ) external view returns (uint256 shares);

    /**
     * @notice Mints `shares` Vault shares to `receiver` by depositing exactly `amount` of underlying tokens
     * @param _assets Amount of assets
     * @param _receiver Address to deposit underlying tokens into
     * @dev Must emit the {Deposit} event
     *
     * MUST support ERC-20 {approve} / {transferFrom} on asset as a deposit flow. MAY support an additional flow in
     * which the underlying tokens are owned by the Vault contract before the {deposit} execution, and are accounted for
     * during {deposit}.
     *
     * MUST revert if all of `assets` cannot be deposited (due to deposit limit being reached, slippage, the user not
     * approving enough underlying tokens to the Vault contract, etc).
     *
     * Note that most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(
        uint256 _assets,
        address _receiver
    ) external returns (uint256 shares);

    /**
     * @notice Returns the maximum amount of shares that can be minted from the vault for the `receiver``, via a `mint`
     * call
     * @param _receiver Address to deposit minted shares into
     * @return maxShares The maximum amount of shares
     * @dev MUST return the maximum amount of shares mint would allow to be deposited to receiver and not cause a revert,
     * which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if necessary).
     * This assumes that the user has infinite assets, i.e. MUST NOT rely on balanceOf of asset.
     *
     * MUST factor in both global and user-specific limits, like if mints are entirely disabled (even temporarily) it
     *
     * MUST return 0.
     *
     * MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     *
     * MUST NOT revert.
     */
    function maxMint(
        address _receiver
    ) external view returns (uint256 maxShares);

    /**
     * @notice Simulate the effects of a user's mint at the current block, given current on-chain conditions
     * @param _shares Amount of shares to mint
     * @return assets Amount of assets required to mint `mint` amount of shares
     * @dev MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     * in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the same
     * transaction. (I.e. {previewMint} should overestimate or round-up)
     *
     * MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     * would be accepted, regardless if the user has enough tokens approved, etc.
     *
     * MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause mint to revert.
     *
     * Note that any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(
        uint256 _shares
    ) external view returns (uint256 assets);

    /**
     * @notice Mints exactly `shares` vault shares to `receiver` by depositing `amount` of underlying tokens
     * @param _shares Amount of shares to mint
     * @param _receiver Address to deposit minted shares into
     * @return assets Amount of assets transferred to vault
     * @dev Must emit the {Deposit} event
     *
     * MUST support ERC-20 {approve} / {transferFrom} on asset as a mint flow. MAY support an additional flow in
     *  which the underlying tokens are owned by the Vault contract before the mint execution, and are accounted for
     * during mint.
     *
     * MUST revert if all of `shares` cannot be minted (due to deposit limit being reached, slippage, the user not
     * approving enough underlying tokens to the Vault contract, etc).
     *
     * Note that most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(
        uint256 _shares,
        address _receiver
    ) external returns (uint256 assets);

    /**
     * @notice Returns the maximum amount of the underlying asset that can be withdrawn from the `owner` balance in the
     * vault, through a `withdraw` call.
     * @param _owner Address of the owner whose max withdrawal amount is being queries
     * @return maxAssets Maximum amount of underlying asset that can be withdrawn
     * @dev MUST return the maximum amount of assets that could be transferred from `owner` through {withdraw} and not
     * cause a revert, which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if
     * necessary).
     *
     * MUST factor in both global and user-specific limits, like if withdrawals are entirely disabled
     * (even temporarily)  it MUST return 0.
     *
     * MUST NOT revert.
     */
    function maxWithdraw(
        address _owner
    ) external view returns (uint256 maxAssets);

    /**
     * @notice Simulate the effects of a user's withdrawal at the current block, given current on-chain conditions.
     * @param _assets Amount of assets
     * @return shares Amount of shares
     * @dev MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a
     * {withdraw} call in the same transaction. I.e. {withdraw} should return the same or fewer shares as
     * {previewWithdraw} if called in the same transaction. (I.e. {previewWithdraw should overestimate or round-up})
     *
     * MUST NOT account for withdrawal limits like those returned from {maxWithdraw} and should always act as though
     * the withdrawal would be accepted, regardless if the user has enough shares, etc.
     *
     * MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause {withdraw} to revert.
     *
     * Note that any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(
        uint256 _assets
    ) external view returns (uint256 shares);

    /**
     * @notice Burns `shares` from `owner` and sends exactly `assets` of underlying tokens to `receiver`
     * @param _assets Amount of underling assets to withdraw
     * @return shares Amount of shares that will be burned
     * @dev Must emit the {Withdraw} event
     *
     * MUST support a withdraw flow where the shares are burned from `owner` directly where `owner` is `msg.sender`
     * or `msg.sender` has ERC-20 approval over the shares of `owner`. MAY support an additional flow in which the shares
     * are transferred to the Vault contract before the withdraw execution, and are accounted for during withdraw.
     *
     * MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     * not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     *  Those methods should be performed separately.
     */
    function withdraw(
        uint256 _assets,
        address _receiver,
        address _owner
    ) external returns (uint256 shares);

    /**
     * @notice Returns the maximum amount of vault shares that can be redeemed from the `owner` balance in the vault, via
     * a `redeem` call.
     * @param _owner Address of the owner whose shares are being queries
     * @return maxShares Maximum amount of shares that can be redeemed
     * @dev MUST return the maximum amount of shares that could be transferred from `owner` through `redeem` and not cause
     * a revert, which MUST NOT be higher than the actual maximum that would be accepted (it should underestimate if
     * necessary).
     *
     * MUST factor in both global and user-specific limits, like if redemption is entirely disabled
     * (even temporarily) it MUST return 0.
     *
     * MUST NOT revert
     */
    function maxRedeem(
        address _owner
    ) external view returns (uint256 maxShares);

    /**
     * @notice Simulate the effects of a user's redemption at the current block, given current on-chain conditions
     * @param _shares Amount of shares that are being simulated to be redeemed
     * @return assets Amount of underlying assets that can be redeemed
     * @dev MUST return as close to and no more than the exact amount of `assets `that would be withdrawn in a {redeem}
     * call in the same transaction. I.e. {redeem} should return the same or more assets as {previewRedeem} if called in
     * the same transaction. I.e. {previewRedeem} should underestimate/round-down
     *
     * MUST NOT account for redemption limits like those returned from {maxRedeem} and should always act as though
     * the redemption would be accepted, regardless if the user has enough shares, etc.
     *
     * MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     *
     * MUST NOT revert due to vault specific user/global limits. MAY revert due to other conditions that would also
     * cause {redeem} to revert.
     *
     * Note that any unfavorable discrepancy between {convertToAssets} and {previewRedeem} SHOULD be considered
     * slippage in share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(
        uint256 _shares
    ) external view returns (uint256 assets);

    /**
     * @notice Burns exactly `shares` from `owner` and sends `assets` of underlying tokens to `receiver`
     * @param _shares Amount of shares to burn
     * @param _receiver Address to deposit redeemed underlying tokens to
     * @return assets Amount of underlying tokens redeemed
     * @dev Must emit the {Withdraw} event
     * MUST support a {redeem} flow where the shares are burned from owner directly where `owner` is `msg.sender` or
     *
     * `msg.sender` has ERC-20 approval over the shares of `owner`. MAY support an additional flow in which the shares
     * are transferred to the Vault contract before the {redeem} execution, and are accounted for during {redeem}.
     *
     * MUST revert if all of {shares} cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     * not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    ) external returns (uint256 assets);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import "./IBaseGauge.sol";

interface IExtraReward is IBaseGauge {
    function initialize(
        address _gauge,
        address _reward,
        address _owner
    ) external;

    function rewardCheckpoint(address _account) external returns (bool);

    function getReward() external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./IBaseGauge.sol";
import "./IERC4626.sol";

interface IGauge is IBaseGauge, IERC4626 {
    function initialize(address _stakingToken, address _owner) external;

    function boostedBalanceOf(address _account) external view returns (uint256);

    function getReward(address _account) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IOYfiRewardPool {
    function burn(uint256 _amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";

interface IVotingYFI is IERC20 {
    struct LockedBalance {
        int128 amount;
        uint256 end;
    }

    function totalSupply() external view returns (uint256);

    function locked(address _user) external view returns (LockedBalance memory);

    function modify_lock(
        uint256 _amount,
        uint256 _unlock_time,
        address _user
    ) external;
}