/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT
// File: Smart Contract/contracts/utils/SafeMath.sol


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

// File: Smart Contract/contracts/utils/Context.sol


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

// File: Smart Contract/contracts/utils/Ownable.sol


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
// File: Smart Contract/contracts/Interfaces/IBEP20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)


/**
 * @dev Interface of the BEP20 standard. Does not include
 * the optional functions; to access them see {BEP20Detailed}.
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

// File: Smart Contract/contracts/extensions/IBEP20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

// File: Smart Contract/contracts/Token/BEP20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)





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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimal_
    ) {
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
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// File: Smart Contract/contracts/Token/Rijent.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)





contract Rijent is BEP20, Ownable{
    using SafeMath for uint256;
    uint256 private totalTokens;

    constructor() BEP20("Rijent Coin", "Rijent", 9) {
        totalTokens = 290000000 * 10**uint256(decimals());
        _mint(msg.sender, totalTokens);
    }

    function transfer(address _receiver, uint256 _amount)
        public
        virtual
        override
        returns (bool success)
    {
        require(_receiver != address(0));

        return BEP20.transfer(_receiver, _amount);
    }

   

    //     constructor() BEP20("Rijent", "Rpay") {}

    function mint(address account, uint256 amount) public onlyOwner(){
        _mint(account, amount);
    }

    function transferPrice(
        address sender,
        address receiver,
        uint256 amount
    ) public {
        BEP20._transfer(sender, receiver, amount);
    }
}

// File: Smart Contract/contracts/test.sol




contract STAKING is Rijent {
    Rijent public stakingToken;
    uint256 interestPerSecond;
    uint256 stakedAmount;
    uint256 secInMonth = 30 * 24 * 60 * 60;
    uint256 rewardGeneratedFor;
    uint256 stakePerWEEK;
    uint256 weekOfClaim;
    uint256 timeAfterStakeFinish;
    uint256 totalclaimAvailable;
    uint256 index = 0;

    //stakedmonth will be of 360 days = 360   24  60 * 60 = 3,11,04,000 sec
    // month will be of 30 days = 30  24  60 * 60 = 25,92,000 sec
    // week = 7 days = 7  24  60 * 60 = 6,04,800 sec

    mapping(address => mapping(uint256 => uint256)) _stakeMonth;
    mapping(address => mapping(uint256 => uint256)) _stakedMoney;
    mapping(address => mapping(uint256 => uint256)) totalClaim;
    mapping(address => mapping(uint256 => uint256)) TotalReward;
    mapping(address => mapping(uint256 => uint256)) claimableReward;
    mapping(address => mapping(uint256 => uint256)) staketime;
    mapping(address => mapping(uint256 => uint256)) coolingTime;

    // enter the token's address you want to stake
    constructor(address _stakingToken) {
        stakingToken = Rijent(_stakingToken);
    }

    // enter amount ,month , and interest according the given condition
    // it deduct the entered amount and add to totalsupply of contract
    //generate a unique id for every stake

    function stake(
        uint256 amount,
        uint256 months,
        uint256 interest
    ) public {
        require(
            (interest == 3 && months == 12) ||
                (interest == 4 && months == 24) ||
                (interest == 5 && months == 36) ||
                (interest == 6 && months == 60),
            "Invalid Input"
        );
        require(amount >= 100, "minimum stake is 100");
        // generate new ID everytime you stake
        index = index + 1;

        stakedAmount += amount;
        _stakeMonth[msg.sender][index] = months;
        staketime[msg.sender][index] = block.timestamp;
        coolingTime[msg.sender][index] =
            staketime[msg.sender][index] +
            _stakeMonth[msg.sender][index] *
            secInMonth;
        _stakedMoney[msg.sender][index] = amount;
        //transfer balance from user to smart contract
        Rijent.transferPrice(msg.sender, address(this), amount);

        //calculate total reward of time period
        TotalReward[msg.sender][index] = (((interest *
            _stakedMoney[msg.sender][index]) * _stakeMonth[msg.sender][index]) /
            100);

        emit staked(
            index,
            _stakedMoney[msg.sender][index],
            staketime[msg.sender][index],
            _stakeMonth[msg.sender][index],
            TotalReward[msg.sender][index]
        );
    }

    // enter the uniqueID generated while staking to access that particular stake
    function indexid(uint256 _index) public {
        require(stakedAmount > 0, "  stake some amonut");
        index = _index;
        require(_index <= index, "First, stake some amount");
        _stakedMoney[msg.sender][index];
        emit indexID(
            index,
            _stakedMoney[msg.sender][_index],
            _stakeMonth[msg.sender][index]
        );
    }

    // reward generation till cooling period
    function rewardGen() public {
        require(stakedAmount > 0, "  stake some amonut");
        //before staketime over
        //reward generation start when you stake some money
        //first time reward generated - reward generate of the fixed timed duration  from staking time to current time
        // reward generate of the fixed timed duration  from last claim time to current time
        if (coolingTime[msg.sender][index] > block.timestamp) {
            interestPerSecond =
                TotalReward[msg.sender][index] /
                (_stakeMonth[msg.sender][index] * secInMonth);
            uint256 RewardTime = block.timestamp - staketime[msg.sender][index];
            claimableReward[msg.sender][index] = RewardTime * interestPerSecond;
            claimableReward[msg.sender][index] =
                claimableReward[msg.sender][index] -
                totalClaim[msg.sender][index];
            rewardGeneratedFor =
                claimableReward[msg.sender][index] /
                interestPerSecond;
            emit RewardGen(
                index,
                interestPerSecond,
                RewardTime,
                claimableReward[msg.sender][index],
                rewardGeneratedFor
            );
        }
        // after staketime over
        // reward generate of fixed timed duration  from last claim time to cooling time
        else if (
            coolingTime[msg.sender][index] < block.timestamp &&
            TotalReward[msg.sender][index] != 0
        ) {
            interestPerSecond =
                TotalReward[msg.sender][index] /
                (_stakeMonth[msg.sender][index] * secInMonth);

            uint256 RewardTime = block.timestamp - staketime[msg.sender][index];
            RewardTime = _stakeMonth[msg.sender][index] * secInMonth;
            claimableReward[msg.sender][index] =
                TotalReward[msg.sender][index] -
                totalClaim[msg.sender][index];
            rewardGeneratedFor =
                _stakeMonth[msg.sender][index] *
                secInMonth -
                totalClaim[msg.sender][index] /
                interestPerSecond;
            emit RewardGen(
                index,
                interestPerSecond,
                RewardTime,
                claimableReward[msg.sender][index],
                rewardGeneratedFor
            );
        }
        //claim principle
        //first claim all reward before claiming principle
        //claim will be generated weekly
        else if (
            coolingTime[msg.sender][index] < block.timestamp &&
            TotalReward[msg.sender][index] == 0
        ) {
            require(
                coolingTime[msg.sender][index] + 604800 < block.timestamp,
                "Can only generate after cooling Time"
            );
            stakePerWEEK = _stakedMoney[msg.sender][index] / 604800;
            timeAfterStakeFinish =
                block.timestamp -
                coolingTime[msg.sender][index];
            weekOfClaim = timeAfterStakeFinish / 20;
            //before 20 weeks time duration
            if (weekOfClaim < 20) {
                totalclaimAvailable = weekOfClaim * stakePerWEEK;
                claimableReward[msg.sender][index] =
                    totalclaimAvailable -
                    totalClaim[msg.sender][index];
                emit Withdrawl(
                    index,
                    stakePerWEEK,
                    weekOfClaim,
                    claimableReward[msg.sender][index],
                    totalClaim[msg.sender][index],
                    _stakedMoney[msg.sender][index]
                );
            }
            //after 20 weeks claim period finish
            else {
                weekOfClaim = _stakedMoney[msg.sender][index] / stakePerWEEK;
                totalclaimAvailable = _stakedMoney[msg.sender][index];
                claimableReward[msg.sender][index] =
                    _stakedMoney[msg.sender][index] -
                    totalClaim[msg.sender][index];
                emit Withdrawl(
                    index,
                    stakePerWEEK,
                    weekOfClaim,
                    claimableReward[msg.sender][index],
                    totalClaim[msg.sender][index],
                    _stakedMoney[msg.sender][index]
                );
            }
        }
    }

    // claiming reward generated by rewardGen() function
    // we need to generate reward by rewardGen() function
    function claimReward() public {
        require(stakedAmount > 0, "  stake some amonut");
        //before staketime over
        //claimed reward will add in a mapping
        // amount generated by rewardGen() function will be mint to user.
        if (block.timestamp < coolingTime[msg.sender][index]) {
            totalClaim[msg.sender][index] =
                claimableReward[msg.sender][index] +
                totalClaim[msg.sender][index];
            _mint(msg.sender, claimableReward[msg.sender][index]);
            //after staketime over
            // amount generated by rewardGen() function will be mint to user.
        } else if (
            coolingTime[msg.sender][index] < block.timestamp &&
            TotalReward[msg.sender][index] != 0
        ) {
            TotalReward[msg.sender][index] -= TotalReward[msg.sender][index];
            totalClaim[msg.sender][index] -= totalClaim[msg.sender][index];
            _mint(msg.sender, claimableReward[msg.sender][index]);
        }
        //for claiming the stakedamount
        // Check StakeAmount Availibilty to claim
        // stakedamount will available and claimed weekly .
        else {
            require(
                claimableReward[msg.sender][index] > 0,
                "cant claim before mature amount"
            );
            //Stakeamount will transfer from smaRijentotract address to user.
            Rijent.transferPrice(
                address(this),
                msg.sender,
                claimableReward[msg.sender][index]
            );
            totalClaim[msg.sender][index] =
                claimableReward[msg.sender][index] +
                totalClaim[msg.sender][index];
            stakedAmount -= claimableReward[msg.sender][index];
            claimableReward[msg.sender][index] -= claimableReward[msg.sender][
                index
            ];
            _stakedMoney[msg.sender][index] -= totalClaim[msg.sender][index];
        }
    }

    // ckecking current amount generated by rewardgen() function
    function ClaimAvailable() public view returns (uint256) {
        return claimableReward[msg.sender][index];
    }

    // total supply of the staked contract
    function totalSupply() public view virtual override returns (uint256) {
        return stakedAmount;
    }

    // for selecting the ID which you want to check detail .
    function getApplicationByBATCHID(uint256 _index)
        public
        view
        returns (
            uint256 stakedtime,
            uint256 stakedmoney,
            uint256 stakeMonth,
            uint256 TotalClaim,
            uint256 totalRewardGenerated,
            uint256 Coolingtime
        )
    {
        return (
            staketime[msg.sender][_index],
            _stakedMoney[msg.sender][_index],
            _stakeMonth[msg.sender][_index],
            totalClaim[msg.sender][_index],
            TotalReward[msg.sender][_index],
            coolingTime[msg.sender][_index]
        );
    }

    event staked(
        uint256 id,
        uint256 stakedAmount,
        uint256 StakeTime,
        uint256 _stakeMonth,
        uint256 totalRewardGeneratead
    );
    event indexID(
        uint256 indexID,
        uint256 stakedMoneyONID,
        uint256 stakedMonthOfID
    );
    event RewardGen(
        uint256 id,
        uint256 interestPerSecond,
        uint256 rewardGeneratedPeriod,
        uint256 RewardGeneratedAmount,
        uint256 rewardGeneratedFor
    );
    event Withdrawl(
        uint256 id,
        uint256 stakePerWEEK,
        uint256 totalWeekOfWithdrawlGenerated,
        uint256 rewardAvailable,
        uint256 totalclaimed,
        uint256 stakedAmount
    );
}