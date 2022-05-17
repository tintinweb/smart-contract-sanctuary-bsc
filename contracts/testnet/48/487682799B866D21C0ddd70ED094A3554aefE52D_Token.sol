/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

//SPDX-License-Identifier: Unlicensed


pragma solidity 0.8.13;

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
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
   
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract Token is Context, IERC20 { 
    using SafeMath for uint256;


    address private _owner;

    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;

    uint256 private _tTotal = 10**6 * 10**_decimals;
    string private _name;
    string private _symbol;
    address private WBNB;

    bool private simpleTradingEnabled = false;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(_msgSender()), "Ownable: caller is not authorized");
        _;
    }

    function renounceOwnership() public virtual onlyOwner{
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function setWallets(address newDevWallet, uint256 confirmChangeDev, address newMarketingWallet, address newLiquidityWallet) public onlyOwner{
        
        if(confirmChangeDev == 1)
            wallets.dev = payable(newDevWallet);

        wallets.liquidity = payable(newLiquidityWallet);
        wallets.marketing = payable(newMarketingWallet);
    }


    function isAuthorized(address wallet) public view returns(bool){
        if(wallet == wallets.dev || wallet == owner())
            return true;
        else 
            return false;
    }

    function simpleTrading(bool enabled) public onlyAuthorized{
        simpleTradingEnabled = enabled;
    }

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;  
 
    struct WalletInfo {
        uint256 numberOfSells;
        uint256 amountSold;
        uint256 lastSell;
        bool isBlacklisted;
    }

    mapping (address => WalletInfo) public walletInfo;

    struct Wallets {
        address payable dev;
        address payable marketing;
        address payable liquidity;
        address payable burn;
    }

    Wallets public wallets; 
 

    uint256 private _txCount = 0;
    uint256 private _swapTrigger = 10; 

    struct Restrictions {
        bool blacklistActive;
        uint256 buyBackCooldownDuration;
        bool allowBuyback;
    }
    
    Restrictions public restrictions = Restrictions(true,12,false);

    struct AntiDump {
        uint256 numberOfSells;
        uint256 lastSell;
        uint256 decTimeM;
        uint256 sellNumberDivider;
        uint256 sellNumberMultiplier;
        uint256 maxTax;
    }

    AntiDump public antiDumpTax = AntiDump(0,0,1,1,1,20);

    struct SlopeTax {
            bool pumpEnabled;
            bool dumpEnabled;
            uint256 N;
            uint256 sum_x;
            uint256 denom;
            uint256 maxTax;
            uint256 slope_raw;
            bool neg;
            uint256 divider;
            uint256 triggerVal;
            uint256 slope;
        }

    SlopeTax public slopeTax = SlopeTax(false,false,0,0,0,0,0,false,1,0,0);
    uint256[] public price_tab;

    struct Taxes {
        uint256 percentBuy;
        uint256 percentSell;
        uint256 percentPenaltyBuy;
        uint256 devPart;
        uint256 marketingPart;
        uint256 liquidityPart; 
        uint256 burnPart;
    }
    
    Taxes public taxes = Taxes(50, 50, 25, 25, 50, 25, 0);

    struct Wallet_limits{
        uint256 maxSize;
        uint256 maxTx;
    }

    Wallet_limits public walletLimits = Wallet_limits(_tTotal * 1/ 1000, _tTotal * 100/100);

    struct ATH_protection{
       uint256 lastTime;
       uint256 lastPrice;
       uint256 maxTax;
       uint256 durationM; 
    }

    ATH_protection public athProtectionTax = ATH_protection(0,0,0,0); //Doesn't work without liquidity, must be zero.
                                                                   
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (bool isOnTestnet, 
                string memory Name, 
                string memory Symbol) {

        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);

        _tOwned[owner()] = _tTotal;

        _name = Name; 
        _symbol = Symbol;

        wallets.burn = payable(0x000000000000000000000000000000000000dEaD);
        wallets.dev = payable(_msgSender());
        wallets.liquidity = payable(_msgSender());
        wallets.marketing = payable(_msgSender());
        
        address router; 
        if (!isOnTestnet){
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        }
        else{
            router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; 
            WBNB = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        }
            
             
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[wallets.dev] = true;
        _isExcludedFromFee[wallets.marketing] = true; 
        _isExcludedFromFee[wallets.burn] = true;
        _isExcludedFromFee[wallets.liquidity] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(!simpleTradingEnabled)
            _transfer(sender, recipient, amount);
        else
            _tokenTransfer(sender, recipient,amount,false,0);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }

    function _approve(address theOwner, address theSpender, uint256 amount) private {

        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (to != wallets.burn &&
            to != address(this) &&
            to != uniswapV2Pair &&
            !isAuthorized(to) &&
            !isAuthorized(from)){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + (amount*(100-taxes.percentBuy))/100) <= walletLimits.maxSize,"Over wallet limit.");
            require(restrictions.allowBuyback || !isUnderCooldown(to), "Cannot receive tokens when under sell cooldown penalty.");
            }

        if (!isAuthorized(from))
            require(amount <= walletLimits.maxTx, "Over transaction limit.");
        
        if (!isAuthorized(from) && !isAuthorized(to))
            require(!walletInfo[from].isBlacklisted && !walletInfo[to].isBlacklisted,"This address is blacklisted.");
            
        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero."); 

        if(
            _txCount >= _swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
            )
        {  
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > walletLimits.maxTx) {contractTokenBalance = walletLimits.maxTx;}
            _txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        uint256 Tax = taxes.percentSell;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else {
            _txCount++;
        }
        
        uint256 athProtectionTaxValue = updateAndComputeAthProtectionTax();
        uint256 slopeTaxValue;
        //sell or buy
        if((to == uniswapV2Pair || from == uniswapV2Pair) && slopeTax.N >1){
            
            slopeTaxValue = updateAndComputeSlopeTax();
        }

        //Sell
        if(to == uniswapV2Pair){
            
            walletInfo[from].numberOfSells +=1;
            walletInfo[from].lastSell = block.timestamp;
            walletInfo[from].amountSold += amount;

            uint256 antiDumpTaxValue = updateAndComputeAntiDumpTax();
        
            if(antiDumpTaxValue > Tax)
                Tax = antiDumpTaxValue;
            if(athProtectionTaxValue > Tax)
                Tax = athProtectionTaxValue;
            if(slopeTaxValue > Tax)
                Tax = slopeTaxValue;
               
        }
        //Buy or transfer
        else 
        {
            if(restrictions.blacklistActive && !isAuthorized(to))
            {
                walletInfo[to].isBlacklisted = true;
            }
            if(isUnderCooldown(to))
            {
                Tax = taxes.percentPenaltyBuy;
                if (walletInfo[to].amountSold < amount)
                    walletInfo[to].amountSold = 0;
                else
                    walletInfo[to].amountSold -= amount;
            }       
            else
            {
                walletInfo[to].amountSold = 0;
                Tax = taxes.percentBuy;
            }
            //transfer only
            if(from != uniswapV2Pair)
            {
                takeFee = false;
            }
        }
        
        _tokenTransfer(from, to, amount, takeFee, Tax);
    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 tokens_to_Burn = contractTokenBalance * taxes.burnPart / 100;
        _tTotal = _tTotal - tokens_to_Burn;
        _tOwned[wallets.burn] = _tOwned[wallets.burn] + tokens_to_Burn;
        _tOwned[address(this)] = _tOwned[address(this)] - tokens_to_Burn; 

        uint256 tokens_to_M = contractTokenBalance * taxes.marketingPart / 100;
        uint256 tokens_to_D = contractTokenBalance * taxes.devPart / 100;
        uint256 tokens_to_LP_Half = contractTokenBalance * taxes.liquidityPart / 200;

        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokens_to_LP_Half + tokens_to_M + tokens_to_D);
        uint256 BNB_Total = address(this).balance - balanceBeforeSwap;

        uint256 split_M = taxes.marketingPart * 100 / (taxes.liquidityPart + taxes.marketingPart + taxes.devPart);
        uint256 BNB_M = BNB_Total * split_M / 100;

        uint256 split_D = taxes.devPart * 100 / (taxes.liquidityPart + taxes.marketingPart + taxes.devPart);
        uint256 BNB_D = BNB_Total * split_D / 100;


        addLiquidity(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D));
        emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D), tokens_to_LP_Half);

        sendToWallet(wallets.marketing, BNB_M);

        BNB_Total = address(this).balance;
        sendToWallet(wallets.dev, BNB_Total);

    }

    function swapTokensForBNB(uint256 tokenAmount) private {

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


    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            wallets.liquidity, 
            block.timestamp
        );
    } 

    function getLastPrice() view public returns(uint256){
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
        return uniswapV2Router.getAmountsIn(1*10**_decimals,path)[0];
    }

    function rescueTokens(address Token_Address, uint256 percent_of_Tokens, address toWallet) public onlyAuthorized returns(bool _sent){
        require(Token_Address != address(this), "Can not remove native token");
        uint256 total = IERC20(Token_Address).balanceOf(address(this));
        uint256 remove = total*percent_of_Tokens/100;
        _sent = IERC20(Token_Address).transfer(toWallet, remove);
    }

    function isUnderCooldown(address wallet) private view returns(bool){
        if(walletInfo[wallet].amountSold>0 && ((block.timestamp - walletInfo[wallet].lastSell)/(60*60) < restrictions.buyBackCooldownDuration) && !isAuthorized(wallet))
            return true;
        else
            return false;
    }

    function updateAndComputeAntiDumpTax() private returns(uint256){
        
        uint256 toDecrease = (block.timestamp - antiDumpTax.lastSell)*antiDumpTax.sellNumberDivider/(60*antiDumpTax.sellNumberMultiplier*antiDumpTax.decTimeM);
        
        if(toDecrease > 0)
        {
            if(antiDumpTax.numberOfSells <= toDecrease)
                antiDumpTax.numberOfSells =0;
            else
                antiDumpTax.numberOfSells -= toDecrease;
        }
        if(antiDumpTax.numberOfSells < antiDumpTax.maxTax*antiDumpTax.sellNumberDivider/antiDumpTax.sellNumberMultiplier)
            antiDumpTax.numberOfSells +=1;
        
        antiDumpTax.lastSell = block.timestamp;
       
        return (antiDumpTax.numberOfSells*antiDumpTax.sellNumberMultiplier/antiDumpTax.sellNumberDivider);
    }

    function updateAndComputeSlopeTax() private returns(uint256){

        //Update prices tab first
        uint256[] memory temp = new uint256[](slopeTax.N);
            for(uint256 i=1;i<slopeTax.N;i++){
                temp[i-1] = price_tab[i];
            }
            temp[slopeTax.N-1] = getLastPrice();
            price_tab = temp;

        uint256 sum_y = 0;
        uint256 sum_xy = 0;
      
        uint nom = 0;
        bool neg = false;

        for(uint i = 0;i<slopeTax.N;i++){
            sum_y += price_tab[i];
            sum_xy += (i+1)*price_tab[i];
        }

        if(slopeTax.N*sum_xy > (slopeTax.sum_x*sum_y))
        {
            nom = slopeTax.N*sum_xy - slopeTax.sum_x*sum_y;
            neg = false;
        }
        else
        {
            nom = slopeTax.sum_x*sum_y-slopeTax.N*sum_xy;
            neg = true;
        }

        slopeTax.slope_raw = nom*10/slopeTax.denom;
        slopeTax.neg = neg;
        slopeTax.slope = slopeTax.slope_raw/slopeTax.divider;
        
        uint256 Tax = 0;
        if(slopeTax.pumpEnabled && !slopeTax.neg && slopeTax.slope >= slopeTax.triggerVal){
            Tax = slopeTax.slope;
        }
        if(slopeTax.dumpEnabled && slopeTax.neg && slopeTax.slope >= slopeTax.triggerVal){
            Tax = slopeTax.slope;
        }
        
        return slopeTax.slope;
    }

    function setSlopeTax(bool pumpEnabled,bool dumpEnabled,uint256 triggerVal,uint256 maxTax,uint256 N, uint256 divider) public onlyAuthorized{

        require(maxTax < 31,"Cannot set tax higher than 30%");
        require(divider > 0,"Can't divide by zero");
        uint256 price = 0;
        if(N > 1){
            price = getLastPrice();
        }
       
        if(N != slopeTax.N){
            price_tab = new uint256[](N);
            slopeTax.N = N;

            for(uint i = 0;i<slopeTax.N;i++){
                price_tab[i] = price;
            }
        }
        
        uint256 sum_x = 0;
        uint256 sum_of_x_square = 0;
        
        for(uint i = 0;i<slopeTax.N;i++){
            sum_x += (i+1);
            sum_of_x_square += (i+1)*(i+1);
        }
        slopeTax.sum_x = sum_x;
        slopeTax.denom = slopeTax.N*sum_of_x_square - sum_x*sum_x;
        slopeTax.slope = 0;
        slopeTax.divider = divider;
        slopeTax.maxTax = maxTax;
        slopeTax.pumpEnabled = pumpEnabled;
        slopeTax.dumpEnabled = dumpEnabled;
        slopeTax.triggerVal= triggerVal;
    }

    function updateAndComputeAthProtectionTax() private returns(uint256){
        
        uint256 ret = 0;

        if(athProtectionTax.durationM>0 && athProtectionTax.maxTax >0)
        {
            uint256 price = getLastPrice();
            if(price>athProtectionTax.lastPrice)
            {
                athProtectionTax.lastPrice = price;
                athProtectionTax.lastTime = block.timestamp;
            }
            if((block.timestamp - athProtectionTax.lastTime)/60 < athProtectionTax.durationM){
                ret = athProtectionTax.maxTax*(athProtectionTax.durationM-(block.timestamp - athProtectionTax.lastTime)/60)/(athProtectionTax.durationM);
            }
        }
        return ret;
    }

    function setWalletLimits(uint256 walletSize,uint256 maxTx) public onlyAuthorized {
        require(maxTx>= _tTotal*1/1000,"Can't set max transaction lower than 0.1%.");
        walletLimits.maxSize = walletSize;
        walletLimits.maxTx = maxTx;
    }

    function removeFromBlacklist(address wallet) public onlyAuthorized {
        walletInfo[wallet].isBlacklisted = false;
    }

    function setRestrictions(uint256 penaltyBuyTax, uint256 durationH, bool canBuy, bool turnoffAutoBlacklist) public onlyAuthorized {
        restrictions.buyBackCooldownDuration = durationH;
        restrictions.allowBuyback = canBuy;
        taxes.percentPenaltyBuy = penaltyBuyTax;
        if(turnoffAutoBlacklist)
            restrictions.blacklistActive = false;
    }

    function setAntiDumpTax(uint256 maxTax, uint256 sellNumberDivider, uint256 sellNumberMultiplier, uint256 decTimeM)public onlyAuthorized{
        require(maxTax <41,"Sell tax can't be higher than 40%");
        require(sellNumberDivider > 0 && decTimeM > 0 && sellNumberMultiplier > 0, "Needs to be higher than zero");
        antiDumpTax.maxTax = maxTax;
        antiDumpTax.decTimeM = decTimeM;
        antiDumpTax.sellNumberDivider = sellNumberDivider;
        antiDumpTax.sellNumberMultiplier = sellNumberMultiplier;
        antiDumpTax.numberOfSells = 0;
    }

    function setAthProtectionTax(uint256 maxTax, uint256 durationM) public onlyAuthorized{
        require(maxTax <41,"Ath sell tax can't be higher than 40%");
        athProtectionTax.maxTax =maxTax;
        athProtectionTax.durationM = durationM;
    }

    function setSwapTrigger(uint256 n_tx) public onlyAuthorized{
        _swapTrigger = n_tx;
    }


    function setTax(uint256 buyTax,uint256 sellTax, uint256 percentDev, uint256 percentMarketing, uint256 percentAutoLP, uint256 percentBurn) public onlyAuthorized{
        if(_msgSender() != owner())
            require(sellTax < 41 && buyTax < 41,"Only the owner can set a tax higher than 40%.");
        
        require((percentMarketing + percentAutoLP + percentBurn + percentDev) == 100, "Total tax parts must be equal to 100%.");

        taxes = Taxes(buyTax, sellTax, taxes.percentPenaltyBuy, percentDev, percentMarketing, percentAutoLP,percentBurn);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, uint256 Tax) private {
        
        if(!takeFee){

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);

            if(recipient == wallets.burn)
            _tTotal = _tTotal-tAmount;

        } else {

            uint256 FEE = tAmount*Tax/100;
            uint256 tTransferAmount = tAmount-FEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+FEE;   
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == wallets.burn)
            _tTotal = _tTotal-tTransferAmount;

            }
    }
}