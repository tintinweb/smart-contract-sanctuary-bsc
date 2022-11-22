/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// File: erc20bsc/base/Context.sol



pragma solidity =0.8.8;

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
// File: erc20bsc/base/Ownable.sol



pragma solidity =0.8.8;


/**
  * @dev Ownable contract
 */
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
// File: erc20bsc/lib/SafeMath.sol



pragma solidity =0.8.8;

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
// File: erc20bsc/interfaces/IERC20Metadata.sol



pragma solidity =0.8.8;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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





/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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
// File: erc20bsc/base/ERC20.sol



pragma solidity ^0.8.7;






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

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 9. To select a different value for
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
     * Tokens usually opt for a value of 9, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
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
// File: erc20bsc/interfaces/IUniswapV2Pair.sol



pragma solidity =0.8.8;

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
// File: erc20bsc/interfaces/IUniswapV2Factory.sol



pragma solidity =0.8.8;

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
// File: erc20bsc/interfaces/IUniswapV2Router02.sol



pragma solidity =0.8.8;

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
// File: erc20bsc/BSCDAO.sol


pragma solidity =0.8.8;






/**
 * @title The BSC Dao
 * @author BSCDAO
 * @notice The BSC DAO ERC20 token contract
 */
contract BSCDAO is ERC20, Ownable {
  using SafeMath for uint256;

  /// @notice Receive bnb
  receive() external payable {}

  /// @notice The uniswap router contract
  IUniswapV2Router02 public uniswapV2Router;

  /// @notice The contract of BSCDAO/WETH pair
  address public uniswapV2Pair;

  /// @notice The identifier to check if meta is active
  bool private isMetaActive = true;

  /// @notice The identifier to check if BSCDAO trading started or not
  bool public isTradingEnabled;

  /// @notice The unix timestamp of BSCDAO launch
  uint256 public launchTime;

  /// @notice The total supply of BSCDAO token
  uint256 internal tokenSupply = 20000000000 * (10**9);

  /// @notice The account of dead wallet
  address public constant DEAD_WALLET =
    0x000000000000000000000000000000000000dEaD;

  /// @notice The list of blacklisted accounts
  mapping(address => bool) public _isBlacklisted;

  /// @notice The meta X
  uint256 public metaX = 0;

  /// @notice The meta Y
  uint256 public metaY = 12;

  /// @notice The total supply of BSCDAO
  uint256 internal bscDaoTotalSupply = 20000000000 * (10**9);

  /// @notice The maximum limit of single transfer transaction
  uint256 public maxTranscation = 5000000000000000;

  /// @notice The enabled/disabled status of BSCDAO anti dump feature
  bool public isAntiDumpEnabled = false;

  /// @notice The status of verifier one vote
  bool public isVerifierOneVoted = false;

  /// @notice The status of verifier owner vote
  bool public isVerifierOwnerVoted = false;

  /// @notice The account of metaX
  address public metaWallet = 0x46C99F178e0175DB844E60559597c041EE57cDA0;

  /// @notice The account of first verifier
  address public firstVerifier = 0x46C99F178e0175DB844E60559597c041EE57cDA0;

  /**
   * @dev Throw error when msgSender() is not equal to first verifier
   */
  modifier onlyfirstVerifier() {
    require(_msgSender() == firstVerifier, "Only First Verifier");
    _;
  }

  /// @notice The list of accounts exclude from fees
  mapping(address => bool) private _isExcludedFromFees;

  /// @notice The anti dump times
  mapping(address => uint256) public antiDump;

  /// @notice The total amount of BSCDAO selling
  mapping(address => uint256) public totalSelling;

  /// @notice The last timestamp of sell
  mapping(address => uint256) public lastSellstamp;

  /// @notice The grace period of anti dump
  uint256 public antiDumpGracePeriod = 10 minutes;

  /// @notice The BSCDAO token amount of anti dump
  uint256 public antiDumpAmount = bscDaoTotalSupply.mul(5).div(10000);

  /// @notice The BSCDAO pairs on pancakeswap
  mapping(address => bool) public ammPairs;

  /**
   * @notice Emits when BSCDAO owner updates pancakeswap v2 router contract
   * @param newRouter The contract address of new pancakeswap router
   * @param oldRouter The contract address of old pancakeswap router
   */
  event UpdateUniswapV2Router(
    address indexed newRouter,
    address indexed oldRouter
  );

  /**
   * @notice Emits when BSCDAO owner excludes fee for specific account
   * @param account The account of user
   * @param isExcluded The status of excluded from fees
   */
  event ExcludeFromFees(address indexed account, bool isExcluded);

  /**
   * @notice Emits when BSCDAO owner excludes fees for multiple accounts
   * @param accounts The list of user accounts
   * @param isExcluded The status of excluded from fees
   */
  event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

  /**
   * @notice Emits when BSCDAO owner sets the ammPair
   * @param pair The contract address of pair
   * @param value The status of pair existance
   */
  event SetAmmPair(address indexed pair, bool indexed value);

  /**
   * @notice Initialization of BSCDAO contract
   */
  constructor() ERC20("BSCDAO", "BSCDAO") payable {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
      0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    );

    address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
      .createPair(address(this), _uniswapV2Router.WETH());

    uniswapV2Router = _uniswapV2Router;
    uniswapV2Pair = _uniswapV2Pair;

    _setAmmPair(_uniswapV2Pair, true);

    // exclude from paying fees or having max transaction amount
    excludeFromFees(owner(), true);
    excludeFromFees(address(this), true);

    _mint(owner(), tokenSupply);
  }

  /**
   * @notice Starts anti dump security feature
   * @param _isAntiDumpEnabled The enabled/disabled status of BSCDAO anti dump feature
   */
  function setIsAntiDumpEnabled(bool _isAntiDumpEnabled) external onlyOwner {
    isAntiDumpEnabled = _isAntiDumpEnabled;
  }

  /**
   * @notice Sets antiDump period and amount
   * @param period The period
   * @param amount The amount
   */
  function setAntiDump(uint256 period, uint256 amount) external onlyOwner {
    antiDumpGracePeriod = period;
    antiDumpAmount = amount;
  }

  /**
   * @notice Update pancake swap router contract
   * @param newRouter The new contract of pancakeswap router
   */
  function updateUniswapV2Router(address newRouter) public onlyOwner {
    require(
      newRouter != address(uniswapV2Router),
      "BSCDAO: The router already has that address"
    );
    require(newRouter != address(0), "new address is zero address");
    emit UpdateUniswapV2Router(newRouter, address(uniswapV2Router));
    uniswapV2Router = IUniswapV2Router02(newRouter);
    address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
      .createPair(address(this), uniswapV2Router.WETH());
    uniswapV2Pair = _uniswapV2Pair;
  }

  /**
   * @notice Exclude from fees to any user account
   * @param account The account of user
   * @param excluded The status of exclude from fee
   */
  function excludeFromFees(address account, bool excluded) public onlyOwner {
    require(
      _isExcludedFromFees[account] != excluded,
      "BSCDAO: Account is already the value of 'excluded'"
    );
    _isExcludedFromFees[account] = excluded;

    emit ExcludeFromFees(account, excluded);
  }

  /**
   * @notice Exclude from fees to multiple users
   * @param accounts The list of user accounts
   * @param excluded The status of excluded from fees
   */
  function excludeMultipleAccountsFromFees(
    address[] calldata accounts,
    bool excluded
  ) public onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
      _isExcludedFromFees[accounts[i]] = excluded;
    }

    emit ExcludeMultipleAccountsFromFees(accounts, excluded);
  }

  /**
   * @notice Update meta X
   * @param value The percentage value of metaX
   */
  function updateMetaX(uint256 value) external onlyOwner {
    metaX = value;
  }

  /**
   * @notice Update Meta Y
   * @param value The percentage value of metaY
   */
  function updateMetaY(uint256 value) external onlyOwner {
    metaY = value;
  }

  /**
   * @notice Sets maximum transaction limit of single transfer
   * @param _maxTransaction The maximum limit of single transfer transaction
   */
  function setMaxTranscation(uint256 _maxTransaction) external onlyOwner {
    maxTranscation = _maxTransaction;
  }

  /**
   * @notice Update meta wallet
   * @param _metaWallet The account of meta
   */
  function updateMetaWallet(address _metaWallet) public onlyOwner {
    metaWallet = _metaWallet;
  }

  /**
   * @notice Update first verifier account
   * @param _firstVerifier The account of first verifier
   */
  function updateFirstVerifier(address _firstVerifier) public onlyOwner {
    require(
      _firstVerifier != address(0),
      "Ownable: new voter is the zero address"
    );
    require(
      isVerifierOneVoted == true && isVerifierOwnerVoted == true,
      "not active"
    );
    firstVerifier = _firstVerifier;
    isVerifierOneVoted = false;
  }

  /**
   * @notice Set active status of BSCDAO meta
   * @param _isMetaActive The active status of BSCDAO meta
   */
  function setIsMetaActive(bool _isMetaActive) external onlyOwner {
    isMetaActive = _isMetaActive;
  }

  /**
   * @notice Vote verifier one
   * @param _isVerifierOneVoted The vote status of verifier one
   */
  function voteVerifierOne(bool _isVerifierOneVoted) public onlyfirstVerifier {
    isVerifierOneVoted = _isVerifierOneVoted;
  }

  /**
   * @notice Vote verifier owner
   * @param _isVerifierOwnerVoted The vote status of verifier owner
   */
  function voteVerifierOwner(bool _isVerifierOwnerVoted) public onlyOwner {
    isVerifierOwnerVoted = _isVerifierOwnerVoted;
  }

  /**
   * @notice Enable BSCDAO trading
   */
  function enableTrading() external onlyOwner {
    require(launchTime == 0, "Already Launched");
    launchTime = block.timestamp;
    isTradingEnabled = true;
  }

  /**
   * @notice Disable BSCDAO trading
   */
  function disableTrading() external onlyOwner {
    launchTime = 0;
    isTradingEnabled = false;
  }

  /**
   * @notice Set AMM pair
   * @param pair The contract address of pair
   * @param flag The identifier of pair listing
   */
  function setAmmPair(address pair, bool flag) public onlyOwner {
    require(
      pair != uniswapV2Pair,
      "BSCDAO: The PanBUSDSwap pair cannot be removed from automatedMarketMakerPairs"
    );

    _setAmmPair(pair, flag);
  }

  /**
   * @notice Blacklist any user
   * @param account The account of user
   * @param flag The flag of blacklisted
   */
  function blacklistAddress(address account, bool flag) external onlyOwner {
    _isBlacklisted[account] = flag;
  }

  /**
   * @notice Set AMM pair
   * @param pair The contract address of pair
   * @param flag The identifier of pair listing
   */
  function _setAmmPair(address pair, bool flag) private {
    require(
      ammPairs[pair] != flag,
      "BSCDAO: Automated market maker pair is already set to that value"
    );
    ammPairs[pair] = flag;

    emit SetAmmPair(pair, flag);
  }

  /**
   * @notice Returns exclude from fee status of specific user account
   * @param account The account of user
   * @return isExcluded The exclude status of specific user account
   */
  function isExcludedFromFees(address account) public view returns (bool) {
    return _isExcludedFromFees[account];
  }

  /**
   * @inheritdoc ERC20
   */
  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(
      !_isBlacklisted[from] && !_isBlacklisted[to],
      "Blacklisted address"
    );
    require(
      _isExcludedFromFees[from] ||
        _isExcludedFromFees[to] ||
        amount <= maxTranscation,
      "Max transaction Limit Exceeds!"
    );

    if (!_isExcludedFromFees[from]) {
      require(isTradingEnabled, "Trading not enabled yet");
    }

    if (from == owner()) {
      require(
        isVerifierOneVoted == true && isVerifierOwnerVoted == true,
        "Not Active Yet"
      );
    }

    if (amount == 0) {
      super._transfer(from, to, 0);
      return;
    }

    if (
      !_isExcludedFromFees[from] &&
      !_isExcludedFromFees[to] &&
      launchTime + 3 minutes >= block.timestamp
    ) {
      // don't allow to buy more than 0.01% of total supply for 3 minutes after launch
      require(
        ammPairs[from] || balanceOf(to).add(amount) <= tokenSupply.div(10000),
        "AntiBot: Buy Banned"
      );
      if (launchTime + 180 seconds >= block.timestamp)
        // don't allow sell for 180 seconds after launch
        require(ammPairs[to], "AntiBot: Sell Banned");
    }

    if (isAntiDumpEnabled && ammPairs[to] && !_isExcludedFromFees[from]) {
      require(antiDump[from] < block.timestamp, "Err: antiDump active");
      if (lastSellstamp[from] + antiDumpGracePeriod < block.timestamp) {
        lastSellstamp[from] = block.timestamp;
        totalSelling[from] = 0;
      }
      totalSelling[from] = totalSelling[from].add(amount);
      if (totalSelling[from] >= antiDumpAmount) {
        antiDump[from] = block.timestamp + antiDumpGracePeriod;
      }
    }

    bool takeMeta = isMetaActive;

    // if any account belongs to _isExcludedFromFee account then remove the fee
    if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
      takeMeta = false;
    }

    if (takeMeta) {
      uint256 fees = 0;
      if (ammPairs[from]) {
        fees += amount.mul(metaX).div(100);
      }
      if (ammPairs[to]) {
        fees += amount.mul(metaY).div(100);
      }
      amount = amount.sub(fees);

      super._transfer(from, metaWallet, fees);
    }

    super._transfer(from, to, amount);
  }

  /**
   * @notice Rescue any token
   * @param token The contract address of token
   * @param amount The amount of token to rescue
   */
  function rescueToken(address token, uint256 amount) public onlyOwner {
    require(token != address(this), "Invalid Token");
    require(
      isVerifierOneVoted == true && isVerifierOwnerVoted == true,
      "Rescue Token Failed"
    );
    IERC20(token).transfer(owner(), amount);
  }

  /**
   * @notice Rescue BNB
   * @param withdrawableAddress The account to withdraw bnb
   */
  function rescueBNB(address withdrawableAddress) public onlyOwner {
    require(withdrawableAddress != address(0), "Invalid Withdrawable Account");
    (bool success, ) = withdrawableAddress.call{value: address(this).balance}(
      ""
    );
    require(success, "Rescue BNB Failed");
  }

  /**
   * @notice Add Liquidity
   * @param tokenAmount The amount of token
   * @param bnbValue The BNB value
   */
  function addLiquidity(uint256 tokenAmount, uint256 bnbValue) private {
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // add the liquidity
    uniswapV2Router.addLiquidityETH{value: bnbValue}(
      address(this),
      tokenAmount,
      0, // slippage is unavoidable
      0, // slippage is unavoidable
      address(0),
      block.timestamp
    );
  }
}