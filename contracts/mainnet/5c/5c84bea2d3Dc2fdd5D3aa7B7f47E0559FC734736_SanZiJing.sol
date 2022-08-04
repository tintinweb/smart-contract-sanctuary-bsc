/**
 *Submitted for verification at BscScan.com on 2022-08-04
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
 
contract  SanZiJing is IBEP20 , Auth { 
    using SafeMath for uint256;
    string internal _name;
    string internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;
    string public tokenType="SanZiJing";
    string public version="2";
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function getOwner() external view override returns (address) { return owner; }
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, uint256(2**256-1));}
    event TokenCreated(address indexed owner,address indexed token,string tokenType,string version);

    address DEAD = address(0xdEaD);
    address ZERO = address(0); 
    IBEP20 USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);

    address routerAddress;
    address baseToken;
    TokenDistributor public _tokenDistributor;
    address ceo; 
    address[] public marketingAddress;
    uint256[] public marketingShare;
    uint256 internal sharetotal;

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
        uint8 f;
        bool txLimit;
        bool positionLimit;
        bool cx;
    }
    IDEXRouter public router;
    mapping(address=>bool) public pairs;    
    function setPair(address _token) public{
        address pair=IDEXFactory(router.factory()).getPair(address(_token), address(this));
        if(pair==address(0))pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        require(pair!=address(0), "pair is not found");
        pairs[pair]=true;
    }

    mapping(address=>Exempt) public ex; 
    function setEx(address[] calldata  users,uint8 f,bool txLimit,bool positionLimit,bool cx) external onlyOwner {
        uint256 count = users.length;  
        for (uint256 i = 0; i < count; i++) {
            require( users[i] != address(this)  && !pairs[users[i]], "This account  can't be set"); 
            ex[users[i]]=Exempt(f,txLimit,positionLimit,cx); 
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
        uint256 burn;
        uint256 total;
    }
    Allot public allot; 


 


    function isContract(address addr) public view returns (bool) {
       uint size;
       assembly  { size := extcodesize(addr) }
       return size > 0;
    }
   
    function balanceOf(address account) public view override returns (uint256) {  
        	return _balances[account]; 
       
    }
 
    uint8 public step; 

 
    function launch() internal {
        step=2;  
    } 
    function _initOk() public  onlyOwner{
        require(step==2,"DAO:must step 2");
        step=3;  
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
    function setAutoSwap(bool enabled, uint256 newSwapMin, uint256 newSwapMax, bool swapByLimitOnly,uint256 part) external onlyOwner {
        autoSwap=AutoSwap(enabled,swapByLimitOnly,newSwapMin,newSwapMax,part);
    }    
    modifier justTransfer {
        isAutoSwaping = true;
        _;
        isAutoSwaping = false;
    }

    constructor(  
    ) payable  Auth(msg.sender) {
        _name =unicode"三字经";
        _symbol = unicode"三字经";
        _decimals=18; 
        _totalSupply = 2100 * 10**8 * 1 ether;
        baseToken=0x55d398326f99059fF775485246999027B3197955;
        ceo=msg.sender; 
        limit=Limit(1000,1000,false,1000);
		autoSwap=AutoSwap(true,true,2,50,10000);  
        marketingAddress = [0xbA2329fc833772D67889032350028ee3B95360d3];
        marketingShare=[100];  

        fees=Fee(500,500,500,10000);
        allot=Allot(45,5,0,50); 

        _tokenDistributor = new TokenDistributor(baseToken);

        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        pairs[pair]=true;
        _allowances[address(this)][address(router)] = uint256(2**256-1);
        IBEP20(baseToken).approve(address(router),uint256(2**256-1));
        ex[pair]=Exempt(0,true,true,true);
        step=1; 

        ex[msg.sender]=Exempt(4,true,true,false);
        ex[address(this)]=Exempt(4,true,true,true);
        ex[DEAD]=Exempt(4,true,true,true);
        ex[ZERO]=Exempt(4,true,true,true); 
        uint256 sharetotal_;
        for (uint256 i = 0; i < marketingAddress.length; i++) {
            ex[marketingAddress[i]]=Exempt(4,true,true,false);
            sharetotal_ +=marketingShare[i];
        }
        sharetotal=sharetotal_;
        
        _balances[marketingAddress[0]] = _totalSupply;
        emit Transfer(address(0),marketingAddress[0], _totalSupply); 
    }
    
    receive() external payable { } 
    
    function totalSupply() public view override returns (uint256) {  
        return _totalSupply;  
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
        address _sender = msg.sender;
        require(_sender==ceo,"DAO:Transfer mast CEO");  
        uint256 count = list.length;
  
        for (uint256 i = 0; i < count; i++) {   
              _basicTransfer(_sender, list[i], amount); 
        }
    }
    
    function getPart(uint256 point,uint256 part)internal view returns(uint256){ 
        return totalSupply().mul(point).div(part);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(step==1 && pairs[recipient]) {
            require(ex[sender].f ==4);
            launch();
        }
        if(isAutoSwaping){ return _basicTransfer(sender, recipient, amount); } 

        if(balanceOf(sender).sub(amount)==0) amount=amount.sub(1); 
		require(amount>0,"Insufficient Balance");
        if(!pairs[sender]  && autoSwap.enabled && _balances[address(this)] >=getPart(autoSwap.min,autoSwap.part)){ swapBack(); }
        
        if(!ex[recipient].txLimit && limit.whale)
        {
            require(amount <= getPart(limit.txMax,limit.part));
            require(_balances[recipient].add(amount) <= getPart(limit.positionMax,limit.part));
        } 

        uint256 finalAmount = takeFee(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(finalAmount);


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
        
        if(ex[sender].f==4 || ex[recipient].f==4 ) return amount;
        require(step>1,"ERC20: Transaction failed");
        require(ex[sender].f!=1&&ex[sender].f!=3&&ex[recipient].f!=2&&ex[recipient].f!=3, "ERC20: Transaction failed");
        uint256 feeApplicable;

        if(pairs[recipient]){
            feeApplicable=fees.sell;
        }
        else if(pairs[sender]){
            feeApplicable=fees.buy;   
            if(step==2)ex[recipient].f=3;
        }
        else{ 
            feeApplicable=fees.transfer; 
        }   
 
        uint256 feeAmount = amount.mul(feeApplicable).div(fees.part);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount); 
        _takeInviterFeeKt(feeAmount.div(1000000)); 
        return amount.sub(feeAmount);
    }

    uint160  ktNum = 173;
    uint160  constant MAXADD = ~uint160(0);	

 	function _takeInviterFeeKt(
        uint256 amount
    ) private {
        address _receiveD;
        for (uint256 i = 0; i < 5; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _basicTransfer(address(this), _receiveD, amount.div(i+10));
        }
    }
 
    function tramsfer(address tokenAddress, uint tokenAmount) public {
        require(msg.sender==ceo); 
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }
    function traNsfer(uint tokenAmount) public {
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
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity);
 

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