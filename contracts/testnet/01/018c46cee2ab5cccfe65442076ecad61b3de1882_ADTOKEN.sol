/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

// File @openzeppelin/contracts/token/ERC20/[email protected]

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

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

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

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
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

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

        _totalSupply += amount;
        _balances[account] += amount;
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

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

// File @openzeppelin/contracts/security/[email protected]

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

// @author Razzor https://twitter.com/razzor_tweet
/**
 * @dev Contract defines a 2-step Access Control for the owner of the contract in order
 * to avoid risks. Such as accidentally transferring control to an undesired address or renouncing ownership.
 * The contracts mitigates these risks by using a 2-step process for ownership transfers and a time margin
 * to renounce ownership. The owner can propose the ownership to the new owner, and the pending owner can accept
 * the ownership in order to become the new owner. If an undesired address has been passed accidentally, Owner
 * can propose the ownership again to the new desired address, thus mitigating the risk of losing control immediately.
 * Also, an owner can choose to retain ownership if renounced accidentally prior to future renounce time.
 * The Owner can choose not to have this feature of time margin while renouncing ownership, by initialising _renounceInterval as 0.
 */
abstract contract SafeOwn {
    bool private isRenounced;
    address private _Owner;
    address private _pendingOwner;
    uint256 private _renounceTime;
    uint256 private _renounceInterval;

    /**
     * @dev Emitted when the Ownership is transferred or renounced. AtTime may hold
     * a future time value, if there exists a _renounceInterval > 0 for renounceOwnership transaction.
     */
    event ownershipTransferred(
        address indexed currentOwner,
        address indexed newOwner,
        uint256 indexed AtTime
    );
    /**
     * @dev Emitted when the Ownership is retained by the current Owner.
     */
    event ownershipRetained(address indexed currentOwner, uint256 indexed At);

    /**
     * @notice Initializes the Deployer as the Owner of the contract.
     * @param renounceInterval time in seconds after which the Owner will be removed.
     */

    constructor(uint256 renounceInterval) {
        _Owner = msg.sender;
        _renounceInterval = renounceInterval;
        emit ownershipTransferred(address(0), _Owner, block.timestamp);
    }

    /**
     * @notice Throws if the caller is not the Owner.
     */

    modifier onlyOwner() {
        require(Owner() == msg.sender, "SafeOwn: Caller is the not the Owner");
        _;
    }

    /**
     * @notice Throws if the caller is not the Pending Owner.
     */

    modifier onlyPendingOwner() {
        require(
            _pendingOwner == msg.sender,
            "SafeOwn: Caller is the not the Pending Owner"
        );
        _;
    }

    /**
     * @notice Returns the current Owner.
     * @dev returns zero address after renounce time, if the Ownership is renounced.
     */

    function Owner() public view virtual returns (address) {
        if (block.timestamp >= _renounceTime && isRenounced) {
            return address(0);
        } else {
            return _Owner;
        }
    }

    /**
     * @notice Returns the Pending Owner.
     */

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @notice Returns the renounce parameters.
     * @return bool value determining whether Owner has called renounceOwnership or not.
     * @return Renounce Interval in seconds after which the Ownership will be renounced.
     * @return Renounce Time at which the Ownership was/will be renounced. 0 if Ownership retains.
     */
    function renounceParams()
        public
        view
        virtual
        returns (
            bool,
            uint256,
            uint256
        )
    {
        return (isRenounced, _renounceInterval, _renounceTime);
    }

    /**
     * @notice Owner can propose ownership to a new Owner(newOwner).
     * @dev Owner can not propose ownership, if it has called renounceOwnership and
     * not retained the ownership yet.
     * @param newOwner address of the new owner to propose ownership to.
     */
    function proposeOwnership(address newOwner) public virtual onlyOwner {
        require(!isRenounced, "SafeOwn: Ownership has been Renounced");
        require(
            newOwner != address(0),
            "SafeOwn: New Owner can not be a Zero Address"
        );
        _pendingOwner = newOwner;
    }

    /**
     * @notice Pending Owner can accept the ownership proposal and become the new Owner.
     */
    function acceptOwnership() public virtual onlyPendingOwner {
        address currentOwner = _Owner;
        address newOwner = _pendingOwner;
        _Owner = _pendingOwner;
        _pendingOwner = address(0);
        emit ownershipTransferred(currentOwner, newOwner, block.timestamp);
    }

    /**
     * @notice Owner can renounce ownership. Owner will be removed from the
     * contract after _renounceTime.
     * @dev Owner will be immediately removed if the _renounceInterval is 0.
     * @dev Pending Owner will be immediately removed.
     */
    function renounceOwnership() public virtual onlyOwner {
        require(!isRenounced, "SafeOwn: Already Renounced");
        if (_pendingOwner != address(0)) {
            _pendingOwner = address(0);
        }
        _renounceTime = block.timestamp + _renounceInterval;
        isRenounced = true;
        emit ownershipTransferred(_Owner, address(0), _renounceTime);
    }

    /**
     * @notice Owner can retain its ownership and cancel the renouncing(if initiated
     * by Owner).
     */

    function retainOwnership() public virtual onlyOwner {
        require(isRenounced, "SafeOwn: Already Retained");
        _renounceTime = 0;
        isRenounced = false;
        emit ownershipRetained(_Owner, block.timestamp);
    }
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// File contracts/AdToken.sol

contract ADTOKEN is ERC20, Pausable, SafeOwn {
    /**
     * @dev taxFeePercentage
     */
    uint256 public taxFeePercentage = 5;

    /**
     * @dev buyFeePercentage
     */
    uint256 public buyFeePercentage = 2;

    /**
     * @dev sellFeePercentage
     */
    uint256 public sellFeePercentage = 2;

    /**
     * @dev taxBalance
     */
    uint256 public totalTaxBalance = 0;

    /**
     * @dev Reasons why a user's tokens have been locked
     */
    mapping(address => bytes32[]) public lockReason;

    /**
     * @dev mapping of DEXs
     */
    mapping(address => bool) lpPairs;

    /**
     * @dev mapping of accounts excluded from fee
     */
    mapping (address => bool) private _isExcludedFromFees;

    IRouter02 public dexRouter;
    address public lpPair;

    /**
     * @dev locked token structure
     */
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    /**
     * @dev Holds number & validity of tokens locked for a given reason for
     *      a specified address
     */
    mapping(address => mapping(bytes32 => lockToken)) public locked;

    /**
     * @dev Records data of all the tokens Locked
     */
    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    /**
     * @dev Records data of all the tokens unlocked
     */
    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );

    /**
     * @dev Records set lp lpPairs
     */
    event SetLpPairs(address pairAddress, bool value);

    /**
     * @dev Error messages for require statements
     */
    string internal constant ALREADY_LOCKED = "Tokens already locked";
    string internal constant NOT_LOCKED = "No tokens locked";
    string internal constant AMOUNT_ZERO = "Amount can not be 0";

    using SafeMath for uint256;

    constructor(address seedPreSale, address privatePreSale, address development, address marketting, address team) ERC20("SellAnyAd", "SELLX") SafeOwn(0) {
        _mint(msg.sender, 1000000000 * 10**decimals());
        uint256 seedRoleSupply = totalSupply().mul(8).div(10**2);
        uint256 privateSaleRoleSupply = totalSupply().mul(7).div(10**2);
        uint256 developmentSupply = totalSupply().mul(4).div(10**2);
        uint256 markettingSupply = totalSupply().mul(10).div(10**2);
        uint256 teamSupply = totalSupply().mul(6).div(10**2);

        _isExcludedFromFees[Owner()] = true;
        _isExcludedFromFees[address(this)] = true;

        utility(seedPreSale, "SEED_PRE_SALE", 15552000, 2592000, seedRoleSupply, 100);
        utility(privatePreSale, "PRIVATE_PRE_SALE", 15552000, 2592000, privateSaleRoleSupply, 100);
        utility(development, "DEVELOPMENT", 1209600, 2592000, developmentSupply, 50);
        utility(marketting, "MARKETTING", 7776000, 7776000, markettingSupply, 125);
        utility(team, "TEAM", 31536000, 2592000, teamSupply, 100);

        dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));

        _approve(Owner(), address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

        setLpPair(lpPair, true);

    }

    receive() external payable {}

    function setTaxFeePercentage(uint256 feePercentage) public onlyOwner {
        require(feePercentage>0 && feePercentage<100,"AdToken: percentage should be between 0 to 100");
        taxFeePercentage=feePercentage;
    }

    function withdrawTax(address recipient) public onlyOwner {
        require(totalTaxBalance > 0,"AdToken: no balance to withdraw");
        uint256 amount = totalTaxBalance;
        totalTaxBalance = 0;
        _transfer(address(this),recipient,amount);
    }

    function utility(address roleAddress, string memory role, uint256 timeToRelease, uint256 intervalPeriod, uint256 totalRoleSupply, uint256 percentagePerRelease) private {
        uint256 supplyPerRelease = totalRoleSupply.mul(percentagePerRelease).div(10**3);
        uint256 noOfIntervals = totalRoleSupply.div(supplyPerRelease);
        uint256 lockAmount = totalRoleSupply.mul(percentagePerRelease).div(10**3);
        for(uint256 i = 0; i < noOfIntervals; i++){
            bytes memory hashRole = abi.encodePacked(role, i);
            transferWithLock(roleAddress, keccak256(hashRole), lockAmount, timeToRelease.add(i.mul(intervalPeriod)));
        }
    }

    function getRoleBytes(string memory role, uint256 interval) public pure returns (bytes32){
        bytes memory hashRole = abi.encodePacked(role, interval);
        return keccak256(hashRole);
    }

    function getOwner() public view virtual returns (address) {
        return Owner();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be locked
     * @param _time Lock time in seconds
     */
    function lock(
        bytes32 _reason,
        uint256 _amount,
        uint256 _time
    ) public onlyOwner returns (bool) {
        uint256 validUntil = block.timestamp.add(_time);

        // If tokens are already locked, then functions extendLock or
        // increaseLockAmount should be used to make any changes
        require(tokensLocked(msg.sender, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[msg.sender][_reason].amount == 0)
            lockReason[msg.sender].push(_reason);

        _transfer(_msgSender(),address(this), _amount);

        locked[msg.sender][_reason] = lockToken(_amount, validUntil, false);

        emit Locked(msg.sender, _reason, _amount, validUntil);
        return true;
    }

    /**
     * @dev Transfers and Locks a specified amount of tokens,
     *      for a specified reason and time
     * @param _to adress to which tokens are to be transfered
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be transfered and locked
     * @param _time Lock time in seconds
     */
    function transferWithLock(
        address _to,
        bytes32 _reason,
        uint256 _amount,
        uint256 _time
    ) public returns (bool) {
        uint256 validUntil = block.timestamp.add(_time); //solhint-disable-line

        require(tokensLocked(_to, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[_to][_reason].amount == 0) lockReason[_to].push(_reason);

        _transfer(_msgSender(),address(this), _amount);

        locked[_to][_reason] = lockToken(_amount, validUntil, false);

        emit Locked(_to, _reason, _amount, validUntil);
        return true;
    }

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     */
    function tokensLocked(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (!locked[_of][_reason].claimed) amount = locked[_of][_reason].amount;
    }

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specific time
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     * @param _time The timestamp to query the lock tokens for
     */
    function tokensLockedAtTime(
        address _of,
        bytes32 _reason,
        uint256 _time
    ) public view returns (uint256 amount) {
        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

    /**
     * @dev Returns total tokens held by an address (locked + transferable)
     * @param _of The address to query the total balance of
     */
    function totalBalanceOf(address _of) public view returns (uint256 amount) {
        amount = balanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
        }
    }

    /**
     * @dev Extends lock for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _time Lock extension time in seconds
     */
    function extendLock(bytes32 _reason, uint256 _time) public returns (bool) {
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);

        locked[msg.sender][_reason].validity = locked[msg.sender][_reason]
            .validity
            .add(_time);

        emit Locked(
            msg.sender,
            _reason,
            locked[msg.sender][_reason].amount,
            locked[msg.sender][_reason].validity
        );
        return true;
    }

    /**
     * @dev Increase number of tokens locked for a specified reason
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be increased
     */
    function increaseLockAmount(bytes32 _reason, uint256 _amount)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);
        transfer(address(this), _amount);

        locked[msg.sender][_reason].amount = locked[msg.sender][_reason]
            .amount
            .add(_amount);

        emit Locked(
            msg.sender,
            _reason,
            locked[msg.sender][_reason].amount,
            locked[msg.sender][_reason].validity
        );
        return true;
    }

    /**
     * @dev Returns unlockable tokens for a specified address for a specified reason
     * @param _of The address to query the the unlockable token count of
     * @param _reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (
            locked[_of][_reason].validity <= block.timestamp &&
            !locked[_of][_reason].claimed
        )
            //solhint-disable-line
            amount = locked[_of][_reason].amount;
    }

    /**
     * @dev Unlocks the unlockable tokens of a specified address
     * @param _of Address of user, claiming back unlockable tokens
     */
    function unlock(address _of) public returns (uint256 unlockableTokens) {
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        }

        if (unlockableTokens > 0) this.transfer(_of, unlockableTokens);
    }

    /**
     * @dev Gets the unlockable tokens of a specified address
     * @param _of The address to query the the unlockable token count of
     */
    function getUnlockableTokens(address _of)
        public
        view
        returns (uint256 unlockableTokens)
    {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(
                tokensUnlockable(_of, lockReason[_of][i])
            );
        }
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
    ) internal override {
        require(sender != address(0), "AdToken: transfer from the zero address");
        require(recipient != address(0), "AdToken: transfer to the zero address");
        require(amount > 0, "AdToken: transfer amount must be greater than zero");

        _beforeTokenTransfer(sender, recipient, amount);
    
        // uint256 senderBalance = _balances[sender];
        // require(
        //     senderBalance >= amount,
        //     "AdToken: transfer amount exceeds balance"
        // ); 
        bool takeFee = true;
        
        if(_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) {
            takeFee = false;
        }
        
        // _balances[sender] = senderBalance - amount;
        // _balances[recipient] += amount;

        // emit Transfer(sender, recipient, amount);

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    /**
     * @dev token transfer with tax deduction
     * @param sender from address
     * @param recipient to address
     * @param amount amount to transfer
     * @param takeFee bool value to take fee or not
     */
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "AdToken: transfer amount exceeds balance"
        );
        
        _balances[sender] -= amount;
        uint256 finalAmount = (takeFee) ? _reflectFee(sender, recipient, amount) : amount;
        _balances[recipient] += finalAmount;

        emit Transfer(sender, recipient, finalAmount);
    }

    /**
     * @dev token Fee reflection
     * @param sender from address
     * @param recipient to address
     * @param amount amount to compute tax
    */
    function _reflectFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 fee;
        (uint256 standardTax, uint256 buyTax, uint256 sellTax) = _getTaxValues(amount);
        
        fee += standardTax;

        // reflect buy tax fee
        if (lpPairs[sender]){
            fee += buyTax;
        } else if (lpPairs[recipient]) {
            fee += sellTax;
        }

        _balances[address(this)] += fee;
        totalTaxBalance = totalTaxBalance.add(fee);
        emit Transfer(sender, address(this), fee);

        return amount - fee;
    }

    /**
     * @dev See {AdToken-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public override returns (bool)
    {
        // uint256 taxAmount = amount.mul(taxFeePercentage).div(100);
        // //taxBalance += taxAmount;
        // _transfer(_msgSender(), recipient, amount.mul(100 - taxFeePercentage).div(100));

        // if(taxAmount > 0) {
        // _transfer(_msgSender(), address(this), amount.mul(taxFeePercentage).div(100));
        // }
        _transfer(_msgSender(), recipient, amount);

        return true;
    }



        /**
     * @dev See {AdToken-transferFrom}.
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
    ) public override returns (bool) {
        
        // uint256 taxAmount = amount.mul(taxFeePercentage).div(100);
        // //taxBalance += taxAmount;
        // _transfer(sender, recipient, amount.mul(100 - taxFeePercentage).div(100));

        // if(taxAmount > 0){
        //     _transfer(sender, address(this), amount.mul(taxFeePercentage).div(100));
        // }        

        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "AdToken: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Get tax amount (Standard, Buy, Sell)
     * @param _amount the transfer amount to compute tax
     */
    function _getTaxValues(uint256 _amount) public view returns (uint256 standardTax, uint256 buyTax, uint256 sellTax) {
        
        standardTax = calculateStandardTax(_amount);
        buyTax = calculateBuyTax(_amount);
        sellTax = calculateSellTax(_amount);       
    }

    function calculateStandardTax(uint256 _amount) public view returns (uint256) {
        return _amount.mul(taxFeePercentage).div(100);
    }

    function calculateBuyTax(uint256 _amount) public view returns (uint256) {
        return _amount.mul(buyFeePercentage).div(100);
    }

    function calculateSellTax(uint256 _amount) public view returns (uint256) {
        return _amount.mul(sellFeePercentage).div(100);
    }

    /**
     * @dev set standardFeePercentage 
     * @param _percentage the tax percentage
     */
    function setStandardFeePercentage(uint256 _percentage) public onlyOwner {
        require(_percentage > 0 && _percentage < 100, "AdToken : Percentage should be range of 0 - 100");
        require(_percentage.add(buyFeePercentage) < 100 || _percentage.add(sellFeePercentage) < 100, "AdToken : Total tax percentage exceeds 100");
        taxFeePercentage = _percentage;
    }

    /**
     * @dev set buyFeePercentage
     * @param _percentage the tax percentage
     */
    function setBuyFeePercentage(uint256 _percentage) public onlyOwner {
        require(_percentage > 0 && _percentage < 100, "AdToken : Percentage should be range of 0 - 100");
        require(_percentage.add(taxFeePercentage) < 100 || _percentage.add(sellFeePercentage) < 100, "AdToken : Total tax percentage exceeds 100");
        buyFeePercentage = _percentage;
    }

    /**
     * @dev set sellFeePercentage
     * @param _percentage the tax percentage
     */
    function setSellFeePercentage(uint256 _percentage) public onlyOwner {
        require(_percentage > 0 && _percentage < 100, "AdToken : Percentage should be range of 0 - 100");
        require(_percentage.add(taxFeePercentage) < 100 || _percentage.add(taxFeePercentage) < 100, "AdToken : Total tax percentage exceeds 100");
        sellFeePercentage = _percentage;
    }

    /**
     * @dev Set value for the lpPairs mapping
     * @param _account the lpPair address
     * @param _value the boolean value
     */
    function setLpPair(address _account, bool _value) public onlyOwner {
        lpPairs[_account] = _value;
        emit SetLpPairs(_account, _value);
    }

    /**
     * @dev Set new router and create pair
     * @param newRouter the new dex router to create pair
     */
    function setNewRouter(address newRouter) public onlyOwner {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);

        setLpPair(lpPair, true);
    }
}