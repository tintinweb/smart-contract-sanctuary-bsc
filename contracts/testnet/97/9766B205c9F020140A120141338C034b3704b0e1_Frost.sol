/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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

// File: Frost/Frost.sol






pragma solidity ^0.8.4;


contract Frost is Ownable {
    
	using SafeMath for uint256;
	
	//IERC20 public token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //Busd Mainnet
	IERC20 public token = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); //Busd tesnet
	

	uint256 private FeeVal = 5;
    uint256 private Portfolio = 50;//Portfolio
    uint256 private MaxRef = 200;//200
	uint256 private MaxTVL = 60000 ether;// 60000 BUSD
	uint256 private MAX_PAYOUT = 62400 ether;// 62400 BUSD
	uint256 private Dline = 1200 ether;// 1200 BUSD
	uint256 private MaxPercDline = 10;//Max DUPL
	uint256 private porcBenf = 2;
	uint256 private porcBenfRef = 5;
	uint256 private porcBenfRefReinv = 5;
	uint256 private minReinv = 6;
	uint256 private minInvest = 10 ether;// 10 BUSD
	uint256 private maxTVLBenf = 1200 ether;// 1200 BUSD
	uint256 private tvlFreeAC = 150 ether;// 150 BUSD  // +150 apply fee 0,2% to TVL in On autocompound

	uint256 private whitelistFeeVal = 1;

    uint256 constant internal TIME_DAY = 1 minutes; //24 hours
	uint256 constant internal TIME_STEP = 6 minutes; //6 days
	uint256 constant internal TIME_STEP_REINV = 15 seconds; //6 hours
	uint256 constant internal TIME_STEP_REWARD = 75 seconds; //30 hours
	uint256 constant internal TIME_LOTTERY = 75 seconds; //30 hours
	uint256 constant internal TIME_MIN_WITHDRAW_CAPITAL = 2 minutes; //30 days

	bool private initialized = false;
	address payable public devAddress;
	address payable public marketingAddress;
	address payable public businessAngelAddress;
    address payable public brokerAddress;

	address private signer;

    struct Userx{

		uint256 invest;
		uint256 investAcum;
		uint256 investAcumBlock;
        uint checkpoint;
		uint checkiniReinv;
        uint256 countReinv;
		uint256 withdraw;
		uint256 rewards;
		address referrals;
        uint256 teamCount;
        address[199] addressTeam;
		bool autoReinv;
		uint checklastInvest;
		
	}

	struct Ctrlbenef{

		uint256 PercDline;
		bool statusActive;

	}

	struct Team{

		uint256 rewardReceivedFromDeposit;
		uint256 rewardReceivedFromCompound;
		uint256 totalSendFromAirdrops;
		uint lastDateAirdrop;
		uint256 amountOfAirdropsSent;
		
	}

	struct Lottery{

		uint256 dateIni;
		uint256 TotalParticipants;
		address winnerAdr;
		uint256 totalDepositWinner;
		uint256 totalWon;
		uint256 percenApplied;
		bool status;
		
	}

	struct LotteryParticipant {
        address adr;
        uint256 totalDeposit;
    }

	struct Airdrop {

		uint256 _dateAirdrop;
		uint256 _numOfWallets;
		uint256 _amountSent;		

    }

	struct WhiteList {
		
        bool _isSend;
		uint256 _send;		

    }

	
    struct Split {
       
        uint8 v;
        bytes32 r;
        bytes32 s;

    }

    struct GiftCertificateData {

		uint256 codeId;
        address beneficiary;
        uint256 giftAmount;
        uint256 directPay;

    }

    mapping(address => Userx) public usersx;
	mapping(address => Ctrlbenef) public ctrlbenef;
	mapping(address => mapping(address => Team)) public myTeam;
	mapping(uint256 => Lottery) public listLottery;
	mapping(uint256 => Airdrop) public SetAirdrop;
	mapping(uint256 => mapping(address => WhiteList)) public myAirdrops;
	mapping(uint256 => bool) public appliedCodes;

	LotteryParticipant[] internal Participants;

	uint public totalInjected;
	uint public totalInvested;
	uint public totalUsers;
	uint public totalWithdrawals;
	uint public lotteryCount;  
	uint public WhiteListRewards;
	

	constructor( address _dev, address _mark, address _ba, address _brok, address _signer) {	

		devAddress = payable(_dev);
		marketingAddress = payable(_mark);
		businessAngelAddress = payable(_ba);
        brokerAddress = payable(_brok);
		signer = _signer;

	}

	modifier initializer() {
		require(initialized, "initialized is false");
		_;
	}

	modifier checkUser_() {
		require(checkUser(), "To withdraw: try again later");
		_;
	}

	function checkUser() public view returns (bool){
		uint256 check = block.timestamp.sub(usersx[msg.sender].checkpoint);
		if(check > TIME_STEP) {
			return true;
		}
		return false;
	}

	modifier checkUserReinv_() {
		require(checkUserReinv(), "To Reinvest: try again later");
		_;
	}

	function checkUserReinv() public view returns (bool){
		uint256 check = block.timestamp.sub(usersx[msg.sender].checkiniReinv);
		if(check > TIME_STEP_REINV) {
			return true;
		}
		return false;
	}

	modifier checkMaxTVL_(address _wallet) {
		require(checkMaxTVL(_wallet), "Total wallet TVL reached");
		_;
	}

	function checkMaxTVL(address _wallet) public view returns (bool){
		
		uint256 tvl = usersx[_wallet].investAcumBlock;
		
		if(tvl < MaxTVL) {
			return true;
		}
		return false;
	}

	modifier checkMaxTVLAcum_(address _wallet) {
		require(checkMaxTVLAcum(_wallet), "Total wallet TVL reached");
		_;
	}

	function checkMaxTVLAcum(address _wallet) public view returns (bool){
		
		uint256 tvl = usersx[_wallet].investAcum;
		
		if(tvl < MaxTVL) {
			return true;
		}
		return false;
	}

	function checkInvMaxTVL(uint256 _amount, address _wallet) public view returns (bool){
		uint256 tvl = usersx[_wallet].investAcum;
		uint256 tvltotal = SafeMath.add(tvl,_amount);
		if(tvltotal <= MaxTVL) {
			return true;
		}
		return false;
	}

	function checkMinInvest(uint256 _amount) public view returns (bool){

		if(_amount >= minInvest) {
			return true;
		}
		return false;
	}

	function checkFreeAC(uint256 _tvl) public view returns (bool){

		if(_tvl <= tvlFreeAC) {
			return true;
		}
		return false;
	}

	function bonusDepUpLine( uint256 _amount, uint256 _myPercDUPL) public view returns(uint256) {

		uint256 valueOnePerc = 0;
		uint256 valueDUPL = 0;
		
		if( _myPercDUPL >= 1  && _myPercDUPL <= MaxPercDline ) {
			
			valueOnePerc = SafeMath.div(_amount,100);
			valueDUPL = SafeMath.mul(valueOnePerc,_myPercDUPL);

		}

		return valueDUPL;

	}

	function bonusDownLine( uint256 _amount, uint256 _myteam) public pure returns(uint256) {

		uint256 perc = 0;
		uint256 valueOnePerc = 0;
		uint256 valueBDL = 0;
		
		if( _myteam >= 5 ) {
			
			if( _myteam >= 5  && _myteam <= 9 )   {perc = 5;}
			if( _myteam >= 10 && _myteam <= 19 )  {perc = 6;}
			if( _myteam >= 20 && _myteam <= 39 )  {perc = 7;}
			if( _myteam >= 40 && _myteam <= 79 )  {perc = 8;}
			if( _myteam >= 80 && _myteam <= 159 ) {perc = 9;}
			if( _myteam >= 160 ) {perc = 10;}
			
			valueOnePerc = SafeMath.div(_amount,100);
			valueBDL = SafeMath.mul(valueOnePerc,perc);

		}

		return valueBDL;

	}

	function percDline( uint256 _amount, address _wallet) public view returns(uint256) {

		uint256 perc = 0;
		uint256 myperc =  ctrlbenef[_wallet].PercDline;
		uint256 percfree = MaxPercDline - myperc;
		uint256 percCountAmount = _amount / Dline;
		uint256 totalpercefut = percCountAmount +  myperc;

		if( percfree >= percCountAmount ) {perc = totalpercefut;}
		if( percfree < percCountAmount ) {perc = MaxPercDline;}

		return perc;

	}

    function invest(uint _amount, address ref) external initializer checkMaxTVLAcum_(msg.sender) {

		require(checkMinInvest(_amount), "The minimum investment is 10 BUSD");
		require(usersx[msg.sender].withdraw < MAX_PAYOUT, "Total payout must be lower than max payout");
		require(checkInvMaxTVL(_amount, msg.sender), "Try a lower deposit to avoid exceeding the max tvl");

		token.transferFrom(msg.sender, address(this), _amount); //ACTIVAR ESTO CUANDO ESTEMOS LISTOS PARA SALIR

		if(_amount >= Dline && ctrlbenef[msg.sender].PercDline < MaxPercDline ) {
			
			Ctrlbenef storage ctrlb = ctrlbenef[msg.sender];
			uint256 perc = percDline(_amount,msg.sender);
			ctrlb.PercDline = perc;

		}

        uint256 fee = devFee(_amount);
        uint256 inv = tradeinv(_amount);
		uint256 _wlfeeInv = SafeMath.div(verifyAmount(_amount,whitelistFeeVal),2);
		WhiteListRewards += (_wlfeeInv);

		sendFeesInv(fee,inv);
 
        _amount = SafeMath.sub(_amount,SafeMath.add(fee,_wlfeeInv));

        if(ref == msg.sender) {
			ref = address(0);
		}

		Userx storage user = usersx[msg.sender];

        if(user.referrals == address(0) && user.referrals != msg.sender) {
			user.referrals = ref;
		}

		if(user.invest == 0 && user.investAcumBlock == 0 && user.checkpoint == 0 ) {

			user.checkpoint = block.timestamp;
			user.autoReinv = false;
			user.countReinv = 1;
			user.checkiniReinv = block.timestamp;
			user.investAcumBlock = _amount;
	
			ctrlbenef[msg.sender].statusActive = true;
			totalUsers++;
			Userx storage referrals_ = usersx[user.referrals];

			if(referrals_.teamCount < MaxRef && user.referrals != address(0)) {

				uint256 rewardRef = SafeMath.div(_amount,SafeMath.div(100,porcBenfRef));  

				referrals_.investAcum = SafeMath.add(referrals_.investAcum,rewardRef); 
				referrals_.rewards = SafeMath.add(referrals_.rewards,rewardRef);
				referrals_.teamCount = SafeMath.add(referrals_.teamCount,1);
				referrals_.addressTeam[referrals_.teamCount - 1] = msg.sender;

				Team storage referralsTeam_ = myTeam[user.referrals][msg.sender];
				referralsTeam_.rewardReceivedFromDeposit = rewardRef;
		
			}

		}
		if(user.invest == 0 && user.investAcum > 0) {

			user.investAcumBlock =  SafeMath.add(user.investAcum,_amount);			

		}
		user.invest += _amount;
		user.investAcum += _amount;
		user.checklastInvest =  block.timestamp;
		totalInvested += _amount;


		if(checkActiveLottery() && ParticipantOK(msg.sender)){

			LotteryParticipant memory newParticipant = LotteryParticipant(msg.sender,_amount);
       	    Participants.push(newParticipant);
			Lottery storage listLott = listLottery[lotteryCount];
			listLott.TotalParticipants = listLott.TotalParticipants + 1;

		}

	}

	function reinvest() public initializer checkUserReinv_ checkMaxTVL_(msg.sender){

		require(usersx[msg.sender].withdraw < MAX_PAYOUT, "Total payout must be lower than max payout");
		require(usersx[msg.sender].investAcum > 0 && usersx[msg.sender].investAcumBlock > 0 , "You must have made at least one investment");
		require(usersx[msg.sender].autoReinv == false, "Can't reinvest while auto compounding is active");

		compound(msg.sender, 1);

	}

	function compound(address _wallet, uint256 _countReinv) private initializer {

		Userx storage user = usersx[_wallet];
		uint256 benefx = benef(_wallet);
		uint256 myteam = usersx[_wallet].teamCount;
		uint256 myPercDUPL =  ctrlbenef[_wallet].PercDline;

		uint256 BDL = bonusDownLine(benefx,myteam);
		uint256 DUPL = bonusDepUpLine(benefx,myPercDUPL);

		uint256 TotalBonus = SafeMath.add(BDL,DUPL);
		uint256 TotalBenefx = SafeMath.add(benefx,TotalBonus);

		user.investAcum = SafeMath.add(user.investAcum,TotalBenefx);
		user.investAcumBlock = user.investAcum;
		user.rewards = SafeMath.add(user.rewards,TotalBonus);
		user.countReinv = SafeMath.add(user.countReinv,_countReinv);
		user.checkiniReinv = block.timestamp;

		if(user.investAcum > MaxTVL ) {user.countReinv = minReinv;}

		if(user.referrals != address(0)) {

			uint256 rewardRefCompound = SafeMath.div(benefx,SafeMath.div(100,porcBenfRefReinv));

			Userx storage referrals_ = usersx[user.referrals];
			referrals_.investAcum = SafeMath.add(referrals_.investAcum,rewardRefCompound);
			referrals_.rewards = SafeMath.add(referrals_.rewards,rewardRefCompound);
			
			Team storage referralsTeam_ = myTeam[user.referrals][_wallet];
			referralsTeam_.rewardReceivedFromCompound =  SafeMath.add(referralsTeam_.rewardReceivedFromCompound,rewardRefCompound);

		}
		
	}

	function onAutoCompounding(uint _amount) external initializer checkUserReinv_ {

		require(usersx[msg.sender].investAcum > 0 && usersx[msg.sender].investAcumBlock > 0, "You must have made at least one investment");
		require(usersx[msg.sender].autoReinv == false, "Turn off the automatic compound before activating it");

		uint256 tvl = usersx[msg.sender].investAcum;
		
		if (!checkFreeAC(tvl)) {

			uint256 feeAC = getFeeAC(tvl);
			require(_amount >= feeAC, "The amount must be equal to or greater than the automatic compounding fee.");

			token.transferFrom(msg.sender, devAddress, _amount); //ACTIVAR ESTO CUANDO ESTEMOS LISTOS PARA SALIR
		
		}

		reinvest();
		Userx storage user = usersx[msg.sender];
		user.autoReinv =  true;

	}

	function offAutoCompounding() external initializer {

		require(usersx[msg.sender].investAcum > 0 && usersx[msg.sender].investAcumBlock > 0, "You must have made at least one investment");
		require(usersx[msg.sender].autoReinv == true, "Turn on auto compound before activating it");

		uint256 secondsPassed = SafeMath.sub(block.timestamp,usersx[msg.sender].checkiniReinv);

        uint256 daysPassed = SafeMath.div(secondsPassed, TIME_DAY);
        uint256 AC = daysPassed;

		Userx storage user = usersx[msg.sender];

        if (AC > 5) {AC = 5;}

        if (AC > 0) {

			compound(msg.sender, AC);
			
		}

		if (AC == 0) {compound(msg.sender, 1);}

		user.autoReinv =  false;
        	
	}

	function withdraw() external initializer checkUser_ {

		require(usersx[msg.sender].withdraw < MAX_PAYOUT, "Total payout must be lower than max payout");
		require(usersx[msg.sender].investAcum > 0 && usersx[msg.sender].investAcumBlock > 0, "You must have made at least one investment");
		require(usersx[msg.sender].autoReinv == false, "Can't withdraw while auto compounding is active");
		require(usersx[msg.sender].countReinv >= minReinv , "You must do at least 6 compounds");

		Userx storage user =usersx[msg.sender];
		
		uint256 benefx = benef(msg.sender);

		uint256 totalBenef = benefx;

		if(SafeMath.add(totalBenef,user.withdraw) > MAX_PAYOUT) {totalBenef = SafeMath.sub(MAX_PAYOUT,user.withdraw);}

		user.withdraw = SafeMath.add(user.withdraw,totalBenef);
		
		user.investAcumBlock = user.investAcum;
		user.checkpoint = block.timestamp;
		user.checkiniReinv = block.timestamp;

		user.countReinv = 1;

		if(user.investAcum > MaxTVL ) {user.countReinv = minReinv;}

		uint256 fee = wFee(totalBenef);
        sendFeesWith(fee);
		uint256 _wlfeeWith = SafeMath.div(verifyAmount(totalBenef,whitelistFeeVal),2);
		WhiteListRewards += (_wlfeeWith);


    	transferHandler(msg.sender, SafeMath.sub(totalBenef,SafeMath.add(fee,_wlfeeWith)));		
		totalWithdrawals += totalBenef; 

	}
	
	function benef(address _wallet) public view returns(uint256) {

		uint256 investAcumx =  usersx[_wallet].investAcumBlock;
		bool ac =  usersx[_wallet].autoReinv;
		uint256 benefxz = 0;
		uint256 time = SafeMath.sub(block.timestamp, usersx[_wallet].checkiniReinv);
		uint256 porcbenef = 0;
		uint256 valuexsec = 0;
		uint256 indi = 0;


		if(ac == true ) {
			
			if(time <= TIME_DAY*6){

				valuexsec = porcbenefcalcAC(time, investAcumx);
				benefxz = SafeMath.mul(time,valuexsec);

			}else{

				valuexsec = porcbenefcalcAC(TIME_DAY*6, investAcumx);
				benefxz = SafeMath.mul(TIME_DAY*6,valuexsec);
			}
		
		}else{

			if(time <= TIME_DAY){

				porcbenef =  porcbenefcalc(TIME_DAY, investAcumx);//
				valuexsec = SafeMath.div(porcbenef,TIME_DAY);
				benefxz = SafeMath.mul(time,valuexsec);

			}

			if(time > SafeMath.mul(TIME_DAY,1) && time <= SafeMath.mul(TIME_DAY,2) ){benefxz = calcbenefDays(1,2,_wallet,investAcumx);}

			if(time > TIME_STEP_REWARD) {

				indi = SafeMath.div(100,porcBenf);
				porcbenef =  SafeMath.div(SafeMath.add(investAcumx,SafeMath.div(investAcumx,indi)), indi) ;
				porcbenef =  SafeMath.sub(porcbenef,SafeMath.div(investAcumx,indi)) ;
				benefxz = SafeMath.add(SafeMath.div(porcbenef,4),SafeMath.div(investAcumx,indi));

			}

		}

		if(benefxz > maxTVLBenf ) {benefxz  = maxTVLBenf;}

		return benefxz;

	}

	function calcbenefDays( uint256 _dayBack, uint256 _dayNow , address _wallet, uint256 _investAcumx) private view returns(uint256) {

		uint256 time2 = 0; 
		uint256 porcbenef = 0;
		uint256 valuexsec = 0;
		uint256 benefx = 0;
		uint256 benefdayback = 0;
		uint256 difDays =0;

		time2 = time2x(_dayBack,_wallet);
		porcbenef =  porcbenefcalc(SafeMath.mul(TIME_DAY,_dayNow) , _investAcumx);
		benefdayback = porcbenefcalc(SafeMath.mul(TIME_DAY,_dayBack) , _investAcumx);
		difDays = SafeMath.sub(porcbenef,benefdayback);
		valuexsec = SafeMath.div(difDays,TIME_DAY);
		benefx = SafeMath.add(benefdayback,SafeMath.mul(time2,valuexsec));

		return benefx;

	}

	function time2x( uint256 _dayBack, address _wallet) private view returns(uint256) {

		uint256 time2xz = 0;
		time2xz = SafeMath.sub(block.timestamp, SafeMath.add(usersx[_wallet].checkiniReinv,SafeMath.mul(TIME_DAY,_dayBack)));
		return time2xz;

	}

	function porcbenefcalc(uint256 _time , uint256 _investAcumx) public view returns(uint256) {

		uint256 div = 0;
		uint256 indi = SafeMath.div(100,porcBenf);

		uint256 day1= _investAcumx / indi;
		uint256 day2= (_investAcumx + day1) / indi;
		uint256 day3= (_investAcumx + day1 + day2) / indi;
		uint256 day4= (_investAcumx + day1 + day2 + day3) / indi;
		uint256 day5= (_investAcumx + day1 + day2 + day3 + day4) / indi;
		uint256 day6= (_investAcumx + day1 + day2 + day3 + day4 + day5) / indi;

		if(_time <= TIME_DAY){div = day1;}
		if(_time > TIME_DAY && _time <= (TIME_DAY*2) ){div = day2;}
		if(_time > (TIME_DAY*2) && _time <= (TIME_DAY*3) ){div = day3;}
		if(_time > (TIME_DAY*3) && _time <= (TIME_DAY*4) ){div = day4;}
		if(_time > (TIME_DAY*4) && _time <= (TIME_DAY*5) ){div = day5;}
		if(_time > (TIME_DAY*5) ){div = day6;}	

		return div;
	}

	function porcbenefcalcAC(uint256 _time , uint256 _investAcumx) public view returns(uint256) {

		uint256 div = 0;
		uint256 indi = SafeMath.div(100,porcBenf);

		uint256 day1= _investAcumx / indi;
		uint256 day2= (_investAcumx + day1) / indi;
		uint256 day3= (_investAcumx + day1 + day2) / indi;
		uint256 day4= (_investAcumx + day1 + day2 + day3) / indi;
		uint256 day5= (_investAcumx + day1 + day2 + day3 + day4) / indi;
		uint256 day6= (_investAcumx + day1 + day2 + day3 + day4 + day5) / indi;

		if(_time <= TIME_DAY){div = day1/ TIME_DAY;}
		if(_time > TIME_DAY && _time <= (TIME_DAY*2) ){div = (day1 + day2)/(TIME_DAY*2);}
		if(_time > (TIME_DAY*2) && _time <= (TIME_DAY*3) ){div = (day1 + day2 + day3)/(TIME_DAY*3);}
		if(_time > (TIME_DAY*3) && _time <= (TIME_DAY*4) ){div = (day1 + day2 + day3 + day4)/(TIME_DAY*4);}
		if(_time > (TIME_DAY*4) && _time <= (TIME_DAY*5) ){div = (day1 + day2 + day3 + day4 + day5)/(TIME_DAY*5);}
		if(_time > (TIME_DAY*5) ){div = (day1 + day2 + day3 + day4 + day5 + day6)/(TIME_DAY*6);}	

		return div;
	}

	function getFeeAC(uint256 _tvl) public pure returns (uint256){
		
		uint256 calcporc = SafeMath.div(SafeMath.mul(_tvl,1),100);
		uint256 fee = SafeMath.div(calcporc,5);//0,2% TVL
		return fee;

	}

	function getMyTeam(address _wallet) public view returns (address[199] memory) {
        return usersx[_wallet].addressTeam;
    }
	
	function devFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,FeeVal),100);
	}

    function tradeinv(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,Portfolio),100);
	}


	function wFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,FeeVal),100);
	}
	
	function startMarket() public onlyOwner {//CAMBIAR EL NOMBRE DE LA FUNCION INICIALIZADORA
		
		initialized = true;
		
	}
	
	function getBalance() public view returns(uint256) {
		return 	token.balanceOf(address(this));
	}
	
	function getPublicData() public view returns(uint _totalInvest, uint _balance) {
		_totalInvest = totalInvested;
		_balance = getBalance();
	}

    function GetAllowance() public view returns(uint256){
       return token.allowance(msg.sender, address(this));
   	}

    function userDatax(address user_) public view returns (

    uint256 invest_,
	uint256 rewards_,
	address referrals_,
	uint256 checkpoint_,
    uint256 teamCount_,
    uint256 countReinv_,
	uint256 withdraw_,
	uint256 investAcum_

	) { 

	Userx memory user = usersx[user_];
	
    invest_= user.invest;
	rewards_= user.rewards;
	referrals_= user.referrals;
	checkpoint_= user.checkpoint;
    teamCount_= user.teamCount;
    countReinv_= user.countReinv;
    withdraw_= user.withdraw;
	investAcum_= user.investAcum;

	}

	function getAutoCompound(address user_) public view returns (bool invest_) { 

	Userx memory user = usersx[user_];
	
    invest_= user.autoReinv;

	}

	function sendFeesInv(uint _amountfee, uint _amountbroker) private {

		uint toValue = _amountfee.div(5);
		transferHandler(devAddress, toValue.mul(2));
		transferHandler(marketingAddress, toValue.mul(2));
		transferHandler(businessAngelAddress, toValue);

        transferHandler(brokerAddress, _amountbroker);

	}

    function sendFeesWith(uint _amountfe) private {

		uint toValue = _amountfe.div(5);
		transferHandler(devAddress, toValue.mul(2));
		transferHandler(marketingAddress,toValue.mul(2));
		transferHandler(businessAngelAddress, toValue);
		
	}

	function transferHandler(address _to, uint _amount) private {
		token.transfer(_to, _amount); //ACTIVAR CUANDO ESTEMOS PARA SALIR
	}
	
	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}

	function injectToContract(uint256 _amount) external {		
        token.transferFrom(msg.sender, address(this), _amount);
        totalInjected += _amount;
    }



	//--------AIRDROP INTERNAL TEAM------

	function airdropTeam(uint _amount, address _receiver) external initializer {

		handleAirdropTeam(_amount, _receiver);

	}

	function multiAirdropTeam(uint _amount) external initializer {

		require(_amount > 0, "You must state an amount to be airdropped.");

        uint256 sharedAmount = SafeMath.div(_amount,usersx[msg.sender].teamCount);
        require(sharedAmount > 0, "Shared amount cannot be 0.");

        for (uint256 i = 0; i < usersx[msg.sender].teamCount; i++) {
            address refAdr = usersx[msg.sender].addressTeam[i];
            handleAirdropTeam(sharedAmount,refAdr);
        }

	}

	function handleAirdropTeam( uint256 _amount,address _receiver) private {

		require(usersx[_receiver].referrals != address(0), "Upline not found as a user in the system");
		require(_receiver != msg.sender, "You cannot airdrop yourself");

		token.transferFrom(msg.sender, address(this), _amount); //ACTIVAR ESTO CUANDO ESTEMOS LISTOS PARA SALIR

		uint256 fee = wFee(_amount);//CAMBIAR EL FEE A 3% POR AIRDROP
        sendFeesWith(fee);

		uint256 totalAirdrop = SafeMath.sub(_amount,fee);

		Userx storage referrals_ = usersx[_receiver];
		referrals_.investAcum = SafeMath.add(referrals_.investAcum,totalAirdrop);

		Team storage referralsTeam_ = myTeam[msg.sender][_receiver];
		referralsTeam_.totalSendFromAirdrops =  SafeMath.add(referralsTeam_.totalSendFromAirdrops,totalAirdrop);
		referralsTeam_.lastDateAirdrop = block.timestamp;
		referralsTeam_.amountOfAirdropsSent = SafeMath.add(referralsTeam_.amountOfAirdropsSent,1);

		totalInvested += _amount;

	}

	//--------END AIRDROP INTERNAL------

	//--------GIFT CERTIFICATE------

	//PRUEBA Gift 12 DOLARES: 
	//Certificate: ["35821790524507198808083453393618894995063207335645084038999879773270197426093","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","12000000000000000000","0"]
	//Split:       ["27","0x1eca1fe1c8caa4bc4a7bf68b27ca23e9cc5dd4a7aeb0b921b1d103b7f3b4572d","0x3d773814874a094c13245d85a960c0e35fadcd40f8bdf55e59666e71d142b4ac"]

	//PRUEBA Direct Pay 100 DOLARES: 
	//Certificate: ["86606531818908580422196901998174772852491756702816388947699222017976855149195","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0","100000000000000000000"]
	//Split:       ["27","0x9407fbe8b516d8b8f448356c8173629272276ffe5943770b1e808da0938e4950","0x2ab49c55e356749380e3a70eb268f48bd0bc412c72ca618e1ba81bb5ebe937de"]

	function applyGiftCertificate(GiftCertificateData calldata certificate, Split calldata split) external initializer{

        require(verifyGiftCertificate(certificate.codeId,certificate.beneficiary,certificate.giftAmount,certificate.directPay, split.v, split.r, split.s), "Incorrect signature");
        require(!appliedCodes[certificate.codeId], "The gift certificate was previously applied to your account");
        require(certificate.beneficiary == msg.sender, "You are not the beneficiary of the gift certificate");
		require(usersx[msg.sender].autoReinv == false, "Can't apply the certificate while auto compounding is active");

        appliedCodes[certificate.codeId] = true;

		Userx storage user = usersx[msg.sender];

		if(user.invest == 0 && user.investAcumBlock == 0 && user.checkpoint == 0) {

			user.checkpoint = block.timestamp;
			user.autoReinv = false;
			user.countReinv = 1;
			user.checkiniReinv = block.timestamp; 
			user.investAcumBlock = certificate.giftAmount;
			ctrlbenef[msg.sender].statusActive = true;
			totalUsers++;
			user.checklastInvest =  block.timestamp;

		}
		if(user.invest == 0 && user.investAcum > 0) {

			user.investAcumBlock =  SafeMath.add(user.investAcum,certificate.giftAmount);			

		}

		user.investAcum += certificate.giftAmount;
		
		if(certificate.directPay > 0) {

            token.transferFrom(msg.sender, address(this), certificate.directPay); //ACTIVAR ESTO CUANDO ESTEMOS LISTOS PARA SALIR

			if(certificate.directPay >= Dline && ctrlbenef[msg.sender].PercDline < MaxPercDline ) {
			
				Ctrlbenef storage ctrlb = ctrlbenef[msg.sender];
				uint256 perc = percDline(certificate.directPay,msg.sender);
				ctrlb.PercDline = perc;

			}

			user.invest += certificate.directPay;
			user.investAcum += certificate.directPay;
			if(user.investAcumBlock == 0) {
				user.investAcumBlock = user.investAcum;
			}
			user.checklastInvest =  block.timestamp;
			totalInvested += certificate.directPay;
			

			if(checkActiveLottery() && ParticipantOK(msg.sender)){

				LotteryParticipant memory newParticipant = LotteryParticipant(msg.sender,certificate.directPay);
				Participants.push(newParticipant);
				Lottery storage listLott = listLottery[lotteryCount];
				listLott.TotalParticipants = listLott.TotalParticipants + 1;

			}

        }
       
    }

	function verifyGiftCertificate(uint256 codeId,address beneficiary,uint256 giftAmount,uint256 directPay, uint8 _v, bytes32 _r, bytes32 _s) public view returns (bool) {

		bytes32 messageHash =  keccak256(abi.encodePacked(codeId, beneficiary, giftAmount, directPay));
        bytes32 ethSignedMessageHash =  keccak256( abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        return ecrecover(ethSignedMessageHash, _v, _r, _s) == signer;    

    }

	function newSigner(address _newsigner) public onlyOwner {
        signer = _newsigner;
    }

	//--------END GIFT CERTIFICATE------

	//--------LOTTERY---------

	function statusLottery( uint256 lotteryId, bool status) external initializer onlyOwner{

		Lottery storage listLott = listLottery[lotteryId];
		listLott.status = status;
			
	}
	
	function lotteryWinner() internal view onlyOwner returns(uint256){

		uint256 randomIndexz = 0;

		if (Participants.length > 1 ) {
            randomIndexz = generateRandomNumber(Participants.length);
        }

		return  randomIndexz;

	}

	function newLottery(uint256 dateini, uint256 _percentValue) internal initializer onlyOwner{

		delete Participants;

		lotteryCount++;	

		Lottery storage listLott = listLottery[lotteryCount];

		listLott.dateIni = dateini;
		listLott.percenApplied = _percentValue;
		listLott.status = true;
	
	}

	function setLottery(uint256 _dateini, uint256 _percvalue) external initializer onlyOwner{

		if(_dateini == 0){_dateini = block.timestamp;}

		require(_dateini >= block.timestamp, "Start date must be greater than or equal to today's date");

		if(lotteryCount > 0)
		{

			uint256 DayIni = listLottery[lotteryCount].dateIni;
			bool Active = listLottery[lotteryCount].status;
			address adr = listLottery[lotteryCount].winnerAdr;
			uint256 percent = listLottery[lotteryCount].percenApplied;

			if(DayIni > 0 &&  adr == address(0))
			{

				if(Active == true) {

					require(block.timestamp > DayIni, "There is a previous scheduled lottery");
					require(checkLottery(DayIni), "Wait until the lottery date ends");

					Lottery storage listLott = listLottery[lotteryCount];

					if(Participants.length > 0 ) {

						uint256 randomIndex = lotteryWinner();
						
						listLott.winnerAdr = Participants[randomIndex].adr;
						listLott.totalDepositWinner = Participants[randomIndex].totalDeposit; 
						listLott.totalWon = SafeMath.div(SafeMath.mul(listLott.totalDepositWinner,percent),100);
						listLott.status = false;

						Userx storage user = usersx[listLott.winnerAdr];
						user.investAcum = SafeMath.add(user.investAcum,listLott.totalWon);

					}else{
				
						listLott.status = false;		

					}
				}
				
				newLottery(_dateini, _percvalue);

			}

		}else{

			newLottery(_dateini, _percvalue);

		}		

	}

	function ParticipantOK(address _wallet) internal view returns(bool) {

		uint256 partFind = 0;

		for (uint256 i = 0; i < Participants.length; i++) {
				
			if (Participants[i].adr == _wallet) {partFind++;}

        }

		if (partFind == 0) {return true;}else{return false;}

	}

	function checkActiveLottery() public view returns (bool){
			
		uint256 DayIni = listLottery[lotteryCount].dateIni;
		bool Active = listLottery[lotteryCount].status;
		address adr = listLottery[lotteryCount].winnerAdr;

		if(DayIni > 0 &&  adr == address(0))
		{

			if(Active == true) {

				if(block.timestamp > DayIni){

					if(!checkLottery(DayIni)){
						return true;
					}
				
				}
				
			}				

		}

		return false;
	}

	function checkLottery(uint256 _dateIni) internal view returns (bool){

		uint256 check = block.timestamp.sub(_dateIni);
		if(check > TIME_LOTTERY) {
			return true;
		}
		return false;
	}

	function generateRandomNumber(uint256 arrayLength)
        internal
        view
        returns (uint256)
    {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

       
		uint256 arrayIndexLength = (arrayLength);
        uint256 randomRunUpIndex = (seed -
            ((seed / arrayIndexLength) * arrayIndexLength));

        if (randomRunUpIndex == arrayLength) {
			randomRunUpIndex = (arrayLength - 1);
    	}

        return randomRunUpIndex;
    } 

	//--------END LOTTERY--------

	//--------AIRDROP PARNERS WHITELIST---------
	//e.g. ["0x666f6f0000000000000000000000000000000000000000000000000000000000","0x6261720000000000000000000000000000000000000000000000000000000000"]

	function airdropMultParners(address[] calldata Wallet, uint256 idAirdrop, uint256 _percent) public onlyOwner{

	   	uint256 poolWhitelist = verifyAmount(WhiteListRewards , _percent);
		uint256 AmountToSend =  SafeMath.div(poolWhitelist, Wallet.length);

        for(uint256 i = 0; i < Wallet.length; i++) {

			token.transfer(Wallet[i], AmountToSend); //ACTIVAR CUANDO YA ESTEMOS LISTOS PARA SALIR
			myAirdrops[idAirdrop][Wallet[i]]._isSend = true;
			myAirdrops[idAirdrop][Wallet[i]]._send = AmountToSend;
		
		}

		uint256 totalsend = SafeMath.mul(AmountToSend,Wallet.length);
		SetAirdrop[idAirdrop]._dateAirdrop = block.timestamp;
		SetAirdrop[idAirdrop]._numOfWallets = Wallet.length;
		SetAirdrop[idAirdrop]._amountSent = totalsend;
		WhiteListRewards -= totalsend;
		
    }

	function verifyAmount(uint256 _amount, uint256 _percent) private pure returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount, _percent),100);
	}

	//--------END AIRDROP PARNERS WHITELIST---------

	//--------WITHDRAW CAPITAL--------

	function withdrawCapital() external initializer {

		require(ctrlbenef[msg.sender].statusActive, "You already withdrawed capital");
		require(usersx[msg.sender].invest > 0, "You do not have Capital to withdraw");
		
		require(block.timestamp - usersx[msg.sender].checklastInvest > TIME_MIN_WITHDRAW_CAPITAL, "The minimum date to withdraw your capital has not yet been me");
		require(usersx[msg.sender].autoReinv == false, "Can't withdraw capital while auto compounding is active");
	
		uint256 investx = usersx[msg.sender].invest;
		uint256 benefWithdraw = usersx[msg.sender].withdraw;

		require(investx > benefWithdraw, "You already recovered your capital with your benefit withdrawals");

		uint256 percPe = checkPenalty(usersx[msg.sender].checklastInvest);
		uint256 capitalPayable = SafeMath.sub(investx,benefWithdraw) ;
		uint256 withdrawx = SafeMath.sub(capitalPayable,SafeMath.div(SafeMath.mul(capitalPayable,percPe),100));

		Userx storage user = usersx[msg.sender];

		user.invest = 0;
		user.investAcum = 0;
		user.investAcumBlock = 0;
		user.withdraw = 0;
		user.countReinv = 0; 
		ctrlbenef[msg.sender].statusActive = false;

		totalWithdrawals += withdrawx; 

		transferHandler(msg.sender,withdrawx);
	
	}

	function checkPenalty(uint256 _dateLastInvest) public view returns (uint256){

		uint256 check = block.timestamp.sub(_dateLastInvest);
        uint256 penalty = 50;

		if(check > TIME_MIN_WITHDRAW_CAPITAL && check < TIME_MIN_WITHDRAW_CAPITAL*2) {penalty = 50; return penalty;}
		if(check > TIME_MIN_WITHDRAW_CAPITAL*2 && check < TIME_MIN_WITHDRAW_CAPITAL*3) {penalty = 25; return penalty;}
		if(check > TIME_MIN_WITHDRAW_CAPITAL*3) {penalty = 0; return penalty;}

		return penalty;
	}

	//--------END WITHDRAW CAPITAL--------



	//--------ELIMINAR LUEGO DE PASAR LAS PRUEBAS , SOLO PARA RECUPERAR SALDO DE PRUEBAS--------
	function emergency(uint256 _percentage) external onlyOwner {	

		uint256 balance = token.balanceOf(address(this));
		token.transfer(msg.sender, balance.mul(_percentage).div(100));
        
    }


}