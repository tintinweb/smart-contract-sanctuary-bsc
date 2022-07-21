/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

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

/**
 * BEP20 standard interface.
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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
   
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }
    
    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        authorizations[account] = true;
        emit OwnershipTransferred(account);
    }

    event OwnershipTransferred(address owner);
}

/* Standard IDEXFactory */
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/* Standard IDEXRouter */
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

/* Interface for the DividendDistributor */
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}


contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 RWRD = IBEP20 (0x92f8aCD124Cfc8c1FeE78514d6AE57b8553f3A1C);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
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

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

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

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWRD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RWRD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
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
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
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

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
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


    contract BUGGATI is IBEP20, Auth { 
    using SafeMath for uint256;

   
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    address public burnFeeReceiver;       
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public devFeeReceiver;
    
    // Name and symbol
    string constant _name = "BUGATTI INU";
    string constant _symbol = "BUGATTI";
    uint8 constant _decimals = 4;

    // total supply 
    uint256 _totalSupply = 10000 * (10 ** _decimals); 

    // Max wallet and TX
    uint256 public _maxBuyTxAmount = _totalSupply * 2 / 100; //1%
    uint256 public _maxSellTxAmount = _totalSupply * 1 / 100; // 1% 
    uint256 public _maxWalletToken = ( _totalSupply * 2 ) / 100; // 1%
    

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public islaunchExempt;
    mapping (address => bool) public isBlacklisted;
    bool public BlacklistMode = true;
    bool public launchMode = true;
    
    // Set Buy Fees
    uint256 liquidityFeeBuy = 2;   //LP Fee
    uint256 BuybackFeeBuy = 0;     //Buyback
    uint256 rewardFeeBuy = 5;      //Reward might be turned on later
    uint256 marketingFeeBuy = 4;   //Marketing 
    uint256 devFeeBuy = 0;         //Dev Fee
    uint256 burnFeeBuy = 1;        //Default sends to Dead adress
    uint256 totalFeeBuy = marketingFeeBuy + liquidityFeeBuy + rewardFeeBuy + burnFeeBuy + devFeeBuy + BuybackFeeBuy;
    

    // Set sell fees
    uint256 liquidityFeeSell = 2;
    uint256 BuybackFeeSell = 0;
    uint256 rewardFeeSell = 8;
    uint256 marketingFeeSell = 5;
    uint256 devFeeSell = 0;
    uint256 burnFeeSell = 1;
    uint256 totalFeeSell = marketingFeeSell + liquidityFeeSell + rewardFeeSell + burnFeeSell + devFeeSell + BuybackFeeSell;
   

    // Fee variables
    uint256 liquidityFee;
    uint256 BuybackFee;
    uint256 rewardFee;
    uint256 marketingFee;
    uint256 devFee;
    uint256 burnFee;
    uint256 totalFee;
    uint256 feeDenominator = 100;

    uint256 launchMultiplier = 10;
    
    // Dead blocks
    uint256 deadBlocks = 0;

    uint256 public swapThreshold = _totalSupply * 5 / 2000;

    uint256 targetLiquidity = 100;
    uint256 targetLiquidityDenominator = 100;

    // Buyback settings
    uint256 BuybackMultiplierNumerator = 200;
    uint256 BuybackMultiplierDenominator = 100;
    uint256 BuybackMultiplierTriggeredAt;
    uint256 BuybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    bool public autoBuybackMultiplier = false;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Set true if Buycooldown is wanted. timer in seconds
    bool public BuyCooldownEnabled = false;    //set to false as standard FUNCTION 11
    uint8 public cooldownTimerInterval = 10;   //interval is in seconds
    mapping (address => uint) private cooldownTimer;

    
    IDEXRouter public router;
    address public pair;
    uint256 public launchedAt;
    bool public tradingOpen = false; //set to false as standard. if set to true, trading will be enabled after LP is added
    bool public swapEnabled = true; //contract sells on as standard
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    

    /* Token constructor */
    constructor () Auth(msg.sender) {

        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));
        
        // Should be the owner wallet/token distributor
        address _deployer = msg.sender;
        isFeeExempt[_deployer] = true;
        isTxLimitExempt[_deployer] = true;
        
        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        isTimelockExempt[devFeeReceiver] = true;
        isTimelockExempt[marketingFeeReceiver] = true;
                
        // Exempt from dividend
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // Fee receivers
        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0xd9b04732aD2D049A668ebA417389F60170861014; //Marketing wallet
        devFeeReceiver = 0xd9b04732aD2D049A668ebA417389F60170861014; //Dev fee
        burnFeeReceiver = DEAD; //Can be changed to treasury but DEAD adress is default

        _balances[_deployer] = _totalSupply;
        emit Transfer(address(0), _deployer, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
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
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);

    }
    
    // settting the max wallet in percentages base 1000 
    
    
     function setMaxWalletPercentBase1000(uint256 maxWallPercent) external onlyOwner() {  
         require(_maxWalletToken >= _totalSupply / 1000); //cannot set below .1%
        _maxWalletToken = _totalSupply.mul(maxWallPercent).div(1000); // 1% = 10

    }
    /* Airdrop Begins */
function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
    }
}

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not enabled yet");
        }

        if(BlacklistMode){
        require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');

        }
       
        bool isSell = recipient == pair; 
        setCorrectFees(isSell);
        checkMaxWallet(sender, recipient, amount);        
        checkBuyCooldown(sender, recipient);
        checkTxLimit(sender, amount, recipient, isSell);      
        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount, launchMode) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function Prepare(bool _launchMode) public onlyOwner{
        launchMode = _launchMode;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Set the correct fees for Buying or selling
    function setCorrectFees(bool isSell) internal {
        if(isSell){
            liquidityFee = liquidityFeeSell;
            BuybackFee = BuybackFeeSell;
            rewardFee = rewardFeeSell;
            marketingFee = marketingFeeSell;
            devFee = devFeeSell;
            burnFee = burnFeeSell;
            totalFee = totalFeeSell;
        } else {
            liquidityFee = liquidityFeeBuy;
            BuybackFee = BuybackFeeBuy;
            rewardFee = rewardFeeBuy;
            marketingFee = marketingFeeBuy;
            devFee = devFeeBuy;
            burnFee = burnFeeBuy;
            totalFee = totalFeeBuy;
        }
    }

    // Check for maxTX
    function checkTxLimit(address sender, uint256 amount, address recipient, bool isSell) internal view {
        if (recipient != owner){
            if(isSell){
                require(amount <= _maxSellTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
            } else {
                require(amount <= _maxBuyTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
            }
        }
    }

    // Check Buy cooldown
    function checkBuyCooldown(address sender, address recipient) internal {
        if (sender == pair &&
            BuyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait between two Buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
    }

    // Check maxWallet
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if (!authorizations[sender] && recipient != owner && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != autoLiquidityReceiver && recipient != devFeeReceiver && !isTxLimitExempt[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not Buy that much.");
        }
    }

    // Check if sender is not feeExempt
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    // Get total fee's or multiplication of fees
    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + deadBlocks >= block.number){ return feeDenominator.sub(1); }
        if(selling && BuybackMultiplierTriggeredAt.add(BuybackMultiplierLength) > block.timestamp){ return getMultipliedFee(); }
        return totalFee;
    }

    // Get a multiplied fee when BuybackMultiplier is active
    function getMultipliedFee() public view returns (uint256) {
        uint256 remainingTime = BuybackMultiplierTriggeredAt.add(BuybackMultiplierLength).sub(block.timestamp);
        uint256 feeIncrease = totalFee.mul(BuybackMultiplierNumerator).div(BuybackMultiplierDenominator).sub(totalFee);
        return totalFee.add(feeIncrease.mul(remainingTime).div(BuybackMultiplierLength));
    }

    function takeFee(address sender, address receiver, uint256 amount, bool LAUNCHMode) internal returns (uint256) {
        uint256 feeAmount;
       
         if (LAUNCHMode == true){
           
          if(islaunchExempt[sender] == true || islaunchExempt[receiver] == true){            
            feeAmount = amount * totalFee > feeDenominator ? amount.mul(totalFee).div(feeDenominator) : 0;
          }else{
            if(totalFee * launchMultiplier < feeDenominator){
            
              if(amount * totalFee * launchMultiplier > feeDenominator){ 
                          
              feeAmount = amount.mul(totalFee).mul(launchMultiplier).div(feeDenominator);
              } else{
                feeAmount = 0;
              }             
            }else{
              feeAmount = amount * 90 > 100 ? amount.mul(90).div(100) : 0;
            }
          }
        } else {
            feeAmount = amount * totalFee > feeDenominator ? amount.mul(totalFee).div(feeDenominator) : 0;
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }


    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
        launch();
    }


    // Enable/disable buy cooldown between trades interval in seconds
    function cooldownEnabled(bool _status, uint8 _interval) public authorized {
        BuyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }
    //GK
    function Manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function enable_blacklist(bool _status) public onlyOwner {
        BlacklistMode = _status;
    }

    function Manage_launch (address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
        islaunchExempt[addresses[i]] = status;
        }
    }
   
    
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
        uint256 amountToBurn = burnFee > 0 ? swapThreshold.mul(burnFee).div(totalFee) : 0;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBreward = amountBNB.mul(rewardFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee); 

        if(amountToBurn  > 0){ _basicTransfer(address(this), burnFeeReceiver, amountToBurn);}

        try distributor.deposit{value: amountBNBreward}() {} catch {}
        (bool successMarketing, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (bool successDev, /* bytes memory data */) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}(""); 
        require(successMarketing, "marketing receiver rejected ETH transfer");
        require(successDev, "dev receiver rejected ETH transfer");
        

        if(amountToLiquify > 0){
            addLiq(amountBNBLiquidity, amountToLiquify);
        }
    }

    function addLiq(uint256 amountBNBLiquidity, uint256 amountToLiquify) private{
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
    }

    // Check if autoBuyback is enabled
    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
            && !inSwap
            && autoBuybackEnabled
            && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number
            && address(this).balance >= autoBuybackAmount;
    }

    // Trigger a manual Buyback
    function triggerManualBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
        uint256 amountWithDecimals = amount * (10 ** 4);
        uint256 amountToBuy = amountWithDecimals.div(100);
        BuyTokens(amountToBuy, DEAD);
        if(triggerBuybackMultiplier){
            BuybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(BuybackMultiplierLength);
        }
    }
       
    function clearBuybackMultiplier() external authorized {
        BuybackMultiplierTriggeredAt = 0;
    }

    // Trigger an autoBuyback
    function triggerAutoBuyback() internal {
        BuyTokens(autoBuybackAmount, DEAD);
        if(autoBuybackMultiplier){
            BuybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(BuybackMultiplierLength);
        }
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }

    // Buy amount of tokens with bnb from the contract
    function BuyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    // Set autoBuyback settings
    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period, bool _autoBuybackMultiplier) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
        autoBuybackMultiplier = _autoBuybackMultiplier;
    }

    // Set Buybackmultiplier settings
    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        BuybackMultiplierNumerator = numerator;
        BuybackMultiplierDenominator = denominator;
        BuybackMultiplierLength = length;
    }
   
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

   
    function launch() internal {
        launchedAt = block.number;
    }

    // Set max Buy TX 
    function setBuyTxLimitInPercentBase1000(uint256 maxBuyTxPercent) external authorized {
        _maxBuyTxAmount = _totalSupply.mul(maxBuyTxPercent).div(1000);
    }

    // Set max sell TX 
    function setSellTxLimitInPercentBase1000(uint256 maxSellTxPercent) external authorized {
	require(_maxSellTxAmount >= _totalSupply / 1000); //cannot set below .1% (antihoneypot)
        _maxSellTxAmount = _totalSupply.mul(maxSellTxPercent).div(1000);
    }

    // Exempt from dividend
    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
     }

    function manage_FeeExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
        }
    }

    function manage_TxLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
        }
    }

    // Exempt from Buy Cooldown
    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setBuyFees(uint256 _liquidityFeeBuy, uint256 _BuybackFeeBuy, uint256 _rewardFeeBuy, uint256 _marketingFeeBuy, uint256 _devFeeBuy, uint256 _burnFeeBuy, uint256 _feeDenominator) external authorized {
        liquidityFeeBuy = _liquidityFeeBuy;
        BuybackFeeBuy = _BuybackFeeBuy;
        rewardFeeBuy = _rewardFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        devFeeBuy = _devFeeBuy;
        burnFeeBuy = _burnFeeBuy;
        updateBuyFees();
        feeDenominator = _feeDenominator;
        require(totalFeeBuy < 50, "Tax cannot be more than 50%");
    }

    function updateBuyFees() private{
        totalFeeBuy = liquidityFeeBuy.add(BuybackFeeBuy).add(rewardFeeBuy).add(marketingFeeBuy).add(devFeeBuy).add(burnFeeBuy);
    }
    
    function updateSellFees() private{
        totalFeeSell = liquidityFeeSell.add(BuybackFeeSell).add(rewardFeeSell).add(marketingFeeSell).add(devFeeSell).add(burnFeeSell);
    }


    function setSellFees(
        uint256 _liquidityFeeSell, uint256 _BuybackFeeSell, uint256 _rewardFeeSell, uint256 _marketingFeeSell, uint256 _devFeeSell, uint256 _burnFeeSell, uint256 _feeDenominator) external authorized {
        liquidityFeeSell = _liquidityFeeSell;
        BuybackFeeSell = _BuybackFeeSell;
        rewardFeeSell = _rewardFeeSell;
        marketingFeeSell = _marketingFeeSell;
        devFeeSell = _devFeeSell;
        burnFeeSell = _burnFeeSell;
        updateSellFees();
        feeDenominator = _feeDenominator;
        require(totalFeeSell < 60, "Tax cannot be more than 60%");
    }

    // Set the marketing, dev and liquidity receivers
    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _devFeeReceiver, address _burnFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        devFeeReceiver = _devFeeReceiver;       
        marketingFeeReceiver = _marketingFeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
   }

    function setSwapBackSettings(bool _enabled, uint256 _amount) public onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;  // dont forget to add decimals!
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function ClearStuckBalance() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(msg.sender).transfer(contractETHBalance);
    }

    function ClearForeignToken(address tokenAddress, uint256 tokens) external authorized returns (bool) {
     if(tokens == 0){
            tokens = IBEP20(tokenAddress).balanceOf(address(this));
        }
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }
    
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
  
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }
   
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    } 

   function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}