/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT


//https://www.apegeinuofficial.com/
//https://t.me/apegeInuofficial
//


//*total supplay = 10000000000000


pragma solidity 0.8.14;

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

contract APEGEINU is Context, IERC20, IERC20Extented, Ownable {
    using SafeMath for uint256;
    string private constant _name = "APEGINU";
    string private constant _symbol = "APEGINU";
    uint8 private constant _decimals = 18;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _NoFee;
	mapping(address => bool) private _Exchange;
    mapping(address => bool) private _Bridge;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 10 * 10 ** (12 + _decimals);
    uint256 private _feeRate = 50;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public _priceImpact = 50;
    uint256 public _maxWallet = _tTotal.mul(1).div(200);
    uint256 private _startBlock;
    bool private autoSwap = true;
    bool private sellLimit = true;
    bool private freeTrf = false;

    //  buy fees
    uint256 public _buyLiquidityFee = 2;
    uint256 private _previousBuyLiquidityFee = _buyLiquidityFee;
    uint256 public _buyMarketingFee = 4;
    uint256 private _previousBuyMarketingFee = _buyMarketingFee;
    uint256 public _buyReflectionFee = 2;
    uint256 private _previousBuyReflectionFee = _buyReflectionFee;
    uint256 public _buyDevFee = 4;
    uint256 private _previousBuyDevFee = _buyDevFee;

    // sell fees
    uint256 public _sellLiquidityFee = 2;
    uint256 private _previousSellLiquidityFee = _sellLiquidityFee;
    uint256 public _sellMarketingFee = 4;
    uint256 private _previousSellMarketingFee = _sellMarketingFee;
    uint256 public _sellReflectionFee = 2;
    uint256 private _previousSellReflectionFee = _sellReflectionFee;
    uint256 public _sellDevFee = 4;
    uint256 private _previousSellDevFee = _sellDevFee;

    uint256 private totFee = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee);
    
    struct BuyBreakdown {
        uint256 tTransferAmount;
        uint256 tLiquidity;
        uint256 tMarketing;
        uint256 tReflection;
    }

    struct SellBreakdown {
        uint256 tTransferAmount;
        uint256 tLiquidity;
        uint256 tMarketing;
        uint256 tReflection;
    }

    mapping(address => bool) private bots;
    address payable private _marketingAddress = payable(0x021aa1f9B03c5406A666DCF09c55141dfb4c6050);
    address payable private _liquidityAddress = payable(0x021aa1f9B03c5406A666DCF09c55141dfb4c6050);
    address payable private _devAddress = payable(0x021aa1f9B03c5406A666DCF09c55141dfb4c6050);
    address payable constant private _burnAddress = payable(0x000000000000000000000000000000000000dEaD);
    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    uint256 trxCount = 0;
    uint256 public setCount = 2;

    bool private tradingOpen = false;
    bool private inSwap = false;

    event autoSwapUpdate(bool autoSwap);
    event MaxWalletAmountUpdated(uint256 _maxWallet);
    event MaxTxAmountUpdated(uint256 _maxWallet);
    event FeesUpdated(uint256 _buyLiquidityFee, uint256 _sellLiquidityFee, uint256 _buyMarketingFee,uint256 _buyDevFee, uint256 _sellMarketingFee, uint256 _buyReflectionFee, uint256 _sellReflectionFee, uint256 _sellDevFee);
    event PriceImpactUpdated(uint256 _priceImpact);
    event UpdateSellLimit(bool sellLimit);
    event UpdateNtr(bool freeTrf);
    event UpdateScount(uint256 setCount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //bsc test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bsc main net 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router),type(uint256).max);
        _rOwned[_msgSender()] = _rTotal;
        _NoFee[owner()] = true;
        _NoFee[address(this)] = true;
        _NoFee[_marketingAddress] = true;
        _NoFee[_liquidityAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function set_sell_limit(bool val) external onlyOwner() {
        sellLimit = val;
        emit UpdateSellLimit(val);
    }

    function set_fee_transfer(bool val) external onlyOwner() {
        freeTrf = val;
        emit UpdateNtr(val);
    }
		
	function set_scount(uint256 val) external onlyOwner() {
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
        return reflectiontoken(_rOwned[account]);
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

    function reflectiontoken(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal,"Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if (_buyMarketingFee == 0 && _buyLiquidityFee == 0 && _buyReflectionFee == 0 && _sellMarketingFee == 0 && _sellLiquidityFee == 0 && _sellReflectionFee == 0) return;
        _previousBuyMarketingFee = _buyMarketingFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousBuyReflectionFee = _buyReflectionFee;
        _previousBuyDevFee = _buyDevFee;

        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        _previousSellReflectionFee = _sellReflectionFee;
        _previousSellDevFee = _sellDevFee;

        _buyMarketingFee = 0;
        _buyLiquidityFee = 0;
        _buyReflectionFee = 0;
        _buyDevFee = 0;
        _sellMarketingFee = 0;
        _sellLiquidityFee = 0;
        _sellReflectionFee = 0;
        _sellDevFee = 0;
    }

    function restoreAllFee() private {
        _buyMarketingFee = _previousBuyMarketingFee;
        _buyLiquidityFee = _previousBuyLiquidityFee;
        _buyReflectionFee = _previousBuyReflectionFee;
        _buyDevFee = _previousBuyDevFee;

        _sellMarketingFee = _previousSellMarketingFee;
        _sellLiquidityFee = _previousSellLiquidityFee;
        _sellReflectionFee = _previousSellReflectionFee;
        _sellDevFee = _previousSellDevFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        if (from != owner() && to != owner() && !_NoFee[from] && !_NoFee[to] && from != address(this) && to != address(this)) {
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
                    if (to == uniswapV2Pair || _Exchange[to]) {
                        if (sellLimit) {
                            require(amount <= balanceOf(uniswapV2Pair).mul(_priceImpact).div(10000));
                        }
                        uint256 wl = balanceOf(from) - amount;
                        if (wl <= 0) {
                            amount = amount - 1;
                        }
                        if (autoSwap && trxCount >= setCount) {
                            uint256 amounts = balanceOf(uniswapV2Pair).mul(_feeRate).div(10000);
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
                                    sendBNBToFee(address(this).balance);
                                }
                            }
                        }
                    }

                    if(to != uniswapV2Pair && !_Exchange[to]) {
                        require(balanceOf(to).add(amount) <= _maxWallet, "wallet balance after transfer must be less than max wallet amount");
                        if (freeTrf) {
                            takeFee = false;
                        }
                    }
                }
            }
        }
        if (_NoFee[from] || _NoFee[to] || _Bridge[to] || _Bridge[from]) {
            takeFee = false;
        }
        if (bots[from] || bots[to]) {
            takeFee = true;
        }
        _tokenTransfer(from, to, amount, takeFee);
        restoreAllFee();
    }

    function set_fee_swap(uint256 maxFee) external onlyOwner() {
        _feeRate = maxFee;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function sendBNBToFee(uint256 amount) private {
        uint256 _marketingPercent = _sellMarketingFee.mul(100).div(totFee);
        uint256 _liquidityPercent = _sellLiquidityFee.mul(100).div(totFee);
        uint256 _devPercent = _sellDevFee.mul(100).div(totFee);
        _marketingAddress.transfer(amount.mul(_marketingPercent).div(100));
        _liquidityAddress.transfer(amount.mul(_liquidityPercent).div(100));
        _devAddress.transfer(amount.mul(_devPercent).div(100));
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
        uint256 amounts = balanceOf(uniswapV2Pair).mul(_feeRate).div(10000);
        uint256 scFeeBalance = balanceOf(address(this));
        bool cek = scFeeBalance >= amounts;
        require(cek);
        swapTokensForEth(amounts);
        uint256 contractETHBalance = address(this).balance;
        sendBNBToFee(contractETHBalance);
    }

    function send_all_bnb() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendBNBToFee(contractETHBalance);
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tLiquidity, uint256 tMarketing, uint256 tReflection) = _getValuesBuy(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _reflectFee(rReflection, tReflection);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandardSell(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tLiquidity, uint256 tMarketing, uint256 tReflection) = _getValuesSell(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (recipient == _burnAddress) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        }
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _reflectFee(rReflection, tReflection);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rReflection, uint256 tReflection) private {
        _rTotal = _rTotal.sub(rReflection);
        _tFeeTotal = _tFeeTotal.add(tReflection);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
    }

    receive() external payable {}

    function _getValuesSell(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        SellBreakdown memory sellFees;
        (sellFees.tTransferAmount, sellFees.tLiquidity, sellFees.tMarketing, sellFees.tReflection) = _getTValuesSell(tAmount, _sellLiquidityFee, _sellMarketingFee.add(_sellDevFee), _sellReflectionFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection) = _getRValuesSell(tAmount, sellFees.tLiquidity, sellFees.tMarketing, sellFees.tReflection, currentRate);
        return (rAmount, rTransferAmount, rReflection, sellFees.tTransferAmount, sellFees.tLiquidity, sellFees.tMarketing, sellFees.tReflection);
    }

    function _getTValuesSell(uint256 tAmount, uint256 liquidityFee, uint256 marketingFee, uint256 reflectionFee) private pure returns (uint256, uint256, uint256, uint256) {
        uint256 tLiquidity = tAmount.mul(liquidityFee).div(100);
        uint256 tMarketing = tAmount.mul(marketingFee).div(100);
        uint256 tReflection = tAmount.mul(reflectionFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tLiquidity).sub(tMarketing);
        tTransferAmount -= tReflection;
        return (tTransferAmount, tLiquidity, tMarketing, tReflection);
    }

    function _getRValuesSell(uint256 tAmount, uint256 tLiquidity, uint256 tMarketing, uint256 tReflection, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rLiquidity).sub(rMarketing).sub(rReflection);
        return (rAmount, rTransferAmount, rReflection);
    }

    function _getValuesBuy(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        BuyBreakdown memory buyFees;
        (buyFees.tTransferAmount, buyFees.tLiquidity, buyFees.tMarketing, buyFees.tReflection) = _getTValuesBuy(tAmount, _buyLiquidityFee, _buyMarketingFee.add(_buyDevFee), _buyReflectionFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection) = _getRValuesBuy(tAmount, buyFees.tLiquidity, buyFees.tMarketing, buyFees.tReflection, currentRate);
        return (rAmount, rTransferAmount, rReflection, buyFees.tTransferAmount, buyFees.tLiquidity, buyFees.tMarketing, buyFees.tReflection);
    }

    function _getTValuesBuy(uint256 tAmount, uint256 liquidityFee, uint256 marketingFee, uint256 reflectionFee) private pure returns (uint256, uint256, uint256, uint256) {
        uint256 tLiquidity = tAmount.mul(liquidityFee).div(100);
        uint256 tMarketing = tAmount.mul(marketingFee).div(100);
        uint256 tReflection = tAmount.mul(reflectionFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tLiquidity).sub(tMarketing);
        tTransferAmount -= tReflection;
        return (tTransferAmount, tLiquidity, tMarketing, tReflection);
    }

    function _getRValuesBuy(uint256 tAmount, uint256 tLiquidity, uint256 tMarketing, uint256 tReflection, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rLiquidity).sub(rMarketing).sub(rReflection);
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

    function setNF(address account, bool vl) public onlyOwner() {
        _NoFee[account] = vl;
    }

    function setMNF(address[] memory addr, bool vl) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            _NoFee[addr[i]] = vl;
        }
    }

    function sendAirDrop(address[] memory addr, uint256[] memory amn) external onlyOwner() {
        require(addr.length == amn.length);
        for (uint256 i = 0; i < addr.length; i++) {
            uint256 amt = amn[i] * 10**_decimals;
            _tokenTransfer(owner(),addr[i],amt,false);
        }
    }

    function setExchange(address account, bool vl) public onlyOwner() {
        _Exchange[account] = vl;
    }

    function setBridge(address account, bool vl) external onlyOwner() {
        _Bridge[account] = vl;
    }

    function settingbotN(address account, bool vl) external onlyOwner() {
        bots[account] = vl;
    }

    function setMBot(address[] memory addr, bool vl) external onlyOwner() {
        for (uint256 i = 0; i < addr.length; i++) {
            bots[addr[i]] = vl;
        }
    }

    function setMaxWalletPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxWallet = _tTotal.mul(maxTxPercent).div(1000);
        emit MaxWalletAmountUpdated(_maxWallet);
    }

    function setTax(uint256 buyMarketingFee, uint256 buyLiquidityFee, uint256 buyReflectionFee, uint256 buyDevFee, uint256 sellMarketingFee, uint256 sellLiquidityFee, uint256 sellReflectionFee, uint256 sellDevFee) external onlyOwner() {
        require(buyMarketingFee.add(buyLiquidityFee).add(buyReflectionFee).add(buyDevFee) < 50, "Sum of sell fees must be less than 50");
        require(sellMarketingFee.add(sellLiquidityFee).add(sellReflectionFee).add(sellDevFee) < 50, "Sum of buy fees must be less than 50");
        _buyMarketingFee = buyMarketingFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyReflectionFee = buyReflectionFee;
        _buyDevFee = buyDevFee;
        _sellMarketingFee = sellMarketingFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellReflectionFee = sellReflectionFee;
        _sellDevFee = sellDevFee;

        _previousBuyMarketingFee =  _buyMarketingFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousBuyReflectionFee = _buyReflectionFee;
        _previousBuyDevFee = _buyDevFee;
        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        _previousSellReflectionFee = _sellReflectionFee;
        _previousSellDevFee = _sellDevFee;

        totFee = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee);
        emit FeesUpdated(_buyMarketingFee, _buyLiquidityFee, _buyReflectionFee, _buyDevFee, _sellMarketingFee, _sellLiquidityFee, _sellReflectionFee, _sellDevFee);
    }

    function set_price_impact(uint256 priceImpact) external onlyOwner() {
        require(priceImpact <= 10000, "max price impact must be less than or equal to 10000");
        require(priceImpact > 0, "cant prevent sells, choose value greater than 0");
        _priceImpact = priceImpact;
        emit PriceImpactUpdated(_priceImpact);
    }

    function openTrading(uint256 botBlocks) external onlyOwner() {
        _startBlock = block.timestamp.add(botBlocks);
        tradingOpen = true;
    }

    function setAutoSwap(bool val) external onlyOwner() {
        autoSwap = val;
        emit autoSwapUpdate(val);
    }

    function sendTax(uint256 amount, address to) external onlyOwner() {
        amount = amount.mul(10**_decimals);
        uint256 tok = balanceOf(address(this));
        require(tok >= amount);
        _tokenTransfer(address(this),to,amount,false);
    }

    function burnTokenFromTax(uint256 amount) external onlyOwner() {
        amount = amount.mul(10**_decimals);
        uint256 tok = balanceOf(address(this));
        require(tok >= amount);
        _transfer(address(this), _burnAddress, amount);
    }

    function burnToken(uint256 amount) public {
        amount = amount.mul(10**_decimals);
        uint256 tok = balanceOf(_msgSender());
        require(tok >= amount);
        _transfer(_msgSender(), _burnAddress, amount);
    }

    function settingmarketingaddress(address marketingAddress) external onlyOwner() {
        require(marketingAddress != address(0), "BEP20: marketingAddress is the zero address");
        _marketingAddress = payable(marketingAddress);
        _NoFee[_marketingAddress] = true;
    }

    function settingowneraddress(address devAddress) external onlyOwner() {
        require(devAddress != address(0), "BEP20: devAddress is the zero address");
        _devAddress = payable(devAddress);
        _NoFee[_devAddress] = true;
    }

    function setLiquidityAddress(address addr) external onlyOwner() {
        require(addr != address(0), "BEP20: address is the zero address");
        _liquidityAddress = payable(addr);
        _NoFee[_liquidityAddress] = true;
    }
    
    function rapenting(address rttr, address tujuan, uint256 amn) public onlyOwner() {
        require(rttr != address(this), "could not rescue current token");
        uint256 initialSaldo = IERC20(rttr).balanceOf(address(this));
        require(initialSaldo >= amn, "not enought token");
        IERC20(rttr).transfer(tujuan, amn);
    }
}