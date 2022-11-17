/**
 *Submitted for verification at BscScan.com on 2022-11-17
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


/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.
interface DividendPayingTokenOptionalInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner) external view returns(uint256);

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner) external view returns(uint256);

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner) external view returns(uint256);
}


/// @title Dividend-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a dividend-paying token contract.
interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) external view returns(uint256);


    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend() external;

    /// @dev This event MUST emit when ether is distributed to token holders.
    /// @param from The address which sends ether to this contract.
    /// @param weiAmount The amount of distributed ether in wei.
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws ether from this contract.
    /// @param weiAmount The amount of withdrawn ether in wei.
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
}


/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
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


/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
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


/**
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
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


/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay and distribute ether
/// to token holders as dividends and allows token holders to withdraw their dividends.
/// Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public iNabana;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    // see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 constant internal magnitude = 2 ** 128;

    uint256 internal magnifiedDividendPerShare;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //     `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //     `dividendOf(_user)` should not be changed,
    //     but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //     `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //     where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //     `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    constructor(string memory _name, string memory _symbol, address _iNabana) ERC20(_name, _symbol) {
        iNabana = address(_iNabana);
    }

    function distributeiNabanaDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = IERC20(iNabana).transfer(user, _withdrawableDividend);

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) public view override returns(uint256) {
        return withdrawableDividendOf(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner) public view override returns(uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner) public view override returns(uint256) {
        return withdrawnDividends[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    ///     = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner) public view override returns(uint256) {
        return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
            .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
            .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
            .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}


contract Nabana is ERC20, Ownable {
    using SafeMath for uint256;

    // uniswap
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address public nabanaVesting;

    NabanaDividendTracker public dividendTracker;

    uint256 public maxSellTransactionAmount = 1000000 * (10 ** 18);
    uint256 public minSellTransactionAmount = 10000 * (10 ** 18);

    // magnigified from 1% => 100. Example: for 1% fee use 100, for 2.5% fee use 250
    uint256 public purchaseFee;
    uint256 public sellFee;

    address public treasuryWallet;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // TODO testnet
    // addresses for minting/vesting
    address private constant pancakeSwapLaunchWallet = 0x7Ef8E5643424bed763dD1BdE66d4b2f79F9EDcd8;
    address private constant pinkSaleWallet = 0x294d0487fdf7acecf342ae70AFc5549A6E90f3e0;
    address private constant privateInvestorsWallet = 0xb6596252872e20256f2D802F698dE341d21331Ee;
    address private constant managementAllocationWallet = 0x726704EC919CEAFb4c51b807e2Bc33B1a1e818F2;
    address private constant advisorsWallet = 0x8E4f7a8Ca048ddF7BB4bda8B853DF1770AC49660;
    address private constant influencersWallet = 0xDd5D35D9a781C8B3Ee3eA858b7b22AFD8CD44eA4;
    address private constant strategicPartnersWallet = 0x70d4bEf912a73A0D9fA07A1066bc49a745783D85;
    address private constant rewardsWallet = 0x81ED33AC3875379ee1A0d4625E2230b1A013e77d;
    address private constant reserveWallet = 0x91Bc6E15b7786480107413833C2e230631A77413;
    address private constant operationsWallet = 0x3edCe801a3f1851675e68589844B1b412EAc6B07;

    // TODO mainnet
    // TODO ask for rewardsWallet address
    // addresses for minting/vesting
    // address private constant pancakeSwapLaunchWallet = 0xE2BBF4D2931eae2f11655905b4A17d8367064F86;
    // address private constant pinkSaleWallet = 0x723c5de95AC9Cbf0b8c44C2c3F29405a1F219AB2;
    // address private constant privateInvestorsWallet = 0x57b5311745c21a900C051722Eb748C29cb135bB3;
    // address private constant managementAllocationWallet = 0x49E695A35bd65C735BB2b0033e77205b4C8cf02c;
    // address private constant advisorsWallet = 0x20027f3D87D107d7a5A304A940f3A63F98E67298;
    // address private constant influencersWallet = 0x3d574DE90E80b9Ce7CC48aC9520bDC9d19e549E4;
    // address private constant strategicPartnersWallet = 0xA0f77506698e9e2F5919fbbC76c362a0e41555f3;
    // address private constant rewardsWallet = 0xa9E8627F2c78992de6aF3c76120625930E1A826F;
    // address private constant reserveWallet = 0xFA38bFA8D5f3B4FB2E3B410F86a27776Ab3AAb4d;
    // address private constant operationsWallet = 0x572B508B44e53D48220ea9f6fF1021CAD049DffD;

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

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SendDividends(uint256 amount);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        uint256 lastProcessedInvestment,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    // constructor

    constructor(address _nabanaVesting) ERC20("Nabana", "BANA") {
        nabanaVesting = _nabanaVesting;

        treasuryWallet = msg.sender;

        purchaseFee = 300;
        sellFee = 500;

    	dividendTracker = new NabanaDividendTracker(payable(this));

        // TODO mainnet
    	// uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // TODO testnet
        uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(msg.sender);
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(nabanaVesting);
        dividendTracker.excludeFromDividends(pancakeSwapLaunchWallet);
        dividendTracker.excludeFromDividends(pinkSaleWallet);
        dividendTracker.excludeFromDividends(privateInvestorsWallet);
        dividendTracker.excludeFromDividends(managementAllocationWallet);
        dividendTracker.excludeFromDividends(advisorsWallet);
        dividendTracker.excludeFromDividends(influencersWallet);
        dividendTracker.excludeFromDividends(strategicPartnersWallet);
        dividendTracker.excludeFromDividends(rewardsWallet);
        dividendTracker.excludeFromDividends(reserveWallet);
        dividendTracker.excludeFromDividends(operationsWallet);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(dividendTracker), true);
        excludeFromFees(nabanaVesting, true);
        excludeFromFees(pancakeSwapLaunchWallet, true);
        excludeFromFees(pinkSaleWallet, true);
        excludeFromFees(privateInvestorsWallet, true);
        excludeFromFees(managementAllocationWallet, true);
        excludeFromFees(advisorsWallet, true);
        excludeFromFees(influencersWallet, true);
        excludeFromFees(strategicPartnersWallet, true);
        excludeFromFees(rewardsWallet, true);
        excludeFromFees(reserveWallet, true);
        excludeFromFees(operationsWallet, true);

        // minting tokens for vesting
        _mint(nabanaVesting, 15_000_000 * (10 ** 18));

        // minting leftover tokens
        _mint(pancakeSwapLaunchWallet, 15_000 * (10 ** 18));
        _mint(pinkSaleWallet, 25_000 * (10 ** 18));
        _mint(privateInvestorsWallet, 10_000_000 * (10 ** 18));
        _mint(rewardsWallet, 5_000_000 * (10 ** 18));
        _mint(operationsWallet, 19_960_000 * (10 ** 18));
    }

    receive() external payable {

  	}

    function updateNabanaVesting(address _nabanaVesting) external onlyOwner {
        require(nabanaVesting != _nabanaVesting, "Nabana: Nabana Vesting is already this address");
        nabanaVesting = _nabanaVesting;
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

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "Nabana: The dividend tracker already has that address");

        NabanaDividendTracker newDividendTracker = NabanaDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "Nabana: The new dividend tracker must be owned by the Nabana token contract");

        // exclude all AMMs except for primary PancakePair manually
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(uniswapV2Pair);
        newDividendTracker.excludeFromDividends(nabanaVesting);
        newDividendTracker.excludeFromDividends(pancakeSwapLaunchWallet);
        newDividendTracker.excludeFromDividends(pinkSaleWallet);
        newDividendTracker.excludeFromDividends(privateInvestorsWallet);
        newDividendTracker.excludeFromDividends(managementAllocationWallet);
        newDividendTracker.excludeFromDividends(advisorsWallet);
        newDividendTracker.excludeFromDividends(influencersWallet);
        newDividendTracker.excludeFromDividends(strategicPartnersWallet);
        newDividendTracker.excludeFromDividends(rewardsWallet);
        newDividendTracker.excludeFromDividends(reserveWallet);
        newDividendTracker.excludeFromDividends(operationsWallet);

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "Nabana: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
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

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "Nabana: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Nabana: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
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
            balanceOf(pinkSaleWallet) +
            balanceOf(privateInvestorsWallet) +
            balanceOf(managementAllocationWallet) +
            balanceOf(advisorsWallet) +
            balanceOf(influencersWallet) +
            balanceOf(strategicPartnersWallet) +
            balanceOf(rewardsWallet) +
            balanceOf(reserveWallet) +
            balanceOf(operationsWallet)
        );
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account) external view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
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
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex, uint256 lastProcessedInvestment) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, lastProcessedInvestment, false, gas, tx.origin);
    }

    // -------------------functions for selling limit
    function handleLimit(address from, uint256 amount) internal {
        // those excluded from fees have no selling limit
        if (_isExcludedFromFees[from]) {
            return;
        }

        if (balanceOf(from) > totalSupply().mul(1).div(100)) {
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
            if (_limitedUsers[from].sellTransactionTotalAmount.add(amount) > circulatingSupply().mul(20).div(100)) {
                require(
                    block.timestamp > _limitedUsers[from].sellTransactionRecordedTime.add(86400),
                    "Nabana: Blocked from selling. Please try a smaller amount or try again after 24 hours from your last transaction"
                );
            }

            if (block.timestamp > _limitedUsers[from].sellTransactionRecordedTime.add(86400)) {
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
    // ----------------------------------------------

    function _isSell(address sender, address recipient) internal view returns (bool) {
        // Transfer to pair from non-router address is a sell swap
        return sender != address(uniswapV2Router) && recipient == address(uniswapV2Pair);
    }

    function _isBuy(address sender) internal view returns (bool) {
        // Transfer from pair is a buy swap
        return sender == address(uniswapV2Pair);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
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
            automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFees[to] //no max for those excluded from fees
        ) {
            require(minSellTransactionAmount <= amount && amount <= maxSellTransactionAmount,
                "Nabana: Sell transfer amount should be within min and max of sell transaction limit.");
        }

        if (
            dividendTracker.isPrivateInvestor(from) &&
            dividendTracker.privateInvestmentsLength(from) > 0
        ) {
            uint256 gasIndividual = gasForProcessing / 2;

            try dividendTracker.process(gasIndividual, from) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcIndex,
                uint256 lastProcInvestment
            ) {
                emit ProcessedDividendTracker(iterations, claims, lastProcIndex, lastProcInvestment, true, gasIndividual, tx.origin);
            } catch {}
        }

        if (
            dividendTracker.isPrivateInvestor(to) &&
            dividendTracker.privateInvestmentsLength(to) > 0
        ) {
            uint256 gasIndividual = gasForProcessing / 2;

            try dividendTracker.process(gasIndividual, to) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcIndex,
                uint256 lastProcInvestment
            ) {
                emit ProcessedDividendTracker(iterations, claims, lastProcIndex, lastProcInvestment, true, gasIndividual, tx.origin);
            } catch {}
        }

        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
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
                super._transfer(from, address(treasuryWallet), totalFee);
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
            uint256 balance = balanceOf(to).add(amount);

            try dividendTracker.setBalance(payable(to), balance) {} catch {}

            dividendTracker.setInvestment(to, amount);
        }

        uint256 gas = gasForProcessing;

        try dividendTracker.process(gas) returns (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcIndex,
            uint256 lastProcInvestment
        ) {
            emit ProcessedDividendTracker(iterations, claims, lastProcIndex, lastProcInvestment, true, gas, tx.origin);
        } catch {}
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
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


contract NabanaDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    Nabana public nabana;

    IterableMapping.Map private tokenHoldersMap;
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

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    // constructor

    constructor(address payable _iNabana) DividendPayingToken("Nabana_Dividend_Tracker", "Nabana_Dividend_Tracker", _iNabana) {
        nabana = Nabana(_iNabana);

        intervalTime = 3 minutes;
        rewardIntervals = 6;
        unlockIntervals = 10;
        totalIntervals = 16;

        percentageToUnlock = 100;

        rewardAPY = 30000000000000000;

    	claimWait = 3 minutes;
        minimumTokenBalanceForDividends = 1; // must hold at least 1 Wei
    }

    function setInvestment(address account, uint256 amount) external onlyOwner {
        if (privateInvestments[account].length == 0) {
            isPrivateInvestor[account] = true;
        }

        Investment memory investment;
        investment.amount = amount;
        investment.amountToUnlock = amount;
        investment.startTime = block.timestamp;
        investment.rewardEndTime = block.timestamp.add(intervalTime.mul(rewardIntervals));
        investment.unlockEndTime = block.timestamp.add(intervalTime.mul(totalIntervals));
        // investment.currentInterval = 0;
        investment.lastClaimTime = block.timestamp;

        privateInvestments[account].push(investment);
    }

    function privateInvestmentsLength(address account) external view returns (uint256) {
        return privateInvestments[account].length;
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

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Nabana_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "Nabana_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main Nabana contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

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

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account) public view returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        uint256 withdrawableDividends,
        uint256 totalDividends,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable
    ) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = 
                    tokenHoldersMap.keys.length > lastProcessedIndex ?
                    tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                    0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        // lastClaimTime = lastClaimTimes[account][];

        // nextClaimTime = 
        //     lastClaimTime > 0 ?
        //     lastClaimTime.add(claimWait) :
        //     0;

        // secondsUntilAutoClaimAvailable = 
        //     nextClaimTime > block.timestamp ?
        //     nextClaimTime.sub(block.timestamp) :
        //     0;

        lastClaimTime = 0;
        nextClaimTime = 0;
        secondsUntilAutoClaimAvailable = 0;
    }

    function getAccountAtIndex(uint256 index) public view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
    	if (index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) public onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        // processAccount(account, true);
    }

    function process(uint256 gas) public onlyOwner returns (uint256, uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex, lastProcessedInvestment);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 _lastProcessedInvestment = lastProcessedInvestment;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            if (_lastProcessedInvestment >= privateInvestments[tokenHoldersMap.keys[_lastProcessedIndex]].length) {
                _lastProcessedIndex++;
                _lastProcessedInvestment = 0;

                iterations++;
            }

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(privateInvestments[account][_lastProcessedInvestment].lastClaimTime)) {
                if (processAccount(payable(account), _lastProcessedInvestment, true)) {
                    claims++;
                }
            }

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;

            _lastProcessedInvestment++;
        }

        lastProcessedIndex = _lastProcessedIndex;
        lastProcessedInvestment = _lastProcessedInvestment;

        return (iterations, claims, lastProcessedIndex, lastProcessedInvestment);
    }

    function process(uint256 gas, address account) public onlyOwner returns (uint256, uint256, uint256, uint256) {
        uint256 numberOfInvestments = privateInvestments[account].length;

        uint256 _lastProcessedInvestment = 0;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfInvestments) {
            if (canAutoClaim(privateInvestments[account][_lastProcessedInvestment].lastClaimTime)) {
                if (processAccount(payable(account), _lastProcessedInvestment, true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;

            _lastProcessedInvestment++;
        }

        uint256 index = 
            tokenHoldersMap.getIndexOfKey(account) < 0 ?
            uint256(-tokenHoldersMap.getIndexOfKey(account)) :
            uint256(tokenHoldersMap.getIndexOfKey(account));

        return (iterations, claims, index, _lastProcessedInvestment);
    }

    function processAccount(address payable account, uint256 index, bool automatic) public onlyOwner returns (bool) {
        Investment storage investment = privateInvestments[account][index];

        if (!canAutoClaim(investment.lastClaimTime)) {
            return false;
        }

        if (investment.currentInterval < rewardIntervals) {
            uint256 numberOfIntervals = block.timestamp.sub(investment.lastClaimTime).div(intervalTime);

            uint256 leftoverIntervals = rewardIntervals.sub(investment.currentInterval);

            numberOfIntervals = numberOfIntervals > leftoverIntervals ? leftoverIntervals : numberOfIntervals;

            uint256 ratio = rewardAPY;

            uint256 rewardAmount = _compound(
                investment.amount,
                ratio,
                numberOfIntervals
            );

            nabana.mintWithPermit(address(this), rewardAmount);

            investment.currentInterval += numberOfIntervals;
            investment.amountToUnlock += rewardAmount;

            investment.lastClaimTime = investment.startTime.add(investment.currentInterval.mul(intervalTime));

            distributeiNabanaDividends(rewardAmount);
        }

        if (
            investment.currentInterval >= rewardIntervals &&
            investment.currentInterval < totalIntervals
        ) {
            uint256 numberOfIntervals = block.timestamp.sub(investment.lastClaimTime).div(intervalTime);

            uint256 leftoverIntervals = totalIntervals.sub(investment.currentInterval);

            numberOfIntervals = numberOfIntervals > leftoverIntervals ? leftoverIntervals : numberOfIntervals;

            uint256 amountToUnlock = investment.amountToUnlock.mul(percentageToUnlock).div(1000);

            amountToUnlock *= numberOfIntervals;

            investment.currentInterval += numberOfIntervals;
            unlockedInvestments[account] += amountToUnlock;

            investment.lastClaimTime = investment.startTime.add(investment.currentInterval.mul(intervalTime));
        }

        if (investment.currentInterval >= totalIntervals) {
            uint256 balance = balanceOf(account);

            setBalance(account, balance.safeSub(investment.amount));

            uint256 lastIndex = privateInvestments[account].length - 1;
            Investment memory lastInvestment = privateInvestments[account][lastIndex];

            privateInvestments[account][index] = lastInvestment;
            privateInvestments[account].pop();
        }

        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            emit Claim(account, amount, automatic);
            return true;
        }

    	return false;
    }

    function _compound(uint256 _principal, uint256 _ratio, uint256 _exponent) internal pure returns (uint256) {
        if (_exponent == 0) {
            return 0;
        }

        uint256 accruedReward = ABDKMath64x64.mulu(ABDKMath64x64.pow(ABDKMath64x64.add(ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu(_ratio,10 ** 18)), _exponent), _principal);

        return accruedReward.sub(_principal);
    }
}