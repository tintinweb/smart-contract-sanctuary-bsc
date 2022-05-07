/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT

/**
 *
 */

pragma solidity ^0.8.13;


/** LIBRARY / DEPENDENCY **/

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @title Safe Math
 * 
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

/**
 * @title Context
 * 
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


    /** FUNCTION **/

    /**
     * @dev Act as the shorthand for msg.sender reference.
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Act as the shorthand for msg.data reference.
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev Act as the shorthand for msg.value reference.
     */
    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }

}

/**
 * @title Ownable
 * 
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

    mapping(address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        authorizations[_msgSender()] = true;
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
     * @dev Throws if called by any account other authorized accounts.
     */
    modifier authorized() {
        require(isAuthorized(_msgSender()), "Ownable: caller is not an authorized account");
        _;
    }

    /**
     * @dev Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * @dev Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * @dev Check if address is owner
     */
    function isOwner(address adr) public view returns (bool) {
        return adr == owner();
    }

    /**
     * @dev Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
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


/** ERC STANDARD **/

/**
 * @title IERC20Extended
 * 
 * @dev The interface for ERC20 with metadata extension included.
 */
interface IERC20Extended {


    /** FUNCTION **/
    
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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    
    
    /** EVENT **/

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

/**
 * @title ERC20
 * 
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
contract ERC20 is Context, IERC20Extended {


    /** DATA **/
    uint8 private _decimals;
    
    uint256 private _totalSupply;
    
    string private _name;
    string private _symbol;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;


    /** CONSTRUTOR **/

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(uint8 decimals_, string memory name_, string memory symbol_) {
        _decimals = decimals_;
        _name = name_;
        _symbol = symbol_;
    }


    /** FUNCTION **/

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
        return _decimals;
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
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
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
    function _transfer(address from, address to, uint256 amount) internal virtual {
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

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

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
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}


/** ROUTER **/

interface IUniswapV2Pair {
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    
    function symbol() external pure returns (string memory);
    
    function decimals() external pure returns (uint8);
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);
    
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);

    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    
    function factory() external view returns (address);
    
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function price0CumulativeLast() external view returns (uint256);
    
    function price1CumulativeLast() external view returns (uint256);
    
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    
    function skim(address to) external;
    
    function sync() external;

    function initialize(address, address) external;

}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}


/** DIVIDEND DISTRIBUTOR **/

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor, Ownable {
    

    /* LIBRARY */

    using SafeMath for uint256;


    /* DATA */
    
    IERC20Extended public rewardToken;
    IUniswapV2Router02 public router;
    
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    
    bool public initialized;

    uint256 public currentIndex;
    uint256 public minPeriod;
    uint256 public minDistribution;
    uint256 public totalShares;
    uint256 public totalDividends; 
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor;

    address public _token;
    address[] public shareholders;
    
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;


    /* MODIFIER */

    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(_msgSender() == _token);
        _;
    }


    /* CONSTRUCTOR */

    constructor(address rewardToken_, address router_) {
        _token = _msgSender();
        rewardToken = IERC20Extended(rewardToken_);
        router = IUniswapV2Router02(router_);

        dividendsPerShareAccuracyFactor = 10**36;
        minPeriod = 1 hours;
        minDistribution = 1 * (10**rewardToken.decimals());
    }


    /* EVENT */

    event ChangeRouter(address caller, address prevRouter, address newRouter);


    /* FUNCTION */

    /**
     * @dev Change router address.
     */
    function changeRouter(IUniswapV2Router02 _router) external authorized {
        address prevRouter = address(router);
        router = _router;
        emit ChangeRouter(_msgSender(), prevRouter, address(router));
    }

    /**
     * @dev Only authorized address can set initialization state for distributor.
     */
    function unInitialized(bool initialization) external authorized {
        initialized = initialization;
    }

    /**
     * @dev Only authorized address can set token address for dividend distributor.
     */
    function setTokenAddress(address token_) external initializer authorized {
        _token = token_;
    }

    /**
     * @dev Only authorized address can set distribution criteria for dividend distributor.
     */
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override authorized {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    /**
     * @dev Only authorized address can change reward token for dividend distribution.
     */
    function changeRewardToken(IERC20Extended _rewardToken) external authorized {
        rewardToken = _rewardToken;
    }

    /**
     * @dev Only token contract can set the number of shares owned by the address.
     */
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    /**
     * @dev Only authorized address can deposit funds into the pool.
     */
    function deposit() external payable override authorized {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: _msgValue()
        } (0, path, address(this), block.timestamp);

        uint256 amount = rewardToken.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    /**
     * @dev Only authorized address can process and trigger dividend distribution.
     */
    function process(uint256 gas) external override authorized {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    /**
     * @dev Check if all the predetermined conditions for dividend distribution have been met.
     */
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    /**
     * @dev Distribute dividend to the shareholders and update dividend information.
     */
    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    /**
     * @dev Get the cumulative dividend for the given share.
     */
    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }
    
    /**
     * @dev Get unpaid dividend that needed to be distributed for the given address.
     */
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    /**
     * @dev Add the address to the array of shareholders.
     */
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    /**
     * @dev Remove the address from the array of shareholders.
     */
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    /**
     * @dev Allow user to manually claim their accumulated dividend.
     */
    function claimDividend() external {
        distributeDividend(_msgSender());
    }

}


/** WHALEFAT **/

contract WHALEFAT is ERC20, Ownable {


    /** LIBRARY **/

    using SafeMath for uint256;


    /** DATA **/

    IUniswapV2Router02 public router;
    IUniswapV2Pair public pairContract;
    DividendDistributor public distributor;

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);

    address public pair;
    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public ecosystemReceiver;
    address public autoBlackhole;
    
    uint8 public rateDecimals;
    
    uint256 public rebaseRate;
    uint256 public uintMax;
    uint256 public gonsTotal;
    uint256 public supplyTotal;
    uint256 public supplyMax;
    uint256 public supplyInitialFragment;
    uint256 public lastRebasedTime;
    uint256 public lastAddLiquidityTime;
    uint256 public initRebaseStartTime;
    uint256 public distributorGas;
    uint256 public liquidityFee;
    uint256 public treasuryFee;
    uint256 public ecosystemFee;
    uint256 public dividendFee;
    uint256 public sellFee;
    uint256 public autoBlackholeFee;
    uint256 public totalFee;
    uint256 public feeDenominator;
    uint256 public gonsPerFragment;
    uint256 public gonSwapThreshold;
    uint256 public targetLiquidity;
    uint256 public targetLiquidityDenominator;

    bool public inSwap;
    bool public swapEnabled;
    bool public autoAddLiquidity;
    bool public autoRebase;

    mapping(address => bool) public _blacklistBotContract;
    mapping(address => bool) public _isFeeExempt;
    mapping(address => bool) public _isDividendExempt;
    mapping(address => uint256) public _gonBalances;
    mapping(address => mapping(address => uint256)) public _allowedFragments;


    /** MODIFIER **/

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address from, address to) {
        require(to != address(ZERO), "Cannot send to zero address!");
        require(!_blacklistBotContract[from], "Sender address has been blacklisted because it is a bot contract address!");
        require(!_blacklistBotContract[to], "Recipient address has been blacklisted because it is a bot contract address!");
        _;
    }


    /** CONSTRUCTOR **/

    constructor(
        uint256 _supplyMax,
        uint256 _supplyInitial,
        address _router,
        DividendDistributor _distributor,
        address[4] memory _feeReceiverSettings
    ) ERC20(5, "WHALEFAT", "WFAT") {
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        pairContract = IUniswapV2Pair(pair);

        _allowedFragments[address(this)][address(router)] = type(uint256).max;

        uintMax = ~uint256(0);
        rateDecimals = 7;
        distributorGas = 500000;
        dividendFee = 4;
        liquidityFee = 2;
        treasuryFee = 2;
        ecosystemFee = 2;
        autoBlackholeFee = 2;
        sellFee = 4;
        feeDenominator = 100;
        targetLiquidity = 50;
        targetLiquidityDenominator = 100;
    
        _initializeFeeReceivers(_feeReceiverSettings);
        _initializeDistributor(_distributor);
        
        initRebaseStartTime = block.timestamp;
        lastRebasedTime = block.timestamp;
        
        totalFee = liquidityFee.add(treasuryFee).add(ecosystemFee).add(dividendFee).add(autoBlackholeFee);
        supplyInitialFragment = _supplyInitial.mul(10**5);
        supplyTotal = supplyInitialFragment;
        supplyMax = _supplyMax.mul(10**5);
        gonsTotal = uintMax - (uintMax % supplyInitialFragment);
        gonsPerFragment = gonsTotal.div(supplyTotal);
        gonSwapThreshold = gonsTotal.div(10000).mul(10);

        _gonBalances[_msgSender()] = gonsTotal;

        autoRebase = false;
        autoAddLiquidity = true;
        swapEnabled = true;
        
        _isFeeExempt[_msgSender()] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[ecosystemReceiver] = true;
        _isDividendExempt[_msgSender()] = true;
        _isDividendExempt[pair] = true;
        _isDividendExempt[address(this)] = true;
        _isDividendExempt[DEAD] = true;

        _transferOwnership(_msgSender());
        emit Transfer(address(ZERO), _msgSender(), supplyTotal);

    }


    /** EVENT **/
    event RebaseInitiated(uint256 indexed epoch, uint256 totalSupply);
    event ChangeRouter(address caller, address prevRouter, address newRouter);
    event ChangePairContract(address caller, address prevPairContract, address newPairContract);
    event BotBlacklisted(address botAddress);


    /** FUNCTION **/

    // General function

    receive() external payable {}

    /**
     * @dev Change router address.
     */
    function changeRouter(IUniswapV2Router02 _router) external authorized {
        address prevRouter = address(router);
        router = _router;
        emit ChangeRouter(_msgSender(), prevRouter, address(router));
    }

    /**
     * @dev Change pair contract address.
     */
    function changePairContract(address _address) external authorized {
        address prevPairContract = address(pairContract);
        pairContract = IUniswapV2Pair(_address);
        emit ChangeRouter(_msgSender(), prevPairContract, address(pairContract));
    }

    /**
     * @dev Initiate manual synchronization.
     */
    function manualSync() external {
        IUniswapV2Pair(pair).sync();
    }

    /**
     * @dev Get the circulating supply based on fragment.
     */
    function getCirculatingSupply() public view returns (uint256) {
        return (gonsTotal.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(gonsPerFragment);
    }

    /**
     * @dev Get the status for auto rebase.
     */
    function setAutoRebase(bool _flag) external authorized {
        if (_flag) {
            autoRebase = _flag;
            lastRebasedTime = block.timestamp;
        } else {
            autoRebase = _flag;
        }
    }

    /**
     * @dev Set blacklist for known bot contract.
     */
    function setBotBlacklist(address _botAddress, bool _flag) external authorized {
        require(
            isContract(_botAddress),
            "Externally owned account are not allowed to be blacklisted only input smart contract address used for bot."
        );
        _blacklistBotContract[_botAddress] = _flag;
        emit BotBlacklisted(_botAddress);
    }

    /**
     * @dev Set settings for swap back.
     */
    function setSwapBackSettings(bool _enabled, uint256 _numerator, uint256 _denominator) external authorized {
        swapEnabled = _enabled;
        gonSwapThreshold = gonsTotal.div(_denominator).mul(_numerator);
    }

    /**
     * @dev Allow authorized account to rescue the token in the smart contract.
     */
    function rescueToken(address _tokenAddress, uint256 _tokens) external authorized returns (bool success) {
        return ERC20(_tokenAddress).transfer(_msgSender(), _tokens);
    }

    // Internal functions

    /**
     * @dev Rebase logic that will run internally.
     */
    function rebase() internal {
        
        if ( inSwap ) {
            return;
        }

        uint256 deltaTimeFromInit = block.timestamp - initRebaseStartTime;
        uint256 deltaTime = block.timestamp - lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 2355;
        } else if (deltaTimeFromInit >= (365 days) && deltaTimeFromInit < ((15 * 365 days) / 10)) {
            rebaseRate = 211;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10) && deltaTimeFromInit < (7 * 365 days)) {
            rebaseRate = 14;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 2;
        }

        for (uint256 i = 0; i < times; i++) {
            supplyTotal = supplyTotal.mul((10**rateDecimals).add(rebaseRate)).div(10**rateDecimals);
        }

        gonsPerFragment = gonsTotal.div(supplyTotal);
        lastRebasedTime = lastRebasedTime.add(times.mul(15 minutes));

        pairContract.sync();

        emit RebaseInitiated(epoch, supplyTotal);
        
    }

    /**
     * @dev Logic to take fee that will run internally.
     */
    function takeFee(address _from, address _to, uint256 _gonAmount) internal  returns (uint256) {
        
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;

        if (_to == pair) {
            _totalFee = totalFee.add(sellFee);
            _treasuryFee = treasuryFee.add(sellFee);
        }

        uint256 feeAmount = _gonAmount.mul(_totalFee).div(feeDenominator);
       
        _gonBalances[autoBlackhole] = _gonBalances[autoBlackhole].add(
            _gonAmount.mul(autoBlackholeFee).div(feeDenominator)
        );

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonAmount.mul(_treasuryFee).div(feeDenominator)
        );

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonAmount.mul(ecosystemFee).div(feeDenominator)
        );

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonAmount.mul(dividendFee).div(feeDenominator)
        );

        _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
            _gonAmount.mul(liquidityFee).div(feeDenominator)
        );
        
        emit Transfer(_from, address(this), feeAmount.div(gonsPerFragment));
        
        return _gonAmount.sub(feeAmount);

    }

    /**
     * @dev Logic to swap back the token that will run internally.
     */
    function swapBack() internal swapping {

        uint256 amountToSwap = _gonBalances[address(this)].div(gonsPerFragment);

        if( amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountETHToRespectiveReceiver = address(this).balance.sub(balanceBefore);
        uint256 feeTotal = treasuryFee.add(ecosystemFee).add(dividendFee);

        try distributor.deposit {
            value: amountETHToRespectiveReceiver.mul(dividendFee).div(feeTotal)
        } () {} catch {}

        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETHToRespectiveReceiver.mul(treasuryFee).div(feeTotal),
            gas: 30000
        }("");

        (success, ) = payable(ecosystemReceiver).call{
            value: amountETHToRespectiveReceiver.mul(ecosystemFee).div(feeTotal),
            gas: 30000
        }("");

        success = false;

    }

    /**
     * @dev Add liquidity logic that will run internally.
     */
    function addLiquidity() internal swapping {
        
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 autoLiquidityAmount = _gonBalances[address(this)].div(gonsPerFragment);
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }

        lastAddLiquidityTime = block.timestamp;

    }

    /**
     * @dev Token buyback logic that will run internally.
     */
    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: amount
        } (0, path, to, block.timestamp);
    }

    // Override ERC standard
    
    /**
     * @dev Override ERC logic for approve to accommodate fragments.
     */
    function approve(address _spender, uint256 _value) public override returns (bool) {
        _allowedFragments[_msgSender()][_spender] = _value;
        emit Approval(_msgSender(), _spender, _value);
        return true;
    }

    /**
     * @dev Override ERC logic for allowance to accommodate fragments.
     */
    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowedFragments[_owner][_spender];
    }

    /**
     * @dev Override ERC logic for decrease allowance to accommodate fragments.
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public override returns (bool) {
        
        uint256 oldValue = _allowedFragments[_msgSender()][_spender];
        
        if (_subtractedValue >= oldValue) {
            _allowedFragments[_msgSender()][_spender] = 0;
        } else {
            _allowedFragments[_msgSender()][_spender] = oldValue.sub(_subtractedValue);
        }
        
        emit Approval(_msgSender(), _spender, _allowedFragments[_msgSender()][_spender]);
        
        return true;

    }

    /**
     * @dev Override ERC logic for increase allowance to accommodate fragments.
     */
    function increaseAllowance(address _spender, uint256 _addedValue) public override returns (bool) {
        
        _allowedFragments[_msgSender()][_spender] = _allowedFragments[_msgSender()][_spender].add(_addedValue);
        
        emit Approval(_msgSender(), _spender, _allowedFragments[_msgSender()][_spender]);
        
        return true;
        
    }

    /**
     * @dev Override ERC logic for transfer to check addresses.
     */
    function transfer(address _to, uint256 _value) public override validRecipient(_msgSender(), _to) returns (bool) {

        _transferFrom(_msgSender(), _to, _value);

        return true;

    }

    /**
     * @dev Override ERC logic for transfer from to check addresses and accommodate fragment.
     */
    function transferFrom(address _from, address _to, uint256 _value) public override validRecipient(_from, _to) returns (bool) {
        
        if (_allowedFragments[_from][_msgSender()] != type(uint256).max) {
            _allowedFragments[_from][_msgSender()] = _allowedFragments[_from][_msgSender()].sub(_value, "Insufficient Allowance");
        }

        _transferFrom(_from, _to, _value);

        return true;

    }

    /**
     * @dev Override ERC logic for transfer that will be executed internally based on predetermined conditions.
     */
    function _basicTransfer(address _from, address _to, uint256 _amount) internal returns (bool) {
        
        uint256 gonAmount = _amount.mul(gonsPerFragment);
        _gonBalances[_from] = _gonBalances[_from].sub(gonAmount);
        _gonBalances[_to] = _gonBalances[_to].add(gonAmount);
        
        return true;
    }

    /**
     * @dev Override ERC logic for transfer from that will be executed internally based on predetermined conditions.
     */
    function _transferFrom(address _from, address _to, uint256 _amount) internal returns (bool) {

        if (inSwap) {
            return _basicTransfer(_from, _to, _amount);
        }

        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = _amount.mul(gonsPerFragment);
        _gonBalances[_from] = _gonBalances[_from].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(_from, _to) ? takeFee(_from, _to, gonAmount) : gonAmount;
        _gonBalances[_to] = _gonBalances[_to].add(gonAmountReceived);

        if(!_isDividendExempt[_from]) {
            try distributor.setShare(_from, balanceOf(_from)) {} catch {}
        }
        if(!_isDividendExempt[_to]) {
            try distributor.setShare(_to, balanceOf(_to)) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(_from, _to, gonAmountReceived.div(gonsPerFragment));

        return true;
    
    }

    /**
     * @dev Override ERC logic for total supply.
     */
    function totalSupply() public view override returns (uint256) {
        return supplyTotal;
    }
   
    /**
     * @dev Override ERC logic for balance of an address and accommodate balance based on fragment.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account].div(gonsPerFragment);
    }

    // Check function

    /**
     * @dev Check whether the predetermined conditions for taking fees have been met.
     */
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    /**
     * @dev Check whether the predetermined conditions for rebase have been met.
     */
    function shouldRebase() internal view returns (bool) {
        return autoRebase && (supplyTotal < supplyMax) && _msgSender() != pair  && !inSwap && block.timestamp >= (lastRebasedTime + 15 minutes);
    }

    /**
     * @dev Check whether the predetermined conditions for adding liquidity have been met.
     */
    function shouldAddLiquidity() internal view returns (bool) {
        return autoAddLiquidity && !inSwap && _msgSender() != pair && block.timestamp >= (lastAddLiquidityTime + 12 hours);
    }

    /**
     * @dev Check whether the predetermined condition for swap back have been met.
     */
    function shouldSwapBack() internal view returns (bool) {
        return swapEnabled && !inSwap && _msgSender() != pair && _gonBalances[address(this)] >= gonSwapThreshold;
    }
    
    /**
     * @dev Check if it is currently overliquified.
     */
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    /**
     * @dev Check to make sure that the transaction is not in swap.
     */
    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    /**
     * @dev Check whether fees are exempted from the given address.
     */
    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    /**
     * @dev Check the value of swap threshold.
     */
    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(gonsPerFragment);
    }

    /**
     * @dev Check whether the given address is a contract address.
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // Fees related functions

    /**
     * @dev Set all the fee receiver settings during contract initialization.
     * 
     * NOTE:
     * 0 - Auto liquidity receiver
     * 1 - Treasury receiver
     * 2 - Ecosystem receiver
     * 3 - Auto blackhole
     */
    function _initializeFeeReceivers(address[4] memory _feeReceiverSettings) internal {
        _setFeeReceivers(_feeReceiverSettings[0], _feeReceiverSettings[1], _feeReceiverSettings[2], _feeReceiverSettings[3]);
    }

    /**
     * @dev Set all the addresses that will receive fee.
     */
    function setFeeReceivers(address _autoLiquidityReceiver, address _treasuryReceiver, address _ecosystemReceiver, address _autoBlackhole) external authorized {
        _setFeeReceivers(_autoLiquidityReceiver, _treasuryReceiver, _ecosystemReceiver, _autoBlackhole);
    }

    /**
     * @dev Run internally to set all the fee receiver settings.
     */
    function _setFeeReceivers(address _autoLiquidityReceiver, address _treasuryReceiver, address _ecosystemReceiver, address _autoBlackhole) internal {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        ecosystemReceiver = _ecosystemReceiver;
        autoBlackhole = _autoBlackhole;
    }

    /**
     * @dev Exempt an address from fee.
     */
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        _isFeeExempt[holder] = exempt;
    }

    // Dividend related functions
    
    /**
     * @dev Set dividend distributor to be used for this contract.
     */
    function _initializeDistributor(DividendDistributor distributor_) internal {
        distributor = DividendDistributor(distributor_);
    }

    /**
     * @dev Initialize dividend distributor.
     */
    function distributorInitialization(bool initialized) public authorized {
        distributor.unInitialized(initialized);
    }
    
    /**
     * @dev Set the information for dividend distributor.
     */
    function setDividendDistributor(address distributor_) public authorized {
        distributor.unInitialized(false);
        distributor.setTokenAddress(_msgSender());
        distributor = DividendDistributor(distributor_);
    }

    /**
     * @dev Set the criteria for dividend distribution.
     */
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    /**
     * @dev Set the maximum gas to be used for auto dividend distribution.
     */
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    /**
     * @dev Exempt an address from dividend.
     */
    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        _isDividendExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    // Liquidity related functions

    /**
     * @dev Get liquidity backing.
     */
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = _gonBalances[pair].div(gonsPerFragment);
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    /**
     * @dev Set the status for add liquidity automation.
     */
    function setAutoAddLiquidity(bool _flag) external authorized {
        if(_flag) {
            autoAddLiquidity = _flag;
            lastAddLiquidityTime = block.timestamp;
        } else {
            autoAddLiquidity = _flag;
        }
    }

    /**
     * @dev Set settings for target liquidity.
     */
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    // Buyback relateed functions

    /**
     * @dev Allow buyback and burn the token using funds stucked in smart contract.
     */
    function triggerZeusBuyback(uint256 amount) external authorized {
        buyTokens(amount, DEAD);
    }

}