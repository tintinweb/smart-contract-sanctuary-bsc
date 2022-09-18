/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.7;








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
     * https:
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











/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https:
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
        
        
        

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https:
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https:
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https:
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
     * use https:
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
            
            if (returndata.length > 0) {
                
                
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
 * 
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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}









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
 * https:
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    
    
    
    
    

    
    
    
    
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        
        _status = _ENTERED;

        _;

        
        
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https:
     */
    uint256[49] private __gap;
}







interface  INodeValidatorManager {
    
    function verify(bytes32 _submissionId, uint8 _excessConfirmations, bytes memory _proofs) external;
}







interface IGBridgeToken {

    function mint(address _receiver, uint256 _amount) external; 
    function burnFrom(address _from, uint256 _amount) external;
}








contract GBridgeToken is ERC20, IGBridgeToken {
    uint8 private _decimals;

    address public bridgeAddress;
    address public admin;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal,
        address _beidgeAddress,
        address _admin
    ) ERC20(_name, _symbol) {
        _decimals = _decimal;
        bridgeAddress = _beidgeAddress;
        admin = _admin;
    }

    error BridgeBadRoleError();
    error AdminBadRoleError();

    fallback() external payable { }

    receive() external payable { }

    modifier onlyAdmin {
        if(msg.sender != admin) revert AdminBadRoleError();
        _;
    }

    modifier onlyBridge {
        if(msg.sender != bridgeAddress) revert BridgeBadRoleError();
        _;
    }

    function updateBridgeAddress(address _beidgeAddress) external onlyAdmin {
        bridgeAddress = _beidgeAddress;
    }

    function mint(address _receiver, uint256 _amount) external override onlyBridge{
        _mint(_receiver, _amount);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    function burnFrom(address _from, uint256 _amount) external override onlyBridge {
        _burn(_from, _amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}








contract AdminAccess {

    address public admin;
    

    constructor(address _admin) {
        admin = _admin;
    }

    error AdminBadRoleError();

    modifier onlyAdmin {
        if(msg.sender != admin) revert AdminBadRoleError();
        _;
    }
}








contract BridgeAccess {

    address public bridgeAddress;
    

    constructor(address _bridgeAddress) {
        bridgeAddress = _bridgeAddress;
    }

    error BridgeBadRoleError();

    modifier onlyBridge {
        if(msg.sender != bridgeAddress) revert BridgeBadRoleError();
        _;
    }
}







library TransactionsTypes {

    enum TokenType {
        ChainToken,
        ERCToken,
        OtherToken
    }

    enum TransactionType {
        FromZilliqa,
        ToZilliqa
    }

    struct TxTransfer {
        bytes32 submissionId;
        address token;
        address from;
        address to;
        uint256 amount;
        uint grph_fees;
        TokenType tokenType;
        uint256 nonce;
        TransactionType transactionType;
    }

    error TxUsedError();
}







interface ITransactionsStorage {

    function saveTx(TransactionsTypes.TxTransfer calldata tx) external;
    function getTx(bytes32 submissionId) external view returns (TransactionsTypes.TxTransfer memory);
}









contract TransactionsStorage is
    AdminAccess,
    BridgeAccess,
    ITransactionsStorage
{

    mapping(bytes32 => TransactionsTypes.TxTransfer) txs;

    constructor(address _bridgeAddress, address _admin) AdminAccess(_admin) BridgeAccess(_bridgeAddress){}

    function saveTx(TransactionsTypes.TxTransfer calldata transferTx) external override onlyBridge {
        txs[transferTx.submissionId] = transferTx;
    }

    function getTx(bytes32 submissionId) external view override returns (TransactionsTypes.TxTransfer memory) {
        return txs[submissionId];
    }

    function updateBridge(address _bridgeAddress) external  onlyAdmin {
        bridgeAddress = _bridgeAddress;
    }
}













contract GBridge is ReentrancyGuardUpgradeable {

    struct Chain {
        address tokenAddress;
        address bridgeAddress;
        uint256 excessAmount;
        uint8 excessConfirmations;
        TransactionsTypes.TokenType tokenType;
        bool isSupported;
        bool isFeeLess;
    }

    struct Config {
        address grph_address;
        address carb_address;
        address node_manager;
        uint256 grph_fees;
        bool is_paused;
        address storageAddress;
        uint256 cuteFees;
    }

    address constant nullAddress = 0x0000000000000000000000000000000000000000;

    Config public config;

    string public chainId;
    address public admin;
    uint256 public nonce;

    uint256 public totalBurndGRPHToken;

    mapping(string => mapping(address => Chain)) public chains;
    mapping(address => uint256) public totalLockedAmount;
    
    mapping(address => mapping(address => uint256)) public claimTokenFees;

    mapping(address => uint256) public totalFees;

    /* ========== ERRORS ========== */

    error NotAdminError();
    error ContractPausedError();
    error TokenNotSupportedError();
    error UnknownChainIdError();
    error AmountError();
    error NotValidClaimFee();

    event TokenChainTransfer(
        bytes32 submissionId,
        string chainId,
        string fromChainId,
        address from,
        address to,
        address token,
        uint256 amount,
        uint256 claimFee,
        uint256 nonce,
        address bridge
    );
    event TokenChainTransferClaimed(
        bytes32 submissionId,
        string chainId,
        string fromChainId,
        address from,
        address to,
        address token,
        uint256 amount,
        uint256 claimFee,
        uint256 nonce,
        address bridge
    );
    event ContractPaused();
    event ContractUnPaused();
    event TokenToChainAdded(address token);
    event ConfigUpdated(Config config);

    constructor(address _admin, string memory _chainId) {
        nonce = 0;
        admin = _admin;
        chainId = _chainId;
        config.cuteFees = 10;
        
    }

    fallback() external payable {}

    receive() external payable {
        totalLockedAmount[nullAddress] += msg.value;
    }

    modifier onlyAdmin() {
        if (admin != msg.sender) revert NotAdminError();
        _;
    }

    modifier notPaused() {
        if (config.is_paused == true) revert ContractPausedError();
        _;
    }

    modifier checkTransferParams(string memory _chainId, address _token, uint256 _amount) {
        (address bridge, address token, bool isFeeLess, bool isSupported) = GetChainInfo(_chainId, _token);
        uint256 transferAmount = _amount;
        if (_token == nullAddress) transferAmount = msg.value;
        if (transferAmount == 0) revert AmountError();
        if (isSupported != true) revert TokenNotSupportedError();
        if (bridge == nullAddress) revert UnknownChainIdError();
        _;
        _NonceIncrement();
    }

    function CalcFeeFromTokenAmount(uint256 amount, uint256 fee) public pure returns (uint256) {
        return (amount * fee) / 10000;
    }

    function CalcCuteFees(uint256 _amount) public view returns (uint256) {
        uint256 fees = CalcFeeFromTokenAmount(_amount, config.cuteFees);
        
        return _amount - fees;
    }

    function CalcFees(uint256 _amount) public view returns (uint256) {
        uint256 fees = CalcFeeFromTokenAmount(_amount, config.cuteFees);
        
        return fees;
    }

    function _NonceIncrement() internal {
        nonce += 1;
    }

    function _SaveFees(address _token, uint256 _fees) internal {
        totalFees[_token] = totalFees[_token] + _fees;
    }

    function _UpdateFees(address _token, uint256 _amount) internal {
        uint256 fees = CalcFeeFromTokenAmount(_amount, config.cuteFees);
        _SaveFees(_token, fees);
    }

    function _ReceiveToken(
        string memory _chainId,
        address token,
        address from,
        uint256 amount
    ) internal {
        (, , bool _isFeeLess,) = GetChainInfo(_chainId, token);
        if(_isFeeLess == false) {
            _UpdateFees(token, amount);
        }
        TransactionsTypes.TokenType _tokenType = chains[_chainId][token].tokenType;
        if (_tokenType == TransactionsTypes.TokenType.ERCToken) {
            IERC20(token).transferFrom(from, address(this), amount);
        } else if (_tokenType == TransactionsTypes.TokenType.OtherToken) {
            IGBridgeToken(token).burnFrom(from, amount);
        }

        totalLockedAmount[token] += amount;
        totalBurndGRPHToken += config.grph_fees;
        _SaveFees(config.grph_address, config.grph_fees);
        IGBridgeToken(config.grph_address).burnFrom(from, config.grph_fees);
    }

    function _SendToken(
        string memory _chainId,
        address token,
        address to,
        uint256 amount,
        uint256 claimFee
    ) internal {

        uint256 rest_amount = amount - claimFee;
        claimTokenFees[msg.sender][token] += claimFee;

        TransactionsTypes.TokenType _tokenType = chains[_chainId][token].tokenType;
        if (_tokenType == TransactionsTypes.TokenType.ChainToken) {
            totalLockedAmount[token] -= rest_amount;
            payable(to).transfer(rest_amount);
        } else if (_tokenType == TransactionsTypes.TokenType.ERCToken) {
            IERC20(token).transfer(to, rest_amount);
            totalLockedAmount[token] -= rest_amount;
        } else if (_tokenType == TransactionsTypes.TokenType.OtherToken) {
            IGBridgeToken(token).mint(to, rest_amount);
        }

    }

    function _Hash(
        string memory _chainId,
        string memory _fromChainId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _claimFee,
        uint256 _nonce,
        address _bridge
    ) internal pure returns (bytes32) {
        bytes32 chainId_hex = keccak256(abi.encodePacked(_chainId));
        bytes32 fromChainId_hex = keccak256(abi.encodePacked(_fromChainId));
        bytes32 from_hex = keccak256(abi.encodePacked(_from));
        bytes32 to_hex = keccak256(abi.encodePacked(_to));
        bytes32 token_hex = keccak256(abi.encodePacked(_token));
        bytes32 amount_hex = keccak256(abi.encode(_amount));
        bytes32 claimFee_hex = keccak256(abi.encode(_claimFee));
        bytes32 nonce_hex = keccak256(abi.encode(_nonce));
        bytes32 bridge_hex = keccak256(abi.encodePacked(_bridge));

        return keccak256(
            abi.encode(
                chainId_hex,
                fromChainId_hex,
                from_hex,
                to_hex,
                token_hex,
                amount_hex,
                claimFee_hex,
                nonce_hex,
                bridge_hex
            )
        );
    }

    function _CheckProof(
        bytes32 _submissionId,
        string memory _chainId,
        address _token,
        uint256 _amount,
        bytes calldata _proofs
    ) internal {
        uint8 _excessConfirmations = 0;
        if (_amount >= chains[_chainId][_token].excessAmount) {
            _excessConfirmations = chains[_chainId][_token].excessConfirmations;
        }
        INodeValidatorManager(config.node_manager).verify(
            _submissionId,
            _excessConfirmations,
            _proofs
        );
    }

    function _SaveClaim(bytes32 _submissionId, TransactionsTypes.TxTransfer memory transferTx) internal {
        TransactionsTypes.TxTransfer memory t = ITransactionsStorage(config.storageAddress).getTx(
            _submissionId
        );
        if (t.submissionId == _submissionId) revert TransactionsTypes.TxUsedError();
        ITransactionsStorage(config.storageAddress).saveTx(transferTx);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTotalFee(address token) public view returns (uint256) {
        return totalFees[token];
    }

    function getBalanceOfToken(address _token) public view returns (uint256) {
        return totalLockedAmount[_token];
    }

    function GetSubmissionId(
        string memory _chainId,
        string memory _fromChainId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _claimFee,
        uint256 _nonce,
        address _bridge
    ) public pure returns (bytes32) {
        return _Hash(_chainId, _fromChainId, _from, _to, _token, _amount, _claimFee, _nonce, _bridge);
    }

    function GetChainInfo(string memory _chainId, address _token) public view returns (address, address, bool, bool) {
        Chain storage chain = chains[_chainId][_token];
        return (chain.bridgeAddress, chain.tokenAddress, chain.isFeeLess, chain.isSupported);
    }

    function _EmitTransferTx(
        string memory _chainId,
        address _token,
        address _to,
        uint256 _amount,
        uint256 _claimFee
    ) internal {
        (address bridge, address token, bool isFeeLess,) = GetChainInfo(_chainId, _token);
        uint256 actual_amount = CalcCuteFees(_amount);
        if(isFeeLess)
            actual_amount = _amount;
        bytes32 submissionId = _Hash(_chainId, chainId, msg.sender, _to, token, actual_amount, _claimFee, nonce, bridge);
        emit TokenChainTransfer(submissionId, _chainId, chainId, msg.sender, _to, token, actual_amount, _claimFee, nonce, bridge);
    }

    function Transfer(
        string memory _chainId,
        address _token,
        uint256 _amount,
        uint256 _claimFee,
        address _to
    ) external payable nonReentrant notPaused checkTransferParams(_chainId, _token, _amount){
        uint256 transferAmount = _amount;
        if (_token == nullAddress) transferAmount = msg.value;
        _EmitTransferTx(_chainId, _token, _to, transferAmount, _claimFee);
        _ReceiveToken(_chainId, _token, msg.sender, transferAmount);
    }

    function Claim(
        string memory _chainId,
        string memory _fromChainId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _claimFee,
        uint256 _nonce,
        address _bridge,
        bytes calldata _proofs
    ) external notPaused {
        if (_amount == 0) revert AmountError();
        if (_bridge != address(this)) revert UnknownChainIdError();
        if(_amount < _claimFee) revert NotValidClaimFee();
        bytes32 _submissionId = _Hash(
            _chainId,
            _fromChainId,
            _from,
            _to,
            _token,
            _amount,
            _claimFee,
            _nonce,
            address(this)
        );
        _SaveClaim(
            _submissionId,
            TransactionsTypes.TxTransfer(
                _submissionId,
                _token,
                _from,
                _to,
                _amount,
                _claimFee,
                chains[_fromChainId][_token].tokenType,
                _nonce,
                TransactionsTypes.TransactionType.FromZilliqa
            )
        );
        _CheckProof(_submissionId, _chainId, _token, _amount, _proofs);
        _SendToken(_chainId, _token, _to, _amount, _claimFee);
        emit TokenChainTransferClaimed(_submissionId, _chainId, _fromChainId, _from, _to, _token, _amount, _claimFee, _nonce, address(this));
    }

    function TransferClaimFeesToChain(string memory _chainId, string memory _fromChainId, address _to, address _token, uint256 _claimFee) external notPaused {
        address token = chains[_chainId][_token].tokenAddress;
        address bridge = chains[_chainId][_token].bridgeAddress;

        uint256 amount = claimTokenFees[msg.sender][token];
        claimTokenFees[msg.sender][token] = 0;

        if (amount == 0) revert AmountError();
        if (chains[_chainId][_token].isSupported != true) revert TokenNotSupportedError();

        bytes32 submissionId = _Hash(
            _chainId,
            _fromChainId,
            msg.sender,
            _to,
            token,
            amount,
            _claimFee,
            nonce,
            bridge
        );

        emit TokenChainTransfer(submissionId, _chainId, _fromChainId, msg.sender, _to, token, amount, _claimFee, nonce, bridge);
        _NonceIncrement();
    }

    function ClaimFees(string memory _chainId, address _token) external nonReentrant notPaused {
        uint256 amount = claimTokenFees[msg.sender][_token];
        claimTokenFees[msg.sender][_token] = 0;
        if (amount == 0) revert AmountError();
        _SendToken(_chainId, _token, msg.sender, amount, 0);
    }

    function TransferFeesToChainId(string memory _chainId, address _to, address _token, uint256 _claimFee) external nonReentrant notPaused onlyAdmin {
        address token = chains[_chainId][_token].tokenAddress;
        address bridge = chains[_chainId][_token].bridgeAddress;

        uint256 amount = totalFees[token];
        totalFees[token] = 0;

        if (amount == 0) revert AmountError();
        if (chains[_chainId][_token].isSupported != true) revert TokenNotSupportedError();

        bytes32 submissionId = _Hash(
            _chainId,
            chainId,
            msg.sender,
            _to,
            token,
            amount,
            _claimFee,
            nonce,
            bridge
        );

        emit TokenChainTransfer(submissionId, chainId, chainId, msg.sender, _to, token, amount, _claimFee, nonce, bridge);
        _NonceIncrement();

    }

    function AddUpdateToken(string memory _chainId, Chain memory chain, address _token) external onlyAdmin {
        chains[_chainId][_token] = chain;
        emit TokenToChainAdded(chain.tokenAddress);
    }

    function UpdateConfig(Config calldata _config) external onlyAdmin {
        config = _config;
        emit ConfigUpdated(config);
    }

    function Pause() external onlyAdmin {
        config.is_paused = true;
        emit ContractPaused();
    }

    function Unpause() external onlyAdmin {
        config.is_paused = false;
        emit ContractUnPaused();
    }
}