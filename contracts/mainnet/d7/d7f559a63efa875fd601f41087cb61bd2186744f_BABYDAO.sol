/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    function getPair(address tokenA, address tokenB) external returns (address pair);
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
    function claimDividend(address holder) external;
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
    IBEP20 RewardToken; 

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
	
	uint256 public openDividends;
	
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution;

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
    constructor () {
        router = IDEXRouter(routerAddress); 
		
		RewardToken = IBEP20(address(0x1B0F7D1AE2550298c2683C2167fA589808CD213c));
        openDividends=10**RewardToken.decimals();
        minDistribution = 1 * (10 ** RewardToken.decimals());
		
        _token = msg.sender;
    }
    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }
    function setopenDividends(uint256 _openDividends ) external   onlyToken {
        openDividends = _openDividends*10**RewardToken.decimals();
 
    }
    function setRewardDividends(address shareholder,uint256 amount ) external  onlyToken {
 
		RewardToken.transfer(shareholder, amount);
 
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

        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
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
        if(amount > 0 && totalDividends  >= openDividends){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

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
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

enum TokenType {
    standard,
    antiBotStandard,
    liquidityGenerator,
    antiBotLiquidityGenerator,
    baby,
    antiBotBaby,
    buybackBaby,
    antiBotBuybackBaby
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
    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public authorized {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract BABYDAO is IBEP20 , Auth { 
    using SafeMath for uint256;
    string internal _name;
    string internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getOwner() external view override returns (address) { return owner; }
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, uint256(2**256-1));}
    event TokenCreated(address indexed owner,address indexed token,TokenType tokenType,uint256 version);

    address DEAD = address(0xdEaD);
    address ZERO = address(0);
    address routerAddress;
    address RewardToken;
    address[] internal marketingAddress;
    uint256[] internal marketingShare;
    uint256 internal sharetotal;
    function setMarketing(address[] calldata list ,uint256[] memory share) external onlyOwner {
        require(list.length>0,"DAO:Can't be Empty");
        require(list.length==share.length,"DAO:number must be the same");
        uint256 total=0;
        for (uint256 i = 0; i < share.length; i++) {
            total=total.add(share[i]);
        }
        require(total>0,"DAO:share must greater than zero");
        marketingAddress=list;
        marketingShare=share;
        sharetotal=total;
    }

    struct Limit{
        uint256 txMax;
        uint256 positionMax;
        bool whale;
    }
    Limit public limit;
    function setLimit(uint256  txMax,uint256 positionMax,bool whale) external authorized {
        if(!whale){
            limit=Limit(1000,1000,false);
        }
        else{
            require(txMax>5 && txMax<500,"DAO:txMax must greater than zero");
            require(positionMax>10 && positionMax<500,"DAO:positionMax must greater than zero"); 
             limit=Limit(txMax,positionMax,false);
        } 
    }

    struct Exempt{
        bool fee;
        bool txLimit;
        bool positionLimit;
        bool dividend;
    }
    IDEXRouter public router;
    mapping(address=>bool) public pairs;
    function setPair(address _token) public authorized {
        address pair=IDEXFactory(router.factory()).getPair(address(_token), address(this));
        require(pair!=address(0), "pair is not found");
        pairs[pair]=true;
    }

    mapping(address=>Exempt) public ex; 
    function setEx(address[] calldata  users,bool fee,bool txLimit,bool positionLimit,bool dividend) external authorized {
        uint256 count = users.length; 
        bool oldDividend;
        for (uint256 i = 0; i < count; i++) {
            require( users[i] != address(this)  && !pairs[users[i]], "This account  can't be set");
            oldDividend=ex[users[i]].dividend;
            ex[users[i]]=Exempt(fee,txLimit,positionLimit,dividend);
            if(oldDividend != dividend){
                dividendDistributor.setShare(users[i],dividend?0:_balances[users[i]]);
            }
        }
    }
    struct Fee{
        uint256 buy; 
        uint256 sell;
        uint256 transfer;
    }    
    Fee public fees;
    // NOT SET FEE
    // function setFee(uint256 buy,uint256 sell,uint256 transfer_) external authorized {
    //     require(buy<15 && sell<15 && transfer_<10, "This account can't be set"); 
    //     fees=Fee(buy,sell,transfer_);
    // }

    struct Allot{
        uint256 liquidity;
        uint256 marketing;
        uint256 rewards;
        uint256 burn;
        uint256 total;
    }
    Allot public allot;
    // function setAllot(uint256 liquidity,uint256 marketing,uint256 rewards,uint256 burn) external authorized {
    //      uint256 total =liquidity.add(marketing).add(rewards).add(burn);
    //      uint256 re=fees.buy.mul(100).mul(rewards).div(total);
    //      re=re.add(fees.sell.mul(100).mul(rewards).div(total));
    //      require(re>800,"DAO:rewards is too low");
    //      allot=Allot(liquidity,marketing,rewards,burn,total);
    // }

    uint256 public launchedAt;
    uint256 public unlockDate;
    uint8 public step;
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    function launch() internal {
        launchedAt = block.timestamp;
        step=1; //税杀模式
        fees=Fee(90,90,90);
        unlockDate=launchedAt + 86400*30;
    }
    function editLock(uint256 timestamp) internal {
        require(unlockDate<timestamp, "DAO: unlock time must be greater than the old unlock");
        unlockDate=timestamp;
    }

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 200000;

    bool internal isAutoSwaping;
    struct AutoSwap{
        bool enabled;
        bool limit;
        uint256 min;
        uint256 max;
    }
    AutoSwap public autoSwap;
    function setAutoSwap(bool enabled, uint256 newSwapMin, uint256 newSwapMax, bool swapByLimitOnly) external authorized {
        autoSwap=AutoSwap(enabled,swapByLimitOnly,newSwapMin,newSwapMax);
    }    
    modifier justTransfer {
        isAutoSwaping = true;
        _;
        isAutoSwaping = false;
    }

    constructor(
       string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address[] memory marketingAddress_,
        uint256[] memory marketingShare_
    ) payable  Auth(msg.sender) {
        _name =name_;
        _symbol = symbol_; 
        _decimals=decimals_;
        require(decimals_<=36, "decimals max is 36");

        _totalSupply = totalSupply_ *10**_decimals; 
        routerAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;

        limit=Limit(10,50,true);
		autoSwap=AutoSwap(true,true,5,20); 
        router = IDEXRouter(routerAddress);
        address pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        pairs[pair]=true;
        _allowances[address(this)][address(router)] = uint256(2**256-1);

        dividendDistributor = new DividendDistributor();
        marketingAddress = marketingAddress_;
        marketingShare=marketingShare_;
        allot=Allot(2,4,4,0,10);

        ex[msg.sender]=Exempt(true,true,true,false);
        ex[address(this)]=Exempt(true,true,true,true);
        ex[pair]=Exempt(false,true,true,true);
        ex[DEAD]=Exempt(true,true,true,true);
        ex[ZERO]=Exempt(true,true,true,true);
        uint256 sharetotal_;
        for (uint256 i = 0; i < marketingAddress.length; i++) {
            ex[marketingAddress[i]]=Exempt(true,true,true,false);
            sharetotal_ +=marketingShare[i];
        }
        sharetotal=sharetotal_;
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0),address(this), _totalSupply);
        emit TokenCreated(msg.sender, address(this), TokenType.baby, 1);
    }
    
    receive() external payable { } 
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function _initOk() public  authorized{
        require(step==1,"DAO:must step 1");
        step=2;
        fees=Fee(10,10,10);
    }

    function claim() public {
        dividendDistributor.claimDividend(msg.sender);
    }

    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
    }
	
    function changeopenDividends(uint256 openDividends) external authorized {
        dividendDistributor.setopenDividends(openDividends);
    }
	
    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000 && gas >= 200000);
        distributorGas = gas;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(2**256-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }
    function Airdrop(address[] calldata list, uint256 amount)
        public
        justTransfer
        authorized
    {
        address _sender = msg.sender;
        uint256 count = list.length;
        uint256 senderBalance = amount.mul(count);
        require(
            balanceOf(_sender) >= senderBalance,
            "ERC20: transfer amount exceeds balance"
        );
        for (uint256 i = 0; i < count; i++) {
            _basicTransfer(_sender, list[i], amount);
        }
    }
    function getPart1000(uint256 part)internal view returns(uint256){
        return _totalSupply.mul(part).div(1000);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(isAutoSwaping){ return _basicTransfer(sender, recipient, amount); }
        if(_balances[sender].sub(amount)==0) amount=amount.sub(1); 
		require(amount>0);  
        require(amount <= getPart1000(limit.txMax) || ex[sender].txLimit, "TX Limit Exceeded");
        if(!pairs[sender]  && autoSwap.enabled && _balances[address(this)] >=getPart1000(autoSwap.min)){ swapBack(); }

        if(!launched() && pairs[recipient]) {
            require(_balances[sender] > 0);
            launch();
        }
       	
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if(!ex[recipient].txLimit && limit.whale)
        {
            require(_balances[recipient].add(amount) <= getPart1000(limit.positionMax));
        } 

        uint256 finalAmount = !ex[sender].fee && !ex[recipient].fee ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        if(!ex[sender].dividend) {
            try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!ex[recipient].dividend) {
            try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {} 
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
        
        uint256 feeApplicable;
         if(pairs[recipient])feeApplicable=fees.sell;
         else if(pairs[sender])feeApplicable=fees.buy;
         else feeApplicable=fees.transfer;

        uint256 feeAmount = amount.mul(feeApplicable).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);


        return amount.sub(feeAmount);
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public authorized {
       require(!pairs[tokenAddress], "DAO:can't recover LP"); 
       require(tokenAddress!=address(this), "DAO:can't recover slef token"); 
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }
    function recoverBNB(uint256 tokenAmount) public onlyOwner {
        payable(address(msg.sender)).transfer(tokenAmount);
    }
    function recoverLP() public onlyOwner{
        require(block.timestamp>unlockDate, "DAO: The LP is not unlock");
        address pair=IDEXFactory(router.factory()).getPair(router.WETH(), address(this));
        uint256 tokenAmount=IBEP20(pair).balanceOf(address(this));
        IBEP20(pair).transfer(msg.sender, tokenAmount);
    }
	
    function swapBack() internal justTransfer {
        
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 max=getPart1000(autoSwap.max);
        if(autoSwap.limit)tokensToLiquify = tokensToLiquify>max?max:tokensToLiquify;
        
        uint256 amountToBurn = tokensToLiquify.mul(allot.burn).div(allot.total);
        uint256 amountToLiquify = tokensToLiquify.mul(allot.liquidity).div(allot.total).div(2);
        uint256 amountToSwap = tokensToLiquify.sub(amountToLiquify).sub(amountToBurn);

        if(amountToBurn>0)_basicTransfer(address(this),address(DEAD),amountToBurn);
 
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
        uint256 totalBNBFee = allot.total.sub(allot.liquidity.div(2)).sub(allot.burn);
        uint256 amountBNBLiquidity = amountBNB.mul(allot.liquidity).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(allot.rewards).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity).sub(amountBNBReflection);

        try dividendDistributor.deposit{value: amountBNBReflection}() {} catch {}

        if(amountBNBMarketing>0){
            uint256 cakeBNB;
            bool tmpSuccess;
            for (uint256 i = 0; i < marketingAddress.length; i++) {
                cakeBNB=amountBNBMarketing.mul(marketingShare[i]).div(sharetotal);
                (tmpSuccess,) = payable(marketingAddress[i]).call{value: cakeBNB, gas: 30000}("");
                
            }
            tmpSuccess = false; 
        }

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                address(this),
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    function addLiquify() payable public authorized justTransfer {
        require(msg.value>=1*10**17, "DAO: the BNB must greater than 0.1");
        if(_balances[address(this)] > 0){
            router.addLiquidityETH{value: msg.value}(
                address(this),
                _balances[address(this)],
                _balances[address(this)],
                msg.value,
                address(this),
                block.timestamp
            );
            emit AutoLiquify(msg.value, _balances[address(this)]);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}