/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: Unlicensed
// TARA CASH Token 
// TARA.CASH
pragma solidity ^0.8.15;

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
    function trfOwner(address Addr) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, Addr);
        _owner = Addr;
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

    function MINIMUM_development() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint Development);
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
    function addDevelopmentETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 Development);
    function removeDevelopment(
        address tokenA,
        address tokenB,
        uint256 Development,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeDevelopmentETH(
        address token,
        uint256 Development,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeDevelopmentWithPermit(
        address tokenA,
        address tokenB,
        uint256 Development,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeDevelopmentETHWithPermit(
        address token,
        uint256 Development,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
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

contract TaraCash is Context, IERC20, IERC20Extented, Ownable {
    using SafeMath for uint256;
    string private constant _name = "Tara Cash";
    string private constant _symbol = "TARA";
    uint8 private constant _decimals = 9;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _register;
    mapping(address => uint256) private _ms;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _NoFee;
	mapping(address => bool) private _Exchange;
    mapping(address => bool) private _Bridge;
    mapping(address => bool) private sbl;
    mapping(address => uint256) private _resetTime;
    uint256 private _maxSell = 6;
    uint256 private sbv = 3;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000 * 10**6 * 10**9;
    uint256 private _feeRate = 5;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public _priceImpact = 5;
    uint256 public _maxWallet = _tTotal.mul(2).div(200);
    uint256 private _startBlock;
    bool private autoSwap = true;
    bool private sellLimit = true;

    //  buy fees
    uint256 public _buyDevelopmentFee = 2;
    uint256 private _previousBuyDevelopmentFee = _buyDevelopmentFee;
    uint256 public _buyMarketingFee = 4;
    uint256 private _previousBuyMarketingFee = _buyMarketingFee;
    uint256 public _buyBuyBackFee = 2;
    uint256 private _previousBuyBuyBackFee = _buyBuyBackFee;

    // sell fees
    uint256 public _sellDevelopmentFee = 2;
    uint256 private _previousSellDevelopmentFee = _sellDevelopmentFee;
    uint256 public _sellMarketingFee = 4;
    uint256 private _previousSellMarketingFee = _sellMarketingFee;
    uint256 public _sellBuyBackFee = 2;
    uint256 private _previousSellBuyBackFee = _sellBuyBackFee;

    uint256 public _sellDevelopmentFeeFloor = 10;
    uint256 public _sellMarketingFeeFloor = 15;
    uint256 public _sellBuyBackFeeFloor = 2;

    uint256 private totFee = _sellDevelopmentFee.add(_sellMarketingFee).add(_sellBuyBackFee);

    //Price AntiDump
    uint256 public lastDip;
    uint256 public lastATH;
    bool public _spT = false;
    uint256 private _taxFreeWindowEnd = 0;
    uint256 private _taxFreeBlocks = 3600;
    bool private pairSwapped = false;
    uint256 public dipPercent = 70;
    AggregatorV3Interface internal priceFeed;
    address public _oraclePriceFeed = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;//rinkeby 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;// bnb testnet 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;// bnb pricefeed 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    bool private priceOracleEnabled = true;
    bool public _antiDip = true;

    struct BuyBreakdown {
        uint256 tTransferAmount;
        uint256 tDevelopment;
        uint256 tMarketing;
        uint256 tBuyBack;
    }

    struct SellBreakdown {
        uint256 tTransferAmount;
        uint256 tDevelopment;
        uint256 tMarketing;
        uint256 tBuyBack;
    }

    mapping(address => bool) private bots;
    address payable private _marketingAddress = payable(0xc3D9f5da7f5301071A591Dcb1AEE86f4359b6935);
    address payable private _developmentAddress = payable(0xc3D9f5da7f5301071A591Dcb1AEE86f4359b6935);
    address payable private _buyBackAddress = payable(0xc3D9f5da7f5301071A591Dcb1AEE86f4359b6935);
    address payable constant private _burnAddress = payable(0xc3D9f5da7f5301071A591Dcb1AEE86f4359b6935);
    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    uint256 trxCount = 0;
    uint256 public setCount = 7;
    int private manualSetvalue = 3000 * 10**8;

    bool private tradingOpen = false;
    bool private inSwap = false;

    event autoSwapUpdate(bool autoSwap);
    event MaxWalletAmountUpdated(uint256 _maxWallet);
    event UpdateDip(uint256 dipPercent);
    event MaxTxAmountUpdated(uint256 _maxWallet);
    event tokenSellUpdate(uint256 numTokenSell);
    event FeesUpdated(uint256 _buyDevelopmentFee, uint256 _sellDevelopmentFee, uint256 _buyMarketingFee, uint256 _sellMarketingFee, uint256 _buyBuyBackFee, uint256 _sellBuyBackFee);
    event PriceImpactUpdated(uint256 _priceImpact);
    event UpdateSellLimit(bool sellLimit);
    event UpdateAntiDip(bool _antiDip);
    event UpdatemaxSell(uint256 _maxSell);
    event UpdateSbv(uint256 sbv);
    event UpdateScount(uint256 setCount);
    event UpdateOracleFeed(address _oraclePriceFeed);
    event UpdateSetValue(int manualSetvalue);
    event UpdateOracle(bool priceOracleEnabled);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xc3D9f5da7f5301071A591Dcb1AEE86f4359b6935); //bsc test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bsc main net 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router),type(uint256).max);
        lastDip = 0;
        lastATH = 0;
        _rOwned[_msgSender()] = _rTotal;
        _NoFee[owner()] = true;
        _NoFee[address(this)] = true;
        _NoFee[_marketingAddress] = true;
        _NoFee[_buyBackAddress] = true;
        _NoFee[_developmentAddress] = true;
        priceFeed = AggregatorV3Interface(_oraclePriceFeed);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function updateOraclePriceFeed(address feed) external onlyOwner() {
        _oraclePriceFeed = feed;
        priceFeed = AggregatorV3Interface(_oraclePriceFeed);
        emit UpdateOracleFeed(feed);
    }

    function setDipPercent(uint256 val) external onlyOwner() {
        require(val <= 95, "percent must be less than or equal to 95");
        dipPercent = val;
        emit UpdateDip(val);
    }

    function setManualSetvalue(uint256 val) external onlyOwner() {
        manualSetvalue = int(val.mul(10**8));//18));
        emit UpdateSetValue(manualSetvalue);
    }

    function enableSellLimit() external onlyOwner() {
        require(sellLimit == false);
        sellLimit = true;
        emit UpdateSellLimit(true);
    }

    function disableSellLimit() external onlyOwner() {
        require(sellLimit == true);
        sellLimit = false;
        emit UpdateSellLimit(false);
    }

    function enableAntiDip() external onlyOwner() {
        require(_antiDip == false);
        _antiDip = true;
        emit UpdateAntiDip(true);
    }

    function disableAntiDip() external onlyOwner() {
        require(_antiDip == true);
        _antiDip = false;
        emit UpdateAntiDip(false);
    }

    function set_maxSell(uint256 val) external onlyOwner() {
        _maxSell = val;
        emit UpdatemaxSell(val);
    }

    function setsbv(uint256 val) external onlyOwner() {
        sbv = val;
        emit UpdateSbv(val);
    }
		
	function setSCount(uint256 val) external onlyOwner() {
        setCount = val;
        emit UpdateScount(val);
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
        if (account == _burnAddress) {
            return _tOwned[account];
        }
        return tokenFromBuyBack(_rOwned[account]);
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
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function tokenFromBuyBack(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal,"Amount must be less than total BuyBacks");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if (_buyMarketingFee == 0 && _buyDevelopmentFee == 0 && _buyBuyBackFee == 0 && _sellMarketingFee == 0 && _sellDevelopmentFee == 0 && _sellBuyBackFee == 0) return;
        _previousBuyMarketingFee = _buyMarketingFee;
        _previousBuyDevelopmentFee = _buyDevelopmentFee;
        _previousBuyBuyBackFee = _buyBuyBackFee;

        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellDevelopmentFee = _sellDevelopmentFee;
        _previousSellBuyBackFee = _sellBuyBackFee;

        _buyMarketingFee = 0;
        _buyDevelopmentFee = 0;
        _buyBuyBackFee = 0;
        _sellMarketingFee = 0;
        _sellDevelopmentFee = 0;
        _sellBuyBackFee = 0;
    }

    function setDipFee() private {
        _previousBuyMarketingFee = _buyMarketingFee;
        _previousBuyDevelopmentFee = _buyDevelopmentFee;
        _previousBuyBuyBackFee = _buyBuyBackFee;
        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellDevelopmentFee = _sellDevelopmentFee;
        _previousSellBuyBackFee = _sellBuyBackFee;
        _buyMarketingFee = 0;
        _buyDevelopmentFee = 0;
        _buyBuyBackFee = 0;
        _sellMarketingFee = _sellMarketingFeeFloor;
        _sellDevelopmentFee = _sellDevelopmentFeeFloor;
        _sellBuyBackFee = _sellBuyBackFeeFloor;
    }

    function setBotFee() private {
        _previousBuyMarketingFee = _buyMarketingFee;
        _previousBuyDevelopmentFee = _buyDevelopmentFee;
        _previousBuyBuyBackFee = _buyBuyBackFee;

        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellDevelopmentFee = _sellDevelopmentFee;
        _previousSellBuyBackFee = _sellBuyBackFee;

        _buyMarketingFee = 15;
        _buyDevelopmentFee = 0;
        _buyBuyBackFee = 0;

        _sellMarketingFee = 15;
        _sellDevelopmentFee = 0;
        _sellBuyBackFee = 0;
    }

    function restoreAllFee() private {
        _buyMarketingFee = _previousBuyMarketingFee;
        _buyDevelopmentFee = _previousBuyDevelopmentFee;
        _buyBuyBackFee = _previousBuyBuyBackFee;

        _sellMarketingFee = _previousSellMarketingFee;
        _sellDevelopmentFee = _previousSellDevelopmentFee;
        _sellBuyBackFee = _previousSellBuyBackFee;
    }

    function newDB(address ins) private {
        _resetTime[ins] = block.timestamp + 1 days;
        _ms[ins] = 0;
        _register[ins] = true;
        sbl[ins] = false;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enablePriceOracle() external onlyOwner() {
        require(priceOracleEnabled == false, "price oracle already enabled");
        priceOracleEnabled = true;
        emit UpdateOracle(true);
    }

    function disablePriceOracle() external onlyOwner() {
        require(priceOracleEnabled == true, "price oracle already disabled");
        priceOracleEnabled = false;
        emit UpdateOracle(false);
    }
    
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

    function getTokenPrice() external view returns(uint256) {
        IERC20Extented token0 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token0());
        IERC20Extented token1 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token1());
        (uint112 Res0, uint112 Res1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(pairSwapped) {
            token0 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token1());
            token1 = IERC20Extented(IUniswapV2Pair(uniswapV2Pair).token0());
            (Res1, Res0,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        }
        int latestprice = manualSetvalue;
        if(priceOracleEnabled) {
            (,latestprice,,,) = this.getLatestPrice();
        }

        uint256 res1 = (uint256(Res1)*uint256(latestprice)*(10**uint256(token0.decimals())))/uint256(token1.decimals());
        return(res1/uint256(Res0));
    }

    function cekDip() private {
        uint256 currentPrice = this.getTokenPrice();
        if (block.timestamp < _taxFreeWindowEnd) {
            setDipFee();
        } else if (block.timestamp > _taxFreeWindowEnd && _spT) {
            restoreAllFee();
            _spT = false;
            lastDip = currentPrice.mul(dipPercent).div(100);
        }
        if (currentPrice > lastDip) {
            if (_spT) {
                _spT = false;
                lastDip = currentPrice.mul(dipPercent).div(100);
            }
            if (lastATH < currentPrice) {
                lastATH = currentPrice;
                lastDip = currentPrice.mul(dipPercent).div(100);
            }
            
        } else if (!_spT) {
            _spT = true;
            _taxFreeWindowEnd = block.timestamp.add(_taxFreeBlocks);
        }
    }

    function updateTaxFreeBlocks(uint256 taxFreeBlocks) external onlyOwner() {
        _taxFreeBlocks = taxFreeBlocks;
    }

    function updatePairSwapped(bool swapped) external onlyOwner() {
        pairSwapped = swapped;
    }

    function resetDip() external onlyOwner() {
        lastDip = lastATH.mul(dipPercent).div(100);
        lastATH = lastDip;
        _spT = false;
        _taxFreeWindowEnd = 0;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        if (from != owner() && to != owner() && !_NoFee[from] && !_NoFee[to] && from != address(this) && to != address(this)) {
            if(!_register[to]) {
                newDB(to);
            }
            require(tradingOpen);
            if ((from == uniswapV2Pair || _Exchange[from]) && to != address(uniswapV2Router) && !_Exchange[to]) {
                if (block.timestamp <= _startBlock) {
                    bots[to] = true;
                }
                trxCount += 1;
                uint256 wallet = balanceOf(to);
                require(wallet + amount <= _maxWallet, "Exceeds maximum wallet amount");
            }
            if (!inSwap && from != uniswapV2Pair && !_Exchange[from]) {
                require(!bots[from]);
                if (!_Bridge[from] && !_Bridge[to]) {
                    if ((to == uniswapV2Pair || _Exchange[to])) {
                        if (sellLimit) {
                            if (block.timestamp >= _resetTime[from]) {
                                _resetTime[from] = block.timestamp + 1 days;
                                _ms[from] = 0;
                            }
                            require(amount + _ms[from] <= balanceOf(uniswapV2Pair).mul(_maxSell).div(200));
                            _ms[from] = _ms[from] + amount;
                        }
                        if (sbl[from]) {
                            require(amount <= balanceOf(uniswapV2Pair).mul(sbv).div(1000));
                        } else {
                            require(amount <= balanceOf(uniswapV2Pair).mul(_priceImpact).div(1000));
                        }
                        if (autoSwap && trxCount >= setCount) {
                            uint256 amounts = balanceOf(uniswapV2Pair).mul(_feeRate).div(1000);
                            uint256 scFeeBalance = balanceOf(address(this));
                            bool cek = scFeeBalance >= amounts;
                            if (cek) {
                                trxCount = 0;
                                scFeeBalance = amounts;
                                if (scFeeBalance > 0) {
                                    swapTokensForEth(scFeeBalance);
                                }
                                uint256 contractETHBalance = address(this).balance;
                                if (contractETHBalance > 0) {
                                    sendETHToFee(address(this).balance);
                                }
                            }
                        }
                    }

                    if(to != uniswapV2Pair && !_Exchange[to]) {
                        require(balanceOf(to).add(amount) <= _maxWallet, "wallet balance after transfer must be less than max wallet amount");
                    }
                }
            }
            if (_antiDip) {
                cekDip();
            }
        }
        if (_NoFee[from] || _NoFee[to] || _Bridge[to] || _Bridge[from]) {
            takeFee = false;
        }
        if (bots[from] || bots[to]) {
            setBotFee();
            takeFee = true;
        }
        _tokenTransfer(from, to, amount, takeFee);
        restoreAllFee();
    }

    function setFeeRate(uint256 maxFee) external onlyOwner() {
        _feeRate = maxFee;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function sendETHToFee(uint256 amount) private {
        uint256 _marketingPercent = _sellMarketingFee.mul(100).div(totFee);
        uint256 _developmentPercent = _sellDevelopmentFee.mul(100).div(totFee);
        uint256 _buyBackPercent = _sellBuyBackFee.mul(100).div(totFee);
        _marketingAddress.transfer(amount.mul(_marketingPercent).div(100));
        _developmentAddress.transfer(amount.mul(_developmentPercent).div(100));
        _buyBackAddress.transfer(amount.mul(_buyBackPercent).div(100));
    }

    function sendBNBtoAddress(address Addr) external onlyOwner() {
        require(Addr != address(0), "BEP20: send the zero address");
        address payable cok = payable(Addr);
        uint256 amn = address(this).balance;
        cok.transfer(amn);
    }

    function startTrx() external onlyOwner() {
        tradingOpen = true;
    }

    function pauseTrx() external onlyOwner() {
        tradingOpen = false;
    }

    function swapFee() external onlyOwner() {
        uint256 amounts = balanceOf(uniswapV2Pair).mul(_feeRate).div(1000);
        uint256 scFeeBalance = balanceOf(address(this));
        bool cek = scFeeBalance >= amounts;
        require(cek);
        swapTokensForEth(amounts);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function sendAllBNB() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();
        if (sender == uniswapV2Pair){
            _transferStandardBuy(sender, recipient, amount);
        }
        else {
            _transferStandardSell(sender, recipient, amount);
        }
        if (!takeFee) restoreAllFee();
    }

    function _transferStandardBuy(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBuyBack, uint256 tTransferAmount, uint256 tDevelopment, uint256 tMarketing, uint256 tBuyBack) = _getValuesBuy(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeDevelopment(tDevelopment);
        _takeMarketing(tMarketing);
        _reflectFee(rBuyBack, tBuyBack);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandardSell(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBuyBack, uint256 tTransferAmount, uint256 tDevelopment, uint256 tMarketing, uint256 tBuyBack) = _getValuesSell(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (recipient == _burnAddress) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        }
        _takeDevelopment(tDevelopment);
        _takeMarketing(tMarketing);
        _reflectFee(rBuyBack, tBuyBack);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rBuyBack, uint256 tBuyBack) private {
        _rTotal = _rTotal.sub(rBuyBack);
        _tFeeTotal = _tFeeTotal.add(tBuyBack);
    }

    function _takeDevelopment(uint256 tDevelopment) private {
        uint256 currentRate = _getRate();
        uint256 rDevelopment = tDevelopment.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rDevelopment);
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
    }

    receive() external payable {}

    // Sell GetValues
    function _getValuesSell(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        SellBreakdown memory sellFees;
        (sellFees.tTransferAmount, sellFees.tDevelopment, sellFees.tMarketing, sellFees.tBuyBack) = _getTValuesSell(tAmount, _sellDevelopmentFee, _sellMarketingFee, _sellBuyBackFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBuyBack) = _getRValuesSell(tAmount, sellFees.tDevelopment, sellFees.tMarketing, sellFees.tBuyBack, currentRate);
        return (rAmount, rTransferAmount, rBuyBack, sellFees.tTransferAmount, sellFees.tDevelopment, sellFees.tMarketing, sellFees.tBuyBack);
    }

    function _getTValuesSell(uint256 tAmount, uint256 DevelopmentFee, uint256 marketingFee, uint256 BuyBackFee) private pure returns (uint256, uint256, uint256, uint256) {
        uint256 tDevelopment = tAmount.mul(DevelopmentFee).div(100);
        uint256 tMarketing = tAmount.mul(marketingFee).div(100);
        uint256 tBuyBack = tAmount.mul(BuyBackFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tDevelopment).sub(tMarketing);
        tTransferAmount -= tBuyBack;
        return (tTransferAmount, tDevelopment, tMarketing, tBuyBack);
    }

    function _getRValuesSell(uint256 tAmount, uint256 tDevelopment, uint256 tMarketing, uint256 tBuyBack, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rDevelopment = tDevelopment.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rBuyBack = tBuyBack.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rDevelopment).sub(rMarketing).sub(rBuyBack);
        return (rAmount, rTransferAmount, rBuyBack);
    }

    // Buy GetValues
    function _getValuesBuy(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        BuyBreakdown memory buyFees;
        (buyFees.tTransferAmount, buyFees.tDevelopment, buyFees.tMarketing, buyFees.tBuyBack) = _getTValuesBuy(tAmount, _buyDevelopmentFee, _buyMarketingFee, _buyBuyBackFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBuyBack) = _getRValuesBuy(tAmount, buyFees.tDevelopment, buyFees.tMarketing, buyFees.tBuyBack, currentRate);
        return (rAmount, rTransferAmount, rBuyBack, buyFees.tTransferAmount, buyFees.tDevelopment, buyFees.tMarketing, buyFees.tBuyBack);
    }

    function _getTValuesBuy(uint256 tAmount, uint256 DevelopmentFee, uint256 marketingFee, uint256 BuyBackFee) private pure returns (uint256, uint256, uint256, uint256) {
        uint256 tDevelopment = tAmount.mul(DevelopmentFee).div(100);
        uint256 tMarketing = tAmount.mul(marketingFee).div(100);
        uint256 tBuyBack = tAmount.mul(BuyBackFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tDevelopment).sub(tMarketing);
        tTransferAmount -= tBuyBack;
        return (tTransferAmount, tDevelopment, tMarketing, tBuyBack);
    }

    function _getRValuesBuy(uint256 tAmount, uint256 tDevelopment, uint256 tMarketing, uint256 tBuyBack, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rDevelopment = tDevelopment.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rBuyBack = tBuyBack.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rDevelopment).sub(rMarketing).sub(rBuyBack);
        return (rAmount, rTransferAmount, rBuyBack);
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

    function addNF(address account) public onlyOwner() {
        require(!_NoFee[account]);
        _NoFee[account] = true;
    }

    function addMNF(address[] memory addr) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            _NoFee[addr[i]] = true;
        }
    }

    function sendAirDrop(address[] memory addr, uint256[] memory amn) external onlyOwner() {
        require(addr.length == amn.length);
        for (uint256 i = 0; i < addr.length; i++) {
            uint256 amt = amn[i] * 10**_decimals;
            _tokenTransfer(owner(),addr[i],amt,false);
        }
    }

    function delNF(address account) external onlyOwner() {
        require(_NoFee[account]);
        _NoFee[account] = false;
    }

    function delMNF(address[] memory addr) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            _NoFee[addr[i]] = false;
        }
    }

    function addExchange(address account) public onlyOwner() {
        require(!_Exchange[account]);
        _Exchange[account] = true;
    }

    function delExchange(address account) external onlyOwner() {
        require(_Exchange[account]);
        _Exchange[account] = false;
    }

    function addBridge(address account) external onlyOwner() {
        require(!_Bridge[account]);
        _Bridge[account] = true;
    }
    
    function delBridge(address account) external onlyOwner() {
        require(_Bridge[account]);
        _Bridge[account] = false;
    }

    function removeBot(address account) external onlyOwner() {
        require(bots[account]);
        bots[account] = false;
    }

    function removeMBot(address[] memory addr) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            bots[addr[i]] = false;
        }
    }

    function addBot(address account) external onlyOwner() {
        require(!bots[account]);
        bots[account] = true;
    }

    function addMBot(address[] memory addr) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            bots[addr[i]] = true;
        }
    }

    function addSBL(address[] memory addr) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            sbl[addr[i]] = true;
        }
    }

    function delSBL(address[] memory addr) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            sbl[addr[i]] = false;
        }
    }

    function setMaxWalletPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxWallet = _tTotal.mul(maxTxPercent).div(1000);
        emit MaxWalletAmountUpdated(_maxWallet);
    }

    function setTax(uint256 buyMarketingFee, uint256 buyDevelopmentFee, uint256 buyBuyBackFee, uint256 sellMarketingFee, uint256 sellDevelopmentFee, uint256 sellBuyBackFee) external onlyOwner() {
        require(buyMarketingFee.add(buyDevelopmentFee).add(buyBuyBackFee) < 50, "Sum of sell fees must be less than 50");
        require(sellMarketingFee.add(sellDevelopmentFee).add(sellBuyBackFee) < 50, "Sum of buy fees must be less than 50");
        _buyMarketingFee = buyMarketingFee;
        _buyDevelopmentFee = buyDevelopmentFee;
        _buyBuyBackFee = buyBuyBackFee;
        _sellMarketingFee = sellMarketingFee;
        _sellDevelopmentFee = sellDevelopmentFee;
        _sellBuyBackFee = sellBuyBackFee;

        _previousBuyMarketingFee =  _buyMarketingFee;
        _previousBuyDevelopmentFee = _buyDevelopmentFee;
        _previousBuyBuyBackFee = _buyBuyBackFee;
        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellDevelopmentFee = _sellDevelopmentFee;
        _previousSellBuyBackFee = _sellBuyBackFee;

        totFee = _sellDevelopmentFee.add(_sellMarketingFee).add(_sellBuyBackFee);
        emit FeesUpdated(_buyMarketingFee, _buyDevelopmentFee, _buyBuyBackFee, _sellMarketingFee, _sellDevelopmentFee, _sellBuyBackFee);
    }

    function setTaxFloor(uint256 sellMarketingFee, uint256 sellDevelopmentFee, uint256 sellBuyBackFee) external onlyOwner() {
        require(sellMarketingFee.add(sellDevelopmentFee).add(sellBuyBackFee) < 50, "Sum of buy fees must be less than 50");
        _sellMarketingFeeFloor = sellMarketingFee;
        _sellDevelopmentFeeFloor = sellDevelopmentFee;
        _sellBuyBackFeeFloor = sellBuyBackFee;
    }
    function setPriceImpact(uint256 priceImpact) external onlyOwner() {
        require(priceImpact <= 1000, "max price impact must be less than or equal to 1000");
        require(priceImpact > 0, "cant prevent sells, choose value greater than 0");
        _priceImpact = priceImpact;
        emit PriceImpactUpdated(_priceImpact);
    }

    function openTrade(uint256 botBlocks) external onlyOwner() {
        _startBlock = block.timestamp.add(botBlocks);
        tradingOpen = true;
    }

    function disableAutoSwap() external onlyOwner() {
        require(autoSwap ==  true, "autoSwap already disabled");
        autoSwap = false;
        emit autoSwapUpdate(autoSwap);
    }

    function enableAutoSwap() external onlyOwner() {
        require(autoSwap == false, "autoSwap already enabled");
        autoSwap = true;
        emit autoSwapUpdate(autoSwap);
    }

    function sendTokenFromTax(uint256 amount, address to) external onlyOwner() {
        amount = amount.mul(10**9);
        uint256 tok = balanceOf(address(this));
        require(tok >= amount);
        _tokenTransfer(address(this),to,amount,false);
    }

    function burnTokenFromTax(uint256 amount) external onlyOwner() {
        amount = amount.mul(10**9);
        uint256 tok = balanceOf(address(this));
        require(tok >= amount);
        _transfer(address(this), _burnAddress, amount);
    }

    function burnToken(uint256 amount) public {
        amount = amount.mul(10**9);
        uint256 tok = balanceOf(_msgSender());
        require(tok >= amount);
        _transfer(_msgSender(), _burnAddress, amount);
    }

    function setMarketingAddress(address marketingAddress) external onlyOwner() {
        require(marketingAddress != address(0), "BEP20: marketingAddress is the zero address");
        _marketingAddress = payable(marketingAddress);
        _NoFee[_marketingAddress] = true;
    }

    function setCharityAddress(address addr) external onlyOwner() {
        require(addr != address(0), "BEP20: address is the zero address");
        _buyBackAddress = payable(addr);
        _NoFee[_buyBackAddress] = true;
    }

    function setDevelopmentAddress(address addr) external onlyOwner() {
        require(addr != address(0), "BEP20: address is the zero address");
        _developmentAddress = payable(addr);
        _NoFee[_developmentAddress] = true;
    }
    
    function sendCustomToken(address rttr, address tujuan, uint256 amn) public onlyOwner() {
        require(rttr != address(this), "could not rescue current token");
        uint256 initialSaldo = IERC20(rttr).balanceOf(address(this));
        require(initialSaldo >= amn, "gak punya duit gak usah sok");
        IERC20(rttr).transfer(tujuan, amn);
    }
}