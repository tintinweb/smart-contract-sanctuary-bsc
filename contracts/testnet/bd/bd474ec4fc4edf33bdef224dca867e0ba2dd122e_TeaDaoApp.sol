/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-21
 */

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

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
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {/**
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);*/
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

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
     /*
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }*/

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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
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

interface dividendStaking {
    function arriveFeeRewardsAccount(address account) external payable;
}

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}
contract FarmContract is ERC20, Ownable{
    using SafeMath for uint256;
    bool inited;//初始化
    uint256 public rebates;//返佣率
    uint256 public rebatesLevel;//返佣级别
    address mainToken;//主质押代币
    uint256 lockApy = 132;//锁定日利率1.32% 1.32*365=481.8
    uint256 Apy = 2;//普通日利率 0.02 年利率 0.02*365=7.3
    using EnumerableSet for EnumerableSet.AddressSet;
    // Declare a set state variable
    EnumerableSet.AddressSet private userList;
    //我的下级列表
    mapping(address => EnumerableSet.AddressSet) private InvitationSon;
    //我的上线
    mapping(address => address) public Invitation;
    //质押列表
    mapping(address => stakingInfo) public stakingList;
    struct stakingInfo{
        address owner;//质押归属地址
        address addr;//持有钱包地址
        uint256 lockTime;//锁定时间
        uint256 stakingTime;//质押时间 过去了多久
        uint256 staking;//质押数量
        uint256 receives;//已提取奖励
        uint256 rebates;//获得的返佣
    }
    function init(address owner,address _mainToken,uint256 _lockApy,uint256 _Apy) external {
        require(!inited);
        inited = true;
        mainToken = _mainToken;
        _owner = owner;
        lockApy = _lockApy;
        Apy = _Apy;
    }

    //质押
    function staking(uint256 amount,uint256 lockDay,address agent,address owner) external{
        IERC20 token = IERC20(mainToken);
        require(token.balanceOf(msg.sender) >= amount, "INSUFFICIENT_BALANCE");
        if(Invitation[msg.sender] == address(0) && agent != address(0) && agent != msg.sender){
            Invitation[msg.sender] = agent;//增加上级
            InvitationSon[agent].add(msg.sender);//增加下级
        }
        token.transferFrom(msg.sender,address(this), amount);
        //block.number
        stakingInfo memory _staking = stakingList[msg.sender];
        uint256 Reward = _caclClaim(_staking);
        if(owner == address(0)){
            _staking.owner = msg.sender;
        }else{
            _staking.owner = owner;
        }
        _staking.addr = msg.sender;
        _staking.lockTime = block.timestamp.add(lockDay.mul(1 days));
        _staking.stakingTime = block.timestamp;
        _staking.staking = amount.add(Reward);//增加质押数额
        stakingList[msg.sender] = _staking;
    }
    //查询收益
    function canCaim(address to) external view
        returns (uint256 _res){
        stakingInfo memory _staking = stakingList[to];
        return _caclClaim(_staking);
    }
    //计算利息
    function _caclClaim(stakingInfo memory _staking) private view
        returns (uint256 _res){
        uint256 totalAmount = _staking.staking;//基础质押额度
        uint256 stakDay = (block.timestamp - _staking.stakingTime).div(1 days);//总质押天数
        uint256 lockDay = (_staking.lockTime - _staking.stakingTime).div(1 days);//获得锁定天数
        uint256 rate = lockDay.mul(lockApy);//总锁定天数 * 锁定利率
        //锁定时间大于已质押时间
        if(lockApy>=stakDay){
            uint256 rateAmount = totalAmount.mul(rate).div(10000).div(lockApy.mul(1 days));//得到每秒的利息
            _res = (block.timestamp - _staking.stakingTime).mul(rateAmount);//总秒数 * 每秒获得的利息
        }else{
            //超过锁定时间 先计算锁定apy利息
            uint256 rateAmount = totalAmount.mul(rate).div(10000);
            //在计算普通利息 基础金额 * (天数 * apy) + 锁定利息
            _res = rateAmount.add( totalAmount.mul((stakDay - lockDay).mul(Apy)).div(10000));
        }
    }
    //领取利息跟本金
    function Claim(address to) external{
        stakingInfo memory _staking = stakingList[msg.sender];
        uint256 Reward = _caclClaim(_staking);
        require(Reward>0, "INSUFFICIENT_BALANCE");
        if(rebatesLevel>0 && rebates>0){
            callRebatesLevel(Reward,msg.sender);
            Reward = Reward.sub( Reward.mul(rebates).div(100));
        }
        Reward += _staking.staking;//奖励+本金
        IERC20 token = IERC20(mainToken);
        token.transfer(to, Reward);
        //清除质押信息
        _staking.lockTime = 0;
        _staking.stakingTime = 0;
        _staking.staking = 0;
        stakingList[msg.sender] = _staking;
    }
    function callRebatesLevel(uint256 reward,address from) private{
        //rebatesLevel
        IERC20 token = IERC20(mainToken);
        uint256 send = reward.mul(rebates).div(100);
        address lastAccount = Invitation[from];
        for(uint i = 0; i < rebatesLevel; i++){
            if(lastAccount == address(0)){
                break;
            }
            //提取给上级的返佣
            uint256 half = send.mul(rebates).div(100);
            send = send.sub(half);
            token.transfer(lastAccount, send);
            stakingList[lastAccount].rebates = send;//获得的返佣
            send = half;
            lastAccount = Invitation[lastAccount];
        }
    }
    /**获取线下总数 */
    function getInvitationLength() external view returns (uint256) {
        return InvitationSon[msg.sender].length();
    }
    /**获取线下数据*/
    function getInvitationList(address to ,uint256 from, uint256 limit)
        external
        view
        returns (stakingInfo[] memory items)
    {
        items = new stakingInfo[](limit);
        uint256 length = InvitationSon[to].length();
        if (from + limit > length) {
            limit = length.sub(from);
        }
        address addr;
        for (uint256 index = 0; index < limit; index++) {
            addr = InvitationSon[to].at(from + index);
            items[index] = stakingList[addr];
        }
    }
    //更换质押代币
    function setMainToken(
        address _mainToken
    ) external onlyOwner {
        mainToken = _mainToken;
    }
    //设置Apy
    //uint256 public rebates;//返佣率
    //uint256 public rebatesLevel;//返佣级别
    function resetApy(
        uint256 _lockApy,uint256 _Apy,uint256 _rebates,uint256 _rebatesLevel
    ) external onlyOwner {
        lockApy = _lockApy;
        Apy = _Apy;
        rebates=_rebates;
        rebatesLevel=_rebatesLevel;
    }
    //提取合约ERC20
    function receiveERC20(
        address addr,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20 token = IERC20(addr);
        if (amount == 0) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }
    //提取合约ETH
    function receiveETH(address payable to, uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = payable(address(this)).balance;
        }
        to.transfer(amount);
    }
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
}

contract TeaDaoApp is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    uint256 public taxFee = 6;
    dividendStaking public dividend;
    mapping(address => bool) public _farm;
    mapping(address => bool) public pairs;
    mapping(address => bool) public _excludedFees;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public farmPools;
    address public uniswapPair;
    bool swapIng;
    //bool inited;
    uint256 public Inflation = 90;//通胀率
    uint256 public lastAmount;
    constructor(){
        _name = "TeaDao.app";
        _symbol = "Tea Coin";
        //_excludedFees[_msgSender()] = true;
        _excludedFees[address(this)] = true;
        _owner = _msgSender();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        pairs[uniswapPair] = true;
        uniswapV2Router = _uniswapV2Router;
        _approve(_msgSender(), address(uniswapV2Router), ~uint256(0));
        // 1 * 10**8 * 10**18
        _mint(_msgSender(), 100000 * 10**18);
        FarmContract Farm = new FarmContract();
        Farm.init(_msgSender(), address(this),132,2);
        farmPools = address(Farm);
    }
    /*
    function init(string memory m_name, string memory m_symbol,address owner) external {
        require(!inited);
        _name = m_name;
        _symbol = m_symbol;
        _owner = owner;
        inited = true;
        _excludedFees[address(this)] = true;
        //0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //测试合约 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //薄饼合约 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        pairs[uniswapPair] = true;
        uniswapV2Router = _uniswapV2Router;
        _approve(_msgSender(), address(uniswapV2Router), ~uint256(0));
        // 1 * 10**8 * 10**18
        _mint(_msgSender(), 100000 * 10**18);
    }*/
    event Deploy(address addr);
    function deployFarm(address owner,address _mainToken,uint256 _lockApy,uint256 _Apy) external payable{
        FarmContract Farm = new FarmContract();
        Farm.init(owner, _mainToken,_lockApy,_Apy);
        require(msg.value >= callPay, "INSUFFICIENT_BALANCE");
        mintFee(msg.sender, callPay);
        emit Deploy(address(Farm));
    }
    //外部支付
    function callPayMint(address to) external payable{
        mintFee(to, msg.value);
    }

    function setRoute(address adr) external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(adr);
    }
    function isExcludedFromFees(address account) external view returns (bool) {
        return _excludedFees[account];
    }
    function excludedFarm(address account, bool excluded) external onlyOwner {
        _farm[account] = excluded;
    }
    //生态农场挖矿
    function farm(address recipient, uint256 amount) external {
        require(recipient != address(0), "0x is not accepted here");
        require(amount > 0, "not accept 0 value");
        require(_farm[msg.sender] == true, "vip user");
        if (_farm[msg.sender] && _farm[recipient]) {
            _mint(recipient, amount);
        }
    }
    function setPair(address _Pair, bool flag) external onlyOwner {
        pairs[_Pair] = flag;
    }
    function setDividend(address _dividend) external onlyOwner {
        dividend = dividendStaking(_dividend);
    }
    function excludedFromFees(address account, bool excluded) external onlyOwner {
        _excludedFees[account] = excluded;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (!_excludedFees[from] && !_excludedFees[to]) {
            uint256 fees;
            if (pairs[from]) {//buy  from==uniswapPair
                fees = amount.mul(taxFee).div(100);
                if(Inflation>taxFee){//通缩
                    lastAmount += amount.mul(Inflation).div(100);
                    _mint(address(this), amount.mul(Inflation).div(100));//买入的时候mint代币
                    Inflation-=1;
                    super._transfer(from, address(this), fees);
                }
                //通缩小于税收 免税
            } else if(pairs[to]) {//sell
                if(taxFee>=Inflation){//免税
                    Inflation+=1;
                }else if(Inflation<90){
                    fees = amount.mul(taxFee).div(100);
                    uint256 tax = fees;
                    Inflation+=1;
                    tax = fees.mul(2);
                    if (!swapIng && balanceOf(address(this)) > tax) {
                        swapIng = true;
                        swapTokenToReward(tax, from);
                        swapETH();
                        swapIng = false;
                    }
                    super._transfer(from, address(this), fees.sub(1));
                }
            }
            if (fees > 0) {
                amount -= fees;
            }
        }
        super._transfer(from, to, amount);
    }
    //总服务费用
    uint256 public ethFee;
    function mintFee(address to,uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        uint256 deserved = uniswapV2Router.getAmountsOut(amount, path)[path.length - 1];
        _mint(to, deserved.mul(30).div(100));
        ethFee+=amount;
    }
    /**添加池子 */
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    //计算市场价格mint代币并增加池子
    function mintEthAddLiquidity (uint256 amount)private{
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        amount += ethFee;
        uint256 deserved = uniswapV2Router.getAmountsOut(amount, path)[path.length - 1];
        _mint(address(this), deserved);
        addLiquidity(deserved, amount);
        ethFee=0;
    }
    /**mint代币并售出 */
    function swapETH() private {
        if(lastAmount >0){
            uint256 amount = lastAmount;
            uint256 balance = payable(address(this)).balance;
            swapTokensForEth(amount);
            balance = payable(address(this)).balance.sub(balance);
            mintEthAddLiquidity(balance);//mint 加池
            lastAmount = 0;
        }
    }
    /**将Token卖出ETH */
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    /**将Token卖出并激活分红 */
    function swapTokenToReward(uint256 tokenAmountIn, address from) private {
        uint256 contractRewardBalance = payable(address(this)).balance;
        swapTokensForEth(tokenAmountIn);
        /*
        _approve(address(this), address(uniswapV2Router), tokenAmountIn);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmountIn,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );*/
        contractRewardBalance = payable(address(this)).balance.sub(contractRewardBalance);
        uint256 amountin = contractRewardBalance.mul(600).div(1000);
        if (address(dividend) != address(0)) {
            try dividend.arriveFeeRewardsAccount{value: amountin}(from) {} catch {}
        }
    }
    uint256 public checkTxPrice = 0.004 ether;
    uint256 public callFee = 0.004 ether;
    uint256 public callPay = 0.3 ether;
    function setTxPrice(uint256 _txprice,uint256 _feeprice,uint256 _callPay) external onlyOwner {
        checkTxPrice = _txprice;
        callFee = _feeprice;
        callPay = _callPay;
    }
    function _checkTax(address[] calldata _tempPath) private {
        address[] memory path = toWETHPath(_tempPath);
        IERC20 token = IERC20(path[path.length - 1]);
        uint256 balance = token.balanceOf(address(this));
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: checkTxPrice}(0, path, address(this), block.timestamp);
        balance = token.balanceOf(address(this)) - balance;
        path = reversePath(path);
        token.approve(address(uniswapV2Router), balance);
        uint256 deserved = uniswapV2Router.getAmountsOut(balance, path)[path.length - 1];
        uint256 Amount = payable(address(this)).balance;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(balance, 0, path, address(this), block.timestamp);
        uint256 totalAmount = payable(address(this)).balance - Amount;
        require(((deserved * 90) / 100) + totalAmount > deserved, unicode"貔貅");
    }
    function toWETHPath(address[] calldata _tempPath) private view returns (address[] memory _path) {
        if (_tempPath[0] != uniswapV2Router.WETH()) {
            _path = new address[](_tempPath.length + 1);
            _path[0] = uniswapV2Router.WETH();
            for (uint256 i = 0; i < _tempPath.length; i++) {
                _path[i + 1] = _tempPath[i];
            }
        } else {
            _path = _tempPath;
        }
    }
    function reversePath(address[] memory _tempPath) private pure returns (address[] memory _path) {
        _path = new address[](_tempPath.length);
        for (uint256 i = 0; i < _tempPath.length; i++) {
            _path[_tempPath.length - i - 1] = _tempPath[i];
        }
    }
    /**
     *如果是主网币交换 传递的总量应该是 amountIn*count*accounts.lenght + checkTax(如果有 +0.005 ether)
     *
     *@param amountIn 单笔购买的数量
     *@param count 每个账号购买多少次 必须大于0
     *@param slippage 总体滑点
     *@param checkTax 是否检测貔貅 如果检测貔貅请追加 0.005 eth
     *@param accounts 接受资产的账号列表, 如果只有一个账号可以为空
     *@param path 交换的路由,
     *如果 path[0]==WETH 传递需要的ETH总量
     *否则 path[0] token请提前授权给当前合约
     */
    function manyTokensBuy(
        uint256 amountIn,
        uint256 count,
        uint256 slippage,
        bool checkTax,
        address[] memory accounts,
        address[] calldata path
    ) external payable {
        if (checkTax && msg.value >= checkTxPrice) {
            _checkTax(path);
        }
        if (accounts.length == 0) {
            accounts = new address[](1);
            accounts[0] = msg.sender;
        }
        uint256 canValue = amountIn * count * accounts.length;
        if (path[0] != uniswapV2Router.WETH()) {
            IERC20 inToken = IERC20(path[0]);
            inToken.transferFrom(msg.sender, address(this), canValue);
            inToken.approve(address(uniswapV2Router), canValue);
        }
        IERC20 token = IERC20(path[path.length - 1]);
        uint256 balance;
        uint256 totalAmount;
        uint256 deserved = uniswapV2Router.getAmountsOut(canValue, path)[path.length - 1];
        for (uint256 ai = 0; ai < accounts.length; ai++) {
            balance = token.balanceOf(accounts[ai]);
            for (uint256 ci = 0; ci < count; ci++) {
                if (path[0] == uniswapV2Router.WETH()) {
                    uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(0, path, accounts[ai], block.timestamp);
                }else if(path[path.length - 1] == uniswapV2Router.WETH()){
                    
                    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, 0, path, accounts[ai], block.timestamp);
                } else {
                    uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, path, accounts[ai], block.timestamp);
                }
            }
            totalAmount += token.balanceOf(accounts[ai]) - balance;
        }
        require(((deserved * slippage) / 100) + totalAmount > deserved, "slippage");
        if (path[0] == uniswapV2Router.WETH()) {
            //eth  手续费+交换所需+貔貅检测(如果有)
            require(msg.value >= (checkTax ? canValue + checkTxPrice : canValue) + callFee, "INSUFFICIENT_BALANCE");
        } else {
            //token  手续费+貔貅检测(如果有)
            require(msg.value >= (checkTax ? callFee + checkTxPrice : callFee), "INSUFFICIENT_BALANCE");
        }
        mintFee(msg.sender, (checkTax ? callFee + checkTxPrice : callFee));
    }
    //批量转ERC20
    function manyTransferToken(
        address tokenAddress,
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external payable {
        require(msg.value >= callFee, "INSUFFICIENT_BALANCE");
        IERC20 token = IERC20(tokenAddress);
        for (uint256 i = 0; i < accounts.length; i++) {
            if(token.balanceOf(msg.sender)>=amounts[i]){
                token.transferFrom(msg.sender,accounts[i], amounts[i]);
            }
        }
        mintFee( msg.sender,callFee);
    }
    //批量转ETH
    function manyTransferETH(address[] calldata accounts, uint256[] calldata amounts) external payable {
        uint256 total;
        for (uint256 i = 0; i < accounts.length; i++) {
            payable(accounts[i]).transfer(amounts[i]);
            total += amounts[i];
        }
        //实际收到ETH - 实际发送ETH  > 手续费
        require(msg.value - total >= callFee, "INSUFFICIENT_BALANCE");
        mintFee( msg.sender,callFee);
    }
    //提取合约ERC20
    function receiveERC20(
        address addr,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20 token = IERC20(addr);
        if (amount == 0) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }
    //提取合约ETH
    function receiveETH(address payable to, uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = payable(address(this)).balance;
        }
        to.transfer(amount);
    }
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
}