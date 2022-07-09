/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter {
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

interface IPancakeSwapFactory {
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

enum TokenClass {
    basicToken,
    reflectionToken,
    babyToken,
    apyToken
}

abstract contract BaseToken {
    event TokenCreated(
        address indexed owner,
        address indexed token,
        TokenClass tokenClass,
        uint256 version
    );
}

contract RAT2COIN is ERC20Detailed, Ownable, BaseToken {

    using SafeMath for uint256;

    mapping(address => uint256) _rBalance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;

    uint256 public buyFee;
    uint256 public sellFee;
    uint256 public liquidityShare;
    uint256 public marketingShare;
    uint256 public burnShare;
    uint256 public totalBuyVolume = 0;
    uint256 public totalSellVolume = 0;

    bool public walletToWalletTransferWithoutFee;

    address public marketingWallet;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    IPancakeSwapRouter public router;
    address public pair;
    IPancakeSwapPair public pairContract;

    uint256 private immutable initialSupply;
    uint256 private immutable rSupply;
    uint256 private constant MAX = type(uint256).max;
    uint256 private _totalSupply;
    uint256 private timeRebase = 10 minutes;

    bool public swapEnabled = true;
    bool private inSwap = false;
    uint256 private swapThreshold;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public autoRebase;
    uint256 public rebaseRate;
    uint256 public lastRebasedTime;
    uint256 public rebase_count;
    uint256 private rate;

    event AutoRebaseStatusUptaded(bool enabled);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludedFromMaxTransactionLimit(
        address indexed account,
        bool isExcluded
    );
    event ExcludedFromMaxWalletLimit(address indexed account, bool isExcluded);
    event FeesUpdated(uint256 buyFee, uint256 sellFee);
    event FeeSharesUpdated(
        uint256 liquidityShare,
        uint256 marketingShare,
        uint256 burnShare
    );

    event MarketingWalletChanged(address marketingWallet);
    event MaxWalletLimitRateChanged(uint256 maxWalletLimitRate);
    event MaxWalletLimitStateChanged(bool maxWalletLimit);
    event MaxTransactionLimitRatesChanged(
        uint256 maxTransferRateBuy,
        uint256 maxTransferRateSell
    );

    event MaxTransactionLimitStateChanged(bool maxTransactionLimit);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    constructor() payable ERC20Detailed("RATSCOIN v2", "RAT2", 18)
    {
        buyFee = 5;
        sellFee = 5;
        burnShare = 25;
        liquidityShare = 25;
        marketingShare = 50;
        marketingWallet = 0xbe19396A94F429FAf41Ff4F79969DEC7F128784b;
        walletToWalletTransferWithoutFee = true;
        maxTransactionAvailable = true;
        maxTransactionLimitEnabled = true;
        maxTransactionRateBuy = 15; // 2%
        maxTransactionRateSell = 2; // 0.2%
        maxWalletAvailable = true;
        maxWalletLimitEnabled = true;
        maxWalletLimitRate = 20;

        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 0x10ED43C718714eb63d5aA57B78B54704E256024E pcs2 // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 test
        
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        pairContract = IPancakeSwapPair(pair);
        _allowances[address(this)][address(router)] = MAX;

        initialSupply = 10000000 * (10**18);
        _totalSupply = initialSupply;

        rSupply = MAX - (MAX % initialSupply);
        rate = rSupply / _totalSupply;

        rebaseRate = 1520;
        autoRebase = false;
        lastRebasedTime = block.timestamp;

        _isExcludedFromMaxTxLimit[owner()] = true;
        _isExcludedFromMaxTxLimit[address(0)] = true;
        _isExcludedFromMaxTxLimit[address(this)] = true;
        _isExcludedFromMaxTxLimit[DEAD] = true;

        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[DEAD] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        swapThreshold = rSupply / 5000;
        _rBalance[owner()] = rSupply;
        emit Transfer(address(0x0), owner(), _totalSupply);
        emit TokenCreated(owner(), address(this), TokenClass.apyToken, 1);
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    //=======APY=======//
    function startAPY() external onlyOwner {
        autoRebase = true;
        lastRebasedTime = block.timestamp;
        emit AutoRebaseStatusUptaded(true);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            autoRebase = _flag;
            lastRebasedTime = block.timestamp;
        } else {
            autoRebase = _flag;
        }
        emit AutoRebaseStatusUptaded(_flag);
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebase &&
            msg.sender != pair &&
            !inSwap &&
            block.timestamp >= (lastRebasedTime + timeRebase);
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 times = (block.timestamp - lastRebasedTime) / timeRebase;

        for (uint256 i = 0; i < times; i++) {
            _totalSupply =
                (_totalSupply * (10_000_000 + rebaseRate)) /
                10_000_000;
            rebase_count++;
        }

        rate = rSupply / _totalSupply;
        lastRebasedTime = lastRebasedTime + (times * timeRebase);

        pairContract.sync();

        emit LogRebase(rebase_count, _totalSupply);
    }

    //=======BEP20=======//
    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue - subtractedValue;
        }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowances[msg.sender][spender] =
            _allowances[msg.sender][spender] +
            addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account] / rate;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (_allowances[from][msg.sender] != MAX) {
            _allowances[from][msg.sender] =
                _allowances[from][msg.sender] -
                value;
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 rAmount = amount * rate;
        _rBalance[from] = _rBalance[from] - rAmount;
        _rBalance[to] = _rBalance[to] + rAmount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (totalBuyVolume > 0 && totalSellVolume > 0 && totalSellVolume > totalBuyVolume) {
            if (totalSellVolume >= totalBuyVolume.mul(120).div(100)) {
                sellFee = 20;
            } else if (totalSellVolume >= totalBuyVolume.mul(110).div(100)) {
                sellFee = 15;
            } else if (totalSellVolume > totalBuyVolume.mul(105).div(100)) {
                sellFee = 10;
            } else {
                sellFee = 5;
            }
        }

        if (maxWalletLimitEnabled) {
            if (
                _isExcludedFromMaxWalletLimit[sender] == false &&
                _isExcludedFromMaxWalletLimit[recipient] == false &&
                recipient != pair
            ) {
                uint256 balance = balanceOf(recipient);
                require(
                    balance + amount <= maxWalletAmount(),
                    "MaxWallet: Transfer amount exceeds the maxWalletAmount"
                );
            }
        }

        if (maxTransactionLimitEnabled) {
            if (
                _isExcludedFromMaxTxLimit[sender] == false &&
                _isExcludedFromMaxTxLimit[recipient] == false
            ) {
                if (sender == pair) {
                    require(
                        amount <= maxTransferAmountBuy(),
                        "AntiWhale: Transfer amount exceeds the maxTransferAmount"
                    );
                } else {
                    require(
                        amount <= maxTransferAmountSell(),
                        "AntiWhale: Transfer amount exceeds the maxTransferAmount"
                    );
                }
            }
        }

        uint256 rAmount = amount * rate;

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        _rBalance[sender] = _rBalance[sender] - rAmount;

        bool wtwWoFee = walletToWalletTransferWithoutFee &&
            sender != pair &&
            recipient != pair;
        uint256 amountReceived = (_isExcludedFromFees[sender] ||
            _isExcludedFromFees[recipient] ||
            wtwWoFee)
            ? rAmount
            : takeFee(sender, rAmount, amount, (recipient == pair));
        _rBalance[recipient] = _rBalance[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived / rate);
        return true;
    }

    function takeFee(
        address sender,
        uint256 rAmount,
        uint256 amount,
        bool isSell
    ) internal returns (uint256) {
        uint256 _finalFee;
        if (isSell) {
            _finalFee = sellFee;
            totalSellVolume = totalSellVolume + amount;
        } else {
            _finalFee = buyFee;
            totalBuyVolume = totalBuyVolume + amount;
        }

        uint256 feeAmount = (rAmount / 100) * _finalFee;

        _rBalance[address(this)] = _rBalance[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount / rate);

        return rAmount - feeAmount;
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account, bool excluded)
        external
        onlyOwner
    {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function updateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 25 && _sellFee <= 25, "Fees must be less than 25%");
        buyFee = _buyFee;
        sellFee = _sellFee;
        emit FeesUpdated(buyFee, sellFee);
    }

    function updateFeeShares(
        uint256 _marketingFeeShare,
        uint256 _liquidityFeeShare,
        uint256 _burnShare
    ) external onlyOwner {
        require(
            _marketingFeeShare + _liquidityFeeShare == 100,
            "Fee shares must add up to 100"
        );
        marketingShare = _marketingFeeShare;
        liquidityShare = _liquidityFeeShare;
        burnShare = _burnShare;
        emit FeeSharesUpdated(marketingShare, liquidityShare, burnShare);
    }

    function enableWalletToWalletTransferWithoutFee(bool enable)
        external
        onlyOwner
    {
        require(
            walletToWalletTransferWithoutFee != enable,
            "Wallet to wallet transfer without fee is already set to that value"
        );
        walletToWalletTransferWithoutFee = enable;
    }

    function changeMarketingWallet(address _marketingWallet)
        external
        onlyOwner
    {
        require(
            _marketingWallet != marketingWallet,
            "Marketing wallet is already that address"
        );
        require(
            !isContract(_marketingWallet),
            "Marketing wallet cannot be a contract"
        );
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    //=======Swap=======//
    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _rBalance[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));

        uint256 liquidityTokens = (contractTokenBalance * liquidityShare) / 100;
        uint256 burnTokens = (contractTokenBalance * burnShare) / 100;
        uint256 marketingTokens = (contractTokenBalance * marketingShare) / 100;

        if (burnTokens > 0) {
            _basicTransfer(address(this), DEAD, burnTokens);
        }

        if (marketingTokens > 0) {
            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                marketingTokens,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance - initialBalance;

            sendBNB(payable(marketingWallet), newBalance);
        }

        if (liquidityTokens > 0) {
            uint256 half = liquidityTokens / 2;
            uint256 otherHalf = liquidityTokens - half;

            uint256 initialBalance = address(this).balance;

            address[] memory path2 = new address[](2);
            path2[0] = address(this);
            path2[1] = router.WETH();

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                half,
                0, // accept any amount of ETH
                path2,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance - initialBalance;

            router.addLiquidityETH{value: newBalance}(
                address(this),
                otherHalf,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                DEAD,
                block.timestamp
            );
        }
    }

    function setSwapBackSettings(bool _enabled, uint256 _percentage_base100000)
        external
        onlyOwner
    {
        require(
            _percentage_base100000 >= 1,
            "Swap back percentage must be more than 0.001%"
        );
        swapEnabled = _enabled;
        swapThreshold = (rSupply / 100000) * _percentage_base100000;
    }

    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold / rate;
    }

    //=======MaxWallet=======//
    mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    bool public maxWalletAvailable;
    bool public maxWalletLimitEnabled;
    uint256 private maxWalletLimitRate;

    modifier _maxWalletAvailable() {
        require(maxWalletAvailable, "Max wallet limit is not available");
        _;
    }

    function setEnableMaxWalletLimit(bool enable)
        external
        onlyOwner
        _maxWalletAvailable
    {
        require(
            enable != maxWalletLimitEnabled,
            "Max wallet limit is already that state"
        );
        maxWalletLimitEnabled = enable;
        emit MaxWalletLimitStateChanged(maxWalletLimitEnabled);
    }

    function isExcludedFromMaxWalletLimit(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxWalletLimit[account];
    }

    function maxWalletAmount() public view returns (uint256) {
        return (totalSupply() * maxWalletLimitRate) / 1000;
    }

    function setMaxWalletRate_Denominator1000(uint256 _val)
        external
        onlyOwner
        _maxWalletAvailable
    {
        require(_val >= 10, "Max wallet percentage cannot be lower than 1%");
        maxWalletLimitRate = _val;
        emit MaxWalletLimitRateChanged(maxWalletLimitRate);
    }

    function setExcludeFromMaxWallet(address account, bool exclude)
        external
        onlyOwner
        _maxWalletAvailable
    {
        require(
            _isExcludedFromMaxWalletLimit[account] != exclude,
            "Account is already set to that state"
        );
        _isExcludedFromMaxWalletLimit[account] = exclude;
        emit ExcludedFromMaxWalletLimit(account, exclude);
    }

    //=======MaxTransaction=======//
    mapping(address => bool) private _isExcludedFromMaxTxLimit;
    bool public maxTransactionAvailable;
    bool public maxTransactionLimitEnabled;
    uint256 private maxTransactionRateBuy;
    uint256 private maxTransactionRateSell;

    modifier _maxTransactionAvailable() {
        require(
            maxTransactionAvailable,
            "Max transaction limit is not available"
        );
        _;
    }

    function setEnableMaxTransactionLimit(bool enable)
        external
        onlyOwner
        _maxTransactionAvailable
    {
        require(
            enable != maxTransactionLimitEnabled,
            "Max transaction limit is already that state"
        );
        maxTransactionLimitEnabled = enable;
        emit MaxTransactionLimitStateChanged(maxTransactionLimitEnabled);
    }

    function isExcludedFromMaxTransaction(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxTxLimit[account];
    }

    function maxTransferAmountBuy() public view returns (uint256) {
        return (totalSupply() * maxTransactionRateBuy) / 1000;
    }

    function maxTransferAmountSell() public view returns (uint256) {
        return (totalSupply() * maxTransactionRateSell) / 1000;
    }

    function setMaxTransactionRates_Denominator1000(
        uint256 _maxTransactionRateBuy,
        uint256 _maxTransactionRateSell
    ) external onlyOwner _maxTransactionAvailable {
        require(
            _maxTransactionRateSell >= 1 && _maxTransactionRateBuy >= 1,
            "Max Transaction limit cannot be lower than 0.1% of total supply"
        );
        maxTransactionRateBuy = _maxTransactionRateBuy;
        maxTransactionRateSell = _maxTransactionRateSell;
        emit MaxTransactionLimitRatesChanged(
            maxTransactionRateBuy,
            maxTransactionRateSell
        );
    }

    function setExcludeFromMaxTransactionLimit(address account, bool exclude)
        external
        onlyOwner
        _maxTransactionAvailable
    {
        require(
            _isExcludedFromMaxTxLimit[account] != exclude,
            "Account is already set to that state"
        );
        _isExcludedFromMaxTxLimit[account] = exclude;
        emit ExcludedFromMaxTransactionLimit(account, exclude);
    }
}