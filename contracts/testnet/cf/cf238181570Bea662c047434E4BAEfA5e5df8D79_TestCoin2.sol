/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: Unlicensed
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

interface IUniswapV2Factory {
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

interface LuckyBunnyFarm {
    function addBoost(address adr, uint256 duration, uint256 percent) external;
    function addMultipleBoost(address[] memory adrs, uint256[] memory durations, uint256[] memory percents) external;
    function removeBoostFor(address[] memory adrs) external;
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

struct BoostTier {
    uint256 tokenAmount;
    uint256 duration;
    uint256 percent;
}

struct Boost {
    uint256 duration;
    uint256 endTimestamp;
    uint256 percent;
    BoostTier tier;
}

abstract contract NFTHolder {
    mapping (address => bool) internal _nftAdmins;
    mapping (address => bool) internal _nftHolders;

    function addNFTAdmin(address admin) external onlyNFTAdmins {
        _nftAdmins[admin] = true;
    }

    function removeNFTAdmin(address admin) external onlyNFTAdmins {
        delete _nftAdmins[admin];
    }

    modifier onlyNFTAdmins(){
        require(_nftAdmins[msg.sender] == true, "caller is not NFT Admin");
        _;
    }

    function addNFTHolders(address[] memory holders) external onlyNFTAdmins {
        for (uint i=0; i<holders.length; i++) {
            _nftHolders[holders[i]] = true;
        } 
    }

    function removeNFTHolders(address[] memory holders) external onlyNFTAdmins {
        for (uint i=0; i<holders.length; i++) {
            delete _nftHolders[holders[i]];
        } 
    }
}

abstract contract TieredBoostable is Ownable {
    BoostTier[] private _tiers;

    constructor() {
        _tiers.push(BoostTier(1000, 31560000, 5));
        _tiers.push(BoostTier(3000, 31560000, 10));
        _tiers.push(BoostTier(5000, 31560000, 15));
    }

    function setBoostTiers(uint256[] memory tokenAmounts, uint256[] memory durations, uint256[] memory percents) external onlyOwner{
        require((tokenAmounts.length == durations.length || durations.length == 1));
        
        delete _tiers;

        for (uint i=0; i< tokenAmounts.length; i++) {
            uint256 duration = durations[0];
            if (durations.length > 1) {
                duration = durations[i];
            }
            uint256 percent = percents[0];
            if (percents.length > 1) {
                percent = percents[i];
            }
            BoostTier memory newTier = BoostTier(tokenAmounts[i], duration, percent);
            _tiers.push(newTier); 
        }
        updateAllHoldersBoost();
    }

    function getBoostTiersFor(uint256 tokenAmount) internal view returns(BoostTier memory) {
        if (_tiers.length == 1 && tokenAmount >= _tiers[0].tokenAmount)
            return _tiers[0];

        for (uint i=0; i < _tiers.length - 1; i++) {
           if (tokenAmount >= _tiers[i].tokenAmount && tokenAmount < _tiers[i+1].tokenAmount) {
               return _tiers[i];
           } else if (i == _tiers.length - 2 && tokenAmount >= _tiers[i+1].tokenAmount) {
               return _tiers[i+1];
           }
        }     
        return BoostTier(0,0,0);
    }
    
    function updateAllHoldersBoost() virtual internal;
}

abstract contract Boostable is TieredBoostable {
    LuckyBunnyFarm internal boostContract;
    mapping (address => Boost) private _boosts;
    address[] private _boostedWallets;

    function boostHolderExists(address adr) private view returns(bool){ 
        for (uint i=0; i<_boostedWallets.length; i++) {
            if (_boostedWallets[i] == adr){
                return true;
            }
        }
        return false;
    }

    function addOrRemoveBoostByOwner(address[] memory adrs, uint256[] memory tokenAmounts) external onlyOwner {
         for (uint i=0; i< adrs.length; i++) {
            uint256 tokenAmount = tokenAmounts[0];
            if (tokenAmounts.length > 1) {
                tokenAmount = tokenAmounts[i];
            }
            addOrRemoveBoost(adrs[i], tokenAmount);
        } 
    }

    function addOrRemoveBoost(address adr, uint256 tokenAmount) internal {
        BoostTier memory tier = getBoostTiersFor(tokenAmount);
        Boost memory boost = Boost(tier.duration, block.timestamp + tier.duration, tier.percent, tier);
        if (boostHolderExists(adr) == false)
            _boostedWallets.push(adr);
        if (_boosts[adr].duration == 0 && tier.percent != 0) {
            _boosts[adr] = boost;
            boostContract.addBoost(adr, tier.duration, tier.percent); 
        }
        else if (tier.percent == 0 && _boosts[adr].duration != 0) {
            delete _boosts[adr];
            address[] memory addrs = new address[](1);
            addrs[0] = adr;
            boostContract.removeBoostFor(addrs); 
        }
        else if (tier.percent != 0 && _boosts[adr].endTimestamp > block.timestamp && (tier.percent != _boosts[adr].percent || tier.duration != _boosts[adr].duration)) {
            delete _boosts[adr];
            _boosts[adr] = boost;
            address[] memory addrs = new address[](1);
            addrs[0] = adr;
            boostContract.removeBoostFor(addrs);
            boostContract.addBoost(adr, tier.duration, tier.percent); 
        } else if (tier.percent != 0 && _boosts[adr].endTimestamp < block.timestamp){
            _boosts[adr] = boost;
            address[] memory addrs = new address[](1);
            addrs[0] = adr;
            boostContract.removeBoostFor(addrs);
            boostContract.addBoost(adr, tier.duration, tier.percent); 
        }
    }
    
    function updateAllHoldersBoost() internal override {
        
        address[] memory shouldBeRemovedFromBoost = new address[](_boostedWallets.length);
        address[] memory shouldBeAddedToBoost = new address[](_boostedWallets.length);
        uint256[] memory durations = new uint256[](_boostedWallets.length);
        uint256[] memory percents = new uint256[](_boostedWallets.length);
        uint256 nbElementToRemove = 0;
        uint256 nbElementToAdd = 0;
        for (uint i=0; i< _boostedWallets.length; i++) {
            address adr = _boostedWallets[i];
            uint256 balanceOfHolder = boostHolderBalance(adr);
            BoostTier memory tier = getBoostTiersFor(balanceOfHolder);
            Boost memory boost = Boost(tier.duration, block.timestamp + tier.duration, tier.percent, tier);
            if (tier.percent == 0) {
                delete _boosts[adr];
                shouldBeRemovedFromBoost[nbElementToRemove] = adr;
                nbElementToRemove += 1;
            }
            else if ((tier.percent != 0 && _boosts[adr].duration == 0) || (tier.percent != 0 && _boosts[adr].endTimestamp > block.timestamp && (tier.percent != _boosts[adr].percent || tier.duration != _boosts[adr].duration))) {
                delete _boosts[adr];
                _boosts[adr] = boost;
                shouldBeRemovedFromBoost[nbElementToRemove] = adr; 
                shouldBeAddedToBoost[nbElementToAdd] = adr; 
                durations[nbElementToAdd] = tier.duration; 
                percents[nbElementToAdd] = tier.percent; 
                nbElementToRemove += 1;
                nbElementToAdd += 1;
            } else if (tier.percent != 0 && _boosts[adr].endTimestamp < block.timestamp){
                delete _boosts[adr];
                shouldBeRemovedFromBoost[nbElementToRemove] = adr;
                nbElementToRemove += 1;
            } 
        }

        shouldBeRemovedFromBoost = copyNElementAddrArray(shouldBeRemovedFromBoost, nbElementToRemove);
        shouldBeAddedToBoost = copyNElementAddrArray(shouldBeAddedToBoost, nbElementToAdd);
        durations = copyNElementUintArray(durations, nbElementToAdd);
        percents = copyNElementUintArray(percents, nbElementToAdd);
        boostContract.removeBoostFor(shouldBeRemovedFromBoost);
        boostContract.addMultipleBoost(shouldBeAddedToBoost, durations, percents);  
    }

    function copyNElementAddrArray(address[] memory initialArray, uint256 nElement) private pure returns(address[] memory myNewArray) {
        address[] memory newArray = new address[](nElement);
        for (uint i=0; i< nElement; i++) {
            newArray[i] = initialArray[i];
        }
        return newArray;
    }

    function copyNElementUintArray(uint256[] memory initialArray, uint256 nElement) private pure returns(uint256[] memory myNewArray) {
        uint256[] memory newArray = new uint256[](nElement);
        for (uint i=0; i< nElement; i++) {
            newArray[i] = initialArray[i];
        }
        return newArray;
    }

    function boostHolderBalance(address adr) internal virtual view returns(uint256);
}

abstract contract AntiBot {
    uint256 private _antiBotUntilBlockNumber = 0;
    bool internal _antiBotActivate = false;

    function prepareAntiBot(uint256 numberOfAntiBotBlocks) internal {
        _antiBotActivate = true;
        _antiBotUntilBlockNumber = block.number + numberOfAntiBotBlocks;
    }

    function antiBotAction() internal {
        if (block.number <= _antiBotUntilBlockNumber){
            enableAntiBotFees(); 
        }
        else if (_antiBotUntilBlockNumber != 0){
            _antiBotActivate = false;
            _antiBotUntilBlockNumber = 0; 
        }   
    }

    function enableAntiBotFees() virtual internal;
}


contract TestCoin2 is Context, IERC20, Boostable, AntiBot, NFTHolder {      
    address payable public buyBackAddress; // Manual BuyBack Address
    address payable public refillBunnyFarmPoolContract; 
    address public presaleAdr;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isBotCaught;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromLimit;
    mapping(address => bool) public whitelistedOnPrivateTrading;

    string private _name = "TestCoin2";
    string private _symbol = "TestCoin2";
    uint8 private _decimals = 18;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000 * (10 ** _decimals);
    
    // Fee setters are all base 1000 based on globalDivisor
    uint256 public _totalLiqFee = 0;
    uint256 private _prevTotalLiqFee = _totalLiqFee;
    uint256 public _liquidityFee = 20;
    uint256 public _tokenBuyBackFee = 100;
    uint256 public _bunnyFarmPoolFee = 30;
    
    //Wallet setters are all base 1000 based on globalDivisor
    uint256 private globalDivisor = 1000; //This allows percent to 1 decimal place
    uint256 public _maxTxPercent = 10;
    uint256 public _maxTxAmount = (_tTotal * _maxTxPercent) / globalDivisor;
    uint256 public _numTokensSellToAddToLiquidity = (_tTotal * 10) / globalDivisor;
    uint256 public _maxWalletPercent = 20;
    uint256 public _maxWalletSize = (_tTotal * _maxWalletPercent) / globalDivisor;

    bool public botCatchMode = true;
    bool public privateTradingIsOn = true;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
   
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
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
    
    constructor (address bunnyFarmContract, address refillContract, address router, address buyBackAdr) {
        refillBunnyFarmPoolContract = payable(refillContract);
        boostContract = LuckyBunnyFarm(bunnyFarmContract); 
        buyBackAddress = payable(buyBackAdr);

        _tOwned[_msgSender()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router); 
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[buyBackAddress] = true;
        _isExcludedFromFee[refillBunnyFarmPoolContract] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        //exclude owner and this contract from limit
        _isExcludedFromLimit[buyBackAddress] = true;
        _isExcludedFromLimit[refillBunnyFarmPoolContract] = true;
        _isExcludedFromLimit[owner()] = true;
        _isExcludedFromLimit[address(this)] = true;

        _nftAdmins[owner()] = true;

        _totalLiqFee = _liquidityFee  + _tokenBuyBackFee + _bunnyFarmPoolFee;
        _prevTotalLiqFee = _totalLiqFee;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tOwned[account];
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
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromLimit(address account) public onlyOwner {
        _isExcludedFromLimit[account] = true;
    }

    function includeInLimit(address account) public onlyOwner {
        _isExcludedFromLimit[account] = false;
    }
    
    //Configure the Contract Max Percentages all are base 1000
    // 30/1000 = 3% and so on
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxPercent = maxTxPercent;
    }

    function _setMaxWalletSizePercent(uint256 maxWalletPercent) external onlyOwner {
        _maxWalletPercent = maxWalletPercent;
    }

    function setbuyBackAddress(address newAddress) external onlyOwner() {
        buyBackAddress = payable(newAddress);
    }

    function setBunnyFarmBuyBackAddress(address newAddress) external onlyOwner() {
        refillBunnyFarmPoolContract = payable(newAddress);
    }

    function setTaxes(uint256 newLiquidityFee, uint256 newBuyBackFee, uint256 newBunnyFarmFee) external onlyOwner() {
        require(newLiquidityFee + newBuyBackFee + newBunnyFarmFee <= 300, "Total fees cannot be greater than 30 percent");
        _liquidityFee = newLiquidityFee;
        _tokenBuyBackFee = newBuyBackFee;
        _bunnyFarmPoolFee = newBunnyFarmFee;
        
        _totalLiqFee = _liquidityFee + _tokenBuyBackFee + _bunnyFarmPoolFee;
        _prevTotalLiqFee = _totalLiqFee;
    }

    function setNumTokensSellToAddToLiquidity(uint256 newLimit) external onlyOwner() {
        _numTokensSellToAddToLiquidity = newLimit;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }

    function setPresaleAdr(address newValue) external onlyOwner {
        presaleAdr = newValue;
         _isExcludedFromFee[presaleAdr] = true;
         _isExcludedFromLimit[presaleAdr] = true;
    }
    
    function setPrivateTradingStatus(bool on) public onlyOwner {
        privateTradingIsOn = on;
    }
    
    function whitelistAddressForPrivateTrading(address account, bool whitelisted) public onlyOwner {
        whitelistedOnPrivateTrading[account] = whitelisted;
    }

    function whitelistMultipleAddress(address[] memory account, bool whitelisted) public onlyOwner {
        for(uint256 i = 0; i < account.length; i++){
            address wallet = account[i];
            whitelistedOnPrivateTrading[wallet] = whitelisted;
        }
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount - (tLiquidity);
        return (tTransferAmount, tLiquidity);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        _tOwned[address(this)] = _tOwned[address(this)]+(tLiquidity);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount*(_totalLiqFee)/(globalDivisor);
    }
    
    function removeAllFee() private {   
        if (!_antiBotActivate)
            _prevTotalLiqFee = _totalLiqFee;     
        _totalLiqFee = 0;
    }
    
    function restoreAllFee() private {
        _totalLiqFee = _prevTotalLiqFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromLimit(address account) public view returns (bool) {
        return _isExcludedFromLimit[account];
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

        uint256 contractTokenBalance = balanceOf(address(this));
        
        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }
        bool overMinimumTokenBalance = contractTokenBalance >= _numTokensSellToAddToLiquidity;
        bool takeFee = true;
        
        if (overMinimumTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled && !_antiBotActivate)
        {
           if(swapAndLiquifyByLimitOnly)
                contractTokenBalance = _numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        else if (from == uniswapV2Pair && !inSwapAndLiquify) {
            antiBotAction();
        }
        
        else if (from != uniswapV2Pair && to !=uniswapV2Pair && !inSwapAndLiquify) {
            takeFee = false;
        }
                // botCatcher
        if(botCatchMode){
            require(!isBotCaught[from] && !isBotCaught[to],"BotCaught");    
        }

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        if (privateTradingIsOn && from == uniswapV2Pair && !_isExcludedFromFee[to]) {
            require(whitelistedOnPrivateTrading[to], "You are not whitelisted on private trading");
        }

        if (!_isExcludedFromLimit[from] && !_isExcludedFromLimit[to]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        if (to != uniswapV2Pair) {
                    require(amount + balanceOf(to) <= _maxWalletSize, "Recipient exceeds max wallet size.");
        }
        
        _tokenTransfer(from, to, amount, takeFee); 
        if (from != uniswapV2Pair && !inSwapAndLiquify && _nftHolders[from] == false && from != presaleAdr) {
            addOrRemoveBoost(from, balanceOf(from)/(10**_decimals));
        }
        
        if (to != uniswapV2Pair && !inSwapAndLiquify && _nftHolders[to] == false && to != presaleAdr) {
            addOrRemoveBoost(to, balanceOf(to)/(10**_decimals));
        }
    }
    
    function swapAndLiquify(uint256 tAmount) public lockTheSwap {
        
        uint256 forLiquidity = tAmount/(_totalLiqFee)*(_liquidityFee);
        uint256 forWallets = tAmount-(forLiquidity);
        if(forLiquidity > 0)
        {
            uint256 half = forLiquidity/(2);
            uint256 otherHalf = forLiquidity-(half);
    
            uint256 initialBalance = address(this).balance;
            swapTokensForEth(half); 
            uint256 newBalance = address(this).balance-(initialBalance);
            addLiquidity(otherHalf, newBalance);
            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
        
        if(forWallets > 0 && _tokenBuyBackFee+(_bunnyFarmPoolFee) > 0)
        {
            uint256 initialBalance = address(this).balance;
            swapTokensForEth(forWallets);
            uint256 newBalance = address(this).balance-(initialBalance);
    
            uint256 marketingShare = newBalance/(_tokenBuyBackFee+(_bunnyFarmPoolFee))*(_tokenBuyBackFee);
            uint256 bunnyFarmShare = newBalance-(marketingShare);
            
            if(marketingShare > 0)
                transferToAddressETH(buyBackAddress, marketingShare);
            
            if(bunnyFarmShare > 0)
                transferToAddressETH(refillBunnyFarmPoolContract, bunnyFarmShare);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
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
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();      
        _transferStandard(sender, recipient, amount);    
        if(!takeFee || _antiBotActivate)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender]-(tAmount);
        _tOwned[recipient] = _tOwned[recipient]+(tTransferAmount);
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function prepareForPreSale() external onlyOwner {
        setSwapAndLiquifyEnabled(false);
        _totalLiqFee = 0;
        _prevTotalLiqFee = 0;
    }

    function prepareForLaunchWithAntiBot(uint256 nbBlock) external onlyOwner {
        prepareAntiBot(nbBlock);
        setSwapAndLiquifyEnabled(true);
        _totalLiqFee = _liquidityFee+_tokenBuyBackFee+_bunnyFarmPoolFee;
        _prevTotalLiqFee = _totalLiqFee;
    }

    function enableAntiBotFees() virtual override internal {
        _totalLiqFee = 99;
    }

    function boostHolderBalance(address adr) internal override view returns(uint256) {
        return balanceOf(adr)/(10**_decimals);
    }

    function enable_botCatch(bool _status) public onlyOwner {
        botCatchMode = _status;
    }

    function manage_botCatch(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBotCaught[addresses[i]] = status;
        }
    }

    function withdrawStuck(address recipient, uint256 amount) public onlyOwner {
        payable(recipient).transfer(amount);
    }

    function withdrawForeignToken(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        IERC20 foreignToken = IERC20(tokenAddress);
        foreignToken.transfer(recipient, amount);
    }
}