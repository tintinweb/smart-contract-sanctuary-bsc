/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


interface IPancakeSwapRouter{
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


interface IPancakeSwapFactory {
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


interface IPancakeSwapPair {
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

interface IMocDao {

    function getParentRelations(address _address) external view returns(address[] memory);

    function isHasMocd(address _address) external view returns(bool);
}


contract Moc is ERC20Detailed, Ownable {
    using SafeMath for uint256;

    string private _name = "Moc Token";
    string private _symbol = "MOC";
    uint8 private _decimals = 8;
    uint256 private _totalSupply;
    uint256 private constant MAX_SUPPLY = ~uint128(0) / 1e14;

    uint256 public constant DECIMALS = 8;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 8;
    uint256 public minMocAmount;

    uint256 public buyInviteFee = 50;
    uint256 public buyLiqMocFee = 50;
    uint256 public buyBackExiFee = 50;
    uint256 public sellLiqExiFee = 50;
    uint256 public sellBackEaiFee = 50;
    uint256 public sellDeadFee = 25;
    uint256 public sellMarketingFee = 25;
    uint256 public transferFee = 150;
    uint256 public feeDenominator = 1000;
    uint256 public totalInviteAmount;

    bool inSwap = false;

    uint256 private TOTAL_GONS;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public blacklist;

    address public mocPair;
    address public usdtAddress;
    address public mocdAddress;
    address public eaiAddress;
    IPancakeSwapRouter public router;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    address public marketingReceiver;
    address public backExiReceiver;
    address public liqExiReceiver;
    address public liqMocReceiver;
    address public backEaiReceiver;

    bool public _autoRebase;
    bool public _autoSwapBack;
    bool public _autoAddLiquidity;
    uint256 public lastRebasedTime;
    uint256 public rebaseInterval;
    uint256 public lastAddLiquidityTime;
    uint256 public addLiquidityInterval;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address _router,
        address _usdtAddress,
        uint256 _initSupply,
        uint256 _startTime,
        uint256 _rebaseInterval,
        uint256 _minMocAmount
    ) ERC20Detailed(_name, _symbol, uint8(_decimals)) Ownable() {
        usdtAddress = _usdtAddress;
        router = IPancakeSwapRouter(_router);
        mocPair = IPancakeSwapFactory(router.factory()).createPair(
            address(this),
            usdtAddress
        );

        require(_initSupply > 0, "invalid init supply");
        _totalSupply = _initSupply * 10**DECIMALS;

        TOTAL_GONS = MAX_UINT256 / 1e10 - ((MAX_UINT256 / 1e10) % _totalSupply);
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _autoRebase = true;
        _autoSwapBack = true;
        _autoAddLiquidity = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        lastRebasedTime = _startTime;
        lastAddLiquidityTime = _startTime;
        rebaseInterval = _rebaseInterval;
        addLiquidityInterval = 10 minutes;
        minMocAmount = _minMocAmount * 1e8;
        totalInviteAmount = 0;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function manualRebase() external {
        require(shouldRebase(), "rebase not required");
        rebase();
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate = 1700000; //1.7% per 12 hours
        uint256 deltaTime = block.timestamp - lastRebasedTime;
        uint256 times = deltaTime.div(rebaseInterval);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        lastRebasedTime = lastRebasedTime.add(times.mul(rebaseInterval));

        emit LogRebase(times, _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transferFrom(from, to, value);
        return true;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        require(!blacklist[from] && !blacklist[to], "in_blacklist");
        require(from != address(0), "ERC20: transfer from the zero address");

        uint256 gonAmount = value.mul(_gonsPerFragment);
        uint256 fromBalance = _balances[from] > 0
            ? _balances[from]
            : _gonBalances[from].div(_gonsPerFragment);

        require(fromBalance >= value, "ERC20: transfer amount exceeds balance");

      if (inSwap) {
            return _basicTransfer(from, to, value);
        }

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            _swapBackEai();
        }

        if (shouldAddLiquidity()) {
            _addLiquidityForMoc();
        }

        if (from == mocPair || _isTokenAccount(from)) {
            _balances[from] -= value;
        } else {
            uint256 subFromBalance = (_gonBalances[from].sub(gonAmount)).div(
                _gonsPerFragment
            );

            if (subFromBalance >= minMocAmount) {
                _gonBalances[from] -= gonAmount;
            } else {
                _balances[from] = subFromBalance;
            }
        }

        if (to == DEAD) {
            _balances[DEAD] += value;
            emit Transfer(from, to, value);
            return true;
        }

       // uint256 gonAmountReceived = shouldTakeFee(from, to)
        //     ? takeFee(from, to, gonAmount)
        //     : gonAmount;

        uint256 gonAmountReceived = gonAmount;

        if (to == mocPair) {
            _balances[to] += gonAmountReceived.div(_gonsPerFragment);
        } else {
            if (!_isTokenAccount(to)) {
                _gonBalances[to] += gonAmountReceived;
            } else {
                uint256 addToBalance = _balances[to].add(
                    gonAmountReceived.div(_gonsPerFragment)
                );
                if (_isHasMocd(to) && addToBalance >= minMocAmount) {
                    _gonBalances[to] = addToBalance.mul(_gonsPerFragment);
                } else {
                    _balances[to] = addToBalance;
                }
            }
        }

        emit Transfer(from, to, gonAmountReceived.div(_gonsPerFragment));
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        uint256 gonAmount = value.mul(_gonsPerFragment);

        if (from == mocPair || _isTokenAccount(from)) {
            _balances[from] -= value;
        } else {
            uint256 subFromBalance = (_gonBalances[from].sub(gonAmount)).div(
                _gonsPerFragment
            );

            if (subFromBalance >= minMocAmount) {
                _gonBalances[from] -= gonAmount;
            } else {
                _balances[from] = subFromBalance;
            }
        }

        if (to == mocPair) {
            _balances[to] += value;
        } else {
            if (!_isTokenAccount(to)) {
                _gonBalances[to] += gonAmount;
            } else {
                uint256 addToBalance = _balances[to].add(value);
                if (_isHasMocd(to) && addToBalance >= minMocAmount) {
                    _gonBalances[to] = addToBalance.mul(_gonsPerFragment);
                } else {
                    _balances[to] = addToBalance;
                }
            }
        }
        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = _allowedFragments[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= value, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - value);
            }
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return
            _gonBalances[account] > 0
                ? _gonBalances[account].div(_gonsPerFragment)
                : _balances[account];
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(_balances[DEAD]).sub(_balances[ZERO]);
    }

    function takeFee(
        address from,
        address to,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _totalFee = 0;

        if (from == mocPair && to != mocPair) {
            (uint112 reserve0, uint112 reserve1, ) = IPancakeSwapPair(mocPair)
                .getReserves();
            uint256 amountA;
            if (reserve0 > 0 && reserve1 > 0) {
                amountA = router.quote(
                    gonAmount.div(_gonsPerFragment),
                    reserve1,
                    reserve0
                );
            }

            if (IERC20(usdtAddress).balanceOf(mocPair) < reserve0 + amountA) {
                _totalFee = _totalFee.add(buyInviteFee).add(buyBackExiFee).add(
                    buyLiqMocFee
                );
                uint256 _totalInviteFee = gonAmount.mul(buyInviteFee).div(
                    feeDenominator
                );

                address[] memory _parentInviters = IMocDao(mocdAddress)
                    .getParentRelations(to);
                uint256 _cInviteFee;
                for (uint8 i = 0; i < _parentInviters.length; i++) {
                    uint256 _inviteFee;
                    if (i == 0 || i == 9) {
                        _inviteFee = gonAmount.mul(9).div(feeDenominator);
                    }
                    if (i == 1 || i == 8) {
                        _inviteFee = gonAmount.mul(7).div(feeDenominator);
                    }
                    if (i == 2 || i == 7) {
                        _inviteFee = gonAmount.mul(5).div(feeDenominator);
                    }
                    if (i == 3 || i == 6) {
                        _inviteFee = gonAmount.mul(3).div(feeDenominator);
                    }
                    if (i == 4) {
                        _inviteFee = gonAmount.mul(1).div(feeDenominator);
                    }
                    _cInviteFee += _inviteFee;

                    if (_isTokenAccount(_parentInviters[i])) {
                        uint256 addInviteAmount = _balances[_parentInviters[i]]
                            .add(_inviteFee.div(_gonsPerFragment));
                        if (
                            _isHasMocd(_parentInviters[i]) &&
                            addInviteAmount >= minMocAmount
                        ) {
                            _gonBalances[_parentInviters[i]] = addInviteAmount
                                .mul(_gonsPerFragment);
                        } else {
                            _balances[_parentInviters[i]] += _inviteFee.div(
                                _gonsPerFragment
                            );
                        }
                    } else {
                        _gonBalances[_parentInviters[i]] += _inviteFee;
                    }

                    emit Transfer(
                        from,
                        _parentInviters[i],
                        _inviteFee.div(_gonsPerFragment)
                    );
                }

                uint256 tempFee = 0;
                tempFee = (_totalInviteFee.sub(_cInviteFee)).div(
                    _gonsPerFragment
                );
                _balances[DEAD] += tempFee;
                emit Transfer(from, DEAD, tempFee);

                totalInviteAmount = totalInviteAmount.add(
                    _cInviteFee.div(_gonsPerFragment)
                );

                tempFee = gonAmount.mul(buyBackExiFee).div(feeDenominator).div(
                    _gonsPerFragment
                );
                _balances[backExiReceiver] += tempFee;
                emit Transfer(from, backExiReceiver, tempFee);

                tempFee = gonAmount.mul(buyLiqMocFee).div(feeDenominator).div(
                    _gonsPerFragment
                );
                _balances[liqMocReceiver] += tempFee;
                emit Transfer(from, liqMocReceiver, tempFee);
            }
        }

        if (from != mocPair && to == mocPair) {
            (uint112 reserve0, uint112 reserve1, ) = IPancakeSwapPair(mocPair)
                .getReserves();
            uint256 amountA;
            if (reserve0 > 0 && reserve1 > 0) {
                amountA = router.quote(
                    gonAmount.div(_gonsPerFragment),
                    reserve1,
                    reserve0
                );
            }

            uint256 balanceA = IERC20(usdtAddress).balanceOf(mocPair);
            if (balanceA < reserve0 + amountA) {
                _totalFee = _totalFee
                    .add(sellLiqExiFee)
                    .add(sellBackEaiFee)
                    .add(sellDeadFee)
                    .add(sellMarketingFee);

                uint256 tempFee = 0;

                tempFee = gonAmount.mul(sellLiqExiFee).div(feeDenominator).div(
                    _gonsPerFragment
                );
                _balances[liqExiReceiver] += tempFee;
                emit Transfer(from, liqExiReceiver, tempFee);

                tempFee = gonAmount.mul(sellBackEaiFee).div(feeDenominator).div(
                        _gonsPerFragment
                    );
                _balances[backEaiReceiver] += tempFee;
                emit Transfer(from, backEaiReceiver, tempFee);

                tempFee = gonAmount.mul(sellDeadFee).div(feeDenominator).div(
                    _gonsPerFragment
                );
                _balances[DEAD] += tempFee;
                emit Transfer(from, DEAD, tempFee);

                tempFee = gonAmount
                    .mul(sellMarketingFee)
                    .div(feeDenominator)
                    .div(_gonsPerFragment);
                _balances[marketingReceiver] += tempFee;
                emit Transfer(from, marketingReceiver, tempFee);
            }
        }

        if (from != mocPair && to != mocPair) {
            _totalFee = _totalFee.add(transferFee);
            uint256 _deadFee = gonAmount
                .mul(transferFee)
                .div(feeDenominator)
                .div(_gonsPerFragment);
            _balances[DEAD] += _deadFee;
            emit Transfer(from, DEAD, _deadFee);
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);
        return gonAmount.sub(feeAmount);
    }

    function _addLiquidityForMoc() internal swapping {
        uint256 half = _balances[liqMocReceiver].div(2);
        uint256 otherHalf = _balances[liqMocReceiver].sub(half);

        _balances[liqMocReceiver] = 0;

        swapTokensForCake(address(this), usdtAddress, half, liqMocReceiver);

        uint256 amountB = IERC20(usdtAddress).balanceOf(liqMocReceiver);

        _approve(liqMocReceiver, address(router), half);
        router.addLiquidity(
            address(this),
            usdtAddress,
            otherHalf,
            amountB,
            0,
            0,
            liqMocReceiver,
            block.timestamp
        );

        lastAddLiquidityTime = block.timestamp;
    }

    function swapTokensForCake(
        address _tokenA,
        address _tokenB,
        uint256 tokenAmount,
        address to
    ) private {
        address[] memory path = new address[](3);
        path[0] = _tokenA;
        path[1] = router.WETH();
        path[2] = _tokenB;
        _approve(to, address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _swapBackEai() internal swapping {
        uint256 _backEaiFee = _balances[backEaiReceiver];

        _balances[backEaiReceiver] = 0;
        //swap Moc token for eai token
        swapTokensForCake(
            address(this),
            eaiAddress,
            _backEaiFee,
            backEaiReceiver
        );
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != mocPair &&
            block.timestamp >= (lastRebasedTime + rebaseInterval);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity &&
            msg.sender != mocPair &&
            block.timestamp >= (lastAddLiquidityTime + addLiquidityInterval);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            _autoSwapBack &&
            msg.sender != mocPair &&
            block.timestamp >= (lastAddLiquidityTime + addLiquidityInterval);
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return !isFeeExempt[from] && !isFeeExempt[to];
    }

    function _isTokenAccount(address _account) internal view returns (bool) {
        if (_balances[_account] > 0 || !_isHasMocd(_account)) {
            return true;
        }
        return false;
    }

    function isTokenAccount(address _account) external view returns (bool) {
        return _isTokenAccount(_account);
    }

    function _isHasMocd(address _account) internal view returns (bool) {
        return IMocDao(mocdAddress).isHasMocd(_account);
    }

    function setFeeExempts(address[] memory _addrs) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            isFeeExempt[_addrs[i]] = true;
        }
    }

    function setBlacklist(address _address, bool _value) external onlyOwner {
        blacklist[_address] = _value;
    }

    function setInswap(bool flag) external onlyOwner {
        inSwap = flag;
    }

    function setParam(
        uint256 _minMocAmount,
        uint256 _rebaseInterval,
        uint256 _addLiquidityInterval
    ) external onlyOwner {
        minMocAmount = _minMocAmount * 1e8;
        rebaseInterval = _rebaseInterval;
        addLiquidityInterval = _addLiquidityInterval;
    }

    function setAddress(address _mocdAddress, address _eaiAddress)
        external
        onlyOwner
    {
        mocdAddress = _mocdAddress;
        eaiAddress = _eaiAddress;
    }

    function setReceiver(
        address _marketingReceiver,
        address _backExiReceiver,
        address _liqExiReceiver,
        address _liqMocReceiver,
        address _backEaiReceiver
    ) external onlyOwner {
        marketingReceiver = _marketingReceiver;
        backExiReceiver = _backExiReceiver;
        liqExiReceiver = _liqExiReceiver;
        liqMocReceiver = _liqMocReceiver;
        backEaiReceiver = _backEaiReceiver;
    }
}