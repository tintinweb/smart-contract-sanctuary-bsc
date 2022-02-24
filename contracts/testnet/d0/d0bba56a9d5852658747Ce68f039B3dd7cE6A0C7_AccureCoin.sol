/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

/**

* The smart contracts that run ACRU implement the latest trend in BSC tokens, 
* AUTO DIVIDEND YIELDING with an AUTO-DEPOSIT feature. 
* By simply buying and holding ACRU you are rewarded!
*
* 11% buy/sell tax:
* 6% rewards
* 2% liquidity
* 1% marketing/development
* 1% Giveaway!
* 1% NFT Dividends
* 
*/

// SPDX-License-Identifier: MIT

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

/*
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

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}


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


/// @title Dividend-Paying Token Interface
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


/// @title Dividend-Paying Token Optional Interface
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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


/// @title Dividend-Paying Token
/// @dev A mintable ERC20 token that allows anyone to pay and distribute ether
///  to token holders as dividends and allows token holders to withdraw their dividends.
contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  address private CAKE;
  uint internal price;
  uint8 internal constant _decimals = 18;

  // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
  // For more discussion about choosing the value of `magnitude`,
  //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
  uint256 constant internal magnitude = 2**128;

  mapping(address => mapping(uint8 => uint)) public magnifiedDividendCorrectionsFrom;
  mapping(address => mapping(uint8 => uint)) public magnifiedDividendCorrectionsTo;

  mapping(address => uint256) public withdrawnDividends;

  struct GroupInfo {
    uint minPrice;
    uint maxPrice;
    uint reflectionRate;
  }

  GroupInfo[] public groupInfo;
  mapping(uint8 => uint) public mapMemberCountInGroup;
  mapping(address => uint8) public mapGroupIndexofUser;
  mapping(uint8 => uint) public magnifiedDividendPerShare;
  mapping(address => uint) mapGiveawaysRewardofUser;

  uint256 public totalDividendsDistributed;

  constructor(string memory _name, string memory _symbol, address _cake) ERC20(_name, _symbol) {
    CAKE = _cake;
  }

  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  /// @notice Set the information of the reward group.
  /// @param _min The minium price in the group.
  /// @param _max The maximum price in the group.
  /// @param _rate The reflection rate for the group.
  function addGroup(uint _min, uint _max, uint _rate) public {
    groupInfo.push(GroupInfo({
        minPrice: _min,
        maxPrice: _max,
        reflectionRate: _rate
    }));
  }

  /// @notice Get the group index from the balance of native token.
  /// @param _balance The balance of native token.
  /// @return index The index of group where the _balance is included.
  function getGroupIndex(uint _balance) public view  returns (uint8 index) {
    uint currentPrice = _balance.mul(price).div(10 ** _decimals);

    uint8 length = uint8(groupInfo.length);
    uint8 i;
    for (i=0; i<length; i++) {
        if (groupInfo[i].minPrice <= currentPrice && groupInfo[i].maxPrice > currentPrice) {
            break;
        }
    }

    return i;
  }

  /// @notice Get the reflection rate for the account in the group.
  /// @param _account The account address in the group.
  /// @return rate View the reflection rate for the _account.
  function getReflectionRate(address payable _account) public view  returns (uint8 rate) {
    uint currentPrice = balanceOf(_account).mul(price);

    uint8 length = uint8(groupInfo.length);
    rate = 0;
    for (uint8 i=0; i<length; i++) {
        if (groupInfo[i].minPrice <= currentPrice && groupInfo[i].maxPrice > currentPrice) {
            return rate;
        }
    }
  }

  /// @notice Get the total reflection rate of the group without members.
  /// @return rate View the total rate of the groups without members.
  function getTotalRatesOfEmptyGroups() public view returns (uint rate) {
    uint8 length = uint8(groupInfo.length);
    rate = 0;
    for (uint8 i=0; i<length; i++) {
        if (mapMemberCountInGroup[i] == 0) {
            rate = rate.add(groupInfo[i].reflectionRate);
        }
    }
  }

  /// @notice Create the information of rewards distributed to each group.
  function distributeCAKEDividends(uint256 amount) public {
    require(totalSupply() > 0);

    if (amount > 0) {
        uint subAmount;
        uint8 length = uint8(groupInfo.length);
        for (uint8 i=0; i<length; i++) {
            if (mapMemberCountInGroup[i] == 0)
                continue;

            subAmount = amount.mul(groupInfo[i].reflectionRate).div(100);
            magnifiedDividendPerShare[i] = magnifiedDividendPerShare[i].add
                ((subAmount).mul(magnitude) / mapMemberCountInGroup[i]
            );
        }

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
      bool success = IERC20(CAKE).transfer(user, _withdrawableDividend);

      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
      }

      mapGiveawaysRewardofUser[user] = 0;

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
  /// = (magnifiedDividendPerShare * balanceOf(_owner) + ACRU_Dividend_Tracker[_owner]) / magnitude
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    uint8 length = uint8(groupInfo.length);
    uint256 totalAmount;
    uint8 currentGroupIndex = getGroupIndex(balanceOf(_owner));
    for (uint8 i=0; i<length; i++) {
        if (i == currentGroupIndex)
            totalAmount = totalAmount.add((magnifiedDividendPerShare[i]
                            .sub(magnifiedDividendCorrectionsFrom[_owner][i])).div(magnitude));
        else 
            totalAmount = totalAmount.add((magnifiedDividendCorrectionsTo[_owner][i]
                            .sub(magnifiedDividendCorrectionsFrom[_owner][i])).div(magnitude));
    }

    totalAmount = totalAmount.add(mapGiveawaysRewardofUser[_owner]);

    return totalAmount;
  }

  /// @notice Set the giveaways reward to the account
  /// @param _account The address of a token holder who receive the griveaways reward
  /// @param _token The amount of griveaways reward.
  function setGiveAwaysRewards(address _account, uint _token) public onlyOwner {
    mapGiveawaysRewardofUser[_account] = mapGiveawaysRewardofUser[_account].add(_token);
  }

  /// @notice Set the group information of the account according to his balance
  /// @param _account The address of a token holder who receive the reflection reward
  /// @param _newBalance The balance of a token holder who receive the reflection reward  
  function _setBalance(address _account, uint256 _newBalance) public {
    uint8 prevGroupIndex = mapGroupIndexofUser[_account];
    uint8 newGroupIndex = getGroupIndex(_newBalance);

    uint256 currentBalance = balanceOf(_account);
    if(_newBalance > currentBalance) {
      uint256 mintAmount = _newBalance.sub(currentBalance);
      _mint(_account, mintAmount);
    } else if(_newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(_newBalance);
      _burn(_account, burnAmount);
    }

    // Calculate count of members in group
    if (mapMemberCountInGroup[prevGroupIndex] > 0)
        mapMemberCountInGroup[prevGroupIndex] --;

    mapMemberCountInGroup[newGroupIndex] ++;

    // Set the new group in dex for account
    mapGroupIndexofUser[_account] = newGroupIndex;

    // Store the last dividend share in previous group
    magnifiedDividendCorrectionsTo[_account][prevGroupIndex] = magnifiedDividendPerShare[prevGroupIndex];

    if (newGroupIndex == 0)
        return;

    // Store the first dividend share in new group
    // If there is previous reward for the account in the new group, store the reward.
    if (magnifiedDividendCorrectionsFrom[_account][newGroupIndex] > 0 && 
        magnifiedDividendCorrectionsTo[_account][newGroupIndex] >= magnifiedDividendCorrectionsFrom[_account][newGroupIndex]) {
        uint remainReward = magnifiedDividendCorrectionsTo[_account][newGroupIndex]
                        .sub(magnifiedDividendCorrectionsFrom[_account][newGroupIndex]);

        magnifiedDividendCorrectionsFrom[_account][newGroupIndex] = magnifiedDividendPerShare[newGroupIndex]
                                                                .sub(remainReward);
    }
  }
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
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

interface NFTInvestor {
    function distributeRewards(uint256 amount) external;
}

interface TokenLocker {
    function lockTokens(uint256 amount, uint256 period, uint256 unlockAmount, address receiver, bool transfer) external;
}

contract AccureCoin is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    AcruDividendTracker public dividendTracker;

//  address public constant BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // BSC mainnet
    address public constant BUSD = address(0xD500E3CF845CC41ABa54bB1dD426bD3485bD8Cd5);  // BSC testnet

    // total supply of token
    uint8 public constant _decimals = 18;
    uint256 public constant _totalSupply = 250_000_000 * (10 ** _decimals);

    uint256 public swapTokensAtAmount = 200_000 * (10 ** _decimals);

    // transaction fee allocation
    uint256 public rewardsFee = 6;
    uint256 public liquidityFee = 2;
    uint256 public marketingFee = 1;
    uint256 public giveAwayFee = 1;
    uint256 public nftFee = 1;

    uint256 public totalFees = rewardsFee.add(liquidityFee).add(marketingFee).add(giveAwayFee).add(nftFee);

    bool enableGiveAways = false;
    uint256 totalGiveAwaysRewards;
    uint256 lastGiveAwaysTime;
    uint256 limitPriceForGiveAways = 500 * 10 ** 8;     // $500 BUSD
    uint256 periosForGiveAways = 7 days;
    mapping(uint256 => uint256) private assignOrders;

    //Sell Mechanics
    mapping(address => uint256) public lastTransferTime;
    mapping(address => uint256) public firstPurchasedTime;
    mapping(address => bool) private excludedFromTransferLimit;

    uint256 totalLockedPeriod = 56 days;
    uint256 subLockedPeriod = 3 days;

    // Max transfer amount rate in basis points. (default is 5% of total supply)
    uint16 public maxTransferAmountRate = 500;

    // Addresses that excluded from antiWhale
    mapping(address => bool) private excludedFromAntiWhale;

    address public marketWalletAddress = address(0x97066393B19194ad9475C78B73de632305530add);
    address public unlockedWallet = address(0xFA1dB028F2ac05F8ed7a61b01f19115bfE44F0D8);
    address public dev1Wallet = address(0x7dBFB5fe5dD0e1D7F173eE850f308A6990c41faE);
    address public dev2Wallet = address(0xeFD11E9D1CDf0CEd00F887079A15E8C3Fe1913aA);

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    NFTInvestor public nftInvestor;
    uint256 public totalNFTRewards;

    TokenLocker public tokenLocker;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event MaxTransferAmountRateUpdated(
        address indexed operator, 
        uint256 previousRate, 
        uint256 newRate
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendMarketingFee(
        uint256 amount
    );

    event SendGiveAwaysFee(
        uint256 amount
    );

    event SendDividends(
        uint256 amount
    );

    event SendNFTFee(
        uint256 amount
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        address indexed processor
    );

    modifier antiWhale(address sender, address recipient, uint256 amount) {
        if (maxTransferAmount() > 0) {
            if (
                excludedFromAntiWhale[sender] == false
                && excludedFromAntiWhale[recipient] == false
            ) {
                require(amount <= maxTransferAmount(), "ACRU::antiWhale: Transfer amount exceeds the maxTransferAmount");
            }
        }
        _;
    }

    constructor() ERC20("AccureCoin", "ACRU") {

        dividendTracker = new AcruDividendTracker(BUSD);

        // PancakeSwap address in bsc mainnet
//      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // PancakeSwap address in bsc testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

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
        dividendTracker.excludeFromDividends(marketWalletAddress);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketWalletAddress, true);

        // exclude from antiwhale
        excludedFromAntiWhale[msg.sender] = true;
        excludedFromAntiWhale[address(0)] = true;
        excludedFromAntiWhale[address(this)] = true;
        excludedFromAntiWhale[marketWalletAddress] = true;

        // exclude from sell limit
        excludedFromTransferLimit[msg.sender] = true;
        excludedFromTransferLimit[address(0)] = true;
        excludedFromTransferLimit[address(this)] = true;
        excludedFromTransferLimit[marketWalletAddress] = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
//      _mint(unlockedWallet, 75_000_000 * (10 ** _decimals));        // Liquidity and unlocked supply
        _mint(owner(), 75_000_000 * (10 ** _decimals));
    }

    receive() external payable {
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function burn(uint256 amount) public override {
        _burn(_msgSender(), amount);
    }

    /**
     * @notice Set the address of Token Locker.
     */
    function setTockenLocker(TokenLocker _tokenLocker) public onlyOwner {
        require(address(_tokenLocker) != address(0), "ACRU: Wrong Token Locker contract address");
        require(address(tokenLocker) == address(0), "ACRU: Token Locker already set");

        tokenLocker = _tokenLocker;

        dividendTracker.excludeFromDividends(address(_tokenLocker));
        excludeFromFees(address(_tokenLocker), true);
        excludedFromAntiWhale[address(_tokenLocker)] = true;
        excludedFromTransferLimit[address(_tokenLocker)] = true;

        initializeLock();
    }

    /**
     * @notice Set the address of NFT Investor.
     */
    function setNFTInvestor(NFTInvestor _nftInvestor) public onlyOwner {
        require(address(_nftInvestor) != address(0), "ACRU: Wrong NFTInvestor contract address");
        require(address(nftInvestor) == address(0), "ACRU: NFT Investor already set");

        nftInvestor = _nftInvestor;

        dividendTracker.excludeFromDividends(address(_nftInvestor));
        excludeFromFees(address(_nftInvestor), true);
        excludedFromAntiWhale[address(_nftInvestor)] = true;
        excludedFromTransferLimit[address(_nftInvestor)] = true;
    }

    /**
     * @notice Lock the native token for liquidity, staking, developer wallets.
     */
    function initializeLock() internal {
        uint256 totalLockedAmount;
        uint256 period;
        uint256 unlockAmount;

        _mint(address(tokenLocker), 170_000_000 * (10 ** _decimals));        // For Locking 68% of total supply for liquidity, staking, etc
        _mint(address(tokenLocker), 5000_000 * (10 ** _decimals));           // For Locking 2% of total supply for developer

        // Lock 68% of total supply for liquidity, staking, etc
        totalLockedAmount = 170_000_000 * (10 ** _decimals);
        period = 30 days;
        unlockAmount = 4_500_000 * (10 ** _decimals);

        tokenLocker.lockTokens(totalLockedAmount, period, unlockAmount, unlockedWallet, false);

        // Lock 2% of total supply for developer
        totalLockedAmount = 2_500_000 * (10 ** _decimals);
        period = 365 days;
        unlockAmount = totalLockedAmount;

        tokenLocker.lockTokens(totalLockedAmount, period, unlockAmount, dev1Wallet, false);
        tokenLocker.lockTokens(totalLockedAmount, period, unlockAmount, dev2Wallet, false);
    }

    /**
     * @notice Update the dividend trancer and exclude from receiving dividends
     */
    function updateDividendTracker(address _newAddress) public onlyOwner {
        require(_newAddress != address(dividendTracker), "ACRU: The dividend tracker already has that address");

        AcruDividendTracker newDividendTracker = AcruDividendTracker(payable(_newAddress));

        require(newDividendTracker.owner() == address(this), "ACRU: The new dividend tracker must be owned by the ACRU token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(marketWalletAddress);
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(_newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    /**
     * @notice Update the uniswap router
     */
    function updateUniswapV2Router(address _newAddress) public onlyOwner {
        require(_newAddress != address(uniswapV2Router), "ACRU: The router already has that address");
        emit UpdateUniswapV2Router(_newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(_newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    /**
     * @dev Returns the max transfer amount.
     */
    function maxTransferAmount() public view returns (uint256) {
        return totalSupply().mul(maxTransferAmountRate).div(10000);
    }

    /**
     * @dev Update the max transfer amount rate.
     * Can only be called by the current operator.
     */
    function updateMaxTransferAmountRate(uint16 _maxTransferAmountRate) public onlyOwner {
        require(_maxTransferAmountRate <= 10000, "ACRU::updateMaxTransferAmountRate: Max transfer amount rate must not exceed the maximum rate.");
        emit MaxTransferAmountRateUpdated(msg.sender, maxTransferAmountRate, _maxTransferAmountRate);
        maxTransferAmountRate = _maxTransferAmountRate;
    }

    /**
     * @dev Returns the address is excluded from antiWhale or not.
     */
    function isExcludedFromAntiWhale(address _account) public view returns (bool) {
        return excludedFromAntiWhale[_account];
    }

    /**
     * @dev Exclude or include an address from antiWhale.
     * Can only be called by the current operator.
     */
    function setExcludedFromAntiWhale(address _account, bool _excluded) public onlyOwner {
        excludedFromAntiWhale[_account] = _excluded;
    }

    /**
     * @dev Returns the address is excluded from transfer limit or not.
     */
    function isExcludedFromTransferLimit(address _account) public view returns (bool) {
        return excludedFromTransferLimit[_account];
    }

    /**
     * @dev Exclude or include an address from transfer limit.
     * Can only be called by the current operator.
     */
    function setExcludedFromTransferLimit(address _account, bool _excluded) public onlyOwner {
        excludedFromTransferLimit[_account] = _excluded;
    }

    /**
     * @notice Exclude or include from paying fees
     */
    function excludeFromFees(address _account, bool _excluded) public onlyOwner {
        require(_isExcludedFromFees[_account] != _excluded, "ACRU: Account is already the value of 'excluded'");
        _isExcludedFromFees[_account] = _excluded;

        emit ExcludeFromFees(_account, _excluded);
    }

    /**
     * @notice Exclude or include multi accounts from paying fees
     */
    function excludeMultipleAccountsFromFees(address[] memory _accounts, bool _excluded) public onlyOwner {
        for(uint256 i = 0; i < _accounts.length; i++) {
            _isExcludedFromFees[_accounts[i]] = _excluded;
        }

        emit ExcludeMultipleAccountsFromFees(_accounts, _excluded);
    }

    /**
     * @notice Set the limit value to make enable swapping token, adding liquidity, 
     *  sending token to dividendtracker and game developer in transfer
     */ 
    function setSwapTokensAtAmount(uint256 _value) external onlyOwner{
        swapTokensAtAmount = _value;
    }

    /**
     * @notice Set the market wallet address
     */ 
    function setMarketWallet(address payable _wallet) external onlyOwner{
        marketWalletAddress = _wallet;
    }

    /**
     * @notice Set the rewards fee for token holders
     */ 
    function setRewardsFee(uint256 _value) external onlyOwner{
        rewardsFee = _value;
        totalFees = rewardsFee.add(liquidityFee).add(marketingFee).add(giveAwayFee).add(nftFee);
    }

    /**
     * @notice Set the liquidity fee
     */ 
    function setLiquiditFee(uint256 _value) external onlyOwner{
        liquidityFee = _value;
        totalFees = rewardsFee.add(liquidityFee).add(marketingFee).add(giveAwayFee).add(nftFee);
    }

    /**
     * @notice Set the fee for market wallet
     */ 
    function setMarketingFee(uint256 _value) external onlyOwner{
        marketingFee = _value;
        totalFees = rewardsFee.add(liquidityFee).add(marketingFee).add(giveAwayFee).add(nftFee);
    }

    /**
     * @notice Set the transaction fee for giveaway
     */ 
    function setGiveAwayFee(uint256 _value) external onlyOwner{
        giveAwayFee = _value;
        totalFees = rewardsFee.add(liquidityFee).add(marketingFee).add(giveAwayFee).add(nftFee);
    }

    /**
     * @notice Set the transaction fee for nft holders
     */ 
    function setNFTFee(uint256 _value) external onlyOwner{
        nftFee = _value;
        totalFees = rewardsFee.add(liquidityFee).add(marketingFee).add(giveAwayFee).add(nftFee);
    }

    /**
     * @notice Set the automated MarketMakerPair
     */ 
    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(_pair != uniswapV2Pair, "ACRU: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(_pair, _value);
    }

    /**
     * @notice Internal function to set the automated MarketMakerPair
     */ 
    function _setAutomatedMarketMakerPair(address _pair, bool value) private {
        require(automatedMarketMakerPairs[_pair] != value, "ACRU: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[_pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(_pair);
        }

        emit SetAutomatedMarketMakerPair(_pair, value);
    }

    /**
     * @notice Update the claim wait time in dividendtracker
     */ 
    function updateClaimWait(uint256 _claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(_claimWait);
    }

    /**
     * @notice Get the claim wait time in dividendtracker
     */ 
    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    /**
     * @notice Get the total amount of dividend distributed
     */ 
    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    /**
     * @notice Check whether account in exclude from receiving dividends
     */ 
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * @notice View the amount of dividend in wei that an address has earned in total.
     */ 
    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    /**
     * @notice Getthe dividend token balancer in account
     */ 
    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    /**
     * @notice Exclude from receiving dividends
     */ 
    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    /**
     * @notice Get the dividend infor for account
     */ 
    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    /**
     * @notice Get the indexed dividend infor
     */ 
    function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

    /**
     * @notice Withdraws the token distributed to all token holders
     */
    function processDividendTracker() external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process();
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, tx.origin);
    }

    /**
     * @notice Withdraws the token distributed to the sender.
     */
    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    /**
     * @notice Get the last processed info in dividend tracker
     */
    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    /**
     * @notice Get the number of dividend token holders
     */
    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override antiWhale(from, to, amount) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        require(noCheckTransferLimit(from, to, amount), "ACRU: No transfers allowed");

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

 //         swapAndSendRewards(contractTokenBalance.sub(swapTokens));

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);
            amount = amount.sub(fees);

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
        lastTransferTime[from] = block.timestamp;

        if (firstPurchasedTime[to] == 0)
            firstPurchasedTime[to] = block.timestamp;

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
            try dividendTracker.process() returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, tx.origin);
            }
            catch {
            }
        }
    }

    /**
     * @notice Check the sell limit
     */
    function noCheckTransferLimit(address from, address to, uint256 amount) 
        public view returns (bool) {
        if (excludedFromTransferLimit[from] || excludedFromTransferLimit[to])
            return true;

        uint256 balance = balanceOf(from);
        uint256 price = dividendTracker.getTokenPrice();

        if (price.mul(balance).div(10 ** _decimals) < 15 * 10 ** 8)      // balance < $15
            return true;

        if (block.timestamp >= firstPurchasedTime[from].add(totalLockedPeriod))
            return true;

        if (block.timestamp < lastTransferTime[from].add(subLockedPeriod))
            return false;

        if (block.timestamp >= firstPurchasedTime[from].add(totalLockedPeriod.div(2)))
            if (amount >= balanceOf(from).div(2))
                return false;

        if (block.timestamp < firstPurchasedTime[from].add(totalLockedPeriod.div(2)))
            if (amount >= balanceOf(from).div(4))
                return false;

        return true;
    }

    /**
     * @notice Set the giveaways to be active.
     */
    function setGiveAways(bool _enable) external onlyOwner {
        enableGiveAways = _enable;
    }

    /**
     * @notice Set the period for giveaways rewards.
     */
    function setInitialTimeForGiveAways(uint256 _time) external onlyOwner {
        lastGiveAwaysTime = _time - periosForGiveAways;
    }

    /**
     * @notice Set the minimum limit price for giveaways rewards.
     */
    function setLimitPriceForGiveAways(uint256 _price) external onlyOwner {
        limitPriceForGiveAways = _price * 10 ** 18;     // amount of BUSD
    }

    /**
     * @notice Swap tokens for ETH and add liquidity
     */ 
    function swapAndLiquify(uint256 tokens) public {
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

        uint256 rate2Eth = newBalance.mul(10 ** _decimals).div(half);
        dividendTracker.setRate2Eth(rate2Eth);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    /**
     * @notice Swap tokens for ETH
     */        
    function swapTokensForEth(uint256 tokenAmount) public {
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

    /**
     * @notice Add liquidity to uniswap
     */
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    /**
     * @notice Swap ACRU and BUSD
     */
    function swapTokensForRewardToken(uint256 tokenAmount) public {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;

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

    /**
     * @notice Swap and send fee for reflection, giveaways, NFT investors
     */
    function swapAndSendRewards(uint256 tokens) public {
        uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));

        swapTokensForRewardToken(tokens);

        uint256 newBalance = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);

        uint256 totalFee = rewardsFee.add(marketingFee).add(giveAwayFee).add(nftFee);

        uint256 amount = newBalance.mul(marketingFee).div(totalFee);
        sendToMarketingFee(amount);
        newBalance.sub(amount);

        amount = newBalance.mul(giveAwayFee).div(totalFee);
        sendToGiveaways(amount);
        newBalance.sub(amount);

        amount = newBalance.mul(nftFee).div(totalFee);
        sendToNFTFee(amount);
        newBalance.sub(amount);

        sendDividends(newBalance);
    }

    /**
     * @notice send Marketing fee
     */
    function sendToMarketingFee(uint256 tokens) public {
        bool success = IERC20(BUSD).transfer(marketWalletAddress, tokens);

        if (success) {
            emit SendMarketingFee(tokens);
        }
    }

    /**
     * @notice Send Givesaways fee
     */
    function sendToGiveaways(uint256 tokens) public {
        totalGiveAwaysRewards = totalGiveAwaysRewards.add(tokens);      // $BUSD

        bool success = IERC20(BUSD).transfer(address(dividendTracker), tokens);

        if (success) {
            if (block.timestamp.sub(lastGiveAwaysTime) >= periosForGiveAways) {
                generateRandomAccountForGiveAway();
            }

            emit SendGiveAwaysFee(tokens);
        }
    }

    /**
     * @notice Generate randomized list of accouts for giveaways reward.
     */
    function generateRandomAccountForGiveAway() public onlyOwner {
        if (!enableGiveAways)
            return;
        
        uint256 candidateCount = totalGiveAwaysRewards.div(limitPriceForGiveAways);
        uint256 totalHolders = dividendTracker.getNumberOfTokenHolders();

        uint256 randIndex;
        uint256 Index;
        uint256 count = 0;
        while (count < candidateCount) {
            randIndex = _random(totalHolders).mod(totalHolders);
            Index = _fillAssignOrder(--totalHolders, randIndex);

            (address account,,,,,,,) = dividendTracker.getAccountAtIndex(Index);
            dividendTracker.setGiveAwaysRewards(account, limitPriceForGiveAways);
            totalGiveAwaysRewards = totalGiveAwaysRewards.sub(limitPriceForGiveAways);

            count ++;
        }

        lastGiveAwaysTime = block.timestamp;
    }

    /**
     * @notice Get the random number in the rage of _count
     */
    function _random(uint _count) public view returns(uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / block.timestamp) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(_msgSender())))) / block.timestamp) + block.number)
            )
        ) / _count;
    }

    function _fillAssignOrder(uint256 orderA, uint256 orderB) public returns(uint256) {
        uint256 temp = orderA;
        if (assignOrders[orderA] > 0) temp = assignOrders[orderA];
        assignOrders[orderA] = orderB;
        if (assignOrders[orderB] > 0) assignOrders[orderA] = assignOrders[orderB];
        assignOrders[orderB] = temp;
        return assignOrders[orderA];
    }

    /**
     * @notice Send transaction fee to dividend trancer.
     */
    function sendDividends(uint256 tokens) public {
        bool success = IERC20(BUSD).transfer(address(dividendTracker), tokens);

        // check empty member group.
        uint256 emptyRate = dividendTracker.getTotalRatesOfEmptyGroups();

        if (emptyRate > 0) {
            uint256 amountForGiveaways = tokens.mul(emptyRate).div(100);
            totalGiveAwaysRewards = totalGiveAwaysRewards.add(amountForGiveaways);

            emit SendGiveAwaysFee(amountForGiveaways);

            tokens = tokens.sub(amountForGiveaways);
        }

        if (success) {
            dividendTracker.distributeCAKEDividends(tokens);
            emit SendDividends(tokens);
        }
    }

    /**
     * @notice Send NFT fee to NFT investors
     */
    function sendToNFTFee(uint256 tokens) public {
        totalNFTRewards += tokens;

        bool success = IERC20(BUSD).transfer(address(nftInvestor), tokens);

        if (success) {
            nftInvestor.distributeRewards(tokens);

            emit SendNFTFee(tokens);
        }
    }
}

contract AcruDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    uint256 private constant MAX = ~uint256(0);  //~uint256(0) = 2**256-1

    AggregatorV3Interface internal priceFeedOfEth;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    uint256 private constant _decimalsInPrice = 8;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(address _cake) DividendPayingToken("ACRU_Dividend_Tracker", "ACRUDT", _cake) {
        claimWait = 1 hours;
        minimumTokenBalanceForDividends = 1_000 * (10**18);

//      priceFeedOfEth = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); // BNB/USD in BSC mainnet
        priceFeedOfEth = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // BNB/USD in BSC testnet

        initGroup();
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "ACRU_Dividend_Tracker: No transfers allowed");
    }

    function initGroup() internal {
        addGroup(0, 100 * 10 ** _decimalsInPrice, 0);
        addGroup(100 * 10 ** _decimalsInPrice, 500 * 10 ** _decimalsInPrice, 29);
        addGroup(500 * 10 ** _decimalsInPrice, 2000 * 10 ** _decimalsInPrice, 23);
        addGroup(2000 * 10 ** _decimalsInPrice, 4000 * 10 ** _decimalsInPrice, 9);
        addGroup(4000 * 10 ** _decimalsInPrice, 8000 * 10 ** _decimalsInPrice, 8);
        addGroup(8000 * 10 ** _decimalsInPrice, 16000 * 10 ** _decimalsInPrice, 7);
        addGroup(16000 * 10 ** _decimalsInPrice, 32000 * 10 ** _decimalsInPrice, 6);
        addGroup(32000 * 10 ** _decimalsInPrice, 65000 * 10 ** _decimalsInPrice, 5);
        addGroup(65000 * 10 ** _decimalsInPrice, 125000 * 10 ** _decimalsInPrice, 4);
        addGroup(125000 * 10 ** _decimalsInPrice, 250000 * 10 ** _decimalsInPrice, 3);
        addGroup(250000 * 10 ** _decimalsInPrice, 500000 * 10 ** _decimalsInPrice, 2);
        addGroup(500000 * 10 ** _decimalsInPrice, 1000000 * 10 ** _decimalsInPrice, 2);
        addGroup(1000000 * 10 ** _decimalsInPrice, MAX, 2);
    }

    function setRate2Eth(uint256 _rate) external onlyOwner {
        (, int _price, , , ) = priceFeedOfEth.latestRoundData();

        price = _rate * _price.toUint256Safe() / 10 ** _decimals;

        minimumTokenBalanceForDividends = (100 * 10 ** _decimalsInPrice / price) * (10 ** _decimals);
    }

    function getTokenPrice() external view returns (uint256){
        return price;
    }

    function withdrawDividend() public pure override {
        require(false, "ACRU_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main ACRU contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "ACRU_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "ACRU_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;

                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }

        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
    }

    function process() public pure returns (uint256, uint256, uint256) {
        return (0,0,0);
/*
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if(numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if(canAutoClaim(lastClaimTimes[account])) {
                if(processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);*/
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if(amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}