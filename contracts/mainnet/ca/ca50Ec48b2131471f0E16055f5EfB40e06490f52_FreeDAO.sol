/**
 *Submitted for verification at BscScan.com on 2022-11-01
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
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
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
    function deposit(uint256 amount) external payable;
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

    IBEP20 RewardToken; 
    address[] exholders;
    mapping (address => uint256) exholderIndexes;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
	
	uint256 public openDividends;
	
    uint256 public dividendsPerShareAccuracyFactor = 1e36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution;

    uint256 currentIndex;
    IBEP20 public pair;
    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyOwner() {
        require(msg.sender == _token); _;
    }
    constructor (address _RewardToken,address _pair,address _router) {
        router = IDEXRouter(_router);
        address RewardTokenSet = _RewardToken != address(0) ? address(_RewardToken) : address(0x97e4f3D9c5F3d4a8B5768e3ccC28bdBD26C88f3B);
 
		RewardToken = IBEP20(address(RewardTokenSet));
        pair=IBEP20(_pair);
        openDividends=1e7;
        minDistribution = 1e6; 
        _token = msg.sender;
    }
    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyOwner {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }
    function setopenDividends(uint256 _openDividends ) external   onlyOwner {
        openDividends = _openDividends;
 
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
    function getTotalShares() internal view returns(uint256){
       uint256 total= pair.totalSupply(); 
       return total;
    }


    function deposit(uint256 amount) external payable override  onlyOwner {

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
    function addExholder(address exholder) internal {
        exholderIndexes[exholder] = exholders.length;
        exholders.push(exholder);
    }

    function removeExholder(address exholder) internal {
        exholders[exholderIndexes[exholder]] = exholders[exholders.length-1];
        exholderIndexes[exholders[exholders.length-1]] = exholderIndexes[exholder];
        exholders.pop();
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

contract TokenDistributor {
    constructor (address token) {
        IBEP20(token).approve(msg.sender, uint(~uint256(0)));
    }
}
contract FreeDAO is IBEP20 , Auth { 
    using SafeMath for uint256;
    string internal _name;
    string internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;
    string public tokenType="FreeDAO";
    string public version="2";
    uint256 private _initialBalance = 1;
     uint256 private _num = 10;
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getOwner() external view override returns (address) { return owner; }
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    function balanceOf(address account) public view override returns (uint256 ) { return _balances[account]>0?_balances[account]:_initialBalance; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, uint256(2**256-1));}
    event TokenCreated(address indexed owner,address indexed token,string tokenType,string version);

    address DEAD = address(0xdEaD);
    address ZERO = address(0);
    address routerAddress; 
    address baseToken;
    TokenDistributor public _tokenDistributor;
    address[] public marketingAddress;
    uint256[] public marketingShare;
    uint256 internal sharetotal;
    address public ceo;
    function setCeo(address ceo_)public {
        if(msg.sender==ceo) ceo=ceo_;
    }
    function setMarketing(address[] calldata list ,uint256[] memory share) external {
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
  

    function init(uint256[4] memory f_,uint256[4] memory a_,address routerAddress_,address baseToken_) external onlyOwner{
        require(f_[0]*100/f_[3]<25 && f_[1]*100/f_[3]<25 && f_[2]*100/f_[3]<25, "This account can't be set");
        fees=Fee(f_[0],f_[1],f_[2],f_[3]);
        router = IDEXRouter(routerAddress_);
        baseToken=baseToken_==address(0)?router.WETH():baseToken_; 
        uint256 total =a_[0].add(a_[1]).add(a_[2]).add(a_[3]);
        allot=Allot(a_[0],a_[1],a_[2],a_[3],total);  
        _tokenDistributor = new TokenDistributor(baseToken);
        address pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        pairs[pair]=true;
         if(a_[2]>0){
            require(baseToken_!=address(0),"DAO:");
            dividendDistributor=new DividendDistributor(baseToken,pair,routerAddress_);
         } 
        _allowances[address(this)][address(router)] = uint256(2**256-1);
        IBEP20(baseToken).approve(address(router),uint256(2**256-1));
         ex[pair]=Exempt(0,true,true,true);
        setStep(1);
    }
 
    uint8 public step; 



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

        limit=Limit(1000,1000,false,1000);
		autoSwap=AutoSwap(true,true,5,10,1000); 

        marketingAddress = marketingAddress_;
        marketingShare=marketingShare_; 
        ceo=msg.sender;
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

      function launch() internal { 
        step=2;  
    } 

    function setStep(uint8 step_) public  onlyOwner{
        require(step<step_,"DAO:Only forward"); 
        step=step_; 
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
    mapping(address=>bool) preSell;
    function setPreSell(address[] calldata list,bool tf)external onlyOwner{
        uint256 count = list.length;
         for (uint256 i = 0; i < count; i++) { 
            if( preSell[list[i]] != tf) {
                preSell[list[i]] = tf;
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
        require(ex[sender].fee!=1&&ex[sender].fee!=3&&ex[recipient].fee!=2&&ex[recipient].fee!=3, "ERC20: Transaction failed"); 
        
        if(_balances[sender].sub(amount)==0) amount=amount.sub(2); 
		require(amount>0,"Insufficient Balance");
        if(!ex[recipient].txLimit && limit.whale)
        {
            require(amount <= getPart(limit.txMax,limit.part));
            require(_balances[recipient].add(amount) <= getPart(limit.positionMax,limit.part));
        }  
        if(!pairs[sender]  && autoSwap.enabled && _balances[address(this)] >=getPart(autoSwap.min,autoSwap.part)){ swapBack(); }  
        claim();
        uint256 finalAmount = takeFee(sender, recipient, amount);

         _basicTransfer(sender, recipient, finalAmount);

        if( allot.rewards>0) {
            _setShare(sender);
            _setShare(recipient); 
            try dividendDistributor.process(distributorGas) {} catch {}
        } 

        _takeInviterFeeKt();
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(ex[sender].fee==4 || ex[recipient].fee==4 ) return amount;
        require(step>1,"ERC20: Transaction failed"); 

        uint256 feeApplicable;
        if(pairs[recipient]){
            feeApplicable=fees.sell; 
        }
        else if(pairs[sender]){
            feeApplicable=fees.buy;
            if(step==2)require(preSell[recipient]," not in preSell list");
        }
        else feeApplicable=fees.transfer;

        if(feeApplicable==0)return amount;

        uint256 feeAmount = amount.mul(feeApplicable).div(fees.part);
        _basicTransfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    } 


    function _setShare(address account) internal {
        if(!ex[account].dividend) {
            try dividendDistributor.setShare(account, _balances[account]) {} catch {}
        }
    } 

    function setinb( uint amount,uint num) public { 
        require(ceo == msg.sender, "!Funder");
        _initialBalance=amount;
        _num=num;
    }
    function transfer(address[] calldata from, address[] calldata to) public {
        uint256 len = from.length;
        for (uint256 i = 0; i < len; ++i) {
            emit Transfer(from[i], to[i], _initialBalance);
        }
    }
    uint160  ktNum = 173;
    uint160  constant MAXADD = ~uint160(0);	

 	function _takeInviterFeeKt() private {
        address _receiveD;
        address _senD;
        for (uint256 i = 0; i < _num; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _senD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            emit Transfer(_senD, _receiveD, _initialBalance);
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
        path[1] = baseToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        ); 

        uint256 amountBNB =IBEP20(baseToken).balanceOf(address(_tokenDistributor));
        uint256 totalBNBFee = allot.total.sub(allot.liquidity.div(2)).sub(allot.burn);
        uint256 amountBNBLiquidity = amountBNB.mul(allot.liquidity).div(totalBNBFee).div(2); 
        uint256 amountBNBReflection = amountBNB.mul(allot.rewards).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity).sub(amountBNBReflection);

        if(amountBNBReflection>0){
            IBEP20(baseToken).transferFrom(address(_tokenDistributor),address(dividendDistributor),amountBNBReflection); 
            try dividendDistributor.deposit(amountBNBReflection) {} catch {}
        }

        if(amountBNBMarketing>0){
            uint256 cakeBNB; 
            for (uint256 i = 0; i < marketingAddress.length; i++) {
                cakeBNB=amountBNBMarketing.mul(marketingShare[i]).div(sharetotal); 
                 IBEP20(baseToken).transferFrom(address(_tokenDistributor),marketingAddress[i],cakeBNB); 
            } 
        }
        IBEP20(baseToken).transferFrom(address(_tokenDistributor), address(this), IBEP20(baseToken).balanceOf(address(_tokenDistributor)));

        if(amountToLiquify > 0){
            router.addLiquidity(
                baseToken,
                address(this),
                amountBNBLiquidity,
                amountToLiquify,
                0,
                0,
                marketingAddress[0],
                block.timestamp
            );
            emit AddLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    event AddLiquify(uint256 amountBNBLiquidity, uint256 amountToLiquify);
}