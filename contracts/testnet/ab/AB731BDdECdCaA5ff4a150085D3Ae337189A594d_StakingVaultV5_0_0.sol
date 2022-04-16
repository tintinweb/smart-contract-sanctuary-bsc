// SPDX-License-Identifier: MIT

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

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

    constructor () {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity >=0.6.2;

//SPDX-License-Identifier: UNLICENSED

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

pragma solidity >=0.6.2;
//SPDX-License-Identifier: UNLICENSED
import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

//Created by Altrucoin.com - V5.0.1 Time Locking Vault

//SPDX-License-Identifier: UNLICENSED

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './utils/VotingToken.sol';
import './interfaces/IUniswapV2Router01.sol';
import './interfaces/IUniswapV2Router02.sol';
// TODO Separate vault functionality and import vault functionality contract interface

// File: contracts/Vault.sol
// Deployed with solidity 0.8.11
pragma solidity ^0.8.12;
pragma abicoder v2;

contract StakingVaultV5_0_0 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Initialize Variables
    address public admin; // Partner company vault control wallet
    address public treasury; // address with access to the bonding function
    uint256 public vaultOpenDate = block.timestamp; // Time when the vault was opened

    // Fee counter for treshold based fee sending
    uint256 public charityFeeTracker = 0;
    uint256 public adminFeeTracker = 0;
    uint256 public platformFeeTracker = 0;
    uint256 public burnFeeTracker = 0;

    // Minimum token treshold amounts to trigger sending
    uint256 private charityMinSend = 3819000000000;
    uint256 private adminMinSend = 3819000000000;
    uint256 private platformMinSend = 3819000000000;
    uint256 private burnMinSend = 3819000000000;

    // Fee counter for treshold based sending for the second token
    uint256 private charityFeeTrackerSecondToken = 0;
    uint256 private adminFeeTrackerSecondToken = 0;
    uint256 private platformFeeTrackerSecondToken = 0;

    // Minimum token treshold amounts to trigger sending for the second token
    uint256 public charityMinSendSecondToken = 10000000000000000000000000000000000000;
    uint256 public adminMinSendSecondToken = 10000000000000000000000000000000000000;
    uint256 public platformMinSendSecondToken = 10000000000000000000000000000000000000;

    // Total raised by vault fees trackers
    uint256 private adminRunningTotal;
    uint256 private charityRunningTotal;
    uint256 private platformRunningTotal;
    uint256 private burnRunningTotal;
    uint256 private adminRunningTotalSecondToken;
    uint256 private charityRunningTotalSecondToken;
    uint256 private platformRunningTotalSecondToken;

    // Controls
    bool private votingTokenEnabled = true;
    bool private mintVTOnUpdate = true; // Mint voting token on update
    bool private updateOnEntry = true;
    bool private updateOnExit = true;
    bool private _disableDeposits = false;
    bool private unstakeEarly = true;
    bool private unstakeEarlyBonding = false;
    bool private secondTokenVault = false; // Toggle dual token features
    bool private feeForSecondToken = false; // Exit fee on second reward token
    // bool public dualGen = false; // Toggle vault generate dual token rewards for a single reflection type token

    // Hold AC to enter settings
    //bool public requireACForVault = false; // Require users to hold AC to enter vault
    //uint256 public minimumTokenHold = 0; // Altrucoin tokens to hold to enter/exit vault

    // Second Token Reward trackers
    uint256 private _tCycleCopy = 0; // Saves tTotalMain for the duration of 1 second token distribution cycle
    uint256 private _rCycleCopy = 0; // Saves rTotalMain for the duration of 1 second token distribution cycle
    uint256 private secondTokenRewards = 0; // Excess second token to be distributed as rewards
    uint256 public totalDistrubtedSecondToken = 0;
    uint256 private userArrayLengthCopy = 0; // Copy of the current length of the user array
    uint256 private userArrayLengthCopy2 = 0; // Copy of the current length of the user array for voting token
    uint256 private loopIndex = 0; // index tracker of where loop is in user index array
    uint256 private loopIndex2 = 0; //loop for voting token
    uint256 private secondTokenDistributesPerCall = 5; // Number of users to distribute to during each normal vault update

    // Lock times
    uint256 public constant MAX_MIN_LOCK_TIME = 365;
    uint256 public constant MAX_MAX_LOCK_TIME = 1825;
    uint256 public minLockTime = 30; // Days
    uint256 public maxLockTime = 90; // Days
    uint256 public minBondLockTime = 30; // Days
    uint256 public maxBondLockTime = 90; // Days

    // Fee payout destination wallets
    address private platformWallet; // Altrucoin Team wallet
    address private adminWallet; // Partner admin dev wallet
    address private charityWallet; // Charity wallet

    // Staking Fees and fee maxes
    uint256 private charityFee = 0; // 100 = 1% pool charity fee
    uint256 private entryFee = 150; // 500 = 5% pool entry fee
    uint256 private withdrawFee = 450; // 500 = 5% pool exit fee
    uint256 private bonusRate = 450; // 500 = 5% bonusRate multiplier for locking tokens
    uint256 private burnFee = 0; // 50 = .5% stkaing token entry and exit burn fee
    uint256 private adminFee = 0; // 100 = 1% stkaing token entry and exit team fee
    uint256 private platformFee = 150; // 50 = .5% stkaing token entry and exit team fee
    uint256 private earlyWithdrawFEE = 1500; // 1500 = 15% + normal withdraw = 25%
    //uint256 public secondTokenConversion = 0; // Used in Dual reward GENERATING vault, likely the conversaion rate or % - Not used in ALTRU vault/untested
    uint256 public constant MAX_CHARITY_FEE = 1000;
    uint256 public constant MAX_ENTRY_FEE = 1000; // 1000 = 10%
    uint256 public constant MAX_WITHDRAW_FEE = 1000; // 1000 = 10%
    uint256 public constant MAX_BONUS_FEE = 2000; // 2000 = 20%
    uint256 public constant MAX_Early_Withdraw_FEE = 5000; // 5000 = 50%
    uint256 public constant MAX_BURN_FEE = 1000; // 1000 = 10%
    uint256 public constant MAX_ADMIN_FEE = 500; // 500 = 5%
    uint256 public constant MAX_PLATFORM_FEE = 1000; // 1000 = 10%

    // Bonding fees
    uint256 private charityBondingFee = 0; // 100 = 1% pool charity fee
    uint256 private entryBondingFee = 300; // 500 = 5% pool entry fee
    uint256 private withdrawBondingFee = 300; // 500 = 5% pool exit fee
    uint256 private bonusBondingRate = 300; // 500 = 5% bonusRate multiplier for locking tokens
    uint256 private burnBondingFee = 0; // 50 = .5% stkaing token entry and exit burn fee
    uint256 private adminBondingFee = 0; // 100 = 1% stkaing token entry and exit team fee
    uint256 private platformBondingFee = 100; // 50 = .5% stkaing token entry and exit team fee
    uint256 private earlyWithdrawBondingFEE = 1500; // 1500 = 15% + normal withdraw = 18%

    //Reward tracker - Tracks last 7 days of rewards from all sources for staking token
    uint256 public allTimeFeeTracker = 0; // Vault total lifetime rewards tracker
    uint256[7] public feeTracker7days = [0, 0, 0, 0, 0, 0, 0]; //rewards from the last 7 days
    uint256 private blockTimeTracker = block.timestamp;
    uint256 private resetTracker = 0;
    uint256[7] private dayTracker = [0, 0, 0, 0, 0, 0, 0];

    //Reward tracker - Tracks last 7 days of rewards from all sources for secondToken
    uint256 public allTimeFeeTracker2ndToken = 0; // Vault total lifetime rewards tracker
    uint256[7] public feeTracker7days2ndToken = [0, 0, 0, 0, 0, 0, 0];
    uint256 private blockTimeTracker2ndToken = block.timestamp;
    uint256 private resetTracker2ndToken = 0;
    uint256[7] private dayTracker2ndToken = [0, 0, 0, 0, 0, 0, 0];

    // Total actual tokens, includes entry and exit fees to be distributed. Used to calculate external bonuses. Excludes locking bonuses and fee buckets (trackers)
    uint256 public _totalDistributedTokens = 0;
    uint256 private _entryExitFeeBucket = 0; // Rewards from entry/exit fee to be distributed to users on pool update. External bonuses go elsewhere. used for APY calculations only
    uint256 private _lastPoolUpdate = block.timestamp; // Tracks last time pool was updated

    //Address array variables
    address[] private addressIndexes;

    //Reflection variables
    uint256 public _tTotalMain1 = 1;
    uint256 public _rTotalMain1 = 1000000000000000000000000000000000000000;
    uint256 public totalStaked = 0;

    //User info
    mapping(address => UserInfo) private userInfo;
    struct UserInfo {
        bool exists; //Does address exist in array
        uint256 index; //index of address in array
        uint256 stakingAmount;
        uint256 lockTime; // Lock duration in seconds
        uint256 bondingLockTime; // Lock duration of bonding tokens in seconds
        uint256 lastLockedDepositTime; // last time the user deposited into locked pool
        uint256 lastBondingTime; // last time the user deposited into locked pool
        uint256 rOwnedStaked; // Staked tokens in R value
        uint256 rOwnedBonded; // Bonded tokens in R value
        uint256 totalSecondToken; // Second tokens owned by the user
        uint256 lastHoldingAmount; // Amount of tokens user owned at last withdraw or deposit, used to calculate rewards since last interaction
        uint256 lastBondingAmount; // Amount of tokens bonded by user at last interaction.
        uint256 stakingBonusTracker; // Used to delete bonus tokens rather than distributing them on withdraw
        uint256 bondingBonusTracker; // Used to delete bonus tokens rather than distributing them on withdraw
    }

    // Token addresses
    IERC20 public stakingToken; // The token being staked
    uint256 public sTokenDecimal; //decimal places of the staking token, used for voting token minting
    IERC20 public altrucoinToken; // Project Token
    IERC20 public secondToken; // 2nd Token in dual rewards system (can be any bep20 token)
    IERC20 public teamPayoutToken; // Token type for Altrucoin team payments
    VotingToken public votingToken; // Placeholder token used to vote on voting app while staking
    IUniswapV2Router02 public uniswapV2Router; //PancakeSwap Interface

    // Events
    event Deposit(address indexed sender, uint256 amount, uint256 lastLockedDepositTime); //amount = staking amount, amountWithFeeTakenOut = LP Mint Amount
    event BondTokens(
        address indexed sender,
        uint256 amount,
        uint256 lastBondedDepositTime
    ); //amount = staking amount, amountWithFeeTakenOut = LP Mint Amount
    event Withdraw(address indexed sender, uint256 stakedTokenWithdrawAmount); //stakedTokenWithdrawAmount = Amount minus exit fee
    event Pause();
    event Unpause();
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    event SwapBNBForTokens(uint256 amountIn, address[] path);

    /**
     * @notice Constructor
     */
    constructor(
        address _admin,
        address _treasury,
        address _adminWallet,
        IERC20 _stakingToken,
        uint256 _sTokenDecimal,
        IERC20 _secondToken,
        VotingToken _votingToken
    ) {
        admin = _admin;
        treasury = _treasury;
        platformWallet = 0x72abD73053AB1f7679bc2e8F7d720560BCe2EfAe;
        adminWallet = _adminWallet;
        charityWallet = 0x615042ee933fBEE8493bEB82C30495A55731AaF6;
        stakingToken = _stakingToken;
        sTokenDecimal = 10**_sTokenDecimal;
        altrucoinToken = IERC20(0x377Ef66728d344BFa2BB370186AB4B57092577bD); // mainnet
        //altrucoinToken = IERC20(0x2479D3E976A6357417B252181bc4a43679F66C2D); // testnet
        secondToken = _secondToken;
        // teamPayoutToken = IERC20(0x55d398326f99059fF775485246999027B3197955); // mainnet
        teamPayoutToken = IERC20(0x5A75b465Bd5Eb7084DD0D4C1864461800c1E1988); // testnet
        votingToken = _votingToken;

        //Safely lower rTotalMain
        _rTotalMain1 = _rTotalMain1.div(sTokenDecimal);

        // Set Pancakeswap Router for token swapping
        // MAINNET PCS Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        // TESTNET PCS Router: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    }

    /*============================================
    /   External User Functions
    /=============================================*/

    /**
     * @notice deposit into vault function, user supplies amount in staking tokens and lock time
     */
    function deposit(uint256 _amount, uint256 _dayNumber)
        external
        whenNotPaused
        nonReentrant
    {
        whenEnabledDeposits();
        UserInfo storage user = userInfo[msg.sender];
        require(_amount > 0);
        require(_amount >= sTokenDecimal / 10**5);
        require(_dayNumber <= maxLockTime && _dayNumber >= minLockTime);
        if (_dayNumber > 0) {
            require(int256((_dayNumber.mul(1 days))) > getStakeTimeLeft());
        }
        /*if (requireACForVault == true){
            require(altrucoinToken.balanceOf(msg.sender) > minimumTokenHold * 10**9, "This vault requires you to hold a certain amount of ALTRU to enter.");
        }*/
        //Set lock time
        if (_dayNumber != 0) {
            user.lastLockedDepositTime = block.timestamp;
            user.lockTime = _dayNumber.mul(1 days);
        }
        // Takes tokens, needs approval before this step, aka enable pool
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        user.stakingAmount += _amount;
        // Calculates fees and bonuses
        uint256 stBurnAmount = _amount.mul(burnFee).div(10000); // Tokens to burn
        uint256 stAdminAmount = _amount.mul(adminFee).div(10000);
        uint256 stPlatformAmount = _amount.mul(platformFee).div(10000);
        uint256 stCharityAmount = _amount.mul(charityFee).div(10000);
        uint256 stBonus = _amount
            .mul(_dayNumber.sub(minLockTime))
            .div(maxLockTime.sub(minLockTime))
            .mul(bonusRate)
            .div(10000);
        uint256 stEntryFee = _amount.mul(entryFee).div(10000); // Entry fee
        // Untested dual gen system
        /*
        if (dualGen == true){
            uint256 amountToConvertToSecondToken = stEntryFee.mul(secondTokenConversion).div(10000);
            stEntryFee = stEntryFee.sub(amountToConvertToSecondToken);
            swapStakingTokensForSecondTokens(amountToConvertToSecondToken, stakingToken, secondToken);
        }*/
        // Calculate amount of LP to "mint"
        uint256 lpMintAmount = _amount.sub(stEntryFee).sub(stAdminAmount).sub(
            stPlatformAmount
        );
        lpMintAmount = lpMintAmount.sub(stCharityAmount);
        lpMintAmount = lpMintAmount.add(stBonus).sub(stBurnAmount);
        user.stakingBonusTracker = user.stakingBonusTracker.add(stBonus);

        // _totalDistributedTokens is used to figure out external bonus tokens, does not include fee trackers or locking bonuses
        _totalDistributedTokens = _totalDistributedTokens.add(_amount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stBurnAmount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stCharityAmount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stAdminAmount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stPlatformAmount);
        //relfection reward distribution math
        if (_tTotalMain1 != 1) {
            _rTotalMain1 = _rTotalMain1.add(
                _rTotalMain1.mul(stEntryFee).div(_tTotalMain1)
            );
            _tTotalMain1 = _tTotalMain1.add(stEntryFee);
            _reflectFee(stEntryFee.mul(_getRate())); //reflect fee before user joins
            _entryExitFeeBucket = _entryExitFeeBucket.add(stEntryFee); // used for APY calculations
        }
        _rTotalMain1 = _rTotalMain1.add(_rTotalMain1.mul(lpMintAmount).div(_tTotalMain1));
        if (_tTotalMain1 == 1) {
            //removing initializer token for first user
            _tTotalMain1 = _tTotalMain1.add(lpMintAmount);
            _totalDistributedTokens = _totalDistributedTokens.sub(stEntryFee); //don't reflect for first user
        } else {
            //otherwise normal ratio update calculations
            _tTotalMain1 = _tTotalMain1.add(lpMintAmount);
        }
        // Add fees to threshold trackers
        adminFeeTracker = adminFeeTracker.add(stAdminAmount);
        platformFeeTracker = platformFeeTracker.add(stPlatformAmount);
        charityFeeTracker = charityFeeTracker.add(stCharityAmount);
        burnFeeTracker = burnFeeTracker.add(stBurnAmount);
        // Safely send fees if passed treshold
        payoutFees();
        //Give user their tokens
        totalStaked += lpMintAmount;
        user.rOwnedStaked = user.rOwnedStaked.add(lpMintAmount.mul(_getRate()));
        user.lastHoldingAmount = user.rOwnedStaked.div(_getRate()); //Reset reward tracker
        //update vualt on entry if enabled (distributed external rewards)
        if (updateOnEntry == true) {
            InternalUpdateVault();
        }
        if (secondTokenVault == true) {
            internalSecondTokenDistrubtion(secondTokenDistributesPerCall);
        }
        // Adds user addess to the array of all addresses
        addAddress(msg.sender);
        // Mint voting tokens for user if needed
        updateUserVotingTokens(msg.sender);
        loopVotingTokens(secondTokenDistributesPerCall);

        emit Deposit(msg.sender, _amount, block.timestamp);
    }

    /**
     * @notice Bond tokens into vault function, only callable by the bonder contract
     */
    function bondTokens(
        uint256 _amount,
        uint256 _dayNumber,
        address _origin
    ) external whenNotPaused nonReentrant {
        require(msg.sender == treasury || msg.sender == owner());
        whenEnabledDeposits();

        UserInfo storage user = userInfo[_origin];

        require(_amount > 0);
        require(_amount >= 10**8);

        require(_dayNumber <= maxBondLockTime && _dayNumber >= minBondLockTime);
        if (_dayNumber > 0) {
            require(int256((_dayNumber.mul(1 days))) > getBondTimeLeftInternal(_origin));
        }
        //Set lock time
        if (_dayNumber != 0) {
            user.lastBondingTime = block.timestamp;
            user.bondingLockTime = _dayNumber.mul(1 days);
        }

        // Takes tokens, needs approval before this step, aka enable pool
        stakingToken.transferFrom(msg.sender, address(this), _amount); //TODO make sure this system gets approval from trasury

        // Calculates fees and bonuses
        uint256 stBurnAmount = _amount.mul(burnBondingFee).div(10000); // Tokens to burn
        uint256 stAdminAmount = _amount.mul(adminBondingFee).div(10000);
        uint256 stPlatformAmount = _amount.mul(platformBondingFee).div(10000);
        uint256 stCharityAmount = _amount.mul(charityBondingFee).div(10000);
        uint256 stBonus = _amount.mul(_dayNumber.sub(minBondLockTime)).div(
            maxBondLockTime.sub(minBondLockTime)
        );
        stBonus = stBonus.mul(bonusBondingRate).div(10000); //stack too deep, had to split
        uint256 stEntryFee = _amount.mul(entryBondingFee).div(10000); // Entry fee

        // Calculate amount of LP to "mint"
        uint256 lpMintAmount = _amount.sub(stEntryFee);
        lpMintAmount = lpMintAmount.sub(stAdminAmount).sub(stPlatformAmount);
        lpMintAmount = lpMintAmount.sub(stCharityAmount);
        lpMintAmount = lpMintAmount.add(stBonus).sub(stBurnAmount);
        user.bondingBonusTracker = user.bondingBonusTracker.add(stBonus);

        // _totalDistributedTokens is used to figure out external bonus tokens, does not include fee trackers or locking bonuses
        _totalDistributedTokens = _totalDistributedTokens.add(_amount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stBurnAmount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stCharityAmount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stAdminAmount);
        _totalDistributedTokens = _totalDistributedTokens.sub(stPlatformAmount);

        //relfection reward distribution math
        if (_tTotalMain1 != 1) {
            _rTotalMain1 = _rTotalMain1.add(
                _rTotalMain1.mul(stEntryFee).div(_tTotalMain1)
            );
            _tTotalMain1 = _tTotalMain1.add(stEntryFee);
            _reflectFee(stEntryFee.mul(_getRate())); //reflect fee before user joins

            _entryExitFeeBucket = _entryExitFeeBucket.add(stEntryFee); // used for APY calculations
        }

        _rTotalMain1 = _rTotalMain1.add(_rTotalMain1.mul(lpMintAmount).div(_tTotalMain1));

        if (_tTotalMain1 == 1) {
            //removing initializer token for first user
            _tTotalMain1 = _tTotalMain1.add(lpMintAmount);
            _totalDistributedTokens = _totalDistributedTokens.sub(stEntryFee); //don't reflect for first user
        } else {
            //otherwise normal ratio update calculations
            _tTotalMain1 = _tTotalMain1.add(lpMintAmount);
        }

        // Add fees to threshold trackers
        adminFeeTracker = adminFeeTracker.add(stAdminAmount);
        platformFeeTracker = platformFeeTracker.add(stPlatformAmount);
        charityFeeTracker = charityFeeTracker.add(stCharityAmount);
        burnFeeTracker = burnFeeTracker.add(stBurnAmount);

        // Safely send team staking tokens
        payoutFees();
        // Stake tokens for user
        user.rOwnedBonded = user.rOwnedBonded.add(lpMintAmount.mul(_getRate()));
        user.lastBondingAmount = user.rOwnedBonded.div(_getRate()); //Reset reward tracker

        //update vualt on entry if enabled (distributed external rewards)
        if (updateOnEntry == true) {
            InternalUpdateVault();
        }
        if (secondTokenVault == true) {
            internalSecondTokenDistrubtion(secondTokenDistributesPerCall);
        }

        // Adds user addess to the array of all addresses
        addAddress(_origin);
        // Mint voting tokens for user if needed
        updateUserVotingTokens(_origin);
        loopVotingTokens(secondTokenDistributesPerCall);
        emit BondTokens(_origin, _amount, block.timestamp); //TODO make new emit
    }

    /**
     * @notice Withdraws the funds from the vault
     * @param _withdrawAmountST: Staking Withdraw amount, _withdrawAmountSecondToken: Second token withdraw amount, _withdrawBondedTokens: bonded tokens withdraw amount
     */
    function withdraw(
        uint256 _withdrawAmountST,
        uint256 _withdrawAmountSecondToken,
        uint256 _withdrawBondedTokens
    ) external whenNotPaused nonReentrant {
        // Safety require statements
        require(
            _withdrawAmountST > 0 ||
                _withdrawAmountSecondToken > 0 ||
                _withdrawBondedTokens > 0
        ); //Min withdraw is 0
        UserInfo storage user = userInfo[msg.sender]; // Set user
        // Withdraw amount checks
        if (_withdrawAmountST > 0) {
            require(_withdrawAmountSecondToken == 0 && _withdrawBondedTokens == 0); //only withdraw 1 token type at a time
            require(user.rOwnedStaked.div(_getRate()) >= _withdrawAmountST);
        }
        if (_withdrawAmountSecondToken > 0) {
            require(_withdrawAmountST == 0 && _withdrawBondedTokens == 0); //only withdraw 1 token type at a time
            require(user.totalSecondToken >= _withdrawAmountSecondToken);
        }
        if (_withdrawBondedTokens > 0) {
            require(_withdrawAmountSecondToken == 0 && _withdrawAmountST == 0); //only withdraw 1 token type at a time
            require(user.rOwnedBonded.div(_getRate()) >= _withdrawBondedTokens);
        }
        /*
        if (requireACForVault == true){
            require(altrucoinToken.balanceOf(msg.sender) > minimumTokenHold * 10**9, "This vault requires you to hold a certain amount of bankerdoge to enter.");
        }*/
        totalStaked -= _withdrawAmountST;
        //Lock time checks
        if (unstakeEarly == false && _withdrawAmountST > 0) {
            require(block.timestamp > user.lastLockedDepositTime.add(user.lockTime));
        }
        if (unstakeEarlyBonding == false && _withdrawBondedTokens > 0) {
            require(block.timestamp > user.lastBondingTime.add(user.bondingLockTime)); // No early withdraw for bonding tokens
        }
        uint256 _rOwnedStaked = user.rOwnedStaked;
        // Withdraw staking tokens

        if (_withdrawAmountST > 0) {
            //If exit fee is disabled, remove bonus from user withdraw
            if (withdrawFee == 0 || withdrawFee < bonusRate) {
                if (_withdrawAmountST > user.stakingBonusTracker) {
                    _withdrawAmountST = _withdrawAmountST.sub(user.stakingBonusTracker);
                    user.rOwnedStaked = user.rOwnedStaked.sub(
                        user.stakingBonusTracker.mul(_getRate())
                    );
                    user.stakingBonusTracker = 0;
                } else if (_withdrawAmountST <= user.stakingBonusTracker) {
                    user.stakingBonusTracker = user.stakingBonusTracker.sub(
                        _withdrawAmountST
                    );
                    user.rOwnedStaked = user.rOwnedStaked.sub(
                        _withdrawAmountST.mul(_getRate())
                    );
                    _withdrawAmountST = 0;
                }
            }
            // Calculates exit fee
            uint256 exitFee = _withdrawAmountST.mul(withdrawFee).div(10000);
            //Checks if unstake early is enabled. If so, charges unstake early fee
            if (
                unstakeEarly &&
                block.timestamp < user.lastLockedDepositTime.add(user.lockTime)
            ) {
                if (_withdrawAmountST == user.rOwnedStaked.div(_getRate())) {
                    user.lockTime = 0; //unlocks user timer if all tokens removed.
                }
                //calculates early withdraw fee
                exitFee = exitFee.add(_withdrawAmountST.mul(earlyWithdrawFEE).div(10000));
            }
            // Untested dual token gen system, not needed for ALTRU
            /*
            if (dualGen == true){
                uint256 amountToConvertToSecondToken = exitFee.mul(secondTokenConversion).div(10000);
                exitFee = exitFee.sub(amountToConvertToSecondToken);
                swapStakingTokensForSecondTokens(amountToConvertToSecondToken, stakingToken, secondToken);
            }*/

            // This line potentially causes double APY calculations of exitFee (once for this, once from external bonus pot)
            //_entryExitFeeBucket = _entryExitFeeBucket.add(exitFee); // used in APY calculations

            // Removes amount from actual tokens, when tokens are transfered this will place the exit fee left behind into external bonuses

            _totalDistributedTokens = _totalDistributedTokens.sub(_withdrawAmountST);

            // Add back user bonus to totalDist so that tokens that don't exist aren't distributed
            if (exitFee >= user.stakingBonusTracker) {
                _totalDistributedTokens = _totalDistributedTokens.add(
                    user.stakingBonusTracker
                );
                user.stakingBonusTracker = 0;
            } else if (exitFee < user.stakingBonusTracker) {
                _totalDistributedTokens = _totalDistributedTokens.add(exitFee);
                user.stakingBonusTracker = user.stakingBonusTracker.sub(exitFee);
            }

            //Reflection Math
            user.rOwnedStaked = user.rOwnedStaked.sub(_withdrawAmountST.mul(_getRate()));
            _rTotalMain1 = _rTotalMain1.sub(
                _rTotalMain1.mul(_withdrawAmountST).div(_tTotalMain1)
            );

            _tTotalMain1 = _tTotalMain1.sub(_withdrawAmountST);
            if (_tTotalMain1 == 0) {
                _tTotalMain1 = 1;
            }

            // Calculate and remove burn and team fee
            uint256 burnFeeST = _withdrawAmountST.mul(burnFee).div(10000);
            uint256 adminFeeST = _withdrawAmountST.mul(adminFee).div(10000);
            uint256 platformFeeST = _withdrawAmountST.mul(platformFee).div(10000);
            uint256 charityFeeST = _withdrawAmountST.mul(charityFee).div(10000);

            // Add fees to threshold trackers
            adminFeeTracker = adminFeeTracker.add(adminFeeST);
            platformFeeTracker = platformFeeTracker.add(platformFeeST);
            charityFeeTracker = charityFeeTracker.add(charityFeeST);
            burnFeeTracker = burnFeeTracker.add(burnFeeST);

            // Safely send fees out if passed threshold
            payoutFees();
            if (_withdrawAmountST > 0) {
                //calculates amount to send to user
                _withdrawAmountST = _withdrawAmountST.sub(exitFee);
                _withdrawAmountST = _withdrawAmountST.sub(burnFeeST).sub(adminFeeST).sub(
                    platformFeeST
                );
                _withdrawAmountST = _withdrawAmountST.sub(charityFeeST);

                // Sends staking tokens to user
                stakingToken.safeTransfer(msg.sender, _withdrawAmountST);
            }
            user.lastHoldingAmount = user.rOwnedStaked.div(_getRate()); //Reset reward tracker
        }

        user.stakingAmount = _rOwnedStaked - _withdrawAmountST.mul(_getRate());

        //Withdraw second tokens
        if (_withdrawAmountSecondToken > 0) {
            // Take tokens from user
            user.totalSecondToken = user.totalSecondToken.sub(_withdrawAmountSecondToken);
            totalDistrubtedSecondToken = totalDistrubtedSecondToken.sub(
                _withdrawAmountSecondToken
            ); // Remove tokens from total tracker

            uint256 platformFeeSTSecondToken = _withdrawAmountSecondToken
                .mul(platformFee)
                .div(10000); // Calc AC team fee
            platformFeeTrackerSecondToken = platformFeeTrackerSecondToken.add(
                platformFeeSTSecondToken
            ); // Add to AC 2nd token fee bucket

            // Calculate and remove burn and team fee
            if (feeForSecondToken == true) {
                //Calc fees
                uint256 exitFeeSecondToken = _withdrawAmountSecondToken
                    .mul(withdrawFee)
                    .div(10000);
                uint256 adminFeeSTSecondToken = _withdrawAmountSecondToken
                    .mul(adminFee)
                    .div(10000);
                uint256 charityFeeSTSecondToken = _withdrawAmountSecondToken
                    .mul(charityFee)
                    .div(10000);

                // Add to threshold trackers
                adminFeeTrackerSecondToken = adminFeeTrackerSecondToken.add(
                    adminFeeSTSecondToken
                );
                charityFeeTrackerSecondToken = charityFeeTrackerSecondToken.add(
                    charityFeeSTSecondToken
                );

                //calculates amount to send to user
                _withdrawAmountSecondToken = _withdrawAmountSecondToken.sub(
                    exitFeeSecondToken
                );
                _withdrawAmountSecondToken = _withdrawAmountSecondToken.sub(
                    adminFeeSTSecondToken
                );
                _withdrawAmountSecondToken = _withdrawAmountSecondToken.sub(
                    charityFeeSTSecondToken
                );
            }
            // Platform fee outside of if statement because platform fee always applies
            _withdrawAmountSecondToken = _withdrawAmountSecondToken.sub(
                platformFeeSTSecondToken
            );

            // Safely send team staking tokens
            payoutFees();

            if (_withdrawAmountSecondToken > 0) {
                // Sends staking tokens to user
                secondToken.safeTransfer(msg.sender, _withdrawAmountSecondToken);
            }
        }

        // Withdraw bonding tokens
        if (_withdrawBondedTokens > 0) {
            //If exit fee is disabled, remove bonus from user withdraw
            if (withdrawBondingFee == 0 || withdrawBondingFee < bonusBondingRate) {
                if (_withdrawBondedTokens > user.bondingBonusTracker) {
                    _withdrawBondedTokens = _withdrawBondedTokens.sub(
                        user.bondingBonusTracker
                    );
                    user.bondingBonusTracker = 0;
                }
                if (_withdrawBondedTokens <= user.bondingBonusTracker) {
                    user.bondingBonusTracker = user.bondingBonusTracker.sub(
                        _withdrawBondedTokens
                    );
                    _withdrawBondedTokens = 0;
                }
            }

            // Calculates fee
            uint256 exitFeeBonded = _withdrawBondedTokens.mul(withdrawBondingFee).div(
                10000
            );

            if (
                unstakeEarlyBonding &&
                block.timestamp < user.lastBondingTime.add(user.bondingLockTime)
            ) {
                if (_withdrawBondedTokens == user.rOwnedBonded.div(_getRate())) {
                    user.lockTime = 0; //unlocks user timer if all tokens removed.
                }
                //calculates early withdraw fee
                exitFeeBonded = exitFeeBonded.add(
                    _withdrawBondedTokens.mul(earlyWithdrawFEE).div(10000)
                );
            }

            // Untested dual token gen system
            /*
            if (dualGen == true){
                uint256 amountToConvertToSecondToken = exitFee.mul(secondTokenConversion).div(10000);
                exitFee = exitFee.sub(amountToConvertToSecondToken);
                swapStakingTokensForSecondTokens(amountToConvertToSecondToken, stakingToken, secondToken);
            }*/

            // This line potentially causes double APY calculations of exitFee (once for this, once from external bonus pot)
            //_entryExitFeeBucket = _entryExitFeeBucket.add(exitBondingFee); // used in APY calculations

            // Removes amount from actual tokens, when tokens are transfered this will place the exit fee left behind into external bonuses
            _totalDistributedTokens = _totalDistributedTokens.sub(_withdrawBondedTokens);
            if (exitFeeBonded >= user.bondingBonusTracker) {
                _totalDistributedTokens = _totalDistributedTokens.add(
                    user.bondingBonusTracker
                );
                user.bondingBonusTracker = 0;
            }
            if (exitFeeBonded < user.bondingBonusTracker) {
                _totalDistributedTokens = _totalDistributedTokens.add(exitFeeBonded);
                user.bondingBonusTracker = user.bondingBonusTracker.sub(exitFeeBonded);
            }

            //Reflection Math
            user.rOwnedBonded = user.rOwnedBonded.sub(
                _withdrawBondedTokens.mul(_getRate())
            );
            _rTotalMain1 = _rTotalMain1.sub(
                _rTotalMain1.mul(_withdrawBondedTokens).div(_tTotalMain1)
            );
            _tTotalMain1 = _tTotalMain1.sub(_withdrawBondedTokens);
            if (_tTotalMain1 == 0) {
                _tTotalMain1 = 1;
            }

            // Calculate and remove burn and team fee
            uint256 burnFeeBonded = _withdrawBondedTokens.mul(burnBondingFee).div(10000);
            uint256 adminFeeBonded = _withdrawBondedTokens.mul(adminBondingFee).div(
                10000
            );
            uint256 platformFeeBonded = _withdrawBondedTokens.mul(platformBondingFee).div(
                10000
            );
            uint256 charityFeeBonded = _withdrawBondedTokens.mul(charityBondingFee).div(
                10000
            );

            // Add fees to threshold trackers
            adminFeeTracker = adminFeeTracker.add(adminFeeBonded);
            platformFeeTracker = platformFeeTracker.add(platformFeeBonded);
            charityFeeTracker = charityFeeTracker.add(charityFeeBonded);
            burnFeeTracker = burnFeeTracker.add(burnFeeBonded);

            // Safely send fees out if passed threshold
            payoutFees();

            //calculates amount to send to user
            _withdrawBondedTokens = _withdrawBondedTokens.sub(exitFeeBonded);
            _withdrawBondedTokens = _withdrawBondedTokens
                .sub(burnFeeBonded)
                .sub(adminFeeBonded)
                .sub(platformFeeBonded);
            _withdrawBondedTokens = _withdrawBondedTokens.sub(charityFeeBonded);

            if (_withdrawBondedTokens > 0) {
                // Sends staking tokens to user
                stakingToken.safeTransfer(msg.sender, _withdrawBondedTokens);
            }

            user.lastBondingAmount = user.rOwnedBonded.div(_getRate()); //Reset reward tracker
        }

        // Removes user address from array of addresses if their balance is now 0
        if (
            user.rOwnedStaked == 0 && user.rOwnedBonded == 0 && user.totalSecondToken == 0
        ) {
            deleteAddress();
        }

        // Update vault distributing pending rewards
        if (updateOnExit == true) {
            InternalUpdateVault();
        }

        // Distribute 2nd token rewards
        if (secondTokenVault == true && updateOnExit == true) {
            internalSecondTokenDistrubtion(secondTokenDistributesPerCall);
        }

        // Burns excess voting tokens from user
        updateUserVotingTokens(msg.sender);
        loopVotingTokens(secondTokenDistributesPerCall);

        emit Withdraw(msg.sender, _withdrawAmountST);
    }

    /**
     * @notice Distributes rewards and bonuses to all users in the vault.
     */
    function updateVault() external whenNotPaused nonReentrant {
        if (addressIndexes.length == 0) {
            // Need at least 1 user
            return;
        }
        if (_tTotalMain1 <= sTokenDecimal) {
            // Need more than 1 token
            return;
        }

        // Saving amounts for apy calculations
        uint256 _allRewards = _entryExitFeeBucket.add(_getExternalBonusPot());
        _entryExitFeeBucket = 0; //empty the reward bucket
        feeTracker(_allRewards);

        //Distributes Staking Token rewards
        uint256 externalBonus = _getExternalBonusPot();
        if (externalBonus > 0) {
            //saves gas if nothing to update

            //Update ratio
            _rTotalMain1 = _rTotalMain1.add(
                _rTotalMain1.mul(externalBonus).div(_tTotalMain1)
            );
            _tTotalMain1 = _tTotalMain1.add(externalBonus);

            //reflect fee
            _reflectFee(externalBonus.mul(_getRate()));

            //Updates global tracker
            _totalDistributedTokens = _totalDistributedTokens.add(externalBonus); //already has entry and exit fees included
        }
        _lastPoolUpdate = block.timestamp; //update time pool was updated

        // Mint voting tokens for msg.sender if needed
        updateUserVotingTokens(msg.sender);
        loopVotingTokens(secondTokenDistributesPerCall);

        if (secondTokenVault == true) {
            internalSecondTokenDistrubtion(secondTokenDistributesPerCall);
        }
    }

    /*============================================
    /   Non UI Extermal Functions
    /=============================================*/

    /**
     * @notice Pays out team, admin and charity fees if thresholds are met
     */
    function payoutFees() internal whenNotPaused {
        // Safely send team staking tokens
        if (adminFeeTracker > adminMinSend) {
            stakingToken.safeTransfer(adminWallet, adminFeeTracker);
            adminRunningTotal = adminRunningTotal.add(adminFeeTracker);
            adminFeeTracker = 0;
        }
        // Safely send Altrucoin team staking tokens in type teamPayoutToken
        if (platformFeeTracker > platformMinSend) {
            uint256 balanceBf = teamPayoutToken.balanceOf(address(this));
            swapStakingTokensForSecondTokens(
                platformFeeTracker,
                stakingToken,
                teamPayoutToken
            );
            uint256 balanceAf = teamPayoutToken.balanceOf(address(this)).sub(balanceBf);
            teamPayoutToken.safeTransfer(platformWallet, balanceAf);
            platformRunningTotal = platformRunningTotal.add(platformFeeTracker);
            platformFeeTracker = 0;
        }
        // Safely send Altrucoin charity staking tokens in type teamPayoutToken
        if (charityFeeTracker > charityMinSend) {
            uint256 balanceBf = teamPayoutToken.balanceOf(address(this));
            swapStakingTokensForSecondTokens(
                charityFeeTracker,
                stakingToken,
                teamPayoutToken
            );
            uint256 balanceAf = teamPayoutToken.balanceOf(address(this)).sub(balanceBf);
            teamPayoutToken.safeTransfer(charityWallet, balanceAf);
            charityRunningTotal = charityRunningTotal.add(charityFeeTracker);
            charityFeeTracker = 0;
        }
        if (burnFeeTracker > burnMinSend) {
            stakingToken.safeTransfer(
                address(0x000000000000000000000000000000000000dEaD),
                burnFeeTracker
            );
            burnRunningTotal = burnRunningTotal.add(burnFeeTracker);
            burnFeeTracker = 0;
        }
        // Safely send team second token fees
        //Send platform team fee
        //TODO CHANGE THE SWAPS HERE FOR BNB secondToken vaults!
        if (secondTokenVault == true) {
            if (platformFeeTrackerSecondToken > platformMinSendSecondToken) {
                uint256 balanceBf = teamPayoutToken.balanceOf(address(this));
                swapStakingTokensForSecondTokens(
                    platformFeeTrackerSecondToken,
                    secondToken,
                    teamPayoutToken
                ); // Swap fee bucket tokens for payout token
                uint256 balanceAf = teamPayoutToken.balanceOf(address(this)).sub(
                    balanceBf
                );
                teamPayoutToken.safeTransfer(platformWallet, balanceAf); // Send tokens to platform team
                platformRunningTotalSecondToken = platformRunningTotalSecondToken.add(
                    platformFeeTrackerSecondToken
                ); // Add to running total
                platformFeeTrackerSecondToken = 0; // Reset fee bucket tracker
            }
            // Send admin fee
            if (adminFeeTrackerSecondToken > adminMinSendSecondToken) {
                secondToken.safeTransfer(adminWallet, adminFeeTrackerSecondToken);
                adminRunningTotalSecondToken = adminRunningTotalSecondToken.add(
                    adminFeeTrackerSecondToken
                );
                adminFeeTrackerSecondToken = 0; // Reset fee bucket tracker
            }
            // Send charity fee
            if (charityFeeTrackerSecondToken > charityMinSendSecondToken) {
                uint256 balanceBf = teamPayoutToken.balanceOf(address(this));
                swapStakingTokensForSecondTokens(
                    charityFeeTrackerSecondToken,
                    secondToken,
                    teamPayoutToken
                ); // Swap fee bucket tokens for payout token
                uint256 balanceAf = teamPayoutToken.balanceOf(address(this)).sub(
                    balanceBf
                );
                teamPayoutToken.safeTransfer(charityWallet, balanceAf);
                charityRunningTotalSecondToken = charityRunningTotalSecondToken.add(
                    charityFeeTrackerSecondToken
                );
                charityFeeTrackerSecondToken = 0; // Reset fee bucket tracker
            }
        }
    }

    /**
     * @notice WARNING: GAS INTENSIVE! - Funciton to distribut dual token rewards to users, for external use, can set number of users to distribute to.
     */
    /*function secondTokenDistrubtion(uint256 loopTimes) external whenNotPaused nonReentrant {	
        TODO Update this to match internal once it is actually used.
        bool EnoughSecondToken = false;	
        if (loopIndex > 0){	
            EnoughSecondToken = true;	
        }	
        if(loopIndex == 0){	
            // Take a copy of r and t totals to do a static "getRate()" until the loop is complete	
            _tCycleCopy = _tTotalMain1;	
            _rCycleCopy = _rTotalMain1;	
            //Only start a new loop if there is new second token to distribute	
            if(secondToken.balanceOf(address(this)) > totalDistrubtedSecondToken.add(adminFeeTrackerSecondToken).add(platformFeeTrackerSecondToken).add(charityFeeTrackerSecondToken)){	
                secondTokenRewards = secondToken.balanceOf(address(this)).sub(totalDistrubtedSecondToken).sub(adminFeeTrackerSecondToken).sub(platformFeeTrackerSecondToken).sub(charityFeeTrackerSecondToken);	
                EnoughSecondToken = true;	
            }	
            //Take a copy of the address array length to cycle through this loop	
            userArrayLengthCopy = addressIndexes.length;	
        }	
        uint256 totalFromloop = 0; // Adds up amount of tokens distributed by this loop, later added to the second token reward tracker	
        if(EnoughSecondToken == true){  // If there are tokens to be distributed	
            for (uint256 i = 0; i < loopTimes; i++){ // Execute loop equal to the # loopTimes	
                // Check if cycle complete	
                if(loopIndex >= userArrayLengthCopy){ 	
                    loopIndex = 0;	
                    break; // If full cycle is complete, end loop	
                }	
                // Calculate reward	
                if(loopIndex < addressIndexes.length){	
                    UserInfo storage user = userInfo[addressIndexes[loopIndex]]; // Get user info at loopIndex	
                    uint256 userAmount = (user.rOwnedStaked.add(user.rOwnedBonded)).div((_rCycleCopy.div(_tCycleCopy))); // Get user Staking + bonding Token amount	
                    userAmount = (secondTokenRewards.mul(userAmount)).div(_tCycleCopy); // Get % of rewards being distributed to user	
                    // Distribute reward	
                    totalDistrubtedSecondToken = totalDistrubtedSecondToken.add(userAmount); // add tokens for user to distributed tracker	
                    user.totalSecondToken = user.totalSecondToken.add(userAmount); // Reward user with their share of tokens	
                    totalFromloop = totalFromloop.add(userAmount); // For general reward tracking		
                }	
                // Increment loopIndex to next user	
                loopIndex = loopIndex.add(1);	
            }	
        }	
        	
        feeTrackerSecondToken(totalFromloop);	
    }*/

    /**
     * @notice Withdraws tokens without caring about rewards. THIS CAN BREAK ALL VAULT MATH
     * @dev EMERGENCY ONLY. THIS CAN BREAK ALL VAULT MATH. Only callable by the contract owner.
     */
    function emergencyWithdraw(
        address _randomToken,
        bool takeTokens,
        uint256 tokenAmount,
        bool takeBNB,
        uint256 bnbAmount,
        bool takeAllTokens,
        bool takeAllBNB
    ) external onlyOwner {
        if (address(this).balance > 0 && takeAllBNB == true) {
            payable(msg.sender).transfer(address(this).balance);
        }
        if (address(this).balance > 0 && takeBNB == true) {
            payable(msg.sender).transfer(bnbAmount);
        }
        if (IERC20(_randomToken).balanceOf(address(this)) > 0 && takeAllTokens == true) {
            uint256 amount = IERC20(_randomToken).balanceOf(address(this));
            IERC20(_randomToken).safeTransfer(msg.sender, amount);
        }
        if (IERC20(_randomToken).balanceOf(address(this)) > 0 && takeTokens == true) {
            IERC20(_randomToken).safeTransfer(msg.sender, tokenAmount);
        }
    }

    /*============================================
    /   Internal Functionality Functions
    /=============================================*/

    /**
     * @notice Dual token reward math used to distribute second reward token to staked users. DUPLICATED FUNCTION for reentrancy conflict
     */
    function internalSecondTokenDistrubtion(uint256 loopTimes) internal {
        bool EnoughSecondToken = false;
        if (loopIndex > 0) {
            EnoughSecondToken = true;
        }
        if (loopIndex == 0) {
            // Take a copy of r and t totals to do a static "getRate()" until the loop is complete
            _tCycleCopy = _tTotalMain1;
            _rCycleCopy = _rTotalMain1;

            //Only start a new loop if there is new second token to distribute
            if (
                secondToken.balanceOf(address(this)) >
                totalDistrubtedSecondToken
                    .add(adminFeeTrackerSecondToken)
                    .add(platformFeeTrackerSecondToken)
                    .add(charityFeeTrackerSecondToken)
            ) {
                secondTokenRewards = secondToken
                    .balanceOf(address(this))
                    .sub(totalDistrubtedSecondToken)
                    .sub(adminFeeTrackerSecondToken)
                    .sub(platformFeeTrackerSecondToken)
                    .sub(charityFeeTrackerSecondToken);
                EnoughSecondToken = true;
            }
            //Take a copy of the address array length to cycle through this loop
            userArrayLengthCopy = addressIndexes.length;
        }

        uint256 totalFromloop = 0; // Adds up amount of tokens distributed by this loop, later added to the second token reward tracker

        if (EnoughSecondToken == true) {
            // If there are tokens to be distributed
            for (uint256 i = 0; i < loopTimes; i++) {
                // Execute loop equal to the # loopTimes
                // Check if cycle complete
                if (loopIndex >= userArrayLengthCopy) {
                    loopIndex = 0;
                    break; // If full cycle is complete, end loop
                }

                // Calculate reward
                if (loopIndex < addressIndexes.length) {
                    UserInfo storage user = userInfo[addressIndexes[loopIndex]]; // Get user info at loopIndex
                    uint256 userAmount = (user.rOwnedStaked.add(user.rOwnedBonded)).div(
                        (_rCycleCopy.div(_tCycleCopy))
                    ); // Get user Staking + bonding Token amount
                    userAmount = (secondTokenRewards.mul(userAmount)).div(_tCycleCopy); // Get % of rewards being distributed to user

                    // Distribute reward
                    totalDistrubtedSecondToken = totalDistrubtedSecondToken.add(
                        userAmount
                    ); // add tokens for user to distributed tracker
                    user.totalSecondToken = user.totalSecondToken.add(userAmount); // Reward user with their share of tokens
                    totalFromloop = totalFromloop.add(userAmount); // For general reward tracking
                }

                // Increment loopIndex to next user
                loopIndex = loopIndex.add(1);
            }
        }

        feeTrackerSecondToken(totalFromloop);
    }

    /**
     * @notice Totals up rewards from the last 7 days.
     */
    function feeTracker(uint256 feeTotal) internal {
        // 7 day reset tracker
        if (block.timestamp > blockTimeTracker.add(7 days)) {
            resetTracker = resetTracker.add(1);
            blockTimeTracker = blockTimeTracker.add(7 days);
        }
        // Loop to save rewards to the appropriate slot in the 7 day array
        for (uint256 i = 0; i < 7; i++) {
            if (
                block.timestamp >= blockTimeTracker.add(i.mul(1 days)) &&
                block.timestamp < blockTimeTracker.add((i.add(1)).mul(1 days))
            ) {
                //finds which day it is
                if (resetTracker != dayTracker[i]) {
                    //checks to make sure a week hasn't passed
                    for (uint256 j = 0; j <= i; j++) {
                        // cycles days
                        if (dayTracker[j] != resetTracker) {
                            //if day didn't have an update
                            dayTracker[j] = resetTracker; //set to new day tracker
                            feeTracker7days[j] = 0; //set that day to 0
                        }
                    }
                }
                feeTracker7days[i] = feeTracker7days[i].add(feeTotal);
                break;
            }
        }

        // Lifetime reward tracker
        allTimeFeeTracker = allTimeFeeTracker.add(feeTotal);
    }

    /**
     * @notice Totals up rewards from the last 7 days. FOR DUAL REWARD TOKEN
     */
    function feeTrackerSecondToken(uint256 feeTotal) internal {
        if (block.timestamp > blockTimeTracker2ndToken.add(7 days)) {
            resetTracker2ndToken = resetTracker2ndToken.add(1);
            blockTimeTracker2ndToken = blockTimeTracker2ndToken.add(7 days);
        }
        for (uint256 i = 0; i < 7; i++) {
            if (
                block.timestamp >= blockTimeTracker2ndToken.add(i.mul(1 days)) &&
                block.timestamp < blockTimeTracker2ndToken.add((i.add(1)).mul(1 days))
            ) {
                if (resetTracker2ndToken != dayTracker2ndToken[i]) {
                    for (uint256 j = 0; j <= i; j++) {
                        if (dayTracker2ndToken[j] != resetTracker2ndToken) {
                            dayTracker2ndToken[j] = resetTracker2ndToken;
                            feeTracker7days2ndToken[j] = 0;
                        }
                    }
                }
                feeTracker7days2ndToken[i] = feeTracker7days2ndToken[i].add(feeTotal);
                break;
            }
        }
        allTimeFeeTracker2ndToken = allTimeFeeTracker2ndToken.add(feeTotal);
    }

    // Sends fee to all vault stakers
    function _reflectFee(uint256 rFee) internal {
        _rTotalMain1 = _rTotalMain1.sub(rFee);
    }

    // Used to convert values from R (relfection) space to T (token) space
    function _getRate() public view returns (uint256) {
        return _rTotalMain1.div(_tTotalMain1);
    }

    /**
     * @notice Distributes rewards and bonuses to all users in the vault. INTERNAL version without Nonreentrant to not conflict with reentrancy guard
     */
    function InternalUpdateVault() internal whenNotPaused {
        if (addressIndexes.length == 0) {
            // Need at least 1 user
            return;
        }
        if (_tTotalMain1 <= sTokenDecimal) {
            // Need more than 1 token
            return;
        }

        // Saving amounts for apy calculations
        uint256 _allRewards = _entryExitFeeBucket.add(_getExternalBonusPot());
        _entryExitFeeBucket = 0; //empty the reward bucket
        feeTracker(_allRewards);

        //Distributes Staking Token rewards
        uint256 externalBonus = _getExternalBonusPot();
        if (externalBonus > 0) {
            //saves gas if nothing to update

            //Update ratio
            _rTotalMain1 = _rTotalMain1.add(
                _rTotalMain1.mul(externalBonus).div(_tTotalMain1)
            );
            _tTotalMain1 = _tTotalMain1.add(externalBonus);

            //reflect fee
            _reflectFee(externalBonus.mul(_getRate()));

            //Updates global tracker
            _totalDistributedTokens = _totalDistributedTokens.add(externalBonus); //already has entry and exit fees included
        }

        _lastPoolUpdate = block.timestamp; //update time pool was updated
    }

    /**
     * @notice Updates users voting token amount based on held tokens
     */
    function updateUserVotingTokens(address _userAddress) internal {
        UserInfo storage user = userInfo[_userAddress]; // Set user
        if (votingTokenEnabled == true && user.exists == true) {
            uint256 userTokensTotal = (
                (user.rOwnedStaked.add(user.rOwnedBonded)).div(_getRate())
            ).mul(10**18).div(sTokenDecimal);
            // Checks to see if there needs to be voting tokens minted for the user
            if (votingToken.balanceOf(_userAddress) < userTokensTotal) {
                //Mints the tokens for the user
                votingToken.mint(
                    _userAddress,
                    userTokensTotal.sub(votingToken.balanceOf(_userAddress))
                );
            }
            // Checks to see if there is more voting token than user staked tokens
            if (votingToken.balanceOf(_userAddress) > userTokensTotal) {
                // Burns excess voting token from the user
                votingToken.burn(
                    _userAddress,
                    votingToken.balanceOf(_userAddress).sub(userTokensTotal)
                );
            }
        }
    }

    /**
     * @notice loops through all users ("loopTimes" users at a time) Updates users voting token amount based on held tokens
     */
    function loopVotingTokens(uint256 loopTimes2) internal {
        //Loop through other users and update voting tokens
        if (loopIndex2 == 0) {
            //Take a copy of the address array length to cycle through this loop
            userArrayLengthCopy2 = addressIndexes.length;
        }
        for (uint256 i = 0; i < loopTimes2; i++) {
            // Execute loop equal to the # loopTimes
            // Check if cycle complete
            if (loopIndex2 >= userArrayLengthCopy2) {
                loopIndex2 = 0;
                break; // If full cycle is complete, end loop
            }
            // Check if loop passed index length (this prevents error if users leave)
            if (loopIndex2 < addressIndexes.length) {
                // Update voting token for user as well
                updateUserVotingTokens(addressIndexes[loopIndex2]);
            }

            // Increment loopIndex to next user
            loopIndex2 = loopIndex.add(1);
        }
    }

    /**
     * @notice Adds new address to array of all vault holders
     */
    function addAddress(address userAddress) internal {
        UserInfo storage user = userInfo[userAddress];

        // If user already exists, skip. Otherwise add user to address list array
        if (user.exists == true) {
            return;
        } else {
            // else its new user
            addressIndexes.push(userAddress);
            if (addressIndexes.length > 0) {
                user.index = addressIndexes.length.sub(1);
            } else if (addressIndexes.length == 0) {
                user.index = addressIndexes.length;
            }
            user.exists = true;
        }
    }

    /**
     * @notice Deletes address to array of all vault holders
     */
    function deleteAddress() internal {
        // Checks if address exists
        if (userInfo[msg.sender].exists == true) {
            // Checks if index is not the last entry
            if (userInfo[msg.sender].index != addressIndexes.length - 1) {
                // Moves address from last slot to the slot of address going to be deleted, then deletes last slot.
                address lastAddress = addressIndexes[addressIndexes.length - 1];
                addressIndexes[userInfo[msg.sender].index] = lastAddress;
                userInfo[lastAddress].index = userInfo[msg.sender].index;
            }
            delete userInfo[msg.sender];
            addressIndexes.pop();
        }
    }

    /*============================================
    /   View Functions
    /=============================================*/

    /**
     * @notice Calculates bonus staking tokens in the pool (from external reflection or manually added bonus)
     */
    function _getExternalBonusPot() public view returns (uint256) {
        return
            balanceOf()
                .sub(_totalDistributedTokens)
                .sub(adminFeeTracker)
                .sub(platformFeeTracker)
                .sub(charityFeeTracker)
                .sub(burnFeeTracker);
    }

    /**
     * @notice Calculates the total stakingTokens in the vault
     */
    function balanceOf() public view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }

    function getUserInfo(address user) external view returns (UserInfo memory) {
        return userInfo[user];
    }

    /**
     * @notice Returns address at index.
     */
    function getAddressAtIndex(uint256 _index) public view returns (address) {
        return addressIndexes[_index];
    }

    /**
     * @notice Gets users lock time remaining
     */
    function getStakeTimeLeft() public view returns (int256) {
        UserInfo storage user = userInfo[msg.sender];
        int256 timeInSeconds = int256(user.lockTime) +
            int256(user.lastLockedDepositTime) -
            int256(block.timestamp);
        if (timeInSeconds <= 0) {
            timeInSeconds = 0;
        }

        return (timeInSeconds);
    }

    /**
     * @notice Gets users bonding time remaining
     */
    function getBondTimeLeftInternal(address _originAddress)
        internal
        view
        returns (int256)
    {
        UserInfo storage user = userInfo[_originAddress];
        int256 timeInSecondsBonding = int256(user.bondingLockTime) +
            int256(user.lastBondingTime) -
            int256(block.timestamp);
        if (timeInSecondsBonding <= 0) {
            timeInSecondsBonding = 0;
        }
        return (timeInSecondsBonding);
    }

    function getTotalUsers() external view returns (uint256) {
        return addressIndexes.length;
    }

    /**
     * @notice Returns all control bools of the vault
     */
    function getAllControls()
        external
        view
        returns (
            bool,
            bool,
            bool,
            bool,
            bool,
            bool,
            bool,
            bool
        )
    {
        return (
            votingTokenEnabled,
            mintVTOnUpdate,
            updateOnEntry,
            updateOnExit,
            unstakeEarly,
            unstakeEarlyBonding,
            secondTokenVault,
            feeForSecondToken
        );
    }

    // See if deposits are disabled
    function depositsDisabled() external view virtual returns (bool) {
        return _disableDeposits;
    }

    // /**
    //  * @notice Checks if address is admin or owner
    //  */
    // function isAdminOrOwner() public view returns (bool) {
    //     if (msg.sender == admin || msg.sender == owner()) {
    //         return true;
    //     } else return false;
    // }

    /**
     * @notice Checks if address is admin or owner
     */
    function getRunningTotals()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            adminRunningTotal,
            charityRunningTotal,
            platformRunningTotal,
            burnRunningTotal,
            adminRunningTotalSecondToken,
            charityRunningTotalSecondToken,
            platformRunningTotalSecondToken
        );
    }

    /**
     * @notice Checks if address is admin or owner
     */
    function getMinSends()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            charityMinSend,
            adminMinSend,
            platformMinSend,
            burnMinSend,
            charityMinSendSecondToken,
            platformMinSendSecondToken,
            adminMinSendSecondToken
        );
    }

    /**
     * @notice Checks if address is admin or owner
     */
    function getWallets()
        external
        view
        returns (
            address,
            address,
            address
        )
    {
        return (adminWallet, platformWallet, charityWallet);
    }

    /**
     * @notice Returns staking fees
     */
    function getAllStakingFees()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            charityFee,
            entryFee,
            withdrawFee,
            bonusRate,
            burnFee,
            adminFee,
            platformFee,
            earlyWithdrawFEE
        );
    }

    /**
     * @notice Returns bonding fees
     */
    function getAllBondingFees()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            charityBondingFee,
            entryBondingFee,
            withdrawBondingFee,
            bonusBondingRate,
            burnBondingFee,
            adminBondingFee,
            platformBondingFee,
            earlyWithdrawBondingFEE
        );
    }

    function getAllTrackers()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            charityFeeTracker,
            adminFeeTracker,
            platformFeeTracker,
            burnFeeTracker,
            charityFeeTrackerSecondToken,
            adminFeeTrackerSecondToken,
            platformFeeTrackerSecondToken
        );
    }

    // /*============================================
    // /   Modifier Functions
    // /=============================================*/

    // /**
    //  * @notice checks that address is admin or owner
    //  */
    // modifier() {
    //     require(msg.sender == admin || msg.sender == owner(), 'not admin/owner');
    //     _;
    // }

    /**
     * @notice checks that deposits are enabled
     */
    function whenEnabledDeposits() internal view {
        require(_disableDeposits == false);
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    /*modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }*/

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    /*function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }*/

    /*============================================
    /   Set Variable Functions
    /=============================================*/

    /**
     * @notice Triggers deposit stopped state
     * @dev Only possible when contract not paused.
     */
    function setDisableDeposits(bool _toggle) external {
        _disableDeposits = _toggle;
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Set enable/disable unstake early
     */
    function setUnstakeEarly(bool _toggle, bool _toggle2) external {
        unstakeEarly = _toggle;
        unstakeEarlyBonding = _toggle2;
    }

    /**
     * @notice Set enable/disable fees on the second token
     */
    function setFeeForSecondTokenAndDualGen(
        bool _toggle,
        /*bool _toggle2,*/
        bool _toggle3
    ) external onlyOwner {
        feeForSecondToken = _toggle;
        //dualGen = _toggle2; //UNTESTED
        secondTokenVault = _toggle3;
    }

    /**
     * @notice Set number of users to distributed second reward tokens to per normal vault update
     */
    function setSecondTokenDistributesPerCall(uint256 amount) external {
        secondTokenDistributesPerCall = amount;
    }

    /**
     * @notice Sets admin address
     * @dev Only callable by the contract owner.
     */
    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0));
        admin = _admin;
    }

    /**
     * @notice Sets treasury address
     * @dev Only callable by the contract owner.
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0));
        treasury = _treasury;
    }

    /**
     * @notice Sets min and max lock time
     * @dev Only callable by the contract admin.
     */
    function setMinAndMaxLockTime(
        uint256 _minLockTime,
        uint256 _maxLockTime,
        uint256 _minBondLockTime,
        uint256 _maxBondLockTime
    ) external {
        if (msg.sender != owner()) {
            require(
                _maxLockTime <= MAX_MAX_LOCK_TIME &&
                    _minLockTime <= MAX_MIN_LOCK_TIME &&
                    _maxBondLockTime <= MAX_MAX_LOCK_TIME &&
                    _minBondLockTime <= MAX_MIN_LOCK_TIME,
                '>MAX'
            );
        }
        maxLockTime = _maxLockTime;
        minLockTime = _minLockTime;
        maxBondLockTime = _maxBondLockTime;
        minBondLockTime = _minBondLockTime;
    }

    /**
     * @notice Sets all fees related to staking tokens
     * @dev Only callable by the contract admin or owner.
     */
    function setStakingFees(
        uint256 _entryFee,
        uint256 _burnFee,
        uint256 _adminFee,
        uint256 _platformFee,
        uint256 _charityFee,
        uint256 _bonusRate,
        uint256 _withdrawFee,
        uint256 _earlyWithdrawFEE /*, uint256 _secondTokenConversion*/
    ) external {
        if (msg.sender != owner()) {
            require(
                _entryFee <= MAX_ENTRY_FEE &&
                    _burnFee <= MAX_BURN_FEE &&
                    _adminFee <= MAX_ADMIN_FEE &&
                    _charityFee <= MAX_CHARITY_FEE &&
                    _platformFee <= MAX_PLATFORM_FEE,
                '>MAX'
            );
            //require(_secondTokenConversion <= MAX_ENTRY_FEE, "second Token Conversion cannot be more than MAX_ENTRY_FEE");
            require(
                _bonusRate <= MAX_BONUS_FEE &&
                    _withdrawFee <= MAX_WITHDRAW_FEE &&
                    _withdrawFee >= _bonusRate &&
                    _earlyWithdrawFEE <= MAX_Early_Withdraw_FEE,
                '>MAX'
            );
        }
        burnFee = _burnFee;
        entryFee = _entryFee;
        adminFee = _adminFee;
        platformFee = _platformFee;
        charityFee = _charityFee;
        bonusRate = _bonusRate;
        withdrawFee = _withdrawFee;
        earlyWithdrawFEE = _earlyWithdrawFEE;
        //secondTokenConversion = _secondTokenConversion;
    }

    /**
     * @notice Sets all fees related to bonding tokens
     * @dev Only callable by the contract admin or owner.
     */
    function setBondingFees(
        uint256 _entryFee,
        uint256 _burnFee,
        uint256 _adminFee,
        uint256 _platformFee,
        uint256 _charityFee,
        uint256 _bonusRate,
        uint256 _withdrawFee,
        uint256 _earlyWithdrawFEE /*, uint256 _secondTokenConversion*/
    ) external {
        if (msg.sender != owner()) {
            require(
                _entryFee <= MAX_ENTRY_FEE &&
                    _burnFee <= MAX_BURN_FEE &&
                    _adminFee <= MAX_ADMIN_FEE &&
                    _charityFee <= MAX_CHARITY_FEE &&
                    _platformFee <= MAX_PLATFORM_FEE,
                '>MAX'
            );
            //require(_secondTokenConversion <= MAX_ENTRY_FEE, "second Token Conversion cannot be more than MAX_ENTRY_FEE");
            require(
                _bonusRate <= MAX_BONUS_FEE &&
                    _withdrawFee <= MAX_WITHDRAW_FEE &&
                    _withdrawFee >= _bonusRate &&
                    _earlyWithdrawFEE <= MAX_Early_Withdraw_FEE,
                '>MAX'
            );
        }
        burnBondingFee = _burnFee;
        entryBondingFee = _entryFee;
        adminBondingFee = _adminFee;
        platformBondingFee = _platformFee;
        charityBondingFee = _charityFee;
        bonusBondingRate = _bonusRate;
        withdrawBondingFee = _withdrawFee;
        earlyWithdrawBondingFEE = _earlyWithdrawFEE;
        //secondTokenConversion = _secondTokenConversion; // UNTESTED
    }

    /**
     * @notice
     * @dev Only possible when contract not paused.
     */
    function setFeeMinSendAmounts(
        uint256 adminFeeMin,
        uint256 platformFeeMin,
        uint256 charityFeeMin,
        uint256 burnFeeMin,
        uint256 adminSecondFeeMin,
        uint256 platformSecondFeeMin,
        uint256 charitySecondFeeMin
    ) external onlyOwner {
        adminMinSend = adminFeeMin;
        platformMinSend = platformFeeMin;
        charityMinSend = charityFeeMin;
        burnMinSend = burnFeeMin;
        adminMinSendSecondToken = adminSecondFeeMin;
        platformMinSendSecondToken = platformSecondFeeMin;
        charityMinSendSecondToken = charitySecondFeeMin;
    }

    /**
     * @notice Sets voting token, altrucoin token and payout token, staking token, 2nd token
     * @dev Only callable by the contract admin.
     */
    function setVaultTokens(
        IERC20 _acAddress,
        IERC20 _payout,
        VotingToken _votingAddress,
        IERC20 _stakingAddress,
        IERC20 _secondTokenAddress
    ) external onlyOwner {
        altrucoinToken = _acAddress;
        teamPayoutToken = _payout;
        votingToken = _votingAddress;
        stakingToken = _stakingAddress;
        secondToken = _secondTokenAddress;
    }

    /**
     * @notice Sets staking token decimal. Enter single or double digit value and it will auto convert to needed value for internal math
     * @dev Only callable by the contract owner.
     */
    function setSTokenDecimal(uint256 newSTokenDecimal) external onlyOwner {
        sTokenDecimal = 10**newSTokenDecimal;
    }

    /**
     * @notice Sets fee payout wallets for admin, platform and charity fees
     * @dev Only callable by the contract admin.
     */
    function setFeeWallets(
        address _adminWallet,
        address _platformWallet,
        address _charityWallet
    ) external {
        adminWallet = _adminWallet;
        platformWallet = _platformWallet;
        charityWallet = _charityWallet;
    }

    /**
     * @notice toggle using voting token
     */
    function setVotingTokenEnabled(bool _toggle, bool _toggle2) public onlyOwner {
        votingTokenEnabled = _toggle;
        mintVTOnUpdate = _toggle2;
    }

    /**
     * @notice toggle updating vault on every user entry and exit
     */
    function setUpdateOnEntryAndExit(bool _entryToggle, bool _exitToggle) public {
        updateOnEntry = _entryToggle;
        updateOnExit = _exitToggle;
    }

    /**
     * @notice toggle requiring BankerDoge token for entry
     * @dev Only callable by the contract owner.
     */
    /*function setRequireBDTAndMinHold(bool _toggle, uint256 _minimumTokenHold) public onlyOwner {
        requireACForVault = _toggle;
        minimumTokenHold = _minimumTokenHold;
    }*/
    // Not needed for ALTRU vault

    /**
     * @notice Set various vault variables in case of math issue. Best to pause vault before using.
     * @dev Only callable by the contract owner.
     */
    function setDistributedValues(
        uint256 _totalDistributedTokensAmount,
        uint256 newTotalDistSecondToken,
        uint256 newSecondTokenRewards,
        uint256 newLoopIndex,
        uint256 newLoopIndex2
    ) external whenPaused onlyOwner {
        _totalDistributedTokens = _totalDistributedTokensAmount;
        totalDistrubtedSecondToken = newTotalDistSecondToken;
        secondTokenRewards = newSecondTokenRewards;
        loopIndex = newLoopIndex;
        loopIndex2 = newLoopIndex2;
    }

    /**
     * @notice Set fee trackers in case of math issue. Best to pause vault before using.
     * @dev Only callable by the contract owner.
     */
    function setTrackerValues(
        uint256 newCharityFeeTracker,
        uint256 newAdminFeeTracker,
        uint256 newPlatformFeeTracker,
        uint256 newBurnFeeTracker,
        uint256 newCharityFeeTracker2nd,
        uint256 newAdminFeeTracker2nd,
        uint256 newPlatformFeeTracker2nd,
        uint256 newEntryExitFeeBucket
    ) external whenPaused onlyOwner {
        // staking token trackers
        charityFeeTracker = newCharityFeeTracker;
        adminFeeTracker = newAdminFeeTracker;
        platformFeeTracker = newPlatformFeeTracker;
        burnFeeTracker = newBurnFeeTracker;

        //2nd token trackers
        charityFeeTrackerSecondToken = newCharityFeeTracker2nd;
        adminFeeTrackerSecondToken = newAdminFeeTracker2nd;
        platformFeeTrackerSecondToken = newPlatformFeeTracker2nd;

        // entry/exit fee bucker - staking token
        newEntryExitFeeBucket = newEntryExitFeeBucket;
    }

    /**
     * @notice Set r and t vault variables in case of math issue. Best to pause vault before using.
     * @dev Only callable by the contract owner.
     */
    function setDistributedValues(uint256 newTTotalMain1, uint256 newRTotalMain1)
        external
        whenPaused
        onlyOwner
    {
        _tTotalMain1 = newTTotalMain1;
        _rTotalMain1 = newRTotalMain1;
    }

    /**
     * @notice Change DEX router in case PCS updates. Best to pause vault before using.
     * @dev Only callable by the contract owner.
     */
    function setDEXRouter(IUniswapV2Router02 newDexAddress) external onlyOwner {
        uniswapV2Router = newDexAddress;
    }

    /**
     * @notice Set fee trackers in case of math issue. Best to pause vault before using.
     * @dev Only callable by the contract owner.
     */
    function setUserValues(
        address _userAddress,
        bool newExists,
        uint256 newIndex,
        uint256 newLockTime,
        uint256 newBondingLockTime,
        uint256 newLastLockedDepositTime,
        uint256 newlastBondingTime,
        uint256 newrOwnedStaked,
        uint256 newrOwnedBonded,
        uint256 newtotalSecondToken,
        uint256 newlastHoldingAmount,
        uint256 newlastBondingAmount
    ) external whenPaused onlyOwner {
        UserInfo storage user = userInfo[_userAddress];
        user.exists = newExists; //Does address exist in array
        user.index = newIndex; //index of address in array

        user.lockTime = newLockTime; // Lock duration in seconds
        user.bondingLockTime = newBondingLockTime; // Lock duration of bonding tokens in seconds

        user.lastLockedDepositTime = newLastLockedDepositTime; // last time the user deposited into locked pool
        user.lastBondingTime = newlastBondingTime; // last time the user deposited into locked pool

        user.rOwnedStaked = newrOwnedStaked; // Staked tokens in R value
        user.rOwnedBonded = newrOwnedBonded; // Bonded tokens in R value
        user.totalSecondToken = newtotalSecondToken; // Second tokens owned by the user

        user.lastHoldingAmount = newlastHoldingAmount; // Amount of tokens user owned at last withdraw or deposit, used to calculate rewards since last interaction
        user.lastBondingAmount = newlastBondingAmount; // Amount of tokens bonded by user at last interaction.
    }

    /*============================================
    /   DEX Swapping Functions
    /=============================================*/

    /**
     * @notice Swaps tokens on the contract for BNB using Pancakeswap. Unused in the ALTRU vault
     */
    /*	
    function swapTokensForBNB(uint256 tokenAmount, IERC20 tokenSwapping) private {	
        // Generate the uniswap pair path of token -> WETH	
        address[] memory path = new address[](2);	
        path[0] = address(tokenSwapping);	
        path[1] = uniswapV2Router.WETH();	
        tokenSwapping.approve(address(uniswapV2Router), tokenAmount);	
        // Make the swap	
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(	
            tokenAmount,	
            0, // Accept any amount of ETH	
            path,	
            address(this), // The contract	
            block.timestamp	
        );	
        	
        emit SwapTokensForETH(tokenAmount, path);	
    }*/
    /**
     * @notice Converts staking tokens to a new token type using Pancakeswap
     */
    function swapStakingTokensForSecondTokens(
        uint256 amount,
        IERC20 firstToken,
        IERC20 tokenSwapping
    ) private {
        // Generate the pancakeswap pair path of token -> WETH -> new token
        address[] memory path = new address[](3);
        path[0] = address(firstToken);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(tokenSwapping);
        firstToken.approve(address(uniswapV2Router), amount);
        // Make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // Accept any amount of Tokens
            path,
            address(this), // Vault address
            block.timestamp.add(300)
        );

        emit SwapBNBForTokens(amount, path); //todo replace emit and event
    }

    /**
     * @notice Funciton to exchange BNB for staking tokens
     */
    /*function swapBNBForTokens(uint256 amount) private {	
        // Generate the pancakeswap pair path of token -> WETH	
        address[] memory path = new address[](2);	
        path[0] = uniswapV2Router.WETH();	
        path[1] = address(secondToken);	
      // Make the swap	
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(	
            0, // Accept any amount of Tokens	
            path,	
            address(this), // Vault address	
            block.timestamp.add(300)	
        );	
        	
        emit SwapBNBForTokens(amount, path);	
    }*/

    receive() external payable {}

    fallback() external payable {}
}

contract StakingFactoryV5 {
    address public routerAddress;
    address public admin;
    mapping(address => address) private stakings;
    address[] private _vaults;

    function getStaking(address stakingToken) external view returns (address) {
        return stakings[stakingToken];
    }

    function getAllVaults() external view returns (address[] memory) {
        return _vaults;
    }

    function changeAdmin(address newAdmin) external {
        require(msg.sender == admin);
        admin = newAdmin;
    }

    constructor(address admin_) {
        admin = admin_;
    }

    function createStaking(
        address _treasury,
        address _adminWallet,
        IERC20 _stakingToken,
        uint256 _sTokenDecimal,
        IERC20 _secondToken,
        VotingToken _votingToken
    ) external {
        StakingVaultV5_0_0 s = new StakingVaultV5_0_0(
            admin,
            _treasury,
            _adminWallet,
            _stakingToken,
            _sTokenDecimal,
            _secondToken,
            _votingToken
        );
        s.transferOwnership(msg.sender);
        _vaults.push(address(s));
        stakings[address(_stakingToken)] = address(s);
    }
}

pragma solidity >=0.8.0;
//SPDX-License-Identifier: UNLICENSED
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract VotingToken is Ownable, ERC20('BANKER Gov Token', 'BD GOV') {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }

    function transfer(address to, uint256 _amount)
        public
        override
        onlyOwner
        returns (bool)
    {
        _transfer(_msgSender(), to, _amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 _amount
    ) public override onlyOwner returns (bool) {
        _transfer(from, to, _amount);
        return true;
    }
}