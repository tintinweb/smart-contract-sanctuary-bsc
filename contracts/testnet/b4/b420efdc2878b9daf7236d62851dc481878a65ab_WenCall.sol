/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

//SPDX-License-Identifier: MIT

//https://bsc.kiemtienonline360.com/
//https://pancake.kiemtienonline360.com/
//https://amm.kiemtienonline360.com/

pragma solidity ^0.8.16;

/**IUniswapV2Pair
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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

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


    //BUSD TESTNET
    IBEP20 Dividend = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); 

    //mainnet
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    //testnet
    //WBNB
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

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

    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;
    uint256 rol = 0;
    
    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
    

   //main 0x10ED43C718714eb63d5aA57B78B54704E256024E;
   //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 ;

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
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
        uint256 balanceBefore = Dividend.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(Dividend);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = Dividend.balanceOf(address(this)).sub(balanceBefore);

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
            Dividend.transfer(shareholder, amount);
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

contract WenCall is IBEP20, Auth {
    using SafeMath for uint256;
    //main
    //utilisé pour la paire pancakeswap / bnb
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //testnet
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    address MkgDevWallet = 0x537bA6588029FFD149A491283b9D7B3D0BDDaFA5; 
    address TeamWallet   = 0x0000000000000000000000000000000000000000; // NOT USE FOR THE MOMENT
    address BBBWallet    = 0xd3F045787d48e0D410DAe421AD54E4bcdA20b687; 


    string constant _name = "WenCall";
    string constant _symbol = "WCL";
    uint8 constant  _decimals = 18;
 
   
    //100000000
    uint256 _totalSupply = 100000000 * (10 ** _decimals);

    //20%
    uint256 public _maxTxAmount = _totalSupply * 20 /100;

    //20%
    uint256 public _maxWalletToken =( _totalSupply * 20 )/100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public isMarketPair;

    //PAS DE LIQUIDITY FEE A L'ACHAT
    uint256 public liquidityFee = 0;
    uint256 public saleLiquidityFee = 1;

    uint256 public reflectionFee = 1;
    uint256 public saleReflectionFee = 1;

    uint256 public MkgDevFee = 6;
    uint256 public saleMkgDevFee = 6;

    //PAS POUR L'INSTANT D'OU LE NOM SETTING DU WALLET 
    uint256 public TeamFee = 0;
    uint256 public saleTeamFee = 0;

    uint256 public BBBFee = 1;
    uint256 public saleBBBFee = 1;

    uint256 public totalFee = liquidityFee.add(reflectionFee).add(MkgDevFee).add(TeamFee).add(BBBFee);
    uint256 public totalSellFee = saleLiquidityFee.add(saleReflectionFee).add(saleMkgDevFee).add(saleTeamFee).add(saleBBBFee);

    uint256 feeDenominator  = 100;

    address public autoLiquidityReceiver;
    address public MkgDevFeeReceiver;
    address public TeamFeeReceiver;
    address public BBBFeeReceiver;


    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = true;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 60;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000;
    bool inSwap;

    //si boolean inSwap = true then execute
    modifier swapping() { 
        inSwap = true;
        _; 
        inSwap = false;
    }

    constructor () Auth(msg.sender) {

        //main 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 ;

        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = address(this);
        MkgDevFeeReceiver = MkgDevWallet;
        TeamFeeReceiver = TeamWallet;
        BBBFeeReceiver = BBBWallet;
        isMarketPair[address(pair)] = true; 
  
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        return approve(spender, ~uint256(0));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    //settting the maximum permitted wallet holding (percent of total supply)
     function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

       
        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }


        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != MkgDevFeeReceiver && 
        recipient != autoLiquidityReceiver && recipient != BBBFeeReceiver && recipient != TeamFeeReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit
        checkTxLimit(sender, amount);

        // Liquidity, taxes ..
        if(shouldSwapBack()){ swapBack(); }

       
        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived;

        //IF BUY WE USE FUCTION TAKEBUYFEE
        if (sender == pair ) {
            amountReceived = shouldTakeFee(recipient) ? takeBuyFee(sender, amount) : amount;
        }
        //IF SELL WE USE FUNCTION TAKESELLFEE
        if (recipient == pair ){
           amountReceived = shouldTakeFee(sender) ? takeSellFee(sender, amount) : amount;
        }

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
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function clearStuckBalance(address addr) public onlyOwner{
        (bool sent,) =payable(addr).call{value: (address(this).balance)}("");
        require(sent);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    

    function takeBuyFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(totalFee).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(totalSellFee).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function takeSellFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalSellFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    //if caller is not the lp / swapEnabled 
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair 
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }


    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }


    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }



    function swapBack() internal swapping {

        //si targetLiguidity > targetLiquidityDenominator return true
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
        uint256 amountBNBLiquidity =  amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMkgDev =  amountBNB.mul(MkgDevFee).div(totalBNBFee);
        uint256 amountBNBTeam =  amountBNB.mul(TeamFee).div(totalBNBFee);
        uint256 amountBNBBBB = amountBNB.mul(BBBFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        (bool tmpMkgDev,) = payable(MkgDevFeeReceiver).call{value: amountBNBMkgDev, gas: 30000}("");
        // only to supress warning msg
        tmpMkgDev = false;

        (bool tmpTeam,) = payable(TeamFeeReceiver).call{value: amountBNBTeam, gas: 30000}("");
        // only to supress warning msg
        tmpTeam = false;

        (bool tmpBBB,) = payable(BBBFeeReceiver).call{value: amountBNBBBB, gas: 30000}("");
        // only to supress warning msg
        tmpBBB = false;
  
        uint256 amountToL = amountToLiquify;

        if(amountToL > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToL,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToL);
        }

        
    }


    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
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

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _MkgDevFee,uint256 _BBBFee,uint256 _TeamFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        MkgDevFee = _MkgDevFee;
        TeamFee = _TeamFee;
        BBBFee = _BBBFee;
        totalFee = _liquidityFee.add(reflectionFee).add(MkgDevFee).add(TeamFee).add(BBBFee);
        //feeDenominator devrait être passé à 100
        feeDenominator = _feeDenominator;
        //pas plus grand que 25%
        require(totalFee < feeDenominator/4);
    }

    function setSellFees(uint256 _saleLiquidityFee, uint256 _saleReflectionFee, uint256 _saleMkgDevFee,uint256 _saleBBBFee,uint256 _saleTeamFee, uint256 _feeDenominator) external authorized {
        saleLiquidityFee = _saleLiquidityFee;
        saleReflectionFee = _saleReflectionFee;
        saleMkgDevFee = _saleMkgDevFee;
        saleTeamFee = _saleTeamFee;
        saleBBBFee = _saleBBBFee;
        totalSellFee = saleLiquidityFee.add(saleReflectionFee).add(saleMkgDevFee).add(saleTeamFee).add(saleBBBFee);
        //feeDenominator devrait être passé à 100
        feeDenominator = _feeDenominator;
        //pas plus grand que 25%
        require(totalSellFee < feeDenominator/4);
    }

    function setReflectionFee (uint256 _reflectionFee, uint256 _feeDenominator) external authorized {
        reflectionFee = _reflectionFee;
        feeDenominator = _feeDenominator;
        require(saleReflectionFee < feeDenominator/5);
    }

    function setSaleReflectionFee (uint256 _saleReflectionFee, uint256 _feeDenominator) external authorized {
        saleReflectionFee = _saleReflectionFee;
        feeDenominator = _feeDenominator;
        require(saleReflectionFee < feeDenominator/5);
    }

    function setMkgDevFee (uint256 _saleMkgDevFee, uint256 _feeDenominator) external authorized {
        saleMkgDevFee = _saleMkgDevFee;
        feeDenominator = _feeDenominator;
        require(saleMkgDevFee < feeDenominator/5);
    }

    function setSaleMkgDevFee (uint256 _saleReflectionFee, uint256 _feeDenominator) external authorized {
        saleReflectionFee = _saleReflectionFee;
        feeDenominator = _feeDenominator;
        require(saleReflectionFee < feeDenominator/5);
    }
    
    function setTeamFee (uint256 _TeamFee, uint256 _feeDenominator) external authorized {
        TeamFee = _TeamFee;
        feeDenominator = _feeDenominator;
        require(TeamFee < feeDenominator/5);
    }

    function setSaleTeamFee (uint256 _saleTeamFee, uint256 _feeDenominator) external authorized {
        saleTeamFee = _saleTeamFee;
        feeDenominator = _feeDenominator;
        require(saleTeamFee < feeDenominator/5);
    }
    
    function setBBBFee (uint256 _saleBBBFee, uint256 _feeDenominator) external authorized {
        saleMkgDevFee = _saleBBBFee;
        feeDenominator = _feeDenominator;
        require(saleBBBFee < feeDenominator/5);
    }

    function setSaleBBBFee (uint256 _saleBBBFee, uint256 _feeDenominator) external authorized {
        saleBBBFee = _saleBBBFee;
        feeDenominator = _feeDenominator;
        require(saleBBBFee < feeDenominator/5);
    }
     

    function setFeeReceivers(address _autoLiquidityReceiver, address _MkgDevFeeReceiver, address _BBBFeeReceiver, address _TeamFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        MkgDevFeeReceiver = _MkgDevFeeReceiver;
        TeamFeeReceiver = _TeamFeeReceiver;
        BBBFeeReceiver = _BBBFeeReceiver;
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

    function setMarketingWalletAddress(address _MarketingWallet) external onlyOwner() {
        MkgDevWallet = _MarketingWallet;
    }

    function setBuyBackBurnWalletAddress(address _BBBWallet) external onlyOwner() {
       BBBWallet = _BBBWallet;
    }

    function setTeamlletAddress(address _TeamWallet) external onlyOwner() {
       TeamWallet = _TeamWallet;
    }

      function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }


    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}