/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// File: contracts/router.sol

// contracts/GLDToken.sol

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}
// File: contracts/icbe.sol

// contracts/GLDToken.sol

pragma solidity ^0.8.0;

interface ICBE {
    /// activete account
    function activateAccount(address inviter) external payable;

    /// whether account activated or not
    function accountActivated(address who) external view returns(bool);

    /// take mining rewards
    function takeMiningRewards() external;

    /// get available minging rewards to take
    function getAvailableMingingRewards(address who) external view returns (uint256);

    /// get invited account count of user
    function getInvitedAccountCount(address who) external view returns (uint256);

    /// get invited account with page supported
    function getInvitedAccount(
        address who,
        uint256 page,
        uint256 pageCount
    ) external view returns (address[] memory);

    /// get total minters
    function getMinterCount() external view returns(uint256);

    /// get total power of contract
    function getTotalPower() external view returns (uint256);

    /// get specified account power
    function getAccountPower(address who) external view returns (uint256);

    /// account activated event
    event AccountActivated(address inviter, uint256 timestamp);

    /// mining reward taken event
    event MiningRewardTaken(address who, uint256 amount);

    /// mining power update event
    event PowerUpdated(address owner, uint256 newPower);

    /// fee added to pool event
    event FeeAddedToPool(uint256 amountWETH, uint256 token);

    /// mining stopped event
    event MiningStopped(uint256);

    /// owner rward, all mining tokens * 20%
    event OwnerRewardAdded(uint256 time, uint256 amount);
}

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

// File: contracts/mining.sol

// contracts/GLDToken.sol

pragma solidity ^0.8.0;


contract Mining {
    using SafeMath for uint256;

    /// total power of contract
    uint256 private _totalPower;

    /// every power of account
    mapping(address=>uint256) private _accountMiningPower;

    /// available mining rewards to claim
    mapping(address=>uint256) private _availableMiningRewards;

    /// mining power update timestamp
    mapping(address=>uint256) private _mingingPowerUpdateTime;

    /// mining 1 token for 1 power every day
    uint256 private constant _oneToken = 1e18;

    /// minging tokens for 1 power each second
    uint256 private _tokenPerSecond = _oneToken.div(24).div(60).div(60);

    /// whether mining stopped timestamp
    /// 0 means not stopped now
    uint256 private _miningStoppedTime = 0;

    /// mining power updated event
    event MiningPowerUpdated(address who, uint256 power);

    constructor() {
        _totalPower = 0;
    }

    /// increase account minming power
    function increaseAccountMiningPowerInternal(address who, uint256 power) internal {
        // update rewards before mining power updated
        _updateAvailableMingingReward(who);

        // update mining power
        _accountMiningPower[who] = _accountMiningPower[who].add(power);
        _mingingPowerUpdateTime[who] = block.timestamp;
        _totalPower = _totalPower.add(power);

        emit MiningPowerUpdated(who, _accountMiningPower[who]);
    }

    /// get available mining rewards to cleam
    function getAvailableMingingRewardsInternal(address who) view internal returns(uint256) {
        uint256 lasttime = block.timestamp;

        if (_miningStoppedTime != 0) {
            lasttime = _miningStoppedTime;
        }

        uint256 amount = lasttime.sub(_mingingPowerUpdateTime[who]).mul(_tokenPerSecond).mul(_accountMiningPower[who]);

        return amount.add(_availableMiningRewards[who]);
    }

    /// take available rewards, only clear data, caller should transfer real token to `who`
    function claimAvailableRewardsInternal(address who) internal returns(uint256) {
        uint256 newAmount = getAvailableMingingRewardsInternal(who);
        _availableMiningRewards[who] = 0;

        uint256 updateTime = block.timestamp;

        if (_miningStoppedTime != 0) {
            updateTime = _miningStoppedTime;
        }

        _mingingPowerUpdateTime[who] = updateTime; // recalculate rewards from now on

        return newAmount;
    }

    /// get accounts' ming power
    function getAccountMiningPowerInternal(address who) view internal returns(uint256) {
        return _accountMiningPower[who];
    }

    /// get total mining power
    function getTotalMiningPowerInternal() view internal returns(uint256) {
        return _totalPower;
    }

    function setStoppedInternal(uint256 timestamp) internal {
        _miningStoppedTime = timestamp;
    }

    /// update available mining reward data
    function _updateAvailableMingingReward(address who) private {
        uint256 newAmount = getAvailableMingingRewardsInternal(who);
        _availableMiningRewards[who] = newAmount;

        uint256 updateTime = block.timestamp;

        if (_miningStoppedTime != 0) {
            updateTime = _miningStoppedTime;
        }

        _mingingPowerUpdateTime[who] = updateTime; // recalculate rewards from now on
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

// File: contracts/cbe.sol

// contracts/GLDToken.sol

pragma solidity ^0.8.0;






contract CBEToken is ERC20, ICBE, Mining {
    using SafeMath for uint256;

    address private constant PANCAKE_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;   // testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
                                                                                                    // mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    address private constant BLACK_HOLE_ADDRESS = 0x000000000000000000000000000000000000dEaD;       // bsc zero address
    uint256 public constant ACTIVATE_FEE = 5e15 wei;                    // activate fee
    uint256 public constant BASIC_MINGING_POWER = 200_000;              // activate basic mining power
    uint256 public constant INVITER_REWARD_MINING_POWER = 20_000;       // inviter reward mining power
    uint256 public constant GRANDINVITER_REWARD_MINING_POWER = 10_000;  // grand inviter reward mining power
    uint256 public constant MAX_MINTER_COUNT = 1000_000;                // minters at 
    uint256 public constant BURN_RATE = 1;                              // 1% of transfer amount will be burned
    uint256 public constant POOL_RATE = 2;                              // 2% of transfer amount send to pool
    uint256 public constant MIN_TOKEN_TO_POOL = 1_000_000e18;           // minimul token counts to pool

    /// account invitation record
    mapping(address=>address) private _invitees;

    /// account invitation list
    mapping(address=>address[]) private _invited;

    /// whether account is activated
    mapping(address=>bool) private _accountActivated;

    /// all activated adresses
    address[] private _activatedAddress;

    /// wether in swap or not
    bool private _inSwap;

    /// contract owner
    address private _owner;

    /// swap router
    IUniswapV2Router02 public router;

    /// created pair
    address public pair;

    /// fee collected to add to pool
    uint256 private _totalTokenToPool;

    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor() ERC20("CBE Token", "CBE") {
        _owner = msg.sender;
        _accountActivated[_owner] = true;   // only used to invite users, do not own ming power

        router = IUniswapV2Router02(PANCAKE_ROUTER_ADDRESS);
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
    }

    /// activete account
    function activateAccount(address inviter) public payable override {
        require(_activatedAddress.length < MAX_MINTER_COUNT, "CBE:minter pool is full");
        require(_accountActivated[msg.sender] == false, "CBE:You have already activated");
        require(msg.value >= ACTIVATE_FEE, "CBE:You must provide 0.005 bnb to activate account");
        require(inviter != address(0) && _accountActivated[inviter], "CBE:Inviter must be activated");

        // transfer token to owner
        (bool succeed, ) = _owner.call{value: msg.value}("");
        require(succeed, "CBE:Failed to withdraw Ether");

        _accountActivated[msg.sender] = true;
        _activatedAddress.push(msg.sender);
        increaseAccountMiningPowerInternal(msg.sender, BASIC_MINGING_POWER);
        emit AccountActivated(msg.sender, block.timestamp);

        // update inviter calculation
        if (inviter != address(0x0) && _accountActivated[inviter]) {
            _invitees[msg.sender] = inviter;
            _invited[inviter].push(msg.sender);

            increaseAccountMiningPowerInternal(inviter, INVITER_REWARD_MINING_POWER);
        }
        
        // update grandparent calculation
        address parentInviter = _invitees[inviter];
        if (parentInviter != address(0) && _accountActivated[parentInviter]) {
            increaseAccountMiningPowerInternal(parentInviter, GRANDINVITER_REWARD_MINING_POWER);
        }

        // minter pool is full, stop minting and mint 20% for owner
        if (_activatedAddress.length >= MAX_MINTER_COUNT) {
            setStoppedInternal(block.timestamp);
            uint256 amount = totalSupply().mul(20).div(100);

            _mint(_owner, amount); // mint 20% of total supply for owner
            emit MiningStopped(block.timestamp);
            emit OwnerRewardAdded(block.timestamp, amount);
        }
    }

    /// take mining rewards
    function takeMiningRewards() public override {
        uint256 amounts = claimAvailableRewardsInternal(msg.sender);
        _mint(msg.sender, amounts);
        emit MiningRewardTaken(msg.sender, amounts);

        // mining is finished, but minging rewards which not taken should mint 20% to owner
        if (_activatedAddress.length >= MAX_MINTER_COUNT) {
            uint256 tokens = amounts.mul(20).div(100);

            _mint(_owner, tokens); // mint 20% of rewards to owner
            emit OwnerRewardAdded(block.timestamp, tokens);
        }
    }

    /// get available minging rewards to take
    function getAvailableMingingRewards(address who) public view override returns (uint256) {
        return getAvailableMingingRewardsInternal(who);
    }

    /// get invited account count of user
    function getInvitedAccountCount(address who) public view override returns (uint256) {
        return _invited[who].length;
    }

    /// whether account activated or not
    function accountActivated(address who) public view override returns(bool) {
        return _accountActivated[who];
    }

    /// get invited account with page supported
    function getInvitedAccount(
        address who,
        uint256 page,
        uint256 pageCount
    ) public view override returns (address[] memory) {
        uint256 invitedCount = getInvitedAccountCount(who);
        uint256 startIndex = page.mul(pageCount);
        require(
            startIndex < invitedCount,
            "CBE:getInvitedAccountWithPaged: page parameter error"
        );

        if (startIndex.add(pageCount) > invitedCount) {
            pageCount = invitedCount.sub(startIndex);
        }

        uint256 finishIndex = startIndex.add(pageCount);
        address[] memory result = new address[](pageCount);
        uint256 index = 0;
        for (uint256 i = startIndex; i < finishIndex; i++) {
            result[index++] = _invited[who][i];
        }
        return result;
    }

    /// get total power of contract
    function getTotalPower() public view override returns (uint256) {
        return getTotalMiningPowerInternal();
    }

    /// get specified account power
    function getAccountPower(address who) public view override returns (uint256) {
        return getAccountMiningPowerInternal(who);
    }

    /// get minter count
    function getMinterCount() public view override returns(uint256) {
        return _activatedAddress.length;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(from != address(0), "CBE: transfer from the zero address");
        require(to != address(0), "CBE: transfer to the zero address");

        uint256 amountToBurn = amount.mul(BURN_RATE).div(100);
        uint256 amountToAddToPool = amount.mul(POOL_RATE).div(100);
        uint256 remain = amount.sub(amountToBurn).sub(amountToAddToPool);

        super._transfer(from, BLACK_HOLE_ADDRESS, amountToBurn);
        super._transfer(from, address(this), amountToAddToPool);
        super._transfer(from, to, remain);

        _totalTokenToPool = _totalTokenToPool.add(amountToAddToPool);
        if (_totalTokenToPool >= MIN_TOKEN_TO_POOL && from != pair) {
            _swapTokenAndAddToPool();
        }
    }

    function _swapTokenAndAddToPool() internal lockTheSwap {
        uint256 balanceBefore = address(this).balance;
        uint256 half = _totalTokenToPool.div(2);    // half token need swap to WETH
        require(half > 0, "CBE: Too less token to add to pool");

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = router.WETH();       
        
        _approve(address(this), address(router), _totalTokenToPool);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0,
            sellPath,
            address(this),
            block.timestamp
        );

        uint256 amountWETHSwapped = address(this).balance.sub(balanceBefore);
        router.addLiquidityETH{value: amountWETHSwapped}(
            address(this),
            half,
            0,
            0,
            _owner,
            block.timestamp
        );
        emit FeeAddedToPool(amountWETHSwapped, half);

        _totalTokenToPool = 0;
    }
}