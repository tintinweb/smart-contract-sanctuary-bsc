/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// Sources flattened with hardhat v2.0.8 https://hardhat.org

// File openzeppelin-solidity/contracts/utils/[email protected]

pragma solidity ^0.5.0;

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
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}


// File openzeppelin-solidity/contracts/token/ERC20/[email protected]

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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


// File openzeppelin-solidity/contracts/GSN/[email protected]

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File openzeppelin-solidity/contracts/math/[email protected]

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File openzeppelin-solidity/contracts/token/ERC20/[email protected]

pragma solidity ^0.5.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
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
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


// File openzeppelin-solidity/contracts/token/ERC20/[email protected]

pragma solidity ^0.5.0;

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


// File openzeppelin-solidity/contracts/utils/[email protected]

pragma solidity ^0.5.5;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


// File openzeppelin-solidity/contracts/token/ERC20/[email protected]

pragma solidity ^0.5.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File erc721o/contracts/Interfaces/[email protected]

pragma solidity ^0.5.4;

/**
 * @title ERC721O token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721O contracts.
 */
contract IERC721OReceiver {
  /**
    * @dev Magic value to be returned upon successful reception of an amount of ERC721O tokens
    *  ERC721O_RECEIVED = `bytes4(keccak256("onERC721OReceived(address,address,uint256,uint256,bytes)"))` = 0xf891ffe0
    *  ERC721O_BATCH_RECEIVED = `bytes4(keccak256("onERC721OBatchReceived(address,address,uint256[],uint256[],bytes)"))` = 0xd0e17c0b
    */
  bytes4 constant internal ERC721O_RECEIVED = 0xf891ffe0;
  bytes4 constant internal ERC721O_BATCH_RECEIVED = 0xd0e17c0b;

  function onERC721OReceived(
    address _operator,
    address _from,
    uint256 tokenId,
    uint256 amount,
    bytes memory data
  ) public returns(bytes4);

  function onERC721OBatchReceived(
    address _operator,
    address _from,
    uint256[] memory _types,
    uint256[] memory _amounts,
    bytes memory _data
  ) public returns (bytes4);
}


// File opium-contracts/contracts/Lib/[email protected]

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

/// @title Opium.Lib.LibDerivative contract should be inherited by contracts that use Derivative structure and calculate derivativeHash
contract LibDerivative {
    // Opium derivative structure (ticker) definition
    struct Derivative {
        // Margin parameter for syntheticId
        uint256 margin;
        // Maturity of derivative
        uint256 endTime;
        // Additional parameters for syntheticId
        uint256[] params;
        // oracleId of derivative
        address oracleId;
        // Margin token address of derivative
        address token;
        // syntheticId of derivative
        address syntheticId;
    }

    /// @notice Calculates hash of provided Derivative
    /// @param _derivative Derivative Instance of derivative to hash
    /// @return derivativeHash bytes32 Derivative hash
    function getDerivativeHash(Derivative memory _derivative) public pure returns (bytes32 derivativeHash) {
        derivativeHash = keccak256(abi.encodePacked(
            _derivative.margin,
            _derivative.endTime,
            _derivative.params,
            _derivative.oracleId,
            _derivative.token,
            _derivative.syntheticId
        ));
    }
}


// File opium-contracts/contracts/Interface/[email protected]

pragma solidity 0.5.16;

/// @title Opium.Interface.IDerivativeLogic contract is an interface that every syntheticId should implement
contract IDerivativeLogic is LibDerivative {
    /// @notice Validates ticker
    /// @param _derivative Derivative Instance of derivative to validate
    /// @return Returns boolean whether ticker is valid
    function validateInput(Derivative memory _derivative) public view returns (bool);

    /// @notice Calculates margin required for derivative creation
    /// @param _derivative Derivative Instance of derivative
    /// @return buyerMargin uint256 Margin needed from buyer (LONG position)
    /// @return sellerMargin uint256 Margin needed from seller (SHORT position)
    function getMargin(Derivative memory _derivative) public view returns (uint256 buyerMargin, uint256 sellerMargin);

    /// @notice Calculates payout for derivative execution
    /// @param _derivative Derivative Instance of derivative
    /// @param _result uint256 Data retrieved from oracleId on the maturity
    /// @return buyerPayout uint256 Payout in ratio for buyer (LONG position holder)
    /// @return sellerPayout uint256 Payout in ratio for seller (SHORT position holder)
    function getExecutionPayout(Derivative memory _derivative, uint256 _result)	public view returns (uint256 buyerPayout, uint256 sellerPayout);

    /// @notice Returns syntheticId author address for Opium commissions
    /// @return authorAddress address The address of syntheticId address
    function getAuthorAddress() public view returns (address authorAddress);

    /// @notice Returns syntheticId author commission in base of COMMISSION_BASE
    /// @return commission uint256 Author commission
    function getAuthorCommission() public view returns (uint256 commission);

    /// @notice Returns whether thirdparty could execute on derivative's owner's behalf
    /// @param _derivativeOwner address Derivative owner address
    /// @return Returns boolean whether _derivativeOwner allowed third party execution
    function thirdpartyExecutionAllowed(address _derivativeOwner) public view returns (bool);

    /// @notice Returns whether syntheticId implements pool logic
    /// @return Returns whether syntheticId implements pool logic
    function isPool() public view returns (bool);

    /// @notice Sets whether thirds parties are allowed or not to execute derivative's on msg.sender's behalf
    /// @param _allow bool Flag for execution allowance
    function allowThirdpartyExecution(bool _allow) public;

    // Event with syntheticId metadata JSON string (for DIB.ONE derivative explorer)
    event MetadataSet(string metadata);
}


// File opium-contracts/contracts/Errors/[email protected]

pragma solidity 0.5.16;

contract RegistryErrors {
    string constant internal ERROR_REGISTRY_ONLY_INITIALIZER = "REGISTRY:ONLY_INITIALIZER";
    string constant internal ERROR_REGISTRY_ONLY_OPIUM_ADDRESS_ALLOWED = "REGISTRY:ONLY_OPIUM_ADDRESS_ALLOWED";
    
    string constant internal ERROR_REGISTRY_CANT_BE_ZERO_ADDRESS = "REGISTRY:CANT_BE_ZERO_ADDRESS";

    string constant internal ERROR_REGISTRY_ALREADY_SET = "REGISTRY:ALREADY_SET";
}


// File opium-contracts/contracts/[email protected]

pragma solidity 0.5.16;

/// @title Opium.Registry contract keeps addresses of deployed Opium contracts set to allow them route and communicate to each other
contract Registry is RegistryErrors {

    // Address of Opium.TokenMinter contract
    address private minter;

    // Address of Opium.Core contract
    address private core;

    // Address of Opium.OracleAggregator contract
    address private oracleAggregator;

    // Address of Opium.SyntheticAggregator contract
    address private syntheticAggregator;

    // Address of Opium.TokenSpender contract
    address private tokenSpender;

    // Address of Opium commission receiver
    address private opiumAddress;

    // Address of Opium contract set deployer
    address public initializer;

    /// @notice This modifier restricts access to functions, which could be called only by initializer
    modifier onlyInitializer() {
        require(msg.sender == initializer, ERROR_REGISTRY_ONLY_INITIALIZER);
        _;
    }

    /// @notice Sets initializer
    constructor() public {
        initializer = msg.sender;
    }

    // SETTERS

    /// @notice Sets Opium.TokenMinter, Opium.Core, Opium.OracleAggregator, Opium.SyntheticAggregator, Opium.TokenSpender, Opium commission receiver addresses and allows to do it only once
    /// @param _minter address Address of Opium.TokenMinter
    /// @param _core address Address of Opium.Core
    /// @param _oracleAggregator address Address of Opium.OracleAggregator
    /// @param _syntheticAggregator address Address of Opium.SyntheticAggregator
    /// @param _tokenSpender address Address of Opium.TokenSpender
    /// @param _opiumAddress address Address of Opium commission receiver
    function init(
        address _minter,
        address _core,
        address _oracleAggregator,
        address _syntheticAggregator,
        address _tokenSpender,
        address _opiumAddress
    ) external onlyInitializer {
        require(
            minter == address(0) &&
            core == address(0) &&
            oracleAggregator == address(0) &&
            syntheticAggregator == address(0) &&
            tokenSpender == address(0) &&
            opiumAddress == address(0),
            ERROR_REGISTRY_ALREADY_SET
        );

        require(
            _minter != address(0) &&
            _core != address(0) &&
            _oracleAggregator != address(0) &&
            _syntheticAggregator != address(0) &&
            _tokenSpender != address(0) &&
            _opiumAddress != address(0),
            ERROR_REGISTRY_CANT_BE_ZERO_ADDRESS
        );

        minter = _minter;
        core = _core;
        oracleAggregator = _oracleAggregator;
        syntheticAggregator = _syntheticAggregator;
        tokenSpender = _tokenSpender;
        opiumAddress = _opiumAddress;
    }

    /// @notice Allows opium commission receiver address to change itself
    /// @param _opiumAddress address New opium commission receiver address
    function changeOpiumAddress(address _opiumAddress) external {
        require(opiumAddress == msg.sender, ERROR_REGISTRY_ONLY_OPIUM_ADDRESS_ALLOWED);
        require(_opiumAddress != address(0), ERROR_REGISTRY_CANT_BE_ZERO_ADDRESS);
        opiumAddress = _opiumAddress;
    }

    // GETTERS

    /// @notice Returns address of Opium.TokenMinter
    /// @param result address Address of Opium.TokenMinter
    function getMinter() external view returns (address result) {
        return minter;
    }

    /// @notice Returns address of Opium.Core
    /// @param result address Address of Opium.Core
    function getCore() external view returns (address result) {
        return core;
    }

    /// @notice Returns address of Opium.OracleAggregator
    /// @param result address Address of Opium.OracleAggregator
    function getOracleAggregator() external view returns (address result) {
        return oracleAggregator;
    }

    /// @notice Returns address of Opium.SyntheticAggregator
    /// @param result address Address of Opium.SyntheticAggregator
    function getSyntheticAggregator() external view returns (address result) {
        return syntheticAggregator;
    }

    /// @notice Returns address of Opium.TokenSpender
    /// @param result address Address of Opium.TokenSpender
    function getTokenSpender() external view returns (address result) {
        return tokenSpender;
    }

    /// @notice Returns address of Opium commission receiver
    /// @param result address Address of Opium commission receiver
    function getOpiumAddress() external view returns (address result) {
        return opiumAddress;
    }
}


// File contracts/Staking/OpiumStakingErrors.sol

pragma solidity 0.5.16;

contract OpiumStakingErrors {
    string internal constant NOT_INITIALIZED = "NOT_INITIALIZED";
    string internal constant TRADING_PHASE_NOT_ENDED = "TRADING_PHASE_NOT_ENDED";
    string internal constant NOT_STAKING_PHASE = "NOT_STAKING_PHASE";
    string internal constant NOT_TRADING_PHASE = "NOT_TRADING_PHASE";
    string internal constant NOT_STAKING_OR_TRADING_PHASE = "NOT_STAKING_OR_TRADING_PHASE";
    string internal constant NOT_EXECUTED = "NOT_EXECUTED";

    string internal constant ERROR_WRONG_TOKEN_ID = "ERROR_WRONG_TOKEN_ID";

    string internal constant WRONG_AMOUNT = "WRONG_AMOUNT";
    string internal constant BALANCE_GREATER_THAN_WITHDRAW_AMOUNT = "BALANCE MUST BE >= _AMOUNT";

    string internal constant EPOCH_LENGTH_IS_WRONG = "EPOCH_LENGTH_IS_WRONG";

    string internal constant INVALID_DERIVATIVE = "INVALID_DERIVATIVE";

    string internal constant HARDCAP_REACHED = "HARDCAP_REACHED";
    string internal constant LP_HARDCAP_REACHED = "LP_HARDCAP_REACHED";

    string internal constant NOT_OPIUM_ADDRESS = "NOT_OPIUM_ADDRESS";
    string internal constant NOT_ADVISOR_ADDRESS = "NOT_ADVISOR_ADDRESS";
    string internal constant NOT_OPIUM_OR_ADVISOR_ADDRESS = "NOT_OPIUM_OR_ADVISOR_ADDRESS";

    string internal constant NOT_ENOUGH_LIQUIDITY = "NOT_ENOUGH_LIQUIDITY";
    string internal constant PREMIUM_TOO_LOW = "PREMIUM_TOO_LOW";
    string internal constant PREMIUM_WRONG = "PREMIUM_WRONG";

    string internal constant NOT_EMERGENCY = "NOT_EMERGENCY";

    string internal constant WITHDRAWAL_NOT_ALLOWED = "WITHDRAWAL_NOT_ALLOWED";
    
    string internal constant INVALID_VALUE = "INVALID_VALUE";
}


// File contracts/StakingPricedOptionsCall/OpiumStakingPricedOptionsCallDerivatives.sol

pragma solidity 0.5.16;






// Opium




interface ITokenMinter {
    function approve(address spender, uint256 tokenId) external;
    function balanceOf(address user, uint256 tokenId) external returns (uint256);
}

interface ICore {
    function execute(uint256 _tokenId, uint256 _quantity, LibDerivative.Derivative calldata _derivative) external;
    function cancel(uint256 _tokenId, uint256 _quantity, LibDerivative.Derivative calldata _derivative) external;
    function create(LibDerivative.Derivative calldata _derivative, uint256 _quantity, address[2] calldata _addresses) external;
}

interface IFactoryOpiumERC20Position {
    function deploy(
        string calldata _name,
        string calldata _symbol,
        uint256 _tokenId,
        ITokenMinter _tokenMinter,
        ICore _core,
        IERC20 _underlying
    ) external returns (address);
}

interface IOpiumERC20Position {
    function mintForSomeone(uint256 _quantity, address _someone) external;
}

interface IOracleSubId {
    function getResult() external view returns (uint256);
}

interface IPricingModule {
    function getDynamicPremium(uint256 _nextMargin) external view returns (uint256);
}

/// @title OpiumStakingPricedOptionsCallDerivatives
/// @author Opium.Team
/// @notice Opium Staking's base contract that communicates with Opium for hedging and manages epoch's phases
contract OpiumStakingPricedOptionsCallDerivatives is ERC20, ERC20Detailed, OpiumStakingErrors, IERC721OReceiver, LibDerivative, ReentrancyGuard {
    // Libraries
    using SafeMath for uint256;
    using SafeERC20 for ERC20Detailed;

    // Events
    /// @notice Indicates deployment of new LONG position token wrapper
    /// @param longTokenId a tokenId of the LONG position
    /// @param wrapper an address of the deployed wrapper
    event LongPositionWrapper(uint256 longTokenId, address wrapper);
    /// @notice Indicates new hedge actin
    /// @param user an address of the hedger
    /// @param _quantity an amount of created positions
    event Hedge(address indexed user, uint256 _quantity);

    // Underlying ERC20 token a.k.a. derivative margin token
    ERC20Detailed public underlying;

    /** Length of the epoch when users are allowed to hedge */
    uint256 public TRADING_PHASE;
    /** Length of the epoch when users are allowed to deposit and withdraw */
    uint256 public STAKING_PHASE;
    /** Duration of the epoch */
    uint256 public EPOCH;

    // Amount of uninitialized epochs till emergency
    uint256 constant public EMERGENCY_EPOCHS = 1;

    // Current epoch's derivative
    LibDerivative.Derivative public derivative;
    // Current epoch's derivative's short token id
    uint256 public shortTokenId;

    // Long position wrapper factory contract
    IFactoryOpiumERC20Position public factoryLongPositionWrapper;
    // Current epoch's LONG positions wrapper instance
    IOpiumERC20Position public longPositionWrapper;

    /** Cached Opium contracts and addresses */
    // Opium.Registry - List with Opium Protocol Smart Contracts
    Registry public opiumRegistry;

    // Governance
    address public opiumAddress;
    address public advisorAddress;

    // Pricing module
    IPricingModule pricingModule;

    // Accumulated fees of Opium
    uint256 public accumulatedOpiumFees = 0;

    // Reference value representing 100% adjusted to 10^18
    uint256 constant public PERCENTAGE_BASE = 1e18;
    // Keeps the staking pool size value at the start of the trading phase during the whole trading phase to calculate pool's utilization
    uint256 public tradingPhasePoolSize = 0;
    // Keeps the staking total supply value at the start of the trading phase during the whole trading phase
    uint256 public tradingPhaseTotalSupply = 0;

    // 60 second buffer for phases to double check and prevent timestamp manipulations
    uint256 public constant TIME_DELTA = 60;

    // Options params
    uint256 public constant MIN_STRIKE_PRICE_DELTA = 0.125e18; // 12.5%
    uint256 public strikePriceDelta = 0.25e18; // 25%
    uint256 public strikePriceDeltaRound = 1e18; // 1
    uint256 public nextFixedPremium = 0; // 0

    // Modifier checking whether msg.sender is Opium governor
    modifier isOpiumAddress() {
        require(msg.sender == opiumAddress, NOT_OPIUM_ADDRESS);
        _;
    }
    // Modifier checking whether msg.sender is Advisor
    modifier isAdvisorAddress() {
        require(msg.sender == advisorAddress, NOT_ADVISOR_ADDRESS);
        _;
    }
    // Modifier checking whether msg.sender is Advisor
    modifier isOpiumOrAdvisorAddress() {
        require((msg.sender == opiumAddress) || (msg.sender == advisorAddress), NOT_OPIUM_OR_ADVISOR_ADDRESS);
        _;
    }

    /// @notice Constructor of the contract that initializes state variables
    /// @param _lengths an array of timestamps describing epoch and phases lengths
    /// @param _pricingModule a pricing module instance
    /// @param _underlying an instance of underlying token
    /// @param _opiumRegistry an instance of Opium Registry contract to fetch other Opium contracts addresses
    /// @param _derivative initial derivative parameters including the end of the first epoch specified by `derivative.endTime`
    /// @param _factoryLongPositionWrapper an instance of the factory for LONG positions token wrapper
    constructor(
        uint256[3] memory _lengths,
        IPricingModule _pricingModule,
        ERC20Detailed _underlying,
        Registry _opiumRegistry,
        LibDerivative.Derivative memory _derivative,
        IFactoryOpiumERC20Position _factoryLongPositionWrapper
    ) public {
        // Initialize epoch and phases length
        EPOCH = _lengths[0];
        STAKING_PHASE = _lengths[1];
        TRADING_PHASE = _lengths[2];

        // Validate epoch and phases lengths
        // STAKING_PHASE + TRADING_PHASE < EPOCH: epoch length should be longer than sum of staking and trading phase lengths
        // The rest is considered as an IDLE phase where neither staking nor trading is allowed
        require(STAKING_PHASE.add(TRADING_PHASE) < EPOCH, EPOCH_LENGTH_IS_WRONG);
        // STAKING_PHASE > TIME_DELTA * 2
        require(STAKING_PHASE > TIME_DELTA.mul(2), EPOCH_LENGTH_IS_WRONG);
        // TRADING_PHASE > TIME_DELTA * 2
        require(TRADING_PHASE > TIME_DELTA.mul(2), EPOCH_LENGTH_IS_WRONG);

        pricingModule = _pricingModule;

        underlying = _underlying;

        // Initialize Opium contracts references
        opiumRegistry = _opiumRegistry;
        opiumAddress = msg.sender;

        // Initialize first derivative params
        derivative = _derivative;

        // Initialize factory for LONG positions token wrapper 
        factoryLongPositionWrapper = _factoryLongPositionWrapper;
    }

    /**
     * Initializes new epoch:
     * - Executes currently held Opium SHORT positions
     * - Changes current derivative's maturity
     * - Calculates new Opium SHORT and LONG token IDs
     * - Deploys new LONG position token wrapper
     * - Approves deployed wrapper to spend LONG position tokens from this contract
     * - Resets `tradingPhasePoolSize` variable
     * - Resets `tradingPhaseTotalSupply` variable
     */
    /// @notice Initialize new epoch
    function initializeEpoch() external {
        // Checks if epoch 0 was already initialized
        if (shortTokenId != 0) {
            // Check if now > derivative maturity + TIME_DELTA
            require(
                now > derivative.endTime.add(TIME_DELTA),
                TRADING_PHASE_NOT_ENDED
            );

            // Execute remaining positions
            execute();

            /* Update derivative params */
            // Increase derivative.endTime by epoch length
            derivative.endTime = derivative.endTime.add(EPOCH);

            uint256 newStrikePrice = _calculateNewStrikePrice();
            // Set new strike price
            derivative.params[0] = newStrikePrice;
            // Set new fixed premium
            derivative.params[2] = nextFixedPremium;
        } else {
            // First epoch initialization
            // Set initial fixed premium as next fixed premium
            nextFixedPremium = derivative.params[2];
        }

        // Calculate derivative hash
        bytes32 derivativeHash = getDerivativeHash(derivative);
        // Calculate SHORT tokenId
        shortTokenId = getShortTokenId(derivativeHash);

        // Instance of OpiumTokenMinter
        ITokenMinter opiumPositionToken = ITokenMinter(opiumRegistry.getMinter());
        ICore opiumCore = ICore(opiumRegistry.getCore());
        
        // Calculate longTokenIds
        uint256 longTokenId = getLongTokenId(derivativeHash);
        // Deploy LONG position token wrapper
        longPositionWrapper = IOpiumERC20Position(
            factoryLongPositionWrapper.deploy(
                "Opium Long Position",
                "OPIUM_LONG",
                longTokenId,
                opiumPositionToken,
                opiumCore,
                IERC20(derivative.token)
            )
        );
        emit LongPositionWrapper(longTokenId, address(longPositionWrapper));

        // Approve deployed wrapper to spend LONG positions from this contract
        opiumPositionToken.approve(address(longPositionWrapper), longTokenId);

        // Reset trading phase pool size on each epoch
        tradingPhasePoolSize = 0;
        // Reset trading phase total supply on each epoch
        tradingPhaseTotalSupply = 0;
    }

    function _calculateNewStrikePrice() private view returns (uint256 newStrikePrice) {
        uint256 currentPrice = IOracleSubId(derivative.oracleId).getResult();
        newStrikePrice = currentPrice
            .mul(
                PERCENTAGE_BASE.add(strikePriceDelta)
            )
            .div(PERCENTAGE_BASE);

        if (newStrikePrice > strikePriceDeltaRound) {
            newStrikePrice = newStrikePrice.sub(
                newStrikePrice.mod(strikePriceDeltaRound)
            );
        }
    }

    /**
     * Execute all Opium SHORT positions held by pool:
     * - Checks if epoch 0 was already initialized
     * - Calculate amount of held SHORT positions of current epoch
     * - If the amount of positions is positive, executes them
     */
    function execute() public {
        // Check if epoch 0 was initialized
        require(shortTokenId != 0, NOT_INITIALIZED);

        // Instance of OpiumTokenMinter
        ITokenMinter opiumPositionToken = ITokenMinter(opiumRegistry.getMinter());
        ICore opiumCore = ICore(opiumRegistry.getCore());
        
        // Calculate amount of held SHORT positions of current epoch
        uint256 heldPositions = opiumPositionToken.balanceOf(address(this), shortTokenId);

        // If the amount of positions is positive, executes them
        if (heldPositions > 0) {
            opiumCore.execute(shortTokenId, heldPositions, derivative);
        }
    }

    /**
     * Cancel all Opium SHORT positions held by pool:
     * - Checks if epoch 0 was already initialized
     * - Calculate amount of held SHORT positions of current epoch
     * - If the amount of positions is positive, cancels them
     */
    function cancel() public {
        // Check if epoch 0 was initialized
        require(shortTokenId != 0, NOT_INITIALIZED);

        // Instance of OpiumTokenMinter
        ITokenMinter opiumPositionToken = ITokenMinter(opiumRegistry.getMinter());
        ICore opiumCore = ICore(opiumRegistry.getCore());
        
        // Calculate amount of held SHORT positions of current epoch
        uint256 heldPositions = opiumPositionToken.balanceOf(address(this), shortTokenId);

        // If the amount of positions is positive, cancels them
        if (heldPositions > 0) {
            opiumCore.cancel(shortTokenId, heldPositions, derivative);
        }
    }

    function isStakingPhase() public view returns (bool) {
        // Check if Pool is in the STAKING phase:
        // derivative maturity - EPOCH + TIME_DELTA < now < derivative maturity - EPOCH + STAKING_PHASE - TIME_DELTA
        return (derivative.endTime.sub(EPOCH).add(TIME_DELTA) < now) && (now < derivative.endTime.sub(EPOCH).add(STAKING_PHASE).sub(TIME_DELTA));
    }

    function isTradingPhase() public view returns (bool) {
        // Check if Pool is in the TRADING phase
        // derivative maturity - EPOCH + STAKING_PHASE + TIME_DELTA < now < derivative maturity - EPOCH + STAKING_PHASE + TRADING_PHASE - TIME_DELTA
        return (derivative.endTime.sub(EPOCH).add(STAKING_PHASE).add(TIME_DELTA) < now) && (now < derivative.endTime.sub(EPOCH).add(STAKING_PHASE).add(TRADING_PHASE).sub(TIME_DELTA));
    }

    /** 
     * Modifier checking if:
     * - Epoch 0 was initialized
     * - Pool is in the STAKING or TRADING phase
    */
    modifier canDeposit() {
        // Check if epoch 0 was initialized
        require(shortTokenId != 0, NOT_INITIALIZED);

        // Check if Pool is in the STAKING phase:
        require(isStakingPhase() || isTradingPhase(), NOT_STAKING_OR_TRADING_PHASE);
        _;
    }

    /** 
     * Modifier checking if:
     * - Epoch 0 was initialized
     * - Pool is in the STAKING phase
    */
    modifier canWithdraw() {
        // Check if epoch 0 was initialized
        require(shortTokenId != 0, NOT_INITIALIZED);

        // Check if Pool is in the STAKING phase:
        require(isStakingPhase(), NOT_STAKING_PHASE);
        _;
    }

    /** 
     * Modifier checking if:
     * - Epoch 0 was initialized
     * - Pool is in the TRADING phase
    */
    modifier canHedge() {
        // Check if epoch 0 was initialized
        require(shortTokenId != 0, NOT_INITIALIZED);

        // Check if Pool is in the TRADING phase
        require(isTradingPhase(), NOT_TRADING_PHASE);
        _;
    }

    /**
     * Creates derivative position with msg.sender as a LONG side counterparty
     * - Modifier checks whether TRADING phase is active
     * - Get positions availability
     * - Check that requested amount of positions is less than or equal to available positions
     * - Set trading pool size if was not set
     * - Calculate required premium
     * - Check that required premium is less than or equal to maximum allowed premium by user
     * - Calculate total premium
     * - Transfer total premium from user
     * - Calculate required margin for derivatives creation
     * - Approve Opium.TokenSpender to spend required margin
     * - Create derivatives and hold both LONG and SHORT positions
     * - Mint LONG position wrapper tokens to user by sending LONG position to the wrapper 
     */
    /// @notice Create LONG position
    /// @param _quantity an amount of positions to create
    /// @param _maxPremium a maximum premium user is willing to pay for one position
    function hedge(uint256 _quantity, uint256 _maxPremium) external canHedge nonReentrant {
        // Get available quantity
        (uint256 availableQuantity, uint256 buyerMargin, uint256 sellerMargin) = getAvailableQuantity();
        // Check that requested amount of positions is less than or equal to available positions
        require(_quantity <= availableQuantity, NOT_ENOUGH_LIQUIDITY);

        // If current pool size is not yet set, it means it's a first hedge in this epoch
        if (tradingPhasePoolSize == 0) {
            // Set trading phase pool size to current pool size
            tradingPhasePoolSize = getCurrentPoolSize();
            // Set trading phase total supply to current total supply
            tradingPhaseTotalSupply = totalSupply();
        }

        // Required premium consist of fixed buyer margin and dynamic premium, which depends on future pool utilization after the trade
        // requiredPremium = buyerMargin + getDynamicPremium(nextMargin)
        // nextMargin = sellerMargin * quantity
        uint256 requiredPremium = buyerMargin.add(
            _getDynamicPremium(sellerMargin.mul(_quantity))
        );

        // Check that required premium is less than or equal to maximum allowed premium by user
        require(requiredPremium <= _maxPremium, PREMIUM_TOO_LOW);

        // Calculate total premium
        // totalPremium = requiredPremium * quantity
        uint256 totalPremium = requiredPremium.mul(_quantity);
        
        // Transfer total premium from user
        underlying.safeTransferFrom(msg.sender, address(this), totalPremium);

        // Calculate required margin for derivatives creation
        // requiredMargin = (buyerMargin + sellerMargin) * quantity
        uint256 requiredMargin = buyerMargin.add(sellerMargin).mul(_quantity);

        ICore opiumCore = ICore(opiumRegistry.getCore());
        address opiumTokenSpender = opiumRegistry.getTokenSpender();

        // Approve Opium.TokenSpender to spend required margin
        underlying.safeApprove(opiumTokenSpender, 0); // Approving 0 first is required in some ERC20 tokens
        underlying.safeApprove(opiumTokenSpender, requiredMargin);

        // Create derivative and temporarily hold LONG tokens
        opiumCore.create(derivative, _quantity, [address(this), address(this)]);

        // Mint LONG position wrapper tokens to user by sending LONG position to the wrapper
        longPositionWrapper.mintForSomeone(_quantity, msg.sender);

        emit Hedge(msg.sender, _quantity);
    }

    /**
     * Estimate required premium for specified quantity
     * - Get positions availability
     * - Check that requested amount of positions is less than or equal to available positions
     * - Set trading pool size if was not set
     * - Calculate required premium
     */
    /// @notice Estimate required premium for specified quantity
    /// @param _quantity an amount of positions to create
    /// @return Estimated premium for specified quantity
    function getRequiredPremium(uint256 _quantity) external view returns (uint256) {
        // Get available quantity
        (uint256 availableQuantity, uint256 buyerMargin, uint256 sellerMargin) = getAvailableQuantity();
        // Check that requested amount of positions is less than or equal to available positions
        require(_quantity <= availableQuantity, NOT_ENOUGH_LIQUIDITY);

        // Required premium consist of fixed buyer margin and dynamic premium, which depends on future pool utilization after the trade
        // requiredPremium = buyerMargin + getDynamicPremium(tradingPhasePoolSize, nextMargin)
        // nextMargin = sellerMargin * quantity
        return buyerMargin.add(_getDynamicPremium(sellerMargin.mul(_quantity)));
    }

    /**
     * Estimate required dynamic premium for specified quantity
     * - Get next pool utilization
     * - Adjust pool utilization to decimals of the underlying token
     * - Calculate dynamic premium by formula
     */
    /// @notice Estimate required dynamic premium for specified quantity
    /// @param nextMargin an amount of margin required for the next settlement
    /// @return Estimated dynamic premium considering specified arguments
    function _getDynamicPremium(uint256 nextMargin) private view returns (uint256) {
        return pricingModule.getDynamicPremium(nextMargin);
    }

    /**
     * Explain to an end user what this does
     * - Fetch required buyer and seller margin from synthetic
     * - Calculate amount of positions that possible to create
     */
    /// @notice Explain to an end user what this does
    /// @return available quantity along side with buyer and seller margin for reusability to avoid repeated call of synthetic contracts
    function getAvailableQuantity() public view returns (uint256 availableQuantity, uint256 buyerMargin, uint256 sellerMargin) {
        // Fetch required buyer and seller margin from synthetic
        (buyerMargin, sellerMargin) = IDerivativeLogic(derivative.syntheticId).getMargin(derivative);
        // Calculate amount of positions that possible to create
        // pool size / seller margin
        availableQuantity = getCurrentPoolSize().div(sellerMargin);
    }

    /// @notice Current pool size
    /// @return Underlying token balance of the pool subtracted by accumulated fees
    function getCurrentPoolSize() public view returns (uint256) {
        uint256 poolBalance = underlying.balanceOf(address(this));
        
        if (poolBalance >= accumulatedOpiumFees) {
            return poolBalance.sub(accumulatedOpiumFees);
        }

        return 0;
    }

    // Helpers
    /// @notice Calculate LONG position tokenId from derivative hash
    /// @param _hash a hash of the derivative
    /// @return Token ID of derivative's LONG position
    function getLongTokenId(bytes32 _hash) public pure returns (uint256 tokenId) {
        tokenId = uint256(keccak256(abi.encodePacked(_hash, "LONG")));
    }

    /// @notice Calculate SHORT position tokenId from derivative hash
    /// @param _hash a hash of the derivative
    /// @return Token ID of derivative's SHORT position
    function getShortTokenId(bytes32 _hash) public pure returns (uint256 tokenId) {
        tokenId = uint256(keccak256(abi.encodePacked(_hash, "SHORT")));
    }

    function getDerivativeParams() external view returns (uint256[] memory) {
        return derivative.params;
    }

    // Opium position token receiver hooks
    // Called by Opium.TokenMinter to make sure that smart contract is prepared to receive provided `tokenId`
    function onERC721OReceived(
        address _operator,
        address _from,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    ) public returns (bytes4) {
        require(shortTokenId == _tokenId, ERROR_WRONG_TOKEN_ID);
        _operator;
        _from;
        _amount;
        _data;
        return ERC721O_RECEIVED;
    }

    function onERC721OBatchReceived(
        address _operator,
        address _from,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts,
        bytes memory _data
    ) public returns (bytes4) {
        for (uint256 index = 0; index < _tokenIds.length; index++) {
            require(shortTokenId == _tokenIds[index], ERROR_WRONG_TOKEN_ID);
        }
        _operator;
        _from;
        _amounts;
        _data;
        return ERC721O_BATCH_RECEIVED;
    }

    // Approve underlying token balance of the pool to governor in case of emergency
    function emergency() external nonReentrant isOpiumAddress {
        // Emergency happens when pool was not initialized within EMERGENCY_EPOCHS
        require(derivative.endTime.add(EPOCH.mul(EMERGENCY_EPOCHS)) < now, NOT_EMERGENCY);

        // Approve governor to spend all underlying token balance of this contract to handle emergency situation manually
        underlying.safeApprove(opiumAddress, 0); // Approving 0 first is required in some ERC20 tokens
        underlying.safeApprove(opiumAddress, uint256(-1));
    }

    // Governance
    /// @notice Sets new strike price delta
    /// @param _strikePriceDelta new strike price delta
    function setStrikePriceDelta(uint256 _strikePriceDelta) external isAdvisorAddress nonReentrant {
        require(_strikePriceDelta >= MIN_STRIKE_PRICE_DELTA, INVALID_VALUE);
        strikePriceDelta = _strikePriceDelta;
    }

    /// @notice Sets new strike price delta rounding
    /// @param _strikePriceDeltaRound new strike price delta rounding
    function setStrikePriceDeltaRound(uint256 _strikePriceDeltaRound) external isAdvisorAddress nonReentrant {
        require(_strikePriceDeltaRound > 0, INVALID_VALUE);
        strikePriceDeltaRound = _strikePriceDeltaRound;
    }

    /// @notice Sets next fixed premium
    /// @param _nextFixedPremium next fixed premium
    function setNextFixedPremium(uint256 _nextFixedPremium) external isOpiumAddress nonReentrant {
        nextFixedPremium = _nextFixedPremium;
    }

    /// @notice Sets pricing module
    /// @param _pricingModule pricing  module
    function setPricingModule(IPricingModule _pricingModule) external isOpiumAddress nonReentrant {
        pricingModule = _pricingModule;
    }
}


// File contracts/StakingPricedOptionsCall/OpiumStakingPricedOptionsCall.sol

pragma solidity 0.5.16;

interface IBarnStaking {
    function depositForSomeone(address tokenAddress, uint256 amount, address user) external;
}

/// @title OpiumStakingPricedOptionsCall
/// @author Opium.Team
/// @notice Opium Staking's main contract that represents ERC20 LP token and handles the logic of withdrawals and deposits
contract OpiumStakingPricedOptionsCall is OpiumStakingPricedOptionsCallDerivatives {
    // Events
    /// @notice Indicates new deposits into the pool
    /// @param user an address of the depositor
    /// @param _amount an amount of the deposit
    event Deposit(address indexed user, uint256 _amount);
    /// @notice Indicates new withdrawals from the pool
    /// @param user an address of the withdrawer
    /// @param _amount an amount of the withdrawal
    event Withdraw(address indexed user, uint256 _amount);

    // Instance of BarnBridge staking contract if enabled
    // Allows to automatically stake user's LP tokens into BarnBridge's rewards smart contract after deposits
    IBarnStaking public barnStaking;

    // Upper bound of pool's size
    // Set to 0 for unlimited upper bound
    uint256 public hardcap;

    // Fees
    // Reference value representing 100% of the fee adjusted to 10^4
    uint256 constant public FEE_BASE = 10000;
    // Maximum allowed fee
    uint256 constant public FEE_MAX = 500;
    // Amount of opium fee taken from withdrawals
    uint256 public opiumFee = 0;

    /// @notice Constructor of the contract that initializes state variables
    /// @param _name a name of LP token
    /// @param _symbol a symbol of LP token
    /// @param _barnStaking an instance of BarnBridge's rewards smart contract 
    /// @param _lengths an array of timestamps describing epoch and phases lengths
    /// @param _pricingModule a pricing module instance
    /// @param _hardcap an upper bound of pool's size
    /// @param _underlying an instance of underlying token
    /// @param _opiumRegistry an instance of Opium Registry contract to fetch other Opium contracts addresses
    /// @param _derivative initial derivative parameters including the end of the first epoch specified by `derivative.endTime`
    /// @param _factoryLongPositionWrapper an instance of the factory for LONG positions token wrapper
    constructor(
        // ERC20
        string memory _name,
        string memory _symbol,
        IBarnStaking _barnStaking,
        // Derivatives
        uint256[3] memory _lengths,
        IPricingModule _pricingModule,
        uint256 _hardcap,
        ERC20Detailed _underlying,
        Registry _opiumRegistry,
        LibDerivative.Derivative memory _derivative,
        IFactoryOpiumERC20Position _factoryLongPositionWrapper
    ) public 
        OpiumStakingPricedOptionsCallDerivatives(
            _lengths,
            _pricingModule,
            _underlying,
            _opiumRegistry,
            _derivative,
            _factoryLongPositionWrapper
        )
        // Initialize LP token with the same decimals as underlying token for 1:1 starting ratio
        ERC20Detailed(_name, _symbol, _underlying.decimals())
    {
        // Create an instance of Synthetic
        IDerivativeLogic iDerivativeLogic = IDerivativeLogic(_derivative.syntheticId);
        // Validate whether provided derivative's params are valid and compliant to synthetic's logic
        require(iDerivativeLogic.validateInput(_derivative), INVALID_DERIVATIVE);

        barnStaking = _barnStaking;
        hardcap = _hardcap;
    }

    /**
     * Deposit underlying token and receive LP tokens (pool shares)
     * - Calls private deposit function without `stake` flag
     */
    function deposit(uint256 _amount) external {
        _deposit(_amount, false);
    }

    /**
     * Deposit underlying token and stake LP tokens into BarnBridge's staking contract (rewards pool)
     * - Calls private deposit function with `stake` flag
     */
    function depositAndStake(uint256 _amount) external {
        _deposit(_amount, true);
    }

    /**
     * Deposit user's funds into staking pool
     * - Modifier checks whether STAKING or TRADING phase is active
     * - Check amount value to be positive
     * - Check if hardcap exists and new pool size will not exceed the hardcap
     * - Calculate shares to mint for provided amount
     * - Transfer underlying token from user 
     * - If `stake` flag is not set, just ming LP tokens to user
     * - If `stake` flag is set, mint LP tokens to the pool, approve them to BarnBridges smart contract and deposit them on user's behalf
     */
    /// @notice Deposit user's funds into staking pool
    /// @param _amount an amount of underlying token to deposit
    /// @param _stake flag indicating whether LP tokens should be staked into BarnBridge's staking contract once minted
    function _deposit(uint256 _amount, bool _stake) private canDeposit nonReentrant {
        // Check amount value to be positive
        require(_amount > 0, WRONG_AMOUNT);
        // Check if hardcap exists and new pool size will not exceed the hardcap
        require(hardcap == 0 || getCurrentPoolSize().add(_amount) <= hardcap, HARDCAP_REACHED);

        // Calculate shares to mint
        uint256 sharesToMint = calculateUnderlyingToSharesRatio(_amount);

        // Transfer underlying from user
        underlying.safeTransferFrom(msg.sender, address(this), _amount);

        if (!_stake) {
            // Mint LP tokens to user
            _mint(msg.sender, sharesToMint);
        } else {
            // Mint LP tokens to itself to stake on user's behalf to Rewards pool contract
            _mint(address(this), sharesToMint);
            // Approve just minted tokens for staking contract
            _approve(address(this), address(barnStaking), sharesToMint);
            // Call reward pool contract
            barnStaking.depositForSomeone(address(this), sharesToMint, msg.sender);
        }

        emit Deposit(msg.sender, _amount);
    }

    /**
     * Withdraw user's funds from staking pool
     * - Modifier checks whether STAKING phase is active
     * - Calculate amount of shares to burn for specified underlying
     * - Check if user's LP token balance is greater than or equal to the amount of shares to burn
     * - Burn LP tokens
     * - Calculate Opium fee
     * - Increment accumulated Opium fees
     * - Transfer underlying to user subtracting Opium fee
     */
    /// @notice Withdraw user's funds from staking pool
    /// @param _amount an amount of underlying token to withdraw
    function withdraw(uint256 _amount) external canWithdraw nonReentrant {
        // Calculate amount of shares to burn for specified underlying
        uint256 sharesToBurn = calculateUnderlyingToSharesRatio(_amount);
        // Check if user's LP token balance is greater than or equal to the amount of shares to burn
        require(
            balanceOf(msg.sender) >= sharesToBurn,
            BALANCE_GREATER_THAN_WITHDRAW_AMOUNT
        );

        // Burn LP tokens
        _burn(msg.sender, sharesToBurn);

        // Calculate Opium fee
        // fee = amount * opiumFee / FEE_BASE
        uint256 fee = _amount.mul(opiumFee).div(FEE_BASE);
        // Increment accumulated Opium fees
        // accumulatedOpiumFees += fee
        accumulatedOpiumFees = accumulatedOpiumFees.add(fee);

        // Transfer underlying to user subtracting Opium fee
        // transferAmount  = amount  - fee
        underlying.safeTransfer(msg.sender, _amount.sub(fee));

        emit Withdraw(msg.sender, _amount);
    }

    /// @notice Calculates amount of shares for specified amount of underlying tokens
    /// @param _amount an amount of underlying tokens
    function calculateUnderlyingToSharesRatio(uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 underlyingBalance = tradingPhasePoolSize;
        // If current pool size is not yet set, it means there were no hedges in this epoch
        if (underlyingBalance == 0) {
            // Set pool size to current pool size
            underlyingBalance = getCurrentPoolSize();
        }

        uint256 totalSharesSupply = tradingPhaseTotalSupply;
        // If current total supply is not yet set, it means there were no hedges in this epoch
        if (totalSharesSupply == 0) {
            // Set total supply to current total supply
            totalSharesSupply = totalSupply();
        }

        // If LP tokens total supply is 0, ratio is 1:1
        if (totalSharesSupply == 0 || underlyingBalance == 0) {
            return _amount;
        } else {
            // shares = amount * totalSharesSupply / totalUnderlyingBalance
            return _amount.mul(totalSharesSupply).div(underlyingBalance);
        }
    }

    /// @notice Calculates amount of underlying tokens for specified amount of shares
    /// @param _amount an amount of shares
    function calculateSharesToUnderlyingRatio(uint256 _amount)
        external
        view
        returns (uint256)
    {
        uint256 underlyingBalance = tradingPhasePoolSize;
        // If current pool size is not yet set, it means there were no hedges in this epoch
        if (underlyingBalance == 0) {
            // Set pool size to current pool size
            underlyingBalance = getCurrentPoolSize();
        }

        uint256 totalSharesSupply = tradingPhaseTotalSupply;
        // If current total supply is not yet set, it means there were no hedges in this epoch
        if (totalSharesSupply == 0) {
            // Set total supply to current total supply
            totalSharesSupply = totalSupply();
        }

        // If LP tokens total supply is 0, ratio is 1:1
        if (totalSharesSupply == 0) {
            return _amount;
        } else {
            // amount = shares * totalUnderlyingBalance / totalSharesSupply
            return _amount.mul(underlyingBalance).div(totalSharesSupply);
        }
    }

    /**
     * Withdraws all accumulated Opium fees to governor
     * - Modifier checks whether msg.sender is governor
     * - Transfer accumulated Opium fees to governor
     * - Reset accumulated Opium fees to 0
     */
    function withdrawOpiumFees() external isOpiumAddress nonReentrant {
        // Transfer accumulated Opium fees to governor
        underlying.safeTransfer(msg.sender, accumulatedOpiumFees);
        // Reset accumulated Opium fees to 0
        accumulatedOpiumFees = 0;
    }

    /// @notice Sets Opium fee by governor
    /// @param _opiumFee a new Opium fee
    function setOpiumFees(uint256 _opiumFee) external isOpiumAddress nonReentrant {
        require(_opiumFee <= FEE_MAX, "WRONG_FEE");
        opiumFee = _opiumFee;
    }

    /// @notice Sets Hardcap by governor
    /// @param _hardcap a new Hardcap
    function setHardcap(uint256 _hardcap) external isAdvisorAddress nonReentrant {
        hardcap = _hardcap;
    }

    /// @notice Sets Opium fee by governor
    /// @param _opiumRegistry a new Opium Registry
    function setOpiumRegistry(Registry _opiumRegistry) external isOpiumAddress nonReentrant {
        require(address(_opiumRegistry) != address(0), INVALID_VALUE);
        opiumRegistry = _opiumRegistry;
    }

    /// @notice Sets new Opium governor by current governor
    /// @param _opiumAddress an address of the new Opium governor
    function setOpiumAddress(address _opiumAddress) external isOpiumAddress nonReentrant {
        require(_opiumAddress != address(0), INVALID_VALUE);
        opiumAddress = _opiumAddress;
    }

    /// @notice Sets new Advisor by current governor or current advisor
    /// @param _advisorAddress an address of the new Advisor
    function setAdvisorAddress(address _advisorAddress) external isOpiumOrAdvisorAddress nonReentrant {
        require(_advisorAddress != address(0), INVALID_VALUE);
        advisorAddress = _advisorAddress;
    }
}