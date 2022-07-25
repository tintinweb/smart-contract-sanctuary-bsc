/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

//SPDX-License-Identifier: MIT
/*
  |   |   _ \ __ __|  __ \   
  |   |  |   |   |    |   | 
  ___ |  |   |   |    |   | 
 _|  _| \___/   _|   ____/  
       /     \
      ((     ))
  ===  \\_v_//  ===
    ====)_^_(====
    ===/ O O \===
    = | /_ _\ | =
   =   \/_ _\/   =
        \_ _/
        (o_o)
         VwV
Only one house will sit on the IRON THRONE, and it will be the Blood of my Blood and a Name of thy own…House Of The Dragon. 

Telegram: t.me/HouseOfTheDragonBSC

Website: www.houseofthedragonbsc.com                     
 */
// o/
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
// main contract
contract  House_Of_The_Dragon is Context, IERC20, Ownable {

//custom
    IUniswapV2Router02 public uniswapV2Router;
//string
    string private _name = "House Of The Dragon";
    string private _symbol = "HOTD";
//bool
    bool public moveBnbToWallets = true;
    bool public swapAndLiquifyEnabled = true;
    bool public marketActive = false;
    bool public limitActive = true;
    bool public buyTimeLimit = true;
    bool private isInternalTransaction = false;
//address
    address public uniswapV2Pair;
    address public _MarketingWalletAddress = 0xa81cb051174A82a7AeDe510d4F2E58b5C6FC216C;
    address public _DevelopmentWalletAddress = 0x0aa26d99Df08020330FA2a92C314b93AE96D7eF7;
    address public _Nft_treasuryWalletAddress = 0x3214c52a4d0ecf421E8Ec7812b565194b5302f3E;
    address public _BuybackWalletAddress = 0x9C88b796B4fda40212e647a1F8607C908E95072d;
    address[] private _excluded;

//uint
    uint public buyReflectionFee = 1;
    uint public sellReflectionFee = 1;
    uint public buyMarketingFee = 5;
    uint public sellMarketingFee = 5;
    uint public buyDevelopmentFee = 2;
    uint public sellDevelopmentFee = 2;
    uint public buyNft_treasuryFee = 1;
    uint public sellNft_treasuryFee = 1;
    uint public buyBuybackFee = 3;
    uint public sellBuybackFee = 3;
    uint public buyFee = buyReflectionFee + buyMarketingFee + buyDevelopmentFee + buyNft_treasuryFee + buyBuybackFee;
    uint public sellFee = sellReflectionFee + sellMarketingFee + sellDevelopmentFee + sellNft_treasuryFee + sellBuybackFee;
    uint public buySecondsLimit = 5;
    uint public maxBuyTx;
    uint public maxSellTx;
    uint public maxWallet;
    uint public intervalSecondsForSwap = 4;
    uint public minimumWeiForTokenomics = 1 * 10**14; // 0.0001 bnb
    uint private startTimeForSwap;
    uint private MarketActiveAt;
    uint private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint private _tTotal = 100_000_000_000 * 10 ** _decimals;
    uint private _rTotal = (MAX - (MAX % _tTotal));
    uint private _tFeeTotal;
    uint private _ReflectionFee;
    uint private _MarketingFee;
    uint private _DevelopmentFee;
    uint private _Nft_treasuryFee;
    uint private _BuybackFee;
    uint private _OldReflectionFee;
    uint private _OldMarketingFee;
    uint private _OldDevelopmentFee;
    uint private _OldNft_treasuryFee;
    uint private _OldBuybackFee;

//mapping
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint) public userLastBuy;
//event
    event MarketingCollected(uint256 amount);
    event DevelopmentCollected(uint256 amount);
    event NftTreasuryCollected(uint256 amount);
    event BuyBackCollected(uint256 amount);
    event ExcludedFromFees(address indexed user, bool state);
    event SwapSystemChanged(bool status, uint256 intervalSecondsToWait);
    event MoveBnbToWallets(bool state);
    event LimitChanged(uint maxsell, uint maxbuy, uint maxwallt);
// constructor
    constructor() {
        // set gvars
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        excludedFromFees[address(this)] = true;
        excludedFromFees[owner()] = true;
        premarketUser[owner()] = true;
        excludedFromFees[_MarketingWalletAddress] = true;
        excludedFromFees[_Nft_treasuryWalletAddress] = true;
        excludedFromFees[_BuybackWalletAddress] = true;

        //spawn pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        // mappings
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        _rOwned[owner()] = _rTotal;
        maxBuyTx = _tTotal / 100; // 1%
        maxSellTx = (_tTotal / 100) / 2; // 0.5%
        maxWallet = (_tTotal * 2) / 100; // 2%
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
            (uint256 rAmount,,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }
    function setFees() private {
        buyFee = buyReflectionFee + buyMarketingFee + buyDevelopmentFee + buyNft_treasuryFee;
        sellFee = sellReflectionFee + sellMarketingFee + sellDevelopmentFee + sellNft_treasuryFee;
    }

    function excludeFromReward(address account) external onlyOwner() {
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
    function setMoveBnbToWallets(bool state) external onlyOwner {
        moveBnbToWallets = state;
        emit MoveBnbToWallets(state);
    }
    function excludeFromFee(address account) external onlyOwner {
        excludedFromFees[account] = true;
        emit ExcludedFromFees(account,true);
    }
    function includeInFee(address account) external onlyOwner {
        excludedFromFees[account] = false;
        emit ExcludedFromFees(account,false);
    }
    function set_Fees(bool isBuy, uint reflection, uint marketing, uint development, uint nftreasury, uint bback) public onlyOwner{
        require(reflection+marketing+development+nftreasury+bback <= 20, "Fees too high");
        if(isBuy == true){
            buyReflectionFee = reflection;
            buyMarketingFee = marketing;
            buyDevelopmentFee = development;
            buyNft_treasuryFee = nftreasury;
            buyBuybackFee = bback;
        }else if(isBuy == false){
            sellReflectionFee = reflection;
            sellMarketingFee = marketing;
            sellDevelopmentFee = development;
            sellNft_treasuryFee = nftreasury;
            sellBuybackFee = bback;
        }
        setFees();
    }
    function setMinimumWeiForTokenomics(uint _value) external onlyOwner {
        minimumWeiForTokenomics = _value;
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,
                                                               uint256 tTransferAmount, uint256 tFee, uint256 tMarketing,
                                                               uint256 tDevelopment, uint256 tNft_treasury, uint256 tBuyback) {
        (tTransferAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback) = _getTValues(tAmount);
        (rAmount, rTransferAmount, rFee) = _getRValues(tAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_treasury, uint256 tBuyback) {
        tFee = calculateReflectionFee(tAmount);
        tMarketing = calculateMarketingFee(tAmount);
        tDevelopment = calculateDevelopmentFee(tAmount);
        tNft_treasury = calculateNft_treasuryFee(tAmount);
        tBuyback = calculateBuybackFee(tAmount);
        tTransferAmount = tAmount - tFee - tMarketing - tDevelopment - tNft_treasury - tBuyback;
        return (tTransferAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_treasury, uint256 tBuyback, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rDevelopment = tDevelopment * currentRate;
        uint256 rNft_treasury = tNft_treasury * currentRate;
        uint rBuyback = tBuyback * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rMarketing - rDevelopment - rNft_treasury - rBuyback;
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
    function _takeNft_treasury(uint256 tNft_treasury) private {
        uint256 currentRate =  _getRate();
        uint256 rNft_treasury = tNft_treasury * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rNft_treasury;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tNft_treasury;
    }
    function _takeBuyback(uint256 tBuyback) private {
        uint256 currentRate =  _getRate();
        uint256 rBuyback = tBuyback * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rBuyback;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tBuyback;
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
    function calculateNft_treasuryFee(uint256 _amount) private view returns (uint256) {
        return _amount * _Nft_treasuryFee / 10**2;
    }
    function calculateBuybackFee(uint256 _amount) private view returns (uint256) {
        return _amount * _BuybackFee / 10**2;
    }
    function setOldFees() private {
        _OldReflectionFee = _ReflectionFee;
        _OldMarketingFee = _MarketingFee;
        _OldDevelopmentFee = _DevelopmentFee;
        _OldNft_treasuryFee = _Nft_treasuryFee;
        _OldBuybackFee = _BuybackFee;
    }
    function shutdownFees() private {
        _ReflectionFee = 0;
        _MarketingFee = 0;
        _DevelopmentFee = 0;
        _Nft_treasuryFee = 0;
        _BuybackFee = 0;
    }
    function setFeesByType(uint tradeType) private {
        //buy
        if(tradeType == 1) {
            _ReflectionFee = buyReflectionFee;
            _MarketingFee = buyMarketingFee;
            _DevelopmentFee = buyDevelopmentFee;
            _Nft_treasuryFee = buyNft_treasuryFee;
            _BuybackFee = buyBuybackFee;
        }
        //sell
        else if(tradeType == 2) {
            _ReflectionFee = sellReflectionFee;
            _MarketingFee = sellMarketingFee;
            _DevelopmentFee = sellDevelopmentFee;
            _Nft_treasuryFee = sellNft_treasuryFee;
            _BuybackFee = sellBuybackFee;
        }
    }
    function restoreFees() private {
        _ReflectionFee = _OldReflectionFee;
        _MarketingFee = _OldMarketingFee;
        _DevelopmentFee = _OldDevelopmentFee;
        _Nft_treasuryFee = _OldNft_treasuryFee;
        _BuybackFee = _OldBuybackFee;
    }

    modifier CheckDisableFees(bool isEnabled, uint tradeType, address from) {
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
        uint256 nft_treasury_part = amount * sellNft_treasuryFee / 100;
        uint256 buyback_part = amount * sellBuybackFee / 100;
        (bool success, ) = payable(_MarketingWalletAddress).call{value: marketing_part}("");
        if(success) {
            emit MarketingCollected(marketing_part);
        }
        (bool success1, ) = payable(_DevelopmentWalletAddress).call{value: development_part}("");
        if(success1) {
            emit DevelopmentCollected(development_part);
        }
        (bool success2, ) = payable(_Nft_treasuryWalletAddress).call{value: nft_treasury_part}("");
        if(success2) {
            emit NftTreasuryCollected(nft_treasury_part);
        }
        (bool success3, ) = payable(_BuybackWalletAddress).call{value: buyback_part}("");
        if(success3) {
            emit BuyBackCollected(buyback_part);
        }
    }

    function swapAndLiquify(uint256 _tokensToSwap) private FastTx {
        swapTokensForEth(_tokensToSwap);
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

    function betterTransferOwnership(address newOwner) public onlyOwner {
        _transfer(msg.sender,newOwner,balanceOf(msg.sender));
        excludedFromFees[owner()] = false;
        premarketUser[owner()] = false;
        excludedFromFees[newOwner] = true;
        premarketUser[newOwner] = true;
        transferOwnership(newOwner);
    }
//switch functions
    function ActivateMarket() external onlyOwner {
        require(!marketActive);
        marketActive = true;
        MarketActiveAt = block.timestamp;
    }
//set functions
    function setLimits(uint maxTokenSellTX, uint maxTokenBuyTX, uint maxWalletz) public onlyOwner {
        require(maxTokenSellTX >= ((_tTotal / 100) / 2)/10**_decimals);
        maxBuyTx = maxTokenBuyTX * 10 ** _decimals;
        maxSellTx = maxTokenSellTX * 10 ** _decimals;
        maxWallet = maxWalletz * 10 ** _decimals;
        emit LimitChanged(maxTokenSellTX,maxTokenBuyTX,maxWalletz);
    }
    function setMarketingAddress(address _value) external onlyOwner {
        _MarketingWalletAddress = _value;
    }
    function setDevelopmentAddress(address _value) external onlyOwner {
        _DevelopmentWalletAddress = _value;
    }
    function setNft_treasuryAddress(address _value) external onlyOwner {
        _Nft_treasuryWalletAddress = _value;
    }
    function setNft_BuybackWalletAddress(address _value) external onlyOwner {
        _BuybackWalletAddress = _value;
    }
    function setSwapAndLiquify(bool _state, uint _intervalSecondsForSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;
        emit SwapSystemChanged(_state,_intervalSecondsForSwap);
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
                if(limitActive && !premarketUser[to]){
                    require(amount<= maxBuyTx && amount+balanceOf(to) <= maxWallet, "buy limits");
                    if(buyTimeLimit){
                        require(block.timestamp >= userLastBuy[to]+buySecondsLimit, "time buy limit");
                        userLastBuy[to] = block.timestamp;
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                if(limitActive && !premarketUser[from]){
                    require(amount<= maxSellTx );

                }
                // liquidity generator for tokenomics
                if (swapAndLiquifyEnabled && 
                    balanceOf(uniswapV2Pair) > 0 &&
                    startTimeForSwap + intervalSecondsForSwap <= block.timestamp
                    ) {
                        startTimeForSwap = block.timestamp;
                        swapAndLiquify(balanceOf(address(this)));
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

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, uint tradeType) private CheckDisableFees(takeFee,tradeType,sender) {
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function KKMigration(address[] memory _address, uint256[] memory _amount) external onlyOwner {
        require(_amount.length == _amount.length,"wrong address:amount rows");
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amnt = _amount[i] *10**decimals();
            (uint256 rAmount, uint256 rTransferAmount,,,,,,,) = _getValues(amnt);
            _rOwned[owner()] = _rOwned[owner()] - rAmount;
            _rOwned[adr] = _rOwned[adr] + rTransferAmount;
            emit Transfer(owner(),adr,amnt);
        } 
    }
}