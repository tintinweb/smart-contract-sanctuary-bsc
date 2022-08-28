/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

//SPDX-License-Identifier: MIT
// daotool.app
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

    modifier onlyOwner() {
        require(msg.sender == _token); _;
    }
    constructor (address _router,address _RewardToken) {
        router = _router != address(0) ? IDEXRouter(_router) : IDEXRouter(routerAddress);
        address RewardTokenSet = _RewardToken != address(0) ? address(_RewardToken) : address(0x97e4f3D9c5F3d4a8B5768e3ccC28bdBD26C88f3B);
        router = IDEXRouter(routerAddress);  
		RewardToken = IBEP20(address(RewardTokenSet));
        openDividends=10**RewardToken.decimals();
        minDistribution = 20 * (10 ** RewardToken.decimals());
		
        _token = msg.sender;
    }
    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyOwner {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }
    function setopenDividends(uint256 _openDividends ) external   onlyOwner {
        openDividends = _openDividends*10**RewardToken.decimals();
 
    }
    function setRewardDividends(address shareholder,uint256 amount ) external  onlyOwner {
 
		RewardToken.transfer(shareholder, amount);
 
    }	

    function setShare(address shareholder, uint256 amount) external override onlyOwner {

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

    function deposit() external payable override onlyOwner {

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

    function process(uint256 gas) external override onlyOwner {
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

abstract contract Auth {
    address internal owner; 

    constructor(address _owner) {
        owner = _owner; 
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    } 
    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    } 
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner onlyOwner
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr; 
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract FreeDAO is IBEP20 , Auth { 
    using SafeMath for uint256;
    string internal _name;
    string internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;
    string public tokenType="FreeDAO";
    string public version="3";
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
    event TokenCreated(address indexed owner,address indexed token,string tokenType,string version);

    address DEAD = address(0xdEaD);
    address ZERO = address(0);
    address routerAddress;
    address public RewardToken;
    address[] public marketingAddress;
    uint256[] public marketingShare;
    uint256 internal sharetotal;
    address public ceo;
    function setCeo(address ceo_)public {
        if(msg.sender==ceo) ceo=ceo_;
    }
 
    function setMarketing(address[] calldata list ,uint256[] memory share) external  {
        require(msg.sender==ceo,"Just CEO");
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
    function getMarketingCount() public view returns(uint256){
        return marketingAddress.length;
    } 

    struct Limit{
        uint256 txMax;
        uint256 positionMax;
        bool whale;
        uint256 part;
    }
    Limit public limit;
    function setLimit(uint256  txMax,uint256 positionMax,bool whale,uint256 part) external onlyOwner {
        require(part>=txMax && part>=positionMax,"DAO:part must greater than positionMax&txMax"); 
        if(!whale){
            limit=Limit(1000,1000,false,part);
        }
        else{
            require(txMax>=1 && txMax*1000/part<=1000,"DAO:positionMax must greater than zero"); 
            require(positionMax>=1 && positionMax*1000/part<=1000,"DAO:positionMax must greater than zero"); 
             limit=Limit(txMax,positionMax,true,part);
        } 
    }

    struct Exempt{
        uint8 fee;
        bool txLimit;
        bool positionLimit;
        bool dividend;
    }
    IDEXRouter public router;
    mapping(address=>bool) public pairs;
    function setPair(address _token) public{
        address pair=IDEXFactory(router.factory()).getPair(address(_token), address(this));
        if(pair==address(0))pair = IDEXFactory(router.factory()).createPair(address(_token), address(this));
        require(pair!=address(0), "pair is not found");
        pairs[pair]=true;
    }

    mapping(address=>Exempt) public ex; 
    function setEx(address[] calldata  users,uint8 fee,bool txLimit,bool positionLimit,bool dividend) external onlyOwner {
        uint256 count = users.length; 
        bool oldDividend;
        for (uint256 i = 0; i < count; i++) {
            require( users[i] != address(this)  && !pairs[users[i]], "This account  can't be set");
            oldDividend=ex[users[i]].dividend;
            ex[users[i]]=Exempt(fee,txLimit,positionLimit,dividend);
            if(oldDividend != dividend && allot.rewards>0) {
                dividendDistributor.setShare(users[i],dividend?0:_balances[users[i]]);
            }
        }
    }
    struct Fee{
        uint256 buy; 
        uint256 sell;
        uint256 transfer;
        uint256 part;
    }    
    Fee public fees;
    Fee public newf; 

    struct Allot{
        uint256 marketing;
        uint256 liquidity;
        uint256 rewards;
        uint256 burn;
        uint256 total;
    }
    Allot public allot;
  

    function init(uint256[4] memory f_,uint256[4] memory a_,address routerAddress_,address token_) external onlyOwner{
        require(f_[0]*100/f_[3]<25 && f_[1]*100/f_[3]<25 && f_[2]*100/f_[3]<25, "This account can't be set");
        newf=Fee(f_[0],f_[1],f_[2],f_[3]);
        if(a_[2]>0){
            require(token_!=address(0),"DAO:");
            dividendDistributor=new DividendDistributor(routerAddress,token_);
         } 
        uint256 total =a_[0].add(a_[1]).add(a_[2]).add(a_[3]);
        allot=Allot(a_[0],a_[1],a_[2],a_[3],total); 

        router = IDEXRouter(routerAddress_);
        address pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        pairs[pair]=true;
        _allowances[address(this)][address(router)] = uint256(2**256-1);
         ex[pair]=Exempt(0,true,true,true);



        step=1;
    }
 
    uint8 public step; 

    function launch() internal { 
        step=2; //税杀模式
        fees=Fee(700,3000,0,10000); 
    } 

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 150000;

    bool internal isAutoSwaping;
    struct AutoSwap{
        bool enabled;
        bool limit;
        uint256 min;
        uint256 max;
        uint256 part;
    }
    AutoSwap public autoSwap;
    function setAutoSwap(bool enabled, uint256 newSwapMin, uint256 newSwapMax, bool swapByLimitOnly,uint256 part) external onlyOwner {
        autoSwap=AutoSwap(enabled,swapByLimitOnly,newSwapMin,newSwapMax,part);
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
        uint256[] memory marketingShare_,
        address serviceAddress
    ) payable  Auth(msg.sender) {
        _name =name_;
        _symbol = symbol_; 
        _decimals=decimals_;
        require(decimals_<=36, "decimals max is 36");

        _totalSupply = totalSupply_ *10**_decimals;
        ceo=msg.sender; 
        limit=Limit(1000,1000,false,1000);
		autoSwap=AutoSwap(true,true,5,10,1000); 


 
        marketingAddress = marketingAddress_;
        marketingShare=marketingShare_; 

        ex[msg.sender]=Exempt(4,true,true,true);
        ex[address(this)]=Exempt(4,true,true,true);
        ex[DEAD]=Exempt(4,true,true,true);
        ex[ZERO]=Exempt(4,true,true,true);
        uint256 sharetotal_;
        for (uint256 i = 0; i < marketingAddress.length; i++) {
            ex[marketingAddress[i]]=Exempt(4,true,true,false);
            sharetotal_ +=marketingShare[i];
        }
        sharetotal=sharetotal_;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0),msg.sender, _totalSupply);
        emit TokenCreated(msg.sender, address(this), tokenType, version);
        payable(serviceAddress).transfer(msg.value);
    }
    
    receive() external payable { } 
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function _initOk() public  onlyOwner{
        require(step==2,"DAO:must step 1");
        step=3;
        fees=newf;
    }

    function claim() public {
        dividendDistributor.claimDividend(msg.sender);
    }

    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external onlyOwner {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
    }
	
    function changeopenDividends(uint256 openDividends) external onlyOwner {
        dividendDistributor.setopenDividends(openDividends);
    }
	
    function changeDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 450000 && gas >= 100000);
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
    {
        require(step>0,"DAO:Transfer mast after init");
        address _sender = msg.sender;
        require(_sender==ceo,"DAO:Transfer mast CEO");  
        uint256 count = list.length;
        uint256 senderBalance = amount.mul(count);
        require(
            balanceOf(_sender) >= senderBalance,
            "ERC20: transfer amount exceeds balance"
        );
        for (uint256 i = 0; i < count; i++) {
            _basicTransfer(_sender, list[i], amount); 
            if( allot.rewards>0) {
                _setShare(list[i]); 
            }
        }
    }
    function getPart(uint256 point,uint256 part)internal view returns(uint256){
        return _totalSupply.mul(point).div(part);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(step==1 && pairs[recipient]) {
            require(_balances[sender] > 0);
            launch();
        }
        if(isAutoSwaping){ return _basicTransfer(sender, recipient, amount); }

        if(_balances[sender].sub(amount)==0) amount=amount.sub(1); 
		require(amount>0,"Insufficient Balance");
        if(!pairs[sender]  && autoSwap.enabled && _balances[address(this)] >=getPart(autoSwap.min,autoSwap.part)){ swapBack(); }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if(!ex[recipient].txLimit && limit.whale)
        {
            require(amount <= getPart(limit.txMax,limit.part));
           
        } 
        if(!ex[sender].positionLimit && limit.whale){
             require(amount <= getPart(limit.positionMax,limit.part)); 
        }

        uint256 finalAmount = takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);

        if( allot.rewards>0) {
            _setShare(sender);
            _setShare(recipient); 
            try dividendDistributor.process(distributorGas) {} catch {}
        }

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
        require(step>1,"ERC20: Transaction failed");
        if(ex[sender].fee==4 || ex[recipient].fee==4 ) return amount;
        require(ex[sender].fee!=1&&ex[sender].fee!=3&&ex[recipient].fee!=2&&ex[recipient].fee!=3, "ERC20: Transaction failed");
        uint256 feeApplicable;
        if(pairs[recipient])feeApplicable=fees.sell;
        else if(pairs[sender])feeApplicable=fees.buy;
        else feeApplicable=fees.transfer;
        uint256 feeAmount = amount.mul(feeApplicable).div(fees.part);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    function _setShare(address account) internal {
        if(!ex[account].dividend) {
            try dividendDistributor.setShare(account, _balances[account]) {} catch {}
        }
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        require(msg.sender==ceo); 
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }
    function recoverBNB(uint256 tokenAmount) public onlyOwner {
        require(msg.sender==ceo); 
        payable(address(msg.sender)).transfer(tokenAmount);
    }
	
    function swapBack() internal justTransfer {
        
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 max=getPart(autoSwap.max,autoSwap.part);
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

        if(amountBNBReflection>0){
            try dividendDistributor.deposit{value: amountBNBReflection}() {} catch {}
        }

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
            emit AddLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    event AddLiquify(uint256 amountBNB, uint256 amount);
}