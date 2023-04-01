/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
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

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

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

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
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

interface Inv {
    function getInviter(address user) external view returns (address);
}

contract Recv {
    IERC20 public token;
    IERC20 public usdt;

    constructor(IERC20 _token, IERC20 _usdt) {
        token = _token;
        usdt = _usdt;
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token), usdtBalance);
        }
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance > 0) {
            token.transfer(address(token), tokenBalance);
        }
    }
}

contract HMTToken is IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private constant MAX = ~uint256(0);

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) _isDividendExempt;

    address public projectAddress;
    IERC20 public usdt;

    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 private tProjectFeeTotal;
    uint256 private tReflowFeeTotal;

    Inv public inv;
    Recv public recv;
    address public pool;

    string private _name = "HMT";
    string private _symbol = "HMT";
    uint8 private _decimals = 18;

    uint256 private _tTotal = 5000 * 10 ** 4 * 10 ** _decimals;

    uint256 buyFee = 600;
    uint256 sellFee = 600;
    uint256 transferFee = 600;

    uint256 projectFee = 180;
    uint256 lianchuangFee = 50;
    uint256 reflowFee = 50;
    uint256 lpRewardFee = 120;
    uint256 burnFee = 100;
    uint256 inviteFee = 100;
    uint256 public feeDenominator = 10000;

    uint256 public lianchuangDividend;
    address[] lianchuangs;
    mapping(address => uint256) lianchuangIndexes;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    uint256 currentIndex;
    mapping(address => bool) private _updated;

    uint256 public offset = 0 * 3600;
    bool public isProtection = false;
    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;

    uint256 public lastPrice;

    bool public limitBuy;

    bool public limitSell;

    uint256 public startTradeBlock;

    uint256 public _releaseLPStartTime;

    uint256 public minTokenNumberToSell = 1 * 10 ** 18;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;

    struct UserInfo {
        bool isLianChuang;
        uint256 lockLPAmount;
        uint256 lpAmount;
        uint256 releaseTokenAmount;
        uint256 lpDividendAmount;
        uint256 averagePrice;
        uint256 lastRewardTime;
    }

    event ResetProtection(
        uint256 indexed today,
        uint256 indexed time,
        uint256 price
    );

    constructor(Inv _inv) {
        projectAddress = msg.sender;
        inv = _inv;

        // usdt = IERC20(0x55d398326f99059fF775485246999027B3197955); //bsc
        usdt = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); //bsctest

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(usdt));

        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(_uniswapV2Router), MAX);
        usdt.approve(address(_uniswapV2Router), MAX);

        recv = new Recv(IERC20(this), usdt);

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(recv)] = true;

        _isDividendExempt[address(this)] = true;
        _isDividendExempt[address(recv)] = true;

        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    // view function
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isDividendExempt(address account) public view returns (bool) {
        return _isDividendExempt[account];
    }

    function shareholdersCount() public view returns (uint256) {
        return shareholders.length;
    }

    function excludeDividend(
        address[] calldata accounts,
        bool excluded
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isDividendExempt[accounts[i]] = excluded;
            if (excluded) {
                removeShareholder(accounts[i]);
            }
        }
    }

    function setPool(address _pool) public onlyOwner {
        pool = _pool;
        _isExcludedFromFee[_pool] = true;
    }

    function setReleaseLPStartTime(
        uint256 releaseLPStartTime
    ) public onlyOwner {
        _releaseLPStartTime = releaseLPStartTime;
    }

    function setFromFees(
        address[] memory accounts,
        bool[] memory flags
    ) public onlyOwner {
        require(accounts.length == flags.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = flags[i];
        }
    }

    function setMinTokenNumberToSell(uint256 amount) public onlyOwner {
        minTokenNumberToSell = amount;
    }

    function setProjectAddress(address addr) public onlyOwner {
        projectAddress = addr;
        _isExcludedFromFee[projectAddress] = true;
    }

    function rescueToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function setProtection(bool _isProtection) public onlyOwner {
        isProtection = _isProtection;
    }

    function setOffset(uint256 timestamp) public onlyOwner {
        offset = timestamp;
    }

    function setLimitBuy(bool _limitBuy) public onlyOwner {
        limitBuy = _limitBuy;
    }

    function setLimitSell(bool _limitSell) public onlyOwner {
        limitSell = _limitSell;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _releaseLPStartTime = block.timestamp;
        limitBuy = true;
        limitSell = true;
    }

    function initLPLockAmounts(
        address[] memory accounts,
        uint256 lpAmount
    ) public onlyOwner {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len; ) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmount;
            userInfo.lockLPAmount = lpAmount;
            userInfo.releaseTokenAmount = lianchuangDividend;

            addlianchuang(accounts[i]);
            _userInfo[accounts[i]].isLianChuang = true;
            unchecked {
                ++i;
            }
        }
    }

    function cancelLPLockAmounts(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len; ) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = 0;
            userInfo.lockLPAmount = 0;

            quitlianchuang(accounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function addlianchuang(address lianchuang) internal {
        lianchuangIndexes[lianchuang] = lianchuangs.length;
        lianchuangs.push(lianchuang);
    }

    function quitlianchuang(address lianchuang) private {
        removelianchuang(lianchuang);
        _userInfo[lianchuang].isLianChuang = false;
    }

    function removelianchuang(address lianchuang) internal {
        lianchuangs[lianchuangIndexes[lianchuang]] = lianchuangs[
            lianchuangs.length - 1
        ];
        lianchuangIndexes[
            lianchuangs[lianchuangs.length - 1]
        ] = lianchuangIndexes[lianchuang];
        lianchuangs.pop();
    }

    function externalMethods(
        address account,
        uint256 unlockLPAmount,
        uint256 releaseTokenAmount,
        uint256 lpDividendAmount
    ) public {
        require(pool == msg.sender, "rq DividendPool");
        UserInfo storage user = _userInfo[account];
        user.lockLPAmount -= unlockLPAmount;
        user.lastRewardTime = block.timestamp;
        user.releaseTokenAmount += releaseTokenAmount;
        user.lpDividendAmount -= lpDividendAmount;
    }

    function getUserInfo(
        address account
    )
        public
        view
        returns (
            uint256 lpAmount,
            uint256 lpLockAmount,
            uint256 releaseLPAmount,
            uint256 lpBalance,
            uint256 averagePrice,
            uint256 lastRewardTime,
            uint256 releaseTokenAmount,
            bool isLianChuang,
            uint256 lpDividendAmount
        )
    {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;

        lpLockAmount = userInfo.lockLPAmount;
        if (_releaseLPStartTime > 0) {
            uint256 releaseTime = userInfo.lastRewardTime > _releaseLPStartTime
                ? userInfo.lastRewardTime
                : _releaseLPStartTime;
            uint256 times = (block.timestamp - releaseTime) / INTERVAL;
            releaseLPAmount = recursion(lpLockAmount, times);

            if (releaseLPAmount > lpLockAmount) {
                releaseLPAmount = lpLockAmount;
            }
        }
        lpBalance = IERC20(uniswapV2Pair).balanceOf(account);

        averagePrice = userInfo.averagePrice;

        lastRewardTime = userInfo.lastRewardTime;

        releaseTokenAmount = userInfo.releaseTokenAmount;

        isLianChuang = userInfo.isLianChuang;

        lpDividendAmount = userInfo.lpDividendAmount;
    }

    function recursion(uint256 a, uint256 b) private pure returns (uint256) {
        uint256 totalRewards;

        for (uint256 i = 0; i < b; i++) {
            totalRewards = a.div(100).add(totalRewards);

            a = a.mul(99).div(100);
        }

        return totalRewards;
    }

    function resetProtection(
        uint256 timestamp,
        uint256 price
    ) public onlyOwner {
        if (timestamp == 0) {
            timestamp = block.timestamp;
        }

        _protectionT = timestamp;
        if (price == 0) {
            price = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(
                _tOwned[uniswapV2Pair]
            );
        }
        _protectionP = price;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    // private function
    function _resetProtection() private {
        if (isProtection) {
            if (block.timestamp.sub(_protectionT) >= INTERVAL) {
                uint256 current = IERC20(usdt)
                    .balanceOf(uniswapV2Pair)
                    .mul(10 ** 18)
                    .div(_tOwned[uniswapV2Pair]);
                if (
                    lastPrice == 0 ||
                    (current > lastPrice.mul(80).div(100) &&
                        current < lastPrice.mul(120).div(100))
                ) {
                    uint256 today = block.timestamp -
                        ((block.timestamp + offset) % 1 days);
                    _protectionT = today;
                    _protectionP = current;
                    emit ResetProtection(today, block.timestamp, _protectionP);
                }
            } else {
                lastPrice = IERC20(usdt)
                    .balanceOf(uniswapV2Pair)
                    .mul(10 ** 18)
                    .div(_tOwned[uniswapV2Pair]);
            }
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");
        _tTotal = _tTotal.add(amount);
        _tOwned[account] = _tOwned[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _resetProtection();

        uint256 contractTokenBalance = _tOwned[address(this)];
        bool canSwap = contractTokenBalance >= minTokenNumberToSell;

        if (canSwap && !inSwapAndLiquify && from != uniswapV2Pair) {
            inSwapAndLiquify = true;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(usdt);
            uniswapV2Router
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tProjectFeeTotal,
                    0, // accept any amount of ETH
                    path,
                    projectAddress,
                    block.timestamp
                );

            tProjectFeeTotal = 0;

            swapAndLiquify(tReflowFeeTotal);
            tReflowFeeTotal = 0;

            inSwapAndLiquify = false;
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        uint256 addLPLiquidity;
        if (to == uniswapV2Pair) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                UserInfo storage userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;

                if (!_isDividendExempt[from]) {
                    addShareholder(from);
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == uniswapV2Pair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                (
                    uint256 lpAmount,
                    uint256 lpLockAmount,
                    uint256 releaseAmount,
                    uint256 lpBalance,
                    ,
                    ,
                    ,
                    ,

                ) = getUserInfo(to);
                if (lpLockAmount > 0) {
                    require(
                        lpBalance + releaseAmount >= lpLockAmount,
                        "rq Lock"
                    );
                }
                _userInfo[to].lpAmount = lpAmount > removeLPLiquidity
                    ? _userInfo[to].lpAmount - removeLPLiquidity
                    : 0;
            }
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(0 < startTradeBlock, "!T");
            if (addLPLiquidity > 0) {
                takeFee = false;
            }
            if (removeLPLiquidity > 0) {
                takeFee = false;
            }
        }

        if (takeFee && block.number < startTradeBlock + 3) {
            _killTransfer(from, to, amount);
            return;
        }

        _tokenTransfer(from, to, amount, takeFee);

    }

    function process(uint256 feeAmount) private {
        uint256 shareholderCount = shareholders.length;
        uint256 nowbanance = feeAmount;

        if (shareholderCount > 0) {
            for (uint256 i = 0; i < shareholderCount; i++) {
                if (currentIndex >= shareholderCount) {
                    currentIndex = 0;
                    return;
                }

                if (
                    IERC20(uniswapV2Pair).balanceOf(
                        shareholders[currentIndex]
                    ) > 0
                ) {
                    uint256 amount = nowbanance
                        .mul(
                            IERC20(uniswapV2Pair).balanceOf(
                                shareholders[currentIndex]
                            )
                        )
                        .div(IERC20(uniswapV2Pair).totalSupply());

                    _userInfo[shareholders[currentIndex]]
                        .lpDividendAmount += amount;
                    currentIndex++;
                } else {
                    removeShareholder(shareholders[currentIndex]);
                    shareholderCount--;
                }
            }
        }
    }

    function addShareholder(address shareholder) private {
        if (!_updated[shareholder]) {
            shareholderIndexes[shareholder] = shareholders.length;
            shareholders.push(shareholder);
            _updated[shareholder] = true;
        }
    }

    function removeShareholder(address shareholder) private {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
        _updated[shareholder] = false;
    }


    function _isAddLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = IUniswapV2Pair(uniswapV2Pair).totalSupply();
        address feeTo = IUniswapV2Factory(uniswapV2Router.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = IUniswapV2Pair(uniswapV2Pair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply *
                        (rootK - rootKLast) *
                        8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
    {
        (uint r0, uint256 r1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();

        address tokenOther = address(usdt);
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }

        balanceOther = IERC20(tokenOther).balanceOf(uniswapV2Pair);
    }

    function _isRemoveLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity =
                (amount * IUniswapV2Pair(uniswapV2Pair).totalSupply() + 1) /
                (balanceOf(uniswapV2Pair) - amount - 1);
        }
    }

    function _killTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender] - tAmount;
        uint256 feeAmount = (tAmount * 99) / 100;
        _takeTransfer(sender, deadAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _tOwned[to] = _tOwned[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);

        uint256 taxFee = 0;
        uint256 extraTaxFee = 0;
        if (takeFee) {
            uint256 currentPrice = IERC20(usdt)
                .balanceOf(uniswapV2Pair)
                .mul(10 ** 18)
                .div(_tOwned[uniswapV2Pair]);

            if (sender == uniswapV2Pair) {
                // buy
                taxFee = buyFee;

                if (limitBuy) {
                    require(amount <= 20 * 10 ** _decimals, "limit buy");
                }

                UserInfo storage u = _userInfo[recipient];
                if (u.averagePrice == 0) {
                    u.averagePrice = currentPrice;
                } else {
                    u.averagePrice = currentPrice.add(u.averagePrice).div(2);
                }
            } else if (recipient == uniswapV2Pair) {
                // sell
                taxFee = sellFee;

                if (limitSell) {
                    if (
                        amount >= 20 * 10 ** _decimals &&
                        amount < 50 * 10 ** _decimals
                    ) {
                        extraTaxFee = 500;
                    } else if (
                        amount >= 50 * 10 ** _decimals &&
                        amount < 100 * 10 ** _decimals
                    ) {
                        extraTaxFee = 1000;
                    } else if (amount >= 100 * 10 ** _decimals) {
                        extraTaxFee = 1500;
                    }
                }

                UserInfo storage u = _userInfo[sender];
                if (u.averagePrice == 0) {
                    u.averagePrice = currentPrice;
                } else {
                    if (currentPrice > u.averagePrice) {
                        uint256 tAmount = currentPrice
                            .sub(u.averagePrice)
                            .mul(amount)
                            .div(10 ** _decimals)
                            .mul(500)
                            .div(feeDenominator);
                        _takeTransfer(sender, projectAddress, tAmount.div(5));
                        _takeTransfer(sender, pool, tAmount.mul(4).div(5));
                    }

                    u.averagePrice = currentPrice.add(u.averagePrice).div(2);
                }

                if (isProtection) {
                    if (currentPrice < _protectionP) {
                        uint256 times = _protectionP
                            .sub(currentPrice)
                            .mul(100)
                            .div(_protectionP)
                            .div(10);
                        times = SafeMath.min(times, 5);
                        if (times * 500 + 700 > extraTaxFee) {
                            extraTaxFee = times * 500 + 700;
                        }
                    }
                }
            } else {
                taxFee = transferFee;
            }

            if (sender == uniswapV2Pair || recipient == uniswapV2Pair) {
                // project
                uint256 fee = amount.mul(projectFee + extraTaxFee).div(
                    feeDenominator
                );
                _takeTransfer(sender, address(this), fee);
                tProjectFeeTotal += fee;

                // lianchuang
                fee = amount.mul(lianchuangFee).div(feeDenominator);
                if (lianchuangs.length > 0) {
                    lianchuangDividend = fee.div(lianchuangs.length).add(
                        lianchuangDividend
                    );
                } else {
                    lianchuangDividend = fee.add(lianchuangDividend);
                }
                _takeTransfer(sender, pool, fee);

                //burn
                fee = amount.mul(burnFee).div(feeDenominator);
                _takeTransfer(sender, deadAddress, fee);

                //lp reward
                fee = amount.mul(lpRewardFee).div(feeDenominator);
                _takeTransfer(sender, pool, fee);
                process(fee);

                //reflow
                fee = amount.mul(reflowFee).div(feeDenominator);
                _takeTransfer(sender, address(this), fee);
                tReflowFeeTotal += fee;

                //invite
                address cur;
                if (sender == uniswapV2Pair) {
                    cur = recipient;
                } else if (recipient == uniswapV2Pair) {
                    cur = sender;
                }
                address parent = inv.getInviter(cur);

                fee = amount.mul(inviteFee).div(feeDenominator);
                _takeTransfer(sender, parent, fee);
            } else {
                // project
                uint256 fee = amount.mul(transferFee).div(feeDenominator);
                _takeTransfer(sender, address(this), fee);
                tProjectFeeTotal += fee;
            }
        }

        uint256 recipientAmount = amount
            .mul(feeDenominator - taxFee - extraTaxFee)
            .div(feeDenominator);
        _takeTransfer(sender, recipient, recipientAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");

        uint256 initialUsdt = usdt.balanceOf(address(this));
        swapTokensForUSDT(half);
        uint256 afterUsdt = usdt.balanceOf(address(this));
        uint256 addUsdt = afterUsdt.sub(initialUsdt);

        addLiquidityUSDT(otherHalf, addUsdt);
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(recv),
            block.timestamp
        );
        recv.withdraw();
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 uAmount) private {
        // approve token transfer to cover all possible scenarios
        uniswapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            uAmount,
            0,
            0,
            projectAddress,
            block.timestamp
        );
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

contract Token is HMTToken {
    constructor()
        HMTToken(
            //Inv
            Inv(0x411fbd91436b840a4E8274C39B4c07D2c313d26f)
        )
    {}
}