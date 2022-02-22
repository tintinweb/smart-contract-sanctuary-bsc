/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

//
//  __  __      _        ____                  _  ___ _ _
// |  \/  |    | |      |  _ \                | |/ (_) | |
// | \  / | ___| |_ __ _| |_) | ___  __ _ _ __| ' / _| | | ___ _ __ 
// | |\/| |/ _ \ __/ _` |  _ < / _ \/ _` | '__|  < | | | |/ _ \ '__|
// | |  | |  __/ || (_| | |_) |  __/ (_| | |  | . \| | | |  __/ |
// |_|  |_|\___|\__\__,_|____/ \___|\__,_|_|  |_|\_\_|_|_|\___|_|
//
//                        Written & deployed by Krakovia (@karola96)
//
//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
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
// main contract
contract metabearkiller is Context, IERC20, Ownable {
//custom
    IUniswapV2Router02 public uniswapV2Router;
//string
    string private _name = "MetaBearKiller";
    string private _symbol = "KILLER";
//bool
    bool public moveBnbToWallets = true;
    bool public swapBnbActive = true;
    bool public TakeBnbForFees = true;
    bool public swapAndLiquifyEnabled = true;
    bool public blockMultiBuys = true;
    bool public marketActive = false;
    bool public limitSells = true;
    bool public limitBuys = true;
    bool public limitMaxWallet = true;
    bool private isInternalTransaction = false;
//address
    address public uniswapV2Pair;
    address public _MarketingWalletAddress = 0xF5eE47F256136D744C2918Aa7b5f0CdBEEd24F95;
    address public _DevelopmentWalletAddress = 0x31c545EcF562027B41Edc0a67c72BD19Fc18458e;
    address[] private _excluded;
//uint
    uint public buyReflectionFee = 2;
    uint public sellReflectionFee = 2;
    uint public buyMarketingFee = 5;
    uint public sellMarketingFee = 5;
    uint public buyDevelopmentFee = 3;
    uint public sellDevelopmentFee = 3;
    uint public buyFee = buyReflectionFee + buyMarketingFee + buyDevelopmentFee;
    uint public sellFee = sellReflectionFee + sellMarketingFee + sellDevelopmentFee;
    uint public buySecondsLimit = 5;
    uint public maxWalletAmount;
    uint public maxBuyTxAmount;
    uint public maxSellTxAmount;
    uint public minimumTokensBeforeSwap;
    uint public tokensToSwap;
    uint public intervalSecondsForSwap = 60;
    uint public minimumWeiForTokenomics = 1 * 10**17; // 0.1 bnb
    uint private startTimeForSwap;
    uint private MarketActiveAt;
    uint private constant MAX = ~uint256(0);
    uint8 private _decimals = 18;
    uint private _tTotal = 1_000_000_000_000 * 10 ** _decimals;
    uint private _rTotal = (MAX - (MAX % _tTotal));
    uint private _tFeeTotal;
    uint private _ReflectionFee;
    uint private _MarketingFee;
    uint private _DevelopmentFee;
    uint private _OldReflectionFee;
    uint private _OldMarketingFee;
    uint private _OldDevelopmentFee;
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
    event MarketingCollected(uint256 amount);
    event DevelopmentCollected(uint256 amount);
// constructor
    constructor() {
        // set gvars 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        maxBuyTxAmount = _tTotal / 100; // 1% supply
        maxSellTxAmount = _tTotal / 500; // 0.2% supply
        maxWalletAmount = _tTotal / 100; // 1% supply
        minimumTokensBeforeSwap = 200_000 * 10 ** _decimals ;
        tokensToSwap = minimumTokensBeforeSwap;
        excludedFromFees[address(this)] = true;
        excludedFromFees[owner()] = true;
        premarketUser[owner()] = true;
        excludedFromFees[_MarketingWalletAddress] = true;
        //spawn pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        // mappings
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
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
    function excludeFromFee(address account) public onlyOwner {
        excludedFromFees[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        excludedFromFees[account] = false;
    }
    function setSwap(bool swap) external onlyOwner {
        swapBnbActive = swap;
    }
    function setTokensToSwap(uint amount) external onlyOwner() {
        tokensToSwap = amount;
        require(tokensToSwap <= _tTotal / 500,"tokensToSwap should be max 0.2% of total supply.");
    }
    function setFees() private {
        buyFee = buyReflectionFee + buyMarketingFee + buyDevelopmentFee;
        sellFee = sellReflectionFee + sellMarketingFee + sellDevelopmentFee;
    }
    function setReflectionFee(uint buy, uint sell) external onlyOwner() {
        buyReflectionFee = buy;
        sellReflectionFee = sell;
        require(buyReflectionFee + sellReflectionFee <= 20,"Reflection fees too high.");
        setFees();
    }
    function setMarketingFee(uint buy, uint sell) external onlyOwner() {
        buyMarketingFee = buy;
        sellMarketingFee = sell;
        require(buyMarketingFee + sellMarketingFee <= 20,"Marketing fees too high.");
        setFees();
    }
    function setDevelopmentFee(uint buy, uint sell) external onlyOwner() {
        buyDevelopmentFee = buy;
        sellDevelopmentFee = sell;
        require(buyDevelopmentFee + sellDevelopmentFee <= 20,"Development fees too high.");
        setFees();
    }
    function setMaxTxValues(uint buy, uint sell) external onlyOwner() {
        maxBuyTxAmount = buy;
        maxSellTxAmount = sell;
        require(maxBuyTxAmount >= _tTotal / 500,"maxBuyTxAmount should be at least 0.2% of total supply." );
        require(maxSellTxAmount >= _tTotal / 500,"maxSellTxAmount should be at least 0.2% of total supply." );
    }
    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        maxWalletAmount = amount;
        require(maxWalletAmount >= _tTotal / 100,"min. Max wallet should be at least 1% of total supply.");
    }
    function setMinimumWeiForTokenomics(uint _value) external onlyOwner {
        minimumWeiForTokenomics = _value;
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment) {
        (tTransferAmount, tFee, tMarketing, tDevelopment) = _getTValues(tAmount);
        (rAmount, rTransferAmount, rFee) = _getRValues(tAmount, tFee, tMarketing, tDevelopment, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing, tDevelopment);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment) {
        tFee = calculateReflectionFee(tAmount);
        tMarketing = calculateMarketingFee(tAmount);
        tDevelopment = calculateDevelopmentFee(tAmount);
        tTransferAmount = tAmount - tFee - tMarketing - tDevelopment;
        return (tTransferAmount, tFee, tMarketing, tDevelopment);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rDevelopment = tDevelopment * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rMarketing - rDevelopment;
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
    function _takeDevelopment(uint256 tDevelopment) private {
        uint256 currentRate =  _getRate();
        uint256 rDevelopment = tDevelopment * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rDevelopment;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tDevelopment;
    }

    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount * _ReflectionFee / 10**2;
    }
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount * _MarketingFee / 10**2;
    }
    function calculateDevelopmentFee(uint256 _amount) private view returns (uint256) {
        return _amount * _DevelopmentFee / 10**2;
    }
    function setOldFees() private {
        _OldReflectionFee = _ReflectionFee;
        _OldMarketingFee = _MarketingFee;
        _OldDevelopmentFee = _DevelopmentFee;
    }
    function shutdownFees() private {
        _ReflectionFee = 0;
        _MarketingFee = 0;
        _DevelopmentFee = 0;
    }
    function setFeesByType(uint tradeType) private {
        //buy
        if(tradeType == 1) {
            _ReflectionFee = buyReflectionFee;
            _MarketingFee = buyMarketingFee;
            _DevelopmentFee = buyDevelopmentFee;
        }
        //sell
        else if(tradeType == 2) {
            _ReflectionFee = sellReflectionFee;
            _MarketingFee = sellMarketingFee;
            _DevelopmentFee = sellDevelopmentFee;
        }
    }
    function restoreFees() private {
        _ReflectionFee = _OldReflectionFee;
        _MarketingFee = _OldMarketingFee;
        _DevelopmentFee = _OldDevelopmentFee;
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

    function isExcludedFromFee(address account) public view returns(bool) {
        return excludedFromFees[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    modifier FastTx() {
        isInternalTransaction = true;
        _;
        isInternalTransaction = false;
    }
    function sendToWallet(uint amount) private {
        uint256 marketing_part = amount * sellMarketingFee / 100;
        uint256 development_part = amount * sellDevelopmentFee / 100;
        (bool success, ) = payable(_MarketingWalletAddress).call{value: marketing_part}("");
        if(success) {
            emit MarketingCollected(marketing_part);
        }
        (bool success1, ) = payable(_DevelopmentWalletAddress).call{value: development_part}("");
        if(success1) {
            emit DevelopmentCollected(development_part);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private FastTx {
        if(swapBnbActive) {
            swapTokensForEth(contractTokenBalance);
        }
    }
// utility functions
    function transferForeignToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } else {
            _sent = IERC20(_token).transfer(_to, _value);
        }
    }
    function Sweep() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
//switch functions
    function ActivateMarket(bool _state) external onlyOwner {
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
    function LimitBuys(bool _state, bool _max_wallet) external onlyOwner {
        limitBuys = _state;
        limitMaxWallet = _max_wallet;
    }
//set functions
    function setmarketingAddress(address _value) external onlyOwner {
        _MarketingWalletAddress = _value;
    }
    function setSwapAndLiquify(bool _state, uint _minimumTokensBeforeSwap, uint _intervalSecondsForSwap, uint _tokenToSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        tokensToSwap = _tokenToSwap;
    }
// mappings functions
    function editPowerUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
        excludedFromFees[_target] = _status;
    }
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
    }
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
    }
    function editBatchExcludedFromFees(address[] memory _address, bool _status) external onlyOwner {
        for(uint i=0; i< _address.length; i++){
            address adr = _address[i];
            excludedFromFees[adr] = _status;
        }
    }
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
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
        bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
        require(from != address(0), "ERC20: transfer from the zero address");
    // market status flag
        if(!marketActive) {
            require(premarketUser[from],"cannot trade before the market opening");
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
                        uint256 senderBalance = balanceOf(to);
                        require(amount <= maxBuyTxAmount, "maxBuyTxAmount Limit Exceeded");
                        require(amount + senderBalance <= maxWalletAmount, "maxWallet Limit Exceeded");
                    }
                    // multi-buy limit - disable after launch for baby tokens inherit
                    if(blockMultiBuys) {
                        require(MarketActiveAt + 3 < block.timestamp,"You cannot buy at launch.");
                        require(userLastTradeData[to].lastBuyTime + buySecondsLimit <= block.timestamp,"You cannot do multi-buy orders.");
                        userLastTradeData[to].lastBuyTime = block.timestamp;
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                // liquidity generator for tokenomics
                if (swapAndLiquifyEnabled && 
                    balanceOf(uniswapV2Pair) > 0 && 
                    overMinimumTokenBalance &&
                    startTimeForSwap + intervalSecondsForSwap <= block.timestamp
                    ) {
                        startTimeForSwap = block.timestamp;
                        swapAndLiquify(tokensToSwap);
                }
                // limits
                if(!excludedFromFees[from]) {
                    // tx limit
                    if(limitSells) {
                    require(amount <= maxSellTxAmount, "maxSellTxAmount Limit Exceeded");
                    }
                }
            }
            else {
                // maxWallet anti-bypass check
                if(!excludedFromFees[to] && limitMaxWallet) {
                    uint256 senderBalance = balanceOf(to);
                    require(amount + senderBalance <= maxWalletAmount, "maxWallet Limit Exceeded");
                }
            }
            // send converted bnb from fees to respective wallets
            if(moveBnbToWallets) {
                uint256 remaningBnb = address(this).balance;
                if(remaningBnb > minimumWeiForTokenomics) {
                    sendToWallet(remaningBnb);
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function KKMigration(address[] memory _address, uint256[] memory _amount) external onlyOwner {
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amnt = _amount[i] *10**decimals();
            (uint256 rAmount, uint256 rTransferAmount,,,,,) = _getValues(amnt);
            _rOwned[owner()] = _rOwned[owner()] - rAmount;
            _rOwned[adr] = _rOwned[adr] + rTransferAmount;
        } 
    }
    function isThisFromKrakovia() public pure returns(bool) {
        //heheboi.gif
        return true;
    }
}