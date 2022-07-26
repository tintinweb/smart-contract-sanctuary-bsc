/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
}

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol";
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
        //slither-disable-next-line low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            //slither-disable-next-line assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

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
    //slither-disable-next-line naming-convention
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

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

// "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
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

    constructor() {
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Pausable.sol";
contract Pausable is Context {
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool) {
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
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
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

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view virtual override returns (string memory) {
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
    function decimals() external view virtual override returns (uint8) {
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
        external
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
        external
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
        external
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
    ) external virtual override returns (bool) {
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
        external
        virtual
        returns (bool)
    {
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        //slither-disable-next-line reentrancy-benign
        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            //slither-disable-next-line reentrancy-benign
            _balances[account] += amount;
        }
        //slither-disable-next-line reentrancy-events
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

interface IXswapFarm {
    function poolLength() external view returns (uint256);

    function userInfo() external view returns (uint256);

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    // Deposit LP tokens to the farm for farm's token allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external;
}

interface IXRouter01 {
    function factory() external pure returns (address);

    //slither-disable-next-line naming-convention
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        //slither-disable-next-line similar-names
        uint256 amountADesired,
        //slither-disable-next-line similar-names
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

interface IXRouter02 is IXRouter01 {
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

contract STRATPCS is ERC20, Ownable, ReentrancyGuard, Pausable {
    // Maximises yields in e.g. pancakeswap

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public constant IS_SINGLE_VAULT = false;
    bool public constant IS_AUTO_COMP = true;
    //slither-disable-next-line naming-convention
    address public FARM_CONTRACT_ADDRESS; // address of farm, eg, PCS, Thugs etc.
    uint256 public pid; // pid of pool in FARM_CONTRACT_ADDRESS
    address public wantAddress;
    //slither-disable-next-line similar-names
    address public token0Address;
    //slither-disable-next-line similar-names
    address public token1Address;
    address public earnedAddress;
    address public constant UNI_ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswap, pancakeswap etc
    address public buybackRouterAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswap, pancakeswap etc
    uint256 public constant ROUTER_DEADLINE_DURATION = 300; // Set on global level, could be passed to functions via arguments

    address public constant WBNB_ADDRESS =
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // should be WBNB or BUSD
    address public nativeFarmAddress;
    address public retroAddress;
    address public govAddress = 0x1F40C69eDfF22BFb99441641922778184dD07e69; // timelock contract

    uint256 public lastEarnBlock = 0;
    uint256 public wantLockedTotal = 0;
    uint256 public sharesTotal = 0;

    uint256 public buybackFee = 50;
    uint256 public controllerFee = 30;
    uint256 public compoundFee = 20;

    uint256 public constant FEE_MAX = 100;

    uint256 public constant PERCENT_DIVIDER = 1000;

    /* This is vanity address -  For instance an address 0x000000000000000000000000000000000000dEaD for which it's
       absolutely impossible to generate a private key with today's computers. */
    //slither-disable-next-line too-many-digits
    address public constant BUY_BACK_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    address[] public earnedToNATIVEPath;
    //slither-disable-next-line similar-names
    address[] public earnedToToken0Path;
    //slither-disable-next-line similar-names
    address[] public earnedToToken1Path;
    //slither-disable-next-line similar-names
    address[] public token0ToEarnedPath;
    //slither-disable-next-line similar-names
    address[] public token1ToEarnedPath;
    address[] public earnedToWantPath;
    address[] public earnedToWBNBPath;
    address[] public wbnbToNativePath;

    event ChangeGov(address indexed oldGov, address indexed newGov);
    event UpdateBuybackFee(uint256 indexed oldFee, uint256 indexed newFee);
    event UpdateControllerFee(uint256 indexed oldFee, uint256 indexed newFee);
    event UpdateCompoundFee(uint256 indexed oldFee, uint256 indexed newFee);
    event Deposit(
        address indexed user,
        uint256 indexed newTotal,
        uint256 amount
    );
    event Withdraw(
        address indexed user,
        uint256 indexed newTotal,
        uint256 amount
    );
    event Compound(address indexed user, uint256 indexed newTotal);

    constructor(
        address _nativeFarmAddress,
        address _retroAddress,
        uint256 _pid,
        address _wantAddress,
        //slither-disable-next-line similar-names
        address _token0Address,
        //slither-disable-next-line similar-names
        address _token1Address,
        string memory _Name,
        string memory _Symbol
    ) ERC20(_Name, _Symbol) {
        require(msg.sender != address(0), "Only contract owner can initialize");
        require(
            _nativeFarmAddress != address(0),
            "Native farm address is not set"
        );
        require(_retroAddress != address(0));
        require(_wantAddress != address(0));
        require(_token0Address != address(0));
        require(_token1Address != address(0));
        nativeFarmAddress = _nativeFarmAddress;
        retroAddress = _retroAddress;

        wantAddress = _wantAddress;

        if (IS_AUTO_COMP) {
            if (!IS_SINGLE_VAULT) {
                token0Address = _token0Address;
                token1Address = _token1Address;
            }

            FARM_CONTRACT_ADDRESS = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
            pid = _pid;
            earnedAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

            earnedToNATIVEPath = [earnedAddress, WBNB_ADDRESS, retroAddress];
            if (WBNB_ADDRESS == earnedAddress) {
                earnedToNATIVEPath = [WBNB_ADDRESS, retroAddress];
            }

            earnedToToken0Path = [earnedAddress, WBNB_ADDRESS, token0Address];
            if (WBNB_ADDRESS == token0Address) {
                earnedToToken0Path = [earnedAddress, WBNB_ADDRESS];
            }

            earnedToToken1Path = [earnedAddress, WBNB_ADDRESS, token1Address];
            if (WBNB_ADDRESS == token1Address) {
                earnedToToken1Path = [earnedAddress, WBNB_ADDRESS];
            }

            token0ToEarnedPath = [token0Address, WBNB_ADDRESS, earnedAddress];
            if (WBNB_ADDRESS == token0Address) {
                token0ToEarnedPath = [WBNB_ADDRESS, earnedAddress];
            }

            token1ToEarnedPath = [token1Address, WBNB_ADDRESS, earnedAddress];
            if (WBNB_ADDRESS == token1Address) {
                token1ToEarnedPath = [WBNB_ADDRESS, earnedAddress];
            }

            earnedToWantPath = [earnedAddress, WBNB_ADDRESS, wantAddress];
            if (WBNB_ADDRESS == wantAddress) {
                earnedToWantPath = [earnedAddress, wantAddress];
            }

            earnedToWBNBPath = [earnedAddress, WBNB_ADDRESS];
            wbnbToNativePath = [WBNB_ADDRESS, retroAddress];
        }

        transferOwnership(nativeFarmAddress);
    }

    modifier onlyAllowGov() {
        require(msg.sender == govAddress, "Not authorised");
        _;
    }

    /**
     * @dev It calculates the total underlying value of {token} held by the system.
     * It takes into account the vault contract balance, the strategy contract balance
     *  and the balance deployed in other contracts as part of the strategy.
     */
    function balance() public view returns (uint256) {
        return
            IERC20(wantAddress).balanceOf(address(this)).add(wantLockedTotal);
    }

    /**
     * @dev Custom logic in here for how much the vault allows to be borrowed.
     * We return 100% of tokens for block.timestamp. Under certain conditions we might
     * want to keep some of the system funds at hand in the vault, instead
     * of putting them to work.
     */
    function available() public view returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

    /**
     * @dev Function for various UIs to display the current value of one of our yield tokens.
     * Returns an uint256 with 18 decimals of how much underlying asset one vault share represents.
     */
    function getPricePerFullShare() external view returns (uint256) {
        //slither-disable-next-line incorrect-equality
        return
            totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    // Receives new deposits from user
    function deposit(address userAddress, uint256 wantAmt)
        public
        onlyOwner
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        uint256 _pool = balance();

        emit Deposit(userAddress, wantLockedTotal, wantAmt);

        IERC20(wantAddress).safeTransferFrom(
            address(msg.sender),
            address(this),
            wantAmt
        );

        uint256 _after = balance();
        wantAmt = _after.sub(_pool); // Additional check for deflationary tokens

        uint256 shares = 0;
        //slither-disable-next-line incorrect-equality
        if (totalSupply() == 0) {
            shares = wantAmt;
        } else {
            shares = (wantAmt.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);

        //slither-disable-next-line reentrancy-benign
        sharesTotal = sharesTotal.add(shares);

        if (IS_AUTO_COMP) {
            _farm();
        } else {
            //slither-disable-next-line reentrancy-benign
            //slither-disable-next-line reentrancy-no-eth
            wantLockedTotal = wantLockedTotal.add(wantAmt);
        }
        return shares;
    }

    function farm() external nonReentrant {
        _farm();
    }

    function _farm() internal {
        require(IS_AUTO_COMP, "!IS_AUTO_COMP");
        // reinvest harvested amount
        uint256 wantAmt = available();
        //slither-disable-next-line reentrancy-benign
        //slither-disable-next-line reentrancy-eth
        wantLockedTotal = wantLockedTotal.add(wantAmt);
        IERC20(wantAddress).safeIncreaseAllowance(
            FARM_CONTRACT_ADDRESS,
            wantAmt
        );

        IXswapFarm(FARM_CONTRACT_ADDRESS).deposit(pid, wantAmt);
    }

    function withdraw(address userAddress, uint256 wrapAmt)
        public
        onlyOwner
        returns (uint256)
    {
        require(wrapAmt > 0, "_wantAmt <= 0");

        uint256 r = (balance().mul(wrapAmt)).div(totalSupply());
        _burn(msg.sender, wrapAmt);

        uint256 b = IERC20(wantAddress).balanceOf(address(this));
        if (b < r) {
            uint256 _withdraw = r.sub(b);

            emit Withdraw(userAddress, wantLockedTotal, wrapAmt);
            if (IS_AUTO_COMP) {
                IXswapFarm(FARM_CONTRACT_ADDRESS).withdraw(pid, _withdraw);
            }

            uint256 _after = IERC20(wantAddress).balanceOf(address(this));
            uint256 _diff = _after.sub(b);

            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }

        if (wrapAmt > sharesTotal) {
            wrapAmt = sharesTotal;
        }
        //slither-disable-next-line reentrancy-benign
        sharesTotal = sharesTotal.sub(wrapAmt);
        //slither-disable-next-line reentrancy-benign
        //slither-disable-next-line reentrancy-no-eth
        wantLockedTotal = wantLockedTotal.sub(r);
        IERC20(wantAddress).safeTransfer(nativeFarmAddress, r);

        return r;
    }

    // 1. Harvest farm tokens
    // 2. Converts farm tokens into want tokens
    // 3. Deposits want tokens

    function earn() external nonReentrant whenNotPaused {
        require(IS_AUTO_COMP, "!IS_AUTO_COMP");
        emit Compound(msg.sender, wantLockedTotal);
        // Harvest farm tokens
        IXswapFarm(FARM_CONTRACT_ADDRESS).withdraw(pid, 0);

        // Converts farm tokens into want tokens
        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));

        earnedAmt = buyBack(earnedAmt);
        earnedAmt = distributeFees(earnedAmt);

        if (IS_SINGLE_VAULT) {
            if (earnedAddress != wantAddress) {
                IERC20(earnedAddress).safeIncreaseAllowance(
                    UNI_ROUTER_ADDRESS,
                    earnedAmt
                );

                // Swap earned to want
                IXRouter02(UNI_ROUTER_ADDRESS)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        earnedAmt,
                        0,
                        earnedToWantPath,
                        address(this),
                        block.timestamp + ROUTER_DEADLINE_DURATION
                    );
            }
            //slither-disable-next-line reentrancy-benign
            lastEarnBlock = block.number;
            _farm();
            return;
        }

        IERC20(earnedAddress).safeIncreaseAllowance(
            UNI_ROUTER_ADDRESS,
            earnedAmt
        );

        if (earnedAddress != token0Address) {
            // Swap half earned to token0
            IXRouter02(UNI_ROUTER_ADDRESS)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    earnedAmt.div(2),
                    0,
                    earnedToToken0Path,
                    address(this),
                    block.timestamp + ROUTER_DEADLINE_DURATION
                );
        }

        if (earnedAddress != token1Address) {
            // Swap half earned to token1
            IXRouter02(UNI_ROUTER_ADDRESS)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    earnedAmt.div(2),
                    0,
                    earnedToToken1Path,
                    address(this),
                    block.timestamp + ROUTER_DEADLINE_DURATION
                );
        }

        // Get want tokens, ie. add liquidity
        uint256 token0Amt = IERC20(token0Address).balanceOf(address(this));
        uint256 token1Amt = IERC20(token1Address).balanceOf(address(this));
        if (token0Amt > 0 && token1Amt > 0) {
            IERC20(token0Address).safeIncreaseAllowance(
                UNI_ROUTER_ADDRESS,
                token0Amt
            );
            IERC20(token1Address).safeIncreaseAllowance(
                UNI_ROUTER_ADDRESS,
                token1Amt
            );
            //slither-disable-next-line unused-state
            //solhint-disable-next-line no-unused-vars
            (uint256 amountA, uint256 amountB, uint256 liquidity) = IXRouter02(
                UNI_ROUTER_ADDRESS
            ).addLiquidity(
                    token0Address,
                    token1Address,
                    token0Amt,
                    token1Amt,
                    0,
                    0,
                    address(this),
                    block.timestamp + ROUTER_DEADLINE_DURATION
                );
        }

        //slither-disable-next-line reentrancy-benign
        lastEarnBlock = block.number;

        _farm();
    }

    function buyBack(uint256 earnedAmt) internal returns (uint256) {
        if (buybackFee <= 0) {
            return earnedAmt;
        }

        uint256 buyBackAmt = earnedAmt.mul(buybackFee).div(PERCENT_DIVIDER);

        if (UNI_ROUTER_ADDRESS != buybackRouterAddress) {
            // Example case: LP token on ApeSwap and NATIVE token on PancakeSwap

            if (earnedAddress != WBNB_ADDRESS) {
                // First convert earn to wbnb
                IERC20(earnedAddress).safeIncreaseAllowance(
                    UNI_ROUTER_ADDRESS,
                    buyBackAmt
                );

                IXRouter02(UNI_ROUTER_ADDRESS)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        buyBackAmt,
                        0,
                        earnedToWBNBPath,
                        address(this),
                        block.timestamp + ROUTER_DEADLINE_DURATION
                    );
            }

            // convert all wbnb to Native and burn them
            uint256 wbnbAmt = IERC20(WBNB_ADDRESS).balanceOf(address(this));
            if (wbnbAmt > 0) {
                IERC20(WBNB_ADDRESS).safeIncreaseAllowance(
                    buybackRouterAddress,
                    wbnbAmt
                );

                IXRouter02(buybackRouterAddress)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        wbnbAmt,
                        0,
                        wbnbToNativePath,
                        BUY_BACK_ADDRESS,
                        block.timestamp + ROUTER_DEADLINE_DURATION
                    );
            }
        } else {
            // Both LP and NATIVE token on same swap

            IERC20(earnedAddress).safeIncreaseAllowance(
                UNI_ROUTER_ADDRESS,
                buyBackAmt
            );

            IXRouter02(UNI_ROUTER_ADDRESS)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    buyBackAmt,
                    0,
                    earnedToNATIVEPath,
                    BUY_BACK_ADDRESS,
                    block.timestamp + ROUTER_DEADLINE_DURATION
                );
        }

        return earnedAmt.sub(buyBackAmt);
    }

    function distributeFees(uint256 earnedAmt) internal returns (uint256) {
        if (earnedAmt > 0) {
            // Performance fee
            uint256 ctrlfee = 0;
            uint256 compfee = 0;

            if (controllerFee > 0) {
                ctrlfee = earnedAmt.mul(controllerFee).div(PERCENT_DIVIDER);
                earnedAmt = earnedAmt.sub(ctrlfee);
            }

            if (compoundFee > 0) {
                compfee = earnedAmt.mul(compoundFee).div(PERCENT_DIVIDER);
                earnedAmt = earnedAmt.sub(compfee);
            }

            if (ctrlfee > 0) {
                IERC20(earnedAddress).safeTransfer(govAddress, ctrlfee);
            }

            if (compfee > 0) {
                IERC20(earnedAddress).safeTransfer(msg.sender, compfee);
            }
        }

        return earnedAmt;
    }

    function convertDustToEarned() external whenNotPaused {
        require(IS_AUTO_COMP, "!IS_AUTO_COMP");
        require(!IS_SINGLE_VAULT, "IS_SINGLE_VAULT");

        // Converts dust tokens into earned tokens, which will be reinvested on the next earn().

        // Converts token0 dust (if any) to earned tokens
        uint256 token0Amt = IERC20(token0Address).balanceOf(address(this));
        if (token0Address != earnedAddress && token0Amt > 0) {
            IERC20(token0Address).safeIncreaseAllowance(
                UNI_ROUTER_ADDRESS,
                token0Amt
            );

            // Swap all dust tokens to earned tokens
            IXRouter02(UNI_ROUTER_ADDRESS)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    token0Amt,
                    0,
                    token0ToEarnedPath,
                    address(this),
                    block.timestamp + ROUTER_DEADLINE_DURATION
                );
        }

        // Converts token1 dust (if any) to earned tokens
        uint256 token1Amt = IERC20(token1Address).balanceOf(address(this));
        if (token1Address != earnedAddress && token1Amt > 0) {
            IERC20(token1Address).safeIncreaseAllowance(
                UNI_ROUTER_ADDRESS,
                token1Amt
            );

            // Swap all dust tokens to earned tokens
            IXRouter02(UNI_ROUTER_ADDRESS)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    token1Amt,
                    0,
                    token1ToEarnedPath,
                    address(this),
                    block.timestamp + ROUTER_DEADLINE_DURATION
                );
        }
    }

    function pause() external onlyAllowGov {
        _pause();
    }

    function unpause() external onlyAllowGov {
        _unpause();
    }

    function setControllerFee(uint256 newControllerFee) external onlyAllowGov {
        require(
            newControllerFee.add(buybackFee).add(compoundFee) <= FEE_MAX,
            "too high"
        );
        emit UpdateControllerFee(controllerFee, newControllerFee);
        controllerFee = newControllerFee;
    }

    function setbuyBackRate(uint256 newBuyBackFee) external onlyAllowGov {
        require(
            newBuyBackFee.add(controllerFee).add(compoundFee) <= FEE_MAX,
            "too high"
        );
        emit UpdateBuybackFee(buybackFee, newBuyBackFee);
        buybackFee = newBuyBackFee;
    }

    function setCompoundFee(uint256 newCompoundFee) external onlyAllowGov {
        require(
            newCompoundFee.add(buybackFee).add(controllerFee) <= FEE_MAX,
            "too high"
        );
        emit UpdateCompoundFee(compoundFee, newCompoundFee);
        compoundFee = newCompoundFee;
    }

    function setGov(address newgovAddress) external onlyAllowGov {
        require(newgovAddress != address(0), "govAddress cannot be 0");
        emit ChangeGov(govAddress, newgovAddress);
        govAddress = newgovAddress;
    }

    function setBuybackRouterAddress(address newbuybackRouterAddress)
        external
        onlyAllowGov
    {
        require(
            newbuybackRouterAddress != address(0),
            "buybackRouterAddress cannot be 0"
        );
        buybackRouterAddress = newbuybackRouterAddress;
    }

    function changeRetroAddress(address newRetroAddress) external onlyAllowGov {
        require(newRetroAddress != address(0), "retroAddress cannot be 0");
        require(newRetroAddress != retroAddress, "retroAddress cannot be same");
        retroAddress = newRetroAddress;

        earnedToNATIVEPath = [earnedAddress, WBNB_ADDRESS, newRetroAddress];
        if (WBNB_ADDRESS == earnedAddress) {
            earnedToNATIVEPath = [WBNB_ADDRESS, newRetroAddress];
        }
        wbnbToNativePath = [WBNB_ADDRESS, newRetroAddress];
    }

    function workerCompound() external view returns (uint256) {
        uint256 BalanceTokens = IERC20(earnedAddress).balanceOf(address(this));
        uint256 Comp = IXswapFarm(FARM_CONTRACT_ADDRESS).pendingCake(
            pid,
            address(this)
        );
        uint256 ToComp = BalanceTokens.add(Comp);
        uint256 buyBackAmt = ToComp.mul(buybackFee).div(PERCENT_DIVIDER);
        ToComp = ToComp.sub(buyBackAmt);
        uint256 fee = ToComp.mul(compoundFee).div(PERCENT_DIVIDER);

        return fee;
    }

    function inCaseTokensGetStuck(
        address token,
        uint256 amount,
        address to
    ) external onlyAllowGov {
        require(token != earnedAddress, "!safe");
        require(token != wantAddress, "!safe");
        IERC20(token).safeTransfer(to, amount);
    }
}