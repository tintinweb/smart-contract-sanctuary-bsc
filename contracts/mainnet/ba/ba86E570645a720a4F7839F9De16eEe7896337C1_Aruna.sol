/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT
/*
    Site: arunacoin.com
    Tg: https://t.me/arunacoin
    Name: Aruna
    Total Supply: 500,000 Tokens
    Decimals: 9
    Symbol: ARU
    Fees: Under 15% (code locked)
    Liquidity: 100% Burned or locked
*/

pragma solidity ^0.7.6;

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
    address internal creator;
    mapping (address => bool) internal authorizations;
    uint authorizationsCount; 

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
        creator = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public authorized {
        if (adr == creator){ require(msg.sender == creator, "Can't remove creator"); }
        require(adr != owner, "Can't remove owner");
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

    IDEXRouter router;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    IBEP20 RewardToken = IBEP20(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 minTokensReflection = 1000000000000; //min 1 token to receive reward

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
    uint256 public minDistribution = 1 * (10 ** 13);

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
            : IDEXRouter(routerAddress);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setRewardToken(IBEP20 _reward) external onlyToken {
        RewardToken = _reward;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if (amount < minTokensReflection){
            amount = 0;
        }

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
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);

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
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend(address shareholder) external onlyToken {
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

contract Aruna is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress =  0x10ED43C718714eb63d5aA57B78B54704E256024E; //pancake v2 router mainnet
    
    string constant _name = "Aruna";
    string constant _symbol = "ARU";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 500000 * (10**_decimals);

    uint256 public _maxTxAmount = _totalSupply;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 public burnFeeBuy         = 0;
    uint256 public liquidityFeeBuy    = 0;
    uint256 public reflectionFeeBuy   = 0;
    uint256 public marketingFeeBuy    = 0;
    uint256 public totalFeeBuy        = burnFeeBuy + liquidityFeeBuy + reflectionFeeBuy + marketingFeeBuy;

    uint256 public burnFeeSell         = 0;
    uint256 public liquidityFeeSell    = 0;
    uint256 public reflectionFeeSell   = 0;
    uint256 public marketingFeeSell    = 0;
    uint256 public totalFeeSell        = burnFeeSell + marketingFeeSell + reflectionFeeSell + liquidityFeeSell;

    uint256 public burnFeeTransfer         = 0;
    uint256 public liquidityFeeTransfer    = 0;
    uint256 public reflectionFeeTransfer   = 0;
    uint256 public marketingFeeTransfer    = 0;
    uint256 public totalFeeTransfer        = burnFeeTransfer + liquidityFeeTransfer + reflectionFeeTransfer + marketingFeeTransfer;

    uint256 public feeDenominator  = 1000;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    IDEXRouter public router;
    address public pair;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = 30 * (10**_decimals);
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        autoLiquidityReceiver = address(0); //burn auto liquidity
        marketingFeeReceiver = 0x75FdcAfb34186405c48F6CB2F26Db13817943e30; //fixed wallet

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
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 10000); //minimum 0,001%
        _maxTxAmount = amount;
    }

    function burn(uint256 amount) public {
        _balances[msg.sender] = _balances[msg.sender].sub(amount, "Insufficient Balance");
        _totalSupply = _totalSupply.sub(amount);
        
        emit Transfer(msg.sender, address(0), amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait to buy again");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit when is buying
        if (sender == pair){
            checkTxLimit(sender, amount);
        }

        if(shouldSwapBack(recipient)){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
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

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient]){
            return false;
        }else{
            return true;
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 burnToTake = 0;
        uint256 feetoTake = 0;

        if (sender == pair){ //buy
            burnToTake = burnFeeBuy;
            feetoTake = totalFeeBuy - burnFeeBuy;
        }else if (recipient == pair){ //sell
            burnToTake = burnFeeSell;
            feetoTake = totalFeeSell - burnFeeSell;
        }else{ //transfer
            burnToTake = burnFeeTransfer;
            feetoTake = totalFeeTransfer - burnFeeTransfer;
        }

        //burn immediately every transaction
        uint256 burnAmount = amount.mul(burnToTake).mul(100).div(feeDenominator * 100);
        if (burnAmount > 0){ 
            _totalSupply = _totalSupply.sub(burnAmount);
            emit Transfer(sender, address(0), burnAmount); 
        }
        uint256 feeAmount = amount.mul(feetoTake).mul(100).div(feeDenominator * 100);    
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount).sub(burnAmount);
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return msg.sender != pair
        && recipient == pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    //save stuck tokens on SC
    function saveStuckTokens(address account, uint256 _quant, address _tokenrec) external authorized {
        IBEP20(_tokenrec).transfer(account, _quant);
    }

    //save stuck BNB
    function saveStuckBNB(address account) external authorized {
        payable(account).transfer(address(this).balance);
    }

    function isFreeFees(address adr) public view returns (bool) {
        return isFeeExempt[adr];
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        require(_interval < 60, "Cooldown can't be hight than 1 minute"); //once it were openned, it can't be closed
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquidityFeeSell).div(totalFeeSell - burnFeeSell).div(2);
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

        //do not count burnfee
        uint256 totalBNBFee = totalFeeSell.sub(burnFeeSell).sub(liquidityFeeSell.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFeeSell).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFeeSell).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFeeSell).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,)  = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        
        // Supress warning msg
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

    function setFeesExchange(uint256 _burnFeeBuy, uint256 _liquidityFeeBuy, uint256 _reflectionFeeBuy, uint256 _marketingFeeBuy,
        uint256 _burnFeeSell, uint256 _liquidityFeeSell, uint256 _reflectionFeeSell, uint256 _marketingFeeSell, uint256 _feeDenominator) external authorized {
        burnFeeBuy = _burnFeeBuy;
        liquidityFeeBuy = _liquidityFeeBuy;
        reflectionFeeBuy = _reflectionFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        totalFeeBuy = _burnFeeBuy.add(_liquidityFeeBuy).add(_reflectionFeeBuy).add(_marketingFeeBuy);

        burnFeeSell = _burnFeeSell;
        liquidityFeeSell = _liquidityFeeSell;
        reflectionFeeSell = _reflectionFeeSell;
        marketingFeeSell = _marketingFeeSell;
        totalFeeSell = _burnFeeSell.add(_liquidityFeeSell).add(_reflectionFeeSell).add(_marketingFeeSell);

        feeDenominator = _feeDenominator;
        require(totalFeeBuy <= feeDenominator.div(100).mul(15), "Fees cannot be more than 15%");
        require(totalFeeSell <= feeDenominator.div(100).mul(15), "Fees cannot be more than 15%");
    }

    function setFeesTransfer(uint256 _burnFeeTransfer, uint256 _liquidityFeeTransfer, uint256 _reflectionFeeTransfer, uint256 _marketingFeeTransfer) external authorized {
        burnFeeTransfer = _burnFeeTransfer;
        liquidityFeeTransfer = _liquidityFeeTransfer;
        reflectionFeeTransfer = _reflectionFeeTransfer;
        marketingFeeTransfer = _marketingFeeTransfer;
        totalFeeTransfer = _burnFeeTransfer.add(_liquidityFeeTransfer).add(_reflectionFeeTransfer).add(_marketingFeeTransfer);

        require(totalFeeTransfer <= feeDenominator.div(100).mul(15), "Fees cannot be more than 15%");
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
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

    function setRewardToken(IBEP20 _reward) external authorized {
        distributor.setRewardToken(_reward);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

/* Airdrop */
function multiTransfer(address[] calldata addresses, uint256 tokens) external onlyOwner {
    address from = msg.sender;

    require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");

    uint256 SCCC = tokens * addresses.length;

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
}

event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}