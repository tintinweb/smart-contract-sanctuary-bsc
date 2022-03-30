/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

/*
5% bnb rewards - BSC FOREVER LETS GO PERMA BULLS
2% max tx/wallet
*/


pragma solidity ^0.7.4;
// SPDX-License-Identifier: Unlicensed

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
    address routerAddress;
    address Bnb; // mainnet bnb


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
    uint256 public minDistribution = 3 * (10 ** 15);

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

    constructor (address _router, address _routerAddress, address _bnb) {
        Bnb = _bnb;
        routerAddress = _routerAddress;
        router = _router != address(0) ? IDEXRouter(_router) : IDEXRouter(routerAddress);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
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
        totalDividends = totalDividends.add(msg.value);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(msg.value).div(totalShares));
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
            // RewardToken.transfer(shareholder, amount);
            payable(shareholder).transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }
    
    function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }
    
    // function rescueDividends(address to) external onlyToken {
    //     RewardToken.transfer(to, RewardToken.balanceOf(address(this)));
    // }
    
    // function setRewardToken(address _rewardToken) external onlyToken{
    //     RewardToken = IBEP20(_rewardToken);
    // }

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

abstract contract BEP20Interface {
    function balanceOf(address whom) view public virtual returns (uint256);
    function approve(address whom, uint256 amount) public virtual;
    function totalSupply(address whom) view public virtual returns(uint256);
}

contract BNB is IBEP20, Auth {
    
    using SafeMath for uint256;

    string constant _name = "Be and be";
    string constant _symbol = "BNB";
    uint8 constant _decimals = 18;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet pancake
    // address RewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // mainnet wbnb
    address Bnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // mainnet bnb
    // NICE!
    address public autoLiquidityReceiver;
    address public marketingWallet;  // teamwallet

    uint256 _totalSupply = 1000000000000 * (10 ** _decimals); // 
    uint256 public _maxTxAmount = _totalSupply * 20 / 1000; // 
    uint256 public _walletMax = _totalSupply * 20 / 1000; // 
    bool public restrictWhales = true;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) _lastTxTime;
	uint256 private deadBlocks = 3;
	uint256 private antiSniperGasLimit = 7 gwei;
	bool private gasLimitActive = true;


    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;


    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;


    

    uint256 public liquidityFeeThou = 20;
    uint256 public marketingFeeThou = 50;
    uint256 public rewardsFeeThou = 50;
    uint256 public sellliquidityFeeThou = 0;
    uint256 public sellmarketingFeeThou = 70;
    uint256 public sellrewardsFeeThou = 50;
    bool private tagAllBuys = true;
    uint256 public totalFeeThou = 0;
    uint256 public totalFeeIfSellingThou = 0;
    

    
    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = false;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 750000;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = _totalSupply * 5 / 2000;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () Auth(msg.sender) {

        
        autoLiquidityReceiver = 0x7354Ec45472ab73f522fD286A6DC807DC1A4E689;

        marketingWallet = 0x7354Ec45472ab73f522fD286A6DC807DC1A4E689;        
        
        router = IDEXRouter(routerAddress);
        address pair_weth = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        pair = pair_weth;
        _allowances[address(this)][address(router)] = uint256(-1);

        dividendDistributor = new DividendDistributor(address(router), routerAddress, Bnb);

        // isFeeExempt[msg.sender] = true;
        // isFeeExempt[address(this)] = true;      
        // isFeeExempt[routerAddress] = true;        
        // // isFeeExempt[pair] = true;        
        // // isFeeExempt[pair_weth] = true;        

        // isTxLimitExempt[msg.sender] = true;
        // isTxLimitExempt[address(this)] = true;      
        // isTxLimitExempt[routerAddress] = true;        
        // // isTxLimitExempt[pair] = true;
        // // isTxLimitExempt[pair_weth] = true;

        // isDividendExempt[pair] = true;
        // isDividendExempt[pair_weth] = true;
        // isDividendExempt[routerAddress] = true;        
        // isDividendExempt[msg.sender] = true;
        // isDividendExempt[address(this)] = true;
        // isDividendExempt[DEAD] = true;
        // isDividendExempt[ZERO] = true;    


        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[pair_weth] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[pair_weth] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;    
        
        totalFeeThou = liquidityFeeThou.add(marketingFeeThou).add(rewardsFeeThou);
        totalFeeIfSellingThou = sellliquidityFeeThou.add(sellmarketingFeeThou).add(sellrewardsFeeThou);


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
        return approve(spender, uint256(-1));
    }
    
    function claimDividend() external {
        dividendDistributor.claimDividend(msg.sender);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    
    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

	function setTagAllBuys(bool active) external authorized {
		tagAllBuys = active;
	}


    function tagSnipers(address sender) internal {
        if (tagAllBuys || block.number - launchedAt <= deadBlocks || gasLimitActive && tx.gasprice >= antiSniperGasLimit) {
            isBlacklisted[sender] = true;
        }
    }

    function setIsSniper(address holder, bool isASniper) external authorized {
        isBlacklisted[holder] = isASniper;
    }

    function changeTxLimit(uint256 newLimit) external onlyOwner {
        _maxTxAmount  = newLimit;
    }

    function changeIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }


    function changeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        
        if(exempt){
            dividendDistributor.setShare(holder, 0);
        }else{
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function changeFees(uint256 newLiqFeeThou, uint256 newRewardFeeThou, uint256 newMarketingFeeThou, uint256 newsellLiqFeeThou, uint256 newsellRewardFeeThou, uint256 newsellMarketingFeeThou) external onlyOwner {
        liquidityFeeThou = newLiqFeeThou;
        rewardsFeeThou = newRewardFeeThou;
        marketingFeeThou = newMarketingFeeThou;
        sellliquidityFeeThou = newsellLiqFeeThou;
        sellrewardsFeeThou = newsellRewardFeeThou;
        sellmarketingFeeThou = newsellMarketingFeeThou;
               
        totalFeeThou = liquidityFeeThou.add(marketingFeeThou).add(rewardsFeeThou);
 
        totalFeeIfSellingThou = sellliquidityFeeThou.add(sellmarketingFeeThou).add(sellrewardsFeeThou);

    }

    function changeFeeReceivers(address newLiquidityReceiver, address newMarketingWallet) external authorized {
        autoLiquidityReceiver = newLiquidityReceiver;
        marketingWallet = newMarketingWallet;
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
        require(gas < 750000);
        distributorGas = gas;
    }
    
    // function setRewardToken(address _rewardToken) external authorized {
    //     dividendDistributor.setRewardToken(_rewardToken);
    // }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender]){
            require(tradingOpen,"Trading not open yet");
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }
        tagSnipers(recipient);
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }

        if(!launched() && recipient == pair) {
            require(_balances[sender] > 0);
            launch();
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
            try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        try dividendDistributor.process(distributorGas) {} catch {}

        _lastTxTime[sender] = block.timestamp;
        _lastTxTime[recipient] = block.timestamp;

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

        uint256 feeApplicableThou;

        if (pair == recipient) {
            feeApplicableThou = totalFeeIfSellingThou;
        } else {
            feeApplicableThou = totalFeeThou;
        }

        // uint256 feeApplicable = pair == recipient ? totalFeeIfSelling : totalFee;
        uint256 feeAmount = amount.mul(feeApplicableThou).div(1000);

    
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function swapBack() internal lockTheSwap {
        inSwapAndLiquify = true;        
        
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToLiquify = tokensToLiquify.mul(liquidityFeeThou).div(totalFeeThou).div(2);
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
        uint256 totalBNBFeeThou = totalFeeThou.sub(liquidityFeeThou.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFeeThou).div(totalBNBFeeThou).div(2);
        uint256 amountBNBReflection = amountBNB.mul(rewardsFeeThou).div(totalBNBFeeThou);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFeeThou).div(totalBNBFeeThou);
        
        dividendDistributor.deposit{value: amountBNBReflection}();
        (bool tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 30000}("");

        path[0] = router.WETH();
        path[1] = Bnb;
        
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNBLiquidity}(
            0,
            path,
            address(this),
            block.timestamp
        );
     
        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            inSwapAndLiquify = true;

            uint256 bnbBalance = BEP20Interface(Bnb).balanceOf(address(this));            
            BEP20Interface(Bnb).approve(address(router), bnbBalance);        

            router.addLiquidity(
                Bnb,
                address(this),
                bnbBalance,                
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );    

            emit AutoLiquify(bnbBalance, amountToLiquify);
        }

        inSwapAndLiquify = false;

    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        _manage_blacklist(addresses, status);
    }

    function _manage_blacklist(address[] memory addresses, bool status) internal {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
        if(tradingOpen && launchedAt == 0){
            launchedAt = block.number;
        }
    }

	function setAntisniperBlocks(uint256 blocks) external authorized {
		deadBlocks = blocks;
	}

	function setAntisniperGas(bool active, uint256 quantity) external authorized {
		require(!active || quantity >= 7 gwei, "Needs to be at least 7 gwei.");
		gasLimitActive = active;
		antiSniperGasLimit = quantity;
	}



    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}