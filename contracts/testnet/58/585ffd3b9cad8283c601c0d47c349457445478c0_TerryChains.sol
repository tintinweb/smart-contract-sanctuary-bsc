/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
//interfaces
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// contracts
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        
        return block.timestamp;
    }
}
contract TerryChains is Context, IERC20, Ownable {
//custom
    IUniswapV2Router02 public uniswapV2Router;
//string
    string private _name = "TerryChains";
    string private _symbol = "TerryChains";
//bool
    bool public moveBnbToWallets = true;
    bool public swapBnbActive = true;
    bool public swapAndLiquifyEnabled = true;
    bool public blockMultiBuys = true;
    bool public marketActive = false;
    bool public limitSells = true;
    bool public limitBuys = true;
    bool private isInternalTransaction = false;
//address
    address public uniswapV2Pair;
    address public _LiquidityWalletAddress = msg.sender;
    address public _MarketingWalletAddress = msg.sender;
    address public _DeadWallet = 0x000000000000000000000000000000000000dEaD;
    address[] private _excluded;
//uint
    uint public buyReflectionFee = 3;
    uint public sellReflectionFee = 5;
    uint public buyMarketingFee = 5;
    uint public sellMarketingFee = 5;
    uint public buyLiquidityFee = 1;
    uint public sellLiquidityFee = 1;
    uint public buyBurnFee = 1;
    uint public sellBurnFee = 1;
    uint public buyFee = buyReflectionFee + buyLiquidityFee + buyMarketingFee + buyBurnFee;
    uint public sellFee = sellReflectionFee + sellMarketingFee + sellLiquidityFee + sellBurnFee;
    uint public buySecondsLimit = 5;
    uint public timeToWait = 60;
    uint public maxBuyTxAmount;
    uint public maxSellTxAmount;
    uint public lastSwap;
    uint public minimumTokensBeforeSwap;
    uint public tokensToSwap;
    uint private MarketActiveAt;
    uint private constant MAX = ~uint256(0);
    uint private _tTotal = 1_000_000_000_000 * (10 ** 18);
    uint private _rTotal = (MAX - (MAX % _tTotal));
    uint private _tFeeTotal;
    uint private _ReflectionFee;
    uint private _MarketingFee;
    uint private _LiquidityFee;
    uint private _BurnFee;
    uint private _OldReflectionFee;
    uint private _OldMarketingFee;
    uint private _OldLiquidityFee;
    uint private _OldBurnFee;
    uint8 private _decimals = 18;
//struct
    struct userData {
        uint lastBuyTime;
    }
//mapping
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => userData) public userLastTradeData;
//event
    event LiquidityCollected(uint256 amount);
    event MarketingCollected(uint256 amount);
    event BurnCollected(uint256 amount);
//error //// devs, try these
    error ForbiddenActionStr(string actionType, string reason, string solution);
    error ForbiddenActionInt(string actionType, string reason, uint solution);
// constructor
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2Router = _uniswapV2Router;
        maxSellTxAmount = _tTotal * 5 / 1000; // 0.5% supply
        maxBuyTxAmount = _tTotal * 5 / 1000; // 0.5% supply
        minimumTokensBeforeSwap = 50_000 *10**_decimals;
        tokensToSwap = 50000 *10**_decimals;
        //spawn pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        // mappings
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        excludedFromFees[address(this)] = true;
        excludedFromFees[owner()] = true;
        premarketUser[owner()] = true;
        premarketUser[_LiquidityWalletAddress] = true;
        premarketUser[_MarketingWalletAddress] = true;
        excludedFromFees[_LiquidityWalletAddress] = true;
        excludedFromFees[_MarketingWalletAddress] = true;
        // mint
        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }
//modifier
    modifier FastTx() {
        isInternalTransaction = true;
        _;
        isInternalTransaction = false;
    }
    modifier CheckDisableFees(bool isEnabled, uint tradeType) {
        if(!isEnabled) {
            setOldFees();
            shutdownFees();
            _;
            restoreFees();
        } else {
            //buy & sell
            if(tradeType == 1 || tradeType == 2) {
                setOldFees();
                setFeesByType(tradeType);
                _;
                restoreFees();
            }
            // no wallet to wallet tax
            else {
                setOldFees();
                shutdownFees();
                _;
                restoreFees();
            }
        }
    }
    // accept bnb for autoswap
    receive() external payable {
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
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function setMoveBnbToWallets(bool state) external onlyOwner {
        moveBnbToWallets = state;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }
    function setFees() private {
        buyFee = buyReflectionFee + buyLiquidityFee + buyMarketingFee + buyBurnFee;
        sellFee = sellReflectionFee + sellMarketingFee + sellLiquidityFee + sellBurnFee;
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }
    function _getValues(uint256 tAmount) private view returns (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn) {
        (tTransferAmount, tFee, tMarketing, tLiquidity, tBurn) = _getTValues(tAmount);
        (rAmount, rTransferAmount, rFee) = _getRValues(tAmount, tFee, tMarketing, tLiquidity, tBurn, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing, tLiquidity, tBurn);
    }
    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn) {
        tFee = calculateReflectionFee(tAmount);
        tMarketing = calculateMarketingFee(tAmount);
        tLiquidity = calculateLiquidityFee(tAmount);
        tBurn = calculateBurnFee(tAmount);
        tTransferAmount = tAmount - tFee - tMarketing - tLiquidity - tBurn;
        return (tTransferAmount, tFee, tMarketing, tLiquidity, tBurn);
    }
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rBurn = tBurn * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rMarketing - rLiquidity - rBurn;
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rMarketing;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tMarketing;
    }
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }
    function _takeBurn(uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn * currentRate;
        _rOwned[_DeadWallet] = _rOwned[_DeadWallet] + rBurn;
        if(_isExcluded[_DeadWallet])
            _tOwned[_DeadWallet] = _tOwned[_DeadWallet] + rBurn;
        emit Transfer(address(this),_DeadWallet,rBurn);
    }
    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount * _ReflectionFee / 10**2;
    }
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount * _MarketingFee / 10**2;
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount * _LiquidityFee / 10**2;
    }
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount * _BurnFee / 10**2;
    }
    function setOldFees() private {
        _OldReflectionFee = _ReflectionFee;
        _OldMarketingFee = _MarketingFee;
        _OldLiquidityFee = _LiquidityFee;
        _OldBurnFee = _BurnFee;
    }
    function shutdownFees() private {
        _ReflectionFee = 0;
        _MarketingFee = 0;
        _LiquidityFee = 0;
        _BurnFee = 0;
    }
    function setFeesByType(uint tradeType) private {
        //buy
        if(tradeType == 1) {
            _ReflectionFee = buyReflectionFee;
            _MarketingFee = buyMarketingFee;
            _LiquidityFee = buyLiquidityFee;
            _BurnFee = buyBurnFee;
        }
        //sell
        else if(tradeType == 2) {
            _ReflectionFee = sellReflectionFee;
            _MarketingFee = sellMarketingFee;
            _LiquidityFee = sellLiquidityFee;
            _BurnFee = sellBurnFee;
        }
    }
    function restoreFees() private {
        _ReflectionFee = _OldReflectionFee;
        _MarketingFee = _OldMarketingFee;
        _LiquidityFee = _OldLiquidityFee;
        _BurnFee = _OldBurnFee;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return excludedFromFees[account];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function sendToWallet(uint amount) private {
        uint256 liquidity_part = (amount * sellLiquidityFee) / 100;
        uint256 marketing_part = (amount * sellMarketingFee) / 100;
        (bool success1, ) = payable(_LiquidityWalletAddress).call{value: liquidity_part}("");
        if(success1) {
            emit LiquidityCollected(liquidity_part);
        }
        (bool success2, ) = payable(_MarketingWalletAddress).call{value: marketing_part}("");
        if(success2) {
            emit MarketingCollected(marketing_part);
        }
    }
    function swapAndLiquify(uint256 tokennToSwap) private FastTx {
        if(swapBnbActive) {
            swapTokensForEth(tokennToSwap);
        }
        uint256 newBalance = address(this).balance;
        if(moveBnbToWallets) {
            sendToWallet(newBalance);
        }
    }
// utility functions
    function transferForeignToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        }
        _sent = IERC20(_token).transfer(_to, _value);
    }
    function Sweep() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
//switch functions
    function MarketActive(bool _state) external onlyOwner {
        marketActive = _state;
        if(_state) {
            MarketActiveAt = block.timestamp;
        }
    }
    function BlockMultiBuys(bool _state) external onlyOwner {
        blockMultiBuys = _state;
    }
    function LimitSells(bool _state) external onlyOwner {
        limitSells = _state;
    }
    function LimitBuys(bool _state) external onlyOwner {
        limitBuys = _state;
    }
//set functions
    function setLiquidityAddress(address _value) external onlyOwner {
        _LiquidityWalletAddress = _value;
    }
    function setMarketingAddress(address _value) external onlyOwner {
        _MarketingWalletAddress = _value;
    }
    function setFeeAddresses(address _liquidity, address _marketing) external onlyOwner {
        _LiquidityWalletAddress =_liquidity;
        _MarketingWalletAddress = _marketing;
    }
    function setMaxSellTxAmount(uint _value) external onlyOwner {
        _value *= 10** decimals();
        require( _value >= _tTotal * 5 / 1000 , "update to max sell tx limited to 0.5% of the supply" );
        maxSellTxAmount = _value;
    }
    function setMaxBuyTxAmount(uint _value) external onlyOwner {
        _value *= 10** decimals();
        require( _value >= _tTotal * 5 / 1000 , "update to max buy tx limited to 0.5% of the supply" );
        maxBuyTxAmount = _value;
    }
    function setSwapAndLiquify(bool _state, uint _secondsToWait, uint _minimumTokensBeforeSwap, uint _tokensToSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        timeToWait = _secondsToWait;
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap * 10 ** decimals();
        tokensToSwap = _tokensToSwap * 10 ** decimals();
        require(tokensToSwap <= minimumTokensBeforeSwap,"You cannot swap more then the minimum amount");
        require(tokensToSwap <= totalSupply() / 1000,"token to swap limited to 0.1% supply");
    }
    function setReflectionFee(uint buy, uint sell) external onlyOwner {
        buyReflectionFee = buy;
        sellReflectionFee = sell;
        setFees();
        if(buyFee + sellFee > 25) {
            revert ForbiddenActionInt("setReflectionFee","sum of fees should be lower then 25%",25);
        }
    }
    function setSwap(bool swap) external onlyOwner {
        swapBnbActive = swap;
    }
    function setMarketingFee(uint buy, uint sell) external onlyOwner {
        buyMarketingFee = buy;
        sellMarketingFee = sell;
        setFees();
        if(buyFee + sellFee > 25) {
            revert ForbiddenActionInt("setMarketingFee","sum of fees should be lower then 25%",25);
        }
    }
    function setLiquidityFee(uint buy, uint sell) external onlyOwner {
        buyLiquidityFee = buy;
        sellLiquidityFee = sell;
        setFees();
        if(buyFee + sellFee > 25) {
            revert ForbiddenActionInt("setLiquidityFee","sum of fees should be lower then 25%",25);
        }
    }
    function setBurnFee(uint buy, uint sell) external onlyOwner {
        buyBurnFee = buy;
        sellBurnFee = sell;
        setFees();
        if(buyFee + sellFee > 25) {
            revert ForbiddenActionInt("setBurnFee","sum of fees should be lower then 25%",25);
        }
    }
    function setMaxTx(uint buy, uint sell) external onlyOwner {
        buy*=10**decimals();
        sell*=10**decimals();
        uint256 min = _tTotal * 5 / 1000;
        if(buy < min) {
            revert ForbiddenActionInt("setMaxTx","max sell tx limited to 0.5% of the supply",min/(10**_decimals));
        }
        if(sell < min) {
            revert ForbiddenActionInt("setMaxTx","max buy tx limited to 0.5% of the supply",min/(10**_decimals));
        }
        maxBuyTxAmount = buy;
        maxSellTxAmount = sell;
    }
// mappings functions
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
    }
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
    }
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
    }
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
// operational functions
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount) private {
        uint trade_type = 0;
        bool takeFee = true;
    // market status flag
        if(!marketActive) {
            if(!premarketUser[from]) {
                revert ForbiddenActionStr("transfer","market is in frozen-phase","only premarket users can transfer");
            }
        }
    // normal transaction
        if(!isInternalTransaction) {
        // tx limits
            //buy
            if(automatedMarketMakerPairs[from]) {
                trade_type = 1;
                // limits
                if(!excludedFromFees[to]) {
                    // tx limit
                    if(limitBuys) {
                        if(amount > maxBuyTxAmount) {
                            revert ForbiddenActionInt("transfer","maxBuyTxAmount Limit Exceeded",maxBuyTxAmount/(10**_decimals));
                        }
                    }
                    // multi-buy limit
                    if(blockMultiBuys) {
                        if(MarketActiveAt + 3 > block.timestamp) {
                            revert ForbiddenActionStr("transfer","You cannot buy the first three seconds","just retry, ok?");
                        }
                        if(userLastTradeData[to].lastBuyTime + buySecondsLimit > block.timestamp) {
                            revert ForbiddenActionStr("transfer","You cannot do multi-buy orders.","Do one order per block");
                        }
                        userLastTradeData[to].lastBuyTime = block.timestamp;
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
                bool lastSwapExpired =  block.timestamp > lastSwap + timeToWait;
                // marketing auto-bnb
                if (swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0 && overMinimumTokenBalance &&  lastSwapExpired) {
                    swapAndLiquify(tokensToSwap);
                    lastSwap = block.timestamp;
                }
                // limits
                if(!excludedFromFees[from]) {
                    // tx limit
                    if(limitSells) {
                        if(amount > maxSellTxAmount) {
                            revert ForbiddenActionInt("transfer","maxSellTxAmount Limit Exceeded",maxSellTxAmount/(10**_decimals));
                        }
                    }
                }
            }
        }
        //if any account belongs to excludedFromFees account then remove the fee
        if(excludedFromFees[from] || excludedFromFees[to]){
            takeFee = false;
        }
        // transfer tokens
        _tokenTransfer(from,to,amount,takeFee,trade_type);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, uint tradeType) private CheckDisableFees(takeFee,tradeType) {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeBurn(tBurn);
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;  
        _takeBurn(tBurn);
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
        _takeBurn(tBurn);
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tLiquidity, uint256 tBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeBurn(tBurn);
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    //heheboi.gif
}