// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
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
     * - `to` cannot be the zero address.
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../math/SafeMath.sol";
import "../../utils/Arrays.sol";
import "../../utils/Counters.sol";
import "./ERC20.sol";

/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */
abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view virtual returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }


    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
      super._beforeTokenTransfer(from, to, amount);

      if (from == address(0)) {
        // mint
        _updateAccountSnapshot(to);
        _updateTotalSupplySnapshot();
      } else if (to == address(0)) {
        // burn
        _updateAccountSnapshot(from);
        _updateTotalSupplySnapshot();
      } else {
        // transfer
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);
      }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        // solhint-disable-next-line max-line-length
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Receiver.sol";
import "../../introspection/ERC165.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";
import "../../utils/EnumerableSet.sol";
import "../../utils/EnumerableMap.sol";
import "../../utils/Strings.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
   /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../math/SafeMath.sol";

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

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
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev AccessManager limits access to owner allowed addresses.
 * @notice AccessManager mantem uma lista de endereços com acesso permitido e negado. 
 * Exemplo de utilização é o LiqiBrlToken, que só deixa endereços com permissão emitir tokens.
**/
contract AccessManager is Ownable {
    // Address-permission access map
    mapping(address => bool) private accessMap;

    /**
     * @dev Only allow access from specified contracts
     */
    modifier onlyAllowedAddress() {
        require(accessMap[_msgSender()], "Access: sender not allowed");
        _;
    }

    /**
     * @dev Gets if the specified address has access
     * @notice Retorna se o endereço especificado tem acesso
     * @param _address Address to check access
     */
    function getAccess(address _address) public view returns (bool) {
        return accessMap[_address];
    }

    /**
     * @dev Enables access to the specified address
     * @notice Dá permissões de acesso para o endereço especificado
     * @param _address Address to enable access
     */
    function enableAccess(address _address) external onlyOwner {
        // check if the address is empty
        require(_address != address(0), "Address is empty");
        // check if the user already has access
        require(!accessMap[_address], "User already has access");

        // allow the address to access
        accessMap[_address] = true;
    }

    /**
     * @dev Disables access to the specified address
     * @notice Remove permissões de acesso para o endereço especificado
     * @param _address Address to disable access
     */
    function disableAccess(address _address) external onlyOwner {
        // check if the address is empty
        require(_address != address(0), "Address is empty");
        // check if the user already has no access
        require(accessMap[_address], "User already has no access");

        // disallow the address        
        accessMap[_address] = false;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IOffer_v2.sol";
import "./ISignatureManager.sol";

/**
 * @dev BaseOfferSale is the base module for all offer modules in the platform
 * It's used primarily for unit testing
 * This contract's code should be the same as genesis Offer.sol
 * @notice Contrato base para todas as ofertas na plataforma
 */
contract BaseOfferSale is Ownable, IOffer {
    // SafeMath for all math operations
    using SafeMath for uint256;

    // To save cashout date/amount so we can filter by date
    struct SubPayment {
        // The amount of tokens the user cashed out
        uint256 amount;
        // The date the user performed this cash out
        uint256 date;
    }

    // Create a structure to save our payments
    struct Payment {
        // The total amount the user bought
        uint256 totalInputAmount;
        // The total amount the user bought in tokens
        uint256 totalAmount;
        // The total amount the user has received in tokens
        uint256 totalPaid;
        // Dates the user cashed out from the offer
        SubPayment[] cashouts;
        // Payments
        SubPayment[] payments;
    }

    // If the offer has been initialized by the owner
    bool internal bInitialized;
    // If the success condition has been met
    bool internal bSuccess;
    // If the offer has finished the sale of tokens
    bool internal bFinished;

    // A counter of the total amount of tokens sold
    uint256 internal nTotalSold;

    // The date the offer finishOffer function was called
    uint256 internal nFinishDate;

    // A map of address to payment
    mapping(address => Payment) internal mapPayments;

    // TESTING: The current rate the tokens are traded at
    uint256 private nRate = 1;

    event OnInvest(address _investor, uint256 _amount);

    constructor() public {}

    function initialize() public override {
        require(!bInitialized, "Offer is already initialized");

        bInitialized = true;

        _initialize();
    }

    /**
     * @dev TESTING PURPOSES: changes the initialized state of the contract
     */
    function setInitialized() public onlyOwner {
        require(!bInitialized, "Offer is already successful");

        bInitialized = true;
    }

    /**
     * @dev Base function for all investments in the offer
     * @notice Função base para investimento,
     * grava a quantidade de tokens que o usuário investiu, converte de acordo com a rate e passa pelas regras e módulos setados pelo gerador.
     */
    function invest(address _investor, uint256 _amount) public onlyOwner {
        // make sure the investor is not an empty address
        require(_investor != address(0), "Investor is empty");
        // make sure the amount is not zero
        require(_amount != 0, "Amount is zero");
        // do not sell if offer is finished
        require(!bFinished, "Offer is already finished");
        // do not sell if not initialized
        require(bInitialized, "Offer is not initialized");

        // read the payment data from our map
        Payment storage payment = mapPayments[_investor];

        // increase the amount of tokens this investor has invested
        payment.totalInputAmount = payment.totalInputAmount.add(_amount);

        // pass the function to one of our modules
        _investInput(_investor, _amount);

        // convert input currency to output
        // - get rate from module
        uint256 nTokenRate = _getRate();

        // - total amount from the rate obtained
        uint256 nOutputAmount = _amount.div(nTokenRate);

        // pass to module to handling outputs
        _investOutput(_investor, nOutputAmount, payment);

        // increase the amount of tokens this investor has purchased
        payment.totalAmount = payment.totalAmount.add(nOutputAmount);

        // after everything, add the bought tokens to the total
        nTotalSold = nTotalSold.add(nOutputAmount);

        // now make sure everything we've done is okay
        _rule();

        // and check if the offer is sucessful after this sale
        if (!bSuccess) {
            _investNoSuccess();
        }

        emit OnInvest(_investor, _amount);
    }

    /**
     * @dev Finishes the offer of tokens, restricting sale and executing the modules for ending
     * @notice Finaliza a oferta de tokens, restringindo a venda e executando os módulos de término
     */
    function finishOffer() public onlyOwner {
        // only if not finished
        require(!bFinished, "Offer is already finished");
        bFinished = true;

        // save the date the offer finished
        nFinishDate = block.timestamp;

        // call module
        _finishOffer();
    }

    function cashoutTokens(address _investor)
        external
        virtual
        override
        returns (bool)
    {
        return bFinished;
    }

    function _initialize() internal virtual {}

    function getRate() public view virtual returns (uint256 rate) {
        return _getRate();
    }

    function _getRate() internal view virtual returns (uint256 rate) {
        return nRate;
    }

    function _investInput(address _investor, uint256 _amount)
        internal
        virtual
    {}

    function _investOutput(
        address _investor,
        uint256 _outputAmount,
        Payment storage payment
    ) internal virtual {}

    function _finishOffer() internal virtual {}

    function _rule() internal virtual {}

    function _investNoSuccess() internal virtual {}

    /**
     * @dev TESTING PURPOSES: changes the rate the token is traded at
     */
    function setRate(uint256 _rate) public {
        nRate = _rate;
    }

    /**
     * @dev TESTING PURPOSES: changes the success state of the contract
     */
    function setSuccess() public onlyOwner {
        require(bInitialized, "Offer is not initialized");

        require(!bSuccess, "Offer is already successful");

        bSuccess = true;
    }

    function getFinishDate() external view override returns (uint256) {
        return nFinishDate;
    }

    function getInitialized() public view override returns (bool) {
        return bInitialized;
    }

    function getFinished() public view override returns (bool) {
        return bFinished;
    }

    function getSuccess() public view override returns (bool) {
        return bSuccess;
    }

    function getTotalBought(address _investor)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    function getTotalCashedOut(address _investor)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    function getTotalBoughtDate(address _investor, uint256 _date)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    function getTotalCashedOutDate(address _investor, uint256 _date)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    function getTotalSold() public view virtual returns (uint256 totalSold) {
        return nTotalSold;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev BaseOfferToken is the base module for all token modules in the platform
 * It's used primarily for unit testing
 * This contract's code should be the same as genesis Token.sol
 */
contract BaseOfferToken is ERC20Snapshot, Ownable {
    // A fuse to disable the exchangeBalance function
    bool internal bDisabledExchangeBalance;

    /**
     * @dev Liqi Offer Token
     */
    constructor(string memory _name, string memory _symbol)
        public
        ERC20(_name, _symbol)
    {}

    /**
     * @dev Disables the exchangeBalance function
     */
    function disableExchangeBalance() public onlyOwner {
        require(
            !bDisabledExchangeBalance,
            "Exchange balance is already disabled"
        );

        bDisabledExchangeBalance = true;
    }

    /**
     * @dev Exchanges the funds of one address to another
     */
    function exchangeBalance(address _from, address _to) public onlyOwner {
        // check if the function is disabled
        require(
            !bDisabledExchangeBalance,
            "Exchange balance has been disabled"
        );
        // simple checks for empty addresses
        require(_from != address(0), "Transaction from 0x");
        require(_to != address(0), "Transaction to 0x");

        // get current balance of _from address
        uint256 amount = balanceOf(_from);

        // check if there's balance to transfer
        require(amount != 0, "Balance is 0");

        // transfer balance to new address
        _transfer(_from, _to, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

/**
 * @dev IOffer is the base interface for all offers in the platform
 */
interface IOffer {
    /**
     * @dev Returns true if the sale is initialized and ready for operation
     */
    function getInitialized() external view returns (bool);

    /**
     * @dev Returns true if the sale has finished operations and can no longer sell
     */
    function getFinished() external view returns (bool);

    /**
     * @dev Returns true if the sale has reached a successful state (should be unreversible)
     */
    function getSuccess() external view returns (bool);

    /**
     * @dev Returns the total amount of tokens bought by the specified _investor
     */
    function getTotalBought(address _investor) external view returns (uint256);

    /**
     * @dev Returns the total amount of tokens cashed out by the specified _investor
     */
    function getTotalCashedOut(address _investor)
        external
        view
        returns (uint256);

    /**
     * @dev Returns the total amount of tokens bought by the specified _investor
     */
    function getTotalBoughtDate(address _investor, uint256 _date)
        external
        view
        returns (uint256);

    /**
     * @dev Returns the total amount of tokens the specified investor
     * has cashed out from this contract, up to the specified date
     */
    function getTotalCashedOutDate(address _investor, uint256 _date)
        external
        view
        returns (uint256);

    /**
     * @dev If the sale is finished, returns the date it finished at
     */
    function getFinishDate() external view returns (uint256);

    /**
     * @dev Prepares the sale for operation
     */
    function initialize() external;

    /**
     * @dev If possible, cashouts tokens for the specified _investor
     */
    function cashoutTokens(address _investor) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

/**
 * @dev IOffer is the base interface for all offers in the platform
 */
interface IOffer {
    /**
     * @dev Returns true if the sale is initialized and ready for operation
     */
    function getInitialized() external view returns (bool);

    /**
     * @dev Returns true if the sale has finished operations and can no longer sell
     */
    function getFinished() external view returns (bool);

    /**
     * @dev Returns true if the sale has reached a successful state (should be unreversible)
     */
    function getSuccess() external view returns (bool);

    /**
     * @dev Returns the total amount of tokens bought by the specified _investor
     */
    function getTotalBought(address _investor) external view returns (uint256);

    /**
     * @dev Returns the total amount of tokens cashed out by the specified _investor
     */
    function getTotalCashedOut(address _investor)
        external
        view
        returns (uint256);

    /**
     * @dev If the sale is finished, returns the date it finished at
     */
    function getFinishDate() external view returns (uint256);

    /**
     * @dev Prepares the sale for operation
     */
    function initialize() external;

    /**
     * @dev If possible, cashouts tokens for the specified _investor
     */
    function cashoutTokens(address _investor) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

/**
 * @dev ISignatureManager
 */
interface ISignatureManager {
    function isSigned(address _assetAddress) external view returns (bool);
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev NFT ERC721 base contract
 *
 */
contract NFBaseToken is ERC721, Ownable {
    using SafeMath for uint256;

    /**
     * @dev Constructor for NFBaseToken
     */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol
    ) public ERC721(_tokenName, _tokenSymbol) {
    }

}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

/**
 * @dev Distributes Eth to specified addresses
 * @notice Automaticamente envia Ether para os endereços especificados na função enableRedistribution.
 * Esse contrato é um experimento para eliminação de taxas na transferência de Ether para multiplos usuários.
 * A primeira vez que invoca enableRedistribution com 64 endereços custa mais caro, mas o preço é otimizado
 * a partir da segunda para extremamente próximo do valor puro de transferência.
 * A principal vantagem desse contrato é que conseguimos fazer 64 transferências em apenas 2 transações.
 **/
contract EthRedistribution {
    struct Payment {
        uint256 amount;
        address destination;
    }

    Payment[64] private payments;
    uint256 toPay;

    /**
     * @dev Enable redistribution
     * @notice Prepara a redistribuição para a próxima vez que o contrato receber Ether
     */
    function enableRedistribution(
        uint256[] calldata _amounts,
        address[] calldata _destinations
    ) external {
        toPay = _amounts.length;

        for (uint256 i = 0; i < _amounts.length; i++) {
            uint256 amount = _amounts[i];
            address destination = _destinations[i];

            payments[i].amount = amount;
            payments[i].destination = destination;
        }
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        //require(toPay != 0, "Nothing to pay");

        for (uint256 i = 0; i < toPay; i++){
            Payment memory payment = payments[i];

            address payable addr2 = address(uint160(payment.destination));
            //address payable addr3 = payable(addr1);
            addr2.transfer(payment.amount);
        }
        toPay = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00 - Contract Instance
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

import "./BokkyPooBahsDateTimeLibrary.sol";

contract BokkyPooBahsDateTimeContract {
    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint public constant SECONDS_PER_HOUR = 60 * 60;
    uint public constant SECONDS_PER_MINUTE = 60;
    int public constant OFFSET19700101 = 2440588;

    uint public constant DOW_MON = 1;
    uint public constant DOW_TUE = 2;
    uint public constant DOW_WED = 3;
    uint public constant DOW_THU = 4;
    uint public constant DOW_FRI = 5;
    uint public constant DOW_SAT = 6;
    uint public constant DOW_SUN = 7;

    function _now() public view returns (uint timestamp) {
        timestamp = now;
    }
    function _nowDateTime() public view returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(now);
    }
    function _daysFromDate(uint year, uint month, uint day) public pure returns (uint _days) {
        return BokkyPooBahsDateTimeLibrary._daysFromDate(year, month, day);
    }
    function _daysToDate(uint _days) public pure returns (uint year, uint month, uint day) {
        return BokkyPooBahsDateTimeLibrary._daysToDate(_days);
    }
    function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDateTime(year, month, day, hour, minute, second);
    }
    function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }
    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);
    }

    function isValidDate(uint year, uint month, uint day) public pure returns (bool valid) {
        valid = BokkyPooBahsDateTimeLibrary.isValidDate(year, month, day);
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (bool valid) {
        valid = BokkyPooBahsDateTimeLibrary.isValidDateTime(year, month, day, hour, minute, second);
    }
    function isLeapYear(uint timestamp) public pure returns (bool leapYear) {
        leapYear = BokkyPooBahsDateTimeLibrary.isLeapYear(timestamp);
    }
    function _isLeapYear(uint year) public pure returns (bool leapYear) {
        leapYear = BokkyPooBahsDateTimeLibrary._isLeapYear(year);
    }
    function isWeekDay(uint timestamp) public pure returns (bool weekDay) {
        weekDay = BokkyPooBahsDateTimeLibrary.isWeekDay(timestamp);
    }
    function isWeekEnd(uint timestamp) public pure returns (bool weekEnd) {
        weekEnd = BokkyPooBahsDateTimeLibrary.isWeekEnd(timestamp);
    }

    function getDaysInMonth(uint timestamp) public pure returns (uint daysInMonth) {
        daysInMonth = BokkyPooBahsDateTimeLibrary.getDaysInMonth(timestamp);
    }
    function _getDaysInMonth(uint year, uint month) public pure returns (uint daysInMonth) {
        daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(year, month);
    }
    function getDayOfWeek(uint timestamp) public pure returns (uint dayOfWeek) {
        dayOfWeek = BokkyPooBahsDateTimeLibrary.getDayOfWeek(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint year) {
        year = BokkyPooBahsDateTimeLibrary.getYear(timestamp);
    }
    function getMonth(uint timestamp) public pure returns (uint month) {
        month = BokkyPooBahsDateTimeLibrary.getMonth(timestamp);
    }
    function getDay(uint timestamp) public pure returns (uint day) {
        day = BokkyPooBahsDateTimeLibrary.getDay(timestamp);
    }
    function getHour(uint timestamp) public pure returns (uint hour) {
        hour = BokkyPooBahsDateTimeLibrary.getHour(timestamp);
    }
    function getMinute(uint timestamp) public pure returns (uint minute) {
        minute = BokkyPooBahsDateTimeLibrary.getMinute(timestamp);
    }
    function getSecond(uint timestamp) public pure returns (uint second) {
        second = BokkyPooBahsDateTimeLibrary.getSecond(timestamp);
    }

    function addYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addYears(timestamp, _years);
    }
    function addMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addMonths(timestamp, _months);
    }
    function addDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addDays(timestamp, _days);
    }
    function addHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addHours(timestamp, _hours);
    }
    function addMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addMinutes(timestamp, _minutes);
    }
    function addSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addSeconds(timestamp, _seconds);
    }

    function subYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subYears(timestamp, _years);
    }
    function subMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subMonths(timestamp, _months);
    }
    function subDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subDays(timestamp, _days);
    }
    function subHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subHours(timestamp, _hours);
    }
    function subMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subMinutes(timestamp, _minutes);
    }
    function subSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.subSeconds(timestamp, _seconds);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) public pure returns (uint _years) {
        _years = BokkyPooBahsDateTimeLibrary.diffYears(fromTimestamp, toTimestamp);
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) public pure returns (uint _months) {
        _months = BokkyPooBahsDateTimeLibrary.diffMonths(fromTimestamp, toTimestamp);
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days) {
        _days = BokkyPooBahsDateTimeLibrary.diffDays(fromTimestamp, toTimestamp);
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) public pure returns (uint _hours) {
        _hours = BokkyPooBahsDateTimeLibrary.diffHours(fromTimestamp, toTimestamp);
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) public pure returns (uint _minutes) {
        _minutes = BokkyPooBahsDateTimeLibrary.diffMinutes(fromTimestamp, toTimestamp);
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) public pure returns (uint _seconds) {
        _seconds = BokkyPooBahsDateTimeLibrary.diffSeconds(fromTimestamp, toTimestamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

library LiqiMathLib {
    /**
     * @notice Usado pela função mulDiv
     */
    function fullMul(uint256 x, uint256 y)
        internal
        pure
        returns (uint256 l, uint256 h)
    {
        uint256 xl = uint128(x);
        uint256 xh = x >> 128;
        uint256 yl = uint128(y);
        uint256 yh = y >> 128;
        uint256 xlyl = xl * yl;
        uint256 xlyh = xl * yh;
        uint256 xhyl = xh * yl;
        uint256 xhyh = xh * yh;

        uint256 ll = uint128(xlyl);
        uint256 lh = (xlyl >> 128) + uint128(xlyh) + uint128(xhyl);
        uint256 hl = uint128(xhyh) + (xlyh >> 128) + (xhyl >> 128);
        uint256 hh = (xhyh >> 128);
        l = ll + (lh << 128);
        h = (lh >> 128) + hl + (hh << 128);
    }

    /**
     * @notice Calcula x * y / z, de forma que não estoure o limite
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        require(h < z);
        uint256 mm = mulmod(x, y, z);
        if (mm > l) h -= 1;
        l -= mm;
        uint256 pow2 = z & -z;
        z /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        return l * r;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AccessManager.sol";

/**
 * @dev LiqiBrlToken is Liqi's stable coin linked to the Brazilian Real. The token has 20 decimals 
 * @notice LiqiBrlToken é a stable coin da Liqi linkada ao Real Brasileiro. O token possui 20 decimais
**/
contract LiqiBRLToken is ERC20, Ownable, AccessManager {
    using SafeMath for uint256;

    /**
     * @dev Liqi Offer Token
     */
    constructor() public ERC20("Liqi BRL", "BRLT") {
        _setupDecimals(20);
    }

    /**
     * @dev Allow minting by the owner
     * @notice Minta tokens na carteira especificada.
     * Somente o owner pode invocar.
     */
    function mint(address _account, uint256 _amount) public onlyOwner {
        require(_account != address(0), "Account is empty");
        require(_amount != 0, "Amount is zero");

        _mint(_account, _amount);
    }

    /**
     * @dev Allow burning by the owner
     * @notice Queima os tokens na carteira do dono do contrato.
     * Somente o owner pode invocar.
     */
    function burn(uint256 _amount) public onlyOwner {
        require(_amount != 0, "Amount is zero");

        _burn(owner(), _amount);
    }

    /**
     * @dev Exchanges the funds of one address to another
     * @notice Troca o balanço da conta _from e _to.
     * Somente o owner pode invocar.
     */
    function exchangeBalance(address _from, address _to) public onlyOwner {
        require(_from != address(0), "From is empty");
        require(_to != address(0), "To is empty");

        // get current balance of _from address
        uint256 nAmount = balanceOf(_from);

        // dont proceed if theres nothing to exchange
        require(nAmount != 0, "Amount is zero");

        // transfer balance to new address
        _transfer(_from, _to, nAmount);
    }

    /**
     * @dev Invest mints the funds on the _investor address and transfers them to the sender address
     * @notice Invest minta a quantidade de fundos no endereço especificado, e os transfere para o endereço de chamada
     */
    function invest(address _investor, uint256 _amount)
        public
        onlyAllowedAddress
    {
        // no empty address
        require(_investor != address(0), "Investor is empty");

        // no zero amount
        require(_amount != 0, "Amount is zero");

        // mint the BRLT tokens to the investor account
        _mint(_investor, _amount);

        // transfer balance to new address
        _transfer(_investor, _msgSender(), _amount);
    }

    /**
     * @dev FailedSale is only called from failed sales
     * @notice FailedSale é chamado pelo contrato de oferta quando uma oferta é finalizada sem sucesso.
     * Esse método queima todos os tokens BRLT do endereço que invoca
     */
    function failedSale() public onlyAllowedAddress {
        // get the address of the caller
        address aSender = _msgSender();

        // get the balance of the offer
        uint256 nBalance = balanceOf(aSender);

        // burn everything
        _burn(aSender, nBalance);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "../../../base/BaseOfferSale.sol";
import "../../../LiqiBRLToken.sol";

/**
 * @dev InputBRLT handles investments using Liqi's BRLT tokens
 * @notice InputBRLT administra investimentos na oferta usando LiqiBRLTs.
 * A cada investimento, há uma chamada ao invest() do BRLToken, que minta os tokens na conta do investidor e automaticamente os transfere à este contrato.
 * Se a oferta for finalizada sem sucesso, todos os tokens são queimados utilizando a função failedSale() do BRLToken.
 */
contract InputBRLT is BaseOfferSale {
    // SafeMath for all math operations
    using SafeMath for uint256;

    // A reference to the BRLToken contract
    LiqiBRLToken private brlToken;

    // A reference to the issuer of the offer
    address private aIssuer;

    // Total amount of BRLT tokens collected during sale
    uint256 internal nTotalCollected;

    /**
     * @dev Investment with Liqi's BRLT token
     */
    constructor(address _issuer, address _brlTokenContract)
        public
        BaseOfferSale()
    {
        // save the issuer's address
        aIssuer = _issuer;

        // convert the BRLT's address to our interface
        brlToken = LiqiBRLToken(_brlTokenContract);
    }

    /**
     * @dev Cashouts BRLTs paid to the offer to the issuer
     * @notice Faz o cashout de todos os BRLTs que estão nesta oferta para o issuer, se a oferta já tiver sucesso.
     */
    function cashoutIssuerBRLT() public {
        // no cashout if offer is not successful
        require(bSuccess, "Offer is not successful");

        // check the balance of tokens of this contract
        uint256 nBalance = brlToken.balanceOf(address(this));

        // nothing to execute if the balance is 0
        require(nBalance != 0, "Balance to cashout is 0");

        // transfer all tokens to the issuer account
        brlToken.transfer(aIssuer, nBalance);
    }

    function _finishOffer() internal virtual override {
        if (!getSuccess()) {
            // notify the BRLT token that we failed, so tokens are burned
            brlToken.failedSale();
        }
    }

    function _investInput(address _investor, uint256 _amount)
        internal
        virtual
        override
    {
        // call with same arguments
        brlToken.invest(_investor, _amount);

        // add the amount to the total
        nTotalCollected = nTotalCollected.add(_amount);
    }

    /**
     * @dev Returns the address of the input token
     * @notice Retorna o endereço do token de input (BRLT)
     */
    function getInputToken() public view returns (address) {
        return address(brlToken);
    }

    /**
     * @dev Returns the total amount of tokens invested
     * @notice Retorna quanto total do token de input (BRLT) foi coletado
     */
    function getTotalCollected() public view returns (uint256) {
        return nTotalCollected;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "../../../base/BaseOfferSale.sol";
import "../../../LiqiBRLToken.sol";

/**
 * @dev InputMarketplaceBRLT handles investments using Liqi's BRLT tokens inside the marketplace
 * @notice InputMarketplaceBRLT administra tokens num ambiente de mercado.
 * Esse contrato não está pronto para produção.
 */
contract InputMarketplaceBRLT is BaseOfferSale {
    // SafeMath for all math operations
    using SafeMath for uint256;

    // A reference to the BRLToken contract
    LiqiBRLToken private brlToken;

    // A reference to the issuer of the offer
    address private aIssuer;

    // Total amount of BRLT tokens collected during sale
    uint256 internal nTotalCollected;

    // A map for the returnal of tokens, if the sale fails
    mapping(address => bool) internal mapReturnals;

    /**
     * @dev Investment with Liqi's BRLT token
     */
    constructor(address _issuer, address _brlTokenContract)
        public
        BaseOfferSale()
    {
        // save the issuer's address
        aIssuer = _issuer;

        // convert the BRLT's address to our interface
        brlToken = LiqiBRLToken(_brlTokenContract);
    }

    function cashoutBRLT() public {
        // cache the sender
        address aSender = _msgSender();

        cashoutAnyBRLT(aSender);
    }

    /**
     * @dev In case of failure, cashout BRLTs invested in the offer
     */
    function cashoutAnyBRLT(address _investor) public {
        // make sure the offer is finished
        require(bFinished, "Offer is not finished");

        // only cashout if finished and failure
        require(!bSuccess, "Offer is successfull");

        // make sure the user has not cashed out
        require(!mapReturnals[_investor], "Already cashed out");

        // check the balance of tokens of this contract
        Payment storage payment = mapPayments[_investor];

        // return the tokens
        brlToken.transfer(_investor, payment.totalInputAmount);

        // save that we returned his tokens
        mapReturnals[_investor] = true;
    }

    /**
     * @dev Cashouts BRLTs paid to the offer to the issuer
     */
    function cashoutIssuerBRLT() public {
        // no cashout if offer is not successful
        require(bSuccess, "Offer is not successful");

        // check the balance of tokens of this contract
        uint256 nBalance = brlToken.balanceOf(address(this));

        // nothing to execute if the balance is 0
        require(nBalance != 0, "Balance to cashout is 0");

        // transfer all tokens to the issuer account
        brlToken.transfer(aIssuer, nBalance);
    }

    function _finishOffer() internal virtual override {
        if (!getSuccess()) {
            // notify the BRLT token that we failed, so tokens are burned
            //brlToken.failedSale();
        }
    }

    function _investInput(address _investor, uint256 _amount)
        internal
        virtual
        override
    {
        // call with same arguments
        //brlToken.investMkt(_investor, _amount);

        // add the amount to the total
        nTotalCollected = nTotalCollected.add(_amount);
    }

    /**
     * @dev Returns the address of the input token
     */
    function getInputToken() public view returns (address) {
        return address(brlToken);
    }

    /**
     * @dev Returns the total amount of tokens invested
     */
    function getTotalCollected() public view returns (uint256) {
        return nTotalCollected;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../../../base/BaseOfferSale.sol";
import "../../../base/BaseOfferToken.sol";

/**
 * @dev OutputOnDemandTransfer sells tokens to investors on demand
 * (i.e. tokens are pre-emitted and held by the offer contract)
 * @notice OutputOnDemandTransfer vende tokens para investidores sob-demanda
 * (tokens são pré-emitidos e segurados pelo contrato da oferta).
 * Se a oferta falha, retorna todos os tokens para o issuer.
 */
contract OutputOnDemandTransfer is BaseOfferSale {
    // SafeMath for all math operations
    using SafeMath for uint256;

    // A reference to the token were selling
    BaseOfferToken private baseToken;

    // A reference to the issuer of the offer
    address private aIssuer;

    // A counter for the total amount users have cashed out
    uint256 private nTotalCashedOut;

    /**
     * @dev Investment with ERC20 token
     */
    constructor(address _issuer, address _tokenAddress) public BaseOfferSale() {
        // save the issuer's address
        aIssuer = _issuer;

        // convert the token's address to our interface
        baseToken = BaseOfferToken(_tokenAddress);
    }

    function _initialize() internal override {
        // for OutputOnDemand, only the token can call initialize
        require(_msgSender() == address(baseToken), "Only call from token");
    }

    function _investOutput(
        address _investor,
        uint256 nOutputAmount,
        Payment storage payment
    ) internal virtual override {
        // get the current contract's balance
        uint256 nBalance = baseToken.balanceOf(address(this));

        // dont sell tokens that are already cashed out
        uint256 nRemainingToCashOut = nTotalSold.sub(nTotalCashedOut);

        // calculate how many tokens we can sell
        uint256 nRemainingBalance = nBalance.sub(nRemainingToCashOut);

        // make sure we're not selling more than we have
        require(
            nOutputAmount <= nRemainingBalance,
            "Offer does not have enough tokens to sell"
        );

        // log the payment
        SubPayment memory subPayment;
        subPayment.amount = nOutputAmount;
        subPayment.date = block.timestamp;
        payment.payments.push(subPayment);
    }

    function _finishOffer() internal virtual override {
        // get the current contract's balance
        uint256 nBalance = baseToken.balanceOf(address(this));

        if (getSuccess()) {
            uint256 nRemainingToCashOut = nTotalSold.sub(nTotalCashedOut);

            // calculate how many tokens we have not sold
            uint256 nRemainingBalance = nBalance.sub(nRemainingToCashOut);

            if (nRemainingBalance != 0) {
                // return remaining tokens to issuer
                baseToken.transfer(aIssuer, nRemainingBalance);
            }
        } else {
            // return all tokens to issuer
            baseToken.transfer(aIssuer, nBalance);
        }
    }

    /**
     * @dev Called directly from the token's contract,
     * cashouts any tokens the investor has that is currently on this contract
     * @notice Função restrita e só pode ser chamada do contrato do token,
     * faz o cashout de todos os tokens que o investidor tem comprados nesse contrato.
     */
    function cashoutTokens(address _investor) external override returns (bool) {
        // cashout is automatic, and done ONLY by the token
        require(_msgSender() == address(baseToken), "Call only from token");

        // wait till the offer is successful to allow transfer
        if (!bSuccess) {
            return false;
        }

        // read the token sale data for that address
        Payment storage payment = mapPayments[_investor];

        // nothing to be paid
        if (payment.totalAmount == 0) {
            return false;
        }

        // calculate the remaining tokens
        uint256 nRemaining = payment.totalAmount.sub(payment.totalPaid);

        // make sure there's something to be paid
        if (nRemaining == 0) {
            return false;
        }

        // transfer to requested user
        baseToken.transfer(_investor, nRemaining);

        // mark that we paid the user in fully
        payment.totalPaid = payment.totalAmount;

        // increase the total cashed out
        nTotalCashedOut = nTotalCashedOut.add(nRemaining);

        // log the cashout
        SubPayment memory cashout;
        cashout.amount = nRemaining;
        cashout.date = block.timestamp;
        payment.cashouts.push(cashout);

        return true;
    }

    /**
     * @dev Returns the total amount of tokens the specified investor has bought from this contract
     * @notice Retorna quantos tokens o investidor comprou em total no contrato
     */
    function getTotalBought(address _investor)
        public
        view
        override
        returns (uint256)
    {
        return mapPayments[_investor].totalAmount;
    }

    /**
     * @dev Returns the total amount of tokens the specified investor has cashed out from this contract
     * @notice Retorna quantos tokens o investidor sacou em total no contrato
     */
    function getTotalCashedOut(address _investor)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return mapPayments[_investor].totalPaid;
    }

    /**
     * @dev Returns the total amount of tokens the specified
     * investor has bought from this contract, up to the specified date
     * @notice Retorna quanto o investidor comprou até a data especificada
     */
    function getTotalBoughtDate(address _investor, uint256 _date)
        public
        view
        override
        returns (uint256)
    {
        Payment memory payment = mapPayments[_investor];
        uint256 nTotal = 0;

        for (uint256 i = 0; i < payment.payments.length; i++) {
            SubPayment memory subPayment = payment.payments[i];
            if (subPayment.date >= _date) {
                break;
            }

            nTotal = nTotal.add(subPayment.amount);
        }

        return nTotal;
    }

    /**
     * @dev Returns the total amount of tokens the specified investor
     * has cashed out from this contract, up to the specified date
     * @notice Retorna quanto o investidor sacou até a data especificada
     */
    function getTotalCashedOutDate(address _investor, uint256 _date)
        external
        view
        virtual
        override
        returns (uint256)
    {
        Payment memory payment = mapPayments[_investor];
        uint256 nTotal = 0;

        for (uint256 i = 0; i < payment.cashouts.length; i++) {
            SubPayment memory cashout = payment.cashouts[i];
            if (cashout.date >= _date) {
                break;
            }

            nTotal = nTotal.add(cashout.amount);
        }

        return nTotal;
    }

    /**
     * @dev Returns the address of the token being sold
     * @notice Retorna o endereço do token sendo vendido
     */
    function getToken() public view returns (address token) {
        return address(baseToken);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "../../../base/BaseOfferSale.sol";

/**
 * @dev Offers tokens at a fixed rate
 * @notice Oferta os tokens à uma taxa fixa
 */
contract RateUniquePhase is BaseOfferSale {
    /**
     * @dev The fixed rate to trade the token at
     * @notice A taxa fixa que o token vai ser ofertado
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;

    function _getRate() internal view override returns (uint256 rate) {
        return TOKEN_BASE_RATE;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

/**
 * @dev RuleMaxTx limits the maximum amount of input tokens a transaction can have
 * @notice RuleMaxTx limita o quantidade máxima de tokens de input que uma transação pode ter
 */
contract RuleMaxTx {
    function _ruleMaxTx(uint256 _maxTx, uint256 _amount) public pure virtual {
        require(_amount <= _maxTx, "Rule: max tx amount");
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

/**
 * @dev RuleMinTx limits the minimum amount of input tokens a transaction must have
 * @notice RuleMinTx limita o quantidade minima de tokens de input que uma transação pode ter
 */
contract RuleMinTx {
    function _ruleMinTx(uint256 _minTx, uint256 _amount) public pure virtual {
        require(_amount >= _minTx, "Rule: min tx amount");
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../../../base/BaseOfferSale.sol";
import "../../../base/BaseOfferToken.sol";
import "../../../SignatureManager.sol";

/**
 * @dev SignatureManagerOffer
 * @notice Módulo de oferta que necessita ser assinado por um SignatureManager para ser inicializado.
 */
contract SignatureManagerOffer is BaseOfferSale {
    // A reference to the contract that signs
    SignatureManager internal signatureManager;

    constructor(address _signatureManagerContract) public BaseOfferSale() {
        // convert the address to the interface
        signatureManager = SignatureManager(_signatureManagerContract);
    }

    function _initialize() internal override {
        // only initialize if our contract is signed
        require(signatureManager.isSigned(address(this)), "Contract is not signed");
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "../../../base/BaseOfferSale.sol";


/**
 * @dev SuccessMinTotalTokenSold
 * @notice Módulo que desbloqueia sucesso quando uma quantidade minima de tokens são vendidos.
 */
contract SuccessMinTotalTokenSold is BaseOfferSale {
    /**
     * @dev The minimum amount of tokens to sell
     * @notice A quantidade minima de tokens para vender
     */
    uint256 public constant MIN_TOTAL_TOKEN_SOLD = 0;

    constructor() public BaseOfferSale() {
    }

    function _investNoSuccess() internal override {
        if (nTotalSold >= MIN_TOTAL_TOKEN_SOLD) {
            // we have sold more than minimum, success
            bSuccess = true;
        }
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/BokkyPooBahsDateTimeLibrary.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev DividendsCreditERC20
 * @notice Módulo para dividendos de crédito,
 * onde a quantidade de tokens emitidos é calculado a partir do valor total das parcelas, menos a porcentagem de desconto aplicada diariamente.
 */
contract DividendsCreditERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev The price of the token
     * @notice O valor base de venda do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;

    /**
     * @dev The value of each period
     * @notice Valor de pagamento de cada parcela
     */
    uint256[] private PERIOD_VALUES = [
        105843.00 * 100 ether,
        51557.40 * 100 ether,
        36204.00 * 100 ether,
        36204.00 * 100 ether,
        36204.00 * 100 ether
    ];

    /**
     * @dev The date for each period
     * @notice Datas de pagamento de cada parcela (unix)
     */
    uint256[] private PERIOD_DATES = [
        1661871600,
        1664550000,
        1664550000,
        1661871600,
        1661871600
    ];

    /**
     * @dev
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 1648479600;

    /**
     * @dev The daily discount rate, in %
     * @notice Taxa de desconto diária em porcentagem
     */
    uint256 public constant DAILY_DISCOUNT_RATE = 0.039769808976692 * 1 ether;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    uint256 private nStatus;

    // Total amount of interest
    uint256 private nTotalInterest;
    uint256 private nTotalTokens;
    uint256 private nTotalValue;
    uint256 private nTotalDiscountedValue;
    // State of contract initialization
    bool private bInitialized;

    // Array with interest for each payment index
    uint256[] private arrInterests;
    uint256[] private arrDiscountedValue;

    /**
     * @dev Constructor for DividendCreditsERC20
     * @notice Constructor para DividendCreditsERC20
     */
    constructor(
        address _issuer,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, 0, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // make sure we have the same number of values and dates
        require(
            PERIOD_VALUES.length == PERIOD_DATES.length,
            "Values and dates must have the same size"
        );

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");
    }

    /**
     * @dev Returns true if the provided timestamp is the last day in February
     * @notice Retorna true se a timestamp provida é o último dia de Fevereiro
     */
    function isFebLastDay(uint256 _timestamp) public pure returns (bool) {
        (
            uint256 nTimeYear,
            uint256 nTimeMonth,
            uint256 nTimeDay
        ) = BokkyPooBahsDateTimeLibrary.timestampToDate(_timestamp);

        if (nTimeMonth == 2) {
            uint256 nFebDays = BokkyPooBahsDateTimeLibrary._getDaysInMonth(
                nTimeYear,
                nTimeMonth
            );

            return nTimeDay == nFebDays;
        }
        return false;
    }

    /**
     * @dev Returns how many days there are between _startDate and _endDate, considering that a year has 360 days.
     * @notice Retorna quantos dias há entre StartDate e EndDate em um ano de 360 dias. Função utilizada na inicialização, pública para referência.
     */
    function days360(
        uint256 _startDate,
        uint256 _endDate,
        bool _method
    ) public pure returns (uint256) {
        (
            uint256 nStartYear,
            uint256 nStartMonth,
            uint256 nStartDay
        ) = BokkyPooBahsDateTimeLibrary.timestampToDate(_startDate);

        (
            uint256 nEndYear,
            uint256 nEndMonth,
            uint256 nEndDay
        ) = BokkyPooBahsDateTimeLibrary.timestampToDate(_endDate);

        if (_method) {
            nStartDay = Math.min(nStartDay, 30);
            nEndDay = Math.min(nEndDay, 30);
        } else {
            // If both date A and B fall on the last day of February, then date B will be changed to
            // the 30th (unless preserving Excel compatibility)
            bool bIsStartLast = isFebLastDay(nStartDay);
            if (bIsStartLast && isFebLastDay(nEndDay)) {
                nEndDay = 30;
            }
            // If date A falls on the 31st of a month or last day of February, then date A will be changed
            // to the 30th.
            if (bIsStartLast || nStartDay == 31) {
                nStartDay = 30;
            }
            // If date A falls on the 30th of a month after applying (2) above and date B falls on the
            // 31st of a month, then date B will be changed to the 30th.
            if (nStartDay == 30 && nEndDay == 31) {
                nEndDay = 30;
            }
        }

        return
            ((nEndYear - nStartYear) * 360) +
            ((nEndMonth - nStartMonth) * 30) +
            (nEndDay - nStartDay);
    }

    /**
     * @dev
     * @notice Executada até o contrato ser inicializado,
     * faz a emissão dos tokens de acordo com as constantes definidas no contrato e
     * calcula os dados a serem utilizados por funcões de referência
     */
    function initialize() public {
        require(!bInitialized, "Contract is already initialized");
        uint256 PAGE_DIVISION = 20;
        uint256 nPages = Math.max(1, PERIOD_VALUES.length / PAGE_DIVISION);

        // convert the discount rate from 0-1 to 0-100
        uint256 nDailyDiscount = DAILY_DISCOUNT_RATE + 100 ether;

        uint256 nStartIndex = PAGE_DIVISION * nStatus;
        uint256 nFinalIndex = Math.min(
            nStartIndex + PAGE_DIVISION,
            PERIOD_VALUES.length
        );

        if (nStatus < nPages + 1) {
            for (uint256 i = nStartIndex; i < nFinalIndex; i++) {
                uint256 nPeriodValue = PERIOD_VALUES[i];
                uint256 nPeriodDate = PERIOD_DATES[i];

                require(nPeriodDate >= DATE_INTEREST_START, "Interest date provided is before one of the payments dates");

                uint256 nDays = days360(
                    DATE_INTEREST_START,
                    nPeriodDate,
                    false
                );

                // total discount = daily discount ^ number of days
                uint256 nDiscountRate = nDailyDiscount;
                for (uint256 j = 1; j < nDays; j++) {
                    nDiscountRate = nDiscountRate * nDailyDiscount;
                    nDiscountRate = nDiscountRate / 100 ether;
                }

                uint256 nDiscountedValue = nPeriodValue * 1 ether;
                nDiscountedValue = (nDiscountedValue / nDiscountRate) * 100;
                arrDiscountedValue.push(nDiscountedValue);

                nTotalValue = nTotalValue.add(nPeriodValue);
                nTotalDiscountedValue = nTotalDiscountedValue.add(
                    nDiscountedValue
                );

                // divide the discount value by the token value to get the amount of tokens this period is worth
                nTotalTokens = nTotalTokens.add(
                    nDiscountedValue.div(TOKEN_BASE_RATE)
                );
            }

            nStatus = nStatus.add(1);
        } else {
            _mint(aIssuer, nTotalTokens);

            uint256 nTotalInterestValue = nTotalValue.sub(
                nTotalDiscountedValue
            );

            uint256 nTotalInterestPC = LiqiMathLib.mulDiv(
                nTotalValue,
                100 ether,
                nTotalDiscountedValue
            );
            nTotalInterestPC = nTotalInterestPC.sub(100 ether);

            for (uint8 i = 0; i < PERIOD_VALUES.length; i++) {
                uint256 nPeriodValue = PERIOD_VALUES[i];
                uint256 nDiscountedValue = arrDiscountedValue[i];

                uint256 nPeriodInterestValue = nPeriodValue.sub(
                    nDiscountedValue
                );

                uint256 nPeriodInterestTotalPC = LiqiMathLib.mulDiv(
                    nPeriodInterestValue,
                    100 ether,
                    nTotalInterestValue
                );

                uint256 nPeriodInterestPC = LiqiMathLib.mulDiv(
                    nPeriodInterestTotalPC,
                    nTotalInterestPC,
                    100 ether
                );

                arrInterests.push(nPeriodInterestPC);

                nTotalInterest = nTotalInterest.add(nPeriodInterestPC);
            }

            bInitialized = true;
        }
    }

    /**
     * @dev Returns the discount rate for a 30-day period
     * @notice Retorna a taxa de disconto para um periodo de 30 dias
     */
    function getMonthlyDiscountRate() public pure returns (uint256) {
        uint256 nDailyDiscount = DAILY_DISCOUNT_RATE + 100 ether;

        uint256 nDiscountRate = nDailyDiscount;
        for (uint8 j = 1; j < 30; j++) {
            nDiscountRate = nDiscountRate * nDailyDiscount;
            nDiscountRate = nDiscountRate.div(100 ether);
        }

        return nDiscountRate.sub(100 ether);
    }

    function onCreate(uint256 _totalTokens) internal override {}

    /**
     * @dev Owner function to pay dividends to all token holders
     * @notice Invocado para pagar dividendos para os token holders.
     * Antes de ser chamado, é necessário chamar increaseAllowance() com no minimo o valor da próxima parcela
     */
    function payDividends() public onlyOwner {
        require(bInitialized, "Contract isn't initialized");
        require(!bCompletedPayment, "Dividends payment is already completed");

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // get the amount needed to pay
        uint256 nPaymentValue = PERIOD_VALUES[nCurrentSnapshotId];

        // make sure we are allowed to transfer the total payment value
        require(
            nPaymentValue <= nAllowance,
            "Not enough allowance to pay dividends"
        );

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), nPaymentValue);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == PERIOD_VALUES.length) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev
     * @notice Invoca payDividends _count numero de vezes
     */
    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends up to 16 times for the calling user
     * @notice Saca até 16 dividendos para o endereço invocando a função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws only 1 dividend for the calling user
     * @notice Saca apenas 1 dividendo para o endereço invocando a função
     */
    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws only 1 dividend for the specified user
     * @notice Saca apenas 1 dividendo para o endereço especificado
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    /**
     * @dev Returns the value of the next payment
     * @notice Retorna o valor do próximo pagamento
     */
    function getNextPaymentValue() public view returns (uint256) {
        if (bCompletedPayment) {
            return 0;
        }

        return PERIOD_VALUES[nCurrentSnapshotId];
    }

    /**
     * @dev
     * @notice Retorna qual o saldo de dividendos do investidor na parcela especificada
     */
    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // get value from index
            uint256 nPaymentValue = PERIOD_VALUES[_nPaymentIndex - 1];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     * @notice Retorna qual o saldo total de dividendos do investidor especificado.
     * Note que o limite de parcelas que esse método calcula é 16, se houverem mais dividendos pendentes o valor estará incompleto.
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        require(bInitialized, "Contract isn't initialized");

        // read the last payment
        uint256 nLastUserPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // get value from index
            uint256 nPaymentValue = PERIOD_VALUES[nLastUserPayment];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Returns the total value for the contract
     * @notice Retorna o valor que será pago ao contrato
     */
    function getTotalValue() public view returns (uint256) {
        return nTotalValue;
    }

    /**
     * @dev Returns the discounted value
     * @notice Retorna o valor descontado
     */
    function getTotalDiscountedValue() public view returns (uint256) {
        return nTotalDiscountedValue;
    }

    /**
     * @dev Returns the discounted value
     * @notice Retorna o valor total menos o descontado
     */
    function getTotalInterestValue() public view returns (uint256) {
        return nTotalValue.sub(nTotalDiscountedValue);
    }

    /**
     * @dev
     * @notice Retorna true se a função initialize foi executada todas as vezes necessárias
     */
    function getInitialized() public view returns (bool) {
        return bInitialized;
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total amount of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the value to pay (0 indexed)
     * @notice Retorna a valor de pagamento da parcela especificada
     */
    function getPaymentValue(uint256 _nIndex) public view returns (uint256) {
        return PERIOD_VALUES[_nIndex];
    }

    /**
     * @dev Gets the period date to pay
     * @notice Retorna a data do periodo
     */
    function getPeriodDate(uint256 _nIndex) public view returns (uint256) {
        return PERIOD_DATES[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna o ultimo pagamento feito ao investidor especificado
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Returns the total amount of payments needed to finish this contract
     * @notice Retorna a quantidade de parcelas
     */
    function getPaymentCount() public view returns (uint256) {
        return PERIOD_VALUES.length;
    }

    /**
     * @dev Gets total interest based on all payments
     * @notice Retorna a porcentagem de interesse de todos os pagamentos
     */
    function getTotalInterest() public view returns (uint256) {
        return nTotalInterest;
    }

    /**
     * @dev Gets current interest
     * @notice Retorna a porcentagem de interesse gerada até agora
     */
    function getCurrentLinearInterest() public view returns (uint256) {
        return getLinearInterest(block.timestamp);
    }

    /**
     * @dev Gets current percent based in period
     * @notice Retorna a porcentagem de interesse gerada até a data especificada
     */
    function getLinearInterest(uint256 _nPaymentDate)
        public
        view
        returns (uint256)
    {
        if (_nPaymentDate < DATE_INTEREST_START) {
            return 0;
        }

        uint256 nInterest = 0;

        // loop all dates
        for (uint8 i = 0; i < PERIOD_DATES.length; i++) {
            uint256 nPeriodInterest = arrInterests[i];
            uint256 nPeriodDate = PERIOD_DATES[i];

            if (_nPaymentDate >= nPeriodDate) {
                // if after the payment date, all interest is already generated
                nInterest += nPeriodInterest;
            } else {
                // calculate the day difference
                uint256 nTotalDays = nPeriodDate.sub(DATE_INTEREST_START);
                uint256 nCurrentDays = nTotalDays.sub(
                    nPeriodDate.sub(_nPaymentDate)
                );
                uint256 nDifInterest = LiqiMathLib.mulDiv(
                    nCurrentDays.mul(1 ether),
                    nPeriodInterest.mul(1 ether),
                    nTotalDays.mul(1 ether)
                );
                nInterest += nDifInterest.div(1 ether);
            }
        }

        return nInterest;
    }

    /**
     * @dev Gets the total amount of interest paid so far
     * @notice Retorna a porcentagem de interesse paga até agora
     */
    function getPaidInterest() public view returns (uint256) {
        if (bCompletedPayment) {
            return nTotalInterest;
        }

        return getInterest(nCurrentSnapshotId);
    }

    /**
     * @dev Gets the total amount of interest up to the specified index
     * @notice Retorna a porcentagem de interesse paga até o índice especificado
     */
    function getInterest(uint256 _nPaymentIndex) public view returns (uint256) {
        uint256 nInterest = 0;

        // loop all dates
        uint256 nLast = Math.min(_nPaymentIndex, PERIOD_VALUES.length);
        for (uint8 i = 0; i < nLast; i++) {
            uint256 nPeriodInterest = arrInterests[i];

            nInterest = nInterest.add(nPeriodInterest);
        }

        return nInterest;
    }

    /**
     * @dev Gets the amount of interest the specified period pays
     * @notice Retorna a porcentagem de interesse que o periodo especificado paga
     */
    function getPeriodInterest(uint256 _nPeriod) public view returns (uint256) {
        if (_nPeriod >= arrInterests.length) {
            return 0;
        }

        return arrInterests[_nPeriod];
    }

    /**
     * @dev Returns the current token value
     * @notice Retorna o valor do token linear até agora
     */
    function getCurrentLinearTokenValue() public view returns (uint256) {
        return getLinearTokenValue(block.timestamp);
    }

    /**
     * @dev Gets current token value based in period
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getLinearTokenValue(uint256 _nPaymentDate)
        public
        view
        returns (uint256)
    {
        if (_nPaymentDate <= DATE_INTEREST_START) {
            return TOKEN_BASE_RATE;
        }

        uint256 nTokenValue = 0;

        // loop all dates
        for (uint8 i = 0; i < PERIOD_DATES.length; i++) {
            uint256 nPeriodInterest = arrInterests[i];
            uint256 nPeriodDate = PERIOD_DATES[i];

            uint256 nInterest = 0;

            if (_nPaymentDate >= nPeriodDate) {
                // if after the payment date, all interest is already generated
                nInterest = nPeriodInterest;
            } else {
                // calculate the day difference
                uint256 nTotalDays = nPeriodDate.sub(DATE_INTEREST_START);
                uint256 nCurrentDays = nTotalDays.sub(
                    nPeriodDate.sub(_nPaymentDate)
                );
                uint256 nDifInterest = LiqiMathLib.mulDiv(
                    nCurrentDays.mul(1 ether),
                    nPeriodInterest.mul(1 ether),
                    nTotalDays.mul(1 ether)
                );

                nInterest = nDifInterest.div(1 ether);
            }

            uint256 nPeriodInterestTotalPC = LiqiMathLib.mulDiv(
                nInterest,
                100 ether,
                nTotalInterest
            );

            uint256 nTokenLinear = LiqiMathLib.mulDiv(
                TOKEN_BASE_RATE,
                nPeriodInterestTotalPC,
                100 ether
            );
            nTokenValue = nTokenValue.add(nTokenLinear);
        }

        return TOKEN_BASE_RATE.sub(nTokenValue);
    }

    /**
     * @dev Gets the value of the token up to the current payment index
     * @notice Retorna o valor do token até o ultimo pagamento efetuado pelo emissor
     */
    function getCurrentTokenValue() public view returns (uint256) {
        return getTokenValue(nCurrentSnapshotId);
    }

    /**
     * @dev Gets the value of the token up to the specified payment index
     * @notice Retorna o valor do token até o pagamento especificado
     */
    function getTokenValue(uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        if (_nPaymentIndex == 0) {
            return TOKEN_BASE_RATE;
        } else if (_nPaymentIndex >= PERIOD_VALUES.length) {
            return 0;
        }

        uint256 nTokenValue = 0;

        for (uint8 i = 0; i < _nPaymentIndex; i++) {
            uint256 nInterest = arrInterests[i];

            uint256 nPeriodInterestTotalPC = LiqiMathLib.mulDiv(
                nInterest,
                100 ether,
                nTotalInterest
            );

            uint256 nTokenLinear = LiqiMathLib.mulDiv(
                TOKEN_BASE_RATE,
                nPeriodInterestTotalPC,
                100 ether
            );
            nTokenValue = nTokenValue.add(nTokenLinear);
        }

        return TOKEN_BASE_RATE.sub(nTokenValue);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev DividendsERC20 handles the payment of dividends by using any IERC20 compatible token
 *
 * PAYMENT
 *  Emitter
 *  - Emitter calls increaseAllowance on the dividends token, with the amount he wants to pay in dividends to the holders
 *  - Emitter calls payDividends with the amount he wants to pay in dividends to the holders
 *
 * @notice Módulo para dividendos genérico, paga parcelas de qualquer valor utilizando um token ERC20
 *
 */
contract DividendsERC20 is TokenTransfer {
    using SafeMath for uint256;

    // Index of the current token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend total amount
    mapping(uint256 => uint256) private mapERCPayment;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Constructor for DividendsERC20
     * @notice Construtor para DividendosERC20
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de pagamento de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna o total de pagamentos de dividendos feitos à este contrato
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets payment data for the specified index
     * @notice Retorna dados sobre o pagamento no índice especificado.
     * nERCPayment: Valor pago no token ERC20 de dividendos.
     * nDate: Data em formato unix do pagamento desse dividendo
     */
    function getPayment(uint256 _nIndex)
        public
        view
        returns (uint256 nERCPayment, uint256 nDate)
    {
        nERCPayment = mapERCPayment[_nIndex];
        nDate = mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment cashed out by the specified _investor
     * @notice Retorna o ID do último saque feito para essa carteira
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Function made for owner to transfer tokens to contract for dividend payment
     * @notice Faz um pagamento de dividendos ao contrato, no valor especificado
     */
    function payDividends(uint256 _amount) public onlyOwner {
        // make sure the amount is not zero
        require(_amount > 0, "Amount cant be zero");

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // make sure we at least have the balance added
        require(_amount <= nAllowance, "Not enough balance to pay dividends");

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), _amount);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // register the balance in ether that entered
        mapERCPayment[nCurrentSnapshotId] = _amount;

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev Withdraws dividends (up to 16 times in the same call, if available)
     * @notice Faz o saque de até 16 dividendos para a carteira que chama essa função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();
        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividend() public {
        address aSender = _msgSender();
        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws only 1 dividend for the specified user
     * @notice Saca apenas 1 dividendo para o endereço especificado
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    function _recursiveGetTotalDividends(
        address _aInvestor,
        uint256 _nPaymentIndex
    ) internal view returns (uint256) {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(_nPaymentIndex);

            // get the total token amount for this payment
            uint256 nTotalTokens = mapERCPayment[_nPaymentIndex];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nTotalTokens,
                nTokenSupply
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of available dividends
     * to be cashed out for the specified _investor
     * @notice Retorna o total de dividendos que esse endereço pode sacar
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(_recursiveGetTotalDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the ERC20 token
     * Be aware that this function will pay dividends
     * even if the tokens are currently in possession of the offer
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        // read the last payment
        uint256 nLastPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // get the total token amount for this payment
            uint256 nTotalTokens = mapERCPayment[nNextUserPayment];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nTotalTokens,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev DividendsEther handles the payment of dividends in Ether
 * @notice Módulo para dividendos genérico, paga parcelas de qualquer valor utilizando Ether.
 * Qualquer valor enviado para contrato acima do valor minimo será registrado como dividendo, e poderá ser sacado por qualquer token holder.
 */
contract DividendsEther is TokenTransfer {
    /**
     * @dev Minimum amount the contract is allowed to receive, in Ethers
     * @notice Quantidade mínima que o contrato pode receber em Ether
     */
    uint256 public constant MIN_ETHER_DIVIDENDS = 1 ether;

    uint256 private nSnapshotId;

    mapping(address => uint256) private mapLastPaymentSnapshot;
    mapping(uint256 => uint256) private mapEtherPayment;

    /**
     * @dev Dividends Ether
     * @notice Construtor para DividendsEther
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {}

    /**
     * @notice Faz o saque de 1 dividendo para o endereço que invoca essa função
     */
    function withdrawDividend() public {
        // use payable so we can send the dividends
        address payable aSender = _msgSender();

        // read the last payment
        uint256 nLastPayment = mapLastPaymentSnapshot[aSender];

        // make sure we have a next payment
        require(nLastPayment < nSnapshotId, "No new withdrawal");

        // add 1 to get the next payment
        uint256 nNextPayment = nLastPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[aSender] = nNextPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(aSender, nNextPayment);

        // if there's balance, pay dividends
        if (nTokenBalance == 0) {
            // get the total eth balance for this payment
            uint256 nTotalEther = mapEtherPayment[nNextPayment];

            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(nNextPayment);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nTotalEther,
                nTokenSuppy
            );

            // send the ether value to the user
            aSender.transfer(nToReceive);
        }
        // console.log("Last Payment: %s", nLastPayment);
        // console.log("Next Payment: %s", nNextPayment);
        // console.log("Latest Payment: %s", nSnapshotId);
        // console.log("-------");
        // console.log("Total Supply: %s", nTokenSuppy);
        // console.log("Total Ether: %s", nTotalEther);
        // console.log("To Receive: %s", nToReceive);
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        if (msg.value < MIN_ETHER_DIVIDENDS) {
            revert();
        }

        // snapshot the tokens at the moment the ether enters
        nSnapshotId = _snapshot();
        // register the balance in ether that entered
        mapEtherPayment[nSnapshotId] = msg.value;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/BokkyPooBahsDateTimeLibrary.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev DividendsFixedAmortizationERC20
 * @notice Modelo de amortização fixa.
 */
contract DividendsFixedAmortizationERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev The price of the token
     * @notice O valor base de venda do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;

    /**
     * @dev The value of amortization for each period
     * @notice Valor amortizado em cada parcela, em %
     */
    uint256[] public PERIOD_AMORTIZATIONS = [
        0.00000000000000000 * 1 ether,
        0.00000000000000000 * 1 ether,
        0.00000000000000000 * 1 ether,
        0.00000000000000000 * 1 ether,
        0.00000000000000000 * 1 ether,
        0.00000000000000000 * 1 ether,
        0.23895378866673800 * 1 ether,
        0.24161830905694500 * 1 ether,
        0.24431906644393600 * 1 ether,
        0.24705670087784600 * 1 ether,
        0.24983186718019700 * 1 ether,
        0.25264523537307000 * 1 ether,
        0.25549749112333000 * 1 ether,
        0.25838933620255700 * 1 ether,
        0.26132148896331000 * 1 ether,
        0.26429468483242600 * 1 ether,
        0.26730967682204400 * 1 ether,
        0.27036723605913200 * 1 ether,
        1.05635384154210000 * 1 ether,
        1.07695714141704000 * 1 ether,
        1.09819097069802000 * 1 ether,
        1.12008388283328000 * 1 ether,
        1.14266618031847000 * 1 ether,
        1.16597005072170000 * 1 ether,
        1.19002971560380000 * 1 ether,
        1.21488159378298000 * 1 ether,
        1.24056448058198000 * 1 ether,
        1.26711974491363000 * 1 ether,
        1.29459154631054000 * 1 ether,
        1.32302707429418000 * 1 ether,
        2.25549352484844000 * 1 ether,
        2.32769536284686000 * 1 ether,
        2.40398426668549000 * 1 ether,
        2.48471423202313000 * 1 ether,
        2.57028134806588000 * 1 ether,
        2.66113024601454000 * 1 ether,
        2.75776177041047000 * 1 ether,
        2.86074215277641000 * 1 ether,
        2.97071404236315000 * 1 ether,
        3.08840984792722000 * 1 ether,
        3.21466797585396000 * 1 ether,
        3.35045272572048000 * 1 ether,
        4.75815971467191000 * 1 ether,
        5.03950815392482000 * 1 ether,
        5.35330652979335000 * 1 ether,
        5.70549830105151000 * 1 ether,
        6.10357275087688000 * 1 ether,
        6.55710250124111000 * 1 ether,
        7.07852207636936000 * 1 ether,
        7.68428381804897000 * 1 ether,
        8.39662327999144000 * 1 ether,
        9.24634514262560000 * 1 ether,
        10.27739128132860000 * 1 ether,
        11.55467977111910000 * 1 ether,
        16.32541211388320000 * 1 ether,
        19.68101471872620000 * 1 ether,
        24.71759362846210000 * 1 ether,
        33.11994524464220000 * 1 ether,
        49.95395807617220000 * 1 ether,
        100.00000000000000000 * 1 ether
    ];

    /**
     * @dev The daily discount rate, in %
     * @notice Valor de juros mensal, em %
     */
    uint256 public constant MONTHLY_INTEREST_RATE = 0.8734593823552 * 1 ether;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply
    uint256 private nTotalInput;

    uint256 private nTotalPayment;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastUserPayment;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;
    // Map of snapshot index to dividend value
    mapping(uint256 => uint256) private mapPaymentValue;

    // Total amount of interest
    uint256 private nTotalInterest;

    // Array with interest for each payment index
    uint256[] private arrInterests;

    // State of contract initialization
    bool private bInitialized;

    /**
     * @dev DividendsFixedAmortizationERC20
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");

        // calculate total input token amount to payoff all dividends
        nTotalInput = _totalTokens.mul(TOKEN_BASE_RATE);
    }

    /**
     * @dev
     * @notice Executada até o contrato ser inicializado,
     * faz a emissão dos tokens de acordo com as constantes definidas no contrato e
     * calcula os dados a serem utilizados por funcões de referência
     */
    function initialize() public {
        require(!bInitialized, "Contract is already initialized");
        bInitialized = true;

        uint256 nCurrentTotalDebit = nTotalInput;

        for (uint256 i = 0; i < PERIOD_AMORTIZATIONS.length; i++) {
            uint256 nLastDebt = nCurrentTotalDebit;

            uint256 nInterest = LiqiMathLib.mulDiv(
                MONTHLY_INTEREST_RATE,
                nCurrentTotalDebit,
                100 ether
            );

            uint256 nAmortizationPc = PERIOD_AMORTIZATIONS[i];

            // calculate how much the user needs to pay from percentage
            if (nAmortizationPc == 0) {
                mapPaymentValue[i] = 0;

                nCurrentTotalDebit = nCurrentTotalDebit.add(nInterest);
            } else {
                uint256 nAmortizationValue = LiqiMathLib.mulDiv(
                    nAmortizationPc,
                    nLastDebt,
                    100 ether
                );

                // remove amortization from total debit
                nCurrentTotalDebit = nCurrentTotalDebit.sub(nAmortizationValue);

                // add interest to payment
                uint256 nPaymentValue = nAmortizationValue.add(nInterest);
                nTotalPayment = nTotalPayment.add(nPaymentValue);

                mapPaymentValue[i] = nPaymentValue;
            }
        }

        uint256 nTotalInterestPC = LiqiMathLib.mulDiv(
            nTotalPayment,
            100 ether,
            nTotalInput
        );
        nTotalInterestPC = nTotalInterestPC.sub(100 ether);

        // save interest values
        for (uint256 i = 0; i < PERIOD_AMORTIZATIONS.length; i++) {
            uint256 nPaymentValue = mapPaymentValue[i];

            uint256 nTotalPeriodInterest = LiqiMathLib.mulDiv(
                nPaymentValue,
                100 ether,
                nTotalPayment
            );

            uint256 nPeriodInterest = LiqiMathLib.mulDiv(
                nTotalPeriodInterest,
                nTotalInterestPC,
                100 ether
            );

            arrInterests.push(nPeriodInterest);
            nTotalInterest = nTotalInterest.add(nPeriodInterest);
        }
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     * @notice Função do dono para pagar dividendos ã todos os token holders
     */
    function payDividends() public onlyOwner {
        require(bInitialized, "Contract isn't initialized");
        require(!bCompletedPayment, "Dividends payment is already completed");

        uint256 nPaymentValue = mapPaymentValue[nCurrentSnapshotId];

        // calculate how much the user needs to pay from percentage
        if (nPaymentValue != 0) {
            // grab our current allowance
            uint256 nAllowance = dividendsToken.allowance(
                _msgSender(),
                address(this)
            );

            // make sure we are allowed to transfer the total payment value
            require(
                nPaymentValue <= nAllowance,
                "Not enough allowance to pay dividends"
            );

            // increase the total amount paid
            nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

            // transfer the tokens from the sender to the contract
            dividendsToken.transferFrom(
                _msgSender(),
                address(this),
                nPaymentValue
            );
        }

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == PERIOD_AMORTIZATIONS.length) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev Invokes the payDividends function multiple times
     * @notice Invoca a função payDividends count vezes
     */
    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends (up to 16 times in the same call, if available)
     * @notice Faz o saque de até 16 dividendos para a carteira que chama essa função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    /**
     * @dev Returns the value of the next payment
     * @notice Retorna o valor do próximo pagamento
     */
    function getNextPaymentValue() public view returns (uint256) {
        if (bCompletedPayment) {
            return 0;
        }

        return mapPaymentValue[nCurrentSnapshotId];
    }

    /**
     * @dev
     * @notice Retorna qual o saldo de dividendos do investidor na parcela especificada
     */
    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // get value from index
            uint256 nPaymentValue = mapPaymentValue[_nPaymentIndex - 1];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     * @notice Retorna qual o saldo total de dividendos do investidor especificado.
     * Note que o limite de parcelas que esse método calcula é 16, se houverem mais dividendos pendentes o valor estará incompleto.
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastUserPayment[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        require(bInitialized, "Contract isn't initialized");

        // read the last payment
        uint256 nLastUserPayment = mapLastUserPayment[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastUserPayment[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // get value from index
            uint256 nPaymentValue = mapPaymentValue[nLastUserPayment];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Gets the amortization percentage for the specified period
     * @notice Retorna a porcentagem de amortização do período especificado
     */
    function getAmortizationValue(uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        return PERIOD_AMORTIZATIONS[_nPaymentIndex];
    }

    /**
     * @dev Gets the MONTHLY_INTEREST_RATE constant value
     * @notice Retorna o valor da constante MONTHLY_INTEREST_RATE
     */
    function getMonthlyInterestRate() public pure returns (uint256) {
        return MONTHLY_INTEREST_RATE;
    }

    /**
     * @dev Gets the TOKEN_BASE_RATE constant value
     * @notice Retorna o valor da constante TOKEN_BASE_RATE (valor base do token)
     */
    function getTokenBaseRate() public pure returns (uint256) {
        return TOKEN_BASE_RATE;
    }

    /**
     * @dev Gets total interest based on all payments
     * @notice Retorna a porcentagem de interesse de todos os pagamentos
     */
    function getTotalInterest() public view returns (uint256) {
        return nTotalInterest;
    }

    /**
     * @dev Gets the total amount of interest paid so far
     * @notice Retorna a porcentagem de interesse paga até agora
     */
    function getPaidInterest() public view returns (uint256) {
        if (bCompletedPayment) {
            return nTotalInterest;
        }

        return getInterest(nCurrentSnapshotId);
    }

    /**
     * @dev Gets the total amount of interest up to the specified index
     * @notice Retorna a porcentagem de interesse paga até o índice especificado
     */
    function getInterest(uint256 _nPaymentIndex) public view returns (uint256) {
        uint256 nInterest = 0;

        // loop all payment interests
        uint256 nLast = Math.min(_nPaymentIndex, PERIOD_AMORTIZATIONS.length);
        for (uint8 i = 0; i < nLast; i++) {
            uint256 nPeriodInterest = arrInterests[i];

            nInterest = nInterest.add(nPeriodInterest);
        }

        return nInterest;
    }

    /**
     * @dev Gets the amount of interest the specified period pays
     * @notice Retorna a porcentagem de interesse que o periodo especificado paga
     */
    function getPeriodInterest(uint256 _nPeriod) public view returns (uint256) {
        if (_nPeriod >= arrInterests.length) {
            return 0;
        }

        return arrInterests[_nPeriod];
    }

    /**
     * @dev Gets the value of the token up to the current payment index
     * @notice Retorna o valor do token até o ultimo pagamento efetuado pelo emissor
     */
    function getCurrentTokenValue() public view returns (uint256) {
        return getTokenValue(nCurrentSnapshotId);
    }

    /**
     * @dev Gets the value of the token up to the specified payment index
     * @notice Retorna o valor do token até o pagamento especificado
     */
    function getTokenValue(uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        if (_nPaymentIndex == 0) {
            return TOKEN_BASE_RATE;
        } else if (_nPaymentIndex >= PERIOD_AMORTIZATIONS.length) {
            return 0;
        }

        uint256 nTokenValue = 0;

        for (uint8 i = 0; i < _nPaymentIndex; i++) {
            uint256 nInterest = arrInterests[i];

            uint256 nPeriodInterestTotalPC = LiqiMathLib.mulDiv(
                nInterest,
                100 ether,
                nTotalInterest
            );

            uint256 nTokenLinear = LiqiMathLib.mulDiv(
                TOKEN_BASE_RATE,
                nPeriodInterestTotalPC,
                100 ether
            );
            nTokenValue = nTokenValue.add(nTokenLinear);
        }

        return TOKEN_BASE_RATE.sub(nTokenValue);
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     * @notice Retorna quanto o emissor precisa pagar até o fim do contrato
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalPayment;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna o ultimo pagamento feito ao investidor especificado
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastUserPayment[_aInvestor];
    }

    /**
     * @dev
     * @notice Retorna true se a função initialize foi executada todas as vezes necessárias
     */
    function getInitialized() public view returns (bool) {
        return bInitialized;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev ExternalDividends handles the payment of an undetermined number of external dividends
 * @notice ExternalDividends é um token customizado onde os dividendos são pagos de forma externa, sem nenhum valor específico.
 */
contract ExternalDividends is TokenTransfer {
    using SafeMath for uint256;

    // Index of the current token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;

    // Map of snapshot index to dividend total amount
    mapping(uint256 => uint256) private mapERCPayment;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Constructor for DividendsERC20
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {}

    /**
     * @dev Gets the total count of payments
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets payment data for the specified index
     */
    function getPayment(uint256 _nIndex)
        public
        view
        returns (uint256 nERCPayment, uint256 nDate)
    {
        nERCPayment = mapERCPayment[_nIndex];
        nDate = mapPaymentDate[_nIndex];
    }

    function setPaidDividendsMultiple(uint256 _count, uint256 _amount)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _count; i++) {
            setPaidDividends(_amount);
        }
    }

    /**
     * @dev Function made for owner to transfer tokens to contract for dividend payment
     */
    function setPaidDividends(uint256 _amount) public onlyOwner {
        // make sure the amount is not zero
        require(_amount > 0, "Amount cant be zero");

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // register the balance in ether that entered
        mapERCPayment[nCurrentSnapshotId] = _amount;

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(_nPaymentIndex);

            // get the total token amount for this payment
            uint256 nTotalTokens = mapERCPayment[_nPaymentIndex];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nTotalTokens,
                nTokenSupply
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of available dividends
     * to be cashed out for the specified _investor
     */
    function getDividendsRange(
        address _investor,
        uint256 _startIndex,
        uint256 _endIndex
    ) public view returns (uint256) {
        // start total balance 0
        uint256 nBalance = 0;

        // loop
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            32,
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = 1; i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev ExternalFixedDiscountDividends
 */
contract ExternalFixedDiscountDividends is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 4102455600; // Unix Timestamp

    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 4133991600; // Unix Timestamp

    /**
     * @dev
     * @notice Valor do token com disconto
     */
    uint256 public constant TOKEN_DISCOUNTED_RATE = 2147;

    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2499;

    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 6;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;

    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Fixed Dividends
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // calculate total input token amount to payoff all dividends
        nTotalInputInterest = totalSupply().mul(TOKEN_BASE_RATE);

        // calculate how much each payment should be
        nPaymentValue = nTotalInputInterest.div(TOTAL_PERIODS);
    }

    function setPaidDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            setPaidDividends();
        }
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     */
    function setPaidDividends() public onlyOwner {
        require(!bCompletedPayment, "Dividends payment is already completed");

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // snapshot the tokens at the moment the payment is done
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of available dividends
     * to be cashed out for the specified _investor
     */
    function getDividendsRange(
        address _investor,
        uint256 _startIndex,
        uint256 _endIndex
    ) public view returns (uint256) {
        // start total balance 0
        uint256 nBalance = 0;

        // loop
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Gets the total count of payments
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets current interest
     */
    function getCurrentInterest() public view returns (uint256) {
        return getPercentByTime(block.timestamp);
    }

    /**
     * @dev Returns the DISCOUNT_RATE constant
     */
    function getDiscountRate() public pure returns (uint256) {
        return TOKEN_DISCOUNTED_RATE;
    }

    /**
     * @dev Returns the payment value needed to execute setPaidDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current percent based in period
     */
    function getPercentByTime(uint256 _nPaymentDate)
        public
        pure
        returns (uint256)
    {
        uint256 nTotalPercent = LiqiMathLib.mulDiv(
            TOKEN_BASE_RATE.mul(100),
            100 ether,
            TOKEN_DISCOUNTED_RATE.mul(100)
        );

        nTotalPercent = nTotalPercent.sub(100 ether);

        if (_nPaymentDate >= DATE_INTEREST_END) {
            return nTotalPercent;
        } else if (_nPaymentDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nPaymentDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays.mul(1 ether),
            nTotalPercent.mul(1 ether),
            nTotalDays.mul(1 ether)
        );

        nTotalPercent = nTotalPercent.mul(1 ether);

        uint256 nFinalValue = nTotalPercent.sub(nDiffPercent);

        return nFinalValue.div(1 ether);
    }

    function getCurrentTokenValue() public view returns (uint256) {
        return getLinearTokenValue(block.timestamp);
    }

    /**
     * @dev Gets current token value based in period
     */
    function getLinearTokenValue(uint256 _nDate) public pure returns (uint256) {
        if (_nDate <= DATE_INTEREST_START) {
            return TOKEN_DISCOUNTED_RATE;
        }

        uint256 nInterest = TOKEN_BASE_RATE.sub(TOKEN_DISCOUNTED_RATE);

        if (_nDate >= DATE_INTEREST_END) {
            return TOKEN_BASE_RATE;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            nInterest,
            nTotalDays
        );

        nDiffPercent = nInterest.sub(nDiffPercent);

        return TOKEN_DISCOUNTED_RATE.add(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev ExternalFixedDividends handles the payment of a fixed amount of dividends partially
 * @notice ExternalFixedDividends é um token customizado onde os dividendos são pagos de forma externa, com valor pré-fixado.
 */
contract ExternalFixedDividends is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 4102455600; // Unix Timestamp
    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 4133991600; // Unix Timestamp

    /**
     * @dev The % of interest generated in the entire interest period
     * @notice A % de interesse gerado sob todo o periodo
     */
    uint256 public constant INTEREST_RATE = 37.532 * 1 ether;

    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 5000;
    
    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 24;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;

    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Fixed Dividends
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // calculate the total supply of tokens with interest
        uint256 nInterestTokenSupply = LiqiMathLib.mulDiv(
            totalSupply(),
            INTEREST_RATE.add(100 ether),
            100 ether
        );

        // calculate total input token amount to payoff all dividends
        nTotalInputInterest = nInterestTokenSupply.mul(TOKEN_BASE_RATE);

        // calculate how much each payment should be
        nPaymentValue = nTotalInputInterest.div(TOTAL_PERIODS);
    }

    function setPaidDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            setPaidDividends();
        }
    }

    /**
     * @dev Owner function to flag dividends were paid to all token holders
     */
    function setPaidDividends() public onlyOwner {
        require(!bCompletedPayment, "Dividends payment is already completed");

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // snapshot the tokens at the moment the Ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of available dividends
     * to be cashed out for the specified _investor
     */
    function getDividendsRange(
        address _investor,
        uint256 _startIndex,
        uint256 _endIndex
    ) public view returns (uint256) {
        // start total balance 0
        uint256 nBalance = 0;

        // loop
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Gets the total count of payments
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets current interest
     */
    function getCurrentInterest() public view returns (uint256) {
        return getPercentByTime(block.timestamp);
    }

    /**
     * @dev Returns the INTEREST_RATE constant
     */
    function getInterestRate() public pure returns (uint256) {
        return INTEREST_RATE;
    }

    /**
     * @dev Returns the minimum payment value needed to execute payDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current percent based in period
     */
    function getPercentByTime(uint256 _nPaymentDate)
        public
        pure
        returns (uint256)
    {
        if (_nPaymentDate >= DATE_INTEREST_END) {
            return INTEREST_RATE;
        } else if (_nPaymentDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nPaymentDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays.mul(1 ether),
            INTEREST_RATE.mul(1 ether),
            nTotalDays.mul(1 ether)
        );

        uint256 nInterestRate = INTEREST_RATE.mul(1 ether);

        uint256 nFinalValue = nInterestRate.sub(nDiffPercent);

        return nFinalValue.div(1 ether);
    }

    function getCurrentTokenValue() public view returns (uint256) {
        return getLinearTokenValue(block.timestamp);
    }

    /**
     * @dev Gets current token value based in period
     */
    function getLinearTokenValue(uint256 _nDate) public pure returns (uint256) {
        if (_nDate <= DATE_INTEREST_START) {
            return TOKEN_BASE_RATE;
        }

        uint256 nInterest = LiqiMathLib.mulDiv(
            TOKEN_BASE_RATE,
            INTEREST_RATE,
            100 ether
        );

        if (_nDate >= DATE_INTEREST_END) {
            return nInterest.add(TOKEN_BASE_RATE);
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            nInterest,
            nTotalDays
        );

        nDiffPercent = nInterest.sub(nDiffPercent);

        return TOKEN_BASE_RATE.add(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev ExternalFixedDividendsPMT
 */
contract ExternalFixedDividendsPMT is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 0; // Unix Timestamp
    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 1000; // Unix Timestamp

    /**
     * @dev % of the remaining paid each month
     * @notice Porcentagem do restante que será paga todo mês
     */
    uint256 public constant MONTHLY_INTEREST_RATE = 1.22 * 1 ether;
    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;
    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 25;
    /**
     * @dev The periods that are already prepaid prior to this contract
     * @notice A quantidade de periodos que já foram pagos antes da emissão deste contrato
     */
    uint256 public constant PRE_PAID_PERIODS = 2;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;
    // The total amount of interest paid over the entire period
    uint256 private nTotalInterest;

    // A flag indicating if initialize() has been invoked
    bool private bInitialized;

    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Dividends based on annual payment (PMT) formula
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure all our periods aren't prepaid
        require(
            TOTAL_PERIODS - 1 > PRE_PAID_PERIODS,
            "Need at least 1 period payment"
        );
    }

    /**
     * @dev Ready the contract for dividend payments
     */
    function initialize() public {
        require(!bInitialized, "Contract is already initialized");
        bInitialized = true;

        // calculate how many input tokens we have
        uint256 nTotalValue = totalSupply().mul(TOKEN_BASE_RATE);

        // calculate the payment
        nPaymentValue = PMT(
            MONTHLY_INTEREST_RATE,
            TOTAL_PERIODS,
            nTotalValue,
            0,
            0
        );

        // round the payment value
        nPaymentValue = nPaymentValue.div(0.01 ether);
        nPaymentValue = nPaymentValue.mul(1 ether);

        // get total periods to pay
        uint256 nPeriodsToPay = TOTAL_PERIODS.sub(PRE_PAID_PERIODS);

        // calculate the total amount the issuer has to pay by the end of the contract
        nTotalInputInterest = nPaymentValue.mul(nPeriodsToPay);

        // calculate the total interest
        uint256 nTotalInc = nTotalInputInterest.mul(1 ether);
        nTotalInterest = nTotalInc.div(nTotalValue);
        nTotalInterest = nTotalInterest.mul(10);
    }

    /**
     * @dev Annual Payment
     */
    function PMT(
        uint256 ir,
        uint256 np,
        uint256 pv,
        uint256 fv,
        uint256 tp
    ) public pure returns (uint256) {
        /*
         * ir   - interest rate per month
         * np   - number of periods (months)
         * pv   - present value
         * fv   - future value
         * type - when the payments are due:
         *        0: end of the period, e.g. end of month (default)
         *        1: beginning of period
         */
        ir = ir.div(100);
        pv = pv.div(100);

        if (ir == 0) {
            // TODO: untested
            return -(pv + fv) / np;
        }

        uint256 nPvif = (1 ether + ir);

        //pmt = (-ir * (pv * pvif + fv)) / (pvif - 1);
        uint256 originalPVIF = nPvif;
        for (uint8 i = 1; i < np; i++) {
            nPvif = nPvif * originalPVIF;
            // TODO: this only works if the ir has only 1 digit
            nPvif = nPvif.div(1 ether);
        }

        uint256 nPvPviFv = pv.mul(nPvif.add(fv));
        uint256 topValue = ir.mul(nPvPviFv);
        uint256 botValue = (nPvif - 1 ether);

        uint256 pmt = topValue / botValue;

        if (tp == 1) {
            // TODO: untested
            pmt /= (1 ether + ir);
        }

        pmt /= 1 ether;

        return pmt;
    }

    function setPaidDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            setPaidDividends();
        }
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     */
    function setPaidDividends() public onlyOwner {
        require(bInitialized, "Contract is not initialized");
        require(!bCompletedPayment, "Dividends payment is already completed");

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS.sub(PRE_PAID_PERIODS)) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of available dividends
     * to be cashed out for the specified _investor
     */
    function getDividendsRange(
        address _investor,
        uint256 _startIndex,
        uint256 _endIndex
    ) public view returns (uint256) {
        // start total balance 0
        uint256 nBalance = 0;

        // loop
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Returns a flag indicating if the contract has been initialized
     */
    function getInitialized() public view returns (bool) {
        return bInitialized;
    }

    /**
     * @dev Gets the total count of payments
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Returns the MONTHLY_INTEREST_RATE constant
     */
    function getMonthlyInterestRate() public pure returns (uint256) {
        return MONTHLY_INTEREST_RATE;
    }

    function getTotalInterest() public view returns (uint256) {
        return nTotalInterest;
    }

    /**
     * @dev Returns the minimum payment value needed to execute payDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current token value based in the total payments
     */
    function getCurrentTokenValue() public view returns (uint256) {
        uint256 nTotalPeriods = TOTAL_PERIODS - PRE_PAID_PERIODS;
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentSnapshotId.mul(1 ether),
            TOKEN_BASE_RATE.mul(1 ether),
            nTotalPeriods
        );

        nDiffPercent = nDiffPercent.div(1 ether).div(1 ether);
        nDiffPercent = TOKEN_BASE_RATE.sub(nDiffPercent);

        return nDiffPercent;
    }

    /**
     * @dev Gets current percent % of total based in the total payments
     */
    function getCurrentPercentPaid() public view returns (uint256) {
        uint256 nTotalPeriods = TOTAL_PERIODS - PRE_PAID_PERIODS;
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentSnapshotId.mul(1 ether),
            nTotalInterest,
            nTotalPeriods
        );

        nDiffPercent = nDiffPercent.div(1 ether);
        return nDiffPercent;
    }

    /**
     * @dev Gets current token value based in period
     */
    function getLinearTokenValue(uint256 _nDate) public pure returns (uint256) {
        if (_nDate >= DATE_INTEREST_END) {
            return 0;
        } else if (_nDate <= DATE_INTEREST_START) {
            return TOKEN_BASE_RATE;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            TOKEN_BASE_RATE,
            nTotalDays
        );

        return nDiffPercent;
    }

    /**
     * @dev Gets current percent based in period
     */
    function getLinearPercentPaid(uint256 _nDate)
        public
        view
        returns (uint256)
    {
        if (_nDate >= DATE_INTEREST_END) {
            return nTotalInterest;
        } else if (_nDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            nTotalInterest,
            nTotalDays
        );

        return nTotalInterest.sub(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev FixedDiscountDividendsERC20
 * @notice
 */
contract FixedDiscountDividendsERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 4102455600; // Unix Timestamp
    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 4133991600; // Unix Timestamp

    /**
     * @dev
     * @notice Valor do token com disconto
     */
    uint256 public constant TOKEN_DISCOUNTED_RATE = 2147;
    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2499;

    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 6;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Fixed Dividends
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");

        // calculate total input token amount to payoff all dividends
        nTotalInputInterest = totalSupply().mul(TOKEN_BASE_RATE);

        // calculate how much each payment should be
        nPaymentValue = nTotalInputInterest.div(TOTAL_PERIODS);
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     */
    function payDividends() public onlyOwner {
        require(!bCompletedPayment, "Dividends payment is already completed");

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // make sure we are allowed to transfer the total payment value
        require(
            nPaymentValue <= nAllowance,
            "Not enough allowance to pay dividends"
        );

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), nPaymentValue);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends up to 16 times for the calling user
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for any specific user
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        // read the last payment
        uint256 nLastUserPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     * @notice Retorna quanto o emissor precisa pagar até o fim do contrato
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna o ultimo pagamento feito ao investidor especificado
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Returns the minimum payment value needed to execute payDividends
     * @notice Retorna o valor necessário para invocar payDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current interest
     * @notice Retorna a porcentagem de interesse gerada até agora
     */
    function getCurrentInterest() public view returns (uint256) {
        return getPercentByTime(block.timestamp);
    }

    /**
     * @dev Gets current percent based in period
     * @notice Retorna a porcentagem de interesse gerada até a data especificada
     */
    function getPercentByTime(uint256 _nPaymentDate)
        public
        pure
        returns (uint256)
    {
        uint256 nTotalPercent = LiqiMathLib.mulDiv(
            TOKEN_BASE_RATE.mul(100),
            100 ether,
            TOKEN_DISCOUNTED_RATE.mul(100)
        );

        nTotalPercent = nTotalPercent.sub(100 ether);

        if (_nPaymentDate >= DATE_INTEREST_END) {
            return nTotalPercent;
        } else if (_nPaymentDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nPaymentDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays.mul(1 ether),
            nTotalPercent.mul(1 ether),
            nTotalDays.mul(1 ether)
        );

        nTotalPercent = nTotalPercent.mul(1 ether);

        uint256 nFinalValue = nTotalPercent.sub(nDiffPercent);

        return nFinalValue.div(1 ether);
    }

    /**
     * @dev Returns the current token value
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getCurrentTokenValue() public view returns (uint256) {
        return getLinearTokenValue(block.timestamp);
    }

    /**
     * @dev Gets current token value based in period
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getLinearTokenValue(uint256 _nDate) public pure returns (uint256) {
        if (_nDate <= DATE_INTEREST_START) {
            return TOKEN_DISCOUNTED_RATE;
        }

        uint256 nInterest = TOKEN_BASE_RATE.sub(TOKEN_DISCOUNTED_RATE);

        if (_nDate >= DATE_INTEREST_END) {
            return TOKEN_BASE_RATE;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            nInterest,
            nTotalDays
        );

        nDiffPercent = nInterest.sub(nDiffPercent);

        return TOKEN_DISCOUNTED_RATE.add(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev FixedDividendsCreditERC20
 */
contract FixedDividendsCreditERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;

    /**
     * @dev The amount of each interest payment
     * @notice Um array com o valor de cada pagamento de interesse
     */
    uint256[] public PERIOD_VALUES = [
        70739.99 * 100 ether,
        21586.83 * 100 ether,
        8842.62 * 100 ether,
        15972.36 * 100 ether,
        8977.41 * 100 ether,
        35744.54 * 100 ether,
        61234.10 * 100 ether,
        38005.14 * 100 ether
    ];

    /**
     * @dev The discount for each period payment
     * @notice Um array com o valor de cada desconto
     */
    uint256[] public PERIOD_DISCOUNTS = [
        100 ether - 2.7934579093017 * 1 ether,
        100 ether - 3.70716072229092 * 1 ether,
        100 ether - 5.50888174769298 * 1 ether,
        100 ether - 6.39706065718524 * 1 ether,
        100 ether - 8.14845136409965 * 1 ether,
        100 ether - 9.81030615668181 * 1 ether,
        100 ether - 11.5535358979457 * 1 ether,
        100 ether - 12.3848974638534 * 1 ether
    ];

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    bool private bInitialized;

    uint256[] private arrInterests;
    uint256 private nTotalInterest;

    /**
     * @dev Fixed Dividends
     */
    constructor(
        address _issuer,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, 0, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");
    }

    function onCreate(uint256 _totalTokens) internal override {}

    /**
     * @dev
     * @notice Retorna true se a função initialize foi executada
     */
    function getInitialized() public view returns (bool) {
        return bInitialized;
    }

    /**
     * @dev
     * @notice Executada apenas 1 vez, faz a emissão dos tokens de acordo com as constantes definidas no contrato.
     */
    function initialize() public {
        require(!bInitialized, "Contract is already initialized");

        uint256 nTotalValue = 0;
        uint256 nTotalDiscountedValue = 0;

        uint256 nTotalTokens = 0;
        for (uint8 i = 0; i < PERIOD_VALUES.length; i++) {
            uint256 nPeriodValue = PERIOD_VALUES[i];
            uint256 nPeriodDiscount = PERIOD_DISCOUNTS[i];

            uint256 nDiscountedValue = LiqiMathLib.mulDiv(
                nPeriodValue,
                nPeriodDiscount,
                100 ether
            );

            nTotalValue = nTotalValue.add(nPeriodValue);
            nTotalDiscountedValue = nTotalDiscountedValue.add(nDiscountedValue);

            nTotalTokens = nTotalTokens.add(
                nDiscountedValue.div(TOKEN_BASE_RATE)
            );
        }

        _mint(aIssuer, nTotalTokens);

        // save interest for reference functions
        nTotalInterest = LiqiMathLib.mulDiv(
            nTotalValue,
            1 ether,
            nTotalDiscountedValue
        );

        for (uint8 i = 0; i < PERIOD_VALUES.length; i++) {
            uint256 nPeriodValue = PERIOD_VALUES[i];

            uint256 nInterest = LiqiMathLib.mulDiv(
                nPeriodValue,
                1 ether,
                nTotalDiscountedValue
            );
            arrInterests.push(nInterest);
        }

        bInitialized = true;
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     * @notice Invocado para pagar dividendos para os token holders.
     * Antes de ser chamado, é necessário chamar increaseAllowance() com no minimo o valor da próxima parcela
     */
    function payDividends() public onlyOwner {
        require(bInitialized, "Contract isn't initialized");
        require(!bCompletedPayment, "Dividends payment is already completed");

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // get the amount needed to pay
        uint256 nPaymentValue = PERIOD_VALUES[nCurrentSnapshotId];

        // make sure we are allowed to transfer the total payment value
        require(
            nPaymentValue <= nAllowance,
            "Not enough allowance to pay dividends"
        );

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), nPaymentValue);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == PERIOD_VALUES.length) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev
     * @notice Invoca payDividends _count numero de vezes
     */
    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends up to 16 times for the calling user
     * @notice Saca até 16 dividendos para o endereço invocando a função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws only 1 dividend for the calling user
     * @notice Saca apenas 1 dividendo para o endereço invocando a função
     */
    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws only 1 dividend for the specified user
     * @notice Saca apenas 1 dividendo para o endereço especificado
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    /**
     * @dev
     * @notice Retorna qual o saldo de dividendos do investidor na parcela especificada
     */
    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // get value from index
            uint256 nPaymentValue = PERIOD_VALUES[_nPaymentIndex - 1];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     * @notice Retorna qual o saldo total de dividendos do investidor especificado.
     * Note que o limite de parcelas que esse método calcula é 16, se houverem mais dividendos pendentes o valor estará incompleto.
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        require(bInitialized, "Contract isn't initialized");

        // read the last payment
        uint256 nLastUserPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // get value from index
            uint256 nPaymentValue = PERIOD_VALUES[nLastUserPayment];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     * @notice Retorna quanto o emissor precisa pagar até o fim do contrato
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna o ultimo pagamento feito ao investidor especificado
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Gets total interest based on all payments
     * @notice Retorna a porcentagem de interesse de todos os pagamentos
     */
    function getTotalInterest() public view returns (uint256) {
        return nTotalInterest;
    }

    /**
     * @dev Gets the total amount of interest paid so far
     * @notice Retorna a porcentagem de interesse paga até agora
     */
    function getPaidInterest() public view returns (uint256) {
        if (bCompletedPayment) {
            return nTotalInterest;
        }

        return getInterest(nCurrentSnapshotId);
    }

    /**
     * @dev Gets the total amount of interest paid so far
     * @notice Retorna a porcentagem de interesse paga até agora
     */
    function getInterest(uint256 _nPaymentIndex) public view returns (uint256) {
        uint256 nInterest = 0;

        // loop all dates
        uint256 nLast = Math.min(_nPaymentIndex, PERIOD_VALUES.length);
        for (uint8 i = 0; i < nLast; i++) {
            uint256 nPeriodInterest = arrInterests[i];

            nInterest = nInterest.add(nPeriodInterest);
        }

        return nInterest;
    }

    /**
     * @dev Gets the amount of interest the specified period pays
     * @notice Retorna a porcentagem de interesse que o periodo especificado paga
     */
    function getPeriodInterest(uint256 _nPeriod) public view returns (uint256) {
        if (_nPeriod >= arrInterests.length) {
            return 0;
        }

        return arrInterests[_nPeriod];
    }

    /**
     * @dev Gets the value of the token up to the current payment index
     * @notice Retorna o valor do token até o ultimo pagamento efetuado pelo emissor
     */
    function getCurrentTokenValue() public view returns (uint256) {
        return getTokenValue(nCurrentSnapshotId);
    }

    /**
     * @dev Gets the value of the token up to the specified payment index
     * @notice Retorna o valor do token até o pagamento especificado
     */
    function getTokenValue(uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        if (_nPaymentIndex == 0) {
            return TOKEN_BASE_RATE;
        } else if (_nPaymentIndex >= PERIOD_VALUES.length) {
            return 0;
        }

        uint256 nTokenValue = 0;

        // loop all dates
        for (uint8 i = 0; i < _nPaymentIndex; i++) {
            uint256 nInterest = arrInterests[i];

            uint256 nTokenInterest = LiqiMathLib.mulDiv(
                TOKEN_BASE_RATE,
                nInterest.mul(100 ether),
                100 ether
            );

            nTokenValue = nTokenValue.add(nTokenInterest);
        }

        uint256 nTokenInterest = LiqiMathLib.mulDiv(
            TOKEN_BASE_RATE,
            nTotalInterest.mul(100 ether),
            100 ether
        );

        uint256 nLinearToken = LiqiMathLib.mulDiv(
            nTokenValue,
            100 ether,
            nTokenInterest
        );

        uint256 nFinalTokenValue = LiqiMathLib.mulDiv(
            TOKEN_BASE_RATE,
            nLinearToken,
            100 ether
        );

        return TOKEN_BASE_RATE.sub(nFinalTokenValue);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev FixedDividendsERC20 handles the payment of a fixed amount of dividends partially
 * @notice FixedDividendsERC20 administra o pagamento de uma quantidade fixa de dividendos
 */
contract FixedDividendsERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 4102455600; // Unix Timestamp
    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 4133991600; // Unix Timestamp

    /**
     * @dev The % of interest generated in the entire interest period
     * @notice A porcentagem de interesse gerado no periodo inteiro
     */
    uint256 public constant INTEREST_RATE = 37.532 * 1 ether;
    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;
    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 33;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Fixed Dividends
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");

        // calculate the total supply of tokens with interest
        uint256 nInterestTokenSupply = LiqiMathLib.mulDiv(
            _totalTokens,
            INTEREST_RATE.add(100 ether),
            100 ether
        );

        // calculate total input token amount to payoff all dividends
        nTotalInputInterest = nInterestTokenSupply.mul(TOKEN_BASE_RATE);

        // calculate how much each payment should be
        nPaymentValue = nTotalInputInterest.div(TOTAL_PERIODS);
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     * @notice Função do dono para pagar dividendos ã todos os token holders
     */
    function payDividends() public onlyOwner {
        require(!bCompletedPayment, "Dividends payment is already completed");

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // make sure we are allowed to transfer the total payment value
        require(
            nPaymentValue <= nAllowance,
            "Not enough allowance to pay dividends"
        );

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), nPaymentValue);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev Invokes the payDividends function multiple times
     * @notice Invoca a função payDividends count vezes
     */
    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends (up to 16 times in the same call, if available)
     * @notice Faz o saque de até 16 dividendos para a carteira que chama essa função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    /**
     * @dev
     * @notice Retorna qual o saldo de dividendos do investidor na parcela especificada
     */
    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     * @notice Retorna qual o saldo total de dividendos do investidor especificado.
     * Note que o limite de parcelas que esse método calcula é 16, se houverem mais dividendos pendentes o valor estará incompleto.
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        // read the last payment
        uint256 nLastUserPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     * @notice Retorna quanto o emissor precisa pagar até o fim do contrato
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Returns the INTEREST_RATE constant
     * @notice Retorna a constante INTEREST_RATE
     */
    function getInterestRate() public pure returns (uint256) {
        return INTEREST_RATE;
    }

    /**
     * @dev Returns the minimum payment value needed to execute payDividends
     * @notice Retorna o valor necessário para invocar payDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current interest
     * @notice Retorna a porcentagem de interesse gerada até agora
     */
    function getCurrentInterest() public view returns (uint256) {
        return getPercentByTime(block.timestamp);
    }

    /**
     * @dev Gets current percent based in period
     * @notice Retorna a porcentagem de interesse gerada até a data especificada
     */
    function getPercentByTime(uint256 _nPaymentDate)
        public
        pure
        returns (uint256)
    {
        if (_nPaymentDate >= DATE_INTEREST_END) {
            return INTEREST_RATE;
        } else if (_nPaymentDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nPaymentDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays.mul(1 ether),
            INTEREST_RATE.mul(1 ether),
            nTotalDays.mul(1 ether)
        );

        uint256 nInterestRate = INTEREST_RATE.mul(1 ether);

        uint256 nFinalValue = nInterestRate.sub(nDiffPercent);

        return nFinalValue.div(1 ether);
    }

    /**
     * @dev Returns the current token value
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getCurrentTokenValue() public view returns (uint256) {
        return getLinearTokenValue(block.timestamp);
    }

    /**
     * @dev Gets current token value based in period
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getLinearTokenValue(uint256 _nDate) public pure returns (uint256) {
        if (_nDate <= DATE_INTEREST_START) {
            return TOKEN_BASE_RATE;
        }

        uint256 nInterest = LiqiMathLib.mulDiv(
            TOKEN_BASE_RATE,
            INTEREST_RATE,
            100 ether
        );

        if (_nDate >= DATE_INTEREST_END) {
            return nInterest.add(TOKEN_BASE_RATE);
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            nInterest,
            nTotalDays
        );

        nDiffPercent = nInterest.sub(nDiffPercent);

        return TOKEN_BASE_RATE.add(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev FixedDividendsPMTERC20 handles the payment of a simple dividends
 * with monthly interest
 */
contract FixedDividendsPMTERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 0; // Unix Timestamp
    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 1000; // Unix Timestamp

    /**
     * @dev % of the remaining paid each month
     * @notice Porcentagem do restante paga todo mês
     */
    uint256 public constant MONTHLY_INTEREST_RATE = 1.3 * 1 ether;
    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;
    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 20;
    /**
     * @dev The periods that are already prepaid prior to this contract
     * @notice A quantidade de periodos que já foram pagos antes da emissão deste contrato
     */
    uint256 public constant PRE_PAID_PERIODS = 3;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;
    // The total amount of interest paid over the entire period
    uint256 private nTotalInterest;

    // A flag indicating if initialize() has been invoked
    bool private bInitialized;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    /**
     * @dev Dividends based on annual payment (PMT) formula
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");

        // make sure all our periods aren't prepaid
        require(
            TOTAL_PERIODS - 1 > PRE_PAID_PERIODS,
            "Need at least 1 period payment"
        );
    }

    /**
     * @dev Ready the contract for dividend payments
     */
    function initialize() public {
        require(!bInitialized, "Contract is already initialized");
        bInitialized = true;

        // calculate how many input tokens we have
        uint256 nTotalValue = totalSupply().mul(TOKEN_BASE_RATE);

        // calculate the payment
        nPaymentValue = PMT(
            MONTHLY_INTEREST_RATE,
            TOTAL_PERIODS,
            nTotalValue,
            0,
            0
        );

        // round the payment value
        nPaymentValue = nPaymentValue.div(0.01 ether);
        nPaymentValue = nPaymentValue.mul(1 ether);

        // get total periods to pay
        uint256 nPeriodsToPay = TOTAL_PERIODS.sub(PRE_PAID_PERIODS);

        // calculate the total amount the issuer has to pay by the end of the contract
        nTotalInputInterest = nPaymentValue.mul(nPeriodsToPay);

        // calculate the total interest
        uint256 nTotalInc = nTotalInputInterest.mul(1 ether);
        nTotalInterest = nTotalInc.div(nTotalValue);
        nTotalInterest = nTotalInterest.mul(10);
    }

    /**
     * @dev Annual Payment
     */
    function PMT(
        uint256 ir,
        uint256 np,
        uint256 pv,
        uint256 fv,
        uint256 tp
    ) public pure returns (uint256) {
        /*
         * ir   - interest rate per month
         * np   - number of periods (months)
         * pv   - present value
         * fv   - future value
         * type - when the payments are due:
         *        0: end of the period, e.g. end of month (default)
         *        1: beginning of period
         */
        ir = ir.div(100);
        pv = pv.div(100);

        if (ir == 0) {
            // TODO: untested
            return -(pv + fv) / np;
        }

        uint256 nPvif = (1 ether + ir);

        //pmt = (-ir * (pv * pvif + fv)) / (pvif - 1);
        uint256 originalPVIF = nPvif;
        for (uint8 i = 1; i < np; i++) {
            nPvif = nPvif * originalPVIF;
            // TODO: this only works if the ir has only 1 digit
            nPvif = nPvif.div(1 ether);
        }

        uint256 nPvPviFv = pv.mul(nPvif.add(fv));
        uint256 topValue = ir.mul(nPvPviFv);
        uint256 botValue = (nPvif - 1 ether);

        uint256 pmt = topValue / botValue;

        if (tp == 1) {
            // TODO: untested
            pmt /= (1 ether + ir);
        }

        pmt /= 1 ether;

        return pmt;
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     * @notice Invocado para pagar dividendos para os token holders.
     * Antes de ser chamado, é necessário chamar increaseAllowance() com no minimo o valor da próxima parcela
     */
    function payDividends() public onlyOwner {
        require(bInitialized, "Contract is not initialized");
        require(!bCompletedPayment, "Dividends payment is already completed");

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // make sure we are allowed to transfer the total payment value
        require(
            nPaymentValue <= nAllowance,
            "Not enough allowance to pay dividends"
        );

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nPaymentValue);

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), nPaymentValue);

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS.sub(PRE_PAID_PERIODS)) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev
     * @notice Invoca payDividends _count numero de vezes
     */
    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends up to 16 times for the calling user
     * @notice Saca até 16 dividendos para o endereço invocando a função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for any specific user
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws only 1 dividend for the specified user
     * @notice Saca apenas 1 dividendo para o endereço especificado
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    /**
     * @dev
     * @notice Retorna qual o saldo de dividendos do investidor na parcela especificada
     */
    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     * @notice Retorna qual o saldo total de dividendos do investidor especificado.
     * Note que o limite de parcelas que esse método calcula é 16, se houverem mais dividendos pendentes o valor estará incompleto.
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        // read the last payment
        uint256 nLastUserPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Returns a flag indicating if the contract has been initialized
     * @notice Retorna uma flag indicando se o metodo initialize() foi invocado e o token está inicializado
     */
    function getInitialized() public view returns (bool) {
        return bInitialized;
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     * @notice Retorna quanto o emissor precisa pagar até o fim do contrato
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna o ultimo pagamento feito ao investidor especificado
     */
    function getLastWithdrawal(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Returns the MONTHLY_INTEREST_RATE constant
     * @notice Retorna a constante MONTHLY_INTEREST_RATE
     */
    function getMonthlyInterestRate() public pure returns (uint256) {
        return MONTHLY_INTEREST_RATE;
    }

    /**
     * @dev Returns the total amount of interest generated over the specified period
     * @notice Retorna o total de interesse gerado sob o periodo especificado no contrato
     */
    function getTotalInterest() public view returns (uint256) {
        return nTotalInterest;
    }

    /**
     * @dev Returns the minimum payment value needed to execute payDividends
     * @notice Retorna o valor necessário para invocar payDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current token value based in the total payments
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getCurrentTokenValue() public view returns (uint256) {
        uint256 nTotalPeriods = TOTAL_PERIODS - PRE_PAID_PERIODS;
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentSnapshotId.mul(1 ether),
            TOKEN_BASE_RATE.mul(1 ether),
            nTotalPeriods
        );

        nDiffPercent = nDiffPercent.div(1 ether).div(1 ether);
        nDiffPercent = TOKEN_BASE_RATE.sub(nDiffPercent);

        return nDiffPercent;
    }

    /**
     * @dev Gets current percent % of total based in the total payments
     * @notice Retorna a porcentagem do total de pagamentos feito
     */
    function getCurrentPercentPaid() public view returns (uint256) {
        uint256 nTotalPeriods = TOTAL_PERIODS - PRE_PAID_PERIODS;
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentSnapshotId.mul(1 ether),
            nTotalInterest,
            nTotalPeriods
        );

        nDiffPercent = nDiffPercent.div(1 ether);
        return nDiffPercent;
    }

    /**
     * @dev Gets current token value based in period
     * @notice Retorna o valor do token linear até a data especificada
     */
    function getLinearTokenValue(uint256 _nDate) public pure returns (uint256) {
        if (_nDate >= DATE_INTEREST_END) {
            return 0;
        } else if (_nDate <= DATE_INTEREST_START) {
            return TOKEN_BASE_RATE;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            TOKEN_BASE_RATE,
            nTotalDays
        );

        return nDiffPercent;
    }

    /**
     * @dev Gets current percent based in period
     * @notice Retorna a porcentagem do total de pagamentos linearmente até a data
     */
    function getLinearPercentPaid(uint256 _nDate)
        public
        view
        returns (uint256)
    {
        if (_nDate >= DATE_INTEREST_END) {
            return nTotalInterest;
        } else if (_nDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays,
            nTotalInterest,
            nTotalDays
        );

        return nTotalInterest.sub(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";
import "../../../base/IOffer_v2.sol";
import "../../../library/BokkyPooBahsDateTimeLibrary.sol";
import "../../../library/LiqiMathLib.sol";

/**
 * @dev FixedMonthlyDividendsERC20 handles the payment
 * of a fixed amount of dividends at the same day every month
 * @notice FixedMonthlyDividendsERC20 administra o pagamentos de uma quantidade fixa de dividendos na mesma data todo mês,
 * com porcentual de multa por dia de pagamento atrasado
 */
contract FixedMonthlyDividendsERC20 is TokenTransfer {
    using SafeMath for uint256;

    /**
     * @dev Date that starts the interest period
     * @notice Data que o interesse começa a contar
     */
    uint256 public constant DATE_INTEREST_START = 4134423600; // Unix Timestamp
    /**
     * @dev Date the dividends finish
     * @notice Data que o interesse termina
     */
    uint256 public constant DATE_INTEREST_END = 4165527600; // Unix Timestamp

    /**
     * @dev Day of the month the payment should be made
     * @notice Dia do mes onde os pagamentos vencem
     */
    uint256 public constant PAYMENT_DAY = 5; // Every 5th

    /**
     * @dev The % of the payment that sould be fined if late
     * @notice Porcentagem da multa diária aplicada para pagamentos atrasados
     */
    uint256 public constant LATE_FINE_RATE = 0.5 * 1 ether;

    /**
     * @dev The % of interest generated in the entire interest period
     * @notice A porcentagem de interesse gerado no periodo inteiro
     */
    uint256 public constant INTEREST_RATE = 37.532 * 1 ether;
    /**
     * @dev The price of the token
     * @notice Valor do token
     */
    uint256 public constant TOKEN_BASE_RATE = 2500;
    /**
     * @dev The total amount of interest payments
     * @notice Total de parcelas de pagamento de interesse
     */
    uint256 public constant TOTAL_PERIODS = 33;

    // Index of the last token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // A flag marking if the payment was completed
    bool private bCompletedPayment;
    // Total amount of input tokens paid to holders
    uint256 private nTotalDividendsPaid;
    // Total amount of input tokens worth of total supply + interest
    uint256 private nTotalInputInterest;
    // The amount that should be paid
    uint256 private nPaymentValue;

    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;

    uint256 nDateInterestStart;

    /**
     * @dev Monthly Dividends
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _dividendsToken
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        // make sure our constants are correct
        require(PAYMENT_DAY <= 28, "Payment day cannot be higher than 28");

        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");

        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);

        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));

        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");

        // calculate the total supply of tokens with interest
        uint256 nInterestTokenSupply = LiqiMathLib.mulDiv(
            totalSupply(),
            INTEREST_RATE.add(100 ether),
            100 ether
        );

        // calculate total input token amount to payoff all dividends
        nTotalInputInterest = nInterestTokenSupply.mul(TOKEN_BASE_RATE);

        // calculate how much each payment should be
        nPaymentValue = nTotalInputInterest.div(TOTAL_PERIODS);

        // get date from timestamp
        (
            uint256 nStartYear,
            uint256 nStartMonth,
            uint256 nStartDay
        ) = BokkyPooBahsDateTimeLibrary.timestampToDate(DATE_INTEREST_START);

        // check if the start of the contract is before or after payment day
        if (nStartDay > PAYMENT_DAY) {
            // add 1 month to our start date
            uint256 nNextMonth = BokkyPooBahsDateTimeLibrary.addMonths(
                DATE_INTEREST_START,
                1
            );

            // reconvert the timestamp to date
            (nStartYear, nStartMonth, nStartDay) = BokkyPooBahsDateTimeLibrary
                .timestampToDate(nNextMonth);

            // convert the date with the payment day back to a timestamp
            nDateInterestStart = BokkyPooBahsDateTimeLibrary.timestampFromDate(
                nStartYear,
                nStartMonth,
                PAYMENT_DAY
            );
        } else {
            // date is before payment day, just save it
            nDateInterestStart = DATE_INTEREST_START;
        }
    }

    function getScheduledPaymentDate(uint256 nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // add 1 month for each payment
        uint256 nPaymentStamp = BokkyPooBahsDateTimeLibrary.addMonths(
            nDateInterestStart,
            nPaymentIndex
        );

        // convert the increased date to date so we can set the day
        (
            uint256 nPaymentYear,
            uint256 nPaymentMonth,
            uint256 nPaymentDay
        ) = BokkyPooBahsDateTimeLibrary.timestampToDate(nPaymentStamp);

        // build the timestamp with the correct payment day and return
        return
            BokkyPooBahsDateTimeLibrary.timestampFromDate(
                nPaymentYear,
                nPaymentMonth,
                PAYMENT_DAY
            );
    }

    /**
     * @dev Owner function to pay dividends to all token holders
     * @notice Função do dono para pagar dividendos ã todos os token holders
     */
    function payDividends() public onlyOwner {
        require(!bCompletedPayment, "Dividends payment is already completed");

        // get the date the payment should be made before
        uint256 nNextPaymentDate = getScheduledPaymentDate(nCurrentSnapshotId);

        // cache the payment value so we can change it
        uint256 nFinalPaymentValue = nPaymentValue;

        // check if the payment is late
        if (block.timestamp > nNextPaymentDate) {
            // calculate how much time has passed since the payment day
            uint256 nDif = block.timestamp - nNextPaymentDate;
            // round down to days
            uint256 nLateDays = nDif / 86400;

            // get the rate of the fine, based on the total days
            uint256 nFineRate = LATE_FINE_RATE.mul(nLateDays);

            // increase the needed payment by the fine rate
            nFinalPaymentValue = LiqiMathLib.mulDiv(
                nPaymentValue,
                nFineRate.add(100 ether),
                100 ether
            );
        }

        // grab our current allowance
        uint256 nAllowance = dividendsToken.allowance(
            _msgSender(),
            address(this)
        );

        // make sure we are allowed to transfer the total payment value
        require(
            nFinalPaymentValue <= nAllowance,
            "Not enough allowance to pay dividends"
        );

        // increase the total amount paid
        nTotalDividendsPaid = nTotalDividendsPaid.add(nFinalPaymentValue);

        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(
            _msgSender(),
            address(this),
            nFinalPaymentValue
        );

        // snapshot the tokens at the moment the ether enters
        nCurrentSnapshotId = _snapshot();

        // check if we have paid everything
        if (nCurrentSnapshotId == TOTAL_PERIODS) {
            bCompletedPayment = true;
        }

        // save the date
        mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }

    /**
     * @dev Invokes the payDividends function multiple times
     * @notice Invoca a função payDividends count vezes
     */
    function payDividendsMultiple(uint256 _count) public onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            payDividends();
        }
    }

    /**
     * @dev Withdraws dividends (up to 16 times in the same call, if available)
     * @notice Faz o saque de até 16 dividendos para a carteira que chama essa função
     */
    function withdrawDividends() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividend() public {
        address aSender = _msgSender();

        require(_withdrawDividends(aSender), "No new withdrawal");
    }

    /**
     * @dev Withdraws dividends up to 16 times for the specified user
     * @notice Saca até 16 dividendos para o endereço especificado
     */
    function withdrawDividendsAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");

        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends(_investor)) {
                return;
            }
        }
    }

    /**
     * @dev Withdraws one single dividend, if available
     * @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
     * (se tiver disponivel)
     */
    function withdrawDividendAny(address _investor) public {
        require(_withdrawDividends(_investor), "No new withdrawal");
    }

    /**
     * @dev
     * @notice Retorna qual o saldo de dividendos do investidor na parcela especificada
     */
    function getDividends(address _aInvestor, uint256 _nPaymentIndex)
        public
        view
        returns (uint256)
    {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSuppy
            );

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     * @notice Retorna qual o saldo total de dividendos do investidor especificado.
     * Note que o limite de parcelas que esse método calcula é 16, se houverem mais dividendos pendentes o valor estará incompleto.
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = Math.min(
            nLastPayment.add(16),
            nCurrentSnapshotId.add(1)
        );

        // loop
        for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(getDividends(_investor, i));
        }

        return nBalance;
    }

    /**
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends(address _sender) private returns (bool) {
        // read the last payment
        uint256 nLastUserPayment = mapLastPaymentSnapshot[_sender];

        // make sure we have a next payment
        if (nLastUserPayment >= nCurrentSnapshotId) {
            return false;
        }

        // add 1 to get the next payment
        uint256 nNextUserPayment = nLastUserPayment.add(1);

        // save back that we have paid this user
        mapLastPaymentSnapshot[_sender] = nNextUserPayment;

        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];

        // get the total amount of balance this user has in offers
        uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nBalanceInOffers);

        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive = LiqiMathLib.mulDiv(
                nTokenBalance,
                nPaymentValue,
                nTokenSupply
            );

            // send the ERC20 value to the user
            dividendsToken.transfer(_sender, nToReceive);
        }

        return true;
    }

    /**
     * @dev Gets the address of the token used for dividends
     * @notice Retorna o endereço do token de dividendos
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /**
     * @dev Gets the total count of payments
     * @notice Retorna a quantidade total de pagamentos efetuados até agora
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nCurrentSnapshotId;
    }

    /**
     * @dev Gets the total count of dividends was paid to this contract
     * @notice Retorna a quantidade total de tokens pagos a esse contrato
     */
    function getTotalDividendsPaid() public view returns (uint256) {
        return nTotalDividendsPaid;
    }

    /**
     * @dev Gets the total amount the issuer has to pay by the end of the contract
     * @notice Retorna quanto o emissor precisa pagar até o fim do contrato
     */
    function getTotalPayment() public view returns (uint256) {
        return nTotalInputInterest;
    }

    /**
     * @dev True if the issuer paid all installments
     * @notice Retorna true se o pagamento de todas as parcelas tiverem sido efetuados
     */
    function getCompletedPayment() public view returns (bool) {
        return bCompletedPayment;
    }

    /**
     * @dev Gets the date the issuer executed the specified payment index
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getPaymentDate(uint256 _nIndex) public view returns (uint256) {
        return mapPaymentDate[_nIndex];
    }

    /**
     * @dev Gets the last payment index for the specified investor
     * @notice Retorna a data de pagamento da parcela especificada
     */
    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /**
     * @dev Gets current interest
     * @notice Retorna a porcentagem de interesse gerada até agora
     */
    function getCurrentInterest() public view returns (uint256) {
        return getPercentByTime(block.timestamp);
    }

    /**
     * @dev Returns the INTEREST_RATE constant
     * @notice Retorna a constante INTEREST_RRATE
     */
    function getInterestRate() public pure returns (uint256) {
        return INTEREST_RATE;
    }

    /**
     * @dev Returns the minimum payment value needed to execute payDividends
     * @notice Retorna o valor necessário para invocar payDividends
     */
    function getPaymentValue() public view returns (uint256) {
        return nPaymentValue;
    }

    /**
     * @dev Gets current percent based in period
     * @notice Retorna a porcentagem de interesse gerada até a data especificada
     */
    function getPercentByTime(uint256 _nPaymentDate)
        public
        pure
        returns (uint256)
    {
        if (_nPaymentDate >= DATE_INTEREST_END) {
            return INTEREST_RATE.mul(1 ether);
        } else if (_nPaymentDate <= DATE_INTEREST_START) {
            return 0;
        }

        uint256 nTotalDays = DATE_INTEREST_END.sub(DATE_INTEREST_START);
        uint256 nCurrentDays = DATE_INTEREST_END.sub(_nPaymentDate);
        uint256 nDiffPercent = LiqiMathLib.mulDiv(
            nCurrentDays.mul(1 ether),
            INTEREST_RATE.mul(1 ether),
            nTotalDays.mul(1 ether)
        );

        // (currentDays * 100) / totalDays;
        return INTEREST_RATE.mul(1 ether).sub(nDiffPercent);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../TokenTransfer.sol";

/**
* @dev LockupDateAfter locks all token tranfers after a specified date
*/
contract LockupDateAfter is TokenTransfer {
    uint256 public constant LOCKUP_DATE_AFTER = 2556198000;  // May 4th 2100 

    /**
     * @dev
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) { }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        // check if were allowed to continue
        if (block.timestamp > LOCKUP_DATE_AFTER) {
            revert("Date is after token lockup date");
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../TokenTransfer.sol";

/**
* @dev LockupDateBefore locks all token tranfers before a specified date
*/
contract LockupDateBefore is TokenTransfer {
    uint256 public constant LOCKUP_DATE_RELEASE = 2524662000;
    bool private bInitialized;

    /**
     * @dev
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        bInitialized = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        // check if were allowed to continue
        if (bInitialized && block.timestamp < LOCKUP_DATE_RELEASE) {
            revert("Date is before token release date");
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../TokenTransfer.sol";

/**
 * @dev LockupIssuerDateAfter locks a amount of tokens to the emitter until a specified date
 */
contract LockupIssuerDateAfter is TokenTransfer {
    uint256 public constant LOCKUP_ISSUER_DATE_AFTER = 2556198000; // Jan 1th 2050
    uint256 public constant LOCKUP_ISSUER_AMOUNT = 2000 * 1 ether; // Total amount of tokens the user has to hold

    bool private bInitialized;

    /**
     * @dev
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        require(_issuer != address(0), "Issuer is empty");

        bInitialized = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        // check if were allowed to continue
        if (_msgSender() == aIssuer && bInitialized) {
            // rule only applies before
            if (block.timestamp < LOCKUP_ISSUER_DATE_AFTER) {
                // check if the balance is enough
                uint256 nBalance = balanceOf(aIssuer);

                // remove the transfer from the balance
                uint256 nFinalBalance = nBalance.sub(amount);

                // make sure the remaining tokens are more than the needed by the rule
                require(
                    nFinalBalance >= LOCKUP_ISSUER_AMOUNT,
                    "Transfering more than account allows"
                );
            }
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../TokenTransfer.sol";
import "../../../base/ISignatureManager.sol";

/**
 * @dev LockupSignatureManager locks all token transfers until the token is signed
 */
contract LockupSignatureManager is TokenTransfer {
    // A reference to the contract that signs
    ISignatureManager internal signatureManager;

    /**
     * @dev
     */
    constructor(
        address _signatureManagerContract,
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {
        require(_issuer != address(0), "Issuer is empty");

        // convert the address to the interface
        signatureManager = ISignatureManager(_signatureManagerContract);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (signatureManager != ISignatureManager(0x0)) {
            require(
                signatureManager.isSigned(address(this)),
                "Token is not signed"
            );
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "../../base/NFBaseToken.sol";

/**
 * @dev Base class for every Non Fungible Token
 */
contract NFTModule is NFBaseToken {
    // Address of the issuer
    address internal aIssuer;

    uint256 private nStatus;

    string public constant NFT_COLLECTION_URI = "hello";

    constructor(
        address _issuer,
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _baseUri
    ) public NFBaseToken(_tokenName, _tokenSymbol) {
        // make sure the issuer is not empty
        require(_issuer != address(0));

        // save address of the issuer
        aIssuer = _issuer;

        setBaseUri(_baseUri);
    }

    /**
     * @dev Sets the base uri
     */
    function setBaseUri(string memory _baseUri) public onlyOwner {
        // save the base URI
        _setBaseURI(_baseUri);
    }

    /**
     * @dev Creates an item with the specified URI and ID
     */
    function createItem(uint256 _tokenId, string memory _tokenUri) public onlyOwner {
        _createItem(_tokenId, _tokenUri);
    }

    /**
     * @dev Creates an item with the specified URI and ID
     */
    function _createItem(uint256 _tokenId, string memory _tokenUri) private {
        _mint(aIssuer, _tokenId);
        _setTokenURI(_tokenId, _tokenUri);
    }

    /**
     * @dev Returns an URI to JSON data about this NFT collection
     */
    function contractURI() public pure returns (string memory) {
        return NFT_COLLECTION_URI;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "../../base/BaseOfferToken.sol";
import "../../base/IOffer_v2.sol";

/**
 * @dev TokenTransfer has most of the implementations
 * needed to interact with offer contracts automatically
 * @notice Contrato base para todos os tokens ofertáveis ERC20.
 * Possui várias implementações para se conectar direto com ofertas Liqi.
 */
contract TokenTransfer is BaseOfferToken {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // A map of the offer index to the start date
    mapping(uint256 => uint256) internal mapOfferStartDate;
    // A map of the offer index to the offer object
    mapping(uint256 => IOffer) internal mapOffers;
    // A map of the investor to the last cashout he did
    mapping(address => uint256) internal mapLastCashout;

    // An internal counter to keep track of the offers
    Counters.Counter internal counterTotalOffers;

    // Address of the issuer
    address internal aIssuer;

    /**
     * @dev Constructor for TokenTransfer
     * @notice Constructor para o token base Token Transfer
     */
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public BaseOfferToken(_tokenName, _tokenSymbol) {
        // make sure the issuer is not empty
        require(_issuer != address(0));

        // save address of the issuer
        aIssuer = _issuer;

        // call onCreate so inheriting contracts can override base mint functionality
        onCreate(_totalTokens);
    }

    function onCreate(uint256 _totalTokens) internal virtual {
        // make sure were not starting with 0 tokens
        require(_totalTokens != 0, "Tokens to be minted is 0");

        // mints all tokens to issuer
        _mint(aIssuer, _totalTokens);
    }

    /**
     * @dev Registers a offer on the token
     * @notice Método para iniciar uma oferta de venda de token Liqi (parte do sistema interno de deployment)
     */
    function startOffer(address _aTokenOffer)
        public
        onlyOwner
        returns (uint256)
    {
        // make sure the address isn't empty
        require(_aTokenOffer != address(0), "Offer cant be empty");

        // convert the offer to a interface
        IOffer objOffer = IOffer(_aTokenOffer);

        // make sure the offer is intiialized
        require(!objOffer.getInitialized(), "Offer should not be initialized");

        // gets the index of the last offer, if it exists
        uint256 nLastId = counterTotalOffers.current();

        // check if its the first offer
        if (nLastId != 0) {
            // get a reference to the last offer
            IOffer objLastOFfer = IOffer(mapOffers[nLastId]);

            // make sure the last offer is finished
            require(objLastOFfer.getFinished(), "Offer should be finished");
        }

        // increment the total of offers
        counterTotalOffers.increment();

        // gets the current offer index
        uint256 nCurrentId = counterTotalOffers.current();

        // save the address of the offer
        mapOffers[nCurrentId] = objOffer;

        // save the date the offer should be considered for dividends
        mapOfferStartDate[nCurrentId] = block.timestamp;

        // initialize the offer
        objOffer.initialize();

        return nCurrentId;
    }

    /**
     * @dev Try to cashout up to 5 times
     * @notice Faz o cashout de até 6 compras de tokens na(s) oferta(s), para a carteira especificada
     */
    function cashoutFrozenMultipleAny(address aSender) public {
        bool bHasCashout = cashoutFrozenAny(aSender);
        require(bHasCashout, "No cashouts available");

        for (uint256 i = 0; i < 5; i++) {
            if (!cashoutFrozenAny(aSender)) {
                return;
            }
        }
    }

    /**
     * @dev Main cashout function, cashouts up to 16 times
     * @notice Faz o cashout de até 6 compras de tokens na(s) oferta(s), para a carteira que chama essa função
     */
    function cashoutFrozen() public {
        // cache the sender
        address aSender = _msgSender();

        // try to do 10 cashouts
        cashoutFrozenMultipleAny(aSender);
    }

    /**
     * @return true if it changed the state
     * @notice Faz o cashout de apenas 1 compra para o endereço especificado.
     * Retorna true se mudar o estado do contrato.
     */
    function cashoutFrozenAny(address _account) public virtual returns (bool) {
        // get the latest token sale that was cashed out
        uint256 nCurSnapshotId = counterTotalOffers.current();

        // get the last token sale that this user cashed out
        uint256 nLastCashout = mapLastCashout[_account];

        // return if its the latest offer
        if (nCurSnapshotId <= nLastCashout) {
            return false;
        }

        // add 1 to get the next payment index
        uint256 nNextCashoutIndex = nLastCashout.add(1);

        // get the address of the offer this user is cashing out
        IOffer offer = mapOffers[nNextCashoutIndex];

        // cashout the tokens, if the offer allows
        bool bOfferCashout = offer.cashoutTokens(_account);

        // check if the sale is finished
        if (offer.getFinished()) {
            // save that it was cashed out, if the offer is over
            mapLastCashout[_account] = nNextCashoutIndex;

            return true;
        }

        return bOfferCashout;
    }

    /**
     * @dev Returns the total amount of tokens the
     * caller has in offers, up to _nPaymentDate
     * @notice Calcula quantos tokens o endereço tem dentro de ofertas com sucesso (possíveis de saque) até a data de pagamento especificada
     */
    function getTotalInOffers(uint256 _nPaymentDate, address _aInvestor)
        public
        view
        returns (uint256)
    {
        // start the final balance as 0
        uint256 nBalance = 0;

        // get the latest offer index
        uint256 nCurrent = counterTotalOffers.current();

        for (uint256 i = 1; i <= nCurrent; i++) {
            // get offer start date
            uint256 nOfferDate = getOfferDate(i);

            // break if the offer started after the payment date
            if (nOfferDate >= _nPaymentDate) {
                break;
            }

            // grab the offer from the map
            IOffer objOffer = mapOffers[i];

            // only get if offer is finished
            if (!objOffer.getFinished()) {
                break;
            }

            if (!objOffer.getSuccess()) {
                continue;
            }

            // get the total amount the user bought at the offer
            uint256 nAddBalance = objOffer.getTotalBoughtDate(
                _aInvestor,
                _nPaymentDate
            );

            // get the total amount the user cashed out at the offer
            uint256 nRmvBalance = objOffer.getTotalCashedOutDate(
                _aInvestor,
                _nPaymentDate
            );

            // add the bought and remove the cashed out
            nBalance = nBalance.add(nAddBalance).sub(nRmvBalance);
        }

        return nBalance;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(to != address(this), "Sending to contract address");

        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev Get the date the offer of the _index started
     * @notice Retorna a data de inicio da oferta especificada
     */
    function getOfferDate(uint256 _index) public view returns (uint256) {
        return mapOfferStartDate[_index];
    }

    /**
     * @dev Get the address of the _index offer
     * @notice Retorna o endereço da oferta especificada
     */
    function getOfferAddress(uint256 _index) public view returns (address) {
        return address(mapOffers[_index]);
    }

    /**
     * @dev Get the index of the last cashout for the _account
     * @notice Retorna o índice da ultima oferta que o endereço especificado fez o cashout
     */
    function getLastCashout(address _account) public view returns (uint256) {
        return mapLastCashout[_account];
    }

    /**
     * @dev Get the total amount of offers registered
     * @notice Retorna o total de ofertas que foram linkadas a esse token
     */
    function getTotalOffers() public view returns (uint256) {
        return counterTotalOffers.current();
    }

    /**
     * @dev Gets the address of the issuer
     * @notice Retorna o endereço da carteira do emissor
     */
    function getIssuer() public view returns (address) {
        return aIssuer;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SingleRewardToken is ERC20, Ownable {
    /**
     * @dev
     * @notice Mapa de pagamentos
     */
    mapping(address => bool) internal mapPayments;

    bool private bLocked;

    constructor(string memory _tokenName, string memory _tokenSymbol)
        public
        ERC20(_tokenName, _tokenSymbol)
    {
    }

    function awardToken(address _account) public onlyOwner {
        require(!mapPayments[_account], "User already awarded token");

        _mint(_account, 1 ether);

        mapPayments[_account] = true;
    }

    function lockToken() public onlyOwner {
        require(!bLocked, "Already locked");
        bLocked = true;
    }

    function returnToken() public {
        uint256 balance = balanceOf(_msgSender());
        require(balance == 1 ether, "No token to return");

        transfer(owner(), 1 ether);
    }

    function returnTokenAny(address _investor) public {
        uint256 balance = balanceOf(_investor);
        require(balance == 1 ether, "No token to return");

        _transfer(_investor, owner(), 1 ether);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(!bLocked, "Contract locked");

        if (from != address(0)) {
            require(to == owner(), "Only return token to owner");
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";

contract UtilityDynamicSupply is TokenTransfer {
    /**
     * @dev The total amount of minted tokens, regardless of burned
     * @notice A quantidade total de tokens emitidos
     */
    uint256 private nTotalMintedTokens;

    /**
     * @dev The total amount of burned tokens
     * @notice A quantidade total de tokens queimados
     */
    uint256 private nTotalBurnedTokens;

    constructor(
        address _issuer,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, 0, _tokenName, _tokenSymbol) {}

    function onCreate(uint256 _totalTokens) internal override {}

    function mint(address _account, uint256 _amount) public onlyOwner {
        nTotalMintedTokens = nTotalMintedTokens.add(_amount);
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public onlyOwner {
        nTotalBurnedTokens = nTotalBurnedTokens.add(_amount);
        _burn(_account, _amount);
    }

    /**
     * @dev Returns the total amount of minted tokens, regardless of burned
     * @notice Retorna a quantidade total de tokens emitidos
     */
    function getTotalMinted() public view returns (uint256) {
        return nTotalMintedTokens;
    }

    /**
     * @dev Returns the total amount of minted tokens, regardless of burned
     * @notice Retorna a quantidade total de tokens emitidos
     */
    function getTotalBurned() public view returns (uint256) {
        return nTotalBurnedTokens;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../TokenTransfer.sol";

contract UtilityFixedSupply is TokenTransfer {
    constructor(
        address _issuer,
        uint256 _totalTokens,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public TokenTransfer(_issuer, _totalTokens, _tokenName, _tokenSymbol) {}

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../base/IOffer.sol";
import "../../LiqiBRLToken.sol";
import "../../base/BaseOfferToken.sol";

contract CRZ0Offer is Ownable, IOffer {
    // R$15,00
    uint256 public constant RATE_PHASE_1 = 1750;
    // R$16,00
    uint256 public constant RATE_PHASE_2 = 1875;
    // R$17,50
    uint256 public constant RATE_PHASE_3 = 2000;
    // R$18,75
    uint256 public constant RATE_PHASE_4 = 2125;
    // Minimum of 72000 to sell
    uint256 public constant MIN_TOTAL_TOKEN_SOLD = 79200 * 1 ether;
    // Total amount of tokens to be sold
    uint256 public constant TOTAL_TOKENS = 316800 * 1 ether;
    // Total amount to sell to end rate 1
    uint256 public constant RATE_AMOUNT_PHASE_1 = 79200 * 1 ether;
    // Total amount to sell to end rate 2
    uint256 public constant RATE_AMOUNT_PHASE_2 = 158400 * 1 ether;
    // Total amount to sell to end rate 3
    uint256 public constant RATE_AMOUNT_PHASE_3 = 237600 * 1 ether;

    // If the offer has been initialized by the owner
    bool private bInitialized;
    // If the success condition has been met
    bool private bSuccess;
    // If the offer has finished the sale of tokens
    bool private bFinished;

    // A counter of the total amount of tokens sold
    uint256 internal nTotalSold;

    // The date the offer finishSale function was called
    uint256 internal nFinishDate;

    // A reference to the BRLToken contract
    LiqiBRLToken private brlToken;
    // A reference to the emitter of the offer
    address private aEmitter;
    // Use safe math for add and sub
    using SafeMath for uint256;
    // Create a structure to save our payments
    struct Payment {
        // The total amount the user bought in tokens
        uint256 totalAmount;
        // The total amount the user has received in tokens
        uint256 totalPaid;
    }
    // A reference to the token were selling
    BaseOfferToken private baseToken;
    // A map of address to payment
    mapping(address => Payment) private mapPayments;

    constructor(
        address _emitter,
        address _brlTokenContract,
        address _tokenAddress
    ) public {
        aEmitter = _emitter;
        brlToken = LiqiBRLToken(_brlTokenContract);
        baseToken = BaseOfferToken(_tokenAddress);
    }

    /*
     * @dev Initializes the sale
     */
    function initialize() public override {
        require(_msgSender() == address(baseToken), "Only call from token");

        require(!bInitialized, "Sale is initialized");

        bInitialized = true;
    }

    function cashoutBRLT() public {
        // no unsuccessful sale
        require(bSuccess, "Sale is not successful");
        // check the balance of tokens of this contract
        uint256 nBalance = brlToken.balanceOf(address(this));
        // nothing to execute if the balance is 0
        require(nBalance != 0, "Balance to cashout is 0");
        // transfer all tokens to the emitter account
        brlToken.transfer(aEmitter, nBalance);
    }

    function getTokenAddress() public view returns (address) {
        return address(brlToken);
    }

    function getToken() public view returns (address token) {
        return address(baseToken);
    }

    /*
     * @dev Declare an investment for an address
     */
    function invest(address _investor, uint256 _amount) public onlyOwner {
        // make sure the investor is not an empty address
        require(_investor != address(0), "Investor is empty");
        // make sure the amount is not zero
        require(_amount != 0, "Amount is zero");
        // do not sell if sale is finished
        require(!bFinished, "Sale is finished");
        // do not sell if not initialized
        require(bInitialized, "Sale is not initialized");

        // process input data
        // call with same args
        brlToken.invest(_investor, _amount);
        // convert input currency to output
        // - get rate from module
        uint256 nRate = getRate();

        // - total amount from the rate obtained
        uint256 nOutputAmount = _amount.div(nRate);

        // pass to module to handling outputs
        // get the current contract's balance
        uint256 nBalance = baseToken.balanceOf(address(this));
        // calculate how many tokens we can sell
        uint256 nRemainingBalance = nBalance.sub(nTotalSold);
        // make sure we're not selling more than we have
        require(
            nOutputAmount <= nRemainingBalance,
            "Offer does not have enough tokens to sell"
        );
        // read the payment data from our map
        Payment memory payment = mapPayments[_investor];
        // increase the amount of tokens this investor has purchased
        payment.totalAmount = payment.totalAmount.add(nOutputAmount);
        mapPayments[_investor] = payment;

        // after everything, add the bought tokens to the total
        nTotalSold = nTotalSold.add(nOutputAmount);

        // and check if the sale is sucessful after this sale
        if (!bSuccess) {
            if (nTotalSold >= MIN_TOTAL_TOKEN_SOLD) {
                // we have sold more than minimum, success
                bSuccess = true;
            }
        }
    }

    /*
     * @dev Marks the offer as finished
     */
    function finishSale() public onlyOwner {
        require(!bFinished, "Sale is finished");
        bFinished = true;

        if (!getSuccess()) {
            // notify the BRLT
            brlToken.failedSale();
        }
        // get the current contract's balance
        uint256 nBalance = baseToken.balanceOf(address(this));
        if (getSuccess()) {
            // calculate how many tokens we have not sold
            uint256 nRemainingBalance = nBalance.sub(nTotalSold);
            // return remaining tokens to owner
            baseToken.transfer(aEmitter, nRemainingBalance);
        } else {
            // return all tokens to owner
            baseToken.transfer(aEmitter, nBalance);
        }
    }

    /*
     * @dev Cashouts tokens for a specified user
     */
    function cashoutTokens(address _investor)
        external
        virtual
        override
        returns (bool)
    {
        require(_msgSender() == address(baseToken), "Call only from token");
        // wait till the offer is successful to allow transfer
        if (!bSuccess) {
            return false;
        }
        // read the token sale data for that address
        Payment storage payment = mapPayments[_investor];
        // nothing to be paid
        if (payment.totalAmount == 0) {
            return false;
        }
        // calculate the remaining tokens
        uint256 nRemaining = payment.totalAmount.sub(payment.totalPaid);
        // make sure there's something to be paid
        if (nRemaining == 0) {
            return false;
        }
        // transfer to requested user
        baseToken.transfer(_investor, nRemaining);
        // mark that we paid the user in fully
        payment.totalPaid = payment.totalAmount;
        return true;
    }

    /*
     * @dev Returns the current rate for the token
     */
    function getRate() public view virtual returns (uint256 rate) {
        if (nTotalSold >= RATE_AMOUNT_PHASE_3) {
            return RATE_PHASE_4;
        } else if (nTotalSold >= RATE_AMOUNT_PHASE_2) {
            return RATE_PHASE_3;
        } else if (nTotalSold >= RATE_AMOUNT_PHASE_1) {
            return RATE_PHASE_2;
        } else {
            return RATE_PHASE_1;
        }
    }

    /*
     * @dev Gets how much the specified user has bought from this offer
     */
    function getTotalBought(address _investor)
        public
        view
        override
        returns (uint256 nTotalBought)
    {
        return mapPayments[_investor].totalAmount;
    }

    /*
     * @dev Get total amount the user has cashed out from this offer
     */
    function getTotalCashedOut(address _investor)
        public
        view
        override
        returns (uint256 nTotalCashedOut)
    {
        return mapPayments[_investor].totalPaid;
    }

    /*
     * @dev Returns true if the sale is initialized
     */
    function getInitialized() public view override returns (bool) {
        return bInitialized;
    }

    /*
     * @dev Returns true if the sale is finished
     */
    function getFinished() public view override returns (bool) {
        return bFinished;
    }

    /*
     * @dev Returns true if the sale is successful
     */
    function getSuccess() public view override returns (bool) {
        return bSuccess;
    }

    /*
     * @dev Gets the total amount of tokens sold
     */
    function getTotalSold() public view virtual returns (uint256 totalSold) {
        return nTotalSold;
    }

    /*
     * @dev Gets the date the offer finished at
     */
    function getFinishDate() external view override returns (uint256) {
        return nFinishDate;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../base/IOffer.sol";

contract CRZ0Token is ERC20Snapshot, Ownable {
    // Name of the token
    string public constant TOKEN_NAME = "Cruzeiro Token - Talentos da Toca";
    // Symbol of the token
    string public constant TOKEN_SYMBOL = "CRZ0";
    // Total amount of tokens
    uint256 public constant TOTAL_TOKENS = 792000 * 1 ether;
    // Date the token should expire
    uint256 public constant EXPIRATION_DATE_AFTER = 1811865600;
    // Date the token should unlock for the emitter
    uint256 public constant LOCKUP_EMITTER_DATE_AFTER = 1811865600;
    // Total amount the emitter has to hold
    uint256 public constant LOCKUP_EMITTER_AMOUNT = 475200 * 1 ether;

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    // A map of the offer index to the start date
    mapping(uint256 => uint256) internal mapOfferStartDate;
    // A map of the offer index to the offer object
    mapping(uint256 => IOffer) internal mapOffers;
    // A map of the investor to the last cashout he did
    mapping(address => uint256) internal mapLastCashout;
    // An internal counter to keep track of the offers
    Counters.Counter internal counterTotalOffers;
    // address of the receiver
    address internal aReceiver;
    // Index of the last token snapshot
    uint256 private nSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend total amount
    mapping(uint256 => uint256) private mapERCPayment;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;
    // A reference to the emitter of the offer
    address internal aEmitter;

    // A fuse to disable the exchangeBalance function
    bool internal bDisabledExchangeBalance;

    constructor(
        address _receiver,
        address _dividendsToken,
        address _emitter
    ) public ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
        // make sure the receiver is not empty
        require(_receiver != address(0));
        // save address of the receiver
        aReceiver = _receiver;
        // mints all tokens to receiver
        _mint(_receiver, TOTAL_TOKENS);
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");
        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);
        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));
        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");
        require(_emitter != address(0), "Emitter is empty");
        // save the address of the emitter
        aEmitter = _emitter;
    }

    /*
     * @dev Get the date the offer of the _index started
     */
    function getOfferDate(uint256 _index) public view returns (uint256) {
        return mapOfferStartDate[_index];
    }

    /*
     * @dev Get the address of the _index offer
     */
    function getOfferAddress(uint256 _index) public view returns (address) {
        return address(mapOffers[_index]);
    }

    /*
     * @dev Get the index of the last cashout for the _account
     */
    function getLastCashout(address _account) public view returns (uint256) {
        return mapLastCashout[_account];
    }

    /*
     * @dev Get the total amount of offers registered
     */
    function getTotalOffers() public view returns (uint256) {
        return counterTotalOffers.current();
    }

    /*
     * @dev Registers a sale on the token
     */
    function startSale(address _aTokenSale) public onlyOwner returns (uint256) {
        // make sure the address isn't empty
        require(_aTokenSale != address(0), "Sale cant be empty");
        // convert the sale to a interface
        IOffer objSale = IOffer(_aTokenSale);
        // make sure the sale is intiialized
        require(!objSale.getInitialized(), "Sale should not be initialized");
        // increment the total of offers
        counterTotalOffers.increment();
        // gets the current offer index
        uint256 nCurrentId = counterTotalOffers.current();
        // save the address of the sale
        mapOffers[nCurrentId] = objSale;
        // save the date the offer should be considered for dividends
        mapOfferStartDate[nCurrentId] = block.timestamp;
        // initialize the sale
        objSale.initialize();
        return nCurrentId;
    }

    /*
     * @dev Try to cashout up to 15 times
     */
    function tryCashouts(address aSender) private {
        for (uint256 i = 0; i < 15; i++) {
            if (!cashoutFrozenAny(aSender)) {
                return;
            }
        }
    }

    /*
     * @dev Main cashout function, cashouts up to 16 times
     */
    function cashoutFrozen() public {
        // cache the sender
        address aSender = _msgSender();
        bool bHasCashout = cashoutFrozenAny(aSender);
        require(bHasCashout, "No cashouts available");
        // try to do 10 cashouts
        tryCashouts(aSender);
    }

    /**
     * @return true if it changed the state
     */
    function cashoutFrozenAny(address _account) public virtual returns (bool) {
        // get the latest token sale that was cashed out
        uint256 nCurrentSnapshotId = counterTotalOffers.current();
        // get the last token sale that this user cashed out
        uint256 nLastCashout = mapLastCashout[_account];
        // return if its the latest offer
        if (nCurrentSnapshotId <= nLastCashout) {
            return false;
        }
        // add 1 to get the next payment index
        uint256 nNextCashoutIndex = nLastCashout.add(1);
        // get the address of the offer this user is cashing out
        IOffer offer = mapOffers[nNextCashoutIndex];
        // cashout the tokens, if the offer allows
        bool bOfferCashout = offer.cashoutTokens(_account);
        // check if the sale is finished
        if (offer.getFinished()) {
            // save that it was cashed out, if the offer is over
            mapLastCashout[_account] = nNextCashoutIndex;
            return true;
        }
        return bOfferCashout;
    }

     /*
     * @dev Returns the total amount of tokens the
     * caller has in offers, up to _nPaymentDate
     */
    function getTotalInOffers(uint256 _nPaymentDate, address _aInvestor)
        public
        view
        returns (uint256)
    {
        // start the final balance as 0
        uint256 nBalance = 0;

        // get the latest offer index
        uint256 nCurrent = counterTotalOffers.current();

        // get the last token sale that this user cashed out
        uint256 nLastCashout = mapLastCashout[_aInvestor];

        for (uint256 i = nLastCashout + 1; i <= nCurrent; i++) {
            // get offer start date
            uint256 nOfferDate = getOfferDate(i);

            // break if the offer started after the payment date
            if (nOfferDate > _nPaymentDate) {
                break;
            }

            // grab the offer from the map
            IOffer objOffer = mapOffers[i];

            // get the total amount the user bought at the offer
            uint256 nAddBalance = objOffer.getTotalBought(_aInvestor);

            // get the total amount the user cashed out at the offer
            uint256 nRmvBalance = objOffer.getTotalCashedOut(_aInvestor);

            // add the bought and remove the cashed out
            nBalance = nBalance.add(nAddBalance).sub(nRmvBalance);
        }

        return nBalance;
    }

    /*
     * @dev Gets the address of the token used for dividends
     */
    function getDividendsToken() public view returns (address) {
        return address(dividendsToken);
    }

    /*
     * @dev Gets the total count of payments
     */
    function getTotalDividendPayments() public view returns (uint256) {
        return nSnapshotId;
    }

    function getPayment(uint256 _nIndex)
        public
        view
        returns (uint256 nERCPayment, uint256 nDate)
    {
        nERCPayment = mapERCPayment[_nIndex];
        nDate = mapPaymentDate[_nIndex];
    }

    function getLastPayment(address _aInvestor) public view returns (uint256) {
        return mapLastPaymentSnapshot[_aInvestor];
    }

    /*
     * @dev Function made for owner to transfer tokens to contract for dividend payment
     */
    function payDividends(uint256 _amount) public onlyOwner {
        // make sure the amount is not zero
        require(_amount > 0, "Amount cant be zero");
        // grab our current allowance
        uint256 nAllowance =
            dividendsToken.allowance(_msgSender(), address(this));
        // make sure we at least have the balance added
        require(_amount <= nAllowance, "Not enough balance to pay dividends");
        // transfer the tokens from the sender to the contract
        dividendsToken.transferFrom(_msgSender(), address(this), _amount);
        // snapshot the tokens at the moment the ether enters
        nSnapshotId = _snapshot();
        // register the balance in ether that entered
        mapERCPayment[nSnapshotId] = _amount;
        // save the date
        mapPaymentDate[nSnapshotId] = block.timestamp;
    }

    /*
     * @dev Withdraws dividends up to 16 times
     */
    function withdrawDividends() public {
        require(_withdrawDividends(), "No new withdrawal");
        for (uint256 i = 0; i < 15; i++) {
            if (!_withdrawDividends()) {
                return;
            }
        }
    }

    function _recursiveGetTotalDividends(
        address _aInvestor,
        uint256 _nPaymentIndex
    ) internal view returns (uint256) {
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);

        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];

        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);

        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);

        if (nTokenBalance == 0) {
            return 0;
        } else {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(_nPaymentIndex);

            // get the total token amount for this payment
            uint256 nTotalTokens = mapERCPayment[_nPaymentIndex];

            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive =
                mulDiv(nTokenBalance, nTotalTokens, nTokenSuppy);

            return nToReceive;
        }
    }

    /**
     * @dev Gets the total amount of dividends for an investor
     */
    function getTotalDividends(address _investor)
        public
        view
        returns (uint256)
    {
        // start total balance 0
        uint256 nBalance = 0;

        // get the last payment index for the investor
        uint256 nLastPayment = mapLastPaymentSnapshot[_investor];

        // add 16 as the limit
        uint256 nEndPayment = nLastPayment.add(16);

        // loop
        for (uint256 i = nLastPayment + 1; i < nEndPayment; i++) {
            // add the balance that would be withdrawn if called for this index
            nBalance = nBalance.add(_recursiveGetTotalDividends(_investor, i));

            // if bigger than all total snapshots, end the loop
            if (i >= nSnapshotId) {
                break;
            }
        }

        return nBalance;
    }

    /*
     * @dev Based on how many tokens the user had at the snapshot,
     * pay dividends of the erc20 token
     * (also pays for tokens inside offer)
     */
    function _withdrawDividends() private returns (bool) {
        // cache the sender
        address aSender = _msgSender();
        // read the last payment
        uint256 nLastPayment = mapLastPaymentSnapshot[aSender];
        // make sure we have a next payment
        if (nLastPayment >= nSnapshotId) {
            return false;
        }
        // add 1 to get the next payment
        uint256 nNextPayment = nLastPayment.add(1);
        // save back that we have paid this user
        mapLastPaymentSnapshot[aSender] = nNextPayment;
        // get the balance of the user at this snapshot
        uint256 nTokenBalance = balanceOfAt(aSender, nNextPayment);
        // get the date the payment entered the system
        uint256 nPaymentDate = mapPaymentDate[nNextPayment];
        // get the total amount of balance this user has in offers
        uint256 nTotalOffers = getTotalInOffers(nPaymentDate, aSender);
        // add the total amount the user has in offers
        nTokenBalance = nTokenBalance.add(nTotalOffers);
        if (nTokenBalance != 0) {
            // get the total supply at this snapshot
            uint256 nTokenSuppy = totalSupplyAt(nNextPayment);
            // get the total token amount for this payment
            uint256 nTotalTokens = mapERCPayment[nNextPayment];
            // calculate how much he'll receive from this lot,
            // based on the amount of tokens he was holding
            uint256 nToReceive =
                mulDiv(nTokenBalance, nTotalTokens, nTokenSuppy);
            // send the ERC20 value to the user
            dividendsToken.transfer(aSender, nToReceive);
        }
        return true;
    }

    function fullMul(uint256 x, uint256 y)
        public
        pure
        returns (uint256 l, uint256 h)
    {
        uint256 xl = uint128(x);
        uint256 xh = x >> 128;
        uint256 yl = uint128(y);
        uint256 yh = y >> 128;
        uint256 xlyl = xl * yl;
        uint256 xlyh = xl * yh;
        uint256 xhyl = xh * yl;
        uint256 xhyh = xh * yh;
        uint256 ll = uint128(xlyl);
        uint256 lh = (xlyl >> 128) + uint128(xlyh) + uint128(xhyl);
        uint256 hl = uint128(xhyh) + (xlyh >> 128) + (xhyl >> 128);
        uint256 hh = (xhyh >> 128);
        l = ll + (lh << 128);
        h = (lh >> 128) + hl + (hh << 128);
    }

    /**
     * @dev Very cheap x*y/z
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        require(h < z);
        uint256 mm = mulmod(x, y, z);
        if (mm > l) h -= 1;
        l -= mm;
        uint256 pow2 = z & -z;
        z /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        return l * r;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        address aSender = _msgSender();
        // try to cashout all possible offers before transfering
        tryCashouts(aSender);
        // check if were allowed to continue
        if (block.timestamp > EXPIRATION_DATE_AFTER) {
            revert("Date is after token lockup date");
        }
        if (_msgSender() == aEmitter) {
            // rule only applies before
            if (block.timestamp < LOCKUP_EMITTER_DATE_AFTER) {
                // check if the balance is enough
                uint256 nBalance = balanceOf(aEmitter);
                // remove the transfer from the balance
                uint256 nFinalBalance = nBalance.sub(amount);
                // make sure the remaining tokens are more than the needed by the rule
                require(
                    nFinalBalance >= LOCKUP_EMITTER_AMOUNT,
                    "Transfering more than account allows"
                );
                super._beforeTokenTransfer(from, to, amount);
            }
        }
    }

    /**
     * @dev Disables the exchangeBalance function
     */
    function disableExchangeBalance() public onlyOwner {
        require(
            !bDisabledExchangeBalance,
            "Exchange balance is already disabled"
        );

        bDisabledExchangeBalance = true;
    }

    /**
     * @dev Exchanges the funds of one address to another
     */
    function exchangeBalance(address _from, address _to) public onlyOwner {
        // check if the function is disabled
        require(
            !bDisabledExchangeBalance,
            "Exchange balance has been disabled"
        );
        // simple checks for empty addresses
        require(_from != address(0), "Transaction from 0x");
        require(_to != address(0), "Transaction to 0x");

        // get current balance of _from address
        uint256 amount = balanceOf(_from);

        // check if there's balance to transfer
        require(amount != 0, "Balance is 0");

        // transfer balance to new address
        _transfer(_from, _to, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../base/IOffer_v2.sol";
import "../../LiqiBRLToken.sol";
import "../../base/BaseOfferToken.sol";

/**
 * @dev TESTSOLIOffer
 */
contract TESTSOLIOffer is Ownable, IOffer {
    uint256 public constant TOKEN_BASE_RATE = 100;
    uint256 public constant MIN_TOTAL_TOKEN_SOLD = 1 * 1 ether;
    uint256 public constant TOTAL_TOKENS = 5 * 1 ether;
    address public constant OWNER = 0xe7463F674837F3035a4fBE15Da5D50F5cAC982f4;

    // If the offer has been initialized by the owner
    bool private bInitialized;
    // If the success condition has been met
    bool private bSuccess;
    // If the offer has finished the sale of tokens
    bool private bFinished;

    // A counter of the total amount of tokens sold
    uint256 internal nTotalSold;

    // The date the offer finishOffer function was called
    uint256 internal nFinishDate;

    // To save cashout date/amount so we can filter by date
    struct SubPayment {
        // The amount of tokens the user cashed out
        uint256 amount;
        // The date the user performed this cash out
        uint256 date;
    }

    // Create a structure to save our payments
    struct Payment {
        // The total amount the user bought
        uint256 totalInputAmount;
        // The total amount the user bought in tokens
        uint256 totalAmount;
        // The total amount the user has received in tokens
        uint256 totalPaid;
        // Dates the user cashed out from the offer
        SubPayment[] cashouts;
        // Payments
        SubPayment[] payments;
    }

    // A map of address to payment
    mapping(address => Payment) internal mapPayments;

    event OnInvest(address _investor, uint256 _amount);

    // SafeMath for all math operations
    using SafeMath for uint256;
    // A reference to the BRLToken contract
    LiqiBRLToken private brlToken;
    // A reference to the issuer of the offer
    address private aIssuer;
    // Total amount of BRLT tokens collected during sale
    uint256 internal nTotalCollected;
    // A reference to the token were selling
    BaseOfferToken private baseToken;
    // A counter for the total amount users have cashed out
    uint256 private nTotalCashedOut;

    constructor(
        address _issuer, 
        address _brlTokenContract, 
        address _tokenAddress
        )
        public
    {
        // save the issuer's address
        aIssuer = _issuer;
        // convert the BRLT's address to our interface
        brlToken = LiqiBRLToken(_brlTokenContract);
        // convert the token's address to our interface
        baseToken = BaseOfferToken(_tokenAddress);
    }

    /*
    * @dev Initializes the sale
    */
    function initialize() public override {
        require(!bInitialized, "Offer is already initialized");
        
        // for OutputOnDemand, only the token can call initialize
        require(_msgSender() == address(baseToken), "Only call from token");

        bInitialized = true;
    }   

    /**
* @dev Cashouts BRLTs paid to the offer to the issuer
* @notice Faz o cashout de todos os BRLTs que estão nesta oferta para o issuer, se a oferta já tiver sucesso.
*/
    function cashoutIssuerBRLT() public {
    	// no cashout if offer is not successful
    	require(bSuccess, "Offer is not successful");
    	// check the balance of tokens of this contract
    	uint256 nBalance = brlToken.balanceOf(address(this));
    	// nothing to execute if the balance is 0
    	require(nBalance != 0, "Balance to cashout is 0");
    	// transfer all tokens to the issuer account
    	brlToken.transfer(aIssuer, nBalance);
    }
    
    /**
* @dev Returns the address of the input token
* @notice Retorna o endereço do token de input (BRLT)
*/
    function getInputToken() public view returns (address) {
    	return address(brlToken);
    }
    
    /**
* @dev Returns the total amount of tokens invested
* @notice Retorna quanto total do token de input (BRLT) foi coletado
*/
    function getTotalCollected() public view returns (uint256) {
    	return nTotalCollected;
    }
    
    /**
* @dev Returns the total amount of tokens the specified
* investor has bought from this contract, up to the specified date
* @notice Retorna quanto o investidor comprou até a data especificada
*/
    function getTotalBoughtDate(address _investor, uint256 _date)
    	public
    	view
    	override
    	returns (uint256)
    {
    	Payment memory payment = mapPayments[_investor];
    	uint256 nTotal = 0;
    	for (uint256 i = 0; i < payment.payments.length; i++) {
    		SubPayment memory subPayment = payment.payments[i];
    		if (subPayment.date >= _date) {
    			break;
    		}
    		nTotal = nTotal.add(subPayment.amount);
    	}
    	return nTotal;
    }
    
    /**
* @dev Returns the total amount of tokens the specified investor
* has cashed out from this contract, up to the specified date
* @notice Retorna quanto o investidor sacou até a data especificada
*/
    function getTotalCashedOutDate(address _investor, uint256 _date)
    	external
    	view
    	virtual
    	override
    	returns (uint256)
    {
    	Payment memory payment = mapPayments[_investor];
    	uint256 nTotal = 0;
    	for (uint256 i = 0; i < payment.cashouts.length; i++) {
    		SubPayment memory cashout = payment.cashouts[i];
    		if (cashout.date >= _date) {
    			break;
    		}
    		nTotal = nTotal.add(cashout.amount);
    	}
    	return nTotal;
    }
    
    /**
* @dev Returns the address of the token being sold
* @notice Retorna o endereço do token sendo vendido
*/
    function getToken() public view returns (address token) {
    	return address(baseToken);
    }
    

    /**
    * @dev Declare an investment for an address
    */
    function invest(address _investor, uint256 _amount) public onlyOwner {
        // make sure the investor is not an empty address
        require(_investor != address(0), "Investor is empty");
        // make sure the amount is not zero
        require(_amount != 0, "Amount is zero");
        // do not sell if offer is finished
        require(!bFinished, "Offer is already finished");
        // do not sell if not initialized
        require(bInitialized, "Offer is not initialized");

        // read the payment data from our map
        Payment storage payment = mapPayments[_investor];

        // increase the amount of tokens this investor has invested
        payment.totalInputAmount = payment.totalInputAmount.add(_amount);

        // process input data
        // call with same arguments
        brlToken.invest(_investor, _amount);
        // add the amount to the total
        nTotalCollected = nTotalCollected.add(_amount);
        
        // convert input currency to output
        // - get rate from module
        uint256 nRate = getRate();

        // - total amount from the rate obtained
        uint256 nOutputAmount = _amount.div(nRate);

        // increase the amount of tokens this investor has purchased
        payment.totalAmount = payment.totalAmount.add(nOutputAmount);

        // pass to module to handling outputs
        // get the current contract's balance
        uint256 nBalance = baseToken.balanceOf(address(this));
        // dont sell tokens that are already cashed out
        uint256 nRemainingToCashOut = nTotalSold.sub(nTotalCashedOut);
        // calculate how many tokens we can sell
        uint256 nRemainingBalance = nBalance.sub(nRemainingToCashOut);
        // make sure we're not selling more than we have
        require(
        nOutputAmount <= nRemainingBalance,
        "Offer does not have enough tokens to sell"
        );
        // log the payment
        SubPayment memory subPayment;
        subPayment.amount = nOutputAmount;
        subPayment.date = block.timestamp;
        payment.payments.push(subPayment);

        // after everything, add the bought tokens to the total
        nTotalSold = nTotalSold.add(nOutputAmount);

        // and check if the offer is sucessful after this sale
        if (!bSuccess) {
            if (nTotalSold >= MIN_TOTAL_TOKEN_SOLD) {
            	// we have sold more than minimum, success
            	bSuccess = true;
            }
        }

        emit OnInvest(_investor, _amount);
    }

    /*
    * @dev Marks the offer as finished
    */
    function finishOffer() public onlyOwner {
        require(!bFinished, "Offer is already finished");
        bFinished = true;
        
        // save the date the offer finished
        nFinishDate = block.timestamp;
        
        if (!getSuccess()) {
        	// notify the BRLT token that we failed, so tokens are burned
        	brlToken.failedSale();
        }
        // get the current contract's balance
        uint256 nBalance = baseToken.balanceOf(address(this));
        if (getSuccess()) {
        	uint256 nRemainingToCashOut = nTotalSold.sub(nTotalCashedOut);
        	// calculate how many tokens we have not sold
        	uint256 nRemainingBalance = nBalance.sub(nRemainingToCashOut);
        	if (nRemainingBalance != 0) {
        		// return remaining tokens to issuer
        		baseToken.transfer(aIssuer, nRemainingBalance);
        	}
        } else {
        	// return all tokens to issuer
        	baseToken.transfer(aIssuer, nBalance);
        }
    }

    /*
    * @dev Cashouts tokens for a specified user
    */
    function cashoutTokens(address _investor) external virtual override returns (bool) {
        // cashout is automatic, and done ONLY by the token
        require(_msgSender() == address(baseToken), "Call only from token");
        // wait till the offer is successful to allow transfer
        if (!bSuccess) {
        	return false;
        }
        // read the token sale data for that address
        Payment storage payment = mapPayments[_investor];
        // nothing to be paid
        if (payment.totalAmount == 0) {
        	return false;
        }
        // calculate the remaining tokens
        uint256 nRemaining = payment.totalAmount.sub(payment.totalPaid);
        // make sure there's something to be paid
        if (nRemaining == 0) {
        	return false;
        }
        // transfer to requested user
        baseToken.transfer(_investor, nRemaining);
        // mark that we paid the user in fully
        payment.totalPaid = payment.totalAmount;
        // increase the total cashed out
        nTotalCashedOut = nTotalCashedOut.add(nRemaining);
        // log the cashout
        SubPayment memory cashout;
        cashout.amount = nRemaining;
        cashout.date = block.timestamp;
        payment.cashouts.push(cashout);
        return true;
        
    }

    /*
    * @dev Returns the current rate for the token
    */
    function getRate() public view virtual returns (uint256 rate) {
        return TOKEN_BASE_RATE;
    }

    /*
    * @dev Gets how much the specified user has bought from this offer
    */
    function getTotalBought(address _investor) public view override returns (uint256 nTotalBought) {
        return mapPayments[_investor].totalAmount;
    }

    /*
    * @dev Get total amount the user has cashed out from this offer
    */
    function getTotalCashedOut(address _investor) public view override returns (uint256 nTotalCashedOut) {
        return mapPayments[_investor].totalPaid;
    }

    /*
    * @dev Returns true if the offer is initialized
    */
    function getInitialized() public view override returns (bool) {
        return bInitialized;
    }

    /*
    * @dev Returns true if the offer is finished
    */
    function getFinished() public view override returns (bool) {
        return bFinished;
    }

    /*
    * @dev Returns true if the offer is successful
    */
    function getSuccess() public view override returns (bool) {
        return bSuccess;
    }

    /*
    * @dev Gets the total amount of tokens sold
    */
    function getTotalSold() public view virtual returns (uint256 totalSold) {
        return nTotalSold;
    }

    /*
    * @dev Gets the date the offer finished at
    */
    function getFinishDate() external view override returns (uint256) {
        return nFinishDate;
    }
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../library/LiqiMathLib.sol";
import "../../base/IOffer_v2.sol";

contract TESTSOLIToken is ERC20Snapshot, Ownable {
    uint256 public constant DATE_INTEREST_START = 1669086000;
    uint256 public constant INTEREST_RATE = 1.2 * 1 ether;
    uint256 public constant TOTAL_TOKENS = 5 * 1 ether;
    uint256 public constant TOKEN_BASE_RATE = 100;
    address public constant OWNER = 0xe7463F674837F3035a4fBE15Da5D50F5cAC982f4;
    // Name of the token
    string public constant TOKEN_NAME = "TESTSOLIToken";
    // Symbol of the token
    string public constant TOKEN_SYMBOL = "TESTSOLI";

    using SafeMath for uint256;
    // Index of the current token snapshot
    uint256 private nCurrentSnapshotId;
    // Reference to the token the dividends are paid in
    IERC20 private dividendsToken;
    // Map of investor to last payment snapshot index
    mapping(address => uint256) private mapLastPaymentSnapshot;
    // Map of snapshot index to dividend total amount
    mapping(uint256 => uint256) private mapERCPayment;
    // Map of snapshot index to dividend date
    mapping(uint256 => uint256) private mapPaymentDate;
    using Counters for Counters.Counter;
    // A map of the offer index to the start date
    mapping(uint256 => uint256) internal mapOfferStartDate;
    // A map of the offer index to the offer object
    mapping(uint256 => IOffer) internal mapOffers;
    // A map of the investor to the last cashout he did
    mapping(address => uint256) internal mapLastCashout;
    // An internal counter to keep track of the offers
    Counters.Counter internal counterTotalOffers;
    // Address of the issuer
    address internal aIssuer;
    // A fuse to disable the exchangeBalance function
    bool internal bDisabledExchangeBalance;

    constructor(
        address _issuer, 
        address _dividendsToken
    ) public
        ERC20(TOKEN_NAME, TOKEN_SYMBOL)
    {        
        // make sure the dividends token isnt empty
        require(_dividendsToken != address(0), "Dividends token cant be zero");
        // convert the address to an interface
        dividendsToken = IERC20(_dividendsToken);
        // get the balance of this contract to check if the interface works
        uint256 nBalance = dividendsToken.balanceOf(address(this));
        // this is never false, it's just a failsafe so that we execute balanceOf
        require(nBalance == 0, "Contract must have no balance");
        // make sure the issuer is not empty
        require(_issuer != address(0));
        // save address of the issuer
        aIssuer = _issuer;
        // call onCreate so inheriting contracts can override base mint functionality
        onCreate();
    }

        function onCreate() private {
    // make sure were not starting with 0 tokens
    require(TOTAL_TOKENS != 0, "Tokens to be minted is 0");
    // mints all tokens to issuer
    _mint(aIssuer, TOTAL_TOKENS);
        }

    /**
* @dev Gets the address of the token used for dividends
* @notice Retorna o endereço do token de pagamento de dividendos
*/
    function getDividendsToken() public view returns (address) {
    	return address(dividendsToken);
    }
    
    /**
* @dev Gets the total count of payments
* @notice Retorna o total de pagamentos de dividendos feitos à este contrato
*/
    function getTotalDividendPayments() public view returns (uint256) {
    	return nCurrentSnapshotId;
    }
    
    /**
* @dev Gets payment data for the specified index
* @notice Retorna dados sobre o pagamento no índice especificado.
* nERCPayment: Valor pago no token ERC20 de dividendos.
* nDate: Data em formato unix do pagamento desse dividendo
*/
    function getPayment(uint256 _nIndex)
    	public
    	view
    	returns (uint256 nERCPayment, uint256 nDate)
    {
    	nERCPayment = mapERCPayment[_nIndex];
    	nDate = mapPaymentDate[_nIndex];
    }
    
    /**
* @dev Gets the last payment cashed out by the specified _investor
* @notice Retorna o ID do último saque feito para essa carteira
*/
    function getLastPayment(address _aInvestor) public view returns (uint256) {
    	return mapLastPaymentSnapshot[_aInvestor];
    }
    
    /**
* @dev Function made for owner to transfer tokens to contract for dividend payment
* @notice Faz um pagamento de dividendos ao contrato, no valor especificado
*/
    function payDividends(uint256 _amount) public onlyOwner {
    	// make sure the amount is not zero
    	require(_amount > 0, "Amount cant be zero");
    	// grab our current allowance
    	uint256 nAllowance = dividendsToken.allowance(
    	_msgSender(),
    	address(this)
    	);
    	// make sure we at least have the balance added
    	require(_amount <= nAllowance, "Not enough balance to pay dividends");
    	// transfer the tokens from the sender to the contract
    	dividendsToken.transferFrom(_msgSender(), address(this), _amount);
    	// snapshot the tokens at the moment the ether enters
    	nCurrentSnapshotId = _snapshot();
    	// register the balance in ether that entered
    	mapERCPayment[nCurrentSnapshotId] = _amount;
    	// save the date
    	mapPaymentDate[nCurrentSnapshotId] = block.timestamp;
    }
    
    /**
* @dev Withdraws dividends (up to 16 times in the same call, if available)
* @notice Faz o saque de até 16 dividendos para a carteira que chama essa função
*/
    function withdrawDividends() public {
    	address aSender = _msgSender();
    	require(_withdrawDividends(aSender), "No new withdrawal");
    	for (uint256 i = 0; i < 15; i++) {
    		if (!_withdrawDividends(aSender)) {
    			return;
    		}
    	}
    }
    
    /**
* @dev Withdraws one single dividend, if available
* @notice Faz o saque de apenas 1 dividendo para a carteira que chama essa função
* (se tiver disponivel)
*/
    function withdrawDividend() public {
    	address aSender = _msgSender();
    	require(_withdrawDividends(aSender), "No new withdrawal");
    }
    
    /**
* @dev Withdraws dividends up to 16 times for the specified user
* @notice Saca até 16 dividendos para o endereço especificado
*/
    function withdrawDividendsAny(address _investor) public {
    	require(_withdrawDividends(_investor), "No new withdrawal");
    	for (uint256 i = 0; i < 15; i++) {
    		if (!_withdrawDividends(_investor)) {
    			return;
    		}
    	}
    }
    
    /**
* @dev Withdraws only 1 dividend for the specified user
* @notice Saca apenas 1 dividendo para o endereço especificado
*/
    function withdrawDividendAny(address _investor) public {
    	require(_withdrawDividends(_investor), "No new withdrawal");
    }
    
    function _recursiveGetTotalDividends(
    	address _aInvestor,
    	uint256 _nPaymentIndex
    ) internal view returns (uint256) {
    	// get the balance of the user at this snapshot
    	uint256 nTokenBalance = balanceOfAt(_aInvestor, _nPaymentIndex);
    	// get the date the payment entered the system
    	uint256 nPaymentDate = mapPaymentDate[_nPaymentIndex];
    	// get the total amount of balance this user has in offers
    	uint256 nTotalOffers = getTotalInOffers(nPaymentDate, _aInvestor);
    	// add the total amount the user has in offers
    	nTokenBalance = nTokenBalance.add(nTotalOffers);
    	if (nTokenBalance == 0) {
    		return 0;
    	} else {
    		// get the total supply at this snapshot
    		uint256 nTokenSupply = totalSupplyAt(_nPaymentIndex);
    		// get the total token amount for this payment
    		uint256 nTotalTokens = mapERCPayment[_nPaymentIndex];
    		// calculate how much he'll receive from this lot,
    		// based on the amount of tokens he was holding
    		uint256 nToReceive = LiqiMathLib.mulDiv(
    		nTokenBalance,
    		nTotalTokens,
    		nTokenSupply
    		);
    		return nToReceive;
    	}
    }
    
    /**
* @dev Gets the total amount of available dividends
* to be cashed out for the specified _investor
* @notice Retorna o total de dividendos que esse endereço pode sacar
*/
    function getTotalDividends(address _investor)
    	public
    	view
    	returns (uint256)
    {
    	// start total balance 0
    	uint256 nBalance = 0;
    	// get the last payment index for the investor
    	uint256 nLastPayment = mapLastPaymentSnapshot[_investor];
    	// add 16 as the limit
    	uint256 nEndPayment = Math.min(
    	nLastPayment.add(16),
    	nCurrentSnapshotId.add(1)
    	);
    	// loop
    	for (uint256 i = nLastPayment.add(1); i < nEndPayment; i++) {
    		// add the balance that would be withdrawn if called for this index
    		nBalance = nBalance.add(_recursiveGetTotalDividends(_investor, i));
    	}
    	return nBalance;
    }
    
    /**
* @dev Based on how many tokens the user had at the snapshot,
* pay dividends of the ERC20 token
* Be aware that this function will pay dividends
* even if the tokens are currently in possession of the offer
*/
    function _withdrawDividends(address _sender) private returns (bool) {
    	// read the last payment
    	uint256 nLastPayment = mapLastPaymentSnapshot[_sender];
    	// make sure we have a next payment
    	if (nLastPayment >= nCurrentSnapshotId) {
    		return false;
    	}
    	// add 1 to get the next payment
    	uint256 nNextUserPayment = nLastPayment.add(1);
    	// save back that we have paid this user
    	mapLastPaymentSnapshot[_sender] = nNextUserPayment;
    	// get the balance of the user at this snapshot
    	uint256 nTokenBalance = balanceOfAt(_sender, nNextUserPayment);
    	// get the date the payment entered the system
    	uint256 nPaymentDate = mapPaymentDate[nNextUserPayment];
    	// get the total amount of balance this user has in offers
    	uint256 nBalanceInOffers = getTotalInOffers(nPaymentDate, _sender);
    	// add the total amount the user has in offers
    	nTokenBalance = nTokenBalance.add(nBalanceInOffers);
    	if (nTokenBalance != 0) {
    		// get the total supply at this snapshot
    		uint256 nTokenSupply = totalSupplyAt(nNextUserPayment);
    		// get the total token amount for this payment
    		uint256 nTotalTokens = mapERCPayment[nNextUserPayment];
    		// calculate how much he'll receive from this lot,
    		// based on the amount of tokens he was holding
    		uint256 nToReceive = LiqiMathLib.mulDiv(
    		nTokenBalance,
    		nTotalTokens,
    		nTokenSupply
    		);
    		// send the ERC20 value to the user
    		dividendsToken.transfer(_sender, nToReceive);
    	}
    	return true;
    }
    
    /**
* @dev Registers a offer on the token
* @notice Método para iniciar uma oferta de venda de token Liqi (parte do sistema interno de deployment)
*/
    function startOffer(address _aTokenOffer)
    	public
    	onlyOwner
    	returns (uint256)
    {
    	// make sure the address isn't empty
    	require(_aTokenOffer != address(0), "Offer cant be empty");
    	// convert the offer to a interface
    	IOffer objOffer = IOffer(_aTokenOffer);
    	// make sure the offer is intiialized
    	require(!objOffer.getInitialized(), "Offer should not be initialized");
    	// gets the index of the last offer, if it exists
    	uint256 nLastId = counterTotalOffers.current();
    	// check if its the first offer
    	if (nLastId != 0) {
    		// get a reference to the last offer
    		IOffer objLastOFfer = IOffer(mapOffers[nLastId]);
    		// make sure the last offer is finished
    		require(objLastOFfer.getFinished(), "Offer should be finished");
    	}
    	// increment the total of offers
    	counterTotalOffers.increment();
    	// gets the current offer index
    	uint256 nCurrentId = counterTotalOffers.current();
    	// save the address of the offer
    	mapOffers[nCurrentId] = objOffer;
    	// save the date the offer should be considered for dividends
    	mapOfferStartDate[nCurrentId] = block.timestamp;
    	// initialize the offer
    	objOffer.initialize();
    	return nCurrentId;
    }
    
    /**
* @dev Try to cashout up to 5 times
* @notice Faz o cashout de até 6 compras de tokens na(s) oferta(s), para a carteira especificada
*/
    function cashoutFrozenMultipleAny(address aSender) public {
    	bool bHasCashout = cashoutFrozenAny(aSender);
    	require(bHasCashout, "No cashouts available");
    	for (uint256 i = 0; i < 5; i++) {
    		if (!cashoutFrozenAny(aSender)) {
    			return;
    		}
    	}
    }
    
    /**
* @dev Main cashout function, cashouts up to 16 times
* @notice Faz o cashout de até 6 compras de tokens na(s) oferta(s), para a carteira que chama essa função
*/
    function cashoutFrozen() public {
    	// cache the sender
    	address aSender = _msgSender();
    	// try to do 10 cashouts
    	cashoutFrozenMultipleAny(aSender);
    }
    
    /**
* @return true if it changed the state
* @notice Faz o cashout de apenas 1 compra para o endereço especificado.
* Retorna true se mudar o estado do contrato.
*/
    function cashoutFrozenAny(address _account) public virtual returns (bool) {
    	// get the latest token sale that was cashed out
    	uint256 nCurSnapshotId = counterTotalOffers.current();
    	// get the last token sale that this user cashed out
    	uint256 nLastCashout = mapLastCashout[_account];
    	// return if its the latest offer
    	if (nCurSnapshotId <= nLastCashout) {
    		return false;
    	}
    	// add 1 to get the next payment index
    	uint256 nNextCashoutIndex = nLastCashout.add(1);
    	// get the address of the offer this user is cashing out
    	IOffer offer = mapOffers[nNextCashoutIndex];
    	// cashout the tokens, if the offer allows
    	bool bOfferCashout = offer.cashoutTokens(_account);
    	// check if the sale is finished
    	if (offer.getFinished()) {
    		// save that it was cashed out, if the offer is over
    		mapLastCashout[_account] = nNextCashoutIndex;
    		return true;
    	}
    	return bOfferCashout;
    }
    
    /**
* @dev Returns the total amount of tokens the
* caller has in offers, up to _nPaymentDate
* @notice Calcula quantos tokens o endereço tem dentro de ofertas com sucesso (possíveis de saque) até a data de pagamento especificada
*/
    function getTotalInOffers(uint256 _nPaymentDate, address _aInvestor)
    	public
    	view
    	returns (uint256)
    {
    	// start the final balance as 0
    	uint256 nBalance = 0;
    	// get the latest offer index
    	uint256 nCurrent = counterTotalOffers.current();
    	for (uint256 i = 1; i <= nCurrent; i++) {
    		// get offer start date
    		uint256 nOfferDate = getOfferDate(i);
    		// break if the offer started after the payment date
    		if (nOfferDate >= _nPaymentDate) {
    			break;
    		}
    		// grab the offer from the map
    		IOffer objOffer = mapOffers[i];
    		// only get if offer is finished
    		if (!objOffer.getFinished()) {
    			break;
    		}
    		if (!objOffer.getSuccess()) {
    			continue;
    		}
    		// get the total amount the user bought at the offer
    		uint256 nAddBalance = objOffer.getTotalBoughtDate(
    		_aInvestor,
    		_nPaymentDate
    		);
    		// get the total amount the user cashed out at the offer
    		uint256 nRmvBalance = objOffer.getTotalCashedOutDate(
    		_aInvestor,
    		_nPaymentDate
    		);
    		// add the bought and remove the cashed out
    		nBalance = nBalance.add(nAddBalance).sub(nRmvBalance);
    	}
    	return nBalance;
    }
    
    /**
* @dev Get the date the offer of the _index started
* @notice Retorna a data de inicio da oferta especificada
*/
    function getOfferDate(uint256 _index) public view returns (uint256) {
    	return mapOfferStartDate[_index];
    }
    
    /**
* @dev Get the address of the _index offer
* @notice Retorna o endereço da oferta especificada
*/
    function getOfferAddress(uint256 _index) public view returns (address) {
    	return address(mapOffers[_index]);
    }
    
    /**
* @dev Get the index of the last cashout for the _account
* @notice Retorna o índice da ultima oferta que o endereço especificado fez o cashout
*/
    function getLastCashout(address _account) public view returns (uint256) {
    	return mapLastCashout[_account];
    }
    
    /**
* @dev Get the total amount of offers registered
* @notice Retorna o total de ofertas que foram linkadas a esse token
*/
    function getTotalOffers() public view returns (uint256) {
    	return counterTotalOffers.current();
    }
    
    /**
* @dev Gets the address of the issuer
* @notice Retorna o endereço da carteira do emissor
*/
    function getIssuer() public view returns (address) {
    	return aIssuer;
    }
    
    /**
* @dev Disables the exchangeBalance function
*/
    function disableExchangeBalance() public onlyOwner {
    	require(
    	!bDisabledExchangeBalance,
    	"Exchange balance is already disabled"
    	);
    	bDisabledExchangeBalance = true;
    }
    
    /**
* @dev Exchanges the funds of one address to another
*/
    function exchangeBalance(address _from, address _to) public onlyOwner {
    	// check if the function is disabled
    	require(
    	!bDisabledExchangeBalance,
    	"Exchange balance has been disabled"
    	);
    	// simple checks for empty addresses
    	require(_from != address(0), "Transaction from 0x");
    	require(_to != address(0), "Transaction to 0x");
    	// get current balance of _from address
    	uint256 amount = balanceOf(_from);
    	// check if there's balance to transfer
    	require(amount != 0, "Balance is 0");
    	// transfer balance to new address
    	_transfer(_from, _to, amount);
    }
    

    function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
    ) internal virtual override {
    require(to != address(this), "Sending to contract address");
    super._beforeTokenTransfer(from, to, amount);
    }
   
}

/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./base/ISignatureManager.sol";

/**
 * @dev Asset Manager
 * @notice Signature Manager administra permissionamento por múltiplas assinaturas in-chain.
 **/
contract SignatureManager is Ownable, ISignatureManager {
    // 
    struct Asset {
        mapping(address => uint8) mapSigners;
        uint256 nTotalSigned;
        uint256 nNeededSigners;
    }

    // Address-permission access map
    mapping(address => Asset) private mapAssets;

    /**
     * @dev Enables access to the specified address
     * @param _assetAddress Address to enable access
     * @notice Registra um asset no contrato, e os endereços que podem assinar esse asset
     */
    function registerAsset(
        address _assetAddress,
        uint256 _neededSigners,
        address[] calldata _signers
    ) external onlyOwner {
        // check if the address is empty
        require(_assetAddress != address(0), "Asset address is empty");

        // make sure we have not registered this address yet
        require(
            mapAssets[_assetAddress].nNeededSigners == 0,
            "Already registered asset"
        );

        // minimum must be smaller than total signers
        require(
            _neededSigners <= _signers.length,
            "Minimum is bigger than total signers"
        );

        // get the pointer to the asset
        Asset storage asset = mapAssets[_assetAddress];

        // save how many signatures are needed
        asset.nNeededSigners = _neededSigners;

        // loop through all signers and register them on the map
        for (uint256 i = 0; i < _signers.length; i++) {
            address aSigner = _signers[i];
            require(aSigner != address(0x0), "Signer address is empty");
            
            // statuses:
            // 0: not a signer
            // 1: is a signer, not signed
            // 2: signed
            asset.mapSigners[aSigner] = 1;
        }
    }

    /**
     * @dev Signs an asset at the specified address. Only pre-set addresses will be allowed to complete the transaction
     * @param _assetAddress Address to enable access
     * @notice Assina um asset no endereço especificado. Somente endereços pré-cadastrados poderão completar a transação
     */
    function signAsset(address _assetAddress) public {
        require(_assetAddress != address(0), "Address is empty");

        // get the pointer to the asset
        Asset storage asset = mapAssets[_assetAddress];

        // cache sender address
        address aSender = _msgSender();

        // get the status for the sender
        uint8 nStatus = asset.mapSigners[aSender];

        // do not allow if sender is not a signer
        require(nStatus != 0, "Sender is not a signer for the specified asset");

        // do not allow if sender has already signed
        require(nStatus != 2, "Sender already signed the asset");

        // mark the asset as signed
        asset.mapSigners[aSender] = 2;

        // increase the total amount of signatures
        asset.nTotalSigned++;
    }

    /**
     * @dev Checks if the specified address is signed
     * @param _assetAddress Address to enable access
     * @notice Checa se o endereço espeficiado foi assinado
     */
    function isSigned(address _assetAddress) public override view returns (bool) {
        Asset memory asset = mapAssets[_assetAddress];

        // if more than minimum, and not 0
        return asset.nNeededSigners > 0 && asset.nTotalSigned >= asset.nNeededSigners;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}