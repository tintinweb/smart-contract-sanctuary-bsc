/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

/*
 _______                       __                            __               ______              __            _______                        __                                    __ 
|       \                     |  \                          |  \             /      \            |  \          |       \                      |  \                                  |  \
| $$$$$$$\ __    __  __    __ | $$____    ______    _______ | $$   __       |  $$$$$$\  ______  _| $$_         | $$$$$$$\  ______    ______  _| $$_     ______    _______   ______  | $$
| $$__/ $$|  \  |  \|  \  |  \| $$    \  |      \  /       \| $$  /  \      | $$   \$$ |      \|   $$ \        | $$__/ $$ /      \  /      \|   $$ \   /      \  /       \ /      \ | $$
| $$    $$| $$  | $$| $$  | $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$      | $$        \$$$$$$\\$$$$$$        | $$    $$|  $$$$$$\|  $$$$$$\\$$$$$$  |  $$$$$$\|  $$$$$$$|  $$$$$$\| $$
| $$$$$$$\| $$  | $$| $$  | $$| $$  | $$ /      $$| $$      | $$   $$       | $$   __  /      $$ | $$ __       | $$$$$$$ | $$   \$$| $$  | $$ | $$ __ | $$  | $$| $$      | $$  | $$| $$
| $$__/ $$| $$__/ $$| $$__/ $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\       | $$__/  \|  $$$$$$$ | $$|  \      | $$      | $$      | $$__/ $$ | $$|  \| $$__/ $$| $$_____ | $$__/ $$| $$
| $$    $$ \$$    $$ \$$    $$| $$    $$ \$$    $$ \$$     \| $$  \$$\       \$$    $$ \$$    $$  \$$  $$      | $$      | $$       \$$    $$  \$$  $$ \$$    $$ \$$     \ \$$    $$| $$
 \$$$$$$$   \$$$$$$  _\$$$$$$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$        \$$$$$$   \$$$$$$$   \$$$$        \$$       \$$        \$$$$$$    \$$$$   \$$$$$$   \$$$$$$$  \$$$$$$  \$$
                    |  \__| $$                                                                                                                                                          
                     \$$    $$                                                                                                                                                          
                      \$$$$$$   



Tokenomics!


BUSD rewards! We understand that the market is in a rough state, so why not get rewards in a STABLEcoin? Secure your profits, 
while maintaining the healthy nature of the chart!

3% marketing (To get all the best influencers on the BSC space of telegram / twitter
3% rewards (3% of all transactions will reward holders in BUSD!~~~) 
3% Buyback (We just don't buyback, we'll burn those tokens thus decreasing the total supply and making the current supply more scarce! We will not announce
buybacks to avoid speculation, and manipulation. Please do not ask WEN BUYBACK to use the friendly whale as exit liquidity. We want to recapture the 
essence of what BSC used to be, not just a pump and dump, but allowing the project to grow to the point where the team will WORK FOR YOU. We have 
a lot of neat ideas that we'd like to create, just give us the opportunity.)
3% LP (To increase the strength of new floors and decrease volatility of traders who blatantly destroy charts)
1% development (Development and Sustainability)


2% max wallet
20000 Max wallet (2%)
10000 Max transaction (1%)

Liquidity will ONLY be locked for 3 days and will be extended when the project surpasses certain thresholds. Please do not ask to extend it, we won't make the 
first mistake and extend the lock PREMATURELY for no reasonn again. We extended our first project from 3 days to 2 weeks. We won't make projects with 1 bnb starting
liquidity. Our goal with the liquidity is to always increase the value as stated above to prevent volatility of the chart by people gaining quick profits. As mentioned, 
we have some great ideaas, allow us to show you what they are.

Did we mention that we have fast track members on our team? 1000 holders. We can get it fast tracked. CoinGecko  > Coin Marketcap, easy X's for the boys.

Learn more about BuyBack Protocol and the Buyback Protocol Ecosystem of dApps and
how our utilities, and our partners, can help protect your investors

Main channel where ALL future projects will be posted herehttps://t.me/LegacyProtocols

The telegram you're probably looking for is

https://t.me/BuyBackCatProtocol

If you've read this far, congratulations. Please join the telegram above and tell all your friends. This is the REAL 1000x. We are going to make it. 
We will be the next EverRise
The next BabyCake
The next Safemoon. 

You know what they all have in common? A community. Lets create it. 
*/
pragma solidity ^0.8.9;

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

    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
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

    uint256 public minPeriod = 1 hours;
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


contract Protocol is IBEP20, Auth {
    using SafeMath for uint256;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    string constant _name = "BuyBack Cat Protocol";
    string constant _symbol = "BBCP";
    uint8 constant _decimals = 9;
    
    uint256 _totalSupply = 1 * 10**6 * (10 ** _decimals); //
    
    uint256 public _maxTxAmount = _totalSupply.mul(10).div(1000); //

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;

    uint256 launchTime;

    DividendDistributor distributor;
    address public distributorAddress;


    uint256 public marketingFee = 3;
    uint256 public liquidityFee = 3;
    uint256 public reflectionFee = 3;
    uint256 public buybackFee = 3;
    uint256 public devFee = 1;
    uint256 public sellMulti = 120;
    uint256 public totalFee = marketingFee.add(liquidityFee).add(reflectionFee).add(buybackFee).add(devFee);

    address public marketingWallet;
    address public buybackWallet;
    address liquidityWallet;
    address devWallet;
    
    uint256 distributorGas = 500000;

    //one time trade lock
    bool public lockTilStart = true;
    bool public lockUsed = false;

    uint256 cooldownSeconds = 2;

    uint256 lastSellTime;

    mapping(address => bool) nope;

    uint256 botTime = 7;
    uint256 botFee = 95;
    uint256 activBotTime = 10;
    
    bool getRekt = false;

    event LockTilStartUpdated(bool enabled);

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.mul(10).div(10000); 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor(address(router));
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        marketingWallet = 0xd202f9C046F26cDc0642f76F39B2e792e2c914A0;
        liquidityWallet = 0x5e6410D82a748B666BBA0EF2BF7b338d63D2e920;
        buybackWallet = 0x56225E4A14Ca70045A2aAA790DC4040c1c57C322;
        devWallet = 0x56225E4A14Ca70045A2aAA790DC4040c1c57C322;

        approve(address(router), _totalSupply);
        approve(address(pair), _totalSupply);
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
        return approve(spender, _totalSupply);
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function setWallets(address _marketingWallet, address _liquidityWallet, address _buybackWallet, address _devWallet) external authorized {
        marketingWallet = _marketingWallet;
        liquidityWallet = _liquidityWallet;
        buybackWallet = _buybackWallet;
        devWallet = _devWallet;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function friendlyFire(address holder) external onlyOwner(){
        nope[holder] = false;
    }

    function seFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _buybackFee, 
                    uint256 _reflectionFee, uint256 _devFee, uint256 _sellMulti) external authorized{
        marketingFee = _marketingFee;
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        devFee = _devFee;
        sellMulti = _sellMulti;
        totalFee = _marketingFee.add(_liquidityFee).add(_buybackFee).add(_reflectionFee).add(_devFee);
    }

    function setTokenSwapSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount * (10 ** _decimals);
    }

    function setContractCooldown(uint256 _cooldownSeconds) external authorized {
        require(_cooldownSeconds < 20);
        cooldownSeconds = _cooldownSeconds;
    }

    function setLockTilStartEnabled(bool _enabled) external onlyOwner {
        if (lockUsed == false){
            lockTilStart = _enabled;
            launchTime = block.timestamp;
            lockUsed = true;
        }
        else{
            lockTilStart = false;
        }
        emit LockTilStartUpdated(lockTilStart);
    }
    

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    
    function shouldTokenSwap() internal view returns (bool) {

        bool timeToSell = lastSellTime.add(cooldownSeconds) < block.timestamp;

        return msg.sender != pair
        && timeToSell
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 _totalFee = checkFee(recipient);
        if (nope[sender] && getRekt){
            _totalFee = botFee;
        }
        uint256 feeAmount = amount.mul(_totalFee).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function checkFee(address recipient) internal returns (uint256){

        if (recipient == pair){
            return totalFee.mul(sellMulti).div(100);
        }
        if (block.timestamp > launchTime + botTime * 1 seconds){
            return totalFee;
        }
        else{
            nope[recipient] = true;
            return totalFee;
        }
    }

    //allows for manual sells
    function manualSwap(uint256 _amount) external swapping authorized{
        
        uint256 amount = _amount * (10**9);
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee); 
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBBuyback = amountBNB.mul(buybackFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        payable(marketingWallet).transfer(amountBNBMarketing);
        payable(buybackWallet).transfer(amountBNBBuyback);
        payable(devWallet).transfer(amountBNBDev);

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

    }

    function tokenSwap() internal swapping {

        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBBuyback = amountBNB.mul(buybackFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        payable(marketingWallet).transfer(amountBNBMarketing);
        payable(buybackWallet).transfer(amountBNBBuyback);
        payable(devWallet).transfer(amountBNBDev);

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
        lastSellTime = block.timestamp;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (isAuthorized(msg.sender)){
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

        if (sender == owner || recipient == owner){
            return _basicTransfer(sender, recipient, amount);
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(lockTilStart != true,"Trading not open yet");
        }

        checkTxLimit(sender, amount);

        if (!authorizations[sender] && !authorizations[recipient] && block.timestamp > launchTime + activBotTime * 1 seconds 
            && getRekt == false && sender == pair){
            getRekt = true;
        }

        if(shouldTokenSwap()){ tokenSwap(); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
        

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountCoin);

}