/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface HeroProxyFactory {
    function getRelations(address user) external returns (address[] memory);
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface InterfaceLP {
    function sync() external;
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) {
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface DividendTracker {
    function setReward(uint256 amount) external;
}

//
contract LgtToken is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address public constant usdtToken =
        0x55d398326f99059fF775485246999027B3197955;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    IUniswapV2Router02 public uniswapV2Router;
    address public pair;

    bool public autoRebase = false;

    address public heroTokenProxy;
    uint256 constant baseFee = 1000;
    uint256 constant baseTime = 1657382400;

    mapping(uint256 => address) public lastHourBuyMaxAccounts;
    mapping(uint256 => mapping(address => uint256)) public accountBuyOfHour;
    mapping(uint256 => uint256) public maxAmountBuyOfHour;
    mapping(uint256 => uint256) public hourTotalFee;

    uint256 public rewardYield = 1645833;
    uint256 public rewardYieldDenominator = 10000000000;

    address[10] public marketWalletAddress;
    uint256[10] public buyMarketRates;

    uint256 public liquidityFee = 40;
    uint256 public rewardLastHourRate = 10;
    uint256 public deadFundRate = 25;
    uint256 public feeFundRate = 50;
    uint256 public superRewardRate = 50;
    uint256 public genesistRewardRate = 25;
    address public feeFundWalletAddress;

    uint256 public lastDayTokenPrice;
    mapping(uint256 => uint256[]) public tokenPriceArray;
    uint256 public updatePriceInterval = 1800;
    uint256 public lastUpdateTime;
    mapping(uint256 => uint256) public historyTokenPrice;

    uint256[4] public priceDownPercentages;
    uint256[4] public priceDownRates;

    uint256[] public circulationSubSupply;
    uint256[] public circulationSubRates;

    uint256 public gasGenesisForProcessing;
    uint256 public gasSuperForProcessing;

    address public genesisDividendTracker;
    address public superDividendTracker;

    bool public enablePriceSwitch;

    uint256 public accumulativeGenesisDividend;
    uint256 public accumulativeSuperDividend;
    uint256 public accumulativeDaoDividend;

    uint256 public rebaseFrequency = 300;
    uint256 public lastRebaseTime;

    uint256 public rewardMinAmount;

    mapping(address => bool) _isFeeExempt;
    address[] public _markerPairs;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);

    uint256 public TOTAL_GONS;
    uint256 public constant MAX_SUPPLY = ~uint128(0);

    uint256 public feeDenominator = 1000;

    bool inSwap;
    uint256 public pairBalance;
    uint256 public lastRebasedTime;

    uint256 public startTradingTime;
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => bool) public excludedTrackers;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    address public liquidityAddress;
    bool public swapEnabled = true;
    uint256 private swapAmountMin = 1e18;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    constructor(uint256 _initSupply, address _initAddress)
        ERC20Detailed("Legend Front", "LGT", uint8(DECIMALS))
    {
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            usdtToken
        );

        setAutomatedMarketMakerPair(pair, true);

        _totalSupply = _initSupply * 10**DECIMALS;

        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % _totalSupply);
        _gonBalances[_initAddress] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        autoRebase = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[_initAddress] = true;
        _isFeeExempt[msg.sender] = true;

        marketWalletAddress = [
            0xfB4e8D7b8B63c5ADcff5a4382aeE50641427992e,
            0xCa6a7808A8A5dC7caB4Bd0EF2E22b286238a0eAE,
            0x2C2b3479572e9be4E406F1C791C5fCcea93d8b30,
            0xc23dbae74Ef5F636c201D73001acC2024445f554,
            0x003b1Cb563c95e3857e3C7Da302AA41096Fa7737,
            0x9da37F2CB153cE14fce31d80d6db229D82121AD6,
            0x98Ac494cbBb3Dbd41E3b8E5174cDaBF309bfEBAF,
            0x8bEa991a4542e9c3009Cd8A7B1D57d302B9DF57B,
            0xa65C849a12547e07FDDdD95232076F0C37Ad5c0F,
            0xF378276B2644AEa4e7d16F9CFD3e03611A1e3bc5
        ];
        buyMarketRates = [40, 20, 5, 5, 5, 5, 5, 5, 5, 5];

        priceDownPercentages = [50, 30, 20, 10];
        priceDownRates = [200, 100, 50, 20];

        circulationSubSupply = [
            4000000000000000000000000000,
            3000000000000000000000000000,
            2000000000000000000000000000
        ];

        circulationSubRates = [30, 20, 10];

        feeFundWalletAddress = 0x2749ffe8b80b9F47D92EA9A2D70CEac59aceA3B9;
        heroTokenProxy = 0xC054290C313ed47ae42Df68220350c7529076604;

        automatedMarketMakerPairs[pair] = true;

        enablePriceSwitch = true;

        rewardMinAmount = 3000 * 1e18;
        lastRebaseTime = block.timestamp;

        liquidityAddress = 0xA7FC2b571Cd0b9b62B715685f0a74736B837d1E7;
        _isFeeExempt[liquidityAddress] = true;
        emit Transfer(address(0x0), _initAddress, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        if (who == pair) {
            return pairBalance;
        } else {
            return _gonBalances[who].div(_gonsPerFragment);
        }
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !inSwap &&
            block.timestamp >= (lastRebaseTime.add(rebaseFrequency));
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return !_isFeeExempt[from] && !_isFeeExempt[to];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
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

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        require(
            block.timestamp > startTradingTime || excludedAccount,
            "Trading not started"
        );
        if (canSwapLiquidity(sender)) {
            uint256 swapAmount = _gonBalances[address(this)].div(
                _gonsPerFragment
            );
            swapAndLiquify(swapAmount);
        }

        if (shouldRebase()) {
            _rebase();
        }
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (
            pair == recipient &&
            _isFeeExempt[sender] == false &&
            _isFeeExempt[recipient] == false
        ) {
            if (gonAmount >= _gonBalances[sender].div(1000).mul(999)) {
                gonAmount = _gonBalances[sender].div(1000).mul(999);
            }
        }
        if (sender == pair) {
            pairBalance = pairBalance.sub(amount);
            refreshBuyMaxAddress(sender, amount);
        } else {
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;

        if (recipient == pair) {
            pairBalance = pairBalance.add(
                gonAmountReceived.div(_gonsPerFragment)
            );
        } else {
            _gonBalances[recipient] = _gonBalances[recipient].add(
                gonAmountReceived
            );
        }
        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );

        return true;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapAmountMin = _amount;
    }

    function canSwapLiquidity(address sender) internal view returns (bool) {
        return
            sender != pair &&
            swapEnabled &&
            !inSwap &&
            _gonBalances[address(this)].div(_gonsPerFragment) > swapAmountMin;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function getCurrentDay() internal view returns (uint256) {
        uint256 intervalDay = block.timestamp.sub(baseTime).div(1 days);
        return baseTime.add(intervalDay * 1 days);
    }

    function getNextBuyRewardSeconds() public view returns (uint256) {
        uint256 timeHour = getTimeHour().add(1 hours);
        return timeHour.sub(block.timestamp);
    }

    function getLgtPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtToken;
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(1e18, path);
        return amounts[1];
    }

    function pushAndGetTokenPrice()
        private
        returns (uint256 currentDay, uint256 currentPrice)
    {
        if (pairBalance > 0) {
            currentDay = getCurrentDay();
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdtToken;
            uint256[] memory amounts = uniswapV2Router.getAmountsOut(
                1e18,
                path
            );
            currentPrice = amounts[1];
            uint256 currentTime = block.timestamp;
            if (currentTime.sub(lastUpdateTime) >= updatePriceInterval) {
                tokenPriceArray[currentDay].push(currentPrice);
                lastUpdateTime = currentTime;
            }
        }
    }

    function getCurrentHourByMaxCount() public view returns (address) {
        uint256 timeHour = getTimeHour();
        return lastHourBuyMaxAccounts[timeHour];
    }

    function getLastHourBuyMaxAccount() public view returns (address) {
        uint256 timeHour = getTimeHour().sub(1 hours);
        address account = lastHourBuyMaxAccounts[timeHour];
        return account == address(0) ? owner() : account;
    }

    function refreshBuyMaxAddress(address account, uint256 amount) internal {
        uint256 timeHour = getTimeHour();
        accountBuyOfHour[timeHour][account] += amount;
        uint256 totalBuyAmount = accountBuyOfHour[timeHour][account];
        uint256 buyMaxTemp = maxAmountBuyOfHour[timeHour];
        if (totalBuyAmount > buyMaxTemp) {
            maxAmountBuyOfHour[timeHour] = totalBuyAmount;
            lastHourBuyMaxAccounts[timeHour] = account;
        }
        emit HourBuyAmount(account, totalBuyAmount, timeHour);
    }

    function getTimeHour() public view returns (uint256) {
        uint256 intervalSeconds = block.timestamp.sub(baseTime);
        return intervalSeconds.div(1 hours).mul(1 hours).add(baseTime);
    }

    function getPriceDownRate(uint256 currentDay, uint256 currentPrice)
        internal
        returns (uint256)
    {
        if (currentPrice == 0) {
            return 0;
        }
        uint256 yesterDay = currentDay.sub(1 days);
        uint256 yesterDayPrice = historyTokenPrice[yesterDay];
        uint256 priceLength = tokenPriceArray[yesterDay].length;
        if (yesterDayPrice == 0 && priceLength == 0) {
            yesterDayPrice = lastDayTokenPrice;
        }
        if (yesterDayPrice == 0 && priceLength > 0) {
            uint256 sumPrice;
            for (uint256 i = 0; i < priceLength; i++) {
                sumPrice += tokenPriceArray[yesterDay][i];
            }
            yesterDayPrice = sumPrice.div(priceLength);
            lastDayTokenPrice = yesterDayPrice;
            historyTokenPrice[yesterDay] = yesterDayPrice;
        }
        if (currentPrice >= yesterDayPrice) {
            return 0;
        }
        uint256 downRate = yesterDayPrice.sub(currentPrice).mul(100).div(
            yesterDayPrice
        );
        for (uint256 i = 0; i < priceDownPercentages.length; i++) {
            if (priceDownPercentages[i] <= downRate) {
                return priceDownRates[i];
            }
        }
        return 0;
    }

    function getCompRewardDownRate() public view returns (uint256) {
        uint256 circulatingSupply = getCirculatingSupply();
        for (uint256 i = 0; i < circulationSubSupply.length; i++) {
            if (circulatingSupply >= circulationSubSupply[i]) {
                return circulationSubRates[i];
            }
        }
        return 100;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 totalFee;
        if (sender == pair) {
            uint256 MFee = sendMarketReward(sender, recipient, gonAmount);
            totalFee += MFee;
            uint256 LFee = sendAutoLiquidity(sender, gonAmount);
            totalFee += LFee;
            uint256 LHAFee = sendLastHourBuyMaxReward(sender, gonAmount);
            totalFee += LHAFee;
        } else {
            uint256 DFee = sendDeadFund(sender, gonAmount);
            totalFee += DFee;
            uint256 FFee = sendFeeFund(sender, gonAmount);
            totalFee += FFee;
            uint256 GFee = sendGenesisDividend(sender, gonAmount);
            totalFee += GFee;
            uint256 SFee = sendSuperDividend(sender, gonAmount);
            totalFee += SFee;
        }
        if (enablePriceSwitch) {
            (uint256 currentDay, uint256 currentPrice) = pushAndGetTokenPrice();
            uint256 downRate = getPriceDownRate(currentDay, currentPrice);
            if (recipient == pair) {
                uint256 DERFee = priceDownExtraFee(sender, gonAmount, downRate);
                totalFee += DERFee;
            }
        }
        return gonAmount.sub(totalFee);
    }

    function sendGenesisDividend(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.mul(genesistRewardRate).div(baseFee);
        if (feeAmount > 0) {
            _gonBalances[genesisDividendTracker] = _gonBalances[
                genesisDividendTracker
            ].add(feeAmount);
            uint256 _realAmount = feeAmount.div(_gonsPerFragment);
            emit Transfer(sender, address(genesisDividendTracker), _realAmount);
            accumulativeGenesisDividend += _realAmount;
            try
                DividendTracker(genesisDividendTracker).setReward(_realAmount)
            {} catch {}
        }
        return feeAmount;
    }

    function sendSuperDividend(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.mul(superRewardRate).div(baseFee);
        if (feeAmount > 0) {
            _gonBalances[superDividendTracker] = _gonBalances[
                superDividendTracker
            ].add(feeAmount);
            uint256 _realAmount = feeAmount.div(_gonsPerFragment);
            emit Transfer(sender, superDividendTracker, _realAmount);
            accumulativeSuperDividend += _realAmount;
            try
                DividendTracker(superDividendTracker).setReward(_realAmount)
            {} catch {}
        }
        return feeAmount;
    }

    function setSuperDividendTracker(address tracker) public onlyOwner {
        superDividendTracker = tracker;
    }

    function setGenesisDividendTracker(address tracker) public onlyOwner {
        genesisDividendTracker = tracker;
    }

    function setCirculationSubConfig(
        uint256[] memory supplys,
        uint256[] memory rates
    ) public onlyOwner {
        for (uint256 i = 0; i < supplys.length; i++) {
            circulationSubSupply[i] = supplys[i];
            circulationSubRates[i] = rates[i];
        }
    }

    function setPriceDownConfig(
        uint256[4] memory percentages,
        uint256[4] memory rates
    ) public onlyOwner {
        for (uint256 i = 0; i < percentages.length; i++) {
            priceDownPercentages[i] = percentages[i];
            priceDownRates[i] = rates[i];
        }
    }

    function setHeroTokenProxy(address newValue) public onlyOwner {
        heroTokenProxy = newValue;
    }

    function setFeeFundWalletAddress(address newValue) public onlyOwner {
        feeFundWalletAddress = newValue;
    }

    function setGenesistRewardRate(uint256 newValue) public onlyOwner {
        genesistRewardRate = newValue;
    }

    function setSuperRewardRate(uint256 newValue) public onlyOwner {
        superRewardRate = newValue;
    }

    function setFeeFundRate(uint256 newValue) public onlyOwner {
        feeFundRate = newValue;
    }

    function setDeadFundRate(uint256 newValue) public onlyOwner {
        deadFundRate = newValue;
    }

    function setRewardLastHourRate(uint256 newValue) public onlyOwner {
        rewardLastHourRate = newValue;
    }

    function setLiquidityFee(uint256 newValue) public onlyOwner {
        liquidityFee = newValue;
    }

    function setMarketWalletAddress(address[10] memory addrs) public onlyOwner {
        for (uint256 index = 0; index < addrs.length; index++) {
            marketWalletAddress[index] = addrs[index];
        }
    }

    function setBuyMarketRates(uint256[10] memory marketRates)
        public
        onlyOwner
    {
        for (uint256 index = 0; index < marketRates.length; index++) {
            buyMarketRates[index] = marketRates[index];
        }
    }

    function setLiquidityAddress(address newValue) public onlyOwner {
        liquidityAddress = newValue;
    }

    function sendMarketReward(
        address sender,
        address to,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 totalFee;
        address[] memory relations = HeroProxyFactory(heroTokenProxy)
            .getRelations(to);
        for (uint256 i = 0; i < relations.length; i++) {
            uint256 feeAmount = gonAmount.mul(buyMarketRates[i]).div(baseFee);
            address _leader = relations[i];
            if (
                _leader == address(0) ||
                _leader == address(1) ||
                balanceOf(_leader) < rewardMinAmount
            ) {
                _gonBalances[marketWalletAddress[i]] = _gonBalances[
                    marketWalletAddress[i]
                ].add(feeAmount);
                emit Transfer(
                    sender,
                    marketWalletAddress[i],
                    feeAmount.div(_gonsPerFragment)
                );
            } else {
                _gonBalances[_leader] = _gonBalances[_leader].add(feeAmount);
                emit Transfer(sender, _leader, feeAmount.div(_gonsPerFragment));
                emit MarketReward(
                    _leader,
                    sender,
                    i,
                    feeAmount.div(_gonsPerFragment)
                );
            }
            totalFee += feeAmount;
        }
        return totalFee;
    }

    function sendAutoLiquidity(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.mul(liquidityFee).div(baseFee);
        if (feeAmount > 0) {
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                feeAmount
            );
            uint256 lpAutoAmount = feeAmount.div(_gonsPerFragment);
            emit Transfer(sender, address(this), lpAutoAmount);
        }
        return feeAmount;
    }

    function sendLastHourBuyMaxReward(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.mul(rewardLastHourRate).div(baseFee);
        if (feeAmount > 0) {
            address account = getLastHourBuyMaxAccount();
            _gonBalances[account] = _gonBalances[account].add(feeAmount);
            uint256 timeHour = getTimeHour();
            uint256 _realAmount = feeAmount.div(_gonsPerFragment);
            hourTotalFee[timeHour] += _realAmount;
            emit Transfer(sender, account, _realAmount);
            emit MaxBuyReward(account, _realAmount);
        }
        return feeAmount;
    }

    function sendDeadFund(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.mul(deadFundRate).div(baseFee);
        if (feeAmount > 0) {
            _gonBalances[DEAD] = _gonBalances[DEAD].add(feeAmount);
            emit Transfer(sender, DEAD, feeAmount.div(_gonsPerFragment));
        }
        return feeAmount;
    }

    function sendFeeFund(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.mul(feeFundRate).div(baseFee);
        if (feeAmount > 0) {
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                feeAmount
            );
            uint256 swapAmount = feeAmount.div(_gonsPerFragment);
            accumulativeDaoDividend += swapAmount;
            if (swapEnabled) {
                emit Transfer(sender, address(this), swapAmount);
                swapToFeeFund(swapAmount);
            } else {
                _gonBalances[feeFundWalletAddress] = _gonBalances[
                    feeFundWalletAddress
                ].add(feeAmount);
                emit Transfer(sender, feeFundWalletAddress, swapAmount);
            }
        }
        return feeAmount;
    }

    function swapToFeeFund(uint256 tokenAmount) internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtToken;
        _allowedFragments[address(this)][
            address(uniswapV2Router)
        ] = _totalSupply;
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            feeFundWalletAddress,
            block.timestamp
        );
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _rebase() private {
        if (!inSwap) {
            uint256 deltaTime = block.timestamp.sub(lastRebaseTime);
            uint256 times = deltaTime.div(rebaseFrequency);
            uint256 epoch = times.mul(rebaseFrequency);
            uint256 downRate = getCompRewardDownRate();
            uint256 realRate = rewardYield.mul(downRate).div(100);
            for (uint256 i = 0; i < times; i++) {
                _totalSupply = _totalSupply
                    .mul((rewardYieldDenominator).add(realRate))
                    .div(rewardYieldDenominator);
            }
            _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
            lastRebaseTime = lastRebaseTime.add(times.mul(rebaseFrequency));
            emit LogRebase(epoch, _totalSupply);
        }
    }

    function setStartTradingTime(uint256 _time) public onlyOwner {
        startTradingTime = _time;
        if (_time > 0) {
            if (lastRebaseTime == 0) {
                lastRebaseTime = _time;
            }
        }
    }

    function setEnablePriceSwitch(bool value) public onlyOwner {
        enablePriceSwitch = value;
    }

    function priceDownExtraFee(
        address sender,
        uint256 amount,
        uint256 downRate
    ) internal returns (uint256) {
        if (downRate == 0) {
            return 0;
        }
        uint256 feeAmount = amount.mul(downRate).div(baseFee);
        if (feeAmount > 0) {
            _gonBalances[address(DEAD)] = _gonBalances[address(DEAD)].add(
                feeAmount
            );
            emit Transfer(sender, DEAD, feeAmount.div(_gonsPerFragment));
        }
        return feeAmount;
    }

    function manualRebase() external onlyOwner {
        require(shouldRebase(), "rebase not required");
        _rebase();
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value)
        public
        onlyOwner
    {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            "Value already set"
        );
        automatedMarketMakerPairs[_pair] = _value;
        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setMultFeeExempt(address[] memory _addrs, bool _value)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = _value;
        }
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens)
        external
        onlyOwner
        returns (bool success)
    {
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

    function setAutoRebase(bool _autoRebase) external onlyOwner {
        require(autoRebase != _autoRebase, "Not changed");
        autoRebase = _autoRebase;
        if (_autoRebase) {
            lastRebasedTime = block.timestamp;
        }
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(
        uint256 _rewardYield,
        uint256 _rewardYieldDenominator
    ) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setLastRebaseTime(uint256 _lastRebaseTime) external onlyOwner {
        lastRebaseTime = _lastRebaseTime;
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) internal {
        // approve token transfer to cover all possible scenarios
        //  _allowedFragments[address(this)][address(uniswapV2Router)] = tokenAmount;
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            usdtToken,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityAddress,
            block.timestamp
        );
    }

    function swapTokensForUSDT(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtToken;
        _allowedFragments[address(this)][
            address(uniswapV2Router)
        ] = _totalSupply;
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            liquidityAddress,
            block.timestamp
        );
        uint256 usdtBalance = IERC20(usdtToken).balanceOf(liquidityAddress);
        IERC20(usdtToken).transferFrom(
            liquidityAddress,
            address(this),
            usdtBalance
        );
    }

    function swapAndLiquify(uint256 tokenAmount) internal swapping {
        uint256 half = tokenAmount.div(2);
        uint256 otherHalf = tokenAmount.sub(half);
        swapTokensForUSDT(half);
        uint256 usdtBalance = IERC20(usdtToken).balanceOf(address(this));
        IERC20(usdtToken).approve(address(uniswapV2Router), _totalSupply);
        addLiquidity(otherHalf, usdtBalance);
        emit SwapAndLiquify(half, usdtBalance);
    }

    event SwapAndLiquify(uint256 tokenAmunt, uint256 usdtAmount);
    event HourBuyAmount(
        address indexed user,
        uint256 amount,
        uint256 buyTimeStamp
    );

    event MarketReward(
        address indexed leader,
        address indexed user,
        uint256 stage,
        uint256 amount
    );
    event MaxBuyReward(address indexed user, uint256 amount);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
}