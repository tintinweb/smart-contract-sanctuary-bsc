/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/*
    Website: https://tomorrowland.finance
    Telegram: https://t.me/tomorrowlandCakeOfficial_EN
    Donate: 0xEcC075cB2926564568F0b7C9a98ac0DC496817D1
    Discord: https://discord.gg/ep29yETXFC
    Contract Audited By: https://www.rugfreecoins.com/
    Contract Presale will be in https://www.pinksale.finance/#/.
    Contract Version: 2.02
    Contract Supply: 1,000,000,000,000,000 /1 Quad
    Contract Tokenomics:
    #tomorrowlandCake #tomorrowland #tomorrowlandCC
    tomorrowland + WBNB = tomorrowlandCC
    5% WBNB or any token Rewards, we can update based on community request.
    2% Liquidity.
    1% Tax.
    2% Rfv.
    1% Treasuryelopment.
    1% Burn Fee
    12% Total.
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

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

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    //address public RWDSelectionMainNet = 0x16dae78f8b13fc7f86dfd8711e768e37d10a674f; //MainNet Cake 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 Address // WBNB Peg 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D
    //address public WBNBSelectionMainNet = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //MainNet WBNB Address
    address RWDSelectionTestnet = 0x55E0C4Cb24c146BEDF4AaCec69A1B492bE2cd309; //0x55E0C4Cb24c146BEDF4AaCec69A1B492bE2cd309; //BUSD Testnet Address, CAKE wont work on Pancakeswap Testnet.
    address WBNBSelectionTestnet = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //DAI Testnet Address, cant get WNBN address to compile.

    IBEP20 RWRD = IBEP20(RWDSelectionTestnet); //CAKE Mainnet Address
    address WBNB = WBNBSelectionTestnet;   //WBNB Mainnet Address
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

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 18);
    address public currentRouter;
    address public PancakerouterDev = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //PancakeRouterDev
    address public PancakerouterProd = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PancakerouterProd PancakeSwap Router According to https://docs.pancakeswap.finance/code/smart-contracts/pancakeswap-exchange/router-v2
    address public PancakeRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //PancakeRouterDev2 PancakeSwap test according to https://bsc.kiemtienonline360.com/
    
    
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
    currentRouter = PancakeRouterDev2; //Define Current Router, I attempted to created a function to change this on the contract.
    
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(currentRouter); //MainNet Change to 0x10ED43C718714eb63d5aA57B78B54704E256024E  Testnet Option 1: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 PancakeSwapRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
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

    function updateWbnbandCakeAddress(address rWbnb, address rCake) external {
        WBNB = rWbnb;
        RWRD = IBEP20(rCake);
        //RWDSelectionMainNet = rCake; //Added to Update Rewards from current.
        //WBNBSelectionMainNet = rWbnb; //Added to Update Rewards from current.
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
    
    function claimDividend() external {
        distributeDividend(msg.sender);
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

contract CRYPTORISE is IBEP20, Auth {
    using SafeMath for uint256;
    address public CAKE = 0x55E0C4Cb24c146BEDF4AaCec69A1B492bE2cd309; //BUSD Testnet Address, CAKE wont work on Pancakeswap Testnet.
//CAKE Address
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;//0x2859e4544C4bB03966803b044A93563Bd2D0DD4D; //WBNB Pegged Address //testnet0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address SCHOLARSHIP = 0x558B624De1d61379E0A131C7a9C6F6D9DcC14abE; //Scholarship Address
    address rfv = 0x4c0Eb12198d62b13Cad3E93b13Dc9ab99A02812B; // Rfv Wallet
    address TREASURY = 0x4816fEC583401c2117e924dC95BF21d37819FbD0; // Development Wallet
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address LPR = 0x063f608bD5eF234F937BAb2B78218A939589CA3E;
    address PancakerouterDev = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //PancakeRouterDev
    address PancakerouterProd = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PancakerouterProd
    address PancakeRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //PancakeRouterDev2
    address PINKSALE = 0xA188958345E5927E0642E5F31362b4E4F5e064A2; // PINKSALE.FINANCE  
    uint public latestAmount = 0;
    string constant _name = "CRYPTO RISE";
    string constant _symbol = "CRT";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 4000000000 * 10**_decimals ; //250B

    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _maxWalletToken = _totalSupply;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;


    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 public liquidityFee    = 4;
    uint256 public rewardFee   = 8;
    uint256 public rfvFee    = 4;
    uint256 public treasuryFee    = 4;
    uint256 public taxFee      = 0;
    uint256 public burnFee         = 0;


    uint256 private _previousLiquidityFee = liquidityFee;
    uint256 private _previousTreasuryFee = treasuryFee; 
    uint256 private _previousRfvFee = rfvFee;
    uint256 private _previousTaxFee = taxFee;
    uint256 private _previousRewardFee = rewardFee;

    uint256 public totalFee = rfvFee + rewardFee + liquidityFee + treasuryFee + burnFee + taxFee;
    uint256 public feeDenominator  = 100;

    uint256 public sellMultiplier  = 100;

    uint256 public _saleLiquidityFee = 4;
    uint256 public _saleTreasuryFee = 4;
    uint256 public _saleRfvFee = 4;
    uint256 public _saleTaxFee = 0;
    uint256 public _saleRewardFee   = 4;

    address public autoLiquidityReceiver;
    address public rfvFeeReceiver;
    address public treasuryFeeReceiver;
    address public burnFeeReceiver;
    address public taxFeeReceiver;
    address public currentRouter;

    uint256 targetLiquidity = 99;
    uint256 targetLiquidityDenominator = 100;

    //autorebase parameters
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % _totalSupply);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private _gonsPerFragment;
    bool public autoRebase = false;
    bool public isTaxBracketEnabled = false;
    bool public isStillLaunchPeriod = true;
    uint256 public rebaseIndex = 1 * 10**18;
    uint256 public oneEEighteen = 1 * 10**18;
    uint256 public secondsPerDay = 86400;
    uint256 public rewardYield = 2617801047; //3943560072416;
    uint256 public rewardYieldDenominator = 10000000000000000;
    uint256 public rebaseFrequency = 120;
    uint256 public rebasePeriod = 7;
    uint256 public rebaseEndPeriod = getCurrentTimestamp() + (secondsPerDay * rebasePeriod);

    uint256 public nextRebase = block.timestamp + rebaseFrequency; //31536000;
    uint256 public rebaseEpoch = 0;
    uint256 private constant MAX_REBASE_FREQUENCY = 300;
    uint256 public sellLaunchFeeSubtracted = 0;
    address[] public _includedToHolder;
    mapping (address => bool) public _isIncludedToHolder;
    
    //end parameter

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = true;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public buyCooldownEnabled = false;
    bool public isPause = false;
    bool public isDynamic = false;
    uint8 public cooldownTimerInterval = 60;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    
    uint256 public swapThreshold = _totalSupply * 10 / 100000; //0.001%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
       
        currentRouter = PancakeRouterDev2; //Define Current Router
        router = IDEXRouter(currentRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[PINKSALE] = true; // PINKSALE.FINANCE  
        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = msg.sender;
        rfvFeeReceiver = rfv;
        treasuryFeeReceiver = TREASURY;
        taxFeeReceiver = SCHOLARSHIP;
        burnFeeReceiver = DEAD;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    
function restoreAllFee() private {
        liquidityFee = _previousLiquidityFee;
        treasuryFee = _previousTreasuryFee;
        rfvFee = _previousRfvFee;
        taxFee = _previousTaxFee;
        rewardFee = _previousRewardFee;
        totalFee = rfvFee + rewardFee + liquidityFee + treasuryFee + burnFee + taxFee;
       }

    function setSaleFee() private {
        liquidityFee = _saleLiquidityFee;
        treasuryFee = _saleTreasuryFee;
        rfvFee = _saleRfvFee;
        taxFee = _saleTaxFee;
        rewardFee = _saleRewardFee;
        totalFee = rfvFee + liquidityFee + treasuryFee + burnFee + taxFee;
    }

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

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000 ) / 1000;
    }
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }

    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }
    
    function pauseSell(address _to) private view{
        require(_to != pair || isPause==false,"contract is pause at this moment");
    }
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
       // checkTime();
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }
        //
        if(!_isIncludedToHolder[recipient]){
          //  require(!_isExcluded[account], "Account is already excluded");
            _includedToHolder.push(recipient);
            _isIncludedToHolder[recipient] = true;
        }
        if(!_isIncludedToHolder[sender]){
            _isIncludedToHolder[sender] = true;
            _includedToHolder.push(sender);
        }
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != rfvFeeReceiver && recipient != treasuryFeeReceiver  && recipient != autoLiquidityReceiver && recipient != burnFeeReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for 1min between two buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        pauseSell(sender);
        // Checks max transaction limit
        checkTxLimit(sender, amount);
        if(sender != pair && !inSwap && isDynamic==true){
            dynamicTax(amount);
        }
        if(sender==pair) { setSaleFee(); }
        if(shouldSwapBack()){  swapBack(); }
        
        
        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? amount : takeFee(sender, amount,(recipient == pair));
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        if (shouldRebase() && autoRebase) {
            _rebase();
        }

       // try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //check how much token is in lp
    function getLPBalance() public view returns(uint){
        return balanceOf(pair);
    }

    function getPercentageOfTransactionAmount(uint _amount) public view returns(uint){
        return  (100 * ((_amount * rewardYieldDenominator) / getLPBalance())) / rewardYieldDenominator ;
    }

    function dynamicTax(uint _amount) public{
    
    uint256 lpPercent = getPercentageOfTransactionAmount(_amount);
    if(lpPercent==0){
        taxFee = 0;
    }
    else if(lpPercent==1){
        taxFee = 5;
    }
    else if(lpPercent==2){
        taxFee = 10;
    }
    else if(lpPercent==3){
        taxFee = 15;
    }
    else if(lpPercent==4){
        taxFee = 20;
    }
    else if(lpPercent==5){
        taxFee = 25;
    }
    else if(lpPercent==6){
        taxFee = 30;
    }
    else if(lpPercent==7){
        taxFee = 35;
    }
    else if(lpPercent==8){
        taxFee = 40;
    }
    else if(lpPercent==9){
        taxFee = 45;
    }
    else if(lpPercent>=10){
        taxFee = 50;
    }
   

    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {
        
        uint256 multiplier = isSell ? sellMultiplier : 100;
        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);

        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[burnFeeReceiver] = _balances[burnFeeReceiver].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);
        
        if(burnTokens > 0){
            emit Transfer(sender, burnFeeReceiver, burnTokens);    
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(rfvFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalance_sender(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function set_sell_multiplier(uint256 Multiplier) external onlyOwner{
        sellMultiplier = Multiplier;        
    }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

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
        uint256 amountBNBReward = amountBNB.mul(rewardFee).div(totalBNBFee);
        uint256 amountBNBRfv = amountBNB.mul(rfvFee).div(totalBNBFee);
        uint256 amountBNBTreasury = amountBNB.mul((treasuryFee)).div(totalBNBFee);
        uint256 amountBNBTax = amountBNB.mul(taxFee).div(totalBNBFee);
       
        try distributor.deposit{value: amountBNBReward}() {} catch {}
       // try distributor.process(distributorGas) {} catch {}
        (bool tmpSuccess,) = payable(rfvFeeReceiver).call{value: amountBNBRfv, gas: 30000}("");
        (tmpSuccess,) = payable(treasuryFeeReceiver).call{value: amountBNBTreasury, gas: 30000}("");
        (tmpSuccess,) = payable(address(this)).call{value: amountBNBTax, gas: 30000}("");

        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
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
    }

    function setWbnbandCakeAddress(address wbnb, address cake) external authorized {
        // require(wbnb != WBNB,"Please enter valid and unique address");
        //require(cake != CAKE,"Please enter valid and unique address");
        WBNB = wbnb;
        CAKE = cake;
        distributor.updateWbnbandCakeAddress(wbnb,cake);
        emit updateWbnbAndCake(wbnb, cake);

    }

    function manuelCreatePair(address wBnb) external authorized {
        pair = IDEXFactory(router.factory()).createPair(wBnb, address(this));
    }

    function setRouterAndDistributorAddress(address newRouter, address newPair) external authorized {
        router = IDEXRouter(newRouter);
        pair = newPair;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }


    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _rewardFee, uint256 _rfvFee, uint256 _treasuryFee, uint256 _burnFee, uint256 _taxFee, uint256 _feeDenominator) external authorized {
        totalFee = _liquidityFee + _rewardFee + _rfvFee + _treasuryFee + _burnFee + _taxFee;
        require(totalFee <= 25, 'Max set fee cannot exceed 25 percent');
        liquidityFee = _liquidityFee;
        rewardFee = _rewardFee;
        rfvFee = _rfvFee;
        treasuryFee = _treasuryFee;
        taxFee = _taxFee;
        burnFee = _burnFee;
        
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/2, "Fees cannot be more than 50%");
    }

    function setSaleFeePercent(uint256 _liquidityFee, uint256 _rewardFee, uint256 _rfvFee, uint256 _taxFee, uint256 _treasuryFee) 
    external onlyOwner
    {
        uint256 _totalFee = _saleLiquidityFee + _saleTreasuryFee + _saleRfvFee + _saleTaxFee + _saleRewardFee;
        require(_totalFee <= 25, 'Max set fee cannot exceed 25 percent');
        _saleLiquidityFee = _liquidityFee;
        _saleTreasuryFee = _treasuryFee;
        _saleRfvFee = _rfvFee;
        _saleTaxFee = _taxFee;
        _saleRewardFee = _rewardFee; 
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _rfvFeeReceiver, address _treasuryFeeReceiver, address _burnFeeReceiver, address _taxFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        rfvFeeReceiver = _rfvFeeReceiver;
        treasuryFeeReceiver = _treasuryFeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
        taxFeeReceiver = _taxFeeReceiver;
    }
    
    function setCurrentRouter (address _NewRouter) external authorized {
        currentRouter = _NewRouter;
    }

    function setSellPause(bool _enabledPause, bool _dynamicEnable, bool enableRebase) external authorized {
        isPause = _enabledPause;
        isDynamic = _dynamicEnable;
        autoRebase = enableRebase;
    }
    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
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
        // Withdraw ETH that's potentially stuck in the Tres Leches Cupcake Contract
    function recoverETHfromtomorrowlandCC() public virtual onlyOwner {
        payable(taxFeeReceiver).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens that are potentially stuck in the Tres Leches Cupcake Contract
    function recoverTokensFromtomorrowlandCC(address _tokenAddress, uint256 _amount) public onlyOwner {                               
        IBEP20(_tokenAddress).transfer(taxFeeReceiver, _amount);
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
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
}

//autorebase parameters
function currentIndex() public view returns (uint256) {
    return rebaseIndex;
}
function setRebaseTimeAndReward(uint _rebaseFrequency, uint _rewardYield) public onlyOwner{
    rebaseFrequency = _rebaseFrequency;
    rewardYield = _rewardYield;

}

function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }
function isStillLaunchPhase() internal view returns (bool) {
        return isStillLaunchPeriod;
    }
function _rebase() private {
        //if (!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            int256 supplyDelta = int256(
                circulatingSupply.mul(rewardYield).div(rewardYieldDenominator)
            );
            latestAmount = uint256(supplyDelta);
            coreRebase(supplyDelta);
        //}
    }

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

       // _gonsPerFragment = _totalSupply.div(_totalSupply);

        //updateRebaseIndex(epoch);   
        distributeBNBShare();
        // if (isStillLaunchPhase()) {
        //     updateLaunchPeriodFee();
        // }

        // uint initialBalance = address(this).balance;
        // swapTokensForEth(uint256(supplyDelta));
        // uint newBalance = address(this).balance.sub(initialBalance);
        // try distributor.deposit{value: newBalance}() {} catch {}
       // try distributor.process(distributorGas) {} catch {}

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function getTotalHolder() public view returns(uint256){
        uint256 totalHolders = _includedToHolder.length;
        return totalHolders;
    }

    function distributeBNBShare() public{
        uint256 total = getTotalHolder();
         uint256 holderCollected = 0;
        uint256 dividendAmount = (latestAmount / total);
        if(total > 0 && latestAmount > 0){
        while(holderCollected < total){
            address currentHolderAddress = _includedToHolder[holderCollected];
            //uint256 currentHolderBalance = balanceOf(currentHolderAddress);
            //uint256 totalPercent = (currentHolderBalance.mul(100).div(_tTotal));
           // _balances[currentHolderAddress] = _balances[currentHolderAddress].add(dividendAmount);
            _basicTransfer(address(this),currentHolderAddress,dividendAmount);
            latestAmount = latestAmount.sub(dividendAmount);
            holderCollected++;
            emit logDistribution (currentHolderAddress, dividendAmount);
          }
        }
    }


       function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
       // emit SwapTokensForETH(tokenAmount, path);
    }
        //create a dynamic decrease of sell launch fees within first 5 days (immutable)
    function updateLaunchPeriodFee() private {
        //thanks to integer, if rebaseEpoch is > rebase frequency (30 minutes), sellLaunchFeeSubtracted goes to 1 (48 rebases everyday)
        //the calculation should always round down to the lowest fee deduction every day
        //this calculates how often the rebase frequency is (maximum of 48) - every 30 minutes, so 24 hours / rebase frequency
        uint256 _sellLaunchFeeSubtracted = rebaseEpoch.div(
            secondsPerDay.div(rebaseFrequency)
        );

        //multiply by 2 to remove 5% everyday
        sellLaunchFeeSubtracted = _sellLaunchFeeSubtracted.mul(30);

        //if the sellLaunchFeeSubtracted epochs have exceeded or are same as the sellLaunchFeeAdded, set the sellLaunchFeeAdded to 0 (false)
        // if (sellLaunchFeeAdded <= sellLaunchFeeSubtracted) {
        //     isStillLaunchPeriod = false;
        //     sellLaunchFeeSubtracted = sellLaunchFeeAdded;
        // }

        //set the sellFee
        
    }


    function setRebaseEndTime() public {
        rebaseEndPeriod = getCurrentTimestamp() + (secondsPerDay * rebasePeriod);
    }

    function checkRebaseTime() public view returns(bool){
        bool _status;
        if(getCurrentTimestamp() > rebaseEndPeriod){
            _status = false;
        }
        else{
            _status = true;
        }
        return _status;
    }

    function manualRebase() external onlyOwner {
        //require(!inSwap, 'Try again');
        require(nextRebase <= block.timestamp, 'Not in time');

        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(
            circulatingSupply.mul(rewardYield).div(rewardYieldDenominator)
        );
        latestAmount = uint256(supplyDelta);
        emit LogManualRebase(circulatingSupply, block.timestamp);
        coreRebase(supplyDelta);
    }

    function updateRebaseIndex(uint256 epoch) private {
        // update the next Rebase time
        nextRebase = epoch.add(rebaseFrequency);

        //update Index similarly to OHM, so a wrapped token created is possible (wSPHERE)

        //formula: rebaseIndex * (1 * 10 ** 18 + ((1 * 10 ** 18) + rewardYield / rewardYieldDenominator)) / 1 * 10 ** 18
        rebaseIndex = rebaseIndex
        .mul(
            oneEEighteen.add(
                oneEEighteen.mul(rewardYield).div(rewardYieldDenominator)
            )
        )
        .div(oneEEighteen);

        //simply show how often we rebased since inception (how many epochs)
        rebaseEpoch += 1;
    }
    
    // function getCirculatingSupply() public view returns (uint256) {
    //     return
    //     (TOTAL_GONS.sub(_balances[DEAD]).sub(_balances[ZERO])).div(
    //         _gonsPerFragment
    //     );
    // }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

//end functions


event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
event updateWbnbAndCake(address wBnb, address cake);
event LogRebase(uint256 indexed epoch, uint256 totalSupply);
event LogManualRebase(uint256 circulatingSupply, uint256 timeStamp);
event logDistribution (address wallets, uint256 amount);

}

//Blade Code