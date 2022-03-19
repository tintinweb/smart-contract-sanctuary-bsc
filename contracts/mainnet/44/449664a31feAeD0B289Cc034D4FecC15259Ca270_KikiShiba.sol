/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * BEP20 standard
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * Basic access control mechanism
 */
abstract contract Ownable {
    address internal owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!You are not the OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

/**
 * Router Interfaces
 */
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/**
 * Rewards Interface & Contract
 */
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 BTC = IBEP20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 8);

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
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

        totalShares = totalShares-(shares[shareholder].amount)+(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BTC.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BTC);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BTC.balanceOf(address(this))-(balanceBefore);

        totalDividends = totalDividends+(amount);
        dividendsPerShare = dividendsPerShare+(dividendsPerShareAccuracyFactor*(amount)/(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed+(gasLeft-(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed+(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised+(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            BTC.transfer(shareholder, amount);
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

        return shareholderTotalDividends-(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share*(dividendsPerShare)/(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

/**
 * Contract Implementation INFORMATION
 */
contract KikiShiba is IBEP20, Ownable {

    // Events
    event Launch(uint256 Time);
    event SetMaxBuyAmount(uint256 percentageBase100, uint256 Time);
    event SetMaxSellAmount(uint256 percentageBase100, uint256 Time);
    event SetMaxWalletSize(uint256 percentageBase100, uint256 Time);
    event SetSellFees(uint256 marketing, uint256 dev, uint256 rewards, uint256 liquidity, uint256 Time);
    event SetBuyFees(uint256 marketing, uint256 dev, uint256 rewards, uint256 liquidity, uint256 Time);
    event SetDevWallet(address indexed oldDevWallet, address indexed newDevWallet);
    event SetMarketingWallet(address indexed oldMarketingWallet, address indexed newMarketingWallet);
    event SetSwapDetails(uint256 swapThreshold, uint256 maxSwapSize);
    event SetIsDividendExempt(address account, bool exempt, uint256 Time);
    event SetIsFeeExempt(address account, bool exempt, uint256 Time);
    event SetDistributionCriteria(uint256 minPeriod, uint256 minDistribution);
    event SetNewAMM(address indexed AutomaticMarketMaker);

    // Mappings
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _excludeFromFees;
    mapping (address => bool) _excludeFromRewards;
    mapping (address => bool) _automatedMarketMakers;

    // Basic Contract Info
    string constant _name = "KIKI SHIBA";
    string constant _symbol = "KISHIB";
    uint8 constant _decimals = 9;

    // Supply
    uint256 constant _totalSupply = 10000000000 * 10 ** _decimals;
    
    // Buy, Sell & Wallet limits
    uint256 public _maxBuyAmount = _totalSupply / 100 * 100;
    uint256 public _maxSellAmount = _totalSupply / 100 * 100;
    uint256 public _maxWalletSize = _totalSupply / 100 * 100; 

    // Fees
        // Sell Fees
    uint256 _sellMarketingFee = 5;
    uint256 _sellDevFee = 5;
    uint256 _sellRewardsFee = 3;
    uint256 _sellLiquidityFee;
    uint256 _sellTotalFee = _sellMarketingFee+_sellDevFee+_sellRewardsFee;
        // Buy Fees
    uint256 _buyMarketingFee = 5;
    uint256 _buyDevFee = 5;
    uint256 _buyRewardsFee = 3;
    uint256 _buyLiquidityFee;
    uint256 _buyTotalFee = _buyMarketingFee+_buyDevFee+_buyRewardsFee;

    // Team Wallet & Dead address
    address private devFeeReceiver = 0x195C5Ee5c4582CafA38356e3249b055D84aEE49e;
    address private marketingFeeReceiver = 0x195C5Ee5c4582CafA38356e3249b055D84aEE49e;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    // Router
    IDEXRouter public router;
    address public pair;

    // Boolean variables
    bool private _addingLP;
    bool private _tradingEnabled;
    bool public _swapEnabled = true;
    uint256 public _launchedAt;

    // Rewards distributor settings
    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Swap details
    uint256 public swapThreshold = _totalSupply / 1000 * 3; 
    uint256 public _maxSwapSize = _maxSellAmount;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable(msg.sender) {
        // Initialize Pancake Pair
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _automatedMarketMakers[pair]=true;
        // Initialize Rewards Distributor
        distributor = new DividendDistributor(address(router));
        // Exclude from fees & rewards
        _excludeFromFees[owner] = true;
        _excludeFromRewards[pair] = _excludeFromRewards[address(this)] = _excludeFromRewards[DEAD] = true;
        // Mint _totalSupply to owner address
        _updateBalance(owner, _totalSupply);
        emit Transfer(address(0), owner, _totalSupply);
    }

    // Internal Functions
    function _transfer(address sender,address recipient,uint256 amount) private{
        require(sender!=address(0)&&recipient!=address(0),"Cannot be address(0).");
        bool isBuy=_automatedMarketMakers[sender]; // Buy - Take fees
        bool isSell=_automatedMarketMakers[recipient]; // Sell - Take fees
        bool isExcluded=_excludeFromFees[sender]||_excludeFromFees[recipient]||_addingLP; // Transfers, Exempts addresses & Adding LP - Without fees
        if(isExcluded)_transferExcluded(sender,recipient,amount);
        else {
            require(_tradingEnabled, "Cannot trade yet, wait until launch");
            if(isBuy)_buyTokens(sender,recipient,amount);
            else if(isSell) {
                // Swap & Liquify
                if(shouldSwapBack()){ swapBack();}
                _distributeRewards();
                _sellTokens(sender,recipient,amount);
            } else {
                // P2P Transfer
                require(_balances[recipient]+amount<=_maxWalletSize); // Check if actual held amount + amount buyed is higher than maximum wallet allowed
                _transferExcluded(sender,recipient,amount);
            }
        }
    }

    function _buyTokens(address sender, address recipient, uint256 amount) private{ // Buy transaction - Check limits and calculate fees
        require(_balances[recipient]+amount<=_maxWalletSize,"Total amount exceeds the bag size"); // Check if actual held amount + amount buyed is higher than maximum wallet allowed
        require(amount<=_maxBuyAmount,"Amount exceeds the max buy"); // Check if amount is higher than maximum buy allowed
        uint256 tokenTax = amount*_buyTotalFee/100; // Calculate fees
        _transferIncluded(sender,recipient,amount,tokenTax);
    }

    function _sellTokens(address sender, address recipient, uint256 amount) private{ // Sell transaction - Check limits and calculate fees
        require(amount<=_maxSellAmount,"Amount exceeds the max sell"); // Check if amount is higher than maximum sell allowed
        uint256 tokenTax = amount*_sellTotalFee/100; // Calculate fees
        _transferIncluded(sender,recipient,amount,tokenTax);
    }

    function _transferIncluded(address sender,address recipient,uint256 amount,uint256 tokenTax) private{ // Used for - Transfer with fees
        uint256 newAmount=amount-tokenTax; // Calculate token amount
        _updateBalance(sender,_balances[sender]-amount); // Substrate tokens from sender address
        _updateBalance(address(this),_balances[address(this)]+tokenTax); // Add fees taken to contract address
        _updateBalance(recipient,_balances[recipient]+newAmount); // Add tokens to recipient address
        emit Transfer(sender,recipient,newAmount);
    }

    function _transferExcluded(address sender, address recipient, uint256 amount) private{ // Used for - Transfer without fees
        _updateBalance(sender,_balances[sender]-amount); // Substrate tokens from sender address
        _updateBalance(recipient,_balances[recipient]+amount); // Add tokens to recipient address
        emit Transfer(sender, recipient, amount);
    }

    function _distributeRewards() private{
        try distributor.process(distributorGas) {} catch {}
    }

    function _updateBalance(address account,uint256 newBalance) private{ // Update accounts balances
        _balances[account]=newBalance;
        if(!_excludeFromRewards[account]){ try distributor.setShare(account,_balances[account]) {} catch {} }
        else return;
    }

    function shouldSwapBack() private view returns (bool) {
        return !inSwap && _swapEnabled && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() private swapping {
        uint256 liquidity = _buyLiquidityFee + _sellLiquidityFee;
        uint256 totalFee = _buyTotalFee + _sellTotalFee;
        uint256 tokensToSell;

        uint256 contractTokenBalance = balanceOf(address(this)); // Check total token amount held in contract
            if(contractTokenBalance >= _maxSwapSize){ tokensToSell = _maxSwapSize;} // If token amount is higher than maxSwapSize, swap maxSwapSize amount
            else{ tokensToSell = contractTokenBalance; } // If token amount is lower, swap total amount

        uint256 totalLPTokens=tokensToSell*liquidity/totalFee;
        uint256 tokensLeft=tokensToSell-totalLPTokens;
        uint256 LPTokens=totalLPTokens/2;
        uint256 LPBNBTokens=totalLPTokens-LPTokens;
        uint256 toSwap=tokensLeft+LPBNBTokens;
        _swapTokensForBNB(toSwap); // Swap fees to BNB
        uint256 newBNB=address(this).balance;
        uint256 LPBNB=(newBNB*LPBNBTokens)/toSwap;
        _addLiquidity(LPTokens,LPBNB); // Add liquidity from fees
        uint256 remainingBNB=address(this).balance;
        _distributeBNB(remainingBNB); // Distribute BNB from fees
    }

    function _swapTokensForBNB(uint256 amount) private {
        address[] memory path=new address[](2);
        path[0]=address(this);
        path[1] = router.WETH();
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _distributeBNB(uint256 amountBNB) private {
        uint256 marketing = _buyMarketingFee + _sellMarketingFee;
        uint256 dev = _buyDevFee + _sellDevFee;
        uint256 rewards = _buyRewardsFee + _sellRewardsFee;
        uint256 totalFee = marketing + dev + rewards;
        
        uint256 BNBRewards = amountBNB*(rewards)/(totalFee); // Calculate BNB amount for rewards
        uint256 BNBMarketing = amountBNB*(marketing)/(totalFee); // Calculate BNB amount for marketing
        uint256 BNBDev = amountBNB*(dev)/(totalFee); // Calculate BNB amount for developer

        try distributor.deposit{value: BNBRewards}() {} catch {} // Swap rewards BNB to BTC
        (bool marketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: BNBMarketing, gas: 30000}("");
        require(marketingSuccess, "Marketing wallet rejected ETH transfer"); // Send marketing BNB to marketing wallet
        (bool devSuccess, /* bytes memory data */) = payable(devFeeReceiver).call{value: BNBDev, gas: 30000}("");
        require(devSuccess, "Dev wallet rejected ETH transfer"); // Send dev BNB to developer wallet
    }

    function _addLiquidity (uint256 amountToLiquify, uint256 amountBNBLiquidity) private{
        if(amountToLiquify > 0){ // Check if there is liquidity from fees
        _addingLP = true;
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                devFeeReceiver, // Dev receive additional LP tokens
                block.timestamp
            ); }
        _addingLP = false;
    }

    // Owner Functions
    function launch() external onlyOwner { // Used to initialize trading
        require (_launchedAt == 0, "Already launched");
        _tradingEnabled = true;
        _launchedAt = block.timestamp;
        emit Launch(block.timestamp);
    }

    function setMaxBuyAmount(uint256 percentageBase100) external onlyOwner { // Owner can set limits - Minimum allowed is 1%
        require (percentageBase100 > 0, "Cannot set 0 percentage");
        _maxBuyAmount = (_totalSupply * percentageBase100) / 100;
        emit SetMaxBuyAmount(percentageBase100, block.timestamp);
    }

    function setMaxSellAmount(uint256 percentageBase100) external onlyOwner { // Owner can set limits - Minimum allowed is 1%
        require (percentageBase100 > 0, "Cannot set 0 percentage");
        _maxSellAmount = (_totalSupply * percentageBase100) / 100;
        emit SetMaxSellAmount(percentageBase100, block.timestamp);
    }

    function setMaxWalletSize(uint256 percentageBase100) external onlyOwner { // Owner can set limits - Minimum allowed is 1%
        require (percentageBase100 > 0, "Cannot set 0 percentage");
        _maxWalletSize = (_totalSupply * percentageBase100) / 100;
        emit SetMaxWalletSize(percentageBase100, block.timestamp);
    }

    function setSellFees(uint256 marketing, uint256 dev, uint256 rewards, uint256 liquidity) external onlyOwner { // Owner can set sell fees - Maximum allowed is 25%
        require(_tradingEnabled,"Trading not enabled");
        require(marketing + dev + rewards + liquidity <= 25, "Cannot set Sell Fees higher than 25%");
        _sellMarketingFee = marketing;
        _sellDevFee = dev;
        _sellRewardsFee = rewards;
        _sellLiquidityFee = liquidity;
        _sellTotalFee = marketing + dev + rewards + liquidity;
        emit SetSellFees(marketing,dev,rewards,liquidity,block.timestamp);
    }

    function setBuyFees(uint256 marketing, uint256 dev, uint256 rewards, uint256 liquidity) external onlyOwner { // Owner can set buy fees - Maximum allowed is 20%
        require(_tradingEnabled,"Trading not enabled");
        require(marketing + dev + rewards + liquidity <= 20, "Cannot set Buy Fees higher than 20%");
        _buyMarketingFee = marketing;
        _buyDevFee = dev;
        _buyRewardsFee = rewards;
        _buyLiquidityFee = liquidity;
        _buyTotalFee = marketing + dev + rewards + liquidity;
        emit SetBuyFees(marketing,dev,rewards,liquidity,block.timestamp);
    }

    function setDevWallet(address devWallet) external onlyOwner { // Owner can set new Dev Fee receiver
        require(devFeeReceiver != devWallet,"This address is already DevWallet");
        address oldWallet = devFeeReceiver;
        devFeeReceiver = devWallet;
        emit SetDevWallet(oldWallet, devWallet);
    }

    function setMarketingWallet(address marketingWallet) external onlyOwner { // Owner can set new Marketing Fee receiver
        require(marketingFeeReceiver != marketingWallet,"This address is already MarketingWallet");
        address oldWallet = marketingFeeReceiver;
        marketingFeeReceiver = marketingWallet;
        emit SetMarketingWallet(oldWallet, marketingWallet);
    }

    function setSwapDetails(bool enabled, uint256 threshold, uint256 maxSwap) external onlyOwner { // Set SwapBack details
        _swapEnabled = enabled;
        swapThreshold = threshold * 10 ** _decimals; // Add token amount without decimals
        _maxSwapSize = maxSwap * 10 ** _decimals; // Add token amount without decimals
        emit SetSwapDetails(threshold, maxSwap);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner { // Set Included (false) or Excluded (true) wallets from fees
        require(holder != address(this) && holder != pair, "Cannot include pair or token contract");
        _excludeFromFees[holder] = exempt;
        emit SetIsFeeExempt(holder, exempt, block.timestamp);
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner { // Set Included (false) or Excluded (true) wallets from rewards
        require(holder != address(this) && holder != pair, "Cannot include pair or token contract");
        _excludeFromRewards[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
        emit SetIsDividendExempt(holder, exempt, block.timestamp);
    }

    function setNewAMM(address AMM) external onlyOwner { // Add new pairs/CEX
        require(!_automatedMarketMakers[AMM], "Address is already added as automated market maker");
        _automatedMarketMakers[AMM]=true;
        emit SetNewAMM(AMM);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner { // Min period = Seconds before next rewards distribution
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit SetDistributionCriteria(_minPeriod,_minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner { 
        require(gas < 750000);
        distributorGas = gas;
    }

    // User Callable Functions
    function claimDividend() external { // Manual claim rewards, if you are allowed to claim
        distributor.claimDividend(msg.sender);
    }

    // IBEP20 
    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]-(amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

}