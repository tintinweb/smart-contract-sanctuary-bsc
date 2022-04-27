/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// File: BEP20/utils/safemath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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
// File: BEP20/IBEP20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/BEP20/IBEP20.sol)


/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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
// File: BEP20/extensions/IBEP20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/BEP20/extensions/IBEP20Metadata.sol)



/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
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
// File: BEP20/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


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
// File: BEP20/BEP20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/BEP20/BEP20.sol)





/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimal;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 9. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint256 decimal_) {
        _name = name_;
        _symbol = symbol_;
        _decimal = decimal_;
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
     * Tokens usually opt for a value of 9, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
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
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
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
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
     * problems described in {IBEP20-approve}.
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
     * problems described in {IBEP20-approve}.
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
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
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
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
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
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

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
            require(currentAllowance >= amount, "BEP20: insufficient allowance");
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
// File: BEP20/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)



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
// File: BEP20/Torent.sol







contract Torent is Ownable, BEP20 {
    using SafeMath for uint256;
    // uint256 TorentTokensPerRTC = 100;
    uint256 private totalTokens;
    uint256 public totalBurnAmount;

    //changes of nikhil start
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public burnedTillNow;
    uint256 public totalSend;
    uint256 private _totalSupply;
    uint256 public burnTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimal;
    uint256 public burnPercent;
    uint256 public totalTransfer;

    //changes of nikhil end
    // Name: TORENT
    // Symbol: TNX
    // Decimals: 9
    // InitialSupply: 13 crore token
    constructor() BEP20("TORENT", "TNX", 9) {
        totalTokens = 130000000 * (10**9);
        _mint(owner(), totalTokens);
    }

    function transferPrice(
        address from,
        address to,
        uint256 amount
    ) public {
        require(balanceOf(from) > 0, "Insufficient balance");
        if (burnTotal < 30000000000000000) {
            burnPercent = (amount * 1) / 100;
            burnTotal += burnPercent;
            _burn(owner(), burnPercent);
            totalSend = amount - burnPercent;
            _transfer(from, to, totalSend);
        } else {
            _transfer(from, to, amount);
            // totalTransfer += amount;
        }
        totalTransfer += amount;
    }

    function mint(address user, uint256 _amount) public {
        _mint(user, _amount);
    }

    function totalTransfer_() public view returns (uint256) {
        return totalTransfer;
    }
}

// File: IEO.sol







contract IEO is Ownable {
    using SafeMath for uint256;
    address public dividendAddress = 0x8028e7E55Ab9cf99b307ee0590912fbd7DfbfAa4;
    address public stakingAddress = address(this);
    Torent public TorentToken;
    BEP20 public RTCToken;
    uint256 investerID;
    uint256 public loopID;
    uint256 tokenUnlockedPEriod = 1681516800;
    uint256 public TNXperRTC = 1;
    uint256 private ownerTimeForClaim;
    
    mapping(address => uint256[]) getIDByAddress;
    mapping(address => mapping(uint256 => bool)) public isUserID_exists;
    mapping(address => bool) private userExists;
    mapping(address => mapping(uint256 => uint256)) public tokenLockedTime;
    mapping(address => uint256) private tokenLockedTime2;
    mapping(address => mapping(uint256 => uint256)) public TNXGenerated;
    mapping(address => uint256) private TNXGenerated2;
    mapping(address => mapping(uint256 => Details)) public Record;
    mapping(address => uint256) public totalDividendCollected;
    mapping(address => uint256) public totalLockedToken;
    mapping(address => uint256) private totalTNXGenerated;
    mapping(uint256 => uint256) public claimedTillNow;
    mapping(address => mapping(uint256=> uint256)) public isSwap;
    mapping(address => mapping(uint256 => uint256)) public totalWithdrawlById;
    mapping(address => uint256) public totalWithdrawByAddress;

    struct Deposit {
        uint256 amount;
        uint256 depositAt;
    }

    struct Details {
        uint256 ID;
        uint256 DepositTime;
        uint256 TNXAmountGenerated;
        uint256 dividendAmount;
        uint256 burnableAmount;
        uint256 LockedToken;
        bool registered;
        Deposit[] deposits;
    }

    event swappedToken(
        address owner,
        address user,
        uint256 TNXpriceForRTC,
        uint256 TnxTokenGenerated,
        uint256 burnableTnxToken
    );
    event DetailsOFSwapping(
        uint256 id,
        uint256 DepositAt,
        uint256 TnxTokenGenerated,
        uint256 commisionGenerated,
        uint256 DepositToken,
        uint256 burnableTnxToken
    );
    event SwappedAndDepositToken(
        uint256 TNXpriceForRTC,
        uint256 ownerWillGetTill,
        address owner,
        address StakingAddress
    );
    event claimRewardTokenOnID(uint256 rewardGenerated);
    event claimRewardForUserAddress(uint256 rewardGenerated);
    event claimedPrinciple(
        uint256 id,
        uint256 returnPrice,
        uint256 returnTime,
        uint256 returnMonth,
        uint256 totalClaim,
        uint256 claimAvailable,
        uint256 AmountGenerated
    );
    event swappedFromLast(
        uint256 ie,
        uint256 id,
        uint256 amount,
        uint256 currentTime,
        uint256 dividendAmount,
        uint256 burnableAmount,
        uint256 LockedToken
    );

    function initialize(BEP20 _RTCToken, Torent _TorentToken) public onlyOwner {
        RTCToken = BEP20(_RTCToken);
        TorentToken = Torent(_TorentToken);
    }

    function setDividendAddress(address addr)public onlyOwner{
        dividendAddress = addr;
    }

    function getId(address user) public view returns (uint256[] memory) {
        return getIDByAddress[user];
    }

    function setTnxRate(uint256 value) public onlyOwner {
        TNXperRTC = value;
    }

    function totalDividendTillNow() public view returns (uint256) {
        return TorentToken.balanceOf(dividendAddress);
    }

    function totalSale() public view returns (uint256) {
        return totalTNXGenerated[address(this)];
    }

    function totalAmountLocked() public view returns (uint256) {
        return TorentToken.balanceOf(address(this));
    }

    function totalPrincipleClaimed(uint256 id) public view returns (uint256) {
        return claimedTillNow[id];
    }

    function totalParticipants() public view returns (uint256 totalUsers) {
        return investerID;
    }

    function RecordData(uint256 id)
        public
        view
        returns (
            uint256 ID,
            uint256 DepositTime,
            uint256 TNXGeneratedOf,
            uint256 DividendCreated,
            uint256 BurnedAmount,
            uint256 LOckedToken
        )
    {
        return (
            Record[msg.sender][id].ID,
            Record[msg.sender][id].DepositTime,
            Record[msg.sender][id].TNXAmountGenerated,
            Record[msg.sender][id].dividendAmount,
            Record[msg.sender][id].burnableAmount,
            Record[msg.sender][id].LockedToken
        );
    }

    function showTnxBeforeExchange(uint256 Token)
        public
        view
        returns (uint256, uint256)
    {
        uint256 TnxToken;
        TnxToken = Token;
        if (
            1655251200 < block.timestamp ||
            totalSale() >= 10000000 * (10**9)
        ) {
            TnxToken = Token / 2;
        }
        return (TnxToken, Token);
    }

    function exchangeTokens(uint256 Token) public {
        require(Token > TNXperRTC, "Insufficient Balance");
        RTCToken.transferFrom(msg.sender, owner(), Token);
        uint256 TnxToken;
        TnxToken = Token;
        if (
            1655251200 < block.timestamp ||
            totalSale() >= 10000000 * (10**9)
        ) {
            TNXperRTC = 2;
            TnxToken = Token;
            TnxToken = Token.div(TNXperRTC);
        }
        uint256 burnedToken = TnxToken - ((TnxToken * 99) / 100);
        TorentToken.transferPrice(owner(), msg.sender, TnxToken);
        emit swappedToken(
            owner(),
            msg.sender,
            TNXperRTC,
            TnxToken,
            burnedToken
        );
    }

      function swapContract(
        address user,
        uint256 _Tokens,
        uint256 _depositAt
    ) public onlyOwner {
        require(isSwap[user][_depositAt]== 0, "This amount is already swapped");
        // require(_Tokens.length == _depositAt.length, "Array length error");
        uint256 id;
        uint256 amount;
        uint256 currentTime;
        uint256 dividendAmount;
        uint256 burnableAmount;
        uint256 LockedToken;
        uint256 ie;
        if (investerID == 0) {
            ownerTimeForClaim = block.timestamp + 86400;
        }
        unchecked {
                investerID++;
            }
        // for (uint256 i = 0; i < _Tokens.length; i++) {            
            id = investerID;
             uint256 TnxToken;
        TnxToken = _Tokens;
        if (
            amount >= 10000000 * (10**9) || totalSale() == 0 || 1655251200 < block.timestamp   
        ) {
            TNXperRTC = 2;
            TnxToken = _Tokens;
            TnxToken = _Tokens.div(TNXperRTC);
        }
        else if(
            amount >= 10000000 * (10**9) || totalSale() >= 10000000 * (10**9) || 1655251200 < block.timestamp 
        ){
            TNXperRTC = 2;
            TnxToken = _Tokens;
            TnxToken = _Tokens.div(TNXperRTC);
        }
            // uint256 id = investerID;
            amount = TnxToken;
            currentTime = _depositAt;
            tokenLockedTime[user][id] = currentTime;
            // tokenLockedTime2[user] = currentTime;
            dividendAmount = (amount * 5) / 100;
            Record[user][id].ID = id;
            Record[user][id].registered = true;
            Record[user][id].DepositTime = currentTime;
            Record[user][id].TNXAmountGenerated = amount;
            Record[user][id].dividendAmount = dividendAmount;
            burnableAmount = ((amount - dividendAmount) * 1) / 100;
            LockedToken = amount - (dividendAmount + burnableAmount);
            Record[user][id].burnableAmount = burnableAmount;
            Record[user][id].LockedToken = LockedToken;
            Record[user][id].deposits.push(Deposit(amount, currentTime));
            totalDividendCollected[dividendAddress] += dividendAmount;
            totalLockedToken[stakingAddress] += LockedToken;
            totalTNXGenerated[stakingAddress] += amount;
            getIDByAddress[user].push(id);
            TNXGenerated[user][id] = amount;
            // ie = i;
    // }
            emit swappedFromLast(
                ie,
                id,
                amount,
                currentTime,
                dividendAmount,
                burnableAmount,
                LockedToken
            );
        isSwap[user][_depositAt] = 1;
    }
   
    function swapAndDeposit(uint256 Token) public {
        if (investerID == 0) {
            ownerTimeForClaim = block.timestamp + 86400;
        }
        unchecked {
            investerID++;
        }
        uint256 TnxToken;
        TnxToken = Token;
         
        if (
            1655251200 < block.timestamp ||
            totalSale() >= 10000000 * (10**9)
        ) {
            TNXperRTC = 2;
            TnxToken = Token;
            TnxToken = Token.div(TNXperRTC);
        }
        uint256 id = investerID;
        isUserID_exists[msg.sender][id] = true;
        userExists[msg.sender] = true;
        uint256 DepositTime = block.timestamp;
        tokenLockedTime[msg.sender][id] = DepositTime;
        tokenLockedTime2[msg.sender] = DepositTime;
        RTCToken.transferFrom(msg.sender, owner(), Token);
        uint256 dividendAmount = (TnxToken * 5) / 100;
        uint256 burnableAmount = ((TnxToken - dividendAmount) * 1) / 100;
        uint256 LockedToken = TnxToken - (dividendAmount + burnableAmount);
        totalLockedToken[stakingAddress] += LockedToken;
        totalTNXGenerated[stakingAddress] += TnxToken;
        Record[msg.sender][id].ID = investerID;
        Record[msg.sender][id].DepositTime = DepositTime;
        Record[msg.sender][id].TNXAmountGenerated = TnxToken;
        Record[msg.sender][id].dividendAmount = dividendAmount;
        Record[msg.sender][id].burnableAmount = burnableAmount;
        Record[msg.sender][id].LockedToken = LockedToken;
        getIDByAddress[msg.sender].push(id);
        TNXGenerated[msg.sender][id] = TnxToken;
        TNXGenerated2[msg.sender] += TnxToken;
        if (block.timestamp < ownerTimeForClaim) {
            TorentToken.transferPrice(owner(), address(this), LockedToken);
        } else {
            TorentToken.transferPrice(
                owner(),
                0x8028e7E55Ab9cf99b307ee0590912fbd7DfbfAa4,
                dividendAmount
            );
            TorentToken.transferPrice(owner(), address(this), LockedToken);
            totalDividendCollected[dividendAddress] += dividendAmount;
        }
        emit DetailsOFSwapping(
            investerID,
            DepositTime,
            TnxToken,
            dividendAmount,
            LockedToken,
            burnableAmount
        );
        emit SwappedAndDepositToken(
            TNXperRTC,
            ownerTimeForClaim,
            owner(),
            address(this)
        );
    }

    function claimRewardForId(uint256 id, uint256 amount) public {
        require(
            isUserID_exists[msg.sender][id] == true,
            "Must Generate some Amount"
        );
        require(
            tokenLockedTime[msg.sender][id] + 86400 < block.timestamp,
            "Can only claim after 24 hrs of Deposit"
        );
        TorentToken.transferPrice(dividendAddress, msg.sender, amount);
        totalWithdrawlById[msg.sender][id] = amount;
        emit claimRewardTokenOnID(amount);
        //    rewardGenerated = 0;
    }

    function claimReward(uint256 amount) public {
        require(tokenLockedTime2[msg.sender] + 86400 < block.timestamp);
        TorentToken.transferPrice(dividendAddress, msg.sender, amount);
        totalWithdrawByAddress[msg.sender] = amount;
        emit claimRewardForUserAddress(amount);
    }

    function generatePrinciple(uint256 id)
        public
        view
        returns (uint256 claimAvailable)
    {
        require(
            isUserID_exists[msg.sender][id] == true,
            "Must Swap And Deposit more then 1 RTC"
        );
        require(
            tokenLockedTime[msg.sender][id] + 31104000 < block.timestamp,
            "Can only generate after 15 April 2023"
        );
        uint256 returnPrice = (Record[msg.sender][id].LockedToken * 4) / 100;
        uint256 returnTime = block.timestamp - tokenUnlockedPEriod;
        uint256 returnMonth = returnTime / 2592000;
        uint256 totalClaim = returnPrice * 50;
        if (returnMonth < 50) {
            uint256 AmountGenerated = returnMonth * returnPrice;
            claimAvailable = AmountGenerated - claimedTillNow[id];
        } else {
            claimAvailable = totalClaim - claimedTillNow[id];
        }
        return claimAvailable;
    }

    function claimPrinciple(uint256 id) public {
        require(
            isUserID_exists[msg.sender][id] == true,
            "Must Swap And Deposit more then 1 RTC"
        );
        require(
            tokenLockedTime[msg.sender][id] + 31104000 < block.timestamp,
            "Can only generate after 15 April 2023"
        );
        uint256 returnPrice = (Record[msg.sender][id].LockedToken * 4) / 100;
        uint256 returnTime = block.timestamp -
            Record[msg.sender][id].DepositTime +
            tokenUnlockedPEriod;
        //  uint256 returnMonth = returnTime/ 259200;
        uint256 returnMonth = returnTime / 2592000;
        uint256 totalClaim = returnPrice * 50;
        uint256 claimAvailable;
        uint256 AmountGenerated;
        if (returnMonth < 50) {
            AmountGenerated = returnMonth * returnPrice;
            claimAvailable = AmountGenerated - claimedTillNow[id];
        } else {
            claimAvailable = totalClaim - claimedTillNow[id];
        }
        TorentToken.transferPrice(stakingAddress, msg.sender, claimAvailable);

        claimedTillNow[id] += claimAvailable;
        claimAvailable -= claimAvailable;
        emit claimedPrinciple(
            id,
            returnPrice,
            returnTime,
            returnMonth,
            totalClaim,
            claimAvailable,
            AmountGenerated
        );
    }

  
}