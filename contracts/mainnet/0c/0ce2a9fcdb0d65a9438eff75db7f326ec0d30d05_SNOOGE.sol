/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**

/*
SNOOGE 
STEALTH LAUNCH

CUSTOM CONTRACT

Buy tax: 5%

5% Reflections


Sell Tax: 10%
4% Buyback and Marketing
1% Resident Wallet
2% LP
3% Reflections


DOGE HOURS
Hour 1 (& below floor): 48%
24% Buyback and Marketing
6% Resident Wallet
6% LP
12% Reflections

Hour 2: 24%
12% Buyback and Marketing
3% Resident Wallet
3% LP
6% Reflections
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract IERC20Extented is IERC20 {
    function decimals() external view virtual returns (uint8);
    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
}

contract SNOOGE is Context, IERC20, IERC20Extented, Ownable {
    using SafeMath for uint256;
    string private constant _name = "SNOOGE ";
    string private constant _symbol = "SNOOGE"; 
    uint8 private constant _decimals = 9;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private sellcooldown;
    mapping(address => uint256) private _sellTotal;
    mapping(address => uint256) private _firstSell;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isContractWallet; // exclude contract wallets maxWalletAmount
    mapping(address => bool) private _isExchange; // used for whitelisting exchange hot wallets
    mapping(address => bool) private _isBridge; //used for whitelisting bridges
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**9; 
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public _priceImpact = 2;
    uint256 private previousClose;
    uint256 private _firstBlock;
    uint256 private _botBlocks;
    uint256 public _maxWalletAmount;
    uint256 private _maxSellAmountBNB = 20000000000000000000; // 20 BNB
    uint256 private _minBuyBNB = 1; 
    uint256 private _minSellBNB = 10000000000000000; 
    uint256 private _taxFreeBlocks = 3600; // 1 hour
    uint256 private _cooldownBlocks = 3600; // 1 hour
    uint256 private _taxFreeWindowEnd; // block.timestamp + _taxFreeBlocks
    uint256 public _goldenHourStartBlock = 0;
    bool public _goldenHourStarted = false;
    uint256 private _slideEndBlock = 0;
    bool public _recovered = true;
    uint256 private _threshold = 10;
    uint256 private _floorPercent;
    uint256 private _ath = 0;
    
    uint256 public _floorBuybackFee = 24;
    uint256 public _floorResidentFee = 6;
    uint256 public _floorLiquidityFee = 6;
    uint256 public _floorReflectionFee = 12;

    uint256 public _slideBuybackFee = 12;
    uint256 public _slideResidentFee = 3;
    uint256 public _slideLiquidityFee = 3;
    uint256 public _slideReflectionFee = 6;

    //  buy fees
    uint256 public _buyBuybackFee = 0;
    uint256 private _previousBuyBuybackFee = _buyBuybackFee;
    uint256 public _buyResidentFee = 0;
    uint256 private _previousBuyResidentFee = _buyResidentFee;
    uint256 public _buyReflectionFee = 5;
    uint256 private _previousBuyReflectionFee = _buyReflectionFee;
    uint256 public _buyLiquidityFee = 0;
    uint256 private _previousBuyLiquidityFee = _buyLiquidityFee;
    
    // sell fees
    uint256 public _sellBuybackFee = 4;
    uint256 private _previousSellBuybackFee = _sellBuybackFee;
    uint256 public _sellResidentFee = 1;
    uint256 private _previousSellResidentFee = _sellResidentFee;
    uint256 public _sellReflectionFee = 3;
    uint256 private _previousSellReflectionFee = _sellReflectionFee;
    uint256 public _sellLiquidityFee = 2;
    uint256 private _previousSellLiquidityFee = _sellLiquidityFee;
  
    struct DynamicTax {
        uint256 buyBuybackFee;
        uint256 buyResidentFee;
        uint256 buyReflectionFee;
        uint256 buyLiquidityFee;
        
        uint256 sellBuybackFee;
        uint256 sellResidentFee;
        uint256 sellReflectionFee;
        uint256 sellLiquidityFee;
    }
    
    uint256 constant private _projectMaintainencePercent = 0;
    uint256 private _residentPercent = 25;
    uint256 private _buybackPercent = 65;

    struct BuyBreakdown {
        uint256 tTransferAmount;
        uint256 tBuyback;
        uint256 tResident;
        uint256 tReflection;
        uint256 tLiquidity;
    }

    struct SellBreakdown {
        uint256 tTransferAmount;
        uint256 tBuyback;
        uint256 tResident;
        uint256 tReflection;
        uint256 tLiquidity;
    }
    
    struct FinalFees {
        uint256 tTransferAmount;
        uint256 tBuyback;
        uint256 tResident;
        uint256 tReflection;
        uint256 tLiquidity;
        uint256 rReflection;
        uint256 rTransferAmount;
        uint256 rAmount;
    }

    mapping(address => bool) private bots;
    address payable private _residentAddress = payable(0xa07784B74932e1104CA5ADf1ABd63bDDD42492C0);
    address payable private _buybackAddress = payable(0xa07784B74932e1104CA5ADf1ABd63bDDD42492C0);
    address payable constant private _burnAddress = payable(0x000000000000000000000000000000000000dEaD);
    address private presaleRouter;
    address private presaleAddress;
    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    uint256 private _maxTxAmount;

    bool private tradingOpen = false;
    bool private inSwap = false;
    bool private presale = true;
    bool private pairSwapped = false;
    bool private _sellCoolDownEnabled = true;
    bool private _dailyMaxEnabled = true;

    event EndedPresale(bool presale);
    event UpdatedAllowableDip(uint256 hundredMinusDipPercent);
    event UpdatedHighLowWindows(uint256 GTblock, uint256 LTblock, uint256 blockWindow);
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    event SellOnlyUpdated(bool sellOnly);
    event PercentsUpdated(uint256 _residentPercent, uint256 _buybackPercent);
    event FeesUpdated(uint256 _buyBuybackFee, uint256 _buyResidentFee, uint256 _buyLiquidityFee, uint256 _buyReflectionFee, uint256 _sellBuyBackFee, uint256 _sellResidentFee, uint256 _sellLiquidityFee, uint256 _sellReflectionFee);
    event PriceImpactUpdated(uint256 _priceImpact);

    AggregatorV3Interface internal priceFeed;
    address public _oraclePriceFeed = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;//rinkeby 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;// bnb testnet 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;// bnb pricefeed 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    bool private priceOracleEnabled = true;
    int private manualETHvalue = 3000 * 10**8;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//ropstenn 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //bsc test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bsc main net 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router),type(uint256).max);

        priceFeed = AggregatorV3Interface(_oraclePriceFeed);

        previousClose = 0;

        _maxTxAmount =_tTotal.div(50); // start off transaction limit at 2% of total supply
        _maxWalletAmount = _tTotal.div(50); // 2%

        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_residentAddress] = true;
        _isExcludedFromFee[_buybackAddress] = true;
        _isContractWallet[_buybackAddress] = true;
        _isContractWallet[_residentAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() override external pure returns (string memory) {
        return _name;
    }

    function symbol() override external pure returns (string memory) {
        return _symbol;
    }

    function decimals() override external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal,"Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if (_buyResidentFee == 0 && _buyBuybackFee == 0 && _buyReflectionFee == 0 && _buyLiquidityFee == 0 && _sellResidentFee == 0 && _sellBuybackFee == 0 && _sellReflectionFee == 0 && _sellLiquidityFee == 0) return;
        _previousBuyResidentFee = _buyResidentFee;
        _previousBuyBuybackFee = _buyBuybackFee;
        _previousBuyReflectionFee = _buyReflectionFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;

        _previousSellResidentFee = _sellResidentFee;
        _previousSellBuybackFee = _sellBuybackFee;
        _previousSellReflectionFee = _sellReflectionFee;
        _previousSellLiquidityFee = _sellLiquidityFee;

        _buyResidentFee = 0;
        _buyBuybackFee = 0;
        _buyReflectionFee = 0;
        _buyLiquidityFee = 0;

        _sellResidentFee = 0;
        _sellBuybackFee = 0;
        _sellReflectionFee = 0;
        _sellLiquidityFee = 0;
    }

    function setBotFee() private {
        _previousBuyResidentFee = _buyResidentFee;
        _previousBuyBuybackFee = _buyBuybackFee;
        _previousBuyReflectionFee = _buyReflectionFee;

        _previousSellResidentFee = _sellResidentFee;
        _previousSellBuybackFee = _sellBuybackFee;
        _previousSellReflectionFee = _sellReflectionFee;

        _buyResidentFee = 5;
        _buyBuybackFee = 85;
        _buyReflectionFee = 0;

        _sellResidentFee = 5;
        _sellBuybackFee = 85;
        _sellReflectionFee = 0;
    }
    
    function restoreAllFee() private {
        _buyResidentFee = _previousBuyResidentFee;
        _buyBuybackFee = _previousBuyBuybackFee;
        _buyReflectionFee = _previousBuyReflectionFee;
        _buyLiquidityFee = _previousBuyLiquidityFee;

        _sellResidentFee = _previousSellResidentFee;
        _sellBuybackFee = _previousSellBuybackFee;
        _sellReflectionFee = _previousSellReflectionFee;
        _sellLiquidityFee = _previousSellLiquidityFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() external view returns (uint80, int, uint, uint,  uint80) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        return (roundID, price, startedAt, timeStamp,  answeredInRound);
    }

    // calculate price based on pair reserves
    function getTokenPrice() external view returns(uint256) {
        IERC20Extented token0 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token0());//dogex
        IERC20Extented token1 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token1());//bnb
        (uint112 Res0, uint112 Res1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(pairSwapped) {
            token0 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token1());//dogex
            token1 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token0());//bnb
            (Res1, Res0,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        }
        int latestETHprice = manualETHvalue; // manualETHvalue used if oracle crashes
        if(priceOracleEnabled) {
            (,latestETHprice,,,) = this.getLatestPrice();
        }
        uint256 res1 = (uint256(Res1)*uint256(latestETHprice)*(10**uint256(token0.decimals())))/uint256(token1.decimals());

        return(res1/uint256(Res0)); // return amount of token1 needed to buy token0
    }

    // calculate price based on pair reserves
    function getTokenPriceBNB(uint256 amount) external view returns(uint256) {
        IERC20Extented token0 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token0());//dogex
        IERC20Extented token1 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token1());//bnb
        (uint112 Res0, uint112 Res1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(pairSwapped) {
            token0 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token1());//dogex
            token1 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token0());//bnb
            (Res1, Res0,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        }

        uint res1 = Res1*(10**token0.decimals());
        return((amount*res1)/(Res0*(10**token0.decimals()))); // return amount of token1 needed to buy token0
    }
    
    function updateFee() private returns(DynamicTax memory) {
        
        DynamicTax memory currentTax;
        
        currentTax.buyBuybackFee = _buyBuybackFee;
        currentTax.buyResidentFee = _buyResidentFee;
        currentTax.buyLiquidityFee = _buyLiquidityFee;
        currentTax.buyReflectionFee = _buyReflectionFee;
        
        currentTax.sellBuybackFee = _sellBuybackFee;
        currentTax.sellResidentFee = _sellResidentFee;
        currentTax.sellLiquidityFee = _sellLiquidityFee;
        currentTax.sellReflectionFee = _sellReflectionFee;
        
        uint256 currentPrice = this.getTokenPrice();

        if(block.timestamp >= _goldenHourStartBlock && block.timestamp <= _taxFreeWindowEnd) {
            currentTax.buyBuybackFee = 0;
            currentTax.buyResidentFee = 0;
            currentTax.buyLiquidityFee = 0;
            currentTax.buyReflectionFee = 0;
            
            currentTax.sellBuybackFee = _floorBuybackFee;
            currentTax.sellResidentFee = _floorResidentFee;
            currentTax.sellLiquidityFee = _floorLiquidityFee;
            currentTax.sellReflectionFee = _floorReflectionFee;
        }
        else if (block.timestamp > _taxFreeWindowEnd && block.timestamp <= _slideEndBlock) {
            currentTax.buyBuybackFee = _buyBuybackFee;
            currentTax.buyResidentFee = _buyResidentFee;
            currentTax.buyLiquidityFee = _buyLiquidityFee;
            currentTax.buyReflectionFee = _buyReflectionFee;
            
            currentTax.sellBuybackFee = _slideBuybackFee;
            currentTax.sellResidentFee = _slideResidentFee;
            currentTax.sellLiquidityFee = _slideLiquidityFee;
            currentTax.sellReflectionFee = _slideReflectionFee;
        }
        if (block.timestamp > _taxFreeWindowEnd && _goldenHourStarted) {
            _goldenHourStarted = false;
        }
        if (currentPrice > previousClose.mul(uint256(100).add(_threshold)).div(100) && !_recovered && !_goldenHourStarted) {
            _recovered = true;
        }
        if (currentPrice <= previousClose) {
            currentTax.buyBuybackFee = _buyBuybackFee;
            currentTax.buyResidentFee = _buyResidentFee;
            currentTax.buyLiquidityFee = _buyLiquidityFee;
            currentTax.buyReflectionFee = _buyReflectionFee;
        
            currentTax.sellBuybackFee = _floorBuybackFee;
            currentTax.sellResidentFee = _floorResidentFee;
            currentTax.sellLiquidityFee = _floorLiquidityFee;
            currentTax.sellReflectionFee = _floorReflectionFee;
            
            if(block.timestamp >= _goldenHourStartBlock && block.timestamp <= _taxFreeWindowEnd) {
                currentTax.buyBuybackFee = 0;
                currentTax.buyResidentFee = 0;
                currentTax.buyLiquidityFee = 0;
                currentTax.buyReflectionFee = 0;
                
                currentTax.sellBuybackFee = _floorBuybackFee;
                currentTax.sellResidentFee = _floorResidentFee;
                currentTax.sellLiquidityFee = _floorLiquidityFee;
                currentTax.sellReflectionFee = _floorReflectionFee;
            }
            if(!_goldenHourStarted && _recovered) {
                startGoldenHour();
                currentTax.buyBuybackFee = 0;
                currentTax.buyResidentFee = 0;
                currentTax.buyLiquidityFee = 0;
                currentTax.buyReflectionFee = 0;
                
                currentTax.sellBuybackFee = _floorBuybackFee;
                currentTax.sellResidentFee = _floorResidentFee;
                currentTax.sellLiquidityFee = _floorLiquidityFee;
                currentTax.sellReflectionFee = _floorReflectionFee;
                _recovered = false;
            }
        }
        if (currentPrice > _ath) {
            _ath = currentPrice;
        }
        
        return currentTax;
    }
    
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;
        
        DynamicTax memory currentTax;

        if (from != owner() && to != owner() && !presale && !_isContractWallet[from] && !_isContractWallet[to] && from != address(this) && to != address(this)) {
            require(tradingOpen);
            if (from != presaleRouter && from != presaleAddress) {
                require(amount <= _maxTxAmount);
            }
            if ((from == uniswapV2Pair || _isExchange[from]) && to != address(uniswapV2Router) && !_isExchange[to]) {//buys
                if (block.timestamp <= _firstBlock.add(_botBlocks) && from != presaleRouter && from != presaleAddress) {
                    bots[to] = true;
                }
                
                uint256 bnbAmount = this.getTokenPriceBNB(amount);
                
                require(bnbAmount >= _minBuyBNB, "you must buy at least min BNB worth of token");
                require(balanceOf(to).add(amount) <= _maxWalletAmount, "wallet balance after transfer must be less than max wallet amount");
                
                currentTax = updateFee();
                
            }
            
            if (!inSwap && from != uniswapV2Pair && !_isExchange[from]) { //sells, transfers
                require(!bots[from] && !bots[to]);
                
                if (!_isBridge[from] && !_isBridge[to]) {
                    if ((to == uniswapV2Pair || _isExchange[to]) && _sellCoolDownEnabled) {
                        require(sellcooldown[from] < block.timestamp);
                        sellcooldown[from] = block.timestamp.add(_cooldownBlocks);
                    }
                    
                    uint256 bnbAmount = this.getTokenPriceBNB(amount);
                    
                    require(bnbAmount >= _minSellBNB, "you must buy at least the min BNB worth of token");
                    
                    if(_dailyMaxEnabled) {
                        if(block.timestamp.sub(_firstSell[from]) > (1 days)) {
                            _firstSell[from] = block.timestamp;
                            _sellTotal[from] = 0;
                        }
                        require(_sellTotal[from].add(bnbAmount) <= _maxSellAmountBNB, "you cannot sell more than the max BNB amount per day");
                        _sellTotal[from] += bnbAmount;
                    }
                    else {
                        require(bnbAmount <= _maxSellAmountBNB, 'you cannot sell more than the max BNB amount per transaction');
                    }
                    
                    require(amount <= balanceOf(uniswapV2Pair).mul(_priceImpact).div(100)); // price impact limit
                    
                    if(to != uniswapV2Pair && !_isExchange[to]) {
                        require(balanceOf(to).add(amount) <= _maxWalletAmount, "wallet balance after transfer must be less than max wallet amount");
                    }

                    currentTax = updateFee();
                    
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {

                        uint256 autoLPamount = _sellLiquidityFee.mul(contractTokenBalance).div(_sellBuybackFee.add(_sellResidentFee).add(_sellLiquidityFee));
                        swapAndLiquify(autoLPamount);
                    
                        swapTokensForEth(contractTokenBalance.sub(autoLPamount));
                    }
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 0) {
                        sendETHToFee(address(this).balance);
                    }
                    
                }
            }
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || presale || _isBridge[to] || _isBridge[from]) {
            restoreAllFee();
            takeFee = false;
        }

        if (bots[from] || bots[to]) {
            restoreAllFee();
            setBotFee();
            takeFee = true;
        }

        if (presale) {
            require(from == owner() || from == presaleRouter || from == presaleAddress);
        }
        
        _tokenTransfer(from, to, amount, takeFee, currentTax);
        restoreAllFee();
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
              address(this),
              tokenAmount,
              0, // slippage is unavoidable
              0, // slippage is unavoidable
              owner(),
              block.timestamp
          );
    }
  
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForEth(half); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancakeswap
        addLiquidity(otherHalf, newBalance);
    }

    function sendETHToFee(uint256 amount) private {
        _residentAddress.transfer(amount.mul(_residentPercent).div(100));
        _buybackAddress.transfer(amount.mul(_buybackPercent).div(100));
    }

    function openTrading(uint256 botBlocks, uint256 floorPercent) private {
        uint256 currentPrice = this.getTokenPrice();
        _floorPercent = floorPercent;
        _ath = currentPrice.mul(_floorPercent).div(100);
        previousClose = _ath;
        _firstBlock = block.timestamp;
        _botBlocks = botBlocks;
        tradingOpen = true;
    }

    function manualswap() external {
        require(_msgSender() == _residentAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() external {
        require(_msgSender() == _residentAddress);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, DynamicTax memory currentTax) private {
        if (!takeFee) { 
                currentTax.buyBuybackFee = 0;
                currentTax.buyResidentFee = 0;
                currentTax.buyLiquidityFee = 0;
                currentTax.buyReflectionFee = 0;
                
                currentTax.sellBuybackFee = 0;
                currentTax.sellResidentFee = 0;
                currentTax.sellLiquidityFee = 0;
                currentTax.sellReflectionFee = 0;
        }
        if (sender == uniswapV2Pair || _isExchange[sender]){
            _transferStandardBuy(sender, recipient, amount, currentTax);
        }
        else {
            _transferStandardSell(sender, recipient, amount, currentTax);
        }
    }

    function _transferStandardBuy(address sender, address recipient, uint256 tAmount, DynamicTax memory currentTax) private {
        FinalFees memory buyFees;
        buyFees = _getValuesBuy(tAmount, currentTax);
        _rOwned[sender] = _rOwned[sender].sub(buyFees.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(buyFees.rTransferAmount);
        _takeBuyback(buyFees.tBuyback);
        _takeResident(buyFees.tResident);
        _reflectFee(buyFees.rReflection, buyFees.tReflection);
        _takeLiquidity(buyFees.tLiquidity);
        emit Transfer(sender, recipient, buyFees.tTransferAmount);
    }

    function _transferStandardSell(address sender, address recipient, uint256 tAmount, DynamicTax memory currentTax) private {
        FinalFees memory sellFees;
        sellFees = _getValuesSell(tAmount, currentTax);
        _rOwned[sender] = _rOwned[sender].sub(sellFees.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(sellFees.rTransferAmount);
        if (recipient == _burnAddress) {
            _tOwned[recipient] = _tOwned[recipient].add(sellFees.tTransferAmount);
        }
        _takeBuyback(sellFees.tBuyback);
        _takeResident(sellFees.tResident);
        _reflectFee(sellFees.rReflection, sellFees.tReflection);
        _takeLiquidity(sellFees.tLiquidity);
        emit Transfer(sender, recipient, sellFees.tTransferAmount);
    }

    function _reflectFee(uint256 rReflection, uint256 tReflection) private {
        _rTotal = _rTotal.sub(rReflection);
        _tFeeTotal = _tFeeTotal.add(tReflection);
    }

    function _takeBuyback(uint256 tBuyback) private {
        uint256 currentRate = _getRate();
        uint256 rBuyback = tBuyback.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rBuyback);
    }

    function _takeResident(uint256 tResident) private {
        uint256 currentRate = _getRate();
        uint256 rResident = tResident.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rResident);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    }
    

    receive() external payable {}

    // Sell GetValues
    function _getValuesSell(uint256 tAmount, DynamicTax memory currentTax) private view returns (FinalFees memory) {
        SellBreakdown memory sellFees = _getTValuesSell(tAmount, currentTax.sellBuybackFee, currentTax.sellResidentFee, currentTax.sellReflectionFee, currentTax.sellLiquidityFee);
        FinalFees memory finalFees;
        uint256 currentRate = _getRate();
        (finalFees.rAmount, finalFees.rTransferAmount, finalFees.rReflection) = _getRValuesSell(tAmount, sellFees.tBuyback, sellFees.tResident, sellFees.tReflection, sellFees.tLiquidity, currentRate);
        finalFees.tBuyback = sellFees.tBuyback;
        finalFees.tResident = sellFees.tResident;
        finalFees.tReflection = sellFees.tReflection;
        finalFees.tLiquidity = sellFees.tLiquidity;
        finalFees.tTransferAmount = sellFees.tTransferAmount;
        return (finalFees);
    }

    function _getTValuesSell(uint256 tAmount, uint256 buybackFee, uint256 residentFee, uint256 reflectionFee, uint256 liquidityFee) private pure returns (SellBreakdown memory) {
        SellBreakdown memory tsellFees;
        tsellFees.tBuyback = tAmount.mul(buybackFee).div(100);
        tsellFees.tResident = tAmount.mul(residentFee).div(100);
        tsellFees.tReflection = tAmount.mul(reflectionFee).div(100);
        tsellFees.tLiquidity = tAmount.mul(liquidityFee).div(100);
        tsellFees.tTransferAmount = tAmount.sub(tsellFees.tBuyback).sub(tsellFees.tResident);
        tsellFees.tTransferAmount -= tsellFees.tReflection;
        tsellFees.tTransferAmount -= tsellFees.tLiquidity;
        return (tsellFees);
    }

    function _getRValuesSell(uint256 tAmount, uint256 tBuyback, uint256 tResident, uint256 tReflection, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rBuyback = tBuyback.mul(currentRate);
        uint256 rResident = tResident.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rBuyback).sub(rResident).sub(rReflection);
        rTransferAmount -= rLiquidity;
        return (rAmount, rTransferAmount, rReflection);
    }

    // Buy GetValues
    function _getValuesBuy(uint256 tAmount, DynamicTax memory currentTax) private view returns (FinalFees memory) {
        BuyBreakdown memory buyFees = _getTValuesBuy(tAmount, currentTax.buyBuybackFee, currentTax.buyResidentFee, currentTax.buyReflectionFee, currentTax.buyLiquidityFee);
        FinalFees memory finalFees;
        uint256 currentRate = _getRate();
        (finalFees.rAmount, finalFees.rTransferAmount, finalFees.rReflection) = _getRValuesBuy(tAmount, buyFees.tBuyback, buyFees.tResident, buyFees.tReflection, buyFees.tLiquidity, currentRate);
        finalFees.tBuyback = buyFees.tBuyback;
        finalFees.tResident = buyFees.tResident;
        finalFees.tReflection = buyFees.tReflection;
        finalFees.tLiquidity = buyFees.tLiquidity;
        finalFees.tTransferAmount = buyFees.tTransferAmount;
        return (finalFees);
    }

    function _getTValuesBuy(uint256 tAmount, uint256 buybackFee, uint256 residentFee, uint256 reflectionFee, uint256 liquidityFee) private pure returns (BuyBreakdown memory) {
        BuyBreakdown memory tbuyFees;
        tbuyFees.tBuyback = tAmount.mul(buybackFee).div(100);
        tbuyFees.tResident = tAmount.mul(residentFee).div(100);
        tbuyFees.tReflection = tAmount.mul(reflectionFee).div(100);
        tbuyFees.tLiquidity = tAmount.mul(liquidityFee).div(100);
        tbuyFees.tTransferAmount = tAmount.sub(tbuyFees.tBuyback).sub(tbuyFees.tResident);
        tbuyFees.tTransferAmount -= tbuyFees.tReflection;
        tbuyFees.tTransferAmount -= tbuyFees.tLiquidity;
        return (tbuyFees);
    }

    function _getRValuesBuy(uint256 tAmount, uint256 tBuyback, uint256 tResident, uint256 tReflection, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rBuyback = tBuyback.mul(currentRate);
        uint256 rResident = tResident.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rBuyback).sub(rResident).sub(rReflection);
        rTransferAmount -= rLiquidity;
        return (rAmount, rTransferAmount, rReflection);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (_rOwned[_burnAddress] > rSupply || _tOwned[_burnAddress] > tSupply) return (_rTotal, _tTotal);
        rSupply = rSupply.sub(_rOwned[_burnAddress]);
        tSupply = tSupply.sub(_tOwned[_burnAddress]);
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    function removeBot(address account) external onlyOwner() {
        bots[account] = false;
    }

    function addBot(address  account) external onlyOwner() {
        bots[account] = true;
    }
    
    function excludeFromContractWallet(address account) public onlyOwner() {
        _isContractWallet[account] = true;
    }

    function includeInContractWallet(address account) external onlyOwner() {
        _isContractWallet[account] = false;
    }
    
    function includeInExchange(address account) external onlyOwner() {
        _isExchange[account] = true;
    }
    
    function excludeFromExchange(address account) external onlyOwner() {
        _isExchange[account] = false;
    }

    function includeInBridge(address account) external onlyOwner() {
        _isBridge[account] = true;
    }
    
    function excludeFromBridge(address account) external onlyOwner() {
        _isBridge[account] = false;
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount > 0, "Amount must be greater than 0");
        require(maxTxAmount <= _tTotal, "Amount must be less than or equal to totalSupply");
        _maxTxAmount = maxTxAmount;
        emit MaxTxAmountUpdated(_maxTxAmount);
    }

    function setMaxWalletAmount(uint256 maxWalletAmount) external onlyOwner() {
        require(maxWalletAmount > 0, "Amount must be greater than 0");
        require(maxWalletAmount <= _tTotal, "Amount must be less than or equal to totalSupply");
        _maxWalletAmount = maxWalletAmount;
    }
    
    function setPercents(uint256 residentPercent, uint256 buybackPercent) external onlyOwner() {
        require(residentPercent.add(buybackPercent) == 95, "Sum of percents must equal 95");
        _residentPercent = residentPercent;
        _buybackPercent = buybackPercent;
        emit PercentsUpdated(_residentPercent, _buybackPercent);
    }

    function setTaxes(uint256 buyResidentFee, uint256 buyBuybackFee, uint256 buyReflectionFee, uint256 buyLiquidityFee, uint256 sellResidentFee, uint256 sellBuybackFee, uint256 sellReflectionFee, uint256 sellLiquidityFee) external onlyOwner() {
        uint256 buyTax = buyResidentFee.add(buyBuybackFee).add(buyReflectionFee);
        buyTax += buyLiquidityFee;
        uint256 sellTax = sellResidentFee.add(sellBuybackFee).add(sellReflectionFee);
        sellTax += sellLiquidityFee;
        require(buyTax < 49, "Sum of sell fees must be less than 49");
        require(sellTax < 49, "Sum of buy fees must be less than 49");
        _buyResidentFee = buyResidentFee;
        _buyBuybackFee = buyBuybackFee;
        _buyReflectionFee = buyReflectionFee;
        _buyLiquidityFee = buyLiquidityFee;
        _sellResidentFee = sellResidentFee;
        _sellBuybackFee = sellBuybackFee;
        _sellReflectionFee = sellReflectionFee;
        _sellLiquidityFee = sellLiquidityFee;
        
        _previousBuyResidentFee = _buyResidentFee;
        _previousBuyBuybackFee = _buyBuybackFee;
        _previousBuyReflectionFee = _buyReflectionFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousSellResidentFee = _sellResidentFee;
        _previousSellBuybackFee = _sellBuybackFee;
        _previousSellReflectionFee = _sellReflectionFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        
        emit FeesUpdated(_buyBuybackFee, _buyResidentFee, _buyLiquidityFee, _buyReflectionFee, _sellBuybackFee, _sellResidentFee, _sellLiquidityFee, _sellReflectionFee);
    }

    function setPriceImpact(uint256 priceImpact) external onlyOwner() {
        require(priceImpact <= 100, "max price impact must be less than or equal to 100");
        require(priceImpact > 0, "cant prevent sells, choose value greater than 0");
        _priceImpact = priceImpact;
        emit PriceImpactUpdated(_priceImpact);
    }

    function setManualETHvalue(uint256 val) external onlyOwner() {
        manualETHvalue = int(val.mul(10**8));//18));
    }

    function updateOraclePriceFeed(address feed) external onlyOwner() {
        _oraclePriceFeed = feed;
    }

    function setPresaleRouterAndAddress(address router, address wallet) external onlyOwner() {
        presaleRouter = router;
        presaleAddress = wallet;
        excludeFromFee(presaleRouter);
        excludeFromFee(presaleAddress);
    }

    function endPresale(uint256 botBlocks, uint256 floorPercent) external onlyOwner() {
        require(presale == true, "presale already ended");
        presale = false;
        openTrading(botBlocks, floorPercent);
        emit EndedPresale(presale);
    }

    function enablePriceOracle() external onlyOwner() {
        require(priceOracleEnabled == false, "price oracle already enabled");
        priceOracleEnabled = true;
    }

    function disablePriceOracle() external onlyOwner() {
        require(priceOracleEnabled == true, "price oracle already disabled");
        priceOracleEnabled = false;
    }

    function setFloor() external onlyOwner() {
        previousClose = _ath.mul(_floorPercent).div(100);
        _ath = previousClose;
    }
    
    function setFloorPercent(uint256 floorPercent) external onlyOwner() {
        require(floorPercent > 0 && floorPercent <= 100, 'floorPercent needs to be between 0 and 100');
        _floorPercent = floorPercent;
    }
    function updateTaxFreeBlocks(uint256 taxFreeBlocks) external onlyOwner() {
        _taxFreeBlocks = taxFreeBlocks;
    }

    function updatePairSwapped(bool swapped) external onlyOwner() {
        pairSwapped = swapped;
    }
    
    function updateMinBuySellBNB(uint256 minBuyBNB, uint256 minSellBNB) external onlyOwner() {
        _minBuyBNB = minBuyBNB;
        _minSellBNB = minSellBNB;
    }
    
    function updateMaxSellAmountBNB(uint256 maxSellBNB) external onlyOwner() {
        _maxSellAmountBNB = maxSellBNB;
    }
    
    function startGoldenHour() private {
        _goldenHourStartBlock = block.timestamp;
        _goldenHourStarted = true;
        _taxFreeWindowEnd = block.timestamp.add(_taxFreeBlocks);
        _slideEndBlock = _taxFreeWindowEnd.add(_taxFreeBlocks);
    }

    function enableSellCoolDown() external onlyOwner() {
        require(!_sellCoolDownEnabled, "already enabled");
        _sellCoolDownEnabled = true;
    }
    
    function disableSellCoolDown() external onlyOwner() {
        require(_sellCoolDownEnabled, "already disabled");
        _sellCoolDownEnabled = false;
    }
    
    function enableDailyMax() external onlyOwner() {
        require(!_dailyMaxEnabled, 'already enabled');
        _dailyMaxEnabled = true;
    }
    
    function disableDailyMax() external onlyOwner() {
        require(_dailyMaxEnabled, 'already diabled');
        _dailyMaxEnabled = false;
    }
    
    function setFloorFees(uint256 floorResidentFee, uint256 floorBuybackFee, uint256 floorReflectionFee, uint256 floorLiquidityFee) external onlyOwner() {
        require(floorResidentFee.add(floorBuybackFee).add(floorReflectionFee).add(floorLiquidityFee) < 49, "sum of fees must be less than 49");
        _floorResidentFee = floorResidentFee;
        _floorBuybackFee = floorBuybackFee;
        _floorReflectionFee = floorReflectionFee;
        _floorLiquidityFee = floorLiquidityFee;
    }
    
    function setSlideFees(uint256 slideResidentFee, uint256 slideBuybackFee, uint256 slideReflectionFee, uint256 slideLiquidityFee) external onlyOwner() {
        require(slideResidentFee.add(slideBuybackFee).add(slideReflectionFee).add(slideLiquidityFee) < 49, "sum of fees must be less than 49");
        _slideResidentFee = slideResidentFee;
        _slideBuybackFee = slideBuybackFee;
        _slideReflectionFee = slideReflectionFee;
        _slideLiquidityFee = slideLiquidityFee;
    }
    
    function setCoolDownBlocks(uint256 cooldownBlocks) external onlyOwner() {
        _cooldownBlocks = cooldownBlocks;
    }
    
    function updateBuyBackAddress(address payable buybackAddress) external onlyOwner() {
        _buybackAddress = buybackAddress;
    }
    
    function updateResidentAddress(address payable residentAddress) external onlyOwner() {
        _residentAddress = residentAddress;
    }
    
    
    function getRemainingSellLimit(address payable account) external view returns (uint256) {
        if (_dailyMaxEnabled) {
            return _maxSellAmountBNB.sub(_sellTotal[account]);
        }
        return _maxSellAmountBNB;
    }
    
    function getTimeLimit(address payable account) external view returns (uint256) {
        if (_sellCoolDownEnabled && !_dailyMaxEnabled) {
            if(sellcooldown[account] < block.timestamp) {
                return block.timestamp.sub(sellcooldown[account]); // seconds remaining until cooldown is over
            }
            return 0; // not in cooldown, can sell now
        }
        else if (_sellCoolDownEnabled && _dailyMaxEnabled) {
            if (_maxSellAmountBNB.sub(_sellTotal[account]) > 0) {
                if (sellcooldown[account] > block.timestamp) {
                    return sellcooldown[account].sub(block.timestamp); // seconds remaining until cooldown is over
                }
                else {
                    return 0; // not in cooldown, can sell now
                }
            }
            else {
                if (block.timestamp > _firstSell[account].add(1 days)) {
                    return 0; // it's been more than 24 hours, can sell now
                }
                else {
                    return (uint256(1 days).add(_firstSell[account])).sub(block.timestamp); // seconds remaining until 24 hours have passed
                }
            }
            
        }
        else {
            return 0; // can sell now
        }
    }
}