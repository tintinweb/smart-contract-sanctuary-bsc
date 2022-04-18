/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/Dividend/Math/SafeMathInt.sol



/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity 0.8.0;

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

// File: contracts/Dividend/Math/SafeMathUint.sol



pragma solidity 0.8.0;

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

// File: contracts/Dividend/DividendPayingTokenOptionalInterface.sol



pragma solidity 0.8.0;


/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.
interface DividendPayingTokenOptionalInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}

// File: contracts/Dividend/DividendPayingTokenInterface.sol



pragma solidity 0.8.0;


/// @title Dividend-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a dividend-paying token contract.
interface DividendPayingTokenInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) external view returns(uint256);


  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawDividend() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their dividend.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: contracts/Dividend/DividendPayingToken.sol



pragma solidity 0.8.0;








/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay and distribute ether
///  to token holders as dividends and allows token holders to withdraw their dividends.
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

// USDT for testnet 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
// USDC mainnet 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
  address public USDC = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // USDC


  // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
  // For more discussion about choosing the value of `magnitude`,
  //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;

  // About dividendCorrection:
  // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
  //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
  // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
  //   `dividendOf(_user)` should not be changed,
  //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
  // To keep the `dividendOf(_user)` unchanged, we add a correction term:
  //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
  //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
  //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
  // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  uint256 public totalDividendsDistributed;

  constructor(string memory _name, string memory _symbol) public ERC20(_name, _symbol) {}

  function setRewardToken(address reward) public onlyOwner {
      USDC = reward;
  }

  function distributeUSDCDividends(uint256 amount) public onlyOwner{
    require(totalSupply() > 0, "no supply");

    if (amount > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (amount).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, amount);

      totalDividendsDistributed = totalDividendsDistributed.add(amount);
    }
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
 function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      emit DividendWithdrawn(user, _withdrawableDividend);
      bool success = IERC20(USDC).transfer(user, _withdrawableDividend);

      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
      }

      return _withdrawableDividend;
    }

    return 0;
  }


  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) public view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }

  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    return withdrawnDividends[_owner];
  }


  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }

  /// @dev Internal function that transfer tokens from one address to another.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param from The address to transfer from.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);

    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }

  /// @dev Internal function that mints tokens to an account.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param account The account that will receive the created tokens.
  /// @param value The amount that will be created.
  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  /// @dev Internal function that burns an amount of the token of a given account.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param account The account whose tokens will be burnt.
  /// @param value The amount that will be burnt.
  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);

    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


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

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

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

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: contracts/Aria.sol


//
// GET PASSIVE INCOME WITH ARIA
// you’ll receive USD Coin (USDC) Stable coing as reward.
// Hold $Aria tokens and get rewarded on every transaction that is made!
// Web: https://ariatoken.com/
// Discord: https://discord.gg/yfuyJfpARv
// Twitter: https://twitter.com/AriaToken 
// Telegram: https://t.me/realariatoken 

pragma solidity 0.8.0;








contract Aria is ERC20, Ownable {
    using SafeMath for uint256;

    struct ChainLinkPricePair {
        int price;
        uint timestamp;
    }

    struct HistoricalPairs {
        uint timestamp;
        mapping (string => ChainLinkPricePair) pairs;
    }

    uint oneHour = 600; // 3600
    uint twentyFourHours = 3600; // 86400
    uint oneWeek = 7200; // 604800 
    uint lastUpdateTimestamp = 0;
    uint checkItemIndex = 6; // 24

    mapping (string => AggregatorV3Interface) public chainLinkPriceFeed;
    mapping (string => ChainLinkPricePair) public latestPrices;

    string totalMarketcapCryptoUsd = "totalMarketcapCryptoUsd";
    string spyUsd = "SPY/USD";

    string[] pairs = [totalMarketcapCryptoUsd, spyUsd];

    mapping (uint => HistoricalPairs) public histPairs;
    uint public numberOfItems = 0;
    uint public indexOfLatestItem = 1;
    uint public indexOfOldestItem = 1;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    AriaDividendTracker public dividendTracker;

    address public deadWallet = address(0x000000000000000000000000000000000000dEaD);
    address public zeroWallet = address(0x0000000000000000000000000000000000000000);

    // USDT for testnet 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    // USDC mainnet 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
    address public USDC = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // USDC
    
    address public _marketingWalletAddress = 0x1791CA66c0d661a2083C333166D8a4F452B42658; // dev / marketing wallet
    address public _treasuryWalletAddress = 0x6CB6E25F44375C197748B10e70bE587203a15c2F;  // treasury multisig wallet
    
    mapping(address => bool) public _isBlacklisted;

    uint256 public constant MAX_TAX_BRACKET_FEE_RATE = 5;
    uint256 public taxBracketMultiplier = 5;
    uint256 private constant maxBracketTax = 10; // max bracket is holding 10%
    bool public isTaxBracketEnabled = true;

    uint256 public targetLiquidity = 50;
    uint256 public targetLiquidityDenominator = 100;

    uint256 public mintQuantityCurrentWeek = 0;
    uint256 public mintQuantityPreviousWeek = 0;
    uint256 public burnQuantityCurrentWeek = 0;
    uint256 public burnQuantityPreviousWeek = 0;
    uint256 public burnMintTimetracker = 0;

    uint256 public USDCRewardsFee = 7; // 5 - 10
    uint256 public treasuryFee = 2;    // 1 - 5
    uint256 public liquidityFee = 3;   // 1 - 5
    uint256 public marketingFee = 3;   // 1 - 5
    uint256 public totalConfigFees = USDCRewardsFee.add(liquidityFee).add(marketingFee).add(treasuryFee);

    uint256 public _maxTotalFee = 15;
    uint256 public _minMintBurnFee = 0;
    uint256 public _maxMintBurnFee = 3;
    uint256 public _minUSDCRewardsFee = 5;
    uint256 public _maxUSDCRewardsFee = 10;
    uint256 public _minLiquidityTreasuryDevMarketingFee = 1;
    uint256 public _maxLiquidityTreasuryDevMarketingFee = 5;

    bool public takeFeeEnabled = true;
    bool public transferEnabled = true;
    bool public blackHoleBurnEnabled = true;
    bool public burnEnabled = false;
    bool public mintEnabled = false;

    uint256 public _minTokenSupply = 1000000000 * (10**18); // 1Billion min supply 
    uint256 public _maxTokenSupply = 10000000000 * (10**18); // 10Billion max supply 
    uint256 public _initialLauchSupply = 1500000000 * (10**18); // 1.5Billion max supply 


     // exlcude from fees and max transaction amount
    mapping (address => bool) public _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
    address[] public _markerPairs;
    uint256 public _markerPairCount;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityRate(string s, uint v);
    event HistoricPriceWeight(string s, string ss, bool b, string sss, uint v);
    event BurnOrMint(string s, uint v, string sss, uint vv);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event SetTaxBracketFeeMultiplier(uint256 indexed state, uint256 indexed time);
    event SetTaxBracket(bool indexed value, uint256 indexed time);
    event SetBlackHoldBurn(bool indexed value, uint256 indexed time);
    event SetMint(bool indexed value, uint256 indexed time);
    event SetBurn(bool indexed value, uint256 indexed time);
    event SetTransfer(bool indexed value, uint256 indexed time);
    event SetTakeFee(bool indexed value, uint256 indexed time);

    constructor() public ERC20("Aria", "ARIA") {

    	dividendTracker = new AriaDividendTracker();

        chainLinkPriceFeed[totalMarketcapCryptoUsd] = AggregatorV3Interface(0x1a602D4928faF0A153A520f58B332f9CAFF320f7); // for prod 0xA7dd120a00aCf4161FdA187b864b73bdc8283D77
        chainLinkPriceFeed[spyUsd] = AggregatorV3Interface(0x4046332373C24Aed1dC8bAd489A04E187833B28d); // for prod 0xb24D1DeE5F9a3f761D286B56d2bC44CE1D02DF7e

        getLatestPrice();
        numberOfItems++;
        setLatestPriceToHistory();
        lastUpdateTimestamp = block.timestamp;

        // track timestap for mint and burn quantity tracker
        burnMintTimetracker = block.timestamp;

        // mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E pancake swap 
        // testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 pancake.kiemtienonline360
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(_marketingWalletAddress);
        dividendTracker.excludeFromDividends(_treasuryWalletAddress);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(_treasuryWalletAddress, true);

        _mint(owner(), _initialLauchSupply);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function setRewardToken(address reward) public onlyOwner {
        USDC = reward;
        dividendTracker.setRewardToken(reward);
    }

    function burnMintTrackerUpdate() private {
        if (burnMintTimetracker <= block.timestamp - oneWeek) {
            // one week has passed
            burnMintTimetracker = block.timestamp;
            burnQuantityPreviousWeek = burnQuantityCurrentWeek;
            mintQuantityPreviousWeek = mintQuantityCurrentWeek;
            burnQuantityCurrentWeek = 0;
            mintQuantityCurrentWeek = 0;
        }
    }

    function internalBurn(uint256 amount) private {
        uint256 tempSupply = (totalSupply()).sub(amount);

        if (tempSupply >= _minTokenSupply) {
            _burn(address(this), amount);
            burnQuantityCurrentWeek += amount;
        } else {
            uint256 amountToBurn = (totalSupply()).sub(_minTokenSupply);
            if (amountToBurn > 0) {
                _burn(address(this), amountToBurn);
                burnQuantityCurrentWeek += amountToBurn;
            }
        }
        burnMintTrackerUpdate();
    }

    function internalMint(uint256 amount) private {
        uint256 tempSupply = (totalSupply()).add(amount);

        if (tempSupply <= _maxTokenSupply) {
            _mint(address(this), amount);
            mintQuantityCurrentWeek += amount;
        } else {
            uint256 amountToMint = (_maxTokenSupply).sub(totalSupply());
            if (amountToMint > 0) {
                _mint(address(this), amountToMint);
                mintQuantityCurrentWeek += amountToMint;
            }
        }
        burnMintTrackerUpdate();
    }

    function isOverLiquified() public returns (bool, uint) {
        uint256 liquidityBacking = getLiquidityBacking(targetLiquidityDenominator);
        uint weight = 0;
        bool toBurn = false;

        emit LiquidityRate("Liquidity Backing", liquidityBacking);

        if (liquidityBacking > targetLiquidity) {
            // over liquified
            toBurn = true;
            weight = 1; 
            if (liquidityBacking > targetLiquidity.add(10)) {
                // liquidity backing is higher than expected 
                weight = 2;
            } 
        } else {
             // under liquified
            toBurn = false;
            weight = 1;
            if (liquidityBacking < targetLiquidity.sub(10)) {
                // liquidity backing lower than expcected
                weight = 2;
            }
        }
        return (toBurn, weight);
    }

    function getLiquidityBacking(uint256 accuracy) private view returns (uint256) {
        uint256 liquidityBalance = 0;
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            liquidityBalance.add(balanceOf(_markerPairs[i]));
        }

        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply().sub(balanceOf(zeroWallet)).sub(balanceOf(deadWallet)));
    }

    function setLatestPriceToHistory() private {
        HistoricalPairs storage latestItem = histPairs[indexOfLatestItem];
        latestItem.timestamp = block.timestamp;

        for (uint i = 0; i < pairs.length; i++) {
            latestItem.pairs[pairs[i]] = ChainLinkPricePair(latestPrices[pairs[i]].price, latestPrices[pairs[i]].timestamp);
        }
    }

    function checkHistoricalPrice() public returns (bool, uint) {
        uint weight = 0;
        bool toBurn = false;

        if (numberOfItems < checkItemIndex && lastUpdateTimestamp <= block.timestamp - oneHour) {
           // data setup logic
          lastUpdateTimestamp = block.timestamp;
          numberOfItems++;
          indexOfLatestItem++;
          getLatestPrice();
          setLatestPriceToHistory();
        } else {
           // main logic
          HistoricalPairs storage oldestPairs = histPairs[indexOfOldestItem];
          if (oldestPairs.timestamp <= block.timestamp - twentyFourHours) {
            getLatestPrice();
            
            uint burnWeight = 100;
            uint mintWeight = 100;
            for (uint i = 0; i < pairs.length; i++) { 
                int fivePercent = oldestPairs.pairs[pairs[i]].price / 100 * 5;
                int tenPercent = oldestPairs.pairs[pairs[i]].price / 100 * 10;
                int fifteenPercent = oldestPairs.pairs[pairs[i]].price / 100 * 15;

                if (latestPrices[pairs[i]].price > oldestPairs.pairs[pairs[i]].price) {
                  // price has increase since 24 hours ago
                  if (latestPrices[pairs[i]].price <= oldestPairs.pairs[pairs[i]].price + fivePercent) {
                    // 5% or less 
                    mintWeight += 100; 
                  } else if (latestPrices[pairs[i]].price <= oldestPairs.pairs[pairs[i]].price + tenPercent) {
                    // 10% or less
                    mintWeight += 200;
                  } else if (latestPrices[pairs[i]].price <= oldestPairs.pairs[pairs[i]].price + fifteenPercent) {
                    // 15% or less
                    mintWeight += 300;
                  } else {
                    // more than 15% 
                    mintWeight += 400;
                  }

                } else {
                  // price has gone down in last 24 hours 
                  if (latestPrices[pairs[i]].price >= oldestPairs.pairs[pairs[i]].price - fivePercent) {
                    // 5% or less 
                    burnWeight += 100;
                  } else if (latestPrices[pairs[i]].price >= oldestPairs.pairs[pairs[i]].price - tenPercent) {
                    // 10% or less
                    burnWeight += 200;
                  } else if (latestPrices[pairs[i]].price >= oldestPairs.pairs[pairs[i]].price - fifteenPercent) {
                    // 15% or less
                    burnWeight += 300;
                  } else {
                    // more than 15% 
                    burnWeight += 400;
                  }
                }
            }
            
            emit BurnOrMint("burn weight - ", burnWeight, "mint weight - ", mintWeight);

            uint twentyPercent = burnWeight / 100 * 20;
            uint fourtyPercent = burnWeight / 100 * 40;
            uint sixtyPercent = burnWeight / 100 * 60;
            uint eightyPercent = burnWeight / 100 * 80;
            if (mintWeight > burnWeight) {
              toBurn = false;
              if (mintWeight <= burnWeight + twentyPercent) {
                weight = 1; 
              } else if (mintWeight <= burnWeight + fourtyPercent) {
                weight = 2;
              } else if (mintWeight <= burnWeight + sixtyPercent) {
                weight = 3;
              } else if (mintWeight <= burnWeight + eightyPercent) {
                weight = 4;
              }
            } else {
              toBurn = true;
              if (mintWeight >= burnWeight - twentyPercent) {
                weight = 1; 
              } else if (mintWeight >= burnWeight - fourtyPercent) {
                weight = 2;
              } else if (mintWeight >= burnWeight - sixtyPercent) {
                weight = 3;
              } else if (mintWeight >= burnWeight - eightyPercent) {
                weight = 4;
              }
            }

            if (mintWeight == burnWeight) {
              toBurn = false;
              weight = 0;
            }
            
            if (lastUpdateTimestamp <= block.timestamp - oneHour) {
              if (indexOfOldestItem == checkItemIndex) {
                indexOfOldestItem = 0;
              }
              indexOfOldestItem++;
              if (indexOfLatestItem == checkItemIndex) {
                indexOfLatestItem = 0;
              }
              indexOfLatestItem++;
              lastUpdateTimestamp = block.timestamp;
              setLatestPriceToHistory();
            }
          }
        }

        emit HistoricPriceWeight("checkHistoricalPrice", "Will it burn? - ", toBurn, "Whats the weight - ", weight);
        return (toBurn, weight);
    }

    function getLatestPrice() private {  
      for (uint i=0; i<pairs.length; i++) {
        latestPrices[pairs[i]] = getLatest(pairs[i]);
      }
    }  

    function getLatest(string memory pair) private view returns (ChainLinkPricePair memory) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = chainLinkPriceFeed[pair].latestRoundData();

        return ChainLinkPricePair(price, timeStamp);
    }

    function setTaxBracketFeeMultiplier(uint256 _taxBracketFeeMultiplier) public onlyOwner {
        require(_taxBracketFeeMultiplier <= MAX_TAX_BRACKET_FEE_RATE, 'max bracket fee exceeded');
        taxBracketMultiplier = _taxBracketFeeMultiplier;
        emit SetTaxBracketFeeMultiplier(_taxBracketFeeMultiplier, block.timestamp);
    }

    function setTaxBracket(bool _isTaxBracketEnabled) external onlyOwner {
        require(isTaxBracketEnabled != _isTaxBracketEnabled,"Tax Bracket function hasn't changed");
        isTaxBracketEnabled = _isTaxBracketEnabled;
        emit SetTaxBracket(_isTaxBracketEnabled, block.timestamp);
    }

    function setBlackHoldBurn(bool _blackHoleBurnEnabled) external onlyOwner {
        require(blackHoleBurnEnabled != _blackHoleBurnEnabled,"Black Hole Burn function hasn't changed");
        blackHoleBurnEnabled = _blackHoleBurnEnabled;
        emit SetBlackHoldBurn(_blackHoleBurnEnabled, block.timestamp);
    }

    function setBurnEnabled(bool _burnEnabled) external onlyOwner {
        require(burnEnabled != _burnEnabled,"Burn Enable function hasn't changed");
        burnEnabled = _burnEnabled;
        emit SetBurn(_burnEnabled, block.timestamp);
    }

    function setMintEnabled(bool _mintEnabled) external onlyOwner {
        require(mintEnabled != _mintEnabled,"Mint Enable function hasn't changed");
        mintEnabled = _mintEnabled;
        emit SetMint(_mintEnabled, block.timestamp);
    }

    function setTransferEnabled(bool _transferEnabled) external onlyOwner {
        require(transferEnabled != _transferEnabled,"Transfer Enable function hasn't changed");
        transferEnabled = _transferEnabled;
        emit SetTransfer(_transferEnabled, block.timestamp);
    }

    function setTakeFeeEnabled(bool _takeFeeEnabled) external onlyOwner {
        require(takeFeeEnabled != _takeFeeEnabled,"Take Fee Enable function hasn't changed");
        takeFeeEnabled = _takeFeeEnabled;
        emit SetTakeFee(_takeFeeEnabled, block.timestamp);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "Aria: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Aria: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setMarketingWallet(address payable wallet) external onlyOwner {
        _marketingWalletAddress = wallet;
    }

    function setTreasuryWallet(address payable wallet) external onlyOwner {
        _treasuryWalletAddress = wallet;
    }

    function setFees(uint256 reward, uint256 liq, uint256 treas, uint256 devMark) external onlyOwner {
        uint256 tempTotalConfigFees = reward.add(liq).add(treas).add(devMark);
        
        require(tempTotalConfigFees <= 15, "Aria: Configurable fees cannot be greater than 15");
        require(reward >= _minUSDCRewardsFee && reward <= _maxUSDCRewardsFee, "Aria: Reward fee has to be between 5 and 10");
        require(treas >= _minLiquidityTreasuryDevMarketingFee && treas <= _maxLiquidityTreasuryDevMarketingFee, "Aria: Treasury fee has to be between 1 and 5");
        require(liq >= _minLiquidityTreasuryDevMarketingFee && liq <= _maxLiquidityTreasuryDevMarketingFee, "Aria: Liquidity fee has to be between 1 and 5");
        require(devMark >= _minLiquidityTreasuryDevMarketingFee && devMark <= _maxLiquidityTreasuryDevMarketingFee, "Aria: Dev/Marketing fee has to be between 1 and 5");        
        
        USDCRewardsFee = reward;
        liquidityFee = liq;
        treasuryFee = treas;
        marketingFee = devMark;
        totalConfigFees = USDCRewardsFee.add(liquidityFee).add(marketingFee).add(treasuryFee);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "Aria: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Aria: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
            _markerPairs.push(pair);
            _markerPairCount++;
        } else {
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function markerPairAddress(uint256 value) public view returns (address) {
        return _markerPairs[value];
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	dividendTracker.setLastProcessedIndex(index);
    }

    function weightToPercentage(uint weight) private returns (uint256) {
        uint256 percentage = 0;
        
        if (weight == 1) {
            percentage = 1;
        } else if (2 <= weight && weight <= 4) {
            percentage = 2;
        }  else if (weight > 4) {
            percentage = 3;
        }

        return percentage;
    }

    function burnOrMintChecker() private returns (bool, uint256, bool, uint256) {
        bool burn = false;
        bool mint = false;
        uint256 burnPercentage = 0;
        uint256 mintPercentage = 0;

        (bool toBurnHP, uint weightHP) = checkHistoricalPrice();
        (bool toBurnOL, uint weightOL) = isOverLiquified();

        if (toBurnHP && toBurnOL) {
            // burn
            burn = true;
            burnPercentage = weightToPercentage(weightHP + weightOL);
        } else if (!toBurnHP && !toBurnOL) {
            // mint
            mint = true; 
            mintPercentage = weightToPercentage(weightHP + weightOL);
        } else {
            // we need to base it on the weight 
            if (weightHP > weightOL) {
                if (toBurnHP) {
                    burn = true;
                    burnPercentage = weightToPercentage(weightHP);
                } else {
                    mint = true;
                    mintPercentage = weightToPercentage(weightHP);
                }
            } else {
                if (toBurnOL) {
                    burn = true;
                    burnPercentage = weightToPercentage(weightOL);
                } else {
                    mint = true;
                    mintPercentage = weightToPercentage(weightOL);
                }
            }
        }

        return (burn, burnPercentage, mint, mintPercentage);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(transferEnabled, "ERC20: transfers are not enabled");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] || !_isBlacklisted[to], "Blacklisted address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = takeFeeEnabled;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 burnAmount = 0;
            uint256 mintAmount = 0;
            bool shouldBurn = false;
            bool shouldMint = false;

        	uint256 fees = amount.mul(totalConfigFees).div(100);
            (bool burn, uint256 burnFee, bool mint, uint256 mintFee) = burnOrMintChecker();

            shouldBurn = burn;
            shouldMint = mint;
            if (burn && (blackHoleBurnEnabled || burnEnabled)) {
                burnAmount = amount.mul(burnFee).div(100);
                fees += burnAmount;
            } else if (mint) {
                mintAmount = amount.mul(mintFee).div(100);
            }

            // take additional selling fee of 3%
        	if(automatedMarketMakerPairs[to]){
                if (isTaxBracketEnabled) {
                    fees += getCurrentTaxBracket(from);
                }

        	    fees += amount.mul(3).div(100);
        	}
        	amount = amount.sub(fees);

            super._transfer(from, address(this), fees);

            if (shouldBurn) {
                if (blackHoleBurnEnabled) {
                    super._transfer(address(this), deadWallet, burnAmount);
                } else if (burnEnabled) {
                    internalBurn(burnAmount);
                }
            } else if (shouldMint && mintEnabled) {
                internalMint(mintAmount);
            }
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
    }

    function getCurrentTaxBracket(address _address) public view returns (uint256) {
        //gets the total balance of the user
        uint256 userTotal = balanceOf(_address);

        //calculate the percentage
        uint256 totalCap = userTotal.mul(100).div(getTokensInLPCirculation());

        //calculate what is smaller, and use that
        uint256 _bracket = totalCap < maxBracketTax ? totalCap : maxBracketTax;

        //multiply the bracket with the multiplier
        _bracket *= taxBracketMultiplier;

        return _bracket;
    }

    function getTokensInLPCirculation() public view returns (uint256) {
        uint256 LPTotal;

        for (uint256 i = 0; i < _markerPairs.length; i++) {
            LPTotal += balanceOf(_markerPairs[i]);
        }

        return LPTotal;
    }

    function claimRewards() public {

        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance > 0) {

            uint256 marketingTokens = contractTokenBalance.mul(marketingFee).div(totalConfigFees);
            swapAndSendToFee(marketingTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalConfigFees);
            swapAndLiquify(swapTokens);

            uint256 treasuryTokens = contractTokenBalance.mul(treasuryFee).div(totalConfigFees);
            swapAndTreasury(treasuryTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapForDividend(sellTokens);
        }

        dividendTracker.processAccount(payable(msg.sender));
    }

    function swapForDividend(uint256 tokens) private {
        swapTokensForUsdc(tokens);  
        uint256 dividends = IERC20(USDC).balanceOf(address(this));
        bool success = IERC20(USDC).transfer(address(dividendTracker), dividends);
        
        if (success) {
            dividendTracker.distributeUSDCDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }

    function swapAndSendToFee(uint256 tokens) private  {
        uint256 initialUSDCBalance = IERC20(USDC).balanceOf(address(this));

        swapTokensForUsdc(tokens);
        uint256 newBalance = (IERC20(USDC).balanceOf(address(this))).sub(initialUSDCBalance);
        IERC20(USDC).transfer(_marketingWalletAddress, newBalance);
    }

    function swapAndTreasury(uint256 tokens) private  {
        uint256 initialUSDCBalance = IERC20(USDC).balanceOf(address(this));

        swapTokensForUsdc(tokens);
        uint256 newBalance = (IERC20(USDC).balanceOf(address(this))).sub(initialUSDCBalance);
        IERC20(USDC).transfer(_treasuryWalletAddress, newBalance);
    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForUsdc(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = USDC;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

}

contract AriaDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 public lastProcessedIndex;
    mapping (address => bool) public excludedFromDividends;

    event ExcludeFromDividends(address indexed account);

    constructor() public DividendPayingToken("Aria_Rewards", "Aria_Rewards") {}

    function _transfer(address, address, uint256) internal override {
        require(false, "Aria_Rewards: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "Aria_Rewards: withdrawDividend disabled. Use the 'claimRewards' function on the main Aria contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account], "Aria_Rewards: excludeFromDividends");
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);

    	emit ExcludeFromDividends(account);
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	lastProcessedIndex = index;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            uint256 withdrawableDividends,
            uint256 totalDividends) {
        account = _account;
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}
        _setBalance(account, newBalance);
    }

    function processAccount(address payable account) public onlyOwner {
         _withdrawDividendOfUser(account);
    }
}