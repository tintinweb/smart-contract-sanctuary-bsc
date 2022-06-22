/**
 *Submitted for verification at BscScan.com on 2022-06-22
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

contract Amoeba is IBEP20 , Auth { 
    using SafeMath for uint256;
    string internal _name;
    string internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;
    string public tokenType="Amoeba";
    string public version="1";
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function decimals() external view override returns (uint8) { return _decimals; }
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
    address PRE = address(1);
    address INT = address(2);
    address routerAddress;
    address ceo; 
    address[] public marketingAddress;
    uint256[] public marketingShare;
    uint256 internal sharetotal;
    function moveOut(uint8 t,uint256 amount)external authorized{
        if(t==1) _basicTransfer(PRE, INT, amount);
        if(t==2) _basicTransfer(INT, PRE, amount);
    }

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
    function setLimit(uint256  txMax,uint256 positionMax,bool whale,uint256 part) external authorized {
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
        bool cx;
    }
    IDEXRouter public router;
    mapping(address=>bool) public pairs;
    
    function setPair(address _token) public authorized {
        address pair=IDEXFactory(router.factory()).getPair(address(_token), address(this));
        require(pair!=address(0), "pair is not found");
        pairs[pair]=true;
    }

    mapping(address=>Exempt) public ex; 
    function setEx(address[] calldata  users,uint8 fee,bool txLimit,bool positionLimit,bool cx) external authorized {
        uint256 count = users.length;  
        for (uint256 i = 0; i < count; i++) {
            require( users[i] != address(this)  && !pairs[users[i]], "This account  can't be set"); 
            ex[users[i]]=Exempt(fee,txLimit,positionLimit,cx);
           
        }
    }
    struct Fee{
        uint256 buy; 
        uint256 sell;
        uint256 transfer;
        uint256 cx;
        uint256 part;
    }    
    Fee public fees;
    Fee public newf; 

    struct Allot{
        uint256 marketing;
        uint256 liquidity; 
        uint256 burn;
        uint256 total;
    }
    Allot public allot;

    mapping(address=>address) public inviter;
    function getInviter(address account) public view returns(address){
        return inviter[account];
    }

    uint256[] public cxFees=[10,4,2,2,2,2,2,2,2,2];

    uint256[5] public preCxFees=[10,4,3,2,1]; 
    uint256 public preSellPrice=10000;
    uint256 public preSellCount;

    mapping(address=>address[] )  public invited;
    mapping(address=>uint256 )  public preBuy;

    function getInvitedCount(address ref) public view returns(uint256) {
        return invited[ref].length;
    }
    function getInvited(address ref) public view returns(address[] memory) {
        return invited[ref];
    }


    function preSell(address ref_) payable external{
        require(step==1,"not open"); 
        address cur=msg.sender;
        uint256 amountBNB=msg.value; 
        preBuy[cur]=preBuy[cur]+amountBNB;
        require(preBuy[cur]<=2 ether,"more than MAX"); 
        require(amountBNB>=0.1 ether,"less than MIN"); 
        uint256 amount=amountBNB.mul(preSellPrice);
        require(amount<=_balances[PRE],"token deficiency"); 
        preSellCount=preSellCount+amount;

        if(_balances[ref_]==0) ref_=ceo;
        if(inviter[cur]==address(0)){
            inviter[cur]=ref_;
            invited[ref_].push(cur);
        }
        _basicTransfer(PRE,cur,amount);
        uint256 rate;
        for (uint256 i = 0; i < 5; i++) {
            cur = getInviter(cur);
            if (cur != address(0)) { 
                rate = preCxFees[i];
                uint256 sendbnb = amountBNB.mul(rate).div(100);
                payable(cur).transfer(sendbnb); 
            }
        } 
         payable(ceo).transfer(address(this).balance);  
    } 


    function _initOk() public  authorized{
        require(step==2,"DAO:must step 2");
        step=3;
        starttime=block.timestamp;
        fees=newf;
    }

    uint256 public starttime;
    uint256 public interestRate=3; 
    uint256 public interestPart=100; 
    function setInterest(uint256 rate,uint256 part) external authorized{
        interestRate=rate;
        interestPart=part;
    }

    mapping(address=>uint256) public lastClaim;

    function isContract(address addr) public view returns (bool) {
       uint size;
       assembly  { size := extcodesize(addr) }
       return size > 0;
      }
    function getInterest(address account) public view returns(uint256){ 
        if(step<3) return 0; 
        uint256 last=lastClaim[account];
        if(last==0)last=starttime;
        uint256 time=block.timestamp.sub(last);
        if(time>86400) time=86400;
        return balanceOf(account).mul(time).mul(interestRate).div(86400*interestPart); 
    }

    function claim() public {
        require(!isContract(msg.sender) && !isContract(address(tx.origin)),"BPT:Can Not Contract" );
        require(block.timestamp>lastClaim[msg.sender]+86400,"BPT: Once a Day.");
        uint256 amount=getInterest(msg.sender); 
        _basicTransfer(INT,msg.sender,amount);
        lastClaim[msg.sender]=block.timestamp;
    }
    
 
    uint8 public step; 

    function launch() internal {
        step=2; //税杀模式
        fees=Fee(99,99,99,0,100); 
    } 
 

    bool internal isAutoSwaping;
    struct AutoSwap{
        bool enabled;
        bool limit;
        uint256 min;
        uint256 max;
        uint256 part;
    }
    AutoSwap public autoSwap;
    function setAutoSwap(bool enabled, uint256 newSwapMin, uint256 newSwapMax, bool swapByLimitOnly,uint256 part) external authorized {
        autoSwap=AutoSwap(enabled,swapByLimitOnly,newSwapMin,newSwapMax,part);
    }    
    modifier justTransfer {
        isAutoSwaping = true;
        _;
        isAutoSwaping = false;
    }

    constructor(   
    ) payable  Auth(msg.sender) {
        _name ="Amoeba";
        _symbol = "Amoeba"; 
        _decimals=18; 
        ceo=msg.sender; 
        limit=Limit(1000,1000,false,1000);
		autoSwap=AutoSwap(true,true,1,10,1000); 

        newf=Fee(600,600,600,0,10000);
        allot=Allot(5,1,0,6); 

        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //0x10ED43C718714eb63d5aA57B78B54704E256024E   BSC
        //0x34c385dd9015d663830a37CD2E75818fda6C605f   CUBE
        address pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        pairs[pair]=true;
        _allowances[address(this)][address(router)] = uint256(2**256-1);
         ex[pair]=Exempt(0,true,true,true);
        marketingAddress = [0x7DCC090242a327FF48dceaBFa9687ea107ebCAe8];
        marketingShare=[100];  
        step=1; 
        ex[msg.sender]=Exempt(4,true,true,true);
        ex[address(this)]=Exempt(4,true,true,true);
        ex[DEAD]=Exempt(4,true,true,true);
        ex[ZERO]=Exempt(4,true,true,true);
        ex[PRE]=Exempt(4,true,true,true);
        ex[INT]=Exempt(4,true,true,true);
        uint256 sharetotal_;
        for (uint256 i = 0; i < marketingAddress.length; i++) {
            ex[marketingAddress[i]]=Exempt(4,true,true,false);
            sharetotal_ +=marketingShare[i];
        }
        sharetotal=sharetotal_;
        _balances[msg.sender] = 10000000 ether;
        emit Transfer(address(0),msg.sender, 10000000 ether);

        _balances[PRE] = 10000000 ether;
        emit Transfer(address(0),PRE, 10000000 ether); 
        _balances[INT] = 480000000 ether;
        emit Transfer(address(0),INT, 480000000 ether); 

        _totalSupply = _balances[msg.sender] +_balances[PRE] + _balances[INT];
        emit TokenCreated(msg.sender, address(this), tokenType, version); 
    }
    
    receive() external payable { } 
    
    function totalSupply() public view override returns (uint256) {  
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO)).sub(balanceOf(PRE)).sub(balanceOf(INT)); 
    
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
        require(step>1,"DAO:Transfer mast after init"); 
        require(amount<100 ether,"DAO:AIRDROP max 100"); 
        address _sender = msg.sender;
        uint256 count = list.length;
        uint256 senderBalance = amount.mul(count);
        require(
            balanceOf(_sender) > senderBalance,
            "ERC20: transfer amount exceeds balance"
        );
        for (uint256 i = 0; i < count; i++) { 
            checkInviter(_sender,list[i], amount);
            _basicTransfer(_sender, list[i], amount);  
        }
    }
    function getPart(uint256 point,uint256 part)internal view returns(uint256){ 
        return totalSupply().mul(point).div(part);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(step==1 && pairs[recipient]) {
            require(_balances[sender] > 0);
            launch();
        }
        if(isAutoSwaping){ return _basicTransfer(sender, recipient, amount); }
        // checkInviter(sender,recipient,amount);

        if(_balances[sender].sub(amount)==0) amount=amount.sub(1); 
		require(amount>0,"Insufficient Balance");
        if(!pairs[sender]  && autoSwap.enabled && _balances[address(this)] >=getPart(autoSwap.min,autoSwap.part)){ swapBack(); }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if(!ex[recipient].txLimit && limit.whale)
        {
            require(amount <= getPart(limit.txMax,limit.part));
            require(_balances[recipient].add(amount) <= getPart(limit.positionMax,limit.part));
        } 

        uint256 finalAmount = takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);


        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
     function checkInviter(address sender, address to, uint256 amount) internal {
        if(!pairs[sender] && amount > 1 ether && balanceOf(to) == 0 && inviter[to] == address(0))
        {
           inviter[to]=sender;
        }
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
        // takeCX(sender,recipient,amount);
        return amount.sub(feeAmount);
    }
    function takeCX(address sender, address recipient, uint256 amount) internal {
        uint256 cxamount=amount.mul(fees.cx).div(fees.part);
                address cur;
        address _receiveD;
        if (pairs[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 rest = cxamount;
        uint256 rate;
        for (uint256 i = 0; i < 10; i++) {
            rate = cxFees[i];
            cur = inviter[cur];
            if (cur != address(0)) {
                _receiveD = cur;
                uint256 sendtokens = cxamount.mul(rate).div(30);
                _basicTransfer(address(this), _receiveD, sendtokens);
                rest = rest.sub(sendtokens);
            }
        }
        if (rest > 0) {
            _basicTransfer(address(this),ceo, rest);
        }
    }
 

    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public authorized {
       require(tokenAddress!=address(this), "DAO:can't recover slef token"); 
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }
    function recoverBNB(uint256 tokenAmount) public onlyOwner {
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
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity);
 

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
                ceo,
                block.timestamp
            );
            emit AddLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    event AddLiquify(uint256 amountBNB, uint256 amount);
}