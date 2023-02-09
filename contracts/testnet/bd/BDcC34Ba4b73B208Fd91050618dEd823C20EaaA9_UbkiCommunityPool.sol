// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
 * @dev Wrappers over Solidity's arithmetic operations.
 */
library FMaths {
  uint8 constant decimalsDefault = 18;

  /*
   * @dev Returns the addition of two uint256 (a + b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert (c >= a);
    assert (c >= b);
    return c;
  }
  function add(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = a + b;
    assert (result >= a);
    assert (result >= b);
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function add(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    uint8 deltaDecimalsA = decimalsDefault - decimalsA;
    uint8 deltaDecimalsB = decimalsDefault - decimalsB;
    uint256 result = add(a * 10 ** uint256(deltaDecimalsA), b * 10 ** uint256(deltaDecimalsB));
    return result;
  }
  function add(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint8 deltaDecimalsA = decimalsDefault - decimalsA;
    uint8 deltaDecimalsB = decimalsDefault - decimalsB;
    uint256 result = add(a * 10 ** uint256(deltaDecimalsA), b * 10 ** uint256(deltaDecimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the substraction of two uint256 (a - b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a - b;
    assert (c <= a);
    return c;
  }
  function sub(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = a - b;
    assert (result <= a);
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function sub(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return sub(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function sub(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = sub(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the multiplication of two uint256 (a * b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = (a * b) / (10 ** decimalsDefault);
    return c;
  }
  function mul(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = mul(a, b);
    return result / 10 ** uint256(decimalsDefault - decimalsOut);
  }
  function mul(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    uint8 deltaDecimalsA = decimalsDefault - decimalsA;
    uint8 deltaDecimalsB = decimalsDefault - decimalsB;
    return mul(a * 10 ** uint256(deltaDecimalsA), b * 10 ** uint256(deltaDecimalsB));
  }
  function mul(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = mul(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the division of two uint256 (a / b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * (10 ** decimalsDefault) / b;
  }
  function div(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = div(a, b);
    return result / 10 ** uint256(decimalsDefault - decimalsOut);
  }
  function div(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return div(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function div(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = div(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the maximum between two values
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? a : b;
  }
  function max(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    return max(a, b) / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function max(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return max(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function max(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = max(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the minimum between two values
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? b : a;
  }
  function min(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    return min(a, b) / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function min(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return min(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function min(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = min(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the squre root of a value
   * @param x
   * @param decimalsX [optional] the number of floating points for x
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function sqrt(uint256 _x) internal pure returns (uint256 result) {
    uint256 x = _x * 10 ** decimalsDefault;
    if (x == 0) {
        return 0;
    }

    // Calculate the square root of the perfect square of a power of two that is the closest to x.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 0x100000000000000000000000000000000) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 0x10000000000000000) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 0x100000000) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 0x10000) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 0x100) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 0x10) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 0x8) {
        result <<= 1;
    }

    // The operations can never overflow because the result is max 2^127 when it enters this block.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1; // Seven iterations should be enough
        uint256 roundedDownResult = x / result;
        return result >= roundedDownResult ? roundedDownResult : result;
    }
  }
  function sqrt(uint256 x, uint8 decimalsX) internal pure returns (uint256 result) {
    assert (decimalsX <= decimalsDefault);
    return sqrt(x * (10 ** uint256(decimalsDefault - decimalsX)));
  }
  function sqrt(uint256 x, uint8 decimalsX, uint8 decimalsOut) internal pure returns (uint256 result) {
    assert (decimalsX <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    return sqrt(x * (10 ** uint256(decimalsDefault - decimalsX))) / (10 ** uint256(decimalsDefault - decimalsOut));
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./UbkiToken.sol";
import "./FloatingMaths.sol";

contract UbkiCommunityPool is Ownable {
    UbkiToken public ubkiToken;
    uint public deployDate;
    uint public counterDistribution;

    constructor(address _ubkiToken) {
        ubkiToken = UbkiToken(_ubkiToken);
        deployDate = block.timestamp;
        counterDistribution = 365;
    }

    /*
     * @dev Distributes 3 percent of the UbkiToken it contains to UBKI DAO.
     * Can only be called at most once every 30 days.
     */
    function distribute() public onlyOwner {
        uint lastMonth = deployDate + counterDistribution * 1 days;
        require(
            block.timestamp >= lastMonth,
            "Need to wait 30 days after last distribution"
        );
        uint availableAmount = (ubkiToken.balanceOf(address(this)) * 3) / 100; // 3 percent of the UbkiTokens in the pool
        ubkiToken.transfer(owner(), availableAmount);
        counterDistribution += 30;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UbkiToken is ERC20, ERC20Capped, Ownable {
    uint256 public totalTokenMinted;
    uint256 public totalTokenBurnt;

    constructor() ERC20("UbkiToken", "AAT") ERC20Capped(15 * 10 ** (8 + 18)) {}

    /*
     * @dev Create tokens. Only callable from owner.
     * @param to The address to mint tokens for.
     * @param amount The amount to be minted.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        totalTokenMinted += amount;
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Capped) {
        super._mint(to, amount);
    }

    /*
     * @dev Destroy tokens. Used when certifying water.
     * @param amount The amount to burn.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        totalTokenBurnt += amount;
    }
}