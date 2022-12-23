/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: GNU GPLv3

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


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


contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
     * All two of these values are: they can only be set once during
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, without an overflow flag
     * @dev Returns zero if overflow does occurs
     */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (b > a) return 0;
            return a - b;
        }
    }
}


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}


library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}


library ABDKMath64x64 {
    /*
     * Minimum value signed 64.64-bit fixed point number may have. 
     */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
     * Maximum value signed 64.64-bit fixed point number may have. 
     */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromInt (int256 x) internal pure returns (int128) {
        unchecked {
            require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
            return int128 (x << 64);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64-bit integer number
     */
    function toInt (int128 x) internal pure returns (int64) {
        unchecked {
            return int64 (x >> 64);
        }
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromUInt (uint256 x) internal pure returns (int128) {
        unchecked {
            require (x <= 0x7FFFFFFFFFFFFFFF);
            return int128 (int256 (x << 64));
        }
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return unsigned 64-bit integer number
     */
    function toUInt (int128 x) internal pure returns (uint64) {
        unchecked {
            require (x >= 0);
            return uint64 (uint128 (x >> 64));
        }
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function from128x128 (int256 x) internal pure returns (int128) {
        unchecked {
            int256 result = x >> 64;
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 128.128 fixed point number
     */
    function to128x128 (int128 x) internal pure returns (int256) {
        unchecked {
            return int256 (x) << 64;
        }
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function add (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) + y;
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sub (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) - y;
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function mul (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) * y >> 64;
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y signed 256-bit integer number
     * @return signed 256-bit integer number
     */
    function muli (int128 x, int256 y) internal pure returns (int256) {
        unchecked {
            if (x == MIN_64x64) {
                require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
                    y <= 0x1000000000000000000000000000000000000000000000000);
                return -y << 63;
            } else {
                bool negativeResult = false;
                if (x < 0) {
                    x = -x;
                    negativeResult = true;
                }
                if (y < 0) {
                    y = -y; // We rely on overflow behavior here
                    negativeResult = !negativeResult;
                }
                uint256 absoluteResult = mulu (x, uint256 (y));
                if (negativeResult) {
                    require (absoluteResult <=
                        0x8000000000000000000000000000000000000000000000000000000000000000);
                    return -int256 (absoluteResult); // We rely on overflow behavior here
                } else {
                    require (absoluteResult <=
                        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                    return int256 (absoluteResult);
                }
            }
        }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y unsigned 256-bit integer number
     * @return unsigned 256-bit integer number
     */
    function mulu (int128 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            if (y == 0) return 0;

            require (x >= 0);

            uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
            uint256 hi = uint256 (int256 (x)) * (y >> 128);

            require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            hi <<= 64;

            require (hi <=
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
            return hi + lo;
        }
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            require (y != 0);
            int256 result = (int256 (x) << 64) / y;
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
     * @param y signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divi (int256 x, int256 y) internal pure returns (int128) {
        unchecked {
            require (y != 0);

            bool negativeResult = false;
            if (x < 0) {
                x = -x; // We rely on overflow behavior here
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
            if (negativeResult) {
                require (absoluteResult <= 0x80000000000000000000000000000000);
                return -int128 (absoluteResult); // We rely on overflow behavior here
            } else {
                require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int128 (absoluteResult); // We rely on overflow behavior here
            }
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divu (uint256 x, uint256 y) internal pure returns (int128) {
        unchecked {
            require (y != 0);
            uint128 result = divuu (x, y);
            require (result <= uint128 (MAX_64x64));
            return int128 (result);
        }
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function neg (int128 x) internal pure returns (int128) {
        unchecked {
            require (x != MIN_64x64);
            return -x;
        }
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function abs (int128 x) internal pure returns (int128) {
        unchecked {
            require (x != MIN_64x64);
            return x < 0 ? -x : x;
        }
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function inv (int128 x) internal pure returns (int128) {
        unchecked {
            require (x != 0);
            int256 result = int256 (0x100000000000000000000000000000000) / x;
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function avg (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            return int128 ((int256 (x) + int256 (y)) >> 1);
        }
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function gavg (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 m = int256 (x) * int256 (y);
            require (m >= 0);
            require (m <
                0x4000000000000000000000000000000000000000000000000000000000000000);
            return int128 (sqrtu (uint256 (m)));
        }
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y uint256 value
     * @return signed 64.64-bit fixed point number
     */
    function pow (int128 x, uint256 y) internal pure returns (int128) {
        unchecked {
            bool negative = x < 0 && y & 1 == 1;

            uint256 absX = uint128 (x < 0 ? -x : x);
            uint256 absResult;
            absResult = 0x100000000000000000000000000000000;

            if (absX <= 0x10000000000000000) {
                absX <<= 63;
                while (y != 0) {
                    if (y & 0x1 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x2 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x4 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x8 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    y >>= 4;
                }

                absResult >>= 64;
            } else {
                uint256 absXShift = 63;
                if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
                if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
                if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
                if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
                if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
                if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

                uint256 resultShift = 0;
                while (y != 0) {
                    require (absXShift < 64);

                    if (y & 0x1 != 0) {
                        absResult = absResult * absX >> 127;
                        resultShift += absXShift;
                        if (absResult > 0x100000000000000000000000000000000) {
                            absResult >>= 1;
                            resultShift += 1;
                        }
                    }
                    absX = absX * absX >> 127;
                    absXShift <<= 1;
                    if (absX >= 0x100000000000000000000000000000000) {
                        absX >>= 1;
                        absXShift += 1;
                    }

                    y >>= 1;
                }

                require (resultShift < 64);
                absResult >>= 64 - resultShift;
            }
            int256 result = negative ? -int256 (absResult) : int256 (absResult);
            require (result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sqrt (int128 x) internal pure returns (int128) {
        unchecked {
            require (x >= 0);
            return int128 (sqrtu (uint256 (int256 (x)) << 64));
        }
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function log_2 (int128 x) internal pure returns (int128) {
        unchecked {
            require (x > 0);

            int256 msb = 0;
            int256 xc = x;
            if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
            if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
            if (xc >= 0x10000) { xc >>= 16; msb += 16; }
            if (xc >= 0x100) { xc >>= 8; msb += 8; }
            if (xc >= 0x10) { xc >>= 4; msb += 4; }
            if (xc >= 0x4) { xc >>= 2; msb += 2; }
            if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

            int256 result = msb - 64 << 64;
            uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
            for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
                ux *= ux;
                uint256 b = ux >> 255;
                ux >>= 127 + b;
                result += bit * int256 (b);
            }

            return int128 (result);
        }
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function ln (int128 x) internal pure returns (int128) {
        unchecked {
            require (x > 0);

            return int128 (int256 (
                uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
        }
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp_2 (int128 x) internal pure returns (int128) {
        unchecked {
            require (x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            uint256 result = 0x80000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0)
                result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
            if (x & 0x4000000000000000 > 0)
                result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
            if (x & 0x2000000000000000 > 0)
                result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
            if (x & 0x1000000000000000 > 0)
                result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
            if (x & 0x800000000000000 > 0)
                result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
            if (x & 0x400000000000000 > 0)
                result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
            if (x & 0x200000000000000 > 0)
                result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
            if (x & 0x100000000000000 > 0)
                result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
            if (x & 0x80000000000000 > 0)
                result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
            if (x & 0x40000000000000 > 0)
                result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
            if (x & 0x20000000000000 > 0)
                result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
            if (x & 0x10000000000000 > 0)
                result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
            if (x & 0x8000000000000 > 0)
                result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
            if (x & 0x4000000000000 > 0)
                result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
            if (x & 0x2000000000000 > 0)
                result = result * 0x1000162E525EE054754457D5995292026 >> 128;
            if (x & 0x1000000000000 > 0)
                result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
            if (x & 0x800000000000 > 0)
                result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
            if (x & 0x400000000000 > 0)
                result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
            if (x & 0x200000000000 > 0)
                result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
            if (x & 0x100000000000 > 0)
                result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
            if (x & 0x80000000000 > 0)
                result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
            if (x & 0x40000000000 > 0)
                result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
            if (x & 0x20000000000 > 0)
                result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
            if (x & 0x10000000000 > 0)
                result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
            if (x & 0x8000000000 > 0)
                result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
            if (x & 0x4000000000 > 0)
                result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
            if (x & 0x2000000000 > 0)
                result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
            if (x & 0x1000000000 > 0)
                result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
            if (x & 0x800000000 > 0)
                result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
            if (x & 0x400000000 > 0)
                result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
            if (x & 0x200000000 > 0)
                result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
            if (x & 0x100000000 > 0)
                result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
            if (x & 0x80000000 > 0)
                result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
            if (x & 0x40000000 > 0)
                result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
            if (x & 0x20000000 > 0)
                result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
            if (x & 0x10000000 > 0)
                result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
            if (x & 0x8000000 > 0)
                result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
            if (x & 0x4000000 > 0)
                result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
            if (x & 0x2000000 > 0)
                result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
            if (x & 0x1000000 > 0)
                result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
            if (x & 0x800000 > 0)
                result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
            if (x & 0x400000 > 0)
                result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
            if (x & 0x200000 > 0)
                result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
            if (x & 0x100000 > 0)
                result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
            if (x & 0x80000 > 0)
                result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
            if (x & 0x40000 > 0)
                result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
            if (x & 0x20000 > 0)
                result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
            if (x & 0x10000 > 0)
                result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
            if (x & 0x8000 > 0)
                result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
            if (x & 0x4000 > 0)
                result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
            if (x & 0x2000 > 0)
                result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
            if (x & 0x1000 > 0)
                result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
            if (x & 0x800 > 0)
                result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
            if (x & 0x400 > 0)
                result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
            if (x & 0x200 > 0)
                result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
            if (x & 0x100 > 0)
                result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
            if (x & 0x80 > 0)
                result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
            if (x & 0x40 > 0)
                result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
            if (x & 0x20 > 0)
                result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
            if (x & 0x10 > 0)
                result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
            if (x & 0x8 > 0)
                result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
            if (x & 0x4 > 0)
                result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
            if (x & 0x2 > 0)
                result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
            if (x & 0x1 > 0)
                result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

            result >>= uint256 (int256 (63 - (x >> 64)));
            require (result <= uint256 (int256 (MAX_64x64)));

            return int128 (int256 (result));
        }
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp (int128 x) internal pure returns (int128) {
        unchecked {
            require (x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            return exp_2 (
                int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return unsigned 64.64-bit fixed point number
     */
    function divuu (uint256 x, uint256 y) private pure returns (uint128) {
        unchecked {
            require (y != 0);

            uint256 result;

            if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                result = (x << 64) / y;
            else {
                uint256 msb = 192;
                uint256 xc = x >> 192;
                if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
                if (xc >= 0x10000) { xc >>= 16; msb += 16; }
                if (xc >= 0x100) { xc >>= 8; msb += 8; }
                if (xc >= 0x10) { xc >>= 4; msb += 4; }
                if (xc >= 0x4) { xc >>= 2; msb += 2; }
                if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

                result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
                require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 hi = result * (y >> 128);
                uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 xh = x >> 192;
                uint256 xl = x << 64;

                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here
                lo = hi << 128;
                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here

                assert (xh == hi >> 128);

                result += xl / y;
            }

            require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return uint128 (result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
     * @return unsigned 128-bit integer number
     */
    function sqrtu (uint256 x) private pure returns (uint128) {
        unchecked {
            if (x == 0) return 0;
            else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
                if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
                if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
                if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
                if (xx >= 0x100) { xx >>= 8; r <<= 4; }
                if (xx >= 0x10) { xx >>= 4; r <<= 2; }
                if (xx >= 0x8) { r <<= 1; }
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return uint128 (r < r1 ? r : r1);
            }
        }
    }
}


library IterableMapping {

    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping (address => uint) values;
        mapping (address => uint) indexOf;
        mapping (address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}


contract Nabana is ERC20, Ownable {
    using SafeMath for uint256;

    address public feeWallet = 0x1C2D9AE254359C9379EAFbFBD0be43Cd167a1595;

    address public nabanaVesting;

    NabanaDividendTracker public dividendTracker;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public purchaseFee;
    uint256 public sellFee;

    // min/max sell amounts
    uint256 public maxSellTransactionAmount = 1_000_000 * (10 ** 18);
    uint256 public minSellTransactionAmount = 10_000 * (10 ** 18);

    // handle limit variables
    uint256 public handleLimitCriteria = 1;
    uint256 public handleLimitMax = 20;
    uint256 public handleLimitTime = 86400;

    // use by default 600,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 450_000;
    uint256 public gasForProcessingIndividual = 150_000;

    // addresses for minting/vesting
    address private constant pancakeSwapLaunchWallet = 0xE2BBF4D2931eae2f11655905b4A17d8367064F86;
    address private constant airdropsWallet = 0xc8059f98A1E337ae193Ea9B2a09AfA2E68315A3C;
    address private constant privateInvestorsWallet = 0x57b5311745c21a900C051722Eb748C29cb135bB3;
    address private constant managementAllocationWallet = 0x49E695A35bd65C735BB2b0033e77205b4C8cf02c;
    address private constant advisorsWallet = 0x20027f3D87D107d7a5A304A940f3A63F98E67298;
    address private constant influencersWallet = 0x3d574DE90E80b9Ce7CC48aC9520bDC9d19e549E4;
    address private constant strategicPartnersWallet = 0xA0f77506698e9e2F5919fbbC76c362a0e41555f3;
    address private constant rewardsIncentivesWallet = 0xa9E8627F2c78992de6aF3c76120625930E1A826F;
    address private constant reserveWallet = 0xFA38bFA8D5f3B4FB2E3B410F86a27776Ab3AAb4d;
    address private constant operationsWallet = 0x572B508B44e53D48220ea9f6fF1021CAD049DffD;

    // struct for selling limit
    struct Limiter {
        address walletAddress;
        uint256 sellTransactionRecordedTime;
        uint256 sellTransactionTotalAmount;
    }

    // exlcuded from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // blacklisted from sending and recieving transactions
    mapping (address => bool) private _isBlacklisted;

    // limited from bulk selling
    mapping (address => Limiter) private _limitedUsers;

    // LP pairs, could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    // events

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event BlackListAddress(address indexed account, bool isBlackListed);

    event BlackListMultipleAddresses(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event GasForProcessingUpdated(uint256 newGas, uint256 oldGas, uint256 newGasIndividual, uint256 oldGasIndividual);

    event SendDividends(uint256 amount);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        uint256 lastProcessedInvestment,
        bool manual,
        uint256 gas,
        address indexed processor
    );

    event ProcessedAccountDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 processedIndex,
        uint256 processedInvestment,
        bool manual,
        uint256 gas,
        address indexed processor
    );

    // constructor

    /**
     * @dev Structured with the assumption that 'owner' will not deploy
     * @dev 'owner' and 'feeWallet' are assumed to be the same during deployment
     */
    constructor(address _nabanaVesting) ERC20("Nabana", "BANA") {
        nabanaVesting = _nabanaVesting;

    	dividendTracker = new NabanaDividendTracker(address(this));

    	uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        purchaseFee = 300;
        sellFee = 500;

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(msg.sender);
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(feeWallet);
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(nabanaVesting);
        dividendTracker.excludeFromDividends(pancakeSwapLaunchWallet);
        dividendTracker.excludeFromDividends(airdropsWallet);
        dividendTracker.excludeFromDividends(privateInvestorsWallet);
        dividendTracker.excludeFromDividends(managementAllocationWallet);
        dividendTracker.excludeFromDividends(advisorsWallet);
        dividendTracker.excludeFromDividends(influencersWallet);
        dividendTracker.excludeFromDividends(strategicPartnersWallet);
        dividendTracker.excludeFromDividends(rewardsIncentivesWallet);
        dividendTracker.excludeFromDividends(reserveWallet);
        dividendTracker.excludeFromDividends(operationsWallet);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);
        excludeFromFees(feeWallet, true);
        excludeFromFees(address(dividendTracker), true);
        excludeFromFees(nabanaVesting, true);
        excludeFromFees(pancakeSwapLaunchWallet, true);
        excludeFromFees(airdropsWallet, true);
        excludeFromFees(privateInvestorsWallet, true);
        excludeFromFees(managementAllocationWallet, true);
        excludeFromFees(advisorsWallet, true);
        excludeFromFees(influencersWallet, true);
        excludeFromFees(strategicPartnersWallet, true);
        excludeFromFees(rewardsIncentivesWallet, true);
        excludeFromFees(reserveWallet, true);
        excludeFromFees(operationsWallet, true);

        // minting tokens for vesting
        _mint(nabanaVesting, 20_000_000 * (10 ** 18));

        // minting all other tokens
        _mint(pancakeSwapLaunchWallet, 15_000 * (10 ** 18));
        _mint(airdropsWallet, 1_709 * (10 ** 18));
        _mint(privateInvestorsWallet, 10_000_000 * (10 ** 18));
        _mint(operationsWallet, 19_983_291 * (10 ** 18));
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "Nabana: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function updateFeeWallet(address newFeeWallet) external onlyOwner {
        require(feeWallet != newFeeWallet, "Nabana: Fee Wallet is already this address");
        feeWallet = newFeeWallet;
    }

    function updateNabanaVesting(address newNabanaVesting) external onlyOwner {
        require(nabanaVesting != newNabanaVesting, "Nabana: Nabana Vesting is already this address");

        dividendTracker.excludeFromDividends(newNabanaVesting);
        excludeFromFees(newNabanaVesting, true);

        nabanaVesting = newNabanaVesting;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "Nabana: The dividend tracker already has that address");

        NabanaDividendTracker newDividendTracker = NabanaDividendTracker(newAddress);

        require(newDividendTracker.owner() == address(this), "Nabana: The new dividend tracker must be owned by the Nabana token contract");

        // exclude all AMMs except for primary PancakePair manually
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(uniswapV2Pair);
        newDividendTracker.excludeFromDividends(nabanaVesting);
        newDividendTracker.excludeFromDividends(pancakeSwapLaunchWallet);
        newDividendTracker.excludeFromDividends(airdropsWallet);
        newDividendTracker.excludeFromDividends(privateInvestorsWallet);
        newDividendTracker.excludeFromDividends(managementAllocationWallet);
        newDividendTracker.excludeFromDividends(advisorsWallet);
        newDividendTracker.excludeFromDividends(influencersWallet);
        newDividendTracker.excludeFromDividends(strategicPartnersWallet);
        newDividendTracker.excludeFromDividends(rewardsIncentivesWallet);
        newDividendTracker.excludeFromDividends(reserveWallet);
        newDividendTracker.excludeFromDividends(operationsWallet);

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    /**
     * @dev Use magnified values for fees
     */
    function updatePurchaseFee(uint256 amount) external onlyOwner {
        require(amount <= 300, "Nabana: Amount exceeds limit");
        purchaseFee = amount;
    }

    function updateSellFee(uint256 amount) external onlyOwner {
        require(amount <= 500, "Nabana: Amount exceeds limit");
        sellFee = amount;
    }

    function updateMinMaxSellTransactionAmounts(
        uint256 newMinSellTransactionAmount,
        uint256 newMaxSellTransactionAmount
    ) external onlyOwner {
        require(minSellTransactionAmount != newMinSellTransactionAmount && maxSellTransactionAmount != newMaxSellTransactionAmount,
            "Nabana: Min and Max Sell Transaction Amount are already these values");

        minSellTransactionAmount = newMinSellTransactionAmount;
        maxSellTransactionAmount = newMaxSellTransactionAmount;
    }

    function updateHandleLimitCriteria(uint256 newHandleLimitCriteria) external onlyOwner {
        require(handleLimitCriteria != newHandleLimitCriteria, "Nabana: Handle Limit Criteria is already this value");
        handleLimitCriteria = newHandleLimitCriteria;
    }

    function updateHandleLimitMax(uint256 newHandleLimitMax) external onlyOwner {
        require(handleLimitMax != newHandleLimitMax, "Nabana: Handle Limit Max is already this value");
        handleLimitMax = newHandleLimitMax;
    }

    function updateHandleLimitTime(uint256 newHandleLimitTime) external onlyOwner {
        require(handleLimitTime != newHandleLimitTime, "Nabana: Handle Limit Time is already this value");
        handleLimitTime = newHandleLimitTime;
    }

    function updateGasForProcessing(uint256 newGas, uint256 newGasIndividual) public onlyOwner {
        require(150000 <= newGas && newGas <= 900000, "Nabana: gasForProcessing must be between 150,000 and 900,000");
        require(150000 <= newGasIndividual && newGasIndividual <= 900000, "Nabana: gasForProcessingIndividual must be between 150,000 and 900,000");
        require(newGas != gasForProcessing, "Nabana: gasForProcessing is already this value");
        require(newGasIndividual != gasForProcessingIndividual, "Nabana: gasForProcessingIndividual is already this value");
        emit GasForProcessingUpdated(newGas, gasForProcessing, newGasIndividual, gasForProcessingIndividual);
        gasForProcessing = newGas;
        gasForProcessingIndividual = newGasIndividual;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Nabana: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function blackListAddress(address account, bool blacklisted) public onlyOwner {
        require(_isBlacklisted[account] != blacklisted, "Nabana: Account is already the value of 'blacklisted'");
        _isBlacklisted[account] = blacklisted;

        emit BlackListAddress(account, blacklisted);
    }

    function blackListMultipleAddresses(address[] calldata accounts, bool blacklisted) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = blacklisted;
        }

        emit BlackListMultipleAddresses(accounts, blacklisted);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Nabana: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function circulatingSupply() public view returns (uint256) {
        return totalSupply().sub(
            balanceOf(owner()) +
            balanceOf(nabanaVesting) +
            balanceOf(pancakeSwapLaunchWallet) +
            balanceOf(airdropsWallet) +
            balanceOf(privateInvestorsWallet) +
            balanceOf(managementAllocationWallet) +
            balanceOf(advisorsWallet) +
            balanceOf(influencersWallet) +
            balanceOf(strategicPartnersWallet) +
            balanceOf(rewardsIncentivesWallet) +
            balanceOf(reserveWallet) +
            balanceOf(operationsWallet)
        );
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function getAccountDividendsInfo(address account) external view returns (
        address,
        int256,
        int256,
        bool,
        uint256,
        uint256,
        uint256
    ) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index) external view returns (
        address,
        int256,
        int256,
        bool,
        uint256,
        uint256,
        uint256
    ) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function getInvestmentInfo(
        address account,
        uint256 index
    ) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return dividendTracker.getPrivateInvestments(account, index);
    }

    /* ========== REWARDS/UNLOCKS ========== */

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex, uint256 lastProcessedInvestment) =
            dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, lastProcessedInvestment, true, gas, tx.origin);
    }

    function processAccountDividendTracker(uint256 gas, address account) external {
        (uint256 iterations, uint256 claims, uint256 processedIndex, uint256 processedInvestment) =
            dividendTracker.processAccount(gas, account);
        emit ProcessedAccountDividendTracker(iterations, claims, processedIndex, processedInvestment, true, gas, tx.origin);
    }

    /* ========== SELLING LIMIT HANLDERS ========== */

    function handleLimit(address from, uint256 amount) internal {
        // those excluded from fees have no selling limit
        if (_isExcludedFromFees[from]) {
            return;
        }

        if (balanceOf(from) > totalSupply().mul(handleLimitCriteria).div(100)) {
            if (!isLimitedUser(from)) {
                addLimitedUser(from, 0);
            }
        }
        else {
            if (isLimitedUser(from)) {
                removeLimitedUser(from);
            }
        }

        if (isLimitedUser(from)) {
            if (_limitedUsers[from].sellTransactionTotalAmount.add(amount) > circulatingSupply().mul(handleLimitMax).div(100)) {
                require(
                    block.timestamp > _limitedUsers[from].sellTransactionRecordedTime.add(handleLimitTime),
                    "Nabana: Blocked from selling. Please try a smaller amount or try again after 24 hours from your last transaction"
                );
            }

            if (block.timestamp > _limitedUsers[from].sellTransactionRecordedTime.add(handleLimitTime)) {
                _limitedUsers[from].sellTransactionTotalAmount = amount;
                _limitedUsers[from].sellTransactionRecordedTime = block.timestamp;
            }
            else {
                _limitedUsers[from].sellTransactionTotalAmount += amount;
            }
        }
    }

    function isLimitedUser(address from) internal view returns (bool) {
        return _limitedUsers[from].walletAddress == from;
    }

    function addLimitedUser(address from, uint256 amount) internal {
        _limitedUsers[from] = Limiter(from, block.timestamp, amount);
    }

    function removeLimitedUser(address from) internal {
        Limiter memory emptyLimiter;
        _limitedUsers[from] = emptyLimiter;
    }

    /* ========== INTERNAL TRANSFER LOGIC ========== */

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount <= balanceOf(from), "ERC20: transfer amount exceeds balance");
        require(_isBlacklisted[from] == false, "Nabana: Cannot send token FROM a blacklisted address");
        require(_isBlacklisted[to] == false, "Nabana: Cannot send token TO a blacklisted address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        // limiting users from selling more than 20% of circulating supply for 24 hours if their balance is more than 1% of Total Supply
        if (_isSell(from, to)) {
            handleLimit(from, amount);
        }

        if (
            _isSell(from, to) &&
            !_isExcludedFromFees[from] // no max for those excluded from fees
        ) {
            require(minSellTransactionAmount <= amount && amount <= maxSellTransactionAmount,
                "Nabana: Sell transfer amount should be within min and max of sell transaction limit.");
        }

        if (
            dividendTracker.isPrivateInvestor(from) &&
            dividendTracker.privateInvestmentsLength(from) > 0
        ) {
            uint256 gasIndividual = gasForProcessingIndividual;

            try dividendTracker.processAccount(gasIndividual, from) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcIndex,
                uint256 lastProcInvestment
            ) {
                emit ProcessedDividendTracker(iterations, claims, lastProcIndex, lastProcInvestment, false, gasIndividual, tx.origin);
            } catch {}
        }

        if (
            dividendTracker.isPrivateInvestor(to) &&
            dividendTracker.privateInvestmentsLength(to) > 0
        ) {
            uint256 gasIndividual = gasForProcessingIndividual;

            try dividendTracker.processAccount(gasIndividual, to) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcIndex,
                uint256 lastProcInvestment
            ) {
                emit ProcessedDividendTracker(iterations, claims, lastProcIndex, lastProcInvestment, false, gasIndividual, tx.origin);
            } catch {}
        }

        bool takeFee = true;

        // if the `from` and `to` accounts belong to _isExcludedFromFee then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 totalFee;

            if (_isBuy(from)) {
                totalFee += amount.mul(purchaseFee).div(10000);
            }
            else if (_isSell(from, to)) {
                totalFee += amount.mul(sellFee).div(10000);
            }

            amount = amount.sub(totalFee);

            if (totalFee > 0) {
                if (dividendTracker.isPrivateInvestor(from)) {
                    require(totalFee <= dividendTracker.unlockedInvestments(from), "Nabana: Amount exceeds unlocked amount");
                    dividendTracker.decreaseUnlockedInvestments(from, totalFee);
                }
                super._transfer(from, address(feeWallet), totalFee);
            }
        }

        if (
            from != privateInvestorsWallet &&
            from != address(dividendTracker) &&
            dividendTracker.isPrivateInvestor(to)
        ) {
            dividendTracker.increaseUnlockedInvestments(to, amount);
        }

        if (dividendTracker.isPrivateInvestor(from)) {
            require(amount <= dividendTracker.unlockedInvestments(from), "Nabana: Amount exceeds unlocked amount");
            dividendTracker.decreaseUnlockedInvestments(from, amount);
        }

        super._transfer(from, to, amount);

        if (from == privateInvestorsWallet && !dividendTracker.excludedFromDividends(to)) {
            uint256 currentInvestment = dividendTracker.getTotalCurrentInvestment(to);

            try dividendTracker.setBalance(to, currentInvestment.add(amount)) {} catch {}

            dividendTracker.setInvestment(to, amount);
        }

        uint256 gas = gasForProcessing;

        try dividendTracker.process(gas) returns (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcIndex,
            uint256 lastProcInvestment
        ) {
            emit ProcessedDividendTracker(iterations, claims, lastProcIndex, lastProcInvestment, false, gas, tx.origin);
        } catch {}
    }

    function _isBuy(address from) internal view returns (bool) {
        // transfer from pair is a buy swap
        return automatedMarketMakerPairs[from];
    }

    function _isSell(address from, address to) internal view returns (bool) {
        // transfer from non-router address to pair is a sell swap
        return from != address(uniswapV2Router) && automatedMarketMakerPairs[to];
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendInvestors() external view returns(uint256) {
        return dividendTracker.getNumberOfInvestors();
    }

    function mintWithPermit(address account, uint256 amount) external onlyDividendTracker returns (bool) {
        _mint(account, amount);

        return true;
    }

    modifier onlyDividendTracker() {
        require(msg.sender == address(dividendTracker), "Nabana: Caller is not the Nabana Dividend Tracker");
        _;
    }
}


contract NabanaDividendTracker is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    Nabana public nabana;

    IterableMapping.Map private investorsMap;
    uint256 public lastProcessedIndex;
    uint256 public lastProcessedInvestment;

    mapping (address => bool) public excludedFromDividends;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    uint256 public intervalTime;
    uint256 private immutable rewardIntervals;
    uint256 private immutable unlockIntervals;
    uint256 private immutable totalIntervals;

    uint256 public percentageToUnlock;

    uint256 public rewardAPY;

    struct Investment {
        uint256 amount;
        uint256 amountToUnlock;
        uint256 amountUnlocked;
        uint256 startTime;
        uint256 rewardEndTime;
        uint256 unlockEndTime;
        uint256 currentInterval;
        uint256 lastClaimTime;
    }

    mapping (address => bool) public isPrivateInvestor;

    mapping (address => Investment[]) public privateInvestments;

    mapping (address => uint256) public unlockedInvestments;

    // events

    event ExcludeFromDividends(address indexed account);

    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool manual);

    // constructor

    constructor(address _iNabana) {
        nabana = Nabana(_iNabana);

        intervalTime = 30 days;
        rewardIntervals = 6;
        unlockIntervals = 10;
        totalIntervals = 16;

        percentageToUnlock = 100;

        rewardAPY = 30000000000000000;

    	claimWait = 30 days;
        minimumTokenBalanceForDividends = 1; // must hold at least 1 Wei
    }

    function setInvestment(address account, uint256 amount) external onlyOwner {
        if (privateInvestments[account].length == 0) {
            isPrivateInvestor[account] = true;
        }

        Investment memory investment;

        investment.amount = amount;
        investment.amountToUnlock = amount;
        // investment.amountUnlocked = 0;
        investment.startTime = block.timestamp;
        investment.rewardEndTime = block.timestamp.add(intervalTime.mul(rewardIntervals));
        investment.unlockEndTime = block.timestamp.add(intervalTime.mul(totalIntervals));
        // investment.currentInterval = 0;
        investment.lastClaimTime = block.timestamp;

        privateInvestments[account].push(investment);
    }

    function increaseUnlockedInvestments(address account, uint256 amount) external onlyOwner {
        unlockedInvestments[account] += amount;
    }

    function decreaseUnlockedInvestments(address account, uint256 amount) external onlyOwner {
        unlockedInvestments[account] = unlockedInvestments[account].safeSub(amount);

        if (
            privateInvestments[account].length == 0 &&
            unlockedInvestments[account] == 0
        ) {
            isPrivateInvestor[account] = false;
        }
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        investorsMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait != claimWait, "Nabana_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;

        intervalTime = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfInvestors() external view returns(uint256) {
        return investorsMap.keys.length;
    }

    function privateInvestmentsLength(address account) external view returns (uint256) {
        return privateInvestments[account].length;
    }

    function getPrivateInvestments(
        address account,
        uint256 index
    ) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        Investment memory investment = privateInvestments[account][index];

        return (
            investment.amount,
            investment.amountToUnlock,
            investment.amountUnlocked,
            investment.startTime,
            investment.rewardEndTime,
            investment.unlockEndTime,
            investment.currentInterval,
            investment.lastClaimTime
        );
    }

    function getTotalCurrentInvestment(address account) external view returns (uint256) {
        return investorsMap.get(account);
    }

    function getAccount(address _account) public view returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        bool privateInvestorStatus,
        uint256 numberOfPrivateInvestments,
        uint256 totalCurrentInvestment,
        uint256 unlockedInvestment
    ) {
        account = _account;

        index = investorsMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = 
                    investorsMap.keys.length > lastProcessedIndex ?
                    investorsMap.keys.length.sub(lastProcessedIndex) :
                    0;

                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        privateInvestorStatus = isPrivateInvestor[account];

        numberOfPrivateInvestments = privateInvestments[account].length;

        totalCurrentInvestment = investorsMap.get(account);

        unlockedInvestment = unlockedInvestments[account];
    }

    function getAccountAtIndex(uint256 index) public view returns (
        address,
        int256,
        int256,
        bool,
        uint256,
        uint256,
        uint256
    ) {
    	if (index >= investorsMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, false, 0, 0, 0);
        }

        address account = investorsMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address account, uint256 newBalance) public onlyOwner returns (uint8) {
        uint8 result;
        
        if (excludedFromDividends[account]) {
            result = 2;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            investorsMap.set(account, newBalance);
            result = 2;
        }
        else {
            investorsMap.remove(account);
            result = 3;
        }

        return result;
    }

    function process(uint256 gas) public onlyOwner returns (uint256, uint256, uint256, uint256) {
        uint256 numberOfInvestors = investorsMap.keys.length;

        if (numberOfInvestors == 0) {
            return (0, 0, lastProcessedIndex, lastProcessedInvestment);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 _lastProcessedInvestment = lastProcessedInvestment;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        uint8 result = 0;

        while (gasUsed < gas && iterations < numberOfInvestors) {
            result = 0;

            address account = investorsMap.keys[_lastProcessedIndex];

            if (canAutoClaim(privateInvestments[account][_lastProcessedInvestment].lastClaimTime)) {
                result = processInvestment(account, _lastProcessedInvestment, false);

                if (result > 0) {
                    claims++;
                }
            }

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;

            if (result < 2) {
                _lastProcessedInvestment++;
            }

            if (result == 3) {
                iterations++;

                if (_lastProcessedIndex >= investorsMap.keys.length) {
                    _lastProcessedIndex = 0;
                    _lastProcessedInvestment = 0;
                }
            }

            if (iterations >= numberOfInvestors) {
                break;
            }

            if (_lastProcessedInvestment >= privateInvestments[investorsMap.keys[_lastProcessedIndex]].length) {
                if (result < 3) {
                    _lastProcessedIndex++;
                }
                _lastProcessedInvestment = 0;

                iterations++;
            }

            if (_lastProcessedIndex >= investorsMap.keys.length) {
                _lastProcessedIndex = 0;
            }
        }

        lastProcessedIndex = _lastProcessedIndex;
        lastProcessedInvestment = _lastProcessedInvestment;

        return (iterations, claims, lastProcessedIndex, lastProcessedInvestment);
    }

    function processAccount(uint256 gas, address account) public onlyOwner returns (uint256, uint256, uint256, uint256) {
        uint256 numberOfInvestments = privateInvestments[account].length;

        if (investorsMap.getIndexOfKey(account) < 0) {
            return (0, 0, 0, 0);
        }

        uint256 _processedInvestment = 0;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        uint8 result = 0;

        uint256 index = uint256(investorsMap.getIndexOfKey(account));

        // bool isLastProcessedIndex = index == lastProcessedIndex;

        while (gasUsed < gas && iterations < numberOfInvestments) {
            result = 0;

            if (canAutoClaim(privateInvestments[account][_processedInvestment].lastClaimTime)) {
                result = processInvestment(account, _processedInvestment, false);

                if (result > 0) {
                    claims++;
                }
            }

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;

            if (result < 2) {
                _processedInvestment++;
            }
            else if (result == 2 && index == lastProcessedIndex) {
                lastProcessedInvestment = _processedInvestment;
            }

            if (result == 3 && lastProcessedIndex >= investorsMap.keys.length) {
                lastProcessedIndex = 0;
                lastProcessedInvestment = 0;
            }

            iterations++;
        }

        return (iterations, claims, index, _processedInvestment);
    }

    function processInvestment(address account, uint256 index, bool manual) public onlyOwner returns (uint8) {
        Investment storage investment = privateInvestments[account][index];

        if (!canAutoClaim(investment.lastClaimTime)) {
            return 0;
        }

        if (investment.currentInterval < rewardIntervals) {
            uint256 numberOfIntervals = block.timestamp.sub(investment.lastClaimTime).div(intervalTime);

            uint256 leftoverIntervals = rewardIntervals.sub(investment.currentInterval);

            numberOfIntervals = numberOfIntervals > leftoverIntervals ? leftoverIntervals : numberOfIntervals;

            uint256 ratio = rewardAPY;

            uint256 rewardAmount = _compound(
                investment.amountToUnlock,
                ratio,
                numberOfIntervals
            );

            nabana.mintWithPermit(account, rewardAmount);

            investment.currentInterval += numberOfIntervals;
            investment.amountToUnlock += rewardAmount;
            investment.lastClaimTime = investment.startTime.add(investment.currentInterval.mul(intervalTime));

            emit Claim(account, rewardAmount, manual);
        }

        if (
            investment.currentInterval >= rewardIntervals &&
            investment.currentInterval < totalIntervals
        ) {
            uint256 numberOfIntervals = block.timestamp.sub(investment.lastClaimTime).div(intervalTime);

            uint256 leftoverIntervals = totalIntervals.sub(investment.currentInterval);

            numberOfIntervals = numberOfIntervals > leftoverIntervals ? leftoverIntervals : numberOfIntervals;

            if (investment.currentInterval + numberOfIntervals >= totalIntervals) {
                uint256 lastUnlockedAmount = investment.amountUnlocked;

                investment.amountUnlocked = investment.amountToUnlock;
                unlockedInvestments[account] += investment.amountToUnlock - lastUnlockedAmount;
            }
            else {
                uint256 amountToUnlock = investment.amountToUnlock.mul(percentageToUnlock).div(1000).mul(numberOfIntervals);

                investment.amountUnlocked += amountToUnlock;
                unlockedInvestments[account] += amountToUnlock;
            }

            investment.currentInterval += numberOfIntervals;
            investment.lastClaimTime = investment.startTime.add(investment.currentInterval.mul(intervalTime));
        }

        if (investment.currentInterval >= totalIntervals) {
            uint256 currentInvestment = investorsMap.get(account);

            uint8 result = setBalance(account, currentInvestment.safeSub(investment.amount));

            uint256 lastIndex = privateInvestments[account].length - 1;
            Investment memory lastInvestment = privateInvestments[account][lastIndex];

            privateInvestments[account][index] = lastInvestment;
            privateInvestments[account].pop();

            return result;
        }

    	return 1;
    }

    function _compound(uint256 _principal, uint256 _ratio, uint256 _exponent) internal pure returns (uint256) {
        if (_exponent == 0) {
            return 0;
        }

        uint256 accruedReward = ABDKMath64x64.mulu(ABDKMath64x64.pow(ABDKMath64x64.add(ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu(_ratio,10 ** 18)), _exponent), _principal);

        return accruedReward.sub(_principal);
    }
}