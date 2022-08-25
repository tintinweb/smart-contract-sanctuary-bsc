/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

////        ////            ///////////          ///////////  
      ////     ////            ///                  ///
       ////  ////            ///                  ///
        ///////             ///                  ///
         /////             \\\                  \\\
        ///////             \\\                  \\\
      ////   ////            \\\                  \\\
    ////      ////            \\\                   \\\
  ////         ////             \\\\\\\\\\\           \\\\\\\\\\\



pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
interface IBEP20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
interface IBEP20Metadata is IBEP20 {
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
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
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

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
contract BEP20 is Context, IBEP20, IBEP20Metadata {
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

interface IPancakeFactory {
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

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract usdtReceiver {
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    constructor() {
        IBEP20(usdt).approve(msg.sender,~uint256(0));
    }
}

contract FomoPool is Ownable {

    using SafeMath for uint256;
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    address[] public holders;
    mapping (address => uint256) private _balances;
    bool public distributeEnable;
    uint256 public minAmountForFomoRewards = 5 * (1e18);
    
    function getholderlength() external view returns(uint256){
        return holders.length;
    }

    function distribute() external onlyOwner {
        require(distributeEnable, "not time");
        uint256 nums = holders.length;
        require(nums > 0, "no account");

        uint256 balanceOfThis = IBEP20(usdt).balanceOf(address(this));
        if(balanceOfThis == 0) return;

        if(nums == 1) {
            IBEP20(usdt).transfer(holders[0], balanceOfThis.div(2));
        } else if (nums == 2) {
            IBEP20(usdt).transfer(holders[0], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[1], balanceOfThis.div(2));
        } else if (nums == 3) {
            IBEP20(usdt).transfer(holders[0], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[1], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[2], balanceOfThis.div(2));
        } else if (nums == 4) {
            IBEP20(usdt).transfer(holders[0], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[1], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[2], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[3], balanceOfThis.div(2));
        } else if (nums == 5) {
            IBEP20(usdt).transfer(holders[0], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[1], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[2], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[3], balanceOfThis.div(20));
            IBEP20(usdt).transfer(holders[4], balanceOfThis.div(2));
        } else {
            uint256 iterations;
            uint256 share;
            uint256 leftNums = nums - 5;
            uint256 leftBalance = balanceOfThis.mul(3).div(10);
            if(leftNums <= 95) {
                share = leftBalance.div(leftNums);
            } else if(leftNums > 95){
                share = leftBalance.div(95);
            }

            while(nums - iterations > 0 && iterations <= 100) {
                iterations++;
                if(_balances[holders[nums - iterations]] < minAmountForFomoRewards) 
                    continue;
                if(iterations == 1) {
                    IBEP20(usdt).transfer(holders[nums - iterations], balanceOfThis.div(2));
                } else if(iterations >= 2 && iterations <= 5) {
                    IBEP20(usdt).transfer(holders[nums - iterations], balanceOfThis.div(20));
                } else {
                    if(share > 0) {
                        IBEP20(usdt).transfer(holders[nums - iterations], share);
                    }
                }    
            }   
        }

        //clear array
        delete holders;

        distributeEnable = false;
    }

    function addAccount(address account, uint256 balanceOf) external onlyOwner {
        if(_balances[account] != balanceOf) {
            _balances[account] = balanceOf;
        }
        holders.push(account);
    }

    function setDistributeEnable(bool value) external onlyOwner {
        distributeEnable = value;
    }

    function setMinAmountForFomoRewards(uint256 value) external onlyOwner {
        minAmountForFomoRewards = value;
    }

    function claimLeftUSDT(uint256 amount) external onlyOwner {
        uint256 left = IBEP20(usdt).balanceOf(address(this));
        require(left >= amount, "unsufficient balance");
        IBEP20(usdt).transfer(owner(), amount);
    }
   
}

contract XCC is Ownable, BEP20 {
    using Address for address;
    using SafeMath for uint256;
   
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public fundWallet = 0xE2BFd8a3665EF128C3D6e9D934E8A330158f1aD0;

    uint256 public lpFee = 5;
    uint256 public fundFee = 1;
    uint256 public fomoFee = 2;
    uint256 public totalFee = lpFee + fomoFee + fundFee;

    uint256 public numTokensSellToAddToLiquidity = 100 * (1e18); 
    uint256 public maxAmountOfWallet = 1000 * (1e18); 
    uint256 public minAmountForLPDividend;
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    uint256 public lastProcessedIndex;

    uint256 public lastTxTimestamp;
    uint256 public interval = 12 hours;// fomo interval
    uint256 public _addedAmount;

    bool public isLaunch;
    uint256 public launchTime;
    address public pair;

    address private lastPotentialLPHolder;
    address[] public lpHolders;

    mapping (address => uint256) internal _balances;
    mapping (address => uint256) internal _lpAmount;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) public exemptFee;
    mapping (address => bool) public _isLPHolderExist;
    mapping(address => bool) public _isbclisted;
    IPancakeRouter02 private _router;
    usdtReceiver public _usdtReceiver;
    FomoPool public fomoPool;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() BEP20("XCC", "XCC") {
        exemptFee[_msgSender()] = true;
        exemptFee[fundWallet] = true;
        exemptFee[address(this)] = true;
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(
            address(usdt),
            address(this)
        );
        _usdtReceiver = new usdtReceiver();
        fomoPool = new FomoPool();
        _mint(owner(), 1000000 * (10**18));

        lastTxTimestamp = block.timestamp;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_isbclisted[sender], 'bclisted address');

        if(amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwap &&
            sender != pair
        ) {
            //swap and distribute
            swapAndDistribute(contractTokenBalance);
        }

        //fomo
        if(block.timestamp - lastTxTimestamp >= interval) {
            fomoPool.setDistributeEnable(true);
        }
        
        uint fees;
        if(!exemptFee[sender] && !exemptFee[recipient]) {
            fees = amount.mul(totalFee).div(100);
            require(isLaunch, "BEP20: Transfer not open");
            if (sender == pair && block.timestamp < launchTime + 9) {
                    _isbclisted[recipient] = true;
            }
        }
        
        if(fees > 0) {
            amount = amount.sub(fees);
            super._transfer(sender, address(this), fees);
        }

        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IBEP20(pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(recipient == pair && sender != address(this)) {
            lastPotentialLPHolder = sender;
        }

        super._transfer(sender, recipient, amount);

        if(recipient != pair && !exemptFee[recipient]) {
            require(balanceOf(recipient) <= maxAmountOfWallet, "ERC20: max amount limit for sigle address");
        } 

        if(sender == pair && !recipient.isContract()) {
            fomoPool.addAccount(recipient, balanceOf(recipient));
            lastTxTimestamp = block.timestamp;
        }  
    }

    function dividendToLPHolders(uint256 gas) internal {
        uint256 numberOfTokenHolders = lpHolders.length;

        if(numberOfTokenHolders == 0) {
            return;
        }

        uint256 totalRewards = IBEP20(usdt).balanceOf(address(this));
        if(totalRewards == 0) return;

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        IBEP20 pairContract = IBEP20(pair);
        uint256 totalLPAmount = (pairContract.totalSupply()).add(_addedAmount) - 1e3;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {

            _lastProcessedIndex++;

            if(_lastProcessedIndex >= lpHolders.length) {
                _lastProcessedIndex = 0;
            }

            address cur = lpHolders[_lastProcessedIndex];
            uint256 LPAmount;
            if(_lpAmount[cur] == 0) {
                LPAmount = pairContract.balanceOf(cur);
            } else {
                LPAmount = _lpAmount[cur];
            }     

            if(LPAmount >= minAmountForLPDividend) {
                uint256 dividendAmount = totalRewards.mul(LPAmount).div(totalLPAmount);
                if(dividendAmount <= 0) continue;
                uint256 balanceOfThis = IBEP20(usdt).balanceOf(address(this));
                if(balanceOfThis <= dividendAmount && _lastProcessedIndex > 0) {
                    _lastProcessedIndex--;
                    break;
                }
                IBEP20(usdt).transfer(cur, dividendAmount);
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    function swapAndDistribute(uint256 amount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(_router), amount);

        uint256 initialBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));

        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of USDT
            path,
            address(_usdtReceiver),
            block.timestamp
        );

        uint256 newBalance = (IBEP20(usdt).balanceOf(address(_usdtReceiver))).sub(initialBalance);

        IBEP20(usdt).transferFrom(address(_usdtReceiver), fundWallet, newBalance.mul(fundFee).div(totalFee));
        IBEP20(usdt).transferFrom(address(_usdtReceiver), address(fomoPool), newBalance.mul(fomoFee).div(totalFee));

        uint256 leftBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        IBEP20(usdt).transferFrom(address(_usdtReceiver), address(this), leftBalance);

        dividendToLPHolders(gasForProcessing);
    }

    function getfomobanlance() external view returns(uint256){
        return IBEP20(usdt).balanceOf(address(fomoPool));
    }

    function launch() public onlyOwner {
        require(!isLaunch, "BEP20: Allready launch");
        isLaunch = true;
        launchTime = block.timestamp;
    }

    function setNumTokensSellToAddToLiquidity(uint256 value) external onlyOwner { 
        numTokensSellToAddToLiquidity = value;
    }

    function setMaxAmountOfWallet(uint256 value) external onlyOwner { 
        maxAmountOfWallet = value;
    }

    function setFundWallet(address value) external onlyOwner { 
        fundWallet = value;
    }

    function bclistAddress(address account, bool value) public onlyOwner{
        _isbclisted[account] = value;
    }

    function setInterval(uint256 value) external onlyOwner { 
        interval = value;
    }

    function updatalastTxTimestamp() external onlyOwner {
        lastTxTimestamp = block.timestamp;
    }

    function setLpFee(uint256 _lpFee) external onlyOwner { 
        lpFee = _lpFee;
        totalFee = lpFee + fomoFee + fundFee;
    }

    function setFomoFee(uint256 _fomoFee) external onlyOwner { 
        fomoFee = _fomoFee;
        totalFee = lpFee + fomoFee + fundFee;
    }

    function setFundFee(uint256 _fundFee) external onlyOwner { 
        fundFee = _fundFee;
        totalFee = lpFee + fomoFee + fundFee;
    }

    function addAccount(address account, uint256 amount) external onlyOwner { 
        require(!_isLPHolderExist[account], "already exist");
        lpHolders.push(account);
        _lpAmount[account] = amount;
        _addedAmount = _addedAmount.add(amount);
        _isLPHolderExist[account] = true;
    }

    function addAccount2(address[] memory account, uint256 amount) external onlyOwner { 

        for(uint256 i = 0; i < account.length; i++) {
            lpHolders.push(account[i]);
            _lpAmount[account[i]] = amount;
            _addedAmount = _addedAmount.add(amount);
            _isLPHolderExist[account[i]] = true;
        }

    }

    function setExemptFee(address[] memory account, bool flag) external onlyOwner {
        require(account.length > 0, "no account");
        for(uint256 i = 0; i < account.length; i++) {
            exemptFee[account[i]] = flag;
        }
    }

    function claimLeftUSDTOfFomo(uint256 value) external onlyOwner { 
        fomoPool.claimLeftUSDT(value);
    }

    function setMinAmountForFomoRewards(uint256 value) external onlyOwner { 
        fomoPool.setMinAmountForFomoRewards(value);
    }

    function distribute() external onlyOwner { 
        fomoPool.distribute();
    }

    function setDistributeEnable(bool value) external onlyOwner { 
        fomoPool.setDistributeEnable(value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 1000000, "gasForProcessing must be between 200,000 and 1000,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function claimLeftUSDT() external onlyOwner {
        uint256 left = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        IBEP20(usdt).transferFrom(address(_usdtReceiver), owner(), left);
    }

    function claimLeftToken(address token) external onlyOwner {
        uint256 left = IBEP20(token).balanceOf(address(this));
        IBEP20(token).transfer(_msgSender(), left);
    }
    
    function airdrop(address[] memory accounts, uint256 amount) public onlyOwner {
        require(accounts.length > 0, "no account");
        require(amount > 0, "no amount");
        address cur;
        uint256 totalAmount = (accounts.length).mul(amount);
        require(totalAmount > 0, "error amount");
        _balances[msg.sender] = _balances[msg.sender].sub(totalAmount);
        for(uint256 i = 0; i < accounts.length; i++) {
            cur = accounts[i];
            _balances[cur] = _balances[cur].add(amount);
            emit Transfer(msg.sender, cur, amount);
        }
    }
}