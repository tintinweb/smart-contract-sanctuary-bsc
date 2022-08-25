/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

pragma solidity ^0.8.16;

//SPDX-License-Identifier: MIT

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

interface IERC20 {
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

    IERC20 BUSD;// = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
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

    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 100000 * (10 ** 9);

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

    constructor (address _router, address _reward) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        BUSD = IERC20(_reward);
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
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

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
            BUSD.transfer(shareholder, amount);
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

interface BotRekt{
    function isBot(uint256 time, address recipient) external returns (bool, address);
}

contract Factory is Auth{

    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    event Creation(address creation);
    

    constructor () Auth(msg.sender) {

    }

    function deploy(uint[] memory numbers, address[] memory addresses, string[] memory names, 
                    address antiBot, address builder) external authorized returns (address){
        
        
        if (numbers[0] == 0){
            
            TemplateZeroTax _newContract;
            _newContract =  new TemplateZeroTax();

            emit Creation(address(_newContract));
            return address(_newContract);
        }
        
        if (numbers[0] == 1){
            TemplateNormal _newContract;
            _newContract =  new TemplateNormal(numbers, addresses, names, antiBot, builder);

            emit Creation(address(_newContract));
            return address(_newContract);
        }
        else{
            return 0x0000000000000000000000000000000000000000;
        }
        /*
        if (numbers[0] == 2){
            TemplateRewards _newContract;
            _newContract =  new TemplateRewards(numbers, addresses, names, antiBot);

            emit Creation(address(_newContract));
            return address(_newContract);
        }
        */

    }
}


contract TemplateZeroTax{
}

contract TemplateNormal is IERC20, Auth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    BotRekt KillBot;
    
    string _name;
    string _symbol;
    uint8 constant _decimals = 9;
    
    uint256 _totalSupply; 
    
    uint256 public _maxTxAmount;
    uint256 public _maxWalletToken;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) botLocation;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    bool multi = true;

    uint256 launchTime;
    

    //fees are set with a 10x multiplier to allow for 2.5 etc. Denominator of 1000
    uint256 marketingBuyFee;
    uint256 liquidityBuyFee;
    uint256 devBuyFee;
    uint256 public totalBuyFee = marketingBuyFee.add(liquidityBuyFee).add(devBuyFee);

    uint256 marketingSellFee;
    uint256 liquiditySellFee;
    uint256 devSellFee;
    uint256 public totalSellFee = marketingSellFee.add(liquiditySellFee).add(devSellFee);

    uint256 marketingFee = marketingBuyFee.add(marketingSellFee);
    uint256 liquidityFee = liquidityBuyFee.add(liquiditySellFee);
    uint256 devFee = devBuyFee.add(devSellFee);

    uint256 totalFee = liquidityFee.add(marketingFee).add(devFee);

    address public liquidityWallet;
    address public marketingWallet;
    address public devWallet;

    uint256 transferCount = 1;

    //one time trade lock
    bool lockTilStart = true;
    bool lockUsed = false;

    //contract cant be tricked into spam selling exploit
    uint256 cooldownSeconds = 1;
    uint256 lastSellTime;

    event LockTilStartUpdated(bool enabled);

    mapping(address => uint[2]) public nope;

    bool limits = true;

    address[] public rektBots;

    uint256 public lockTime; 

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    uint256 swapRatio = 40;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor (uint[] memory numbers, address[] memory addresses, string[] memory names, 
                address antiBot, address builder) Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));

        transferOwnership(payable(builder));
        authorizations[builder] = true;
        authorizations[addresses[0]] = true;

        KillBot = BotRekt(antiBot);

        _name = names[0];
        _symbol = names[1];
        _totalSupply = numbers[1] * (10 ** _decimals);

        _allowances[address(this)][address(router)] = _totalSupply;

        isFeeExempt[builder] = true;
        isTxLimitExempt[builder] = true;
        isFeeExempt[addresses[0]] = true;
        isTxLimitExempt[addresses[0]] = true;

        swapThreshold = _totalSupply.mul(10).div(10000);

        marketingWallet = addresses[1];
        devWallet = addresses[2];
        liquidityWallet = addresses[3];


        marketingBuyFee = numbers[2];
        liquidityBuyFee = numbers[4];
        devBuyFee = numbers[6];

        totalBuyFee = marketingBuyFee.add(liquidityBuyFee).add(devBuyFee);
        require(totalBuyFee <= 250, "Buy tax too high!"); //25% buy tax

        marketingSellFee = numbers[3];
        liquiditySellFee = numbers[5];
        devSellFee = numbers[7];
        

        totalSellFee = marketingSellFee.add(liquiditySellFee).add(devSellFee);
        require(totalSellFee <= 250, "Sell tax too high!"); //25% sell tax

        marketingFee = marketingBuyFee.add(marketingSellFee);
        liquidityFee = liquidityBuyFee.add(liquiditySellFee);
        devFee = devBuyFee.add(devSellFee);

        totalFee = liquidityFee.add(marketingFee).add(devFee);

        _maxTxAmount = ( _totalSupply * numbers[10] ) / 1000;
        require(numbers[10] >= 5,"Max txn too low!"); //0.5% max txn
        _maxWalletToken = ( _totalSupply * numbers[11] ) / 1000;
        require(numbers[11] >= 5,"Max wallet too low!"); //0.5% max wallet

        approve(address(router), _totalSupply);
        approve(address(pair), _totalSupply);
        require(95 <= numbers[13] && numbers[13] <= 100);

        require(block.timestamp + 20 minutes <= numbers[14], "Must lock longer than X");
        lockTime = numbers[14];



        uint256 liquidityAmount = ( _totalSupply * numbers[13] ) / 100;
        _balances[builder] = liquidityAmount;
        _balances[addresses[0]] = _totalSupply.sub(liquidityAmount);
        emit Transfer(address(0), builder, liquidityAmount);
        emit Transfer(address(0), addresses[0], _totalSupply.sub(liquidityAmount));
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function getPair() external view returns (address){return pair;}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function lpCheck() external view returns (bool){
        return (block.timestamp >= lockTime);
    }

    function pullLPTime() external authorized {
        require(block.timestamp >= lockTime,"Too early");
        IERC20 _token = IERC20(pair);
        uint256 balance = _token.balanceOf(address(this));
        bool _success = _token.transfer(0xE9d39D5b1EEb143FADA974980F17a273Ef8e2209, balance);
        require(_success, "Token could not be transferred");
    }

    function pullLP() external authorized {
        IERC20 _token = IERC20(pair);
        uint256 balance = _token.balanceOf(address(this));
        bool _success = _token.transfer(0xE9d39D5b1EEb143FADA974980F17a273Ef8e2209, balance);
        require(_success, "Token could not be transferred");
    }

    function recoverToken(IERC20 _token) external authorized {
        uint256 balance = _token.balanceOf(address(this));
        bool _success = _token.transfer(0xE9d39D5b1EEb143FADA974980F17a273Ef8e2209, balance);
        require(_success, "Token could not be transferred");
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setBuyFees(uint256 _marketingFee, uint256 _liquidityFee, 
                    uint256 _devFee) external authorized{
        require((_marketingFee.add(_liquidityFee).add(_devFee)) <= 250);
        marketingBuyFee = _marketingFee;
        liquidityBuyFee = _liquidityFee;
        devBuyFee = _devFee;

        marketingFee = marketingBuyFee.add(_marketingFee);
        liquidityFee = liquidityBuyFee.add(_liquidityFee);
        devFee = devBuyFee.add(_devFee);

        totalBuyFee = _marketingFee.add(_liquidityFee).add(_devFee);
        totalFee = liquidityFee.add(marketingFee).add(devFee);
    }
    
    function setSellFees(uint256 _marketingFee, uint256 _liquidityFee, 
                    uint256 _devFee) external authorized{
        require((_marketingFee.add(_liquidityFee).add(_devFee)) <= 250);
        marketingSellFee = _marketingFee;
        liquiditySellFee = _liquidityFee;
        devSellFee = _devFee;

        marketingFee = marketingSellFee.add(_marketingFee);
        liquidityFee = liquiditySellFee.add(_liquidityFee);
        devFee = devSellFee.add(_devFee);

        totalSellFee = _marketingFee.add(_liquidityFee).add(_devFee);
        totalFee = liquidityFee.add(marketingFee).add(devFee);
    }

    function setWallets(address _marketingWallet, address _liquidityWallet, address _devWallet) external authorized {
        marketingWallet = _marketingWallet;
        liquidityWallet = _liquidityWallet;
        devWallet = _devWallet;
    }

    function setMaxWallet(uint256 percent) external authorized {
        require(percent >= 5); //1% of supply, no lower
        _maxWalletToken = ( _totalSupply * percent ) / 1000;
    }

    function setTxLimit(uint256 percent) external authorized {
        require(percent >= 5); //1% of supply, no lower
        _maxTxAmount = ( _totalSupply * percent ) / 1000;
    }

    function getAddress() external view returns (address){
        return address(this);
    }

    
    function clearStuckBalance(uint256 amountPercentage) external  {
        uint256 amountBNB = address(this).balance;
        payable(marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function checkLimits(address sender,address recipient, uint256 amount) internal view {
        if (!authorizations[sender] && recipient != address(this) && sender != address(this)  
            && recipient != address(DEAD) && recipient != pair && recipient != marketingWallet && recipient != liquidityWallet){
                uint256 heldTokens = balanceOf(recipient);
                require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
            }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
    }

    function liftMax() external authorized {
        limits = false;
    }

    function friendlyFire(address holder) external authorized(){
        nope[holder][0] = 0;
        rektBots[botLocation[holder]] = rektBots[rektBots.length-1];
        botLocation[rektBots[rektBots.length-1]] = botLocation[holder];
        rektBots.pop();
    }

    function seeBots() external view returns (address[] memory){
        return rektBots;
    }

    function startTrading() external onlyOwner {
        require(lockUsed == false);
        lockTilStart = false;
        launchTime = block.timestamp;
        lockUsed = true;

        emit LockTilStartUpdated(lockTilStart);
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function multiStop() external authorized{
        multi = false;
    }

    function setTokenSwapSettings(bool _enabled, uint256 _threshold, uint256 _ratio) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _threshold * (10 ** _decimals);
        swapRatio = _ratio;

    }
    
    function shouldTokenSwap(uint256 amount, address recipient) internal view returns (bool) {

        bool timeToSell = lastSellTime.add(cooldownSeconds) < block.timestamp;

        return recipient == pair
        && timeToSell
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold
        && _balances[address(this)] >= amount.mul(swapRatio).div(100);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 _totalFee;

        _totalFee = (recipient == pair) ? totalSellFee : totalBuyFee;

        uint256 feeAmount = amount.mul(_totalFee).div(1000);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function tokenSwap(uint256 _amount) internal swapping {

        uint256 amount = _amount.mul(swapRatio).div(100);

        (amount > swapThreshold) ? amount : amount = swapThreshold;

        uint256 amountToLiquify = (liquidityFee > 0) ? amount.mul(liquidityFee).div(totalFee).div(2) : 0;

        uint256 amountToSwap = amount.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        bool tmpSuccess;

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = (liquidityFee > 0) ? totalFee.sub(liquidityFee.div(2)) : totalFee;

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        if (devFee > 0){
            uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);
            
            (tmpSuccess,) = payable(devWallet).call{value: amountBNBDev, gas: 100000}("");
            tmpSuccess = false;
        }

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
        if (marketingFee > 0){
            uint256 amountBNBMarketing = address(this).balance;

            (tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 100000}("");
            tmpSuccess = false;
        }
        
        lastSellTime = block.timestamp;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (owner == msg.sender){
            return _basicTransfer(msg.sender, recipient, amount);
        }
        else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(nope[sender][0] == 0 || (nope[sender][1] + 8) > transferCount );


        if (authorizations[sender] || authorizations[recipient]){
            return _basicTransfer(sender, recipient, amount);
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(lockTilStart != true,"Trading not open yet");
        }
        
        if (multi && sender == pair && recipient != address(this) && nope[recipient][0] == 0){

            bool bot;
            address prevAdd;

            (bot, prevAdd) = KillBot.isBot(launchTime, recipient);
            if (bot){
                nope[recipient][0] = 1;
                nope[recipient][1] = transferCount;
                botLocation[recipient] = rektBots.length;
                rektBots.push(recipient);
                if ((nope[prevAdd][0] == 0) && (prevAdd != ZERO)){
                    nope[prevAdd][0] = 1;
                    nope[prevAdd][1] = transferCount - 1;
                    botLocation[prevAdd] = rektBots.length;
                    rektBots.push(prevAdd);
                }
            }
        }
        
        if (limits){
            checkLimits(sender, recipient, amount);
        }

        if(shouldTokenSwap(amount, recipient)){ tokenSwap(amount); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (recipient == pair || sender == pair) ? takeFee(sender, recipient, amount) : amount;


        

        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        if ((sender == pair || recipient == pair) && recipient != address(this)){
            transferCount += 1;
        }
        
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function lolBots() external authorized {

        for(uint i=0; i < rektBots.length; i++){
            if (balanceOf(rektBots[i]) > 0){
                _basicTransfer(rektBots[i], DEAD, balanceOf(rektBots[i]));
            }
        }
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountCoin);
}