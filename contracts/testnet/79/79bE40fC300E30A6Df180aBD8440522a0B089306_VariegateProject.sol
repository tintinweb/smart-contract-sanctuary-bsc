/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity ^0.8.11;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;
    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);
    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function abs(int256 a) internal pure returns (int256) {
    require(a != MIN_INT256);
    return a < 0 ? -a : a;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {
    require(a >= 0);
    return uint256(a);
  }
}
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
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
contract RewardsTracker is Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 public totalBalance = 0;
  uint256 public totalDistributed = 0;
  uint256 internal magnifiedBalance;
  uint256 constant internal MAGNIFIER = 2**128;

  mapping(address => uint256) public balanceOf;
  mapping(address => int256) internal magnifiedCorrections;
  mapping(address => uint256) internal withdrawnRewards;

  event FundsDeposited(address indexed from, uint amount);
  event FundsWithdrawn(address indexed account, uint amount);

  constructor() { }

  receive() external payable {
    require(msg.value > 0, "No funds sent");
    require(totalBalance > 0, "No balances tracked");

    distributeFunds(msg.value);
    emit FundsDeposited(msg.sender, msg.value);
  }

  function getAccumulated(address account) public view returns(uint256) {
    return magnifiedBalance.mul(balanceOf[account]).toInt256Safe().add(magnifiedCorrections[account]).toUint256Safe() / MAGNIFIER;
  }

  function getPending(address account) public view returns(uint256) {
    return getAccumulated(account).sub(withdrawnRewards[account]);
  }

  function getWithdrawn(address account) external view returns(uint256) {
    return withdrawnRewards[account];
  }

  function putBalance(address account, uint256 newBalance) public virtual onlyOwner {
    updateBalance(account, newBalance);
  }

  function withdrawFunds(address payable account) public virtual {
    uint256 amount = processWithdraw(account);
    if (amount > 0) emit FundsWithdrawn(account, amount);
  }

  // PRIVATE

  function decreaseBalance(address account, uint256 amount) internal {
    magnifiedCorrections[account] = magnifiedCorrections[account].add((magnifiedBalance.mul(amount)).toInt256Safe());
  }

  function distributeFunds(uint256 amount) internal virtual {
    if (totalBalance > 0 && amount > 0) {
      magnifiedBalance = magnifiedBalance.add((amount).mul(MAGNIFIER) / totalBalance);
      totalDistributed = totalDistributed.add(amount);
    }
  }

  function increaseBalance(address account, uint256 amount) internal {
    magnifiedCorrections[account] = magnifiedCorrections[account].sub((magnifiedBalance.mul(amount)).toInt256Safe());
  }

  function processWithdraw(address payable account) internal returns (uint256) {
    uint256 amount = getPending(account);
    if (amount <= 0) return 0;
    withdrawnRewards[account] = withdrawnRewards[account].add(amount);

    if (sendReward(account, amount)) return amount;

    withdrawnRewards[account] = withdrawnRewards[account].sub(amount);
    return 0;
  }

  function sendReward(address payable account, uint256 amount) internal virtual returns (bool) {
    (bool success,) = account.call{value: amount, gas: 3000}("");
    return success;
  }

  function updateBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf[account];
    balanceOf[account] = newBalance;
    if (newBalance > currentBalance) {
      uint256 increaseAmount = newBalance.sub(currentBalance);
      increaseBalance(account, increaseAmount);
      totalBalance += increaseAmount;
    } else if(newBalance < currentBalance) {
      uint256 reduceAmount = currentBalance.sub(newBalance);
      decreaseBalance(account, reduceAmount);
      totalBalance -= reduceAmount;
    }
  }
}
contract VariegateProject is RewardsTracker {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  uint256 public constant MIN_BALANCE = 250_000 ether; // TOKENS REQ FOR DIVIDENDS
  uint256 public paybackBNB = 0;
  uint256 public funds = 0;

  address payable public variegate;

  struct Holder {
    uint256 index;
    uint256 dollars;
  }

  mapping (address => Holder) public holder;
  mapping (uint256 => address) public holderAt;
  uint256 public holders = 0;

  event FundsApproved(address to, uint256 amount);

  constructor() RewardsTracker() { }

  modifier onlyAdmin() {
    require(isAdmin(_msgSender()), "Caller invalid");
    _;
  }

  function getReport() public view returns (uint256 holderCount, uint256 totalDollars, uint256 totalBNB) {
    holderCount = holders;
    totalDollars = totalBalance;
    totalBNB = totalDistributed;
  }

  function getReportAccount(address key) public view returns (address account, uint256 index, uint256 dollars, uint256 depositedBNB, uint256 withdrawnBNB) {
    account = key;
    index = holder[account].index;
    dollars = balanceOf[account];
    depositedBNB = getAccumulated(account);
    withdrawnBNB = withdrawnRewards[account];
  }

  function getReportAccountAt(uint256 indexOf) public view returns (address account, uint256 index, uint256 dollars, uint256 depositedBNB, uint256 withdrawnBNB) {
    require(indexOf > 0 && indexOf <= holders, "Value invalid");

    return getReportAccount(holderAt[indexOf]);
  }

  function requestFunds(address to, uint256 amount) external onlyAdmin {
    require(funds > amount, "Overdraft");

    if (!isConfirmed(2)) return;

    funds -= amount;
    (bool success,) = payable(to).call{ value: amount, gas: 3000 }("");
    if (success) {
      emit FundsApproved(to, amount);
    } else {
      funds += amount;
    }
  }

  function setHolders(address[] memory accounts, uint256[] memory dollars) external onlyAdmin { // REWARDS TRACKER REQUIRES OWNER
    require(totalBalance==0, "Already set.");
    require(accounts.length<100, "100 accounts max");

    for (uint256 idx=0;idx<accounts.length;idx++) setHolder(accounts[idx], dollars[idx]);

    paybackBNB = (totalBalance * 1 ether).div(333); // FOR EACH $1K RETURN 3 BNB - ADJUST BNB PRICE AT LAUNCH
  }

  function withdrawFunds(address payable account) public override {
    verifyMinimumBalances();
    super.withdrawFunds(account);
  }

  // PRIVATE

  function _transferOwnership(address newOwner) internal override {
    super._transferOwnership(newOwner);
    if (isContract(newOwner)) variegate = payable(newOwner);
  }

  function confirmCall(uint256 required, address account, bytes4 method, bytes calldata args) private returns (bool) {
    return required < 2 || !isContract(owner()) || Variegate(variegate).confirmCall(required, account, method, args);
  }

  function distributeFunds(uint256 amount) internal override {
    if (totalDistributed >= paybackBNB) { // PAID IN FULL, NO MORE DISTRIBUTIONS
      funds += amount;
      return;
    }
    uint256 split = amount.div(10); // 20% of Fees go to pay start up costs
    funds += amount.sub(split);
    super.distributeFunds(split);
  }

  function isAdmin(address account) private view returns(bool) {
    return (!isContract(owner()) && account==owner()) || (isContract(owner()) && Variegate(variegate).isAdmin(account));
  }

  function isConfirmed(uint256 required) private returns (bool) {
    return required < 2 || !isContract(owner()) || Variegate(variegate).confirmCall(required, msg.sender, msg.sig, msg.data);
  }

  function isContract(address key) private view returns (bool) {
    return key.code.length > 0;
  }

  function setHolder(address account, uint256 dollars) internal {
    updateBalance(account, dollars);
    if (holder[account].index==0) {
      holders++;
      holderAt[holders] = account;
      holder[account].index = holders;
    }
    holder[account].dollars = dollars;
  }

  function verifyMinimumBalances() internal {
    if (!isContract(owner())) return;

    for (uint idx; idx<holders; idx++) {
      address account = holderAt[idx];
      uint256 balance = IERC20(owner()).balanceOf(account);

      if (balanceOf[account] > 0 && balance < MIN_BALANCE) {
        updateBalance(account, 0);
      } else if (balanceOf[account]==0 && balance >= MIN_BALANCE) {
        updateBalance(account, holder[account].dollars); // RESTORE ORIGINAL SHARE
      }
    }
  }
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
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
}
contract VariegateRewards is RewardsTracker {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  IUniswapV2Router02 public immutable uniswapV2Router;
  address payable public variegate;

  struct Holder {
    uint256 index;
    uint256 balance;
    uint32 percent;
    uint32 added;
    uint32 excluded;
    uint32 bought;
    uint32 sold;
    uint32 claimed;
  }

  uint256 public holders = 0;
  uint256 public currentHolder = 0;
  mapping (uint256 => address) public holderAt;
  mapping (address => Holder) public holder;

  struct Token {
    address token;
    uint256 index;
    uint256 added;     // date added
    uint256 claims;   // # of claims processed
    uint256 balance; // total tokens distributed
    uint256 amount; // total BNB of tokens distributed
  }

  uint256 public tokens = 0;
  mapping (uint256 => address) public tokenAt;
  mapping (address => Token) public token;

  uint256 public constant MAX_SLOTS = 10;
  uint256 public slots = 0;
  uint256 public offset = 0;
  mapping (uint256 => address) public tokenInSlot;

  uint256 public minimumBalance = 500_000 ether;
  uint256 public waitingPeriod = 6 hours;
  bool public isStakingOn = false;
  uint256 public totalTracked = 0;

  event ClaimsProcessed(uint256 iterations, uint256 claims, uint256 lastRecord, uint256 gasUsed);
  event ExcludedChanged(address indexed account, bool excluded);
  event MinimumBalanceChanged(uint256 from, uint256 to);
  event StakingChanged(bool from, bool to);
  event WaitingPeriodChanged(uint256 from, uint256 to);
  event TokenAdded(address indexed token, string name);
  event TokenDeleted(address indexed token, string name);
  event SlotSet(uint256 slot, address indexed token, string name);

  constructor() RewardsTracker() {
    // address ROUTER_PCSV2_MAINNET = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address ROUTER_PCSV2_TESTNET = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address ROUTER_FAKEPCS_TESTNET = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 router = IUniswapV2Router02(ROUTER_FAKEPCS_TESTNET);
    uniswapV2Router = router;
    holder[owner()].excluded = stamp();
  }

  modifier onlyAdmin() { // CALL COMES FROM OWNER OR PROJECT ADMIN
    require(isAdmin(_msgSender()), "Caller invalid");
    _;
  }

  function addToken(address key) external onlyAdmin {
    require(isContract(key), "Not a contract");
    require(token[key].added==0, "Token exists");

    token[key].token = key;
    token[key].added = stamp();
    tokens++;
    tokenAt[tokens] = key;
    token[key].index = tokens;
    emit TokenAdded(key, ERC20(key).name());
  }

  function currentSlot() public view returns (uint256) {
    if (slots==0) return 0;
    uint256 since = block.timestamp / (24 * 60 * 60) + offset;
    return (since % slots) + 1;
  }

  function deleteSlot(uint256 slot) external onlyAdmin {
    require(slot>0 && slot <= slots, "Value invalid");

    for (uint256 idx=slot; idx<slots; idx++) {
      tokenInSlot[idx] = tokenInSlot[idx+1];
    }
    delete tokenInSlot[slots];
    slots--;
  }

  function deleteToken(address remove) external onlyAdmin { // REMOVES TRACKING DATA
    require(token[remove].added > 0, "Token not found");

    token[tokenAt[tokens]].index = token[remove].index; // LAST TOKEN TAKES THIS ONES PLACE
    tokenAt[token[remove].index] = tokenAt[tokens]; // LAST TOKEN TAKES THIS ONES PLACE
    delete tokenAt[tokens];
    delete token[remove];
    tokens--;
    emit TokenDeleted(remove, ERC20(remove).name());
  }

  function getReport() external view returns (uint256 holderCount, bool stakingOn, uint256 totalTokensTracked, uint256 totalTokensStaked, uint256 totalRewardsPaid, uint256 requiredBalance, uint256 waitPeriodSeconds) {
    holderCount = holders;
    stakingOn = isStakingOn;
    totalTokensTracked = totalTracked;
    totalTokensStaked = totalBalance;
    totalRewardsPaid = totalDistributed;
    requiredBalance = minimumBalance;
    waitPeriodSeconds = waitingPeriod;
  }

  function getReportAccount(address key) public view returns (address account, uint256 index, uint256 balance, uint256 stakedPercent, uint256 stakedTokens, uint256 rewardsEarned, uint256 rewardsClaimed, uint256 claimHours) {
    require(holder[key].added > 0, "Value invalid");

    account = key;
    index = holder[account].index;
    balance = holder[account].balance;
    stakedPercent = holder[account].percent;
    stakedTokens = balanceOf[account];
    rewardsEarned = getAccumulated(account);
    rewardsClaimed = withdrawnRewards[account];
    claimHours = ageInHours(holder[account].claimed);
  }

  function getReportAccountAt(uint256 indexOf) public view returns (address account, uint256 index, uint256 balance, uint256 stakedPercent, uint256 stakedTokens, uint256 rewardsEarned, uint256 rewardsClaimed, uint256 claimHours) {
    require(indexOf > 0 && indexOf <= holders, "Value invalid");

    return getReportAccount(holderAt[indexOf]);
  }

  function getReportToken(address key) public view returns (string memory name, string memory symbol, address tokenAddress, uint256 claims, uint256 balance, uint256 amount) {
    require(token[key].added > 0, "Token not found");

    ERC20 reward = ERC20(key);
    name = reward.name();
    symbol = reward.symbol();
    tokenAddress = key;
    claims = token[key].claims;
    balance = token[key].balance;
    amount = token[key].amount;
  }

  function getReportTokenInSlot(uint256 slot) external view returns (string memory name, string memory symbol, address tokenAddress, uint256 claims, uint256 balance, uint256 amount) {
    require(slots > 0 && slot>=0 && slot <= slots, "Value invalid");

    if (slot==0) slot = currentSlot();

    return getReportToken(tokenInSlot[slot]);
  }

  function getTokens() external view returns (string[] memory) {
    string[] memory data = new string[](tokens);
    for (uint256 idx=1; idx<=slots; idx++) {
      data[idx-1] = ERC20(tokenInSlot[idx]).name();
    }
    return data;
  }

  function processClaims(uint256 gas) external {
    if (holders==0) return;

    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();
    uint256 iterations = 0;
    uint256 claims = 0;

    while (gasUsed < gas && iterations < holders) {
      bool worthy = (address(this).balance > (1 ether / 10)); // ENOUGH FUNDS TO WARRANT PUSHING?
      // IF WORTHY 1 LOOP COST MAX ~65_000 GAS, UNWORTHY MAX ~8_500 GAS
      if (gasLeft < (worthy ? 65_000 : 8_500)) break; // EXIT IF NOT ENOUGH TO PROCESS THIS ITERATION TO AVOID OOG ERROR

      currentHolder = (currentHolder % holders) + 1;
      address account = holderAt[currentHolder];
      updatedWeightedBalance(account);
      if (worthy && pushFunds(account)) claims++;
      iterations++;
      uint256 newGasLeft = gasleft();
      if (gasLeft > newGasLeft) gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
      gasLeft = newGasLeft;
    }

    emit ClaimsProcessed(iterations, claims, currentHolder, gasUsed);
  }

  function setExcluded(address account, bool setting) external onlyAdmin {
    require(setting && holder[account].excluded==0 || !setting && holder[account].excluded!=0, "Value unchanged");

    if (!isConfirmed(2)) return;

    holder[account].excluded = setting ? 0 : stamp();
    setBalance(account, holder[account].balance);
    emit ExcludedChanged(account, true);
  }

  function setCurrentSlot(uint256 slot) external onlyAdmin {
    require(slot>0 && slot <= slots, "Value invalid");
    offset = 0;
    offset = (slots + slot - currentSlot()) % 7;
  }

  function setMinimumBalance(uint256 newBalance) external onlyAdmin {
    require(newBalance >= 100_000 && newBalance <= 500_000, "Value invalid");
    newBalance = (newBalance * 1 ether);
    require(newBalance != minimumBalance, "Value unchanged");
    require(minimumBalance > newBalance, "Value cannot increase");

    if (!isConfirmed(2)) return;

    emit MinimumBalanceChanged(minimumBalance, newBalance);
    minimumBalance = newBalance;
  }

  function setSlot(uint256 slot, address key) public onlyAdmin {
    require(slot>=0 && slot <= slots, "Value invalid");
    require(slot>0 || slots < MAX_SLOTS, "All slots filled");
    require(token[key].added>0, "Token not found");

    if (slot==0) {
      slots++;
      slot = slots;
    }
    tokenInSlot[slot] = key;
    emit SlotSet(slot, key, ERC20(key).name());
  }

  function setSlots(address[] memory keys) external onlyAdmin {
    require(keys.length > 0 && keys.length < MAX_SLOTS, "Too many values");
    for (uint256 idx=0; idx<keys.length; idx++) require(token[keys[idx]].added>0, "Token not found");

    for (uint256 idx=1; idx<=slots; idx++) delete tokenInSlot[idx];
    slots = 0;
    for (uint256 idx=0; idx<keys.length; idx++) setSlot(0, keys[idx]);
  }

  function setStaking(bool setting) external onlyAdmin {
    require(isStakingOn!=setting, "Value unchanged");

    if (!isConfirmed(2)) return;

    isStakingOn = setting;
    emit StakingChanged(!setting, setting);
  }

  function setWaitingPeriod(uint256 inSeconds) external onlyAdmin {
    require(inSeconds != waitingPeriod, "Value unchanged");
    require(inSeconds >= 1 hours && inSeconds <= 1 days, "Value invalid");

    if (!isConfirmed(2)) return;

    emit WaitingPeriodChanged(waitingPeriod, inSeconds);
    waitingPeriod = inSeconds;
  }

  function trackBuy(address account, uint256 newBalance) external onlyOwner {
    if (holder[account].added==0) holder[account].added = stamp();
    holder[account].bought = stamp();
    setBalance(account, newBalance);
  }

  function trackSell(address account, uint256 newBalance) external onlyOwner {
    holder[account].sold = stamp();
    setBalance(account, newBalance);
  }

  function withdrawFunds(address payable account) public override { // EMITS EVENT
    require(getPending(account) > 0, "No funds");
    require(canClaim(holder[account].claimed), "Wait time active");

    updatedWeightedBalance(account);
    holder[account].claimed = stamp();
    super.withdrawFunds(account);
  }

  // PRIVATE

  function _transferOwnership(address newOwner) internal override {
    super._transferOwnership(newOwner);
    if (isContract(newOwner)) variegate = payable(newOwner);
  }

  function ageInDays(uint32 stamped) private view returns (uint32) {
    return ageInHours(stamped) / 24;
  }

  function ageInHours(uint32 stamped) private view returns (uint32) {
    return stamped==0 ? 0 : (stamp() - stamped) / 1 hours;
  }

  function canClaim(uint48 lastClaimTime) private view returns (bool) {
    if (lastClaimTime > block.timestamp) return false;
    return block.timestamp.sub(lastClaimTime) >= waitingPeriod;
  }

  function holderSet(address account, uint256 val) private {
    if (holder[account].index==0) {
      holders++;
      holderAt[holders] = account;
      holder[account].index = holders;
    }
    holder[account].balance = val;
  }

  function holderRemove(address account) private {
    if (holder[account].index==0) return;

    // COPY LAST ROW INTO SLOT BEING DELETED
    holder[holderAt[holders]].index = holder[account].index;
    holderAt[holder[account].index] = holderAt[holders];

    delete holderAt[holders];
    holders--;
    holder[account].index = 0;
  }

  function isAdmin(address account) private view returns(bool) {
    return (!isContract(owner()) && account==owner()) || (isContract(owner()) && Variegate(variegate).isAdmin(account));
  }

  function isConfirmed(uint256 required) private returns (bool) {
    return required < 2 || !isContract(owner()) || Variegate(variegate).confirmCall(required, msg.sender, msg.sig, msg.data);
  }

  function isContract(address key) private view returns (bool) {
    return key.code.length > 0;
  }

  function setBalance(address account, uint256 newBalance) private {
    if (newBalance < minimumBalance || holder[account].excluded!=0) { // BELOW MIN OR EXCLUDED
      totalTracked -= holder[account].balance;
      updateBalance(account, 0);
      holderRemove(account); // REMOVE FROM ARRAY TO THIN STORAGE
      return;
    }

    if (newBalance > holder[account].balance) {
      totalTracked += newBalance.sub(holder[account].balance);
    } else if(newBalance < holder[account].balance) {
      totalTracked -= holder[account].balance.sub(newBalance);
    }

    holderSet(account, newBalance);
    putWeighted(account);

    if (getPending(account) <= 0) return; // NOTHING PENDING WE ARE DONE HERE
    // PUSH FUNDS TO ACCOUNT W/EVENT AND UPDATE CLAIMED STAMP
    holder[account].claimed = stamp();
    super.withdrawFunds(payable(account));
  }

  function stakePercent(address account) internal view returns (uint32) {
    if (!isStakingOn) return 100;
    uint32 stamped = holder[account].sold;
    if (stamped==0) stamped = holder[account].added;
    uint32 age = ageInDays(stamped);
    return (age > 50) ? 100 : 50 + age;
  }

  function stamp() private view returns (uint32) {
    return uint32(block.timestamp); // - 1231006505 seconds past BTC epoch
  }

  function pushFunds(address account) internal returns (bool) {
    if (!canClaim(holder[account].claimed) || getPending(account)==0) return false;

    super.withdrawFunds(payable(account));

    holder[account].claimed = stamp();
    return true;
  }

  function putWeighted(address account) private {
    holder[account].percent = stakePercent(account);
    updateBalance(account, weightedBalance(account));
  }

  function sendReward(address payable account, uint256 amount) internal override returns (bool) {
    if (currentSlot()==0) return super.sendReward(account, amount);

    address tkn = tokenInSlot[currentSlot()];
    IERC20 rewards = IERC20(tkn);
    uint256 before = rewards.balanceOf(account);
    address[] memory path = new address[](2);
    path[0] = uniswapV2Router.WETH();
    path[1] = tkn;

    try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount} (0, path, address(account), block.timestamp){
      token[tkn].balance += rewards.balanceOf(account).sub(before);
      token[tkn].amount += amount;
      token[tkn].claims++;
    } catch {
      return false;
    }
    return true;
  }

  function weightedBalance(address account) internal view returns (uint256) {
    uint256 balance = holder[account].balance;
    if (!isStakingOn || balance==0 || holder[account].percent > 99) return balance;
    return balance.mul(holder[account].percent).div(100);
  }

  function updatedWeightedBalance(address account) internal {
    if (holder[account].percent==stakePercent(account)) return; // NO CHANGE
    putWeighted(account); // REWEIGHT TOKENS
  }
}
contract Variegate is ERC20, Ownable {
  using SafeMath for uint256;
  IUniswapV2Router02 public immutable uniswapV2Router;
  address public immutable uniswapV2Pair;

  address payable public rewards;
  address payable public project;

  uint256 public constant FINAL_SUPPLY = 1_000_000_000 ether;
  uint256 public constant MAX_WALLET = 15_000_000 ether; // MAX PER WALLET: 1.5%
  uint256 public constant MAX_SELL = 5_000_000 ether; // MAX PER SELL: 0.5%

  uint256 public accumulatedProject = 0;
  uint256 public accumulatedRewards = 0;
  uint256 public gasLimit = 300_000; // GAS FOR REWARDS PROCESSING
  uint256 public swapThreshold = 5_000_000 ether; // CONTRACT SWAPS TO BSD

  uint16 public constant FEE_PROJECT = 2;
  uint16 public constant FEE_TO_BUY = 8;
  uint16 public constant FEE_TO_SELL = 12;

  bool public isOpenToPublic = false;
  bool private swapping = false;

  // ADMIN CONTROL
  address[3] public admins;

  struct Confirm {
    uint256 expires;
    uint256 count;
    address[] accounts;
    bytes args;
  }
  mapping (bytes4 => Confirm) public confirm;

  // MAPPINGS
  mapping (address => bool) public autoMarketMakers; // Any transfer to these addresses are likely sells
  mapping (address => bool) public isFeeless; // exclude from all fees and maxes
  mapping (address => bool) public isPresale; // can trade in PreSale

  // EVENTS
  event FundsReceived(address indexed from, uint amount);
  event FundsSentToProject(uint256 tokens, uint256 value);
  event FundsSentToRewards(uint256 tokens, uint256 value);
  event GasLimitChanged(uint256 from, uint256 to);
  event IsFeelessChanged(address indexed account, bool excluded);
  event ProjectContractChanged(address indexed from, address indexed to);
  event RewardsContractChanged(address indexed from, address indexed to);
  event SetAutomatedMarketMakerPair(address indexed pair, bool active);
  event MarketCapCalculated(uint256 price, uint256 marketCap, uint256 tokens, uint256 value);

  event ConfirmationRequired(address account, bytes4 method, uint256 confirmations, uint256 required);
  event ConfirmationComplete(address account, bytes4 method, uint256 confirmations);
  event AdminChanged(address from, address to);

  constructor() ERC20("Variegate", "$VARI") {
    // address ROUTER_PCSV2_MAINNET = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address ROUTER_PCSV2_TESTNET = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address ROUTER_FAKEPCS_TESTNET = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IUniswapV2Router02 router = IUniswapV2Router02(ROUTER_FAKEPCS_TESTNET);
    address pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
    uniswapV2Router = router;
    uniswapV2Pair = pair;
    autoMarketMakers[pair] = true;
    isPresale[owner()] = true;
    isFeeless[address(this)] = true;
    project = payable(owner());
    rewards = payable(owner());

    _mint(owner(), FINAL_SUPPLY);
  }

  modifier onlyAdmin() {
    require(isAdmin(_msgSender()), "Caller invalid");
    _;
  }

  modifier onlyVariegates() {
    require(rewards==_msgSender() || project==_msgSender(), "Caller invalid");
    _;
  }

  receive() external payable {
    emit FundsReceived(msg.sender, msg.value);
  }

  function confirmCall(uint256 required, address account, bytes4 method, bytes calldata args) public onlyVariegates returns (bool) {
    require(isAdmin(account), "Caller invalid");
    return confirmed(required, account, method, args);
  }

  function isAdmin(address account) public view returns (bool) {
    for (uint idx; idx<admins.length; idx++) if (admins[idx]==account) return true;
    return (admins[0]==address(0) && account==owner()); // IF NO OFFICERS SET USE onlyOwner
  }

  function openToPublic() external onlyAdmin { // NO GOING BACK
    require(isContract(project) && isContract(rewards) && admins[0]!=address(0), "Configuration required");
    require(address(this).balance > 0, "Must have bnb to pair for launch");
    require(balanceOf(address(this)) > 0, "Must have tokens to pair for launch");

    if (!isConfirmed(2)) return;

    isOpenToPublic = true;

    // INITIAL LIQUIDITY GOES TO OWNER TO LOCK
    // addLiquidity(balanceOf(address(this)), address(this).balance);
  }

  function setAdmins(address[] memory accounts) external onlyAdmin {
    require(admins[0]==address(0), "Already set");
    require(accounts.length==3, "3 Admins required");

    for (uint256 idx=0;idx<accounts.length;idx++) admins[idx] = accounts[idx];
  }

  function setAutomatedMarketMakerPair(address pair, bool setting) external onlyAdmin {
    require(pair != uniswapV2Pair, "Value invalid");
    require(autoMarketMakers[pair] != setting, "Value unchanged");

    if (!isConfirmed(2)) return;

    autoMarketMakers[pair] = setting;
    emit SetAutomatedMarketMakerPair(pair, setting);
  }

  function setFeeless(address account, bool setting) external onlyAdmin {
    require(isFeeless[account]!=setting, "Value unchanged");

    if (!isConfirmed(2)) return;

    isFeeless[account] = setting;
    emit IsFeelessChanged(account, setting);
  }

  function setGasLimit(uint256 gas) external onlyAdmin {
    require(gas >= 250_000 && gas <= 750_000, "Value invalid");
    require(gas != gasLimit, "Value unchanged");

    if (!isConfirmed(2)) return;

    emit GasLimitChanged(gasLimit, gas);
    gasLimit = gas;
  }

  function setPresale(address account, bool setting) external onlyAdmin {
    if (!isConfirmed(2)) return;

    isPresale[account] = setting;
  }

  function setProjectContract(address newContract) external onlyAdmin {
    require(newContract != project, "Value unchanged");
    require(isContract(newContract), "Not a contract");
    require(Ownable(newContract).owner() == address(this), "Token must own project");

    if (!isConfirmed(3)) return;

    if (isContract(project)) VariegateProject(project).transferOwnership(owner());
    emit ProjectContractChanged(project, newContract);
    project = payable(newContract);
  }

  function setRewardsContract(address newContract) external onlyAdmin {
    require(newContract != rewards, "Value unchanged");
    require(isContract(newContract), "Not a contract");
    require(Ownable(newContract).owner() == address(this), "Token must own tracker");

    if (!isConfirmed(3)) return;

    if (isContract(rewards)) VariegateRewards(rewards).transferOwnership(owner());
    emit RewardsContractChanged(rewards, newContract);
    rewards = payable(newContract);
  }

  function replaceAdmin(address from, address to) external onlyAdmin {
    require(to!=address(0) && isAdmin(from) && !isAdmin(to), "Value invalid");

    if (!isConfirmed(2)) return;

    for (uint idx; idx<admins.length; idx++) if (admins[idx]==from) admins[idx] = to;
    emit AdminChanged(from, to);
  }

  // PRIVATE

  function _transfer(address from, address to, uint256 amount) internal override {
    require(from != address(0) && to != address(0), "Value invalid");
    require(amount > 0, "Value invalid");

    require(to==address(this) || autoMarketMakers[to] || balanceOf(to).add(amount) <= MAX_WALLET, "Wallet over limit");

    if (!isOpenToPublic && isPresale[from]) { // PRE-SALE WALLET - NO FEES, JUST TRANSFER AND UPDATE TRACKER BALANCES
      transferAndUpdateRewardsTracker(from, to, amount);
      return;
    }

    require(isOpenToPublic, "Trading closed");

    if (!autoMarketMakers[to] && !autoMarketMakers[from]) { // NOT A SALE, NO FEE TRANSFER
      transferAndUpdateRewardsTracker(from, to, amount);
      processSomeClaims();
      return; // NO TAXES
    }

    if (!swapping) {
      bool feePayer = !isFeeless[from] && !isFeeless[to];
      if (feePayer) {
        uint256 taxTotal = 0;
        uint256 taxProject = 0;
        uint256 taxRewards = 0;
        if (autoMarketMakers[to] && from!=address(uniswapV2Router)) { // SELL
          require(amount <= MAX_SELL, "Sell over limit");
          taxTotal = amount.mul(FEE_TO_SELL).div(100);
          taxProject = taxTotal.mul(FEE_PROJECT).div(FEE_TO_SELL);
        } else { // BUY
          taxTotal = amount.mul(FEE_TO_BUY).div(100);
          taxProject = taxTotal.mul(FEE_PROJECT).div(FEE_TO_BUY);
        }
        if (taxTotal > 0) {
          taxRewards = taxTotal.sub(taxProject);
          accumulatedProject += taxProject;
          accumulatedRewards += taxRewards;
          super._transfer(from, address(this), taxTotal);
          amount -= taxTotal;
        }
      }

      if (!autoMarketMakers[from]) {
        swapping = true;
        if (balanceOf(address(this)) >= swapThreshold) swapAndSendToRewards(swapThreshold);
        if (balanceOf(address(this)) >= swapThreshold) swapAndSendToProject(swapThreshold);
        swapping = false;
      }
    }

    transferAndUpdateRewardsTracker(from, to, amount);

    if (!swapping) {
      processSomeClaims();
    }
  }

  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, payable(owner()), block.timestamp);
  }

  function changeMarketCap(uint256 swappedETH, uint256 tokens) private {
    uint256 marketCap = swappedETH.mul(FINAL_SUPPLY).div(tokens).div(1 ether);
    uint256 price = marketCap.mul(1 ether).div(FINAL_SUPPLY.div(1 ether));
    emit MarketCapCalculated(price, marketCap, tokens, swappedETH); // TESTING
    // TODO SET swapThreshold
    // swapThreshold = uint256((17-level)) * 1_000_000 ether;
  }

  function confirmed(uint256 required, address account, bytes4 method, bytes calldata args) internal returns (bool) {
    if (required==1) return true;

    if (confirm[method].expires!=0 && (confirm[method].expires<block.timestamp || keccak256(confirm[method].args)!=keccak256(args))) { // EXISTING CALL EXPIRED OR ARGS NEQ
      delete confirm[method];
    }

    bool found = false;
    for (uint idx; idx<confirm[method].accounts.length; idx++) if (confirm[method].accounts[idx]==account) found = true; // CHECK RE-CONFIRMS

    if (!found) confirm[method].accounts.push(account);

    if (confirm[method].accounts.length==required) { // CONFIRMED
      emit ConfirmationComplete(account, method, required);
      delete confirm[method];
      return true;
    }

    confirm[method].count = confirm[method].accounts.length;
    confirm[method].args = args;
    confirm[method].expires = block.timestamp + 60 * 15;
    emit ConfirmationRequired(account, method, confirm[method].count, required);

    return false;
  }

  function isConfirmed(uint256 required) private returns (bool) {
    return required < 2 || admins[0]==address(0) || confirmed(required, msg.sender, msg.sig, msg.data);
  }

  function isContract(address key) private view returns (bool) {
    return key.code.length > 0;
  }

  function processSomeClaims() private {
    if (!isContract(rewards)) return;

    try VariegateRewards(rewards).processClaims(gasLimit) {} catch {}
  }

  function swapAndSendToRewards(uint256 tokens) private {
    if (accumulatedRewards < tokens) return; // NOT YET

    accumulatedRewards -= tokens;
    uint256 swappedETH = swapTokensForETH(tokens);
    if (swappedETH > 0) {
      (bool success,) = rewards.call{value: swappedETH}("");
      if (success) {
        emit FundsSentToRewards(tokens, swappedETH);
        changeMarketCap(swappedETH, tokens);
      }
    }
  }

  function swapAndSendToProject(uint256 tokens) private {
    if (accumulatedProject < tokens) return; // NOT YET

    accumulatedProject -= tokens;
    uint256 swappedETH = swapTokensForETH(tokens);
    if (swappedETH > 0) {
      (bool success,) = project.call{value: swappedETH}("");
      if (success) emit FundsSentToProject(tokens, swappedETH);
    }
  }

  function swapTokensForETH(uint256 tokens) private returns(uint256) {
    address[] memory pair = new address[](2);
    pair[0] = address(this);
    pair[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokens);
    uint256 currentETH = address(this).balance;
    uniswapV2Router.swapExactTokensForETH(tokens, 0, pair, address(this), block.timestamp);
    return address(this).balance.sub(currentETH);
  }

  function transferAndUpdateRewardsTracker(address from, address to, uint256 amount) private {
    super._transfer(from, to, amount);

    if (!isContract(rewards)) return;

    try VariegateRewards(rewards).trackSell(from, balanceOf(from)) {} catch {}
    try VariegateRewards(rewards).trackBuy(to, balanceOf(to)) {} catch {}
  }
}