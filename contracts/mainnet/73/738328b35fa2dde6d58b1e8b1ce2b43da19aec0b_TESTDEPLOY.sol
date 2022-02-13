/**
TEST
 */

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;
 
import "./Libraries.sol";

/**
TEST
 */
contract TESTDEPLOY is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;
 
    // Events
    event OwnerUpdateBuyTaxes(uint8 reflection,uint8 liquidity,uint8 marketing,uint8 buyback,uint8 dev);
    event OwnerUpdateSellTaxes(uint8 reflection,uint8 liquidity,uint8 marketing,uint8 buyback,uint8 dev);
    event OwnerUpdateMarketingWallet(address oldMarketingWallet, address newMarketingWallet);
    event OwnerUpdateBuybackWallet(address oldBuybackWallet,address buyback);
    event OwnerUpdateDevWallet(address oldDevWallet,address developer);
    event OwnerUpdateLimits(uint256 maxWalletSize, uint256 maxTxAmount);
    event OwnerSwitchAntiBlock(bool enabled);
    event OwnerSwitchSwapAndLiquify(bool enabled);
    event OwnerTriggerSwap(bool ignoreLimits,uint256 timestamp);
    event OwnerEnableTrading(uint256 timestamp);
    event OwnerUpdateSwapSettings(uint256 swapthreshold,uint256 maxswap);
    event OwnerUpdateTransferFees(uint256 transferFee);

    // Mappings
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint256) private lastTrade;
 
    // Basic Contract Info
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000*10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
 
    string private _name = "STest";     
    string private _symbol = "TEST"; 
    uint8 private _decimals = 9;
 
    // Project & Burn Wallets
    address public burnWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0x000000000000000000000000000000000000dEaD; 
    address public buybackWallet = 0x000000000000000000000000000000000000dEaD;  
    address public devWallet = 0x000000000000000000000000000000000000dEaD;    
 
    // Taxes
    uint256 public _reflectFee;
    uint256 private _previousReflectFee;
    uint256 public _secondaryTax;
    uint256 private _previousSecondaryFee;
    uint256 public _transferFees = 5;
 
    BuyTaxes private _buy;
    SellTaxes private _sell;
    struct BuyTaxes { //Buy taxes set in constructor function
        uint8 liquidityTax;
        uint8 marketingTax;
        uint8 buybackTax;
        uint8 devTax;
        uint8 totalTax;
        uint8 reflection;
    }
    struct SellTaxes { //Sell taxes set in constructor function
        uint8 liquidityTax;
        uint8 marketingTax;
        uint8 buybackTax;
        uint8 devTax;
        uint8 totalTax;
        uint8 reflection;
    }

    // Limits
    uint256 public _maxTxAmount = _tTotal/1000*10;    // Max Transaction Allowed 1%
    uint256 public _maxWalletSize = _tTotal/1000*15; //  Max Tokens Held 1.5%
    bool public sameBlockActive;                    // Only one transaction per user per block is allowed
 
    // DEX
    IPancakeRouter02 private _pancakeRouter;
    address public _pancakeRouterAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //Pancake Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E || Pancake Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address public _pancakePairAddress;
 
    // SwapAndLiquify
    bool public swapAndLiquifyEnabled;            // Swap fees to BNB
    uint256 private _swapThreshold=_tTotal/1000; //  Minimum amount to trigger SwapAndLiquify
    uint256 private _maxSwapSize=_maxTxAmount;  //   Maximum amount to swap
    
    bool tradingEnabled;
    uint256 launchedAt;
    bool inSwapAndLiquify;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
 
    constructor () {
        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
        _pancakeRouter=IPancakeRouter02(_pancakeRouterAddress);
        _pancakePairAddress=IPancakeFactory(_pancakeRouter.factory()).createPair(address(this),_pancakeRouter.WETH());
        _approve(address(this),address(_pancakeRouter), type(uint256).max);
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()]=_isExcludedFromFee[burnWallet]=_isExcludedFromFee[address(this)]=true;
        
        // Set initial Buy taxes
        _buy.liquidityTax=2; _buy.marketingTax=3; _buy.buybackTax=2; _buy.devTax=2; _buy.reflection=2;
        _buy.totalTax=_buy.liquidityTax+_buy.marketingTax+_buy.buybackTax+_buy.devTax;
        
        // Set initial Sell taxes
        _sell.liquidityTax=3; _sell.marketingTax=5; _sell.buybackTax=5; _sell.devTax=2; _sell.reflection=2;
        _sell.totalTax=_sell.liquidityTax+_sell.marketingTax+_sell.buybackTax+_sell.devTax;
    }
 
// Basic Internal Functions
 
    function name() public view override returns (string memory) {
        return _name;
    }
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function getOwner() external view override returns (address) { return owner();}
 
    function balanceOf(address account) public view override returns (uint256) {
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
 
    receive() external payable {}
 
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
// Reflections
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tSecondary) = _getTokenValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRateValues(tAmount, tFee, tSecondary, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tSecondary);
    }
    function _getTokenValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateReflectFee(tAmount);
        uint256 tSecondary = calculateSecondaryFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tSecondary);
        return (tTransferAmount, tFee, tSecondary);
    }
    function _getRateValues(uint256 tAmount, uint256 tFee, uint256 tSecondary, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rSecondary = tSecondary.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rSecondary);
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
 
// Taxes
    function calculateReflectFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectFee).div(100);
    }
    function calculateSecondaryFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_secondaryTax).div(100);
    }
    function removeAllFee() private {
        if(_reflectFee == 0 && _secondaryTax == 0) return;
 
        _previousReflectFee = _reflectFee;
        _previousSecondaryFee = _secondaryTax;
 
        _reflectFee = 0;
        _secondaryTax = 0;
    }
    function restoreAllFee() private {
        _reflectFee = _previousReflectFee;
        _secondaryTax = _previousSecondaryFee;
    }
    function _takeFees(uint256 tSecondary, uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
        uint256 currentRate =  _getRate();
        uint256 rSecondary = tSecondary.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rSecondary);
    }
 
// Swap and distribution
    function swapAndLiquify(bool ignoreLimits) private lockTheSwap {
       uint256 contractTokenBalance = balanceOf(address(this));
       uint256 tokensToSell;
        if(contractTokenBalance >= _maxSwapSize){
            tokensToSell = _maxSwapSize;            
        } else{
            tokensToSell = contractTokenBalance;
        }
        if(ignoreLimits){tokensToSell = contractTokenBalance;}

        uint256 liquidity = _buy.liquidityTax + _sell.liquidityTax;
        uint256 marketing = _buy.marketingTax + _sell.marketingTax;
        uint256 buyback = _buy.buybackTax + _sell.buybackTax;
        uint256 totalTax = _buy.totalTax + _sell.totalTax;

        uint256 totalLiquidityTokens=tokensToSell*liquidity/totalTax;
        uint256 tokensLeft=tokensToSell-totalLiquidityTokens;
        uint256 liquidityTokens=totalLiquidityTokens/2;
        uint256 liquidityBNBTokens=totalLiquidityTokens-liquidityTokens;
        tokensToSell=liquidityBNBTokens+tokensLeft;
        uint256 oldBNB=address(this).balance;
        swapTokensForBNB(tokensToSell);
        uint256 newBNB=address(this).balance-oldBNB;
        uint256 LPBNB=(newBNB*liquidityBNBTokens)/tokensToSell;
        addLiquidity(liquidityTokens, LPBNB);
        uint256 remainingBNB=address(this).balance-oldBNB;
        uint256 BNBMarketing=remainingBNB*marketing/totalTax;
        uint256 BNBBuyback=remainingBNB*buyback/totalTax;
        uint256 BNBDev=remainingBNB-BNBMarketing-BNBBuyback;
        if(BNBMarketing > 0) {payable(marketingWallet).transfer(BNBMarketing);}
        if(BNBBuyback > 0) {payable(buybackWallet).transfer(BNBBuyback);}
        if(BNBDev > 0) {payable(devWallet).transfer(BNBDev);}

    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
 
    function addLiquidity(uint256 tokenAmount, uint256 amountWei) private {
        _pancakeRouter.addLiquidityETH{value: amountWei}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
 
// Transfer functions
    function _transfer(address sender,address recipient,uint256 amount) private {
        require(_isExcludedFromFee[sender]||tradingEnabled);
        
        bool isBuy = sender==_pancakePairAddress;
        bool isSell = recipient==_pancakePairAddress;
        bool isTransfer = recipient!=_pancakePairAddress && sender!=_pancakePairAddress;

        if(isSell){_secondaryTax=_sell.totalTax; _reflectFee=_sell.reflection;
            require(_isExcludedFromFee[recipient] || _isExcludedFromFee[sender] || amount<=_maxTxAmount, "Amount is higher than maximum amount");
        }
        if(isBuy){_secondaryTax=_buy.totalTax; _reflectFee=_buy.reflection;
            require(_isExcludedFromFee[recipient] || _isExcludedFromFee[sender] || balanceOf(recipient)+amount<=_maxWalletSize, "Cannot hold that total amount");
            require(_isExcludedFromFee[recipient] || _isExcludedFromFee[sender] || amount<=_maxTxAmount, "Amount is higher than maximum amount");
        }
        if(isTransfer){_secondaryTax=_transferFees;_reflectFee=0;}

        if(launchedAt + 1 >= block.number){_secondaryTax=99;_reflectFee=0;}
            
        if(isSell &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            balanceOf(address(this)) >= _swapThreshold
        ) {
           swapAndLiquify(false);
        }

        bool takeFee = true;
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        _tokenTransfer(sender,recipient,amount,takeFee);
    }
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(sender != owner()
            && recipient != owner()
            && recipient != address(0)
            && sender != address(this)) {
        // If SameBlock function is active, only one transaction per user per block is allowed
            if (sameBlockActive) {
                if (sender == _pancakePairAddress){
                    require(lastTrade[recipient] != block.number);
                    lastTrade[recipient] = block.number;
                } else {
                    require(lastTrade[sender] != block.number);
                    lastTrade[sender] = block.number;
                    }
                }
            }
        if(!takeFee) removeAllFee();
            _transferStandard(sender, recipient, amount); 
        if(!takeFee) restoreAllFee();
    }
   function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSecondary) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFees(tSecondary, rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
// View Functions
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / (currentRate);
    }
 
// Owner Functions
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function ownerUpdateBuyTaxes(uint8 reflection, uint8 liquidity, uint8 marketing, uint8 buyback, uint8 dev) public onlyOwner {
        require(reflection+liquidity+marketing+buyback+dev<=30,"Cannot set higher buy taxes than 20%");
        _buy.liquidityTax = liquidity;
        _buy.marketingTax = marketing;
        _buy.buybackTax = buyback;
        _buy.devTax = dev;
        _buy.reflection = reflection;
        _buy.totalTax = liquidity+marketing+buyback+dev;
        emit OwnerUpdateBuyTaxes(reflection,liquidity,marketing,buyback,dev);
    }
    function ownerUpdateSellTaxes(uint8 reflection, uint8 liquidity, uint8 marketing, uint8 buyback, uint8 dev) public onlyOwner {
        require(reflection+liquidity+marketing+buyback+dev<=30,"Cannot set higher sell taxes than 30%");
        _sell.liquidityTax = liquidity;
        _sell.marketingTax = marketing;
        _sell.buybackTax = buyback;
        _sell.devTax = dev;
        _sell.reflection = reflection;
        _sell.totalTax = liquidity+marketing+buyback+dev;
        emit OwnerUpdateSellTaxes(reflection,liquidity,marketing,buyback,dev);
    }
    function ownerUpdateTransferFees(uint256 transferFee) public onlyOwner{
        require(transferFee <=5,"Cannot set higher P2P fee than 5%");
        _transferFees = transferFee;
        emit OwnerUpdateTransferFees(transferFee);
    }
    function ownerUpdateMarketingWallet(address marketing) public onlyOwner{
        address oldMarketingWallet = marketingWallet; 
        marketingWallet = marketing;
        emit OwnerUpdateMarketingWallet(oldMarketingWallet,marketing);
    }
    function ownerUpdateBuybackWallet(address buyback) public onlyOwner{
        address oldBuybackWallet = buybackWallet; 
        buybackWallet = buyback;
        emit OwnerUpdateBuybackWallet(oldBuybackWallet,buyback);
    }
    function ownerUpdateDevWallet(address developer) public onlyOwner{
        address oldDevWallet = devWallet; 
        devWallet = developer;
        emit OwnerUpdateDevWallet(oldDevWallet,developer);
    }
    function ownerUpdateLimits(uint256 maxTxAmount, uint256 maxWalletSize) public onlyOwner{
        require(maxTxAmount*10**_decimals >= _tTotal/200,"Cannot set MaxTransaction below 0.5%");
        require(maxWalletSize*10**_decimals >= _tTotal/100,"Cannot set MaxWallet below 1%");
        _maxTxAmount = maxTxAmount*10**_decimals;
        _maxWalletSize = maxWalletSize*10**_decimals;
        emit OwnerUpdateLimits(maxWalletSize,maxTxAmount);
    }
    function ownerSwitchAntiBlock(bool enabled) public onlyOwner{
        sameBlockActive = enabled;
        emit OwnerSwitchAntiBlock(enabled);
    }
    function ownerTriggerSwap(bool ignoreLimits) public onlyOwner {
        swapAndLiquify(ignoreLimits);
        emit OwnerTriggerSwap(ignoreLimits,block.timestamp);
    }
    function ownerSwitchSwapAndLiquify(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled=enabled;
        emit OwnerSwitchSwapAndLiquify(enabled);
    }
    function ownerUpdateSwapSettings(uint256 swapthreshold, uint256 maxswap) public onlyOwner{
        require(maxswap*10**_decimals<=_maxTxAmount,"Cannot set maxSwap higher than maxTransaction");
        _swapThreshold = swapthreshold*10**_decimals;
        _maxSwapSize = maxswap*10**_decimals;
        emit OwnerUpdateSwapSettings(swapthreshold,maxswap);
    }
    function ownerWithdrawStuckBNB() public onlyOwner {
        (bool success,) = msg.sender.call{value: (address(this).balance)}("");
        require(success);
    }
    function ownerEnableTrading() public onlyOwner {
        tradingEnabled=true;
        launchedAt=block.number;
        sameBlockActive = true;
        swapAndLiquifyEnabled = true;
        emit OwnerEnableTrading(block.timestamp);
    }
}