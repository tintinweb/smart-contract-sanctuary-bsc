/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

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

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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
  constructor() {
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

// File contracts/interfaces/IDEXRouter.sol

pragma solidity ^0.8.13;

interface IDEXRouter {
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

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

// File contracts/interfaces/IDEXFactory.sol

pragma solidity ^0.8.13;

interface IDEXFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// File contracts/interfaces/IDEXPair.sol

pragma solidity ^0.8.13;

interface IDEXPair {
  function token0() external view returns (address);

  function token1() external view returns (address);

  function sync() external;

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );
}

// File contracts/Token.sol

pragma solidity 0.8.13;

/**
 * @title EQUO ERC20 token
 * @dev This is part of an implementation of the EQUO token.
 *      EQUO is a normal ERC20 token, but its supply can be adjusted by splitting and
 *      combining tokens proportionally across all wallets.
 *
 *      Stash balances are privately represented with a hidden denomination, 'gons'.
 *      We support splitting the currency in expansion and combining the currency on contraction by
 *      changing the exchange rate between the hidden 'gons' and the public 'fragments'.
 */
contract Token is IERC20, Ownable, Pausable {
  using SafeMath for uint256;

  string private constant _name = "EQUO";
  string private constant _symbol = "EQUO";
  uint8 private constant _decimals = 18;

  enum RebaseType {
    POSITIVE,
    NEGATIVE
  }

  enum TransactionType {
    BUY,
    SELL,
    TRANSFER
  }

  uint256 private constant ONE_UNIT = 10**_decimals;
  uint256 private constant INITIAL_FRAGMENTS_SUPPLY = (10**9 + 5 * 10**8) * ONE_UNIT; // 1.5 billion
  uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

  uint256 public constant MAX_UINT256 = ~uint256(0);
  address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address public constant ZERO = 0x0000000000000000000000000000000000000000;

  uint256 public constant MAX_DAILY_SELL_LIMIT_FACTOR = 100;
  uint256 public constant MIN_DAILY_SELL_LIMIT_FACTOR = 10;

  uint256 private _totalSupply;
  uint256 private _gonsPerFragment;
  bool private _inSwap = false;
  uint256 private DEFAULT_GONSWAP_THRESHOLD = TOTAL_GONS / 1000;
  uint256 private _minFeeAmountToCollect = DEFAULT_GONSWAP_THRESHOLD;
  uint256 private _minAmountToAddLiquidity = DEFAULT_GONSWAP_THRESHOLD;

  mapping(address => bool) public automatedMarketMakerPairs;
  mapping(address => uint256) private _gonBalances;
  mapping(address => mapping(address => uint256)) private _allowedFragments;
  mapping(address => bool) private _noCheckDailySellLimit;
  address[] public _makerPairs;

  uint256 public positiveRebaseRate = 2073;
  uint256 public positiveRebaseRateDenominator = 10**7;
  uint256 public negativeRebaseRate = 51;
  uint256 public negativeRebaseRateDenominator = 10**3;

  uint256 public negativeFromAthPercent = 5;
  uint256 public negativeFromAthPercentDenominator = 100;

  uint256 public lastRebasedTime;

  // Transaction fees
  uint256 public buyFee = 13;
  uint256 public sellFee = 17;
  uint256 public transferFee = 35;
  uint256 public feeDenominator = 100;

  // Coefficients for the daily sell limit liner equation
  uint256 public coefficientA = 10;
  uint256 public coefficientB = 110;
  uint256 public maxHoldingPercentSellLimitApplied = 9;

  // Fee split
  uint256 public autoLiquidityFeePercent = 50;
  uint256 public treasuryFeePercent = 30;
  uint256 public burnFeePercent = 20;

  // Sell limit
  uint256 public sellLimitDenominator = 10000;

  // 3rd party contracts
  address public BUSD;
  IDEXRouter public router;

  address public pair;
  // all time high price
  uint256 public athPrice;
  uint256 public lastNegativeRebaseTriggerAthPrice;
  uint256 public rebaseFrequency = 30 minutes;

  address public autoLiquidityReceiver;
  address public treasury;

  bool public autoRebase;
  bool public autoCollectFees;
  bool public autoAddLiquidity;
  bool public dailySellLimitEnabled;
  bool public priceEnabled;
  bool public transferFeeEnabled;
  mapping(address => bool) public blocklist;
  mapping(address => bool) public isFeeExempt;
  mapping(address => SaleHistory) public saleHistories;

  // SaleHistory tracking how many tokens that a user has sold within a span of 24hs
  struct SaleHistory {
    uint256 lastDailySellLimitAmount;
    uint256 lastSoldTimestamp;
    uint256 totalSoldAmountLast24h;
  }

  event LogRebase(uint256 indexed epoch, RebaseType rebaseType, uint256 lastTotalSupply, uint256 currentTotalSupply);
  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

  modifier swapping() {
    _inSwap = true;
    _;
    _inSwap = false;
  }

  modifier validRecipient(address to) {
    require(to != address(0x0));
    _;
  }

  constructor(
    address _dexRouter,
    address _busd,
    address _autoLiquidityReceiver,
    address _treasury
  ) {
    router = IDEXRouter(_dexRouter);
    BUSD = _busd;
    pair = IDEXFactory(router.factory()).createPair(_busd, address(this));

    autoLiquidityReceiver = _autoLiquidityReceiver;
    treasury = _treasury;

    setAutomatedMarketMakerPair(pair, true);

    _allowedFragments[address(this)][address(router)] = MAX_UINT256;

    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

    address deployer = msg.sender;
    _gonBalances[deployer] = TOTAL_GONS;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    isFeeExempt[deployer] = true;

    lastRebasedTime = block.timestamp;

    autoRebase = true;
    autoCollectFees = true;
    autoAddLiquidity = true;

    emit Transfer(address(0x0), deployer, _totalSupply);
  }

  receive() external payable {}

  function transfer(address to, uint256 value) external override validRecipient(to) whenNotPaused returns (bool) {
    _transferFrom(msg.sender, to, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external override validRecipient(to) whenNotPaused returns (bool) {
    uint256 currentAllowance = allowance(from, msg.sender);
    if (currentAllowance != MAX_UINT256) {
      _allowedFragments[from][msg.sender] = currentAllowance.sub(value, "ERC20: insufficient allowance");
    }
    _transferFrom(from, to, value);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    uint256 oldValue = _allowedFragments[msg.sender][spender];
    if (subtractedValue >= oldValue) {
      _allowedFragments[msg.sender][spender] = 0;
    } else {
      _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
    }
    emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
    return true;
  }

  function approve(address spender, uint256 value) external override whenNotPaused returns (bool) {
    _allowedFragments[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Manual trigger rebase to increase or reduce the total supply of the token
   */
  function rebase() external {
    require(_shouldRebase(), "SHOULD_NOT_REBASE");
    // calculate time weighted price for 1 EQUO token
    uint256 price = _getTokenPriceInBUSD();
    _rebase(price);
  }

  /* ========== FUNCTIONS FOR OWNER ========== */

  /**
   * @dev enable calculating current price for each transaction
   */
  function setPriceEnabled(bool flag) external onlyOwner {
    priceEnabled = flag;
  }

  /**
   * @dev Set rebase frequency in seconds
   * @param valueInSeconds Provide duration in seconds
   */
  function setRebaseFrequency(uint256 valueInSeconds) external onlyOwner {
    rebaseFrequency = valueInSeconds;
  }

  /**
   * @dev Set auto rebase to trigger automatic rebasing on a transfer when rebase frequency duration has passed
   * @param flag provide the boolean value
   */
  function setAutoRebase(bool flag) external onlyOwner {
    if (flag) {
      lastRebasedTime = block.timestamp;
    }

    autoRebase = flag;
  }

  /**
   * @dev Switch on/off checking daily sell limit feature
   * @param flag provide the boolean value
   */
  function setDailySellLimitEnabled(bool flag) external onlyOwner {
    dailySellLimitEnabled = flag;
  }

  /**
   * @dev Exclude an address from daily sell limit restriction
   * @param _address Provide the address to be excluded
   * @param flag provide the boolean value
   */
  function setNoCheckDailySellLimit(address _address, bool flag) external onlyOwner {
    _noCheckDailySellLimit[_address] = flag;
  }

  /**
   * @dev Switch on/off taking transfer fee feature
   * @param flag provide the boolean value
   */
  function setTransferFeeEnabled(bool flag) external onlyOwner {
    transferFeeEnabled = flag;
  }

  /**
   * @dev Set auto liquidity to trigger automatic liquidity on a transfer when balance of liquidityReceiver has gone above threshold
   * @param flag provide the boolean value
   */
  function setAutoAddLiquidity(bool flag) external onlyOwner {
    autoAddLiquidity = flag;
  }

  /**
   * @dev Set auto liquidity to trigger collecting available fees and send to the treasury
   * @param flag provide the boolean value
   */
  function setAutoCollectFees(bool flag) external onlyOwner {
    autoCollectFees = flag;
  }

  /**
   * @dev Set threshold amount to trigger adding liquidity when balance of liquidityReceiver goes above this threshold
   * @param amount provide the threshold amount
   */
  function setMinAmountToAddLiquidity(uint256 amount) external onlyOwner {
    _minAmountToAddLiquidity = amount.mul(_gonsPerFragment);
  }

  /**
   * @dev Set threshold amount to trigger collecting fees when balance of the contract goes above this threshold
   * @param amount provide the threshold amount
   */
  function setMinFeeAmountToCollect(uint256 amount) external onlyOwner {
    _minFeeAmountToCollect = amount.mul(_gonsPerFragment);
  }

  /**
   * @dev daily sell limit amount follow a linear equation y = ax + b
   * Set the coefficients for the linear equation
   *
   * @param _coefficientA `a` value of the equation
   * @param _coefficientB `b` value of the equation
   * @param denominator the denominator of the dailySellLimitFactor
   */
  function setDailySellLimitCoefficients(
    uint256 _coefficientA,
    uint256 _coefficientB,
    uint256 denominator
  ) external onlyOwner {
    require(_coefficientB > _coefficientA * maxHoldingPercentSellLimitApplied, "INVALID_COEFFICIENTS");
    coefficientA = _coefficientA;
    coefficientB = _coefficientB;
    sellLimitDenominator = denominator;
  }

  /**
   * @dev set the max percentage that could be applied when calculating the daily sell limit factor to avoid math overflow
   * the percentage is the percent of a holder's balance comparing to the balance of liquidity pool
   * @param percent provide the max percentage
   */
  function setMaxHoldingPercentSellLimitApplied(uint256 percent) external onlyOwner {
    maxHoldingPercentSellLimitApplied = percent;
  }

  /**
   * @dev how much should the price drop before triggering negative rebase
   * This is a percentage (base value: 5%)
   * @param percent provide the percent
   */
  function setNegativeRebaseFromAth(uint256 percent, uint256 denominator) external onlyOwner {
    negativeFromAthPercent = percent;
    negativeFromAthPercentDenominator = denominator;
  }

  /**
   * @dev set rebase rate and denominator for the positive rabase mechanism
   */
  function setPositiveRebaseRate(uint256 rate, uint256 denominator) external onlyOwner {
    positiveRebaseRate = rate;
    positiveRebaseRateDenominator = denominator;
  }

  /**
   * @dev set rebase rate and denominator for the negative rabase mechanism
   */
  function setNegativeRebaseRate(uint256 rate, uint256 denominator) external onlyOwner {
    negativeRebaseRate = rate;
    negativeRebaseRateDenominator = denominator;
  }

  /**
   * @dev Function allows admin to set the address of the treasury
   */
  function setTreasuryWallet(address wallet) external onlyOwner {
    treasury = wallet;
  }

  /**
   * @dev Function allows admin to set the address of the treasury
   */
  function setAutoLiquidityReceiver(address wallet) external onlyOwner {
    autoLiquidityReceiver = wallet;
  }

  /**
   * @dev Function allows admin to block list an address
   */
  function setBlocklistAddress(address address_, bool flag) external onlyOwner {
    blocklist[address_] = flag;
  }

  /**
   * @dev Function allows admin to exclude an address from transaction fees
   */
  function setFeeExemptAddress(address address_, bool flag) external onlyOwner {
    isFeeExempt[address_] = flag;
  }

  /**
   * @dev Set LP address of EQUO/BUSD pair
   */
  function setBackingLPToken(address lpAddress) external onlyOwner {
    pair = lpAddress;
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  /**
   * @dev Function allows admin to withdraw ETH accidentally dropped to the contract.
   */
  function clearStuckBalance(address _receiver) external onlyOwner {
    uint256 balance = address(this).balance;
    payable(_receiver).transfer(balance);
  }

  /**
   * @dev Function allows admin to withdraw tokens accidentally dropped to the contract.
   */
  function rescueToken(address tokenAddress, uint256 amount) external onlyOwner {
    require(IERC20(tokenAddress).transfer(msg.sender, amount), "RESCUE_TOKENS_FAILED");
  }

  /**
   * @dev Set fee split for transaction fee
   * 3 values that modify the percentage of how fees are divided and
   * distributed (Auto-Liquidity, Treasury and Burn Address)
   */
  function setFeeSplit(
    uint256 autoLiquidityPercent,
    uint256 treasuryPercent,
    uint256 burnPercent
  ) external onlyOwner {
    require(autoLiquidityPercent + treasuryPercent + burnPercent == 100, "INVALID_FEE_SPLIT");
    autoLiquidityFeePercent = autoLiquidityPercent;
    treasuryFeePercent = treasuryPercent;
    burnFeePercent = burnPercent;
  }

  /**
   * @dev Set transaction fee rate
   */
  function setFees(
    uint256 _buyFee,
    uint256 _sellFee,
    uint256 _transferFee,
    uint256 _feeDenominator
  ) external onlyOwner {
    buyFee = _buyFee;
    sellFee = _sellFee;
    transferFee = _transferFee;
    feeDenominator = _feeDenominator;
  }

  function balanceOf(address who) external view override returns (uint256) {
    return _gonBalances[who].div(_gonsPerFragment);
  }

  function checkMinAmountToAddLiquidity() external view returns (uint256) {
    return _minAmountToAddLiquidity.div(_gonsPerFragment);
  }

  function checkMinFeeAmountToCollect() external view returns (uint256) {
    return _minFeeAmountToCollect.div(_gonsPerFragment);
  }

  function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
    require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

    automatedMarketMakerPairs[_pair] = _value;

    if (_value) {
      _makerPairs.push(_pair);
    } else {
      require(_makerPairs.length > 1, "Required 1 pair");
      for (uint256 i = 0; i < _makerPairs.length; i++) {
        if (_makerPairs[i] == _pair) {
          _makerPairs[i] = _makerPairs[_makerPairs.length - 1];
          _makerPairs.pop();
          break;
        }
      }
    }

    emit SetAutomatedMarketMakerPair(_pair, _value);
  }

  /**
   * @dev Calculate the sell limit factor
   * A user can only sell a portion of his total balance within a span of 24h
   * This factor is used to calculate the max token amount that a holder could sell in 24h
   * The factor is the result of a linear equation: y = -ax + b
   * @param holdingPercent the percentage of a wallet balance over the liquidity pool balance
   */
  function calculateSellLimitFactor(uint256 holdingPercent) public view returns (uint256) {
    // the sell limit factor follow a linear equation
    uint256 percentApplied = holdingPercent > maxHoldingPercentSellLimitApplied ? maxHoldingPercentSellLimitApplied : holdingPercent;
    uint256 sellLimitFactor = (coefficientB - coefficientA * percentApplied);

    if (sellLimitFactor > MAX_DAILY_SELL_LIMIT_FACTOR) {
      return MAX_DAILY_SELL_LIMIT_FACTOR;
    } else if (sellLimitFactor < MIN_DAILY_SELL_LIMIT_FACTOR) {
      return MIN_DAILY_SELL_LIMIT_FACTOR;
    }

    return sellLimitFactor;
  }

  function getDailySellLimitAmount(address _address) public view returns (uint256) {
    uint256 factor = _getDailySellLimitFactor(_address);
    uint256 bal = IERC20(address(this)).balanceOf(_address);
    return bal.mul(factor).div(sellLimitDenominator);
  }

  function allowance(address owner_, address spender) public view override returns (uint256) {
    return _allowedFragments[owner_][spender];
  }

  function manualSync() public {
    for (uint256 i = 0; i < _makerPairs.length; i++) {
      IDEXPair(_makerPairs[i]).sync();
    }
  }

  /* ========== PUBLIC AND EXTERNAL VIEW FUNCTIONS ========== */

  /**
   * @dev Get total supply excluding burned amount
   */
  function totalSupplyIncludingBurnAmount() public view returns (uint256) {
    return _totalSupply;
  }

  function totalSupply() public view override returns (uint256) {
    return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
  }

  function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
    uint256 liquidityBalance = 0;
    for (uint256 i = 0; i < _makerPairs.length; i++) {
      liquidityBalance = liquidityBalance.add(_gonBalances[_makerPairs[i]].div(_gonsPerFragment));
    }

    return accuracy.mul(liquidityBalance.mul(2)).div(totalSupply());
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public pure returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public pure returns (string memory) {
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
  function decimals() public pure returns (uint8) {
    return _decimals;
  }

  /* ========== PRIVATE FUNCTIONS ========== */
  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(!blocklist[sender] && !blocklist[recipient], "ADDRESS_IN_BLOCKLIST");
    if (_inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    uint256 price;
    if (priceEnabled) {
      price = _getTokenPriceInBUSD();
    }

    if (_shouldRebase()) {
      _rebase(price);
    }

    if (dailySellLimitEnabled && _isSellTx(recipient) && !_noCheckDailySellLimit[sender]) {
      _checkDailySellLimitAndUpdateSaleHistory(sender, amount);
    }

    // make sure this transaction either execute auto collect fees or auto add liquidity
    if (_shouldCollectFees()) {
      _collectFeesAndSendToTreasury();
    } else if (_shouldAddLiquidity()) {
      // avoid trigger updating oracle if this transaction already trigger auto adding liquidity to save gas
      _addLiquidity();
    }

    uint256 gonAmount = amount.mul(_gonsPerFragment);
    uint256 gonAmountToRecipient = _shouldTakeFee(sender, recipient) ? _takeFee(sender, recipient, gonAmount) : gonAmount;
    _gonBalances[sender] = _gonBalances[sender].sub(gonAmount, "ERC20: transfer amount exceeds balance");
    _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountToRecipient);

    if (price > athPrice) {
      athPrice = price;
    }

    emit Transfer(sender, recipient, gonAmountToRecipient.div(_gonsPerFragment));
    return true;
  }

  /**
   * @dev Collects tax fees, swap into BUSD and send to the treasury
   */
  function _collectFeesAndSendToTreasury() private swapping {
    uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;

    if (IERC20(address(this)).allowance(address(this), address(router)) < amountToSwap) {
      IERC20(address(this)).approve(address(router), type(uint256).max);
    }

    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, treasury, block.timestamp);
  }

  function _basicTransfer(
    address from,
    address to,
    uint256 amount
  ) private returns (bool) {
    uint256 gonAmount = amount.mul(_gonsPerFragment);
    _gonBalances[from] = _gonBalances[from].sub(gonAmount, "ERC20: transfer amount exceeds balance");
    _gonBalances[to] = _gonBalances[to].add(gonAmount);
    return true;
  }

  /**
   * @dev Internal function to check if transfer amount surpasses the daily sell limit amount
   * @param sender address of the sender that execute the transaction
   * @param amount transfer amount
   */
  function _checkDailySellLimitAndUpdateSaleHistory(address sender, uint256 amount) private {
    SaleHistory storage history = saleHistories[sender];
    uint256 timeElapsed = block.timestamp.sub(history.lastSoldTimestamp);
    if (timeElapsed < 1 days) {
      require(history.totalSoldAmountLast24h.add(amount) <= history.lastDailySellLimitAmount, "EXCEEDS_DAILY_SELL_LIMIT");
      history.totalSoldAmountLast24h += amount;
    } else {
      uint256 limitAmount = getDailySellLimitAmount(sender);
      require(amount <= limitAmount, "EXCEEDS_DAILY_SELL_LIMIT");
      history.lastSoldTimestamp = block.timestamp;
      history.lastDailySellLimitAmount = limitAmount;
      history.totalSoldAmountLast24h = amount;
    }
  }

  function _addLiquidity() private swapping {
    uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(_gonsPerFragment);
    _gonBalances[address(this)] = _gonBalances[address(this)].add(_gonBalances[autoLiquidityReceiver]);
    _gonBalances[autoLiquidityReceiver] = 0;
    uint256 amountToLiquify = autoLiquidityAmount.div(2);
    uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

    if (amountToSwap == 0) {
      return;
    }
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;

    uint256 balanceBUSDBefore = IERC20(BUSD).balanceOf(autoLiquidityReceiver);
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountToSwap, 0, path, autoLiquidityReceiver, block.timestamp);

    uint256 amountBUSDLiquidity = IERC20(BUSD).balanceOf(autoLiquidityReceiver) - balanceBUSDBefore;
    // make sure autoLiquidityReceiver must approve spending for the token contract first
    IERC20(BUSD).transferFrom(autoLiquidityReceiver, address(this), amountBUSDLiquidity);

    if (IERC20(BUSD).allowance(address(this), address(router)) < amountBUSDLiquidity) {
      IERC20(BUSD).approve(address(router), type(uint256).max);
    }

    if (IERC20(address(this)).allowance(address(this), address(router)) < amountToLiquify) {
      IERC20(address(this)).approve(address(router), type(uint256).max);
    }

    if (amountToLiquify > 0 && amountBUSDLiquidity > 0) {
      router.addLiquidity(address(this), BUSD, amountToLiquify, amountBUSDLiquidity, 0, 0, autoLiquidityReceiver, block.timestamp);
    }
  }

  function _takeFee(
    address sender,
    address recipient,
    uint256 gonAmount
  ) private returns (uint256) {
    uint256 fee;

    TransactionType txType = _getTransactionType(sender, recipient);
    if (txType == TransactionType.BUY) {
      fee = buyFee;
    } else if (txType == TransactionType.SELL) {
      fee = sellFee;
    } else if (txType == TransactionType.TRANSFER) {
      fee = _shouldApplyTransferFee(sender, gonAmount) ? transferFee : 0;
    }

    if (fee == 0) {
      return gonAmount;
    }

    uint256 feeAmount = gonAmount.div(feeDenominator).mul(fee);
    // burn tokens
    uint256 burnAmount = feeAmount.div(feeDenominator).mul(burnFeePercent);
    uint256 treasuryAmount = feeAmount.div(feeDenominator).mul(treasuryFeePercent);
    uint256 liquidityAmount = feeAmount.sub(burnAmount.add(treasuryAmount));

    _gonBalances[DEAD] = _gonBalances[DEAD].add(burnAmount);
    _gonBalances[address(this)] = _gonBalances[address(this)].add(treasuryAmount);
    _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(liquidityAmount);

    emit Transfer(sender, DEAD, burnAmount.div(_gonsPerFragment));
    emit Transfer(sender, autoLiquidityReceiver, liquidityAmount.div(_gonsPerFragment));
    emit Transfer(sender, address(this), treasuryAmount.div(_gonsPerFragment));

    return gonAmount.sub(feeAmount);
  }

  function _getTokenPriceInBUSD() private view returns (uint256) {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;
    uint256[] memory amounts = router.getAmountsOut(ONE_UNIT, path);
    return amounts[1];
  }

  function _isSellTx(address recipient) private view returns (bool) {
    return recipient == pair;
  }

  function _shouldRebase() private view returns (bool) {
    return autoRebase && !_inSwap && msg.sender != pair && block.timestamp >= (lastRebasedTime + rebaseFrequency);
  }

  function _shouldAddLiquidity() private view returns (bool) {
    return autoAddLiquidity && !_inSwap && msg.sender != pair && _gonBalances[autoLiquidityReceiver] >= _minAmountToAddLiquidity;
  }

  function _shouldCollectFees() private view returns (bool) {
    return autoCollectFees && !_inSwap && msg.sender != pair && _gonBalances[address(this)] >= _minFeeAmountToCollect;
  }

  function _shouldTakeFee(address from, address to) private view returns (bool) {
    if (isFeeExempt[from] || isFeeExempt[to]) {
      return false;
    }

    return true;
  }

  /**

   * @dev Check if the transfer fee will be applied on a transfer
   * Transfer fee is only applied to users that transfer less than 100% of their holdings
   * from their wallet to another wallet
   *
   * @param sender the sender of transfer
   * @param gonAmount transfer amount in `gonAmount` unit
   */
  function _shouldApplyTransferFee(address sender, uint256 gonAmount) private view returns (bool) {
    if (!transferFeeEnabled) {
      return false;
    }

    uint256 balance = _gonBalances[sender].div(_gonsPerFragment);
    uint256 transferAmount = gonAmount.div(_gonsPerFragment);
    if (balance == transferAmount) {
      return false;
    }

    return true;
  }

  /**
   * @dev Get daily sell limit factor for a wallet address
   */
  function _getDailySellLimitFactor(address _address) private view returns (uint256) {
    uint256 balance = IERC20(address(this)).balanceOf(_address);
    uint256 balanceOfPair = IERC20(address(this)).balanceOf(pair);
    if (balanceOfPair == 0) {
      return 0;
    }

    uint256 holdingPercent = balance.mul(100).div(balanceOfPair);
    return calculateSellLimitFactor(holdingPercent);
  }

  /**
   * @dev Internal rebase method that notifies token contract about a new rebase cycle
   * this will trigger either a positive or negative rebase depending on the current price
   * If it detects a significant price drop, it will trigger a negative rebase to reduce the totalSupply
   * otherwise it would increase the totalSupply
   * Ater increase/reduce the totalSupply, it executes syncing to update values of the pair's reserve
   */
  function _rebase(uint256 currentPrice) private {
    RebaseType rebaseType = RebaseType.POSITIVE;
    uint256 triggerNegativeRebasePrice = athPrice.sub(athPrice.mul(negativeFromAthPercent).div(negativeFromAthPercentDenominator));

    if (currentPrice != 0 && currentPrice < triggerNegativeRebasePrice && lastNegativeRebaseTriggerAthPrice < athPrice) {
      rebaseType = RebaseType.NEGATIVE;
      // make sure only one negative rebase is trigger when the price drop 5% below the current ATH
      lastNegativeRebaseTriggerAthPrice = athPrice;
    }

    uint256 lastTotalSupply = _totalSupply;
    uint256 deltaTime = block.timestamp - lastRebasedTime;
    uint256 times = deltaTime.div(rebaseFrequency);

    if (rebaseType == RebaseType.POSITIVE) {
      for (uint256 i = 0; i < times; i++) {
        _totalSupply = _totalSupply.mul(positiveRebaseRateDenominator.add(positiveRebaseRate)).div(positiveRebaseRateDenominator);
      }
    } else {
      // if negative rebase, trigger rebase once
      _totalSupply = _totalSupply.mul(negativeRebaseRateDenominator.sub(negativeRebaseRate)).div(negativeRebaseRateDenominator);
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    lastRebasedTime = lastRebasedTime.add(times.mul(rebaseFrequency));

    manualSync();

    uint256 epoch = block.timestamp;
    emit LogRebase(epoch, rebaseType, lastTotalSupply, _totalSupply);
  }

  function _getTransactionType(address sender, address recipient) private view returns (TransactionType) {
    if (pair == sender) {
      return TransactionType.BUY;
    } else if (pair == recipient) {
      return TransactionType.SELL;
    }

    return TransactionType.TRANSFER;
  }
}