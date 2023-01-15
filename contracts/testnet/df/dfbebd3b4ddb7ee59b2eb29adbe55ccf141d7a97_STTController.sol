/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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

// File: /STTData.sol



pragma solidity ^0.8.0;




contract STTData is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    struct TokenRecord {

        address user;

        uint256 tokenType;//Usdt:1, STT:2

        int256 tokens;//amount

        //Usdt:1-buyblackHoleValue, 2-invest, 3-freeCabinValueDraw, 4-orbitalCabinValueDraw
        //STT:1-freeCabinTokenReward, 2-orbitalCabinTokenReward, 3-inviteReward, 4-teamReward, 5-swapUsdt, 6-userTokenTransfer
        uint256 types;

        uint256 time;
    }

    struct InvestRecord {

        address user;

        uint256 costBlackHoleValue;

        uint256 freeCabinValue;

        uint256 orbitalCabinValue;

        uint256 investTime;

        uint256 freeCabinTokenProfit;

        uint256 freeCabinDrawTime;

        uint256 orbitalCabinTokenProfit;

        uint256 orbitalCabinDrawTime;
    }

    struct User {

        uint256 blackHoleValue;

        uint256 usdtToReinvest;

        uint256 tokenToReinvest;

        uint256 tokenProfitTotal;

        uint256 tokenProfitToday;

        uint256 inviteRewardTotal;//推荐收益

        bool disable;

        uint256 bindTime;

        address recommender;

        address[] myInvitees;
    }

    mapping(address => User) public users;

    TokenRecord[] public tokenRecords;
    InvestRecord[] public investRecords;

    mapping(address => uint256[]) public myTokenRecords;
    mapping(address => uint256[]) public myInvestRecords;

    uint256[4] public mineOutputLimits = [100000 * 10 **10,1000000 * 10 **18,5000000 * 10 **18,8000000 * 10 **18];
    uint256[4] public mineOutputs = [10000 * 10 **18,100000 * 10 **18,500000 * 10 **18,350000 * 10 **18];

    uint256[5] public teamLevelLimits = [50000 * 10 **18,100000 * 10 **18,300000 * 10 **18,900000 * 10 **18,3000000 * 10 **18];
    uint256[5] public teamLevelRewardRates = [10,20,30,40,50];

    uint256[3] public inviteesNumRewardLimits = [1,2,3];
    uint256[3] public inviteRewardLevels = [2,3,6];
    uint256[6] public inviteLevelRewardRates = [20,10,8,5,3,3];

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public pair;
    address public stt;
    address public usdt;

    string public baseLink;

    uint256 public buyBlackHoleValueLimit = 100 * 10 **10;//复投门槛

    uint256 public investUsdtLimit = 1 * 10 **10;//复投门槛
    uint256 public lpTokensLimit = 1 * 10 **10;//复投

    uint256 public freeCabinValueRewardLimit = 10 * 10 **10;
    uint256 public orbitalCabinValueRewardLimit = 10 * 10 **10;

    uint256 public totalUserAmount;
    uint256 public todayNewUserAmount;
    uint256 public totalRechargeAmount;
    uint256 public todayRechargeAmount;
    uint256 public totalDrawUsdtAmount;
    uint256 public todayDrawUsdtAmount;
    uint256 public totalUserTokenProfit;
    uint256 public todayUserTokenProfit;
    uint256 public totalBuyBlackHoleValue;
    uint256 public todayBuyBlackHoleValue;
    uint256 public totalTransferAmount;
    uint256 public todayTransferAmount;

    uint256 public totalGammaValue;
    uint256 public totalPropulsiveCabinValue;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Pancake: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    mapping(address => bool) public isController;
    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    constructor() {
        pair = address(0x27036469ab3E67b0fa6ee068Bc88B4E1bd89a112);
        stt = address(0xB7dFc629341d26219Af3a77c7ec32EEA2E5D99b7);
        usdt = address(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47);
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function updateSTT(address _stt) public onlyOwner {
        stt = address(_stt);
    }

    function updateUSDT(address _usdt) public onlyOwner {
        usdt = address(_usdt);
    }

    function updatePair(address _pair) public onlyOwner {
        pair = address(_pair);
    }

    function setBaseLink(string memory base) public onlyOwner {
        baseLink = base;
    }

    function setTeamUsdtLimit(uint256 index, uint256 limt) public onlyOwner {
        teamLevelLimits[index - 1] = limt;
    }

    function setTeamLevelRewardRates(uint256 index, uint256 rate) public onlyOwner {
        teamLevelRewardRates[index - 1] = rate;
    }

    function setInviteesNumRewardLimits(uint256 index, uint256 inviteesnum) public onlyOwner {
        inviteesNumRewardLimits[index - 1] = inviteesnum;
    }

    function setInviteRewardLevels(uint256 index, uint256 levels) public onlyOwner {
        inviteRewardLevels[index - 1] = levels;
    }

    function setInviteLevelRewardRates(uint256 index, uint256 rate) public onlyOwner {
        inviteLevelRewardRates[index - 1] = rate;
    }

    function setMineOutputLimits(uint256 index, uint256 limt) public onlyOwner {
        mineOutputLimits[index - 1] = limt;
    }

    function setMineOutputs(uint256 index, uint256 output) public onlyOwner {
        mineOutputs[index - 1] = output;
    }

    function setBuyBlackHoleValueLimit(uint256 limit) public onlyOwner {
        buyBlackHoleValueLimit = limit;
    }

    function setInvestUsdtLimit(uint256 limit) public onlyOwner {
        investUsdtLimit = limit;
    }

    function setLpTokensLimit(uint256 limit) public onlyOwner {
        lpTokensLimit = limit;
    }

    function updateUserDisableStatus(address user, bool disable) public onlyOwner {
        users[user].disable = disable;
    }


    function queryAllInvestRecords() public view returns(InvestRecord[] memory) {
        return investRecords;
    }

    function queryAllInvestRecordsNum() public view returns(uint256) {
        return investRecords.length;
    }

    function queryAllTokenRecords() public view returns(TokenRecord[] memory) {
        return tokenRecords;
    }

    function queryAllTokenRecordsNum() public view returns(uint256) {
        return tokenRecords.length;
    }

    function queryMyInvitees(address user) public view returns(address[] memory) {
        return users[user].myInvitees;
    }

    function queryMyInviteesNum(address user) public view returns(uint256) {
        return users[user].myInvitees.length;
    }

    function queryMyTokenRecords(address user) public view returns(uint256[] memory) {
        return myTokenRecords[user];
    }

    function queryMyTokenRecordsNum(address user) public view returns(uint256) {
        return myTokenRecords[user].length;
    }

    function queryMyInvestRecords(address user) public view returns(uint256[] memory) {
        return myInvestRecords[user];
    }

    function queryMyInvestRecordsNum(address user) public view returns(uint256) {
        return myInvestRecords[user].length;
    }

    function queryUserTokenRecords(address user) public view returns(TokenRecord[] memory records) {

        uint256[] memory indexs = myTokenRecords[user];
        records = new TokenRecord[](indexs.length);

        uint256 count;
        uint256 i;

        for(i = indexs.length; i > 0; i--){
            records[count] = tokenRecords[indexs[i - 1]];
            count++;
        }
        return records;
    }

    function queryUserTokenRecordsByTokenType(address user, uint256 tokenType) public view returns(TokenRecord[] memory records) {

        uint256[] memory indexs = myTokenRecords[user];
        TokenRecord[] memory records0 = new TokenRecord[](indexs.length);

        uint256 count;
        uint256 i;

        for(i = indexs.length; i > 0; i--){
            if(tokenRecords[indexs[i - 1]].tokenType == tokenType){
                records0[count] = tokenRecords[indexs[i - 1]];
                count++;
            }
        }

        records = new TokenRecord[](count);

        for(i = 0; i < count; i++){
            records[i] = records0[i];
        }
        return records;
    }

    function queryUserTokenRecordsByType(address user, uint256 types) public view returns(TokenRecord[] memory records) {

        uint256[] memory indexs = myTokenRecords[user];
        TokenRecord[] memory records0 = new TokenRecord[](indexs.length);

        uint256 count;
        uint256 i;

        for(i = indexs.length; i > 0; i--){
            if(types == 0){
                records0[count] = tokenRecords[indexs[i - 1]];
                count++;
            }else if(types == 7){
                if(tokenRecords[indexs[i - 1]].types == 3 || tokenRecords[indexs[i - 1]].types == 4){
                    records0[count] = tokenRecords[indexs[i - 1]];
                    count++;
                }
            }else if(types == 23){
                if(tokenRecords[indexs[i - 1]].types == 11 || tokenRecords[indexs[i - 1]].types == 12){
                    records0[count] = tokenRecords[indexs[i - 1]];
                    count++;
                }
            }else{
                if(tokenRecords[indexs[i - 1]].types == types){
                    records0[count] = tokenRecords[indexs[i - 1]];
                    count++;
                }
            }
        }

        records = new TokenRecord[](count);

        for(i = 0; i < count; i++){
            records[i] = records0[i];
        }
        return records;
    }

    function queryTokenRecordsByTokenType(uint256 tokenType) public view returns(TokenRecord[] memory records) {

        TokenRecord[] memory records0 = new TokenRecord[](tokenRecords.length);
        uint256 count;
        uint256 i;

        for(i = tokenRecords.length; i > 0; i--){
            if(tokenRecords[i - 1].tokenType == tokenType){
                records0[count] = tokenRecords[i - 1];
                count++;
            }
        }

        records = new TokenRecord[](count);

        for(i = 0; i < count; i++){
            records[i] = records0[i];
        }
        return records;
    }

    function queryTokenRecordsByType(uint256 types) public view returns(TokenRecord[] memory records) {

        TokenRecord[] memory records0 = new TokenRecord[](tokenRecords.length);
        uint256 count;
        uint256 i;

        for(i = tokenRecords.length; i > 0; i--){
            if(tokenRecords[i - 1].types == types){
                records0[count] = tokenRecords[i - 1];
                count++;
            }
        }

        records = new TokenRecord[](count);

        for(i = 0; i < count; i++){
            records[i] = records0[i];
        }
        return records;
    }

    function bindRecommender(address user, address recommender) public onlyController {
        users[user].recommender = recommender;
        users[recommender].myInvitees.push(user);//myInvitees
        users[user].bindTime = block.timestamp;
    }

    function addTotalUserAmount(uint256 amount) public onlyController {
        totalUserAmount = totalUserAmount.add(amount);
    }

    function addTodayNewUserAmount(uint256 amount, bool reset) public onlyController {
        if(reset){
            todayNewUserAmount = amount;
        }else{
            todayNewUserAmount = todayNewUserAmount.add(amount);
        }
        // uint256 lastTime = investRecords[investRecords.length - 1].investTime;
        // if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
        //     todayNewUserAmount = amount;
        // }else{
        //     todayNewUserAmount = todayNewUserAmount.add(amount);
        // }
    }

    function addTotalRechargeAmount(uint256 amount) public onlyController {
        totalRechargeAmount = totalRechargeAmount.add(amount);
    }

    function addTodayRechargeAmount(uint256 amount, bool reset) public onlyController {
        if(reset){
            todayRechargeAmount = amount;
        }else{
            todayRechargeAmount = todayRechargeAmount.add(amount);
        }
        // uint256 lastTime = investRecords[investRecords.length - 1].investTime;
        // if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
        //     todayRechargeAmount = amount;
        // }else{
        //     todayRechargeAmount = todayRechargeAmount.add(amount);
        // }
    }

    function addTotalDrawUsdtAmount(uint256 amount) public onlyController {
        totalDrawUsdtAmount = totalDrawUsdtAmount.add(amount);
    }

    function addTodayDrawUsdtAmount(uint256 amount, bool reset) public onlyController {
        if(reset){
            todayDrawUsdtAmount = amount;
        }else{
            todayDrawUsdtAmount = todayDrawUsdtAmount.add(amount);
        }
    }

    function addTotalUserTokenProfit(uint256 amount) public onlyController {
        totalUserTokenProfit = totalUserTokenProfit.add(amount);
    }

    function addTodayUserTokenProfit(uint256 amount, bool reset) public onlyController {
        if(reset){
            todayUserTokenProfit = amount;
        }else{
            todayUserTokenProfit = todayUserTokenProfit.add(amount);
        }
    }

    function addTotalBuyBlackHoleValue(uint256 amount) public onlyController {
        totalBuyBlackHoleValue = totalBuyBlackHoleValue.add(amount);
    }

    function addTodayBuyBlackHoleValue(uint256 amount, bool reset) public onlyController {
        if(reset){
            todayBuyBlackHoleValue = amount;
        }else{
            todayBuyBlackHoleValue = todayBuyBlackHoleValue.add(amount);
        }
    }

    function addTotalTransferAmount(uint256 amount) public onlyController {
        totalTransferAmount = totalTransferAmount.add(amount);
    }

    function addTodayTransferAmount(uint256 amount, bool reset) public onlyController {
        if(reset){
            todayTransferAmount = amount;
        }else{
            todayTransferAmount = todayTransferAmount.add(amount);
        }
    }

    function addUserTokenProfitTotal(address user, uint256 amount) public onlyController {
        users[user].tokenProfitTotal = users[user].tokenProfitTotal.add(amount);
    }

    function addUserTokenProfitToday(address user, uint256 amount, bool reset) public onlyController {
        if(reset){
            users[user].tokenProfitToday = amount;
        }else{
            users[user].tokenProfitToday = users[user].tokenProfitToday.add(amount);
        }
        // uint256 lastTime = tokenRecords[myTokenRecords[user][myTokenRecords[user].length - 1]].time;
        // if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
        //     users[user].tokenProfitToday = amount;
        // }else{
        //     users[user].tokenProfitToday = users[user].tokenProfitToday.add(amount);
        // }
    }

    function addUserInviteRewardTotal(address user, uint256 amount) public onlyController {
        users[user].inviteRewardTotal = users[user].inviteRewardTotal.add(amount);
    }

    function addUserTokenRecords(address user, uint256 tokenType, int256 tokenAmount, uint256 types) public onlyController {
        myTokenRecords[user].push(tokenRecords.length);
        tokenRecords.push(TokenRecord(user,tokenType,tokenAmount,types,block.timestamp));
    }

    function addUserInvestRecords(address user, uint256 usdtAmount) public onlyController {
        myInvestRecords[user].push(investRecords.length);
        investRecords.push(InvestRecord(user,usdtAmount.mul(20).div(100),usdtAmount.mul(30).div(100),usdtAmount.mul(70).div(100),block.timestamp,0,0,0,0));
    }
   
    function addUserBlackHoleValue(address user, uint256 amount) public onlyController {
        users[user].blackHoleValue = users[user].blackHoleValue.add(amount);
    }

    function subUserBlackHoleValue(address user, uint256 amount) public onlyController {
        users[user].blackHoleValue = users[user].blackHoleValue.sub(amount);
    }

    function addUserUsdtToReinvest(address user, uint256 amount) public onlyController {
        users[user].usdtToReinvest = users[user].usdtToReinvest.add(amount);
    }

    function subUserUsdtToReinvestTo0(address user) public onlyController {
        users[user].usdtToReinvest = 0;
    }

    function addUserTokenToReinvest(address user, uint256 amount) public onlyController {
        users[user].tokenToReinvest = users[user].tokenToReinvest.add(amount);
    }

    function subUserTokenToReinvestTo0(address user) public onlyController {
        users[user].tokenToReinvest = 0;
    }

    function addFreeCabinTokenReward(address user, uint256 index, uint256 amount, uint256 time) public onlyController {
        require(investRecords[index].user == user,"The user is not the owner of the record");
        investRecords[index].freeCabinTokenProfit = investRecords[index].freeCabinTokenProfit.add(amount);
        investRecords[index].freeCabinDrawTime = time;
    }

    function addOrbitalCabinTokenReward(address user, uint256 index, uint256 amount, uint256 time) public onlyController {
        require(investRecords[index].user == user,"The user is not the owner of the record");
        investRecords[index].orbitalCabinTokenProfit = investRecords[index].orbitalCabinTokenProfit.add(amount);
        investRecords[index].orbitalCabinDrawTime = time;
    }

    function subFreeCabinValueTo0(address user, uint256 index) public onlyController {
        require(investRecords[index].user == user,"The user is not the owner of the record");
        investRecords[index].freeCabinValue = 0;
    }

    function subOrbitalCabinValueTo0(address user, uint256 index) public onlyController {
        require(investRecords[index].user == user,"The user is not the owner of the record");
        investRecords[index].orbitalCabinValue = 0;
    }

    function addTotalGammaValue(uint256 amount) public onlyController {
        totalGammaValue = totalGammaValue.add(amount);
    }

    function subTotalGammaValue(uint256 amount) public onlyController {
        totalGammaValue = totalGammaValue.sub(amount);
    }

    function addTotalPropulsiveCabinValue(uint256 amount) public onlyController {
        totalPropulsiveCabinValue = totalPropulsiveCabinValue.add(amount);
    }

    function subTotalPropulsiveCabinValue(uint256 amount) public onlyController {
        totalPropulsiveCabinValue = totalPropulsiveCabinValue.sub(amount);
    }

    // function addTotalMineOutput(uint256 amount) public onlyController {
    //     totalMineOutput = totalMineOutput.add(amount);
    // }


}
// File: /STTQuery.sol



pragma solidity ^0.8.0;


contract STTQuery is Ownable {

    using SafeMath for uint256;

    STTData STTD;

    constructor() {
        STTD = STTData(payable(0xA707b50f9bfC98d46870585387A1F595C0921507));
    }

    function updateSTTD(address _sttd) public onlyOwner {
        STTD = STTData(payable(_sttd));
    }

    function queryUserBlackHoleValue(address user) public view returns(uint256) {
        (uint256 blackHoleValue,,,,,,,,) = STTD.users(user);
        return blackHoleValue;
    }

    function queryUserDisable(address user) public view returns (bool){
        (,,,,,,bool disable,,) = STTD.users(user);
        return disable;
    }

    function queryUserRecommender(address user) public view returns (address){
        (,,,,,,,,address recommender) = STTD.users(user);
        return recommender;
    }

    function queryUserGammaValue(address user) public view returns(uint256) {
        return queryUserFreeCabinValue(user) + queryUserOrbitalCabinValue(user) + queryUserCostBlackHoleValue(user);
    }

    function queryUserPropulsiveCabinValue(address user) public view returns(uint256) {
        return queryUserFreeCabinValue(user) + queryUserOrbitalCabinValue(user);
    }

    function queryUserFreeCabinValue(address user) public view returns(uint256 freeCabinValue) {
        uint256[] memory indexs = STTD.queryMyInvestRecords(user);
        uint256 freeCabinValue0;
        uint256 i;

        for(i = 0; i < indexs.length; i++){
            (,,freeCabinValue0,,,,,,) = STTD.investRecords(indexs[i]);
            freeCabinValue += freeCabinValue0;
        }
    }

    function queryUserOrbitalCabinValue(address user) public view returns(uint256 orbitalCabinValue) {
        uint256[] memory indexs = STTD.queryMyInvestRecords(user);
        uint256 orbitalCabinValue0;
        uint256 i;

        for(i = 0; i < indexs.length; i++){
            (,,,orbitalCabinValue0,,,,,) = STTD.investRecords(indexs[i]);
            orbitalCabinValue += orbitalCabinValue0;
        }
    }

    function queryUserCostBlackHoleValue(address user) public view returns(uint256 costBlackHoleValue) {
        uint256[] memory indexs = STTD.queryMyInvestRecords(user);
        uint256 costBlackHoleValue0;
        uint256 i;

        for(i = 0; i < indexs.length; i++){
            (,costBlackHoleValue0,,,,,,,) = STTD.investRecords(indexs[i]);
            costBlackHoleValue += costBlackHoleValue0;
        }
    }

    function queryUserUsdtToReinvest(address user) public view returns(uint256) {
        (,uint256 usdtToReinvest,,,,,,,) = STTD.users(user);
        return usdtToReinvest;
    }

    function queryUserTokenToReinvest(address user) public view returns(uint256) {
        (,,uint256 tokenToReinvest,,,,,,) = STTD.users(user);
        return tokenToReinvest;
    }

    function queryUserTokensToReinvest(address user) public view returns(uint256 usdtToReinvest,uint256 tokenToReinvest) {
        (,usdtToReinvest,tokenToReinvest,,,,,,) = STTD.users(user);
        return (usdtToReinvest,tokenToReinvest);
    }

    function queryUserTotalUsdtToReinvest(address user) public view returns(uint256) {
        return queryUserUsdtToReinvest(user) + tokenEqualsToUsdt(queryUserTokenToReinvest(user));
    }

    function tokenEqualsToUsdt(uint256 tokenAmount) public view returns(uint256 usdtAmount) {
        uint256 tokenOfPair = ERC20(STTD.stt()).balanceOf(STTD.pair());
        uint256 usdtOfPair = ERC20(STTD.usdt()).balanceOf(STTD.pair());

        if(tokenOfPair > 0 && usdtOfPair > 0){
            usdtAmount = tokenAmount.mul(usdtOfPair).div(tokenOfPair);
        }

        return usdtAmount;
    }

    function usdtEqualsToToken(uint256 usdtAmount) public view returns(uint256 tokenAmount) {
        uint256 tokenOfPair = ERC20(STTD.stt()).balanceOf(STTD.pair());
        uint256 usdtOfPair =  ERC20(STTD.usdt()).balanceOf(STTD.pair());

        if(tokenOfPair > 0 && usdtOfPair > 0){
            tokenAmount = usdtAmount.mul(tokenOfPair).div(usdtOfPair);
        }

        return tokenAmount;
    }

    function queryInvestProfit(address user, uint256 types) public view returns(uint256) {

        uint256[] memory indexs = STTD.queryMyInvestRecords(user);

        uint256 nowTime = block.timestamp;
        uint256 freeCabinValue;
        uint256 freeCabinDrawTime;
        uint256 orbitalCabinValue;
        uint256 orbitalCabinDrawTime;
        uint256 investTime;
        uint256 gammaValue;
        uint256 profit;
        uint256 i;

        if(types == 1){//freeCabin
            for(i = 0; i < indexs.length; i++){
                (,,freeCabinValue,orbitalCabinValue,investTime,,freeCabinDrawTime,,) = STTD.investRecords(indexs[i]);
                if(freeCabinValue >= STTD.freeCabinValueRewardLimit() && ((freeCabinDrawTime > 0 && freeCabinDrawTime + 10 minutes < nowTime) || (freeCabinDrawTime == 0 && investTime + 10 minutes < nowTime))){
                    gammaValue = (freeCabinValue + orbitalCabinValue).mul(120).div(100);
                    profit += queryMineOutputs().mul(gammaValue).mul(10).div(STTD.totalGammaValue()).div(100);
                }
            }
        }else if(types == 2){//orbitalCabin
            for(i = 0; i < indexs.length; i++){
                (,,,orbitalCabinValue,,,,,orbitalCabinDrawTime) = STTD.investRecords(indexs[i]);
                if(orbitalCabinValue >= STTD.orbitalCabinValueRewardLimit() && ((orbitalCabinDrawTime > 0 && orbitalCabinDrawTime + 10 minutes < nowTime) || (orbitalCabinDrawTime == 0 && investTime + 10 minutes < nowTime))){
                    gammaValue = (freeCabinValue + orbitalCabinValue).mul(120).div(100);
                    profit += gammaValue.mul(25 * 10 **15).div(tokenEqualsToUsdt(10 **18));
                }
            }
        }

        return profit;
    }

    function queryInvestPrincipalCanDraw(address user, uint256 types) public view returns(uint256) {

        uint256[] memory indexs = STTD.queryMyInvestRecords(user);

        uint256 nowTime = block.timestamp;
        uint256 freeCabinValue;
        uint256 orbitalCabinValue;
        uint256 investTime;
        uint256 principal;
        uint256 i;

        if(types == 1){//freeCabin
            for(i = 0; i < indexs.length; i++){
                (,,freeCabinValue,,investTime,,,,) = STTD.investRecords(indexs[i]);
            
                // if(freeCabinValue > 0 && investTime + 24 hours < nowTime){
                //     principal += freeCabinValue;
                // }
                if(freeCabinValue > 0 && investTime + 1 hours < nowTime){
                    principal += freeCabinValue;
                }
            }
        }else if(types == 2){//orbitalCabin
            for(i = 0; i < indexs.length; i++){
                (,,,orbitalCabinValue,investTime,,,,) = STTD.investRecords(indexs[i]);

                // if(orbitalCabinValue > 0 && investTime + 20 days < nowTime){
                //     principal += orbitalCabinValue;
                // }
                if(orbitalCabinValue > 0 && investTime + 3 hours < nowTime){
                    principal += orbitalCabinValue;
                }
            }
        }

        return principal;
    }

    function queryMineOutputs() public view returns(uint256) {

        uint256 i;

        for(i = 4; i > 0; i--){
            if(STTD.totalPropulsiveCabinValue() > STTD.mineOutputLimits(i - 1)){
                return STTD.mineOutputs(i - 1);
            }
        }
        return 0;
    }

    function queryInviteRewardLevels(address user) public view returns(uint256) {

        uint256 inviteesNum = STTD.queryMyInviteesNum(user);
        uint256 i;

        for(i = 3; i > 0; i--){
            if(inviteesNum >= STTD.inviteesNumRewardLimits(i - 1)){
                return STTD.inviteRewardLevels(i - 1);
            }
        }
        return 0;
    } 

    function queryUserTeamLevel(address user) public view returns(uint256) {

        uint256 teamPropulsiveCabinValue = queryTeamPropulsiveCabinValue(user);
        uint256 i;

        for(i = 5; i > 0; i--){
            if(teamPropulsiveCabinValue > STTD.teamLevelLimits(i - 1)){
                return i;
            }
        }
        return 0;
    }

    function queryTeamInvitees(address user) public view returns(address[] memory teamInvitees) {

        address[] memory invitees0 = STTD.queryMyInvitees(user);
        address[] memory invitees1 = new address[](10000);
        address user0 = user;

        uint256 count0;
        uint256 count1;
        uint256 i;

        for(i = 0; i < invitees0.length; i++){
            if(count0 < 10000){
                invitees1[count0] = invitees0[i];
                count0++;
        
                do {
                    user0 = invitees1[count1];
                    count1++;
                    invitees0 = STTD.queryMyInvitees(user0);
                    i = 0;
                } while (count1 <= count0 && (invitees0.length == 0 || i + 1 == invitees0.length));
            }
        }

        teamInvitees = new address[](count0);

        for(i = 0; i < count0; i++){
            teamInvitees[i] = invitees1[i];
        }
    }

    function queryTeamInviteesNum(address user) public view returns(uint256 teamInviteesNum) {
        address[] memory teamInvitees = queryTeamInvitees(user);
        teamInviteesNum = teamInvitees.length;
    }

    function queryDirectInviteLevelNum(address user) public view returns(uint256[6] memory directInviteLevelsNum) {

        address[] memory invitees = STTD.queryMyInvitees(user);
        uint256 level;
        uint256 i;

        for(i = 0; i < invitees.length; i++){
            level = queryUserTeamLevel(invitees[i]);
            directInviteLevelsNum[level] += 1;
        }
        return directInviteLevelsNum;
    }

    function queryInviteLevelNum(address user) public view returns(uint256[6] memory inviteLevelsNum) {

        address[] memory invitees = queryTeamInvitees(user);
        uint256 level;
        uint256 i;

        for(i = 0; i < invitees.length; i++){
            level = queryUserTeamLevel(invitees[i]);
            inviteLevelsNum[level] += 1;
        }
        return inviteLevelsNum;
    }

    function queryTeamGammaValue(address user) public view returns(uint256 teamGammaValue) {

        address[] memory teamInvitees = queryTeamInvitees(user);
        uint256 i;

        for(i = 0; i < teamInvitees.length; i++){
            teamGammaValue += queryUserGammaValue(teamInvitees[i]);
        }

        teamGammaValue += queryUserGammaValue(user);
    }

    function queryTeamPropulsiveCabinValue(address user) public view returns(uint256 teamPropulsiveCabinValue) {

        address[] memory teamInvitees = queryTeamInvitees(user);
        uint256 i;

        for(i = 0; i < teamInvitees.length; i++){
            teamPropulsiveCabinValue += queryUserPropulsiveCabinValue(teamInvitees[i]);
        }

        teamPropulsiveCabinValue += queryUserPropulsiveCabinValue(user);
    }

    function queryUserTokenProfitToday(address user) public view returns(uint256 tokenProfitToday) {

        uint256 lastTime1 = queryUserLastTokenRecordIndexByTypes(user,11);
        uint256 lastTime2 = queryUserLastTokenRecordIndexByTypes(user,12);
        uint256 lastTime = lastTime1 > lastTime2? lastTime1 : lastTime2;
        
        if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
            tokenProfitToday = 0;
        }else{
            (,,,,tokenProfitToday,,,,) = STTD.users(user);
        }
    }

    function queryTeamTokenProfitToday(address user) public view returns(uint256 teamTokenProfitToday) {

        address[] memory teamInvitees = queryTeamInvitees(user);
        uint256 i;

        for(i = 0; i < teamInvitees.length; i++){
            teamTokenProfitToday += queryUserTokenProfitToday(teamInvitees[i]);
        }
    }

    function queryTeamTokenProfitTotal(address user) public view returns(uint256 teamTokenProfitTotal) {

        address[] memory teamInvitees = queryTeamInvitees(user);
        uint256 tokenProfitTotal;
        uint256 i;

        for(i = 0; i < teamInvitees.length; i++){
            (,,,tokenProfitTotal,,,,,) = STTD.users(user);
            teamTokenProfitTotal += tokenProfitTotal;
        }
    }

    function queryLastInvestRecordsTime() public view returns(uint256 investTime) {
        if(STTD.queryAllInvestRecordsNum() == 0){
            return 0;
        }
        (,,,,investTime,,,,) = STTD.investRecords(STTD.queryAllInvestRecordsNum() - 1);
    }

    function queryLastTokenRecordIndexByTypes(uint256 types) public view returns(uint256 index) {
        uint256 types0;
        uint256 i;

        for(i = STTD.queryAllTokenRecordsNum(); i > 0; i--){
            (,,,types0,) = STTD.tokenRecords(i - 1);
            if(types == types0){
                return i - 1;
            }
        }
        return 10 * 18;
    }

    function queryLastTokenRecordTimeByTypes(uint256 types) public view returns(uint256) {
        uint256 index = queryLastTokenRecordIndexByTypes(types);
        (,,,,uint256 time) = STTD.tokenRecords(index);
        return time;
    }

    function queryUserLastTokenRecordIndexByTypes(address user, uint256 types) public view returns(uint256 index) {

        uint256[] memory indexs = STTD.queryMyTokenRecords(user);

        uint256 types0;
        uint256 i;

        for(i = indexs.length; i > 0; i--){
            (,,,types0,) = STTD.tokenRecords(indexs[i - 1]);
            if(types == types0){
                return indexs[i - 1];
            }
        }
        return 10 * 18;
    }

    function queryUserLastTokenRecordTimeByTypes(address user, uint256 types) public view returns(uint256) {
        uint256 index = queryUserLastTokenRecordIndexByTypes(user,types);
        (,,,,uint256 time) = STTD.tokenRecords(index);
        return time;
    }

    function queryIsBindRecommender(address user) public view returns (bool){
        (,,,,,,,,address recommender) = STTD.users(user);
        if(recommender == address(0)){
            return false;
        }else{
            return true;
        }
    }

    function queryInviteLink(address user) public view returns (string memory inviteLink){
        if(queryUserPropulsiveCabinValue(user) > STTD.investUsdtLimit()){
            string memory addr = toString(user);

            if (user != address(0)) {
                inviteLink = string(abi.encodePacked(STTD.baseLink(), addr));
            }
        }
        return inviteLink;
    }

    function toString(address account) internal pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }


    function checkBindRecommender(address user, address recommender) public view returns (uint256){
        // require(users[msg.sender].recommender == address(0), "You have bound a recommender");
        // require(userGammaValue(recommender) > 0 && users[recommender].blackHoleValue > 0, "The address you bound is invalid");
        // require(msg.sender != recommender, "You can't bind yourself");
        // require(recommender != address(0) && recommender != deadWallet, "You can't bind address 0");
        if(queryUserRecommender(user) != address(0)) return 1;
        if(queryUserPropulsiveCabinValue(recommender) == 0) return 2;
        if(user == recommender) return 3;
        if(recommender == address(0) || recommender == STTD.deadWallet()) return 4;

        return 0;
    }

    function checkBuyBlackHoleValue(address user, uint256 usdtAmount) public view returns (uint256){
        // require(usdtAmount >= STTD.buyBlackHoleValueLimit(), "The buy amount is less than the minimum buy limit");
        // require(STTQ.queryUserRecommender(msg.sender) != address(0), "Please bind the recommender first");
        if(ERC20(STTD.usdt()).balanceOf(user) < usdtAmount) return 1;
        if(usdtAmount < STTD.buyBlackHoleValueLimit()) return 2;
        if(queryUserRecommender(user) == address(0)) return 3;

        return 0;
    }

    function checkPropulsiveCabin(address user, uint256 usdtAmount) public view returns (uint256){
        // require(ERC20(pair).balanceOf(msg.sender) >= lpTokensLimit, "You must add liquidity");
        // require(usdtAmount >= investUsdtLimit, "USDT amount below minimum limit");
        // require(STTD.queryUserBlackHoleValue(user) >= usdtAmount.mul(20).div(100),"Black hole value is insufficient");
        if(ERC20(STTD.pair()).balanceOf(user) < STTD.lpTokensLimit()) return 1;
        if(ERC20(STTD.usdt()).balanceOf(user) < usdtAmount) return 2;
        if(usdtAmount < STTD.investUsdtLimit()) return 3;
        if(queryUserBlackHoleValue(user) < usdtAmount.mul(20).div(100)) return 4;

        return 0;
    }

    function checkDrawInvestPrincipal(address user, uint256 types) public view returns (uint256){
        // require(ERC20(pair).balanceOf(msg.sender) >= lpTokensLimit, "You must add liquidity");
        // require(userFreeCabinValue(msg.sender) > 0, "You haven't invested");
        // require(principal > 0, "You have no principal to withdraw");
        if(ERC20(STTD.pair()).balanceOf(user) < STTD.lpTokensLimit()) return 1;
        if(queryInvestPrincipalCanDraw(user, types) == 0) return 2;

        return 0;
    }

    function checkDrawInvestProfit(address user, uint256 types) public view returns (uint256){
        // require(ERC20(pair).balanceOf(msg.sender) >= lpTokensLimit, "You must add liquidity");
        // require(userFreeCabinValue(msg.sender) > 0, "You haven't invested");
        // require(principal > 0, "You have no principal to withdraw");
        if(ERC20(STTD.pair()).balanceOf(user) < STTD.lpTokensLimit()) return 1;
        if(queryInvestProfit(user, types) == 0) return 2;

        return 0;
    }

    function checkUserTokenTransfer(address user, address to, uint256 sttAmount) public view returns (uint256){
        // require(STTD.queryMyInvestRecordsNum(msg.sender) > 0 && STTD.queryMyInvestRecordsNum(to) > 0 && amount > 0, "Transfer function is only available between platform users");
        if(STTD.queryMyInvestRecordsNum(user) == 0 || STTD.queryMyInvestRecordsNum(to) == 0) return 1;
        if(sttAmount < 10 ** 16) return 2;

        return 0;
    }



}
// File: STTController.sol



pragma solidity ^0.8.0;


interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

contract STTController is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);//addBlackHoleValues(address userAddr, uint256 usdtAmount)
    event AddBlackHoleValue(address account, uint256 costUsdt, uint256 blackHoleValueReceived);
    event PropulsiveCabin(address account, uint256 investUsdt, uint256 costBlackHoleValue);
    event DrawInvestPrincipal(address account, uint256 types, uint256 drawUsdtPrincipal);
    event DrawInvestProfit(address account, uint256 types, uint256 tokenProfit);
    event Reinvest(address account, uint256 investUsdt, uint256 costUsdt, uint256 costToken);
    event BindRecommender(address account, address recommender);
    event SwapForUsdtToThis(address account, uint256 initialUsdtBalance, uint256 newUsdtBalance, uint256 swapUsdts);

    address private deadWallet = 0x000000000000000000000000000000000000dEaD;

    ISwapRouter private swapRouter;
    
    STTData STTD;
    STTQuery STTQ;

    uint256 private constant MAX = ~uint256(0);

    uint private unlocked = 1;
    modifier lockTheSwap() {
        require(unlocked == 1, 'Pancake: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier permit(address operator) {
        require(!isContract(operator) && !STTQ.queryUserDisable(operator), "Not allowed");
        _;
    }

    constructor() {
        // swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapRouter = ISwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        // ERC20(STTD.stt()).approve(address(swapRouter), MAX);
        // ERC20(STTD.usdt()).approve(address(swapRouter), MAX);

        STTD = STTData(payable(address(0xA707b50f9bfC98d46870585387A1F595C0921507)));
        STTQ = STTQuery(address(0x04A320A158024617b47063b4B70dE58af550DBA5));
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function approveForRouter() public onlyOwner {
        ERC20(STTD.stt()).approve(address(swapRouter), MAX);
        ERC20(STTD.usdt()).approve(address(swapRouter), MAX);
    }

    function updateSTTD(address _sttd) public onlyOwner {
        STTD = STTData(payable(_sttd));
    }

    function updateSTTQ(address _sttq) public onlyOwner {
        STTQ = STTQuery(_sttq);
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function swapForToken(uint256 usdtAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(STTD.usdt());
        path[1] = address(STTD.stt());

        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of ETH
            path,
            address(to),
            block.timestamp
        );
    }

    function swapForUsdt(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(STTD.stt());
        path[1] = address(STTD.usdt());

        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(to),
            block.timestamp
        );
    }

    function bindRecommender(address recommender) public permit(msg.sender) {

        uint256 checkId = STTQ.checkBindRecommender(msg.sender, recommender);
        require(checkId == 0, 'Fail reason: checkId');

        STTD.bindRecommender(msg.sender,recommender);
        emit BindRecommender(msg.sender, recommender);
    }

    function buyBlackHoleValue(uint256 usdtAmount) public permit(msg.sender) {
        // require(usdtAmount >= STTD.buyBlackHoleValueLimit(), "The buy amount is less than the minimum buy limit");
        // require(STTQ.queryUserRecommender(msg.sender) != address(0), "Please bind the recommender first");
        uint256 checkId = STTQ.checkBuyBlackHoleValue(msg.sender, usdtAmount);
        require(checkId == 0, 'Fail reason: checkId');

        ERC20(STTD.usdt()).transferFrom(msg.sender,address(this),usdtAmount);
        _addBlackHoleValue(msg.sender, usdtAmount);
    }

    function _addBlackHoleValue(address userAddr, uint256 usdtAmount) private {

        swapForToken(usdtAmount, deadWallet);

        STTD.addUserBlackHoleValue(userAddr,usdtAmount);
        STTD.addUserTokenRecords(userAddr, 1, -int(usdtAmount), 1);

        emit AddBlackHoleValue(userAddr,usdtAmount,usdtAmount);
    }

    function propulsiveCabin(uint256 usdtAmount) public permit(msg.sender) {
        
        uint256 checkId = STTQ.checkPropulsiveCabin(msg.sender, usdtAmount);
        require(checkId == 0, 'Fail reason: checkId');

        ERC20(STTD.usdt()).transferFrom(msg.sender,address(this),usdtAmount);

        uint256 myInvestRecordsNum = STTD.queryMyInvestRecordsNum(msg.sender);

        if(myInvestRecordsNum == 0){
            STTD.addTotalUserAmount(1);
            uint256 lastTime = STTQ.queryLastInvestRecordsTime();
            if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
                STTD.addTodayNewUserAmount(1, true);
            }else{
                STTD.addTodayNewUserAmount(1, false);
            }
        }

        _propulsiveCabin(msg.sender, usdtAmount);
    }

    function _propulsiveCabin(address user, uint256 usdtAmount) private {

        uint256 needBlackHoleValue = usdtAmount.mul(20).div(100);
        
        STTD.subUserBlackHoleValue(user, needBlackHoleValue);

        STTD.addTotalGammaValue(usdtAmount.mul(120).div(100));
        STTD.addTotalPropulsiveCabinValue(usdtAmount);

        STTD.addUserInvestRecords(user, usdtAmount);
        STTD.addUserTokenRecords(user, 1, -int(usdtAmount), 2);

        emit PropulsiveCabin(user,usdtAmount,needBlackHoleValue);
    }

    function drawInvestPrincipal(uint256 types) public permit(msg.sender) {

        uint256 checkId = STTQ.checkDrawInvestPrincipal(msg.sender, types);
        require(checkId == 0, 'Fail reason: checkId');

        uint256 principal = STTQ.queryInvestPrincipalCanDraw(msg.sender, types);
        require(principal > 0, "You have no principal to withdraw");

        _drawInvestProfit(msg.sender, types);

        STTD.subTotalGammaValue(principal);
        STTD.subTotalPropulsiveCabinValue(principal);

        _addBlackHoleValue(msg.sender, principal.mul(10).div(60));
        
        STTD.addUserUsdtToReinvest(msg.sender, principal.mul(50).div(60));

        uint256 total = STTQ.queryUserTotalUsdtToReinvest(msg.sender);

        if(total > STTD.investUsdtLimit()){
            _reinvest(msg.sender);
        }

        _updateInvestRecords(msg.sender, types);

        ERC20(STTD.usdt()).transfer(msg.sender, principal.mul(40).div(100));

        STTD.addUserTokenRecords(msg.sender, 1, int(principal.mul(40).div(100)), types + 2);

        emit DrawInvestPrincipal(msg.sender,types,principal);
    }

    function drawInvesProfit(uint256 types) public permit(msg.sender) {

        uint256 checkId = STTQ.checkDrawInvestProfit(msg.sender, types);
        require(checkId == 0, 'Fail reason: checkId');

        _drawInvestProfit(msg.sender, types);

        _updateInvestRecords(msg.sender, types + 2);
    }

    function _drawInvestProfit(address user, uint256 types) private {

        uint256 profit = STTQ.queryInvestProfit(user, types);

        if(profit > 0){
            _updateInvestRecords(user, types + 2);
            ERC20(STTD.stt()).transfer(user, profit);

            STTD.addUserTokenProfitTotal(user, profit);

            uint256 lastTime = STTQ.queryUserLastTokenRecordTimeByTypes(user,types);
            if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
                STTD.addUserTokenProfitToday(user, profit, true);
            }else{
                STTD.addUserTokenProfitToday(user, profit, false);
            }

            STTD.addUserTokenToReinvest(user, profit.mul(60).div(100));

            // uint256 total = user.usdtToReinvest + tokenEqualsToUsdt(user.tokenToReinvest);
            uint256 total = STTQ.queryUserUsdtToReinvest(user);

            if(total > STTD.investUsdtLimit()){
                _reinvest(user);
            }

            _recommenderRewards(user, profit);
            _teamRewards(user, profit);

            STTD.addUserTokenRecords(msg.sender, 2, int(profit), types + 10);

            // STTD.addTotalMineOutput(profit);
            STTD.addTotalUserTokenProfit(profit);

            lastTime = STTQ.queryLastTokenRecordTimeByTypes(types);
            if(lastTime == 0 || block.timestamp.div(24 hours) - lastTime.div(24 hours) > 0){
                STTD.addTodayUserTokenProfit(profit, true);
            }else{
                STTD.addTodayUserTokenProfit(profit, false);
            }
        }

        emit DrawInvestProfit(msg.sender,types,profit);
    }

    function _reinvest(address user) private {

        (uint256 usdtToReinvest,uint256 tokenToReinvest) = STTQ.queryUserTokensToReinvest(user);

        uint256 swapUsdts = _swapForUsdtToThis(tokenToReinvest);

        uint256 total = usdtToReinvest + swapUsdts;

        STTD.subUserUsdtToReinvestTo0(user);
        STTD.subUserUsdtToReinvestTo0(user);

        _addBlackHoleValue(user, total.mul(10).div(60));

        _propulsiveCabin(user, total.mul(50).div(60));

        STTD.addUserTokenRecords(user, 1, -int(total), 2);
        STTD.addUserTokenRecords(user, 2, -int(tokenToReinvest), 5 + 10);

        emit Reinvest(user,total,usdtToReinvest,tokenToReinvest);
    }

    function _swapForUsdtToThis(uint256 tokens) private lockTheSwap returns(uint256) {
        uint256 initialUsdtBalance = ERC20(STTD.usdt()).balanceOf(address(this));
        swapForUsdt(tokens, address(this));
        uint256 swapUsdts = ERC20(STTD.usdt()).balanceOf(address(this)).sub(initialUsdtBalance);

        emit SwapForUsdtToThis(msg.sender,initialUsdtBalance,ERC20(STTD.usdt()).balanceOf(address(this)),swapUsdts);

        return swapUsdts;
    }

    function _updateInvestRecords(address user, uint256 types) private {

        uint256[] memory indexs = STTD.queryMyInvestRecords(user);
        uint256 gammaValue;

        uint256 nowTime = block.timestamp;
        uint256 profit;
        uint256 i;

        uint256 freeCabinValue;
        uint256 orbitalCabinValue;
        uint256 investTime;
        uint256 freeCabinDrawTime;
        uint256 orbitalCabinDrawTime;
        if(types == 1){//freeCabin
            for(i = 0; i < indexs.length; i++){
                (,,freeCabinValue,orbitalCabinValue,investTime,,,,) = STTD.investRecords(indexs[i]);
                if(freeCabinValue >= STTD.freeCabinValueRewardLimit() && investTime + 24 hours < nowTime){
                    gammaValue = (freeCabinValue + orbitalCabinValue).mul(60).div(50);
                    profit = STTQ.queryMineOutputs().mul(gammaValue).mul(10).div(STTD.totalGammaValue()).div(100);
                    
                    STTD.addFreeCabinTokenReward(user,indexs[i],profit,nowTime);
                    STTD.subFreeCabinValueTo0(user,indexs[i]);
                }
            }
        }else if(types == 2){//orbitalCabin
            for(i = 0; i < indexs.length; i++){
                (,,freeCabinValue,orbitalCabinValue,investTime,,,,) = STTD.investRecords(indexs[i]);
                if(orbitalCabinValue >= STTD.orbitalCabinValueRewardLimit() && investTime + 20 days < nowTime){
                    gammaValue = (freeCabinValue + orbitalCabinValue).mul(60).div(50);
                    profit = gammaValue.mul(25).div(STTQ.tokenEqualsToUsdt(10 **21));
                    
                    STTD.addOrbitalCabinTokenReward(user,indexs[i],profit,nowTime);
                    STTD.subOrbitalCabinValueTo0(user,indexs[i]);
                }
            }
        }else if(types == 3){//freeCabin
            for(i = 0; i < indexs.length; i++){
                (,,freeCabinValue,orbitalCabinValue,investTime,,freeCabinDrawTime,,) = STTD.investRecords(indexs[i]);
                if(freeCabinValue >= STTD.freeCabinValueRewardLimit() && ((freeCabinDrawTime > 0 && freeCabinDrawTime + 24 < nowTime) || (freeCabinDrawTime == 0 && investTime + 24 < nowTime))){
                    gammaValue = (freeCabinValue + orbitalCabinValue).mul(60).div(50);
                    profit = STTQ.queryMineOutputs().mul(gammaValue).mul(10).div(STTD.totalGammaValue()).div(100);
                    
                    STTD.addFreeCabinTokenReward(user,indexs[i],profit,nowTime);
                }
            }
        }else if(types == 4){//orbitalCabin
            for(i = 0; i < indexs.length; i++){
                (,,freeCabinValue,orbitalCabinValue,investTime,,freeCabinDrawTime,,orbitalCabinDrawTime) = STTD.investRecords(indexs[i]);
                if(orbitalCabinValue >= STTD.orbitalCabinValueRewardLimit() && ((orbitalCabinDrawTime > 0 && orbitalCabinDrawTime + 24 < nowTime) || (orbitalCabinDrawTime == 0 && investTime + 24 < nowTime))){
                    gammaValue = (freeCabinValue + orbitalCabinValue).mul(60).div(50);
                    profit = gammaValue.mul(25).div(STTQ.tokenEqualsToUsdt(10 **21));
                    
                    STTD.addOrbitalCabinTokenReward(user,indexs[i],profit,nowTime);
                }
            }
        }
    }

    function _recommenderRewards(address user, uint256 reward) private {

        address recommender;
        uint256 generation;
        uint256 rewards;
        uint256 i;

        for(i = 0; i < 6; i++){
            recommender = STTQ.queryUserRecommender(user);
            generation = STTQ.queryInviteRewardLevels(recommender);
            if(i < generation){
                rewards = reward.mul(STTD.inviteLevelRewardRates(i)).div(100);
                ERC20(STTD.stt()).transfer(recommender, rewards);
                STTD.addUserInviteRewardTotal(recommender, rewards);
                STTD.addUserTokenRecords(recommender, 2, int(rewards), 3 + 10);
            }
            user = recommender;
        }
    }

    function _teamRewards(address user, uint256 reward) private {

        address recommender;
        uint256 teamLevel;
        uint256 rewards;
        uint256 i;

        for(i = 0; i < 10000; i++){
            recommender = STTQ.queryUserRecommender(user);
            if(recommender == address(0)){
                break;
            }else{
                teamLevel = STTQ.queryUserTeamLevel(recommender);
                if(teamLevel > 0){
                    rewards = reward.mul(STTD.teamLevelRewardRates(teamLevel - 1)).div(100);
                    ERC20(STTD.stt()).transfer(recommender, rewards);
                    STTD.addUserInviteRewardTotal(recommender, rewards);
                    STTD.addUserTokenRecords(recommender, 2, int(rewards), 4 + 10);
                }
                user = recommender;
            }
        }
    }

    function userTokenTransfer(address to, uint256 sttAmount) public permit(msg.sender) {
        // require(STTD.queryMyInvestRecordsNum(msg.sender) > 0 && STTD.queryMyInvestRecordsNum(to) > 0 && amount > 0, "Transfer function is only available between platform users");
        uint256 checkId = STTQ.checkUserTokenTransfer(msg.sender, to, sttAmount);
        require(checkId == 0, 'Fail reason: checkId');

        ERC20(STTD.stt()).transferFrom(msg.sender, to, sttAmount);

        STTD.addUserTokenRecords(msg.sender, 2, -int(sttAmount), 6 + 10);
        STTD.addUserTokenRecords(to, 2, int(sttAmount), 6 + 10);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    

}