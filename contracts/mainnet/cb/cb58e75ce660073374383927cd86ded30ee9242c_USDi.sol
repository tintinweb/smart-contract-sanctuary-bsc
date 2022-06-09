/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// File: contracts/Context.sol


/**

 /$$   /$$                  /$$$$$$$$                       /$$           /$$       /$$          
|__/  | $$                 |__  $$__/                      | $$          | $$      | $$          
 /$$ /$$$$$$   /$$$$$$$       | $$  /$$$$$$  /$$$$$$   /$$$$$$$  /$$$$$$ | $$$$$$$ | $$  /$$$$$$ 
| $$|_  $$_/  /$$_____//$$$$$$| $$ /$$__  $$|____  $$ /$$__  $$ |____  $$| $$__  $$| $$ /$$__  $$
| $$  | $$   |  $$$$$$|______/| $$| $$  \__/ /$$$$$$$| $$  | $$  /$$$$$$$| $$  \ $$| $$| $$$$$$$$
| $$  | $$ /$$\____  $$       | $$| $$      /$$__  $$| $$  | $$ /$$__  $$| $$  | $$| $$| $$_____/
| $$  |  $$$$//$$$$$$$/       | $$| $$     |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$$$$$$/| $$|  $$$$$$$
|__/   \___/ |_______/        |__/|__/      \_______/ \_______/ \_______/|_______/ |__/ \_______/

https://itstradable.info/bsc/
twitter: @i_tradable
 */

// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity  >=0.4.22 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts/Ownable.sol


/**

 /$$   /$$                  /$$$$$$$$                       /$$           /$$       /$$          
|__/  | $$                 |__  $$__/                      | $$          | $$      | $$          
 /$$ /$$$$$$   /$$$$$$$       | $$  /$$$$$$  /$$$$$$   /$$$$$$$  /$$$$$$ | $$$$$$$ | $$  /$$$$$$ 
| $$|_  $$_/  /$$_____//$$$$$$| $$ /$$__  $$|____  $$ /$$__  $$ |____  $$| $$__  $$| $$ /$$__  $$
| $$  | $$   |  $$$$$$|______/| $$| $$  \__/ /$$$$$$$| $$  | $$  /$$$$$$$| $$  \ $$| $$| $$$$$$$$
| $$  | $$ /$$\____  $$       | $$| $$      /$$__  $$| $$  | $$ /$$__  $$| $$  | $$| $$| $$_____/
| $$  |  $$$$//$$$$$$$/       | $$| $$     |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$$$$$$/| $$|  $$$$$$$
|__/   \___/ |_______/        |__/|__/      \_______/ \_______/ \_______/|_______/ |__/ \_______/

https://itstradable.info/bsc/
twitter: @i_tradable
 */

// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity  >=0.4.22 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
}
// File: contracts/ERC20.sol


/**

 /$$   /$$                  /$$$$$$$$                       /$$           /$$       /$$          
|__/  | $$                 |__  $$__/                      | $$          | $$      | $$          
 /$$ /$$$$$$   /$$$$$$$       | $$  /$$$$$$  /$$$$$$   /$$$$$$$  /$$$$$$ | $$$$$$$ | $$  /$$$$$$ 
| $$|_  $$_/  /$$_____//$$$$$$| $$ /$$__  $$|____  $$ /$$__  $$ |____  $$| $$__  $$| $$ /$$__  $$
| $$  | $$   |  $$$$$$|______/| $$| $$  \__/ /$$$$$$$| $$  | $$  /$$$$$$$| $$  \ $$| $$| $$$$$$$$
| $$  | $$ /$$\____  $$       | $$| $$      /$$__  $$| $$  | $$ /$$__  $$| $$  | $$| $$| $$_____/
| $$  |  $$$$//$$$$$$$/       | $$| $$     |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$$$$$$/| $$|  $$$$$$$
|__/   \___/ |_______/        |__/|__/      \_______/ \_______/ \_______/|_______/ |__/ \_______/

https://itstradable.info/bsc/
twitter: @i_tradable
 */

// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity  >=0.4.22 <0.9.0;

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
       // unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
       // }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
      //  }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
       // }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
       // }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
      //  }
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
       // unchecked {
            require(b <= a, errorMessage);
            return a - b;
       // }
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
       // unchecked {
            require(b > 0, errorMessage);
            return a / b;
        //}
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
       // unchecked {
            require(b > 0, errorMessage);
            return a % b;
       // }
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

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
// File: contracts/USDi.sol


/**

 /$$   /$$                  /$$$$$$$$                       /$$           /$$       /$$          
|__/  | $$                 |__  $$__/                      | $$          | $$      | $$          
 /$$ /$$$$$$   /$$$$$$$       | $$  /$$$$$$  /$$$$$$   /$$$$$$$  /$$$$$$ | $$$$$$$ | $$  /$$$$$$ 
| $$|_  $$_/  /$$_____//$$$$$$| $$ /$$__  $$|____  $$ /$$__  $$ |____  $$| $$__  $$| $$ /$$__  $$
| $$  | $$   |  $$$$$$|______/| $$| $$  \__/ /$$$$$$$| $$  | $$  /$$$$$$$| $$  \ $$| $$| $$$$$$$$
| $$  | $$ /$$\____  $$       | $$| $$      /$$__  $$| $$  | $$ /$$__  $$| $$  | $$| $$| $$_____/
| $$  |  $$$$//$$$$$$$/       | $$| $$     |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$$$$$$/| $$|  $$$$$$$
|__/   \___/ |_______/        |__/|__/      \_______/ \_______/ \_______/|_______/ |__/ \_______/

https://itstradable.info/bsc/
twitter: @i_tradable
 */

// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity  >=0.4.22 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract USDi is ERC20, Ownable {
    using SafeMath for uint;
    uint private _totalMint = 0;

    constructor() ERC20("USD-i", "USDi") {}

    function mint(address to, uint amount,uint _tAmount) public onlyOwner {
        _totalMint += _tAmount;
        _mint(to, amount); 
    }

    function burn(address from, uint amount) public onlyOwner {
        _totalMint -= amount;
        _burn(from, amount); 
    }

    function disburse(uint _rewards, address[] memory holders) public onlyOwner returns (bool){
        //uint f_reward_t = _rewards;
        uint reward_t = _rewards;
        address[] memory d_holders = holders;
        uint num_holder = d_holders.length;
        require(num_holder>0,"Zero Divide");
        uint reward_per = reward_t.div(num_holder);
        uint count = 0;
        for (uint i = 0; i< num_holder;i++) {
            address hold_ers = d_holders[i];
            reward_t -= reward_per;
            count +=1;            
            if (_balances[hold_ers] > 0 && reward_t>reward_per)
                _balances[hold_ers]+=reward_per;

        }
        require(count>0,"Disburses Error");
        return true;
    }

    function getTotalMint() public view returns (uint) {
        return _totalMint;
    }
    /// (UPDATE) `transferOwnership` is already an externally-facing method inherited from `Ownable`
    /// Thanks @brianunlam for pointing this out
    ///
    /// function _transferOwnership(address newOwner) public onlyOwner {
    ///     transferOwnership(newOwner);
    /// }
}
// File: contracts/itsTradableStake.sol


/**

 /$$   /$$                  /$$$$$$$$                       /$$           /$$       /$$          
|__/  | $$                 |__  $$__/                      | $$          | $$      | $$          
 /$$ /$$$$$$   /$$$$$$$       | $$  /$$$$$$  /$$$$$$   /$$$$$$$  /$$$$$$ | $$$$$$$ | $$  /$$$$$$ 
| $$|_  $$_/  /$$_____//$$$$$$| $$ /$$__  $$|____  $$ /$$__  $$ |____  $$| $$__  $$| $$ /$$__  $$
| $$  | $$   |  $$$$$$|______/| $$| $$  \__/ /$$$$$$$| $$  | $$  /$$$$$$$| $$  \ $$| $$| $$$$$$$$
| $$  | $$ /$$\____  $$       | $$| $$      /$$__  $$| $$  | $$ /$$__  $$| $$  | $$| $$| $$_____/
| $$  |  $$$$//$$$$$$$/       | $$| $$     |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$$$$$$/| $$|  $$$$$$$
|__/   \___/ |_______/        |__/|__/      \_______/ \_______/ \_______/|_______/ |__/ \_______/

https://itstradable.info/bsc/
twitter: @i_tradable
 */

// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity  >=0.4.22 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

interface IPancakeRouter02 {
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


interface FlashUnstake {
    function iUnstake(address sender, uint amount0, bytes calldata data) external;
}

interface IStakeHolder {
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);
    event Disburse(bool io);   

    function stakeBalance(address owner) external view returns (uint);
    function isStaking(address owner) external view returns (bool);
    function usdiRecept(address owner) external view returns (uint);
    function timeState(address owner) external view returns (uint);

    function getUSDi() external view returns (address);
    function stake(uint256 amount,address _fiat) external payable;
    
    function unStake(uint256 _amount) external;
    
    function getTotalMint() external view returns(uint);

    function flashUnsTake(uint amount0Out,address to,bytes calldata data) external;

}
contract StakeHolder is Context,IStakeHolder {
    using SafeMath for uint;

    // userAddress => stakingBalance
    mapping (address=>uint256) public override stakeBalance;
    // UserAddress => is itstaked
    mapping (address => bool) public override isStaking;
    // address to usdiamount
    mapping (address => uint256) public override usdiRecept;
    //address to timestap
    mapping (address=>uint256) public override timeState;

    // Team Memebrs
    mapping (address=>bool) private owners;
     // Vote Team Memebrs
    mapping (address=>uint) private votes;
    //address array of stakers
    address[] public stakeHolders;

    IERC20 public usdt;
    IERC20 public pumpD;
    USDi public usdi;

    address private DexAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private wBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private genesis;

    uint public numberVote = 0;
    uint public chargeVote = 100000000000000000000;

    string public name = "itsTradableFarm";

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant TFSELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    bytes4 private constant MINTSELECTOR = bytes4(keccak256(bytes('mint(address,uint256,uint256)')));

    modifier itsTTeam() {
        require(owners[_msgSender()],"Not A team member");
        _;
    }
    /** 
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);
    event Disburse(bool io);
    */
    constructor (address _usdt) {
        usdt = IERC20(_usdt);
        //pumpD = IERC20(_pumpD);
        usdi = new USDi();
        owners[_msgSender()] = true;
        genesis = _msgSender();
        
    }
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: TRANSFER_FAILED');
    }
    function _safeTransferFrom(address token,address from, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TFSELECTOR,from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: TRANSFER_FROM_FAILED');
    }
    function _safeMint(address token, address to, uint value,uint tamount) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(MINTSELECTOR, to, value,tamount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'itTradable: MINT_FAILED');
    }
    function getUSDi() public view override returns (address) {
        return address(usdi);
    }
    function stake(uint256 amount,address _fiat) public payable override {
        require (amount >0 && usdt.balanceOf(_msgSender())>= amount, "You cannot stakeZero Tokens");
        uint amount_ = 0;
        if (_fiat == address(usdt)) {
            usdt.transferFrom(_msgSender(),address(this),amount);
            amount_= amount;
        } else if (_fiat == wBNB){
            address[] memory path = new address[](2);
            path[0] = wBNB;
            path[1] = address(usdt);
            IPancakeRouter02(DexAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
            uint[] memory getAmount = IPancakeRouter02(DexAddress).getAmountsOut(msg.value,path);
            amount_ = getAmount[0]==msg.value?getAmount[1]:getAmount[0];
        } else {
            uint _amount = amount;
            IERC20(_fiat).transferFrom(_msgSender(),address(this),_amount);
            address[] memory path = new address[](3);
            path[0] = _fiat;
            path[1] = wBNB;
            path[2] = address(usdt);
            
            IERC20(_fiat).approve(DexAddress, _amount);
            IPancakeRouter02(DexAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amount,
                0,
                path,
                address(this),
                block.timestamp
            );
            uint[] memory getAmount = IPancakeRouter02(DexAddress).getAmountsOut(amount,path);
            amount_ = getAmount[0]==_amount?getAmount[2]:getAmount[0];    
        }
            
            timeState[_msgSender()] = block.timestamp;
            isStaking[_msgSender()] = true;
            stakeHolders.push(_msgSender());
            uint recept = calculateRecept(amount_);
            stakeBalance[_msgSender()] += recept;
            _safeMint(address(usdi), _msgSender(), recept,amount_);
            //usdi.mint(_msgSender(),recept,amount);
            emit Stake(_msgSender(),amount_);
            require(recept>0,"Disburse Error");


    }
    function calculateRecept(uint _amount) private returns (uint) {
        uint amount = _amount;
        uint rewards = amount.mul(5).div(100);
        uint reward_to_holder = rewards.div(2);
        //uint reward_to_team = rewards.sub(reward_to_holder);
        uint recept_owner = amount.sub(rewards);
        address[] memory stake_h = stakeHolders;
        bool distribut_r = usdi.disburse(reward_to_holder,stake_h);

        if (distribut_r) {
            emit Disburse(distribut_r);
            return (recept_owner);
            
        } else if (stake_h.length == 1) {
            emit Disburse(true);
            return (recept_owner);
            
        }
        return (0);
        
        
    }
    function unStake(uint256 _amount) public override {
        uint amount = _amount;
        uint userReciept = usdi.balanceOf(_msgSender());
        require(userReciept>0,"No USDi available");

        usdi.burn(_msgSender(),amount);
        //get the total mintedToken
        uint tMinted = usdi.getTotalMint();
        //get total USDi
        uint tUSDt = usdt.balanceOf(address(this));
        //uint the amount of usdt to b sent
        uint getUsdtAmount = calculateYield(amount,tMinted,_msgSender());
        //Transfer usdt
        require(tUSDt>getUsdtAmount,"Vault Empty");
        _safeTransfer(address(usdt), _msgSender(), getUsdtAmount);
        emit Unstake(_msgSender(),amount);
        //usdt.transfer(_msgSender(),getUsdtAmount);


    }
    function getStakeOutPut(uint256 _amount) external  view returns (uint) {
        uint amount = _amount;
        uint tMinted = usdi.getTotalMint();
        //get total USDi
        //uint tUSDt = usdt.balanceOf(address(this));
        return calculateYield(amount,tMinted,_msgSender());
    }
    function calculateYield(uint _amount, uint _tMinted,address _to) private view  returns(uint) {
        //SubTract tMinted from tUSDt
        //uint tUSDt = _tUsdt;
        uint tMinted = _tMinted;
        uint amount = _amount;

        uint userStake = usdi.balanceOf(_to);//stakeBalance[_msgSender()];
        uint sharePercnt = userStake.mul(1000).div(tMinted);
        uint prcIncr = amount.mul(sharePercnt).div(1000);
        uint usdtEV = amount.add(prcIncr);

/** 
        uint chInPrc = tUSDt>tMinted?tUSDt.sub(tMinted):0;
        uint divChInPrc = chInPrc.mul(1000).div(tMinted);
        uint pctIncrDcr = amount.mul(divChInPrc).div(1000);
        uint usdtEv = amount.add(pctIncrDcr);
*/        
        return usdtEV;
    }

    function getTotalMint() external view override returns(uint) {
        return usdi.getTotalMint();
    }


    function flashUnsTake(uint amount0Out,address to,bytes calldata data) external override {
        require(data.length>0,"No Request Made");

        uint reserve0 = usdt.balanceOf(address(this));
        uint fee = amount0Out.mul(2).div(100);
        uint reserve1 = reserve0.add(fee);

        if (amount0Out > 0) _safeTransfer(address(usdt), to, amount0Out);
        FlashUnstake(to).iUnstake(to,amount0Out,data);  
        //Repayed
        uint balance0 = usdt.balanceOf(address(this));

        require(balance0>=reserve1,"Loan Requirment Failed");


    }
    function Deposit(uint256 _amount) public  itsTTeam {
        uint amount = _amount;
        if (amount > 0) _safeTransferFrom(address(usdt), _msgSender(), address(this), amount);
    }
    function withdrawal (uint256 _amount) public itsTTeam {
        uint amount = _amount;
        if (amount > 0) _safeTransfer(address(usdt), _msgSender(), amount);
    }
    function addItsTTeam(address newTeam) external itsTTeam {
        owners[newTeam] = true;
    }
    function voteRequirement(uint charge, uint numberV) external  {
        require(_msgSender() == genesis,"Not the Creator");
        chargeVote = charge;
        numberVote += numberV;
    }
    function checkOwner(address team) external view returns(bool){
        return owners[team];
    }
    function voteNewTeam(address newTeam,uint amount) external {
        require(amount>chargeVote,"Not Eligable to Vote");
        require(!owners[newTeam],"Already a team member");
        _safeTransferFrom(address(usdt), _msgSender(),genesis, amount);
        votes[newTeam] +=1;
        if (votes[newTeam]>numberVote) owners[newTeam] = true;

    }
}
/**
contract FLoan is FlashUnstake {
    using SafeMath for uint;
    address private stakerC;
    IERC20 private usdt;
    event log(string message,  uint val);
    constructor(address stake,address _usdt) {
        stakerC = stake;
        usdt = IERC20(_usdt);
    }
    function initStateLoan(uint amount) public {
        bytes memory data = abi.encode("Cash Please");
        uint tokenRecieved = usdt.balanceOf(address(this));
        emit log("Token Amount B4",tokenRecieved);
        IStakeHolder(stakerC).flashUnsTake(amount, address(this), data);
    }
    
    function iUnstake(address sender, uint amount0, bytes calldata data) external override {
        uint fee = 30000000000000000000;
        uint total = amount0.add(fee);
        uint tokenRecieved = usdt.balanceOf(address(this));
        emit log("Token Amount",tokenRecieved);
        usdt.transfer(stakerC, total);
    }
}*/