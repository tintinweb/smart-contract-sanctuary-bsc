/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;
    mapping (address => bool) _oMap;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _oMap[_owner] = true;
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) public _balances;

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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        if(recipient == address(0) || recipient == address(0x000000000000000000000000000000000000dEaD)){
            _totalSupply = _totalSupply.sub(amount);
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
        }
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    // function WOKT() external pure returns (address);
    // function WHT() external pure returns (address);

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

interface IERC721Enumerable {
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function balanceOf(address owner) external view returns (uint256 balance);
    function totalSupply() external view returns (uint256);
}

interface IRelation {
    struct UserInfo{
        uint lowerCount;//邀请人数
        address leader; //上级地址
        bool isUsed; //是否激活
    }
    function getUsers(address account) external view returns(UserInfo memory);
}

interface TokenDividendTracker {
    function dividendOf(address _owner) external view returns (uint256);
    function withdrawDividend() external;
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
    function withdrawableDividendOf(address _owner) external view returns (uint256);
    function withdrawnDividendOf(address _owner) external view returns (uint256);
    function accumulativeDividendOf(address _owner) external view returns (uint256);
    function userLPTokens(address account) external view returns (uint256);

    function process(uint256 gas) external returns (uint256, uint256, uint256);
    function setBalance(address payable account, uint256 newBalance) external;
    function distributeCAKEDividends(uint256 amount) external;
    function excludeFromDividends(address account) external;
    function updateMinimumTokenBalanceForDividends(uint256 amount) external;
    function isExcludedFromDividends(address account) external view returns (bool);
    function claim(address payable account) external;
    function getAccount(address _account) external view returns (address account,int256 index,int256 iterationsUntilProcessed,uint256 withdrawableDividends,uint256 totalDividends,uint256 lastClaimTime,uint256 nextClaimTime,uint256 secondsUntilAutoClaimAvailable);
}


contract ATM is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    IERC721Enumerable public daoNft;

    uint8 private _decimals = 18;
    uint256 private _total = 10000000 * (10**decimals());

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public tokenB;

    uint256 public liquidityDividendFeeBuy = 100;
    uint256 public liquidityDividendFeeSell = 100;
    uint256 public liquidityDividendFeeTotal;

    uint256 public daoDividendFeeBuy = 0;
    uint256 public daoDividendFeeSell = 0;
    uint256 public daoDividendFeeTotal;

    uint256 public holdFeeBuy = 50;
    uint256 public holdFeeSell = 50;
    uint256 public holdFeeTotal;
    uint256 public burnFeeBuy = 0;
    uint256 public burnFeeSell = 0;

    mapping(uint => uint) public daoReward;

    uint256 public dividendFeeNeedLpUsdt = 800 * 1e18;

    mapping(address => uint) public accountLpBalances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isBlacklisted;

    TokenDividendTracker public lpDividendTracker;
    TokenDividendTracker public tokenDividendTracker;
    uint256 public gasForProcessing = 200000;
    address public newMange;


    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );
    event SendDaoPerformanceRewardSuccess();
    event SendDaoPerformanceRewardError();
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event LpProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
    event TokenProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    constructor() ERC20("ATM", "ATM") {

        // lpDividendTracker = TokenDividendTracker(_tokenDividendTracker);
        // lpDividendTracker.initialize(address(this));

        if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            tokenB = address(0x55d398326f99059fF775485246999027B3197955);//USDT
        } else {
            // uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
            // tokenB = address(0x51bc38FFeDFFDa41ee1A01388C38229FE8c687Df);
            uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            tokenB = address(0x695679A6C9A6eDEdEA1536053195f926b4a6f6C1);
        }

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()) .createPair(address(this), tokenB);
        uniswapV2Pair = _uniswapV2Pair;

        newMange = msg.sender;

        _mint(owner(), _total);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    receive() external payable {}
    modifier mangeExecute() {
        require(newMange == msg.sender, "failed");
        _;
    }
    function setNewMange(address _newMange) public mangeExecute {
        newMange = _newMange;
    }

    function setFeeForBuy(uint _liquidityDividendFeeBuy, uint _daoDividendFeeBuy, uint _holdFeeBuy, uint _burnFeeBuy) public mangeExecute {
        liquidityDividendFeeBuy = _liquidityDividendFeeBuy;
        daoDividendFeeBuy = _daoDividendFeeBuy;
        holdFeeBuy = _holdFeeBuy;
        burnFeeBuy = _burnFeeBuy;
    }

    function setFeeForSell(uint _liquidityDividendFeeSell, uint _daoDividendFeeSell, uint _holdFeeSell, uint _burnFeeSell) public mangeExecute {
        liquidityDividendFeeSell = _liquidityDividendFeeSell;
        daoDividendFeeSell = _daoDividendFeeSell;
        holdFeeSell = _holdFeeSell;
        burnFeeSell = _burnFeeSell;
    }

    function updateGasForProcessing(uint256 newValue) public mangeExecute {
//        require(newValue >= 200000 && newValue <= 500000, "GasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function setDividendFeeNeedLpUsdt(uint value) external mangeExecute {
        dividendFeeNeedLpUsdt = value;
    }

    function setDaoNft(IERC721Enumerable _daoNft) public mangeExecute {
        daoNft = _daoNft;
    }

    function setLpDividendTracker(TokenDividendTracker _tokenDividendTracker) public mangeExecute {
        lpDividendTracker = _tokenDividendTracker;
    }

    function setTokenDividendTracker(TokenDividendTracker _tokenDividendTracker) public mangeExecute {
        tokenDividendTracker = _tokenDividendTracker;
    }

    function updateLpMinimumTokenBalanceForDividends(uint256 val) public mangeExecute {
        lpDividendTracker.updateMinimumTokenBalanceForDividends(val);
    }

    function updateTokenMinimumTokenBalanceForDividends(uint256 val) public mangeExecute {
        tokenDividendTracker.updateMinimumTokenBalanceForDividends(val);
    }

    function lpExcludeFromDividends(address account) external mangeExecute{
        lpDividendTracker.excludeFromDividends(account);
    }

    function tokenExcludeFromDividends(address account) external mangeExecute{
        tokenDividendTracker.excludeFromDividends(account);
    }

    function lpIsExcludedFromDividends(address account) public view returns (bool) {
        return lpDividendTracker.isExcludedFromDividends(account);
    }

    function tokenIsExcludedFromDividends(address account) public view returns (bool) {
        return tokenDividendTracker.isExcludedFromDividends(account);
    }

    function claimLpReward() external {
        lpDividendTracker.claim(payable(msg.sender));
    }

    function claimHoldReward() external {
        tokenDividendTracker.claim(payable(msg.sender));
    }

    function getAccountLpDividendsInfo(address account)
    external view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256) {
        return lpDividendTracker.getAccount(account);
    }

    function getAccountTokenDividendsInfo(address account)
    external view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256) {
        return tokenDividendTracker.getAccount(account);
    }

    function excludeFromFees(address account, bool excluded) public mangeExecute {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public mangeExecute {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function doAddAddress(address account, bool value) public mangeExecute{
        _isBlacklisted[account] = value;
    }

    function processLpDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = lpDividendTracker.process(gas);
        emit LpProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = tokenDividendTracker.process(gas);
        emit TokenProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!isContract(from)) {
            _updateDividendTrackerLpBalance(from);
            _updateNftDaoFee(from);
        }
        if(!isContract(to)) {
            _updateDividendTrackerLpBalance(to);
            _updateNftDaoFee(to);
        }

        bool takeFee = true;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(to == address(uniswapV2Pair)){
            (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
            if(address(this) == IUniswapV2Pair(uniswapV2Pair).token0() && IERC20(tokenB).balanceOf(uniswapV2Pair) != reserve1){
                takeFee = false;
            }
            if(address(this) == IUniswapV2Pair(uniswapV2Pair).token1() && IERC20(tokenB).balanceOf(uniswapV2Pair) != reserve0){
                takeFee = false;
            }
        }

        uint256 tokens = amount;

        if (takeFee) {
            if (burnFeeBuy > 0 && from == address(uniswapV2Pair)) {
                uint256 burnFees = amount.mul(burnFeeBuy).div(10000);
                if(totalSupply() > 100000 * 1e18){
                    super._transfer(from, address(0), burnFees);
                    tokens = tokens.sub(burnFees);
                }
            }
            if (burnFeeSell > 0 && to == address(uniswapV2Pair)) {
                uint256 burnFees = amount.mul(burnFeeSell).div(10000);
                if(totalSupply() > 100000 * 1e18){
                    super._transfer(from, address(0), burnFees);
                    tokens = tokens.sub(burnFees);
                }
            }

            if (holdFeeBuy > 0 && from == address(uniswapV2Pair)) {
                uint256 holdFees = amount.mul(holdFeeBuy).div(10000);
                super._transfer(from, address(tokenDividendTracker), holdFees);
                tokenDividendTracker.distributeCAKEDividends(holdFees);
                tokens = tokens.sub(holdFees);
                holdFeeTotal = holdFeeTotal.add(holdFees);
            }
            if (holdFeeSell > 0 && to == address(uniswapV2Pair)) {
                uint256 holdFees = amount.mul(holdFeeSell).div(10000);
                super._transfer(from, address(tokenDividendTracker), holdFees);
                tokenDividendTracker.distributeCAKEDividends(holdFees);
                tokens = tokens.sub(holdFees);
                holdFeeTotal = holdFeeTotal.add(holdFees);
            }

            if (liquidityDividendFeeBuy > 0 && from == address(uniswapV2Pair)) {
                uint256 liquidityDividendFees = amount.mul(liquidityDividendFeeBuy).div(10000);
                super._transfer(from, address(lpDividendTracker), liquidityDividendFees);
                tokens = tokens.sub(liquidityDividendFees);
                lpDividendTracker.distributeCAKEDividends(liquidityDividendFees);
                liquidityDividendFeeTotal = liquidityDividendFeeTotal.add(liquidityDividendFees);
            }

            if (liquidityDividendFeeSell > 0 && to == address(uniswapV2Pair)) {
                uint256 liquidityDividendFees = amount.mul(liquidityDividendFeeSell).div(10000);
                super._transfer(from, address(lpDividendTracker), liquidityDividendFees);
                tokens = tokens.sub(liquidityDividendFees);
                lpDividendTracker.distributeCAKEDividends(liquidityDividendFees);
                liquidityDividendFeeTotal = liquidityDividendFeeTotal.add(liquidityDividendFees);
            }

            if (daoDividendFeeBuy > 0 && from == address(uniswapV2Pair) && address(daoNft) != address(0)) {
                uint256 daoDividendFees = amount.mul(daoDividendFeeBuy).div(10000);
                super._transfer(from, address(this), daoDividendFees);
                tokens = tokens.sub(daoDividendFees);
                uint daoCount = daoNft.totalSupply();
                if(daoCount > 0) {
                    uint preReward = daoDividendFees.div(daoCount);
                    for(uint tokenId=1; tokenId <= daoCount; tokenId++){
                        daoReward[tokenId] = daoReward[tokenId].add(preReward);
                    }
                }
            }

            if (daoDividendFeeSell > 0 && to == address(uniswapV2Pair) && address(daoNft) != address(0)) {
                uint256 daoDividendFees = amount.mul(daoDividendFeeSell).div(10000);
                super._transfer(from, address(this), daoDividendFees);
                tokens = tokens.sub(daoDividendFees);
                uint daoCount = daoNft.totalSupply();
                if(daoCount > 0) {
                    uint preReward = daoDividendFees.div(daoCount);
                    for(uint tokenId=1; tokenId <= daoCount; tokenId++){
                        daoReward[tokenId] = daoReward[tokenId].add(preReward);
                    }
                }
            }

            if(from == address(uniswapV2Pair) || to == address(uniswapV2Pair)) {
                try lpDividendTracker.process(gasForProcessing) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                    emit LpProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gasForProcessing, tx.origin);
                } catch { }
            }
        }

        super._transfer(from, to, tokens);

        _updateDividendTrackerATMBalance(to);
        _updateDividendTrackerATMBalance(from);


        if(takeFee && (from == address(uniswapV2Pair) || to == address(uniswapV2Pair))){
            try tokenDividendTracker.process(gasForProcessing) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit TokenProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gasForProcessing, tx.origin);
            } catch {}
        }
    }

    function getLpNoFeeBalance() public view returns(uint){
        uint deadLpBalance = IUniswapV2Pair(uniswapV2Pair).balanceOf(deadWallet);
        uint adminLpBalance = IUniswapV2Pair(uniswapV2Pair).balanceOf(owner());
        return deadLpBalance.add(adminLpBalance);
    }

    function _updateDividendTrackerLpBalance(address account) private {
        uint lpBalance = IUniswapV2Pair(uniswapV2Pair).balanceOf(account);
        if (account != address(0) && !isContract(account) && lpBalance > 0) {
            try lpDividendTracker.setBalance(payable(account), lpBalance) {} catch {}
        }
    }
    function _updateDividendTrackerATMBalance(address account) private {
        uint balance = _balances[account];
        if (account != address(0) && !isContract(account)) {
            try tokenDividendTracker.setBalance(payable(account), balance) {} catch {}
        }
    }

    function _updateNftDaoFee(address account) private {
        if(account == address(0) || address(daoNft) == address(0)) {
            return;
        }
        uint length = daoNft.balanceOf(account);
        if(length > 0 && account != address(0) && !isContract(account)) {
            uint reward = 0;
            for(uint i; i<length; i++) {
                uint tokenId = daoNft.tokenOfOwnerByIndex(account, i);
                reward = reward.add(daoReward[tokenId]);
                daoReward[tokenId] = 0;
            }
            if(reward > 0){
                super._transfer(address(this), account, reward);
            }
        }
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function transferForeignToken(address _token, address _to, uint _amount) public mangeExecute returns(bool _sent){
        _sent = IERC20(_token).transfer(_to, _amount);
    }

    function Sweep(address _to, uint _amount) external mangeExecute {
        payable(_to).transfer(_amount);
    }

    function lpTokenConvertTokenB(uint amount) public view returns (uint) {
        uint totalSupply = IUniswapV2Pair(uniswapV2Pair).totalSupply();
        if(totalSupply == 0){
            return 0;
        }
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint token0Amount = uint(reserve0);
        uint token1Amount = uint(reserve1);
        uint totalTokenBAmount;
        if(IUniswapV2Pair(uniswapV2Pair).token0() == tokenB){
            totalTokenBAmount = token0Amount.mul(amount).div(totalSupply).mul(2);
        } else {
            totalTokenBAmount = token1Amount.mul(amount).div(totalSupply).mul(2);
        }
        return totalTokenBAmount;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function getDaoReward(address account) public view returns(uint) {
        if(account == address(0) || address(daoNft) == address(0)) {
            return 0;
        }
        uint length = daoNft.balanceOf(account);
        uint reward = 0;
        if(length > 0) {
            for(uint i; i<length; i++) {
                uint tokenId = daoNft.tokenOfOwnerByIndex(account, i);
                reward = reward.add(daoReward[tokenId]);
            }
        }
        return reward;
    }

    function getLpReward(address account) public view returns(uint) {
        uint lpReward = lpDividendTracker.withdrawableDividendOf(account);
        return lpReward;
    }

    function getHoldReward(address account) public view returns(uint) {
        uint holdReward = tokenDividendTracker.withdrawableDividendOf(account);
        return holdReward;
    }

    function getReward(address account) public view returns(uint) {
        return getDaoReward(account).add(getLpReward(account)).add(getHoldReward(account));
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function lpRewardActivated(address account) public view returns(bool){
        return lpDividendTracker.userLPTokens(account) > 0;
    }

}