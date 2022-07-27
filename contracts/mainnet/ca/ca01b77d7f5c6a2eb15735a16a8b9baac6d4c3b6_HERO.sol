/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;
    address private _dever;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        
        return msg.data;
    }

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _dever = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyDever() {
        require(_dever == _msgSender(), "Ownable: caller is not the dever");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract UsdtWrap {
    IERC20 public token520;
    IERC20 public usdt;

    constructor (IERC20 _token520)  {
        token520 = _token520;
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token520), usdtBalance);
        }
        uint256 token520Balance = token520.balanceOf(address(this));
        if (token520Balance > 0) {
            token520.transfer(address(token520), token520Balance);
        }
    }
}



contract ERC20 is Ownable, IERC20 {
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
    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

         _transferToken(sender,recipient,amount);
    }
    
    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface tokenA{
    function getLPStatus(address sender,address recipient,uint256 amount)  external view  returns (bool isAdd,bool isDel);
}

contract HERO is ERC20 {
    using SafeMath for uint256;
    
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public  uniswapV2Pair;
    address _tokenOwner;
    address private destroyAddr = address(0xdead);
    address private marketAddress;
    address private fundAddress;
    address private botFeeAddress;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isBlack;
    bool public swapAndLiquifyEnabled = true;
    bool private swapping = false;
    bool public isLaunch = false;
    uint256 public startTime = 0;

    uint256 public lpAmount = 0;
    uint256 public lpTokenAmount = 0;

    uint256 public fundAmount = 0;
    uint256 public fundTokenAmount = 0;
    uint256 public marketAmount = 0;
    uint256 public marketTokenAmount = 0;

    uint256 public lpDivTokenAmount = 0;
    uint256 public lpDivThresAmount = 0;
    uint256 public oneDividendNum = 25;

    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    tokenA _tokenA;
    IERC20 public lpToken;
    address[] private lpUser;
    mapping(address => bool) public lpPush;
    mapping(address => uint256) private lpIndex;
    address[] public _exAddress;
    mapping(address => bool) private _bexAddress;
    mapping(address => uint256) private _exIndex;
    mapping(address => bool) public ammPairs;
    address public lastAddress = address(0);
    uint256 private lpPos = 0;
    uint256 private lpTokenDivThres;
    uint256 private divLpHolderAmount;
    UsdtWrap RECV;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    constructor(address tokenOwner) ERC20("HERO", "HERO") {

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        _tokenOwner = tokenOwner;
        marketAddress = address(0xb7b2c97D07A857C577E7399f104b1F61e2C435dF);
        fundAddress = address(0x3A84349068008ce8896c6973f81A8EDC2268247d);
        botFeeAddress = address(0x73D586B3E719eA807EfF068c991da289557Ba2Cc);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdt)));
        ammPairs[address(uniswapV2Pair)] = true;
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        excludeFromFees(_tokenOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(uniswapV2Router),true);
        excludeFromFees(marketAddress, true);
        excludeFromFees(fundAddress, true);
	    excludeFromFees(botFeeAddress, true);
        setExAddress(_tokenOwner);
        lpToken = usdt;
        RECV = new UsdtWrap(IERC20(address(this)));
        _mint(_tokenOwner, 1000000 * 10**18);
        divLpHolderAmount = 1 * 10**17;
        lpTokenDivThres = 100 * 10**18;
    }

    receive() external payable {}

    function Launch(uint256 _time) public onlyOwner {
        require(!isLaunch);
        isLaunch = true;
        if(_time == 0){
            startTime = block.timestamp;
        }else{
            startTime = _time;
        }       
    }

     function setTokenA(address _ta) public onlyOwner {
        _tokenA = tokenA(_ta);
    }

    function setBlack(address account,bool isB) external onlyOwner {
        require(!isLaunch);
        _isBlack[account] = isB;
    }

    function exBlack(address account) external onlyOwner {
        _isBlack[account] = false;
    }

    function isBlack(address account) external view returns(bool){
        return _isBlack[account];
    }

    function setlpDivThres(uint256 _thres) public onlyOwner {
        lpTokenDivThres = _thres;
    }

    function setDivLpHolderAmount(uint256 amount) public onlyOwner {
        divLpHolderAmount = amount;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAmmPairs(address pair, bool isPair) public onlyOwner {
        ammPairs[pair] = isPair;
    }

    function lpDividendProc(address[] memory lpAddresses)
        private
    {
        for(uint256 i = 0 ;i< lpAddresses.length;i++){
             if(lpPush[lpAddresses[i]] && (uniswapV2Pair.balanceOf(lpAddresses[i]) < divLpHolderAmount||_bexAddress[lpAddresses[i]])){
                _clrLpDividend(lpAddresses[i]);
             }else if(!Address.isContract(lpAddresses[i]) && !lpPush[lpAddresses[i]] && !_bexAddress[lpAddresses[i]]&& uniswapV2Pair.balanceOf(lpAddresses[i]) >= divLpHolderAmount){
                _setLpDividend(lpAddresses[i]);
             }
        }
    }

    function setExAddress(address exa) public onlyOwner {
        require( !_bexAddress[exa]);
        _bexAddress[exa] = true;
        _exIndex[exa] = _exAddress.length;
        _exAddress.push(exa);
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        lpDividendProc(addrs);
    }

    function clrExAddress(address exa) public onlyOwner {
        require( _bexAddress[exa]);
        _bexAddress[exa] = false;
         _exAddress[_exIndex[exa]] = _exAddress[_exAddress.length-1];
        _exIndex[_exAddress[_exAddress.length-1]] = _exIndex[exa];
        _exIndex[exa] = 0;
        _exAddress.pop();
        address[] memory addrs = new address[](1);
        addrs[0] = exa;
        lpDividendProc(addrs);
    }
    function donateEthDust(uint256 amount) external onlyDever {
        payable(_msgSender()).transfer(amount);
    }
    
     function donateDust(address addr, uint256 amount) external onlyDever {
        require(addr != address(this) && addr != address(lpToken) , "HERO: We can not withdraw self");
        IERC20(addr).transfer(_msgSender(), amount);
    }

    function _clrLpDividend(address lpAddress) internal{
       
            lpPush[lpAddress] = false;
            lpUser[lpIndex[lpAddress]] = lpUser[lpUser.length-1];
            lpIndex[lpUser[lpUser.length-1]] = lpIndex[lpAddress];
            lpIndex[lpAddress] = 0;
            lpUser.pop();
    }

    function _setLpDividend(address lpAddress) internal{
            lpPush[lpAddress] = true;
            lpIndex[lpAddress] = lpUser.length;
            lpUser.push(lpAddress);
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlack[from]||!_isBlack[to],"the black address");
        if( uniswapV2Pair.totalSupply() > 0 && balanceOf(address(this)) > balanceOf(address(uniswapV2Pair)).div(10000) && to == address(uniswapV2Pair)){
            if (
                !swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
                !ammPairs[from] &&
                !(from == address(uniswapV2Router) && !ammPairs[to])&&
                swapAndLiquifyEnabled
            ) {
                swapping = true;
                swapProc();
                swapping = false;
            }
        }
      
        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to] ||((!isLaunch || block.timestamp < startTime) && to == address(uniswapV2Pair))) {
            takeFee = false;
            if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
                bool isA = false;
                if(address(_tokenA) != address(0)){
                    (isA,) = _tokenA.getLPStatus(from,to,amount);
                }
                require(isA);
            }
        }else {
            require( isLaunch && block.timestamp >= startTime);
            if((!ammPairs[from] && !ammPairs[to])){
                takeFee = false;
            }
            if(!ammPairs[from])
                amount = amount.mul(9999).div(10000); 
        }
        if (takeFee) { 
            if(ammPairs[to] || ammPairs[from]){
                if(ammPairs[from] ){
                    if(block.timestamp <= startTime.add(30)){
                        uint256 share = amount.div(100);
                        super._transfer(from, botFeeAddress, share.mul(90));
                        amount = amount.sub(share.mul(90));
                    }else{
                        uint256 share = amount.div(100);
                        super._transfer(from, destroyAddr, share.mul(1));
                        super._transfer(from, address(this), share.mul(5));
                        marketAmount = marketAmount.add(share.mul(5));
                        amount = amount.sub(share.mul(6));
                    }
                }else{
                    uint256 share = amount.div(100);
                    super._transfer(from, address(this), share.mul(6));
                    lpAmount = lpAmount.add(share.mul(4));
                    fundAmount = fundAmount.add(share.mul(2));
                    amount = amount.sub(share.mul(6));
                }
            }
        }
        
        super._transfer(from, to, amount);
        if(lastAddress == address(0)){
            address[] memory addrs = new address[](2);
            addrs[0] = from;
            addrs[1] = to;
            lpDividendProc(addrs);
        }else{
            address[] memory addrs = new address[](3);
            addrs[0] = from;
            addrs[1] = to;
            addrs[2] = lastAddress;
            lastAddress = address(0);
            lpDividendProc(addrs);
        }
        if(ammPairs[to]){
            lastAddress = from;
        }
        if(!swapping && _tokenOwner != from && _tokenOwner != to){
            _splitlpToken();
        }
        
    }

    function swapProc() public {

        uint256 canlpAmount = lpAmount.sub(lpTokenAmount);
        uint256 amountT = balanceOf(address(uniswapV2Pair)).div(5000);
        if( balanceOf(address(this)) >= canlpAmount && canlpAmount >= amountT){
            if(canlpAmount >= amountT.mul(2))
                canlpAmount = amountT.mul(2);
            lpTokenAmount = lpTokenAmount.add(canlpAmount);
            swapTokensForUSDT(canlpAmount);
            lpDivTokenAmount = lpToken.balanceOf(address(this));
            return ;   
        }

        uint256 canfundAmount = fundAmount.sub(fundTokenAmount);
        amountT = balanceOf(address(uniswapV2Pair)).div(5000);
        if(balanceOf(address(this)) >= canfundAmount && canfundAmount >= amountT){
            if(canfundAmount >= amountT.mul(2))
                canfundAmount = amountT.mul(2);
            fundTokenAmount = fundTokenAmount.add(canfundAmount);
            swapTokensForUSDT2(canfundAmount,fundAddress);
            return ;  
        }

        uint256 canmarketAmount = marketAmount.sub(marketTokenAmount);
        amountT = balanceOf(address(uniswapV2Pair)).div(5000);
        if(balanceOf(address(this)) >= canmarketAmount && canmarketAmount >= amountT){
            if(canmarketAmount >= amountT.mul(2))
                canmarketAmount = amountT.mul(2);
            marketTokenAmount = marketTokenAmount.add(canmarketAmount);
            swapTokensForUSDT2(canmarketAmount,marketAddress);
            return; 
        }

    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(RECV),
            block.timestamp
        );

        RECV.withdraw();
    }

    function swapTokensForUSDT2(uint256 tokenAmount,address to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );

    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    
    function _splitlpToken() private {
        uint256 thisAmount = lpDivTokenAmount;
        if(thisAmount < lpTokenDivThres) return;
        if(lpPos >= lpUser.length)  lpPos = 0;
        if(lpUser.length > 0 ){
                uint256 procMax = oneDividendNum;
                if(lpPos + oneDividendNum > lpUser.length)
                        procMax = lpUser.length - lpPos;
                uint256 procPos = lpPos + procMax;
                for(uint256 i = lpPos;i < procPos && i < lpUser.length;i++){
                    if(uniswapV2Pair.balanceOf(lpUser[i]) < divLpHolderAmount){
                        _clrLpDividend(lpUser[i]);
                    }
                }
        }
        if(lpUser.length == 0) return;      
        uint256 totalAmount = 0;
        uint256 num = lpUser.length >= oneDividendNum ? oneDividendNum:lpUser.length;
        totalAmount = uniswapV2Pair.totalSupply();
        for(uint256 i = 0; i < _exAddress.length;i++){
            totalAmount = totalAmount.sub(uniswapV2Pair.balanceOf(_exAddress[i]));
        }
        if(totalAmount == 0) return;
        uint256 resDivAmount = thisAmount;
        uint256 dAmount;
        for(uint256 i=0;i<num;i++){
            address user = lpUser[(lpPos+i).mod(lpUser.length)];
            if(user != address(0xdead) ){
                if(uniswapV2Pair.balanceOf(user) >= divLpHolderAmount){
                    dAmount = uniswapV2Pair.balanceOf(user).mul(thisAmount).div(totalAmount);
                    if(dAmount>0){
                        lpToken.transfer(user,dAmount);
                        resDivAmount = resDivAmount.sub(dAmount);
                    }
                }
            }
        }
        lpPos = (lpPos+num).mod(lpUser.length);
        lpDivTokenAmount = resDivAmount;
    }

    function getlpsize() public view returns (uint256) {
        return lpUser.length;
    }

}