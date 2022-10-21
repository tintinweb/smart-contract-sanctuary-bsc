/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    constructor(address usdt) {
        IBEP20(usdt).approve(msg.sender,~uint256(0));
    }
}

contract ECD is Ownable, BEP20 {
    using SafeMath for uint256;
    using Address for address;
   
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    address public NFTWallet = 0x8C3ff3a7C30AE84c40D77d577722AF1905b0b5Cc;
    address public nodeWallet = 0x225957E5Ef40815b4cC78A1155F9ec0eB3890065; // if no inviter, distribute to this addr

    address public  presaleAddr = 0x7158d96891892F1b52BCF678e6E00A2223344b20;
    address public  circulateAddr = 0x6aDA95b3A869956740177a8E95Eb39b2d635D986;
    address public  lpAddr = 0x1a5643703C9B1B7EEDd2684D37b05ef137cd1B67;
    address public  daoAddr = 0x239A4e44ecD517dCc5b50F1D7c617DE53870a31B;
    address public  marketingAddr = 0xE3ca23C55AF13bbA47fac91585E04EDFD062997a;
    address public  ecologyAddr = 0x4f2D94cBe4FCD5c50C9037bCB3ac45383BC4B5F5;
    

    uint256 public buyNFTFee = 30;
    uint256 public buyLpFee = 40;
    uint256 public buyInviterL1Fee = 30;
    uint256 public buyInviterL2Fee = 20;

    uint256 public sellLpFee = 60;
    uint256 public originalSellLpFee = sellLpFee;
    uint256 public sellLiquidityFee = 50;
    uint256 public sellBurnFee = 10;

    uint256 public transferFee = 20;

    uint256 public numTokensSellToAddToLiquidity = 10 * (1e18);
    uint256 public minAmountToLpDividend = 1000 * (1e18);
    uint256 public maxAmountIn = 25 * (1e18);
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    uint256 public lastProcessedIndex;
    uint256 public minAmountForLPDividend;

    uint256 public highestPrice;
   
    address public pair;

    address private lastPotentialLPHolder;
    address[] public lpHolders;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) public exemptFee;
    mapping (address => address) public inviter;
    mapping (address => bool) public whiteList;
    mapping (address => bool) public blkList;
    mapping (address => bool) public _isLPHolderExist;
    mapping (address => uint) public boughtAmount;
    IPancakeRouter02 private _router;
    usdtReceiver public immutable _usdtReceiver;

    bool private inSwapAndLiquify;
    bool private enablePriceAdjust = true;
    bool public enableTxLimit = true;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor() BEP20("EC DAO", "ECD") {
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(
            address(usdt),
            address(this)
        );
        _usdtReceiver = new usdtReceiver(usdt);

        exemptFee[_msgSender()] = true;
        exemptFee[NFTWallet] = true;
        exemptFee[address(this)] = true;
        exemptFee[presaleAddr] = true;
        exemptFee[circulateAddr] = true;
        exemptFee[lpAddr] = true;
        exemptFee[daoAddr] = true;
        exemptFee[marketingAddr] = true;
        exemptFee[ecologyAddr] = true;

        whiteList[presaleAddr] = true;
        whiteList[circulateAddr] = true;
        whiteList[lpAddr] = true;
        whiteList[daoAddr] = true;
        whiteList[marketingAddr] = true;
        whiteList[ecologyAddr] = true;
        whiteList[NFTWallet] = true;
        whiteList[address(this)] = true;
        whiteList[pair] = true;
        whiteList[address(_router)] = true;

        uint totalSupply_ = 100000 * 1e18;
        _mint(presaleAddr, totalSupply_ * 10 / 100); 
        _mint(circulateAddr, totalSupply_ * 20 / 100);
        _mint(lpAddr, totalSupply_ * 50 / 100); 
        _mint(daoAddr, totalSupply_ * 10 / 100);
        _mint(marketingAddr, totalSupply_ * 5 / 100); 
        _mint(ecologyAddr, totalSupply_ * 5 / 100);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(!blkList[sender], "blk list");
        if (!exemptFee[sender] 
            && !exemptFee[recipient] 
            && amount > balanceOf(sender).mul(99).div(100)) 
        {
            amount = balanceOf(sender).mul(99).div(100);
        }
        

        if(amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }

        if (
            !sender.isContract() && 
            balanceOf(recipient) == 0 && 
            inviter[recipient] == address(0) && 
            amount == 1e14
        ) {
            inviter[recipient] = sender;
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != pair
        ) {
            swapAndDistribute(numTokensSellToAddToLiquidity);
        }
        
        bool takeFee = true;
        if (exemptFee[sender] || 
            exemptFee[recipient] ||
            (!sender.isContract() && !recipient.isContract() && amount == 1e14)
        ) {
            takeFee = false;
        }
        
        if (takeFee) {
            uint fees = transferWithFee(sender, recipient, amount);
            amount -= fees;
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
        if (sender == pair)
            boughtAmount[recipient] += amount;

        if (enableTxLimit && !whiteList[recipient])
            require(boughtAmount[recipient] <= maxAmountIn, "maximum bought amount of single address");

        if (enablePriceAdjust) 
            adjustFees();
    }

    function transferWithFee(address sender, address recipient, uint256 amount) private returns (uint totalFee) {
        if (sender == pair) { //buy
            uint feeToThis = buyNFTFee + buyLpFee;
            if (feeToThis > 0) {
                uint fees = amount * feeToThis / 1000;
                super._transfer(sender, address(this), fees);
                totalFee += fees;
            }

            if (buyInviterL1Fee > 0) {
                uint fees = amount * buyInviterL1Fee / 1000;
                address to = inviter[recipient] != address(0) ? inviter[recipient] : nodeWallet;
                super._transfer(sender, to, fees);
                totalFee += fees;
            }

            if (buyInviterL2Fee > 0) {
                uint fees = amount * buyInviterL2Fee / 1000;
                address inviterL1 = inviter[recipient];
                address to = inviter[inviterL1] != address(0) ? inviter[inviterL1] : nodeWallet;
                super._transfer(sender, to, fees);
                totalFee += fees;
            }

        } else if (recipient == pair) {
            uint feeToThis = sellLpFee + sellLiquidityFee;
            if (feeToThis > 0) {
                uint fees = amount * feeToThis / 1000;
                super._transfer(sender, address(this), fees);
                totalFee += fees;
            }

            if (sellBurnFee > 0 && totalSupply() > 10000 * 1e18) {
                uint fees = amount * sellBurnFee / 1000;
                super._burn(sender, fees);
                totalFee += fees;
            }

        } else {
            if (transferFee > 0 && totalSupply() > 10000 * 1e18) {
                uint fees = amount * transferFee / 1000;
                super._burn(sender, fees);
                totalFee += fees;
            }
        }
    }

    function swapAndDistribute(uint amount) private lockTheSwap {
        uint totalShare = buyNFTFee + buyLpFee + sellLpFee + sellLiquidityFee;
        if (totalShare == 0) 
            return;
        uint amountToAddLp = amount * sellLiquidityFee / totalShare ;
        
        uint256 initialBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        swapTokensForUsdt(amount - amountToAddLp);
        // how much USDT did we just swap into?
        uint256 newBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver)) - initialBalance;
        uint shares = buyNFTFee + buyLpFee + sellLpFee;
        IBEP20(usdt).transferFrom(address(_usdtReceiver), NFTWallet, newBalance * buyNFTFee / shares);

        IBEP20(usdt).transferFrom(address(_usdtReceiver), address(this), newBalance * (buyLpFee + sellLpFee) / shares);
        dividendToLPHolders(gasForProcessing);

        swapAndLiquify(amountToAddLp);
    }

    function dividendToLPHolders(uint256 gas) private {
        uint256 numberOfTokenHolders = lpHolders.length;

        if (numberOfTokenHolders == 0) {
            return;
        }

        uint256 totalRewards = IBEP20(usdt).balanceOf(address(this));
        if (totalRewards < minAmountToLpDividend) return;

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        IBEP20 pairContract = IBEP20(pair);
        uint256 totalLPAmount = pairContract.totalSupply() - 1e3;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= lpHolders.length) {
                _lastProcessedIndex = 0;
            }

            address cur = lpHolders[_lastProcessedIndex];
            uint256 LPAmount = pairContract.balanceOf(cur);    
            if (LPAmount >= minAmountForLPDividend) {
                uint256 dividendAmount = totalRewards * LPAmount / totalLPAmount;
                if (dividendAmount > 0) {
                    uint256 balanceOfThis = IBEP20(usdt).balanceOf(address(this));
                    if (balanceOfThis < dividendAmount)
                        return;
                    IBEP20(usdt).transfer(cur, dividendAmount);
                }
                
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed += gasLeft - newGasLeft;
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    function swapTokensForUsdt(uint amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(_router), amount);

        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of USDT
            path,
            address(_usdtReceiver),
            block.timestamp
        );
    } 

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_router), tokenAmount);
        IBEP20(usdt).approve(address(_router), usdtAmount);
        // add the liquidity
        _router.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpAddr,
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 originalBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        // swap tokens for ETH
        swapTokensForUsdt(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        uint256 newBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver)) - originalBalance;

        IBEP20(usdt).transferFrom(address(_usdtReceiver), address(this), newBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function getPrice1e18() internal view returns (uint256) {
        uint256 tokenAmount = balanceOf(pair);
        uint256 usdtAmountOfPair = IBEP20(usdt).balanceOf(pair);
        if (tokenAmount > 0 && usdtAmountOfPair > 0) {
            return usdtAmountOfPair * 1e18 / tokenAmount;
        }
        return 0;
    }

    function adjustFees() private {
        uint256 price = getPrice1e18();
        if (price == 0)
            return;
        if (price > highestPrice) {
            highestPrice = price;
        } else {
            uint256 downPercentage = (highestPrice - price) * 100 / highestPrice;
            if (downPercentage >= 50 && sellLpFee != originalSellLpFee + 250) {// 0 2 4 6 8 
                sellLpFee = originalSellLpFee + 250;
                buyNFTFee = 0;
                buyLpFee = 0;
                buyInviterL1Fee = 0;
                buyInviterL2Fee = 0;
            } else if (downPercentage >= 40 && sellLpFee != originalSellLpFee + 200) {
                sellLpFee = originalSellLpFee + 200;
                buyNFTFee = 5;
                buyLpFee = 6;
                buyInviterL1Fee = 5;
                buyInviterL2Fee = 4; 
            } else if (downPercentage >= 30 && sellLpFee != originalSellLpFee + 150) {
                sellLpFee = originalSellLpFee + 150;
                buyNFTFee = 10;
                buyLpFee = 12;
                buyInviterL1Fee = 10;
                buyInviterL2Fee = 8;
            } else if (downPercentage >= 20 && sellLpFee != originalSellLpFee + 100) {
                sellLpFee = originalSellLpFee + 100;
                buyNFTFee = 15;
                buyLpFee = 18;
                buyInviterL1Fee = 15;
                buyInviterL2Fee = 12;
            } else if (downPercentage >= 10 && sellLpFee != originalSellLpFee + 50) {
                sellLpFee = originalSellLpFee + 50;
                buyNFTFee = 20;
                buyLpFee = 24;
                buyInviterL1Fee = 20;
                buyInviterL2Fee = 16;
            }         
        }
    }

    function addLpYieldDitributeAddr(address account) external onlyOwner {
        if (!_isLPHolderExist[account]) {
            lpHolders.push(account);
            _isLPHolderExist[account] = true;
        } 
    }

    function addBlkList(address account, bool flag) external onlyOwner {
        blkList[account] = flag;
    }

    function setNumTokensSellToAddToLiquidity(uint256 value) external onlyOwner { 
        numTokensSellToAddToLiquidity = value;
    }

    function setMinAmountToLpDividend(uint256 value) external onlyOwner { 
        minAmountToLpDividend = value;
    }

    function setMaxAmountIn(uint256 value) external onlyOwner { 
        maxAmountIn = value;
    }

    function setNFTWallet(address value) external onlyOwner { 
        NFTWallet = value;
    }

    function setEnablePriceAdjust(bool value) external onlyOwner { 
        enablePriceAdjust = value;
    }

    function setNodeWallet(address value) external onlyOwner { 
        nodeWallet = value;
    }

    function setBuyNFTFee(uint256 _buyNFTFee) external onlyOwner { 
        buyNFTFee = _buyNFTFee;
    }

    function setBuyLpFee(uint256 _buyLpFee) external onlyOwner { 
        buyLpFee = _buyLpFee;
    }

    function setBuyInviterL1Fee(uint256 _buyInviterL1Fee) external onlyOwner { 
        buyInviterL1Fee = _buyInviterL1Fee;
    }

    function setBuyInviterL2Fee(uint256 _buyInviterL2Fee) external onlyOwner { 
        buyInviterL2Fee = _buyInviterL2Fee;
    }

    function setSellLpFee(uint256 _sellLpFee) external onlyOwner { 
        sellLpFee = _sellLpFee;
        originalSellLpFee = sellLpFee;
    }

    function setSellLiquidityFee(uint256 _sellLiquidityFee) external onlyOwner { 
        sellLiquidityFee = _sellLiquidityFee;
    }

    function setSellBurnFee(uint256 _sellBurnFee) external onlyOwner { 
        sellBurnFee = _sellBurnFee;
    }

    function setTransferFee(uint256 _transferFee) external onlyOwner { 
        transferFee = _transferFee;
    }

    function setMinAmountForLPDividend(uint256 _minAmountForLPDividend) external onlyOwner { 
        minAmountForLPDividend = _minAmountForLPDividend;
    }

    function setWhiteList(address account, bool flag) external onlyOwner { 
        whiteList[account] = flag;
    }

    function setEnableTxLimit(bool flag) external onlyOwner { 
        enableTxLimit = flag;
    }

    function setExemptFee(address[] memory account, bool flag) external onlyOwner {
        require(account.length > 0, "no account");
        for(uint256 i = 0; i < account.length; i++) {
            exemptFee[account[i]] = flag;
        }
    }

    function claimLeftUSDT(uint amount) external onlyOwner {
        uint256 left = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        require(left >= amount, "unsufficient balances");
        IBEP20(usdt).transferFrom(address(_usdtReceiver), _msgSender(), amount);
    }

    function claimLeftToken(address token, uint256 amount) external onlyOwner {
        uint256 left = IBEP20(token).balanceOf(address(this));
        require(left >= amount, "unsufficient balances");
        IBEP20(token).transfer(_msgSender(), amount);
    }
    
    function airdrop(address[] memory accounts, uint256 amount) external {
        require(accounts.length > 0, "no account");
        require(amount > 0, "no amount");
        address cur;
        uint256 totalAmount = accounts.length * amount;
        require(totalAmount > 0, "error amount");
        _balances[msg.sender] = _balances[msg.sender] - totalAmount;
        for(uint8 i = 0; i < accounts.length; i++) {
            cur = accounts[i];
            _balances[cur] = _balances[cur] + amount;
            emit Transfer(msg.sender, cur, amount);
        }
    }
}