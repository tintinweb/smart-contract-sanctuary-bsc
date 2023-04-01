/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactory02 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IPair02 {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
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
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}



interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    mapping (address => bool) internal authorizations;


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
}

contract ERC20 is Context, IERC20{

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract DividendDistributor is IDividendDistributor {
    
    address private _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] private _shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) private _shareholderLastClaims;
    uint256 public currentIndex;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 24 hours;
    uint256 public minDistribution = 1 * (10 ** 15); // 0.001 BNB


    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor () {
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares - (shares[shareholder].amount) + (amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        if (msg.value > 0) {
            uint256 amount = msg.value;
            totalDividends = totalDividends + (amount);
            dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * (amount) / (totalShares));
        }
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = _shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(_shareholders[currentIndex])){
                distributeDividend(_shareholders[currentIndex]);
            }

            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return _shareholderLastClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed += amount;
            _shareholderLastClaims[shareholder] = block.timestamp;
            (bool success,) = shareholder.call{value: amount}("");
            shares[shareholder].totalRealised += amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);

            if(!success) {
                totalDistributed -= amount;
            }
        }
    }
    
    function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - (shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * (dividendsPerShare) / (dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = _shareholders.length;
        _shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        _shareholders[shareholderIndexes[shareholder]] = _shareholders[_shareholders.length-1];
        shareholderIndexes[_shareholders[_shareholders.length-1]] = shareholderIndexes[shareholder];
        _shareholders.pop();
    }
}

contract SwordGameCorp is ERC20, Ownable {
    using Address for address payable;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromReward;
    mapping (address => bool) private _isExcludedFromMaxSellLimit;

    address payable public marketingWallet = payable(0xdE3D56dB69Ebf8A8F190f4Ff9e41E12589b77758);
    address public liquidityWallet;

    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public sellRewardFee = 7;
    uint256 public sellLiquidityFee = 4;
    uint256 public sellMarketingFee = 9;
    uint256 public totalSellFees;

    uint256 public buyRewardFee = 5;
    uint256 public buyLiquidityFee = 2;
    uint256 public buyMarketingFee = 3;
    uint256 public totalBuyFees;

    uint256 public transferRewardFee = 0;
    uint256 public transferLiquidityFee = 0;
    uint256 public transferMarketingFee = 10;
    uint256 public totalTransferFees;

    uint256 private _marketingCurrentAccumulatedFee;
    uint256 private _liquidityCurrentAccumulatedFee;

    bool public tradingIsEnabled = false;

    mapping (address => bool) private _presaleAddresses;

    uint256 public maxSellLimit = 2 * 10 ** 6 * (10**9); // 0.1%
    
    IRouter02 public dexRouter;
    address public dexPair;
    uint256 public swapThreshold = 2 * 10 ** 5 * (10**9); // 0.01%

    bool private _isLiquefying;

    modifier lockTheSwap {
    if (!_isLiquefying) {
        _isLiquefying = true;
        _;
        _isLiquefying = false;
    }}

    DividendDistributor distributor;
    uint256 public distributorGas = 500_000;

    modifier onlyPresale() {
        require(_presaleAddresses[msg.sender] , "SGC: caller is not one of the presale address");
        _;
    }

    // Any transfer to these addresses could be subject to some sell/buy taxes
    mapping (address => bool) public automatedMarketMakerPairs;

    event DistributorGasUpdated(uint256 newGas, uint256 oldGas);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromMaxSellLimit(address indexed account, bool isExcluded);
    event ExcludeFromReward(address indexed account, bool isExcluded);

    event AddAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event Router02Updated(address indexed newAddress, address indexed oldAddress);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);

    event Burn(uint256 amount);

    event SellFeesUpdated(uint8 rewardFee, uint8 liquidityFee, uint8 marketingFee);
    event BuyFeesUpdated(uint8 rewardFee, uint8 liquidityFee, uint8 marketingFee);
    event TransferFeesUpdated (uint8 rewardFee, uint8 liquidityFee, uint8 marketingFee);

    event MaxSellLimitUpdated(uint256 amount);
    event SwapThresholdUpdated(uint256 amount);

    event SwapAndDistribute(uint256 tokensSwapped,uint256 bnbReceived);

    event DistributionCriteriaUpdated(uint256 minPeriod, uint256 minDistribution);

    event Claim(address indexed account);

    event TradingEnabled();
    event PresaleAddressAdded(address indexed account);



    constructor() ERC20("Sword Game Corp", "SGC") {
        _mint(msg.sender, 2 * 10 ** 9 * (10**9));

        totalBuyFees = buyRewardFee + buyLiquidityFee + buyMarketingFee;
        totalSellFees = sellRewardFee + sellLiquidityFee + sellMarketingFee;
        totalTransferFees = transferRewardFee + transferLiquidityFee + transferMarketingFee;

        dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    	distributor = new DividendDistributor();
        liquidityWallet = owner();

        dexPair = IFactory02(dexRouter.factory())
            .createPair(address(this), dexRouter.WETH());
        _setAutomatedMarketMakerPair(dexPair, true);

        excludeFromReward(address(this),true);
        excludeFromReward(owner(),true);
        excludeFromReward(address(dexRouter),true);
        excludeFromReward(address(distributor),true);
        excludeFromReward(address(DEAD),true);

        excludeFromFees(liquidityWallet, true);
        excludeFromFees(address(this), true);

        _isExcludedFromMaxSellLimit[address(this)] = true;
        _isExcludedFromMaxSellLimit[owner()] = true;

        _presaleAddresses[owner()] = true;

    }

    receive() external payable {
  	}
    
    function excludeFromReward(address account, bool excluded) public onlyOwner {
        require((account != address(this) && account != dexPair) || excluded, "SGC: Main pair and contract's addresses cannot be included from rewards");
        _isExcludedFromReward[account] = excluded;
        if(excluded){
            distributor.setShare(account, 0);
        }else{
            distributor.setShare(account, balanceOf(account));
        }
        emit ExcludeFromReward(account, excluded);

    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "SGC: Account has already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromMaxSellLimit(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromMaxSellLimit[account] != excluded, "SGC: Account has already the value of 'excluded'");
        _isExcludedFromMaxSellLimit[account] = excluded;
        emit ExcludeFromMaxSellLimit(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != dexPair, "SGC: The main pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "SGC: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        excludeFromReward(pair,value);
        _isExcludedFromMaxSellLimit[pair] = value;

        emit AddAutomatedMarketMakerPair(pair, value);
    }

    function setNewRouter02(address newRouter_) public onlyOwner {
        IRouter02 newRouter = IRouter02(newRouter_);
        address newPair = IFactory02(newRouter.factory()).getPair(address(this), newRouter.WETH());
        if (newPair == address(0)) {
            newPair = IFactory02(newRouter.factory()).createPair(address(this), newRouter.WETH());
        }
        dexPair = newPair;
        dexRouter = IRouter02(newRouter_);
    }


    function setBuyFees(uint8 rewardFee, uint8 liquidityFee, uint8 marketingFee) external onlyOwner {
        uint8 newTotalBuyFees = rewardFee + liquidityFee + marketingFee;
        require(newTotalBuyFees <= 10 && newTotalBuyFees >=0,"SGC: Total fees must be between 0 and 10");
        buyRewardFee = rewardFee;
        buyLiquidityFee = liquidityFee;
        buyMarketingFee = marketingFee;
        totalBuyFees = newTotalBuyFees;
        emit BuyFeesUpdated(rewardFee, liquidityFee, marketingFee);
    }
    
    function setSellFees(uint8 rewardFee,uint8 liquidityFee,uint8 marketingFee) external onlyOwner {
        uint8 newTotalSellFees = rewardFee + liquidityFee + marketingFee;
        require(newTotalSellFees <= 20 && newTotalSellFees >=0, "SGC: Total fees must be between 0 and 20");
        sellRewardFee = rewardFee;
        sellLiquidityFee = liquidityFee;
        sellMarketingFee = marketingFee;
        totalSellFees = newTotalSellFees;
        emit SellFeesUpdated(rewardFee, liquidityFee, marketingFee);
    }

    function setTransferFees(uint8 rewardFee,uint8 liquidityFee,uint8 marketingFee) external onlyOwner {
        uint8 newTotalTransferFees = rewardFee + liquidityFee + marketingFee;
        require(newTotalTransferFees <= 10 && marketingFee >=0, "SGC: Total fees must be between 0 and 10");
        transferRewardFee = rewardFee;
        transferLiquidityFee = liquidityFee;
        transferMarketingFee = marketingFee;
        totalTransferFees = newTotalTransferFees;
        emit TransferFeesUpdated(rewardFee,liquidityFee,marketingFee);
    }

    function setMaxSellLimit(uint256 amount) external onlyOwner {
        require(amount >= totalSupply()/1000 / 10**9, "SGC: Max sell limit must be greater or equals than 0.1% of the total supply");
        maxSellLimit = amount *10**9;
        emit MaxSellLimitUpdated(amount);
    }

    function setSwapThreshold(uint256 amount) external onlyOwner {
        require(amount >= 1 && amount <= totalSupply()/50 / 10**9, "SGC: Amount must be greater or equals than 1 and lower or equals than 2% of the total supply");
        swapThreshold = amount *10**9;
        emit SwapThresholdUpdated(amount);
    }

    function setLiquidityWallet(address newWallet) public onlyOwner {
        require(newWallet != liquidityWallet, "SGC: The liquidity wallet has already this address");
        emit LiquidityWalletUpdated(newWallet, liquidityWallet);
        liquidityWallet = newWallet;
    }
    function setMarketingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != marketingWallet, "SGC: The marketing wallet has already this address");
        emit MarketingWalletUpdated(newWallet,marketingWallet);
        marketingWallet = newWallet;
    }

    function enableTrading() external onlyOwner {
        require(!tradingIsEnabled,"SGC: Trading is already enabled");
        tradingIsEnabled = true;
        emit TradingEnabled();
    }

    function addPresaleAccount(address account) public onlyOwner {
        require(!_presaleAddresses[account],"SGC: This account is already added");
        _presaleAddresses[account] = true;
        emit PresaleAddressAdded(account);
    }

    function burn(uint256 amount) external returns (bool) {
        _transfer(_msgSender(), DEAD, amount);
        emit Burn(amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "SGC: Transfer from the zero address");
        require(to != address(0), "SGC: Transfer to the zero address");
        require(amount >= 0, "SGC: Transfer amount must be greater or equals to zero");

        bool isBuyTransfer = automatedMarketMakerPairs[from];
        bool isSellTransfer = automatedMarketMakerPairs[to];

        if(!tradingIsEnabled) {
            require(_presaleAddresses[from], "SGC: This account is not allowed to send tokens before trading is enabled");
        }

        if(tradingIsEnabled && !_isLiquefying && isSellTransfer && !_isExcludedFromMaxSellLimit[from] && from != address(dexRouter)) {
            require(amount <= maxSellLimit, "SGC: Amount exceeds the maxSellLimit");
        }

        bool takeFee = tradingIsEnabled && !_isLiquefying;
        // Remove fees if one of the address is excluded from fees
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) takeFee = false;

        bool canSwap =  balanceOf(address(this)) >= swapThreshold;

        if(tradingIsEnabled && canSwap &&!_isLiquefying &&!automatedMarketMakerPairs[from] /* not during buying */) {
            swapAndDistribute(swapThreshold);
        }
        if(takeFee) {
            uint256 totalFees;
            if(isSellTransfer){
                totalFees = totalSellFees;
                _liquidityCurrentAccumulatedFee+= amount * sellLiquidityFee / 100;
                _marketingCurrentAccumulatedFee+= amount * sellMarketingFee / 100;
            }

            else if(isBuyTransfer) {
                totalFees = totalBuyFees;
                _liquidityCurrentAccumulatedFee+= amount * buyLiquidityFee / 100;
                _marketingCurrentAccumulatedFee+= amount * buyMarketingFee / 100;
            }

            else {
                totalFees = totalTransferFees;
                _liquidityCurrentAccumulatedFee+= amount * transferLiquidityFee / 100;
                _marketingCurrentAccumulatedFee+= amount * transferMarketingFee / 100;
            }
            uint256 fees = amount * totalFees /100;
            amount -= fees;

            if(fees > 0) super._transfer(from, address(this), fees);
        }
        
        super._transfer(from, to, amount);

        processRewards(from, to);
    }

    function processRewards(address from, address to) internal {
        if (!_isExcludedFromReward[from]) {
            try distributor.setShare(from, balanceOf(from)) {} catch {}
        }
        if (!_isExcludedFromReward[to]) {
            try distributor.setShare(to, balanceOf(to)) {} catch {}
        }
        if(tradingIsEnabled) {
            try distributor.process(distributorGas) {} catch {}
        }
    }

    function swapAndDistribute(uint256 tokenAmount) private lockTheSwap {
        uint256 initialBalance = address(this).balance;

        uint256 liquidityTokensToNotSwap = _liquidityCurrentAccumulatedFee / 2;

        uint256 totalTokensToSwap = tokenAmount - liquidityTokensToNotSwap;

        // swap tokens for BNB
        _swapTokensForBNB(totalTokensToSwap);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;
        uint256 marketingAmount = newBalance * _marketingCurrentAccumulatedFee / totalTokensToSwap;
        uint256 liquidityAmount = newBalance * liquidityTokensToNotSwap / totalTokensToSwap;
        _marketingCurrentAccumulatedFee = 0;
        _liquidityCurrentAccumulatedFee = 0;

        // Add liquidity to LP
        if(liquidityAmount > 0 )addLiquidity(liquidityTokensToNotSwap, liquidityAmount);
        // Send marketing fees
        marketingWallet.sendValue(marketingAmount);

        uint256 rewardAmount = address(this).balance - initialBalance;
        
        emit SwapAndDistribute(totalTokensToSwap, newBalance);
        try distributor.deposit{value: rewardAmount}() {} catch {}

    }

    function _swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexRouter), tokenAmount);

        // add the liquidity
        dexRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
        
    }

    function distributeTokensManually() external payable onlyOwner {     
        require(tradingIsEnabled,"SGC: Trading must be enabled to distribute tokens");
        swapAndDistribute(balanceOf(address(this)));
        
    } 
    // Airdrop
    function batchTokensTransfer(address[] calldata _accounts, uint256[] calldata _amounts) external onlyPresale {
        require(_accounts.length <= 200, "SGC: 200 addresses maximum");
        require(_accounts.length == _amounts.length, "SGC: Account array must have the same size as the amount array");
        require(_isExcludedFromReward[_msgSender()], "SGC: Owner must be excluded from reward");
        for (uint i = 0; i < _accounts.length; i++) {
            if (_accounts[i] != address(0)) {
                super._transfer(_msgSender(), _accounts[i], _amounts[i]);
                if (!_isExcludedFromReward[_accounts[i]]) {
                    try distributor.setShare(_accounts[i], balanceOf(_accounts[i])) {} catch {}
                }
            }
        }
    }

    function getStuckBNBs(address payable to) external onlyOwner {
        require(address(this).balance > 0, "SGC: There are no BNBs in the contract");
        to.transfer(address(this).balance);
    } 

    function getStuckTokens(address payable to, address token, uint256 amount) external onlyOwner {
        require(IERC20(token).balanceOf(address(this)) > 0, "SGC: There are tokens in the contract");
        require(token != address(this),"SGC: SGC tokens cannot be got from the contract");
        IERC20(token).transfer(to,amount);
    }


    function setDistributorSettings(uint256 newGas) external onlyOwner {
        require(newGas >= 100_000 && newGas <= 900_000, "SGC: Gas must be between 100,000 and 900,000");
        require(newGas != distributorGas, "SGC: DistributorGas is already this value");
        distributorGas = newGas;
        emit DistributorGasUpdated(newGas, distributorGas);
    }

    function setDistributionCriteria(uint256 minPeriod_, uint256 minDistribution_) external onlyOwner {
        distributor.setDistributionCriteria(minPeriod_, minDistribution_);
        emit DistributionCriteriaUpdated(minPeriod_,minDistribution_);
    }

    function claimReward(address account) external {
        distributor.claimDividend(account);
        emit Claim(account);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(DEAD) - balanceOf(address(0));
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromMaxSellLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxSellLimit[account];
    }

    function isExcludedFromRewards(address account) public view returns(bool) {
        return _isExcludedFromReward[account];    
    }

    function getTotalShares() public view returns(uint256) {
        return distributor.totalShares();
    }

    function getTotalDividends() public view returns(uint256) {
        return distributor.totalDividends();
    }

    function getTotalDistributed() public view returns(uint256) {
        return distributor.totalDistributed();
    }

    function getCurrentIndex() public view returns(uint256) {
        return distributor.currentIndex();
    }

    function getUnpaidEarnings(address account) public view returns(uint256) {
        return distributor.getUnpaidEarnings(account);
    }
    

}