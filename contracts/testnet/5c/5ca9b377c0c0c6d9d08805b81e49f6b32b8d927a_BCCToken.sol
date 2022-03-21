/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

pragma solidity 0.5.17;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
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
 * For a generic mechanism see {ERC20Mintable}.
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

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

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
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

/**
 * @dev Extension of {ERC20} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

/**
 * @dev Extension of {ERC20Mintable} that adds a cap to the supply of tokens.
 */
contract ERC20Capped is ERC20Mintable {
    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20Mintable-mint}.
     *
     * Requirements:
     *
     * - `value` must not cause the total supply to go over the cap.
     */
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}

contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/**
 * @title Pausable token
 * @dev ERC20 with pausable transfers and allowances.
 *
 * Useful if you want to stop trades until the end of a crowdsale, or have
 * an emergency switch for freezing all token transfers in the event of a large
 * bug.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BCCToken is ERC20, ERC20Detailed, ERC20Capped, ERC20Burnable, Ownable {

    address StrategicPrivateSale = 0x893064cA1550c9ceD53E85e24A72679f59385B07;
    address Liquidity = 0x893064cA1550c9ceD53E85e24A72679f59385B07;
    address Marketing = 0x4FA89AE1609B414b91c10925DC68cED8C8202208;
    address Team = 0xA2B7b5aF1f704685F8A5Cc1A9dEAB5AD194Ecb06;

    struct LockTime {
        uint256  releaseDate;
        uint256  amount;
    }

    mapping (address => LockTime[]) public lockList;
    mapping (uint => uint) public MarketingLockMap;
    mapping (uint => uint) public TeamLockMap;

    struct Investor {
        address  wallet;
        uint256  amount;
    }

    uint8 private _d = 18;
    uint256 private totalTokens = 300000000 * 10 ** uint256(_d);

    address [] private lockedAddressList;

    constructor() public ERC20Detailed("Bitback Coin", "BBC", _d) ERC20Capped(totalTokens) {
        _mint(StrategicPrivateSale, 60000000 * 10 ** uint256(_d));
        _mint(Liquidity, 30000000 * 10 ** uint256(_d));
        _mint(Team, 39000000 * 10 ** uint256(_d));
        _mint(Marketing, 36000000 * 10 ** uint256(_d));
        lockWallets();
    }

    function transfer(address _receiver, uint256 _amount) public returns (bool success) {
        require(_receiver != address(0));
        require(_amount <= getAvailableBalance(msg.sender));
        return ERC20.transfer(_receiver, _amount);
    }

    function transferFrom(address _from, address _receiver, uint256 _amount) public returns (bool) {
        require(_from != address(0));
        require(_receiver != address(0));
        require(_amount <= allowance(_from, msg.sender));
        require(_amount <= getAvailableBalance(_from));
        return ERC20.transferFrom(_from, _receiver, _amount);
    }

    function transferWithLock(address _receiver, uint256 _amount, uint256 _releaseDate) public returns (bool success) {
        require(msg.sender == owner());
        ERC20._transfer(msg.sender,_receiver,_amount);

        if (lockList[_receiver].length==0) lockedAddressList.push(_receiver);

        LockTime memory item = LockTime({amount:_amount, releaseDate:_releaseDate});
        lockList[_receiver].push(item);

        return true;
    }

    function getLockedAmount(address lockedAddress) public view returns (uint256 _amount) {
        uint256 lockedAmount =0;
        for(uint256 j = 0; j<lockList[lockedAddress].length; j++) {
            if(now < lockList[lockedAddress][j].releaseDate) {
                uint256 temp = lockList[lockedAddress][j].amount;
                lockedAmount += temp;
            }
        }
        return lockedAmount;
    }

    function getAvailableBalance(address lockedAddress) public view returns (uint256 _amount) {
        uint256 bal = balanceOf(lockedAddress);
        uint256 locked = getLockedAmount(lockedAddress);
        return bal.sub(locked);
    }

    function getLockedAddresses() public view returns (address[] memory) {
        return lockedAddressList;
    }

    function getNumberOfLockedAddresses() public view returns (uint256 _count) {
        return lockedAddressList.length;
    }

    function getNumberOfLockedAddressesCurrently() public view returns (uint256 _count) {
        uint256 count=0;
        for(uint256 i = 0; i<lockedAddressList.length; i++) {
            if (getLockedAmount(lockedAddressList[i])>0) count++;
        }
        return count;
    }

    function getLockedAddressesCurrently() public view returns (address[] memory) {
        address [] memory list = new address[](getNumberOfLockedAddressesCurrently());
        uint256 j = 0;
        for(uint256 i = 0; i<lockedAddressList.length; i++) {
            if (getLockedAmount(lockedAddressList[i])>0) {
                list[j] = lockedAddressList[i];
                j++;
            }
        }

        return list;
    }

    function getLockedAmountTotal() public view returns (uint256 _amount) {
        uint256 sum =0;
        for(uint256 i = 0; i<lockedAddressList.length; i++) {
            uint256 lockedAmount = getLockedAmount(lockedAddressList[i]);
            sum = sum.add(lockedAmount);
        }
        return sum;
    }

    function getCirculatingSupplyTotal() public view returns (uint256 _amount) {
        return totalSupply().sub(getLockedAmountTotal());
    }

    function burn(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }

    function updateLockList(address _receiver, uint256 _amount, uint256 _releaseDate) internal returns (bool success) {
        require(msg.sender == owner());

        if (lockList[_receiver].length==0) lockedAddressList.push(_receiver);

        LockTime memory item = LockTime({amount:_amount, releaseDate:_releaseDate});
        lockList[_receiver].push(item);

        return true;
    }

    function lockWallets () internal returns (bool success) {

        TeamLockMap[1]=1679961600; // 2023-03-28T00:00:00Z
        TeamLockMap[2]=1682640000; // 2023-04-28T00:00:00Z
        TeamLockMap[3]=1685232000; // 2023-05-28T00:00:00Z
        TeamLockMap[4]=1687910400; // 2023-06-28T00:00:00Z
        TeamLockMap[5]=1690502400; // 2023-07-28T00:00:00Z
        TeamLockMap[6]=1693180800; // 2023-08-28T00:00:00Z
        TeamLockMap[7]=1695859200; // 2023-09-28T00:00:00Z
        TeamLockMap[8]=1698451200; // 2023-10-28T00:00:00Z
        TeamLockMap[9]=1701129600; // 2023-11-28T00:00:00Z
        TeamLockMap[10]=1703721600; // 2023-12-28T00:00:00Z
        TeamLockMap[11]=1706400000; // 2024-01-28T00:00:00Z
        TeamLockMap[12]=1709078400; // 2024-02-28T00:00:00Z
        TeamLockMap[13]=1711584000; // 2024-03-28T00:00:00Z
        TeamLockMap[14]=1714262400; // 2024-04-28T00:00:00Z
        TeamLockMap[15]=1716854400; // 2024-05-28T00:00:00Z
        TeamLockMap[16]=1719532800; // 2024-06-28T00:00:00Z
        TeamLockMap[17]=1722124800; // 2024-07-28T00:00:00Z
        TeamLockMap[18]=1724803200; // 2024-08-28T00:00:00Z
        TeamLockMap[19]=1727481600; // 2024-09-28T00:00:00Z
        TeamLockMap[20]=1730073600; // 2024-10-28T00:00:00Z
        TeamLockMap[21]=1732752000; // 2024-11-28T00:00:00Z
        TeamLockMap[22]=1735344000; // 2024-12-28T00:00:00Z
        TeamLockMap[23]=1738022400; // 2025-01-28T00:00:00Z
        TeamLockMap[24]=1740700800; // 2025-02-28T00:00:00Z
        TeamLockMap[25]=1743120000; // 2025-03-28T00:00:00Z
        TeamLockMap[26]=1745798400; // 2025-04-28T00:00:00Z
        TeamLockMap[27]=1748390400; // 2025-05-28T00:00:00Z
        TeamLockMap[28]=1751068800; // 2025-06-28T00:00:00Z
        TeamLockMap[29]=1753660800; // 2025-07-28T00:00:00Z
        TeamLockMap[30]=1756339200; // 2025-08-28T00:00:00Z
        TeamLockMap[31]=1759017600; // 2025-09-28T00:00:00Z
        TeamLockMap[32]=1761609600; // 2025-10-28T00:00:00Z
        TeamLockMap[33]=1764288000; // 2025-11-28T00:00:00Z
        TeamLockMap[34]=1766880000; // 2025-12-28T00:00:00Z
        TeamLockMap[35]=1769558400; // 2026-01-28T00:00:00Z
        TeamLockMap[36]=1772236800; // 2026-02-28T00:00:00Z
        TeamLockMap[37]=1774656000; // 2026-03-28T00:00:00Z
        TeamLockMap[38]=1777334400; // 2026-04-28T00:00:00Z
        TeamLockMap[39]=1779926400; // 2026-05-28T00:00:00Z
        TeamLockMap[40]=1782604800; // 2026-06-28T00:00:00Z
        TeamLockMap[41]=1785196800; // 2026-07-28T00:00:00Z
        TeamLockMap[42]=1787875200; // 2026-08-28T00:00:00Z
        TeamLockMap[43]=1790553600; // 2026-09-28T00:00:00Z
        TeamLockMap[44]=1793145600; // 2026-10-28T00:00:00Z
        TeamLockMap[45]=1795824000; // 2026-11-28T00:00:00Z
        TeamLockMap[46]=1798416000; // 2026-12-28T00:00:00Z
        TeamLockMap[47]=1801094400; // 2027-01-28T00:00:00Z
        TeamLockMap[48]=1803772800; // 2027-02-28T00:00:00Z
        TeamLockMap[49]=1806192000; // 2027-03-28T00:00:00Z
        TeamLockMap[50]=1808870400; // 2027-04-28T00:00:00Z

        MarketingLockMap[1]=1649030400; // 2022-04-04T00:00:00Z
        MarketingLockMap[2]=1651622400; // 2022-05-04T00:00:00Z
        MarketingLockMap[3]=1654300800; // 2022-06-04T00:00:00Z
        MarketingLockMap[4]=1656892800; // 2022-07-04T00:00:00Z
        MarketingLockMap[5]=1659571200; // 2022-08-04T00:00:00Z
        MarketingLockMap[6]=1662249600; // 2022-09-04T00:00:00Z
        MarketingLockMap[7]=1664841600; // 2022-10-04T00:00:00Z
        MarketingLockMap[8]=1667520000; // 2022-11-04T00:00:00Z
        MarketingLockMap[9]=1670112000; // 2022-12-04T00:00:00Z
        MarketingLockMap[10]=1672790400; // 2023-01-04T00:00:00Z
        MarketingLockMap[11]=1675468800; // 2023-02-04T00:00:00Z
        MarketingLockMap[12]=1677888000; // 2023-03-04T00:00:00Z
        MarketingLockMap[13]=1680566400; // 2023-04-04T00:00:00Z
        MarketingLockMap[14]=1683158400; // 2023-05-04T00:00:00Z
        MarketingLockMap[15]=1685836800; // 2023-06-04T00:00:00Z
        MarketingLockMap[16]=1688428800; // 2023-07-04T00:00:00Z
        MarketingLockMap[17]=1691107200; // 2023-08-04T00:00:00Z
        MarketingLockMap[18]=1693785600; // 2023-09-04T00:00:00Z
        MarketingLockMap[19]=1696377600; // 2023-10-04T00:00:00Z
        MarketingLockMap[20]=1699056000; // 2023-11-04T00:00:00Z
        MarketingLockMap[21]=1701648000; // 2023-12-04T00:00:00Z
        MarketingLockMap[22]=1704326400; // 2024-01-04T00:00:00Z
        MarketingLockMap[23]=1707004800; // 2024-02-04T00:00:00Z
        MarketingLockMap[24]=1709510400; // 2024-03-04T00:00:00Z
        MarketingLockMap[25]=1712188800; // 2024-04-04T00:00:00Z
        MarketingLockMap[26]=1714780800; // 2024-05-04T00:00:00Z
        MarketingLockMap[27]=1717459200; // 2024-06-04T00:00:00Z
        MarketingLockMap[28]=1720051200; // 2024-07-04T00:00:00Z
        MarketingLockMap[29]=1722729600; // 2024-08-04T00:00:00Z
        MarketingLockMap[30]=1725408000; // 2024-09-04T00:00:00Z
        MarketingLockMap[31]=1728000000; // 2024-10-04T00:00:00Z
        MarketingLockMap[32]=1730678400; // 2024-11-04T00:00:00Z
        MarketingLockMap[33]=1733270400; // 2024-12-04T00:00:00Z
        MarketingLockMap[34]=1735948800; // 2025-01-04T00:00:00Z
        MarketingLockMap[35]=1738627200; // 2025-02-04T00:00:00Z
        MarketingLockMap[36]=1741046400; // 2025-03-04T00:00:00Z
        MarketingLockMap[37]=1743724800; // 2025-04-04T00:00:00Z
        MarketingLockMap[38]=1746316800; // 2025-05-04T00:00:00Z
        MarketingLockMap[39]=1748995200; // 2025-06-04T00:00:00Z
        MarketingLockMap[40]=1751587200; // 2025-07-04T00:00:00Z
        MarketingLockMap[41]=1754265600; // 2025-08-04T00:00:00Z
        MarketingLockMap[42]=1756944000; // 2025-09-04T00:00:00Z
        MarketingLockMap[43]=1759536000; // 2025-10-04T00:00:00Z
        MarketingLockMap[44]=1762214400; // 2025-11-04T00:00:00Z
        MarketingLockMap[45]=1764806400; // 2025-12-04T00:00:00Z
        MarketingLockMap[46]=1767484800; // 2026-01-04T00:00:00Z
        MarketingLockMap[47]=1770163200; // 2026-02-04T00:00:00Z
        MarketingLockMap[48]=1772582400; // 2026-03-04T00:00:00Z
        MarketingLockMap[49]=1775260800; // 2026-04-04T00:00:00Z

        for(uint i = 1; i <= 50; i++) {
            updateLockList(Team, 780000 * 10 ** uint256(decimals()), TeamLockMap[i]);
        }

        updateLockList(Marketing, 1800000 * 10 ** uint256(decimals()), MarketingLockMap[1]);
        for(uint i = 2; i <= 48; i++) {
            updateLockList(Marketing, 720000 * 10 ** uint256(decimals()), MarketingLockMap[i]);
        }
        updateLockList(Marketing, 360000 * 10 ** uint256(decimals()), MarketingLockMap[49]);

        return true;
    }

    function () payable external {
        revert();
    }

}