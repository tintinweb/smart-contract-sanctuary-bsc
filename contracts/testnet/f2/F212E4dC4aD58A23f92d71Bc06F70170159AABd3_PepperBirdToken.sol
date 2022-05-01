/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// PEPPERBIRD TOKEN BEP 20 Source Code
// BUILD 009
// pepperbird.finance
// 4/30/2022
// SPDX-License-Identifier: MIT
//////////////////////////////////////////////////////////////
/// @custom:security-contact [email protected]

pragma solidity =0.8.9;

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

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
  /**
   * @dev Destroys `amount` tokens from the caller.
   *
   * See {ERC20-_burn}.
   */
  function burn(uint256 amount) public virtual {
    _burn(_msgSender(), amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, deducting from the caller's
   * allowance.
   *
   * See {ERC20-_burn} and {ERC20-allowance}.
   *
   * Requirements:
   *
   * - the caller must have allowance for ``accounts``'s tokens of at least
   * `amount`.
   */
  function burnFrom(address account, uint256 amount) public virtual {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
  }
}

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
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
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

/**
 * @dev String operations.
 */
library Strings {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
  enum RecoverError {
    NoError,
    InvalidSignature,
    InvalidSignatureLength,
    InvalidSignatureS,
    InvalidSignatureV
  }

  function _throwError(RecoverError error) private pure {
    if (error == RecoverError.NoError) {
      return; // no error: do nothing
    } else if (error == RecoverError.InvalidSignature) {
      revert("ECDSA: invalid signature");
    } else if (error == RecoverError.InvalidSignatureLength) {
      revert("ECDSA: invalid signature length");
    } else if (error == RecoverError.InvalidSignatureS) {
      revert("ECDSA: invalid signature 's' value");
    } else if (error == RecoverError.InvalidSignatureV) {
      revert("ECDSA: invalid signature 'v' value");
    }
  }

  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature` or error string. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   *
   * Documentation for signature generation:
   * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
   * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
   *
   * _Available since v4.3._
   */
  function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
    // Check the signature length
    // - case 65: r,s,v signature (standard)
    // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
    if (signature.length == 65) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      // ecrecover takes the signature parameters, and the only way to get them
      // currently is to use assembly.
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
      return tryRecover(hash, v, r, s);
    } else if (signature.length == 64) {
      bytes32 r;
      bytes32 vs;
      // ecrecover takes the signature parameters, and the only way to get them
      // currently is to use assembly.
      assembly {
        r := mload(add(signature, 0x20))
        vs := mload(add(signature, 0x40))
      }
      return tryRecover(hash, r, vs);
    } else {
      return (address(0), RecoverError.InvalidSignatureLength);
    }
  }

  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature`. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   */
  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, signature);
    _throwError(error);
    return recovered;
  }

  /**
   * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
   *
   * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
   *
   * _Available since v4.3._
   */
  function tryRecover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address, RecoverError) {
    bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    uint8 v = uint8((uint256(vs) >> 255) + 27);
    return tryRecover(hash, v, r, s);
  }

  /**
   * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
   *
   * _Available since v4.2._
   */
  function recover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, r, vs);
    _throwError(error);
    return recovered;
  }

  /**
   * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
   * `r` and `s` signature fields separately.
   *
   * _Available since v4.3._
   */
  function tryRecover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address, RecoverError) {
    // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
    // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
    // signatures from current libraries generate a unique signature with an s-value in the lower half order.
    //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
    // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
    // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
    // these malleable signatures as well.
    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return (address(0), RecoverError.InvalidSignatureS);
    }
    if (v != 27 && v != 28) {
      return (address(0), RecoverError.InvalidSignatureV);
    }

    // If the signature is valid (and not malleable), return the signer address
    address signer = ecrecover(hash, v, r, s);
    if (signer == address(0)) {
      return (address(0), RecoverError.InvalidSignature);
    }

    return (signer, RecoverError.NoError);
  }

  /**
   * @dev Overload of {ECDSA-recover} that receives the `v`,
   * `r` and `s` signature fields separately.
   */
  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
    _throwError(error);
    return recovered;
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from a `hash`. This
   * produces hash corresponding to the one signed with the
   * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
   * JSON-RPC method as part of EIP-191.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from `s`. This
   * produces hash corresponding to the one signed with the
   * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
   * JSON-RPC method as part of EIP-191.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
  }

  /**
   * @dev Returns an Ethereum Signed Typed Data, created from a
   * `domainSeparator` and a `structHash`. This produces hash corresponding
   * to the one signed with the
   * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
   * JSON-RPC method as part of EIP-712.
   *
   * See {recover}.
   */
  function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
  }
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
  /* solhint-disable var-name-mixedcase */
  // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
  // invalidate the cached domain separator if the chain id changes.
  bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
  uint256 private immutable _CACHED_CHAIN_ID;
  address private immutable _CACHED_THIS;

  bytes32 private immutable _HASHED_NAME;
  bytes32 private immutable _HASHED_VERSION;
  bytes32 private immutable _TYPE_HASH;

  /* solhint-enable var-name-mixedcase */

  /**
   * @dev Initializes the domain separator and parameter caches.
   *
   * The meaning of `name` and `version` is specified in
   * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
   *
   * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
   * - `version`: the current major version of the signing domain.
   *
   * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
   * contract upgrade].
   */
  constructor(string memory name, string memory version) {
    bytes32 hashedName = keccak256(bytes(name));
    bytes32 hashedVersion = keccak256(bytes(version));
    bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    _HASHED_NAME = hashedName;
    _HASHED_VERSION = hashedVersion;
    _CACHED_CHAIN_ID = block.chainid;
    _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
    _CACHED_THIS = address(this);
    _TYPE_HASH = typeHash;
  }

  /**
   * @dev Returns the domain separator for the current chain.
   */
  function _domainSeparatorV4() internal view returns (bytes32) {
    if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
      return _CACHED_DOMAIN_SEPARATOR;
    } else {
      return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
    }
  }

  function _buildDomainSeparator(
    bytes32 typeHash,
    bytes32 nameHash,
    bytes32 versionHash
  ) private view returns (bytes32) {
    return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
  }

  /**
   * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
   * function returns the hash of the fully encoded EIP712 message for this domain.
   *
   * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
   *
   * ```solidity
   * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
   *     keccak256("Mail(address to,string contents)"),
   *     mailTo,
   *     keccak256(bytes(mailContents))
   * )));
   * address signer = ECDSA.recover(digest, signature);
   * ```
   */
  function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
    return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
  }
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
  struct Counter {
    // This variable should never be directly accessed by users of the library: interactions must be restricted to
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    uint256 _value; // default: 0
  }

  function current(Counter storage counter) internal view returns (uint256) {
    return counter._value;
  }

  function increment(Counter storage counter) internal {
    unchecked {
      counter._value += 1;
    }
  }

  function decrement(Counter storage counter) internal {
    uint256 value = counter._value;
    require(value > 0, "Counter: decrement overflow");
    unchecked {
      counter._value = value - 1;
    }
  }

  function reset(Counter storage counter) internal {
    counter._value = 0;
  }
}

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
  using Counters for Counters.Counter;

  mapping(address => Counters.Counter) private _nonces;

  // solhint-disable-next-line var-name-mixedcase
  bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

  /**
   * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
   *
   * It's a good idea to use the same `name` that is defined as the ERC20 token name.
   */
  constructor(string memory name) EIP712(name, "1") {}

  /**
   * @dev See {IERC20Permit-permit}.
   */
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public virtual override {
    require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

    bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

    bytes32 hash = _hashTypedDataV4(structHash);

    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == owner, "ERC20Permit: invalid signature");

    _approve(owner, spender, value);
  }

  /**
   * @dev See {IERC20Permit-nonces}.
   */
  function nonces(address owner) public view virtual override returns (uint256) {
    return _nonces[owner].current();
  }

  /**
   * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
   */
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view override returns (bytes32) {
    return _domainSeparatorV4();
  }

  /**
   * @dev "Consume a nonce": return the current value and increment.
   *
   * _Available since v4.1._
   */
  function _useNonce(address owner) internal virtual returns (uint256 current) {
    Counters.Counter storage nonce = _nonces[owner];
    current = nonce.current();
    nonce.increment();
  }
}

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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

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

interface IDividendDistributor {
  function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

  function setShare(address shareholder, uint256 amount) external;

  function deposit() external payable;

  function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
  using SafeMath for uint256;

  address _token;

  struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
  }

  IERC20 BEP_TOKEN;

  address WBNB;
  IUniswapV2Router02 router;

  address[] shareholders;
  mapping(address => uint256) shareholderIndexes;
  mapping(address => uint256) shareholderClaims;

  mapping(address => Share) public shares;

  uint256 public totalShares;
  uint256 public totalDividends;
  uint256 public totalDistributed;
  uint256 public dividendsPerShare;
  uint256 public constant dividendsPerShareAccuracyFactor = 10**36;

  uint256 public minPeriod = 1 hours;
  uint256 public minDistribution = 1 * (10**18);

  uint256 currentIndex;
  address constant pancakeSwapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  bool initialized;
  modifier initialization() {
    require(!initialized);
    _;
    initialized = true;
  }

  modifier onlyFactory() {
    require(msg.sender == _token);
    _;
  }

  constructor(
    address _router,
    address _BEP_TOKEN,
    address _wbnb
  ) {
    router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(pancakeSwapV2Router);
    _token = msg.sender;
    BEP_TOKEN = IERC20(_BEP_TOKEN);
    WBNB = _wbnb;
  }

  function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyFactory {
    minPeriod = _minPeriod;
    minDistribution = _minDistribution;
  }

  function setShare(address shareholder, uint256 amount) external override onlyFactory {
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

  function deposit() external payable override onlyFactory {
    uint256 balanceBefore = BEP_TOKEN.balanceOf(address(this));

    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = address(BEP_TOKEN);
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(0, path, address(this), block.timestamp);

    uint256 amount = BEP_TOKEN.balanceOf(address(this)).sub(balanceBefore);

    totalDividends = totalDividends.add(amount);
    dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
  }

  function process(uint256 gas) external override onlyFactory {
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

  function shouldDistribute(address shareholder) internal view returns (bool) {
    return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
  }

  function distributeDividend(address shareholder) internal {
    if (shares[shareholder].amount == 0) {
      return;
    }

    uint256 amount = getUnpaidEarnings(shareholder);

    if (amount > 0) {
      totalDistributed = totalDistributed.add(amount);
      BEP_TOKEN.transfer(shareholder, amount);
      shareholderClaims[shareholder] = block.timestamp;
      shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
      shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
  }

  function claimDividend() external {
    distributeDividend(tx.origin);
  }

  function getTotalRealized() external view returns (uint256) {
    return shares[tx.origin].totalRealised;
  }

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

  function getCumulativeDividends(uint256 share) internal view returns (uint256) {
    return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
  }

  function addShareholder(address shareholder) internal {
    shareholderIndexes[shareholder] = shareholders.length;
    shareholders.push(shareholder);
  }

  function getShareholders() external view onlyFactory returns (address[] memory) {
    return shareholders;
  }

  function getShareholderAmount(address shareholder) external view returns (uint256) {
    return shares[shareholder].amount;
  }

  function removeShareholder(address shareholder) internal {
    shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
    shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
    shareholders.pop();
  }
}

contract DistributorFactory {
  using SafeMath for uint256;
  address _token;
  address _tokenHolder;

  struct structDistributors {
    DividendDistributor distributorAddress;
    uint256 index;
    string tokenName;
    bool exists;
  }

  struct structCustomReflections {
    uint256 index;
    address token_holder;
    address[] reflection_tokens;
    bool exists;
  }

  mapping(address => structDistributors) public distributorsMapping;
  address[] public distributorsArrayOfKeys;

  mapping(address => structCustomReflections) public customReflectionMapping;
  address[] customReflectionArrayOfKeys;
  address[] public defaultReflectionsAddress;

  uint256 maxCustomReflections = 3;

  bool customReflectionsOn = true;

  modifier onlyToken() {
    require(msg.sender == _token);
    _;
  }

  modifier onlyTokenHolder() {
    require(tx.origin == _tokenHolder);
    _;
  }

  constructor() {
    _token = msg.sender;
    _tokenHolder = tx.origin;
  }

  function customReflectionsExist(address[] memory _reflectionAddresses) internal view returns (bool) {
    bool state = true;
    uint256 arrayLength = _reflectionAddresses.length;
    for (uint256 i = 0; i < arrayLength; i++) {
      if (!distributorsMapping[_reflectionAddresses[i]].exists) {
        return false;
      }
    }

    return state;
  }

  function addDefaultReflections(address[] memory _defaultReflectionAddresses) external onlyToken {
    require((_defaultReflectionAddresses.length <= maxCustomReflections), "Max Custom Reflection Exceeded.");
    defaultReflectionsAddress = _defaultReflectionAddresses;
  }

  function getDefaultReflections() external view returns (address[] memory) {
    return defaultReflectionsAddress;
  }

  function addCustomReflections(address _owner, address[] memory _reflectionAddresses) external returns (bool) {
    require((_reflectionAddresses.length <= maxCustomReflections), "Max Custom Reflection Exceeded.");
    require(customReflectionsExist(_reflectionAddresses), "Address not in master list.");

    uint256 arrayLength = _reflectionAddresses.length;
    // Clean reflection array to hold new set.
    delete customReflectionMapping[_owner].reflection_tokens;
    //Check if we already have a mapping for token user
    if (!customReflectionMapping[_owner].exists) {
      customReflectionArrayOfKeys.push(_owner);
      if (customReflectionArrayOfKeys.length != 0) {
        customReflectionMapping[_owner].index = customReflectionArrayOfKeys.length - 1;
      } else {
        customReflectionMapping[_owner].index = 0;
      }
      customReflectionMapping[_owner].exists = true;
    }

    for (uint256 i = 0; i < arrayLength; i++) {
      customReflectionMapping[_owner].reflection_tokens.push(_reflectionAddresses[i]);
    }

    return true;
  }

  function getCustomReflections(address _owner) external view returns (address[] memory) {
    return customReflectionMapping[_owner].reflection_tokens;
  }

  function addDistributor(
    address _router,
    address _BEP_TOKEN,
    address _wbnb
  ) external onlyToken returns (bool) {
    require(!distributorsMapping[_BEP_TOKEN].exists, "Distributor already exists");

    IERC20Metadata BEP_TOKEN = IERC20Metadata(_BEP_TOKEN);
    DividendDistributor distributor = new DividendDistributor(_router, _BEP_TOKEN, _wbnb);

    distributorsArrayOfKeys.push(_BEP_TOKEN);
    distributorsMapping[_BEP_TOKEN].distributorAddress = distributor;
    distributorsMapping[_BEP_TOKEN].index = distributorsArrayOfKeys.length - 1;
    distributorsMapping[_BEP_TOKEN].tokenName = BEP_TOKEN.name();
    distributorsMapping[_BEP_TOKEN].exists = true;

    // set shares
    if (distributorsArrayOfKeys.length > 0) {
      address firstDistributerKey = distributorsArrayOfKeys[0];

      uint256 shareholdersCount = distributorsMapping[firstDistributerKey].distributorAddress.getShareholders().length;

      for (uint256 i = 0; i < shareholdersCount; i++) {
        address shareholderAddress = distributorsMapping[firstDistributerKey].distributorAddress.getShareholders()[i];

        uint256 shareholderAmount = distributorsMapping[firstDistributerKey].distributorAddress.getShareholderAmount(shareholderAddress);

        distributor.setShare(shareholderAddress, shareholderAmount);
      }
    }

    return true;
  }

  function getShareholderAmount(address _BEP_TOKEN, address shareholder) external view returns (uint256) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.getShareholderAmount(shareholder);
  }

  function claimDividend(address _BEP_TOKEN) external {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.claimDividend();
  }

  function getTotalRealized(address _BEP_TOKEN) external view returns (uint256) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.getTotalRealized();
  }

  function getUnpaidEarnings(address shareholder, address _BEP_TOKEN) external view returns (uint256) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress.getUnpaidEarnings(shareholder);
  }

  function deleteDistributor(address _BEP_TOKEN) external onlyToken returns (bool) {
    require(distributorsMapping[_BEP_TOKEN].exists, "Distributor not found");

    structDistributors memory deletedDistributer = distributorsMapping[_BEP_TOKEN];
    // if index is not the last entry
    if (deletedDistributer.index != distributorsArrayOfKeys.length - 1) {
      address lastAddress = distributorsArrayOfKeys[distributorsArrayOfKeys.length - 1];
      distributorsArrayOfKeys[deletedDistributer.index] = lastAddress;
      distributorsMapping[lastAddress].index = deletedDistributer.index;
    }
    delete distributorsMapping[_BEP_TOKEN];
    distributorsArrayOfKeys.pop();
    return true;
  }

  function getDistributorsAddresses() external view returns (address[] memory) {
    return distributorsArrayOfKeys;
  }

  function useCustomReflection(address _shareholder) internal view returns (bool) {
    bool state = true;
    if (!customReflectionsOn) {
      state = false;
    } else {
      if (!customReflectionMapping[_shareholder].exists) {
        state = false;
      }
    }
    return state;
  }

  /// @dev
  /// This functions runs through the contract's list of custom reflection token then
  /// checks if the shareholder has enabled that token as a reward before setting the share amount.

  function setShare(address shareholder, uint256 amount) external onlyToken {
    uint256 arrayLength = distributorsArrayOfKeys.length;
    if (useCustomReflection(shareholder)) {
      for (uint256 i = 0; i < arrayLength; i++) {
        // Looping through master set of reflections
        for (uint256 j = 0; j < customReflectionMapping[shareholder].reflection_tokens.length; j++) {
          //looping through tokenHolder custom reflection list
          if (distributorsArrayOfKeys[i] == customReflectionMapping[shareholder].reflection_tokens[j]) {
            distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.setShare(shareholder, amount);
          }
        }
      }
    } else {
      // use default reflection code
      uint256 defaultReflectionArrayLength = defaultReflectionsAddress.length;
      for (uint256 i = 0; i < defaultReflectionArrayLength; i++) {
        distributorsMapping[defaultReflectionsAddress[i]].distributorAddress.setShare(shareholder, amount);
      }
    }
  }

  function process(uint256 gas) external onlyToken {
    uint256 arrayLength = distributorsArrayOfKeys.length;
    for (uint256 i = 0; i < arrayLength; i++) {
      distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.process(gas);
    }
  }

  function deposit() external payable onlyToken {
    uint256 arrayLength = distributorsArrayOfKeys.length;
    uint256 valuePerToken = msg.value.div(arrayLength);

    for (uint256 i = 0; i < arrayLength; i++) {
      distributorsMapping[distributorsArrayOfKeys[i]].distributorAddress.deposit{ value: valuePerToken }();
    }
  }

  function getDistributor(address _BEP_TOKEN) external view returns (DividendDistributor) {
    return distributorsMapping[_BEP_TOKEN].distributorAddress;
  }

  function getTotalDistributers() external view returns (uint256) {
    return distributorsArrayOfKeys.length;
  }

  function getMaxUserReflections() external view returns (uint256) {
    return maxCustomReflections;
  }

  function setMaxUserReflection(uint256 _maxReflections) external onlyToken {
    maxCustomReflections = _maxReflections;
  }

  function isCustomReflectionActive() external view returns (bool) {
    return customReflectionsOn;
  }

  function setCustomReflectionToOn(bool state) external onlyToken {
    customReflectionsOn = state;
  }

  function setDistributionCriteria(
    address _BEP_TOKEN,
    uint256 _minPeriod,
    uint256 _minDistribution
  ) external onlyToken {
    distributorsMapping[_BEP_TOKEN].distributorAddress.setDistributionCriteria(_minPeriod, _minDistribution);
  }
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  /**
   * Function modifier to require caller to be contract owner
   */
  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  /**
   * Function modifier to require caller to be authorized
   */
  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  /**
   * Authorize address. Owner only
   */
  function authorize(address adr) external onlyOwner {
    authorizations[adr] = true;
  }

  /**
   * Remove address' authorization. Owner only
   */
  function unauthorize(address adr) external onlyOwner {
    authorizations[adr] = false;
  }

  /**
   * Check if address is owner
   */
  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  /**
   * Return address' authorization status
   */
  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }
}

contract PepperBirdToken is Auth, ERC20, ERC20Burnable, ERC20Permit {
  string public contractBuild = "9";
  using SafeMath for uint256;
  mapping(address => bool) private _isBot;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  mapping(address => bool) public buyBacker;
  mapping(address => bool) public isFeeExempt;
  mapping(address => bool) public isDividendExempt;
  mapping(address => bool) isTxLimitExempt;

  address private constant DEAD = address(0xdead);
  address private constant ZERO = address(0);
  uint256 public constant NEW_OWNER_DELAY_TIME_MS = 172800000; // 48 Hours in Milliseconds

  IUniswapV2Router02 public router;

  address public pair;

  uint256 public liquidityFee; // default: 300
  uint256 public buybackFee; // default: 050
  uint256 public reflectionFee; // default: 600
  uint256 public marketingFee; // default: 100
  uint256 public charityFee; // default 100;
  uint256 public gasWalletFee; // default: 050
  uint256 public totalFee; // default: 12%
  uint256 public feeDenominator; // default: 10000

  address public autoLiquidityReceiver;
  address public marketingFeeReceiver;
  address public charityFeeReceiver;
  address public gasWalletFeeReceiver;

  uint256 public targetLiquidity; // default: 25
  uint256 public targetLiquidityDenominator; // default: 100

  uint256 public buybackMultiplierNumerator; // default: 200
  uint256 public buybackMultiplierDenominator; // default: 100
  uint256 public buybackMultiplierTriggeredAt;
  uint256 public buybackMultiplierLength; // default: 30 mins

  uint256 public maxWalletToken;

  bool public autoBuybackEnabled;

  bool public isPostLaunchMode;
  bool public isReflectionOnTimer;

  uint256 public autoBuybackCap;
  uint256 public autoBuybackAccumulator;
  uint256 public autoBuybackAmount;
  uint256 public autoBuybackBlockPeriod;
  uint256 public autoBuybackBlockLast;
  address public futureOwnershipTransferAddress;
  uint256 private _futureOwnershipTransferAddressInitTime;

  DistributorFactory distributor;

  uint256 public distributorGas;

  bool public swapEnabled;
  uint256 public swapThreshold;

  bool inSwap;
  modifier swapping() {
    inSwap = true;
    _;
    inSwap = false;
  }

  event Log(string message);
  event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
  event BuybackMultiplierActive(uint256 duration);

  event OwnershipTransferred(address owner);
  event DistributionCriteriaUpdated(address indexed bepToken, uint256 minPeriod, uint256 minDistribution);
  event MaxNumberReflectionUpdated(uint256 amount);
  event AutoBuyBackSettingsUpdated(bool enabled, uint256 cap, uint256 amount, uint256 period);
  event BuyBackMultiplierSettingsUpdated(uint256 numerator, uint256 deonimator, uint256 length);
  event SwapBackSettingsUpdated(bool enabled, uint256 amount);
  event TargetLiquidityUpdated(uint256 target, uint256 denominator);

  error WalletLimitReached(uint256 walletBalance, uint256 proposedWalletBalance, uint256 walletMaxBalance);
  error TransferAddressNotWhitelisted(address transferAddress);

  modifier onlyBuybacker() {
    require(buyBacker[msg.sender], "Not a buybacker");
    _;
  }

  constructor(address router_) payable Auth(msg.sender) ERC20("PEPPERBIRD", "PBIRD") ERC20Permit("PEPPERBIRD") {
    _mint(msg.sender, 100000000000000 * 10**decimals());

    uint256[7] memory feeSettings_;
    feeSettings_[0] = 300;
    // Liquidity Fee
    feeSettings_[1] = 50;
    // BuyBackFee
    feeSettings_[2] = 600;
    // ReflectionFee
    feeSettings_[3] = 100;
    // MarketingFee
    feeSettings_[4] = 100;
    // CharityFee
    feeSettings_[5] = 50;
    // GasWalletFee
    feeSettings_[6] = 10000;
    // Denominator

    maxWalletToken = (totalSupply() * 3) / 100;
    //set at 3%

    router = IUniswapV2Router02(router_);

    pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

    distributor = new DistributorFactory();

    _initializeFees(feeSettings_);
    _initializeLiquidityBuyBack();

    distributorGas = 500000;
    swapEnabled = true;
    swapThreshold = totalSupply() / 20000;

    isFeeExempt[msg.sender] = true;
    isTxLimitExempt[msg.sender] = true;
    isDividendExempt[pair] = true;
    isDividendExempt[address(this)] = true;
    isDividendExempt[DEAD] = true;
    buyBacker[msg.sender] = true;
    isPostLaunchMode = false;
    isReflectionOnTimer = false;

    autoLiquidityReceiver = msg.sender;
    marketingFeeReceiver = msg.sender;
    charityFeeReceiver = msg.sender;
    gasWalletFeeReceiver = msg.sender;

    _allowances[address(this)][address(router)] = totalSupply();
    _allowances[address(this)][address(pair)] = totalSupply();

    approve(router_, totalSupply());
    approve(address(pair), totalSupply());

    _balances[msg.sender] = totalSupply();

    emit Transfer(address(0), msg.sender, totalSupply());
    emit Log("Token Created");
  }

  receive() external payable {}

  ///////////// PUBLIC/EXTERNAL

  function airdrop(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
    uint256 PBT = 0;

    require(addresses.length == tokens.length, "Mismatch between Address and token count");

    for (uint256 i = 0; i < addresses.length; i++) {
      PBT = PBT + tokens[i];
    }

    require(balanceOf(msg.sender) >= PBT, "Not enough tokens in wallet for airdrop");

    for (uint256 i = 0; i < addresses.length; i++) {
      _basicTransfer(msg.sender, addresses[i], tokens[i]);
      if (isPostLaunchMode) {
        if (!isDividendExempt[addresses[i]]) {
          try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {}
        }
      }
    }

    // Dividend tracker
    if (isPostLaunchMode) {
      if (!isDividendExempt[msg.sender]) {
        try distributor.setShare(msg.sender, _balances[msg.sender]) {} catch {}
      }
    }
  }

  function addCustomReflections(address[] memory _customReflections) external {
    address _owner = msg.sender;
    distributor.addCustomReflections(_owner, _customReflections);
  }

  function addDefaultReflections(address[] memory _defaultReflectionAddresses) external authorized {
    distributor.addDefaultReflections(_defaultReflectionAddresses);
  }

  function addDistributor(
    address _Router,
    address _BEP_TOKEN,
    address _WBNB
  ) external authorized {
    distributor.addDistributor(_Router, _BEP_TOKEN, _WBNB);
  }

  function bulkAntiBot(address[] memory accounts, bool state) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
      _isBot[accounts[i]] = state;
    }
  }

  function claimDividend(address _BEP_TOKEN) external {
    return distributor.claimDividend(_BEP_TOKEN);
  }

  function clearBuybackMultiplier() external authorized {
    buybackMultiplierTriggeredAt = 0;
  }

  function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
    uint256 amountBNB = address(this).balance;
    payable(marketingFeeReceiver).transfer((amountBNB * amountPercentage) / 100);
  }

  function deleteDistributor(address _BEP_TOKEN) external authorized {
    distributor.deleteDistributor(_BEP_TOKEN);
  }

  function getChainID() external view returns (uint256) {
    return block.chainid;
  }

  function getCustomReflections() external view returns (address[] memory) {
    address _owner = msg.sender;
    return distributor.getCustomReflections(_owner);
  }

  function getCirculatingSupply() public view returns (uint256) {
    return totalSupply().sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
  }

  function getDefaultReflections() external view returns (address[] memory) {
    return distributor.getDefaultReflections();
  }

  function getDistributer(address _BEP_TOKEN) external view returns (DividendDistributor) {
    return distributor.getDistributor(_BEP_TOKEN);
  }

  function getDistributersBEP20Keys() external view returns (address[] memory) {
    return distributor.getDistributorsAddresses();
  }

  function getDistributorFactory() external view returns (DistributorFactory) {
    return distributor;
  }

  function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
    return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
  }

  function getMaxUserReflections() external view returns (uint256) {
    return distributor.getMaxUserReflections();
  }

  function getMultipliedFee() public view returns (uint256) {
    if (buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp) {
      uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
      uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
      return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }
    return totalFee;
  }

  function getPairContract() external view returns (address) {
    return _getPairContract();
  }

  function getShareholderAmount(address _BEP_TOKEN, address shareholder) external view returns (uint256) {
    return distributor.getShareholderAmount(_BEP_TOKEN, shareholder);
  }

  function getTotalDividends(address _BEP_TOKEN) external view returns (uint256) {
    DividendDistributor singleDistributor = distributor.getDistributor(_BEP_TOKEN);
    return singleDistributor.totalDividends();
  }

  function getTotalFee(bool selling) public view returns (uint256) {
    if (selling) {
      return getMultipliedFee();
    }
    return totalFee;
  }

  function getTotalRealized(address _BEP_TOKEN) external view returns (uint256) {
    return distributor.getTotalRealized(_BEP_TOKEN);
  }

  function getUnpaidEarnings(address shareholder, address _BEP_TOKEN) external view returns (uint256) {
    return distributor.getUnpaidEarnings(shareholder, _BEP_TOKEN);
  }

  function isBot(address account) public view returns (bool) {
    return _isBot[account];
  }

  function isCustomReflectionActive() external view returns (bool) {
    return distributor.isCustomReflectionActive();
  }

  function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
    return getLiquidityBacking(accuracy) > target;
  }

  function processReflections() external authorized {
    try distributor.process(distributorGas) {} catch {}
  }

  function rescueAnyBEP20Tokens(
    address _tokenAddress,
    address _to,
    uint256 _amount
  ) public onlyOwner {
    require(_tokenAddress != address(this), "Cannot transfer out Token123!");
    IERC20(_tokenAddress).transfer(_to, _amount);
  }

  function rescueBNB(uint256 weiAmount) external onlyOwner {
    require(address(this).balance >= weiAmount, "insufficient BNB balance");
    payable(msg.sender).transfer(weiAmount);
  }

  function setAntibot(address account, bool state) external onlyOwner {
    require(_isBot[account] != state, "Value already set");
    _isBot[account] = state;
  }

  function setAutoBuybackSettings(
    bool _enabled,
    uint256 _cap,
    uint256 _amount,
    uint256 _period
  ) external authorized {
    autoBuybackEnabled = _enabled;
    autoBuybackCap = _cap;
    autoBuybackAccumulator = 0;
    autoBuybackAmount = _amount;
    autoBuybackBlockPeriod = _period;
    autoBuybackBlockLast = block.number;
    emit AutoBuyBackSettingsUpdated(_enabled, _cap, _amount, _period);
  }

  function setBuyBacker(address acc, bool add) external authorized {
    buyBacker[acc] = add;
  }

  function setBuybackMultiplierSettings(
    uint256 numerator,
    uint256 denominator,
    uint256 length
  ) external authorized {
    require(numerator / denominator <= 2 && numerator > denominator);
    buybackMultiplierNumerator = numerator;
    buybackMultiplierDenominator = denominator;
    buybackMultiplierLength = length;
    emit BuyBackMultiplierSettingsUpdated(numerator, denominator, length);
  }

  function setCustomReflectionToOn(bool state) external authorized {
    distributor.setCustomReflectionToOn(state);
  }

  function setDistributionCriteria(
    address _BEP_TOKEN,
    uint256 _minPeriod,
    uint256 _minDistribution
  ) external authorized {
    distributor.setDistributionCriteria(_BEP_TOKEN, _minPeriod, _minDistribution);
    emit DistributionCriteriaUpdated(_BEP_TOKEN, _minPeriod, _minDistribution);
  }

  function setDistributorSettings(uint256 gas) external authorized {
    distributorGas = gas;
  }

  function setFees(
    uint256 _liquidityFee,
    uint256 _buybackFee,
    uint256 _reflectionFee,
    uint256 _marketingFee,
    uint256 _charityFee,
    uint256 _gasWalletFee,
    uint256 _feeDenominator
  ) external authorized {
    _setFees(_liquidityFee, _buybackFee, _reflectionFee, _marketingFee, _charityFee, _gasWalletFee, _feeDenominator);
  }

  function setFeeReceivers(
    address _autoLiquidityReceiver,
    address _marketingFeeReceiver,
    address _charityFeeReceiver,
    address _gasWalletReceiver
  ) external authorized {
    autoLiquidityReceiver = _autoLiquidityReceiver;
    marketingFeeReceiver = _marketingFeeReceiver;
    charityFeeReceiver = _charityFeeReceiver;
    gasWalletFeeReceiver = _gasWalletReceiver;
  }

  function setFutureOwnershipTransferAddress(address _address) external onlyOwner {
    futureOwnershipTransferAddress = _address;
    _futureOwnershipTransferAddressInitTime = block.timestamp.add(NEW_OWNER_DELAY_TIME_MS);
  }

  function setIsDividendExempt(address holder, bool exempt) external authorized {
    require(holder != address(this) && holder != pair);
    isDividendExempt[holder] = exempt;
    if (exempt) {
      distributor.setShare(holder, 0);
    } else {
      distributor.setShare(holder, _balances[holder]);
    }
  }

  function setIsFeeExempt(address holder, bool exempt) external authorized {
    isFeeExempt[holder] = exempt;
  }

  function setIsPostLaunch(bool state) external authorized {
    isPostLaunchMode = state;
  }

  function setMaxUserReflections(uint256 amount) external authorized {
    distributor.setMaxUserReflection(amount);
    emit MaxNumberReflectionUpdated(amount);
  }

  function setMaxWalletPercent(uint256 _maxWalletPercent) external onlyOwner {
    require(_maxWalletPercent >= 3, "Max wallet can not be less than 3%");
    maxWalletToken = (totalSupply() * _maxWalletPercent) / 100;
  }

  function setReflectionOnTimer(bool state) external authorized {
    isReflectionOnTimer = state;
  }

  function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
    swapEnabled = _enabled;
    swapThreshold = _amount;
    emit SwapBackSettingsUpdated(_enabled, _amount);
  }

  function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
    targetLiquidity = _target;
    targetLiquidityDenominator = _denominator;
    emit TargetLiquidityUpdated(_target, _denominator);
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    return _transferFrom(msg.sender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    if (_allowances[sender][msg.sender] != totalSupply()) {
      _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
    }

    return _transferFrom(sender, recipient, amount);
  }

  function transferOwnership(address payable adr) external onlyOwner {
    if (!_isTransferAddressConfirmed(adr)) {
      revert TransferAddressNotWhitelisted({ transferAddress: adr });
    }
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
    _buyTokens(amount, DEAD);
    if (triggerBuybackMultiplier) {
      buybackMultiplierTriggeredAt = block.timestamp;
      emit BuybackMultiplierActive(buybackMultiplierLength);
    }
  }

  ///////////// INTERNAL/PRIVATE

  function _basicTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function _buyTokens(uint256 amount, address to) internal swapping {
    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = address(this);

    router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(0, path, to, block.timestamp);
  }

  function _getPairContract() internal view returns (address) {
    address pairContract = IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
    return pairContract;
  }

  function _initializeFees(uint256[7] memory feeSettings_) internal {
    _setFees(
      feeSettings_[0], // liquidityFee
      feeSettings_[1], // buybackFee
      feeSettings_[2], // reflectionFee
      feeSettings_[3], // marketingFee
      feeSettings_[4], // charityFee
      feeSettings_[5], // gasFee
      feeSettings_[6] // feeDenominator
    );
  }

  function _initializeLiquidityBuyBack() internal {
    targetLiquidity = 25;
    targetLiquidityDenominator = 100;

    buybackMultiplierNumerator = 200;
    buybackMultiplierDenominator = 100;
    buybackMultiplierLength = 30 minutes;
  }

  function _isTransferAddressConfirmed(address _address) internal view returns (bool) {
    bool _state = false;
    if ((block.timestamp <= _futureOwnershipTransferAddressInitTime) && (_address == futureOwnershipTransferAddress)) {
      _state = true;
    }
    return _state;
  }

  function _setAllowance(
    address owner,
    address spender,
    uint256 wad
  ) internal virtual returns (bool) {
    _allowances[owner][spender] = wad;
    emit Approval(owner, spender, wad);

    return true;
  }

  function _setFees(
    uint256 _liquidityFee,
    uint256 _buybackFee,
    uint256 _reflectionFee,
    uint256 _marketingFee,
    uint256 _charityFee,
    uint256 _gasWalletFee,
    uint256 _feeDenominator
  ) internal {
    liquidityFee = _liquidityFee;
    buybackFee = _buybackFee;
    reflectionFee = _reflectionFee;
    marketingFee = _marketingFee;
    charityFee = _charityFee;
    gasWalletFee = _gasWalletFee;
    totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee).add(_charityFee);
    totalFee = totalFee.add(_gasWalletFee);
    feeDenominator = _feeDenominator;
    require(totalFee < feeDenominator / 4, "Total fee should not be greater than 1/4 of fee denominator");
  }

  function _shouldAutoBuyback() internal view returns (bool) {
    return
      msg.sender != pair &&
      !inSwap &&
      autoBuybackEnabled &&
      autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number && // After N blocks from last buyback
      address(this).balance >= autoBuybackAmount;
  }

  function _shouldSwapBack() internal view returns (bool) {
    return msg.sender != pair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
  }

  function _shouldTakeFee(address sender) internal view returns (bool) {
    return !isFeeExempt[sender];
  }

  function _swapBack() internal swapping {
    uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
    uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
    uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();
    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

    uint256 amountBNB = address(this).balance.sub(balanceBefore);

    uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));

    uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
    uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
    uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
    uint256 amountBNBCharity = amountBNB.mul(charityFee).div(totalBNBFee);
    uint256 amountBNBGasWallet = amountBNB.mul(gasWalletFee).div(totalBNBFee);

    try distributor.deposit{ value: amountBNBReflection }() {} catch {}
    payable(marketingFeeReceiver).transfer(amountBNBMarketing);
    payable(charityFeeReceiver).transfer(amountBNBCharity);
    payable(gasWalletFeeReceiver).transfer(amountBNBGasWallet);

    if (amountToLiquify > 0) {
      router.addLiquidityETH{ value: amountBNBLiquidity }(address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);
      emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
    }
  }

  function _takeFee(
    address sender,
    address receiver,
    uint256 amount
  ) internal returns (uint256) {
    uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

    _balances[address(this)] = _balances[address(this)].add(feeAmount);
    emit Transfer(sender, address(this), feeAmount);

    return amount.sub(feeAmount);
  }

  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    require(!_isBot[sender] && !_isBot[recipient], "You are a bot");
    if (inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }
    // Setting Max Available In Wallet
    if (
      isPostLaunchMode &&
      !authorizations[sender] &&
      recipient != address(this) &&
      recipient != address(DEAD) &&
      recipient != pair &&
      recipient != marketingFeeReceiver &&
      recipient != autoLiquidityReceiver
    ) {
      uint256 heldTokens = balanceOf(recipient);
      if ((heldTokens + amount) > maxWalletToken) {
        revert WalletLimitReached({ walletBalance: heldTokens, proposedWalletBalance: (heldTokens + amount), walletMaxBalance: maxWalletToken });
      }
    }

    if (_shouldSwapBack()) {
      _swapBack();
    }
    if (_shouldAutoBuyback()) {
      _triggerAutoBuyback();
    }

    _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

    uint256 amountReceived = amount;
    // DISABLE FEEs PreLaunch
    if (isPostLaunchMode) {
      amountReceived = _shouldTakeFee(sender) ? _takeFee(sender, recipient, amount) : amount;
    }

    _balances[recipient] = _balances[recipient].add(amountReceived);

    // DISABLE Dividends PreLaunch
    if (isPostLaunchMode) {
      if (!isDividendExempt[sender]) {
        try distributor.setShare(sender, _balances[sender]) {} catch {}
      }
      if (!isDividendExempt[recipient]) {
        try distributor.setShare(recipient, _balances[recipient]) {} catch {}
      }
      if (!isReflectionOnTimer) {
        try distributor.process(distributorGas) {} catch {}
      }
    }

    emit Transfer(sender, recipient, amountReceived);
    return true;
  }

  function _triggerAutoBuyback() internal {
    _buyTokens(autoBuybackAmount, DEAD);
    autoBuybackBlockLast = block.number;
    autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
    if (autoBuybackAccumulator > autoBuybackCap) {
      autoBuybackEnabled = false;
    }
  }
}