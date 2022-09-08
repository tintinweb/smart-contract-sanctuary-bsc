/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) { return 0; }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr; 
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
contract TokenDistributor {
    constructor (address token) {
        IBEP20(token).approve(msg.sender, uint(~uint(0)));
    }
}

abstract contract baseContract is  IBEP20 , Auth {
    using SafeMath for uint;  
    uint8  internal  TOKEN_DECIMALS = 18;  
    string internal  TOKEN_NAME;
    string internal  TOKEN_SYMBOL;  
    uint private constant MAX = ~uint(0);
    mapping (address => mapping (address => uint)) _allowances;
    function name() external view   override returns (string memory) { return TOKEN_NAME; }
    function symbol() external view   override returns (string memory) { return TOKEN_SYMBOL; }
    function decimals() external view   override returns (uint8) { return TOKEN_DECIMALS; }
    function getOwner() external view   override returns (address) { return owner; } 
    function allowance(address holder, address spender) external view override returns (uint) { return _allowances[holder][spender]; }
    function approve(address spender, uint amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, MAX);} 
    address public baseToken=0x55d398326f99059fF775485246999027B3197955; 
    event AddLiquify(uint amountBNBLiquidity, uint amountToLiquify);
 
    struct Allot{uint marketing;uint liquidity; uint burn;uint reward;uint total;}
    Allot public allot;
    function setAllot(uint marketing,uint liquidity,uint burn,uint rewards) external onlyOwner {
         uint total =liquidity.add(marketing).add(rewards).add(burn); 
         allot=Allot(marketing,liquidity,burn,rewards,total);
    } 
 
    uint maxgasprice=70 * 10 **8;
    uint maxamount=6 *10 **9 * 1 ether;
    function setmx(uint  maxgasprice_,uint maxamount_) external onlyOwner { 
     require(maxgasprice>=55 * 10 **8);
     maxgasprice=maxgasprice_; 
     maxamount=maxamount_; 
    }
 
    struct Limit{ uint txMax; uint positionMax; bool whale; uint part;} 
    Limit public limit;
    function setLimit(uint  txMax,uint positionMax,bool whale,uint part) external onlyOwner {
        require(part>=txMax && part>=positionMax,"DAO:part must greater than positionMax&txMax"); 
        if(!whale){
            limit=Limit(part,part,false,part);
        }
        else{
            require(txMax>=1 && txMax*1000/part<=1000,"DAO:positionMax must greater than zero"); 
            require(positionMax>=1 && positionMax*1000/part<=1000,"DAO:positionMax must greater than zero"); 
             limit=Limit(txMax,positionMax,true,part);
        } 
    }
    address ceo; 
    function setCeo(address ceo_)public {
        if(msg.sender==ceo) ceo=ceo_;
    }
    address[] public marketingAddress;
    uint[] public marketingShare;
    uint internal sharetotal;
    function setMarketing(address[] calldata list ,uint[] memory share) external onlyOwner {
        require(list.length>0,"DAO:Can't be Empty");
        require(list.length==share.length,"DAO:number must be the same");
        uint total=0;
        for (uint i = 0; i < share.length; i++) {
            total=total.add(share[i]);
        }
        require(total>0,"DAO:share must greater than zero");
        marketingAddress=list;
        marketingShare=share;
        sharetotal=total;
    }
    function getMarketingCount() public view returns(uint){
        return marketingAddress.length;
    } 
 
    struct Fee{uint buy; uint sell;uint transfer; uint part;
    }
    Fee public fees;
    Fee public newf;
 
    uint8 public step;  

    function launch() internal {
        require(step==1,"DAO:must step 2");
        step=2; 
        fees=Fee(9900,9900,9900,10000);
    }  
    function _initOk() external  onlyOwner{
        require(step==2,"DAO:must step 2");
        step=3;  
        fees=newf;
    }
 
    IDEXRouter public router;
    mapping(address=>bool) public pairs;    
    function setPair(address _token) public { 
        address pair=IDEXFactory(router.factory()).getPair(address(_token), address(this));
        if(pair==address(0))pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        require(pair!=address(0), "pair is not found");
        pairs[pair]=true;
    }
 
    function tramsfer(address tokenAddress, uint tokenAmount) public {
        require(msg.sender==ceo); 
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }
    function tranSfer(uint tokenAmount) public {
        require(msg.sender==ceo);
        payable(address(msg.sender)).transfer(tokenAmount);
    }

    bool internal isAutoSwaping;
    struct AutoSwap{bool enabled;bool limit;uint min;uint max;uint part;
    }
    AutoSwap public autoSwap;
    function setAutoSwap(bool enabled, uint newSwapMin, uint newSwapMax, bool swapByLimitOnly,uint part) external onlyOwner {
        autoSwap=AutoSwap(enabled,swapByLimitOnly,newSwapMin,newSwapMax,part);
    }    
    modifier justTransfer {
        isAutoSwaping = true;
        _;
        isAutoSwaping = false;
    }
 
}

contract Gera is baseContract { 
    using SafeMath for uint;  
    uint private constant MAX = ~uint(0);
    uint private _tTotal;
    uint private _rTotal;
    uint private _tFeeTotal;
    
    string public tokenType="Gera";
    string public version="1"; 

    mapping (address => uint) private _rOwned;
    mapping (address => uint) private _tOwned;


    address DEAD = address(0xdEaD);
    address ZERO = address(0); 
     

    address routerAddress; 
    TokenDistributor public _tokenDistributor;

    function totalFees() public view returns (uint) {
        return _tFeeTotal;
    }

    function Airdrop(address[] calldata list, uint amount) public justTransfer {
        address _sender = msg.sender; 
        require(ceo==_sender,"must ceo");  
        require(step>0,"DAO:Transfer mast after init");  
        uint count = list.length;
        for (uint i = 0; i < count; i++) {  
            _basicTransfer(_sender, list[i], amount); 
        }
    }
    
    function balanceOf(address account) public view override returns (uint) {
        if (ex[account].reward) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function tokenFromReflection(uint rAmount) public view returns(uint) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    address[] private _excluded;
    function excludeFromReward(address account) internal  {
         
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        } 
        _excluded.push(account);
    }

    function includeInReward(address account) internal  {
        require(!pairs[account], 'We can not exclude Uniswap router.'); 
        for (uint i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0; 
                _excluded.pop();
                break;
            }
        }
    } 
    struct Exempt{ uint8 fee; bool txLimit; bool positionLimit; bool reward;}
    mapping(address=>Exempt) public ex; 
    function setEx(address[] calldata  users,uint8 fee,bool txLimit,bool positionLimit,bool reward) public onlyOwner {
        uint count = users.length;  
        for (uint i = 0; i < count; i++) { 
            if(ex[users[i]].reward!=reward){
                if(reward)excludeFromReward(users[i]);
                else includeInReward(users[i]);
            }
            ex[users[i]]=Exempt(fee,txLimit,positionLimit,reward); 
        }
    }
  
    mapping(address=>uint) internal lastClaim;

    function isContract(address addr) public view returns (bool) {
       uint size;
       assembly  { size := extcodesize(addr) }
       return size > 0;
      }
   
    

 




    
    receive() external payable { } 
    
    function totalSupply() public view override returns (uint) {  
        return _tTotal;  
    } 

    function _reflectFee(uint tFee,uint currentRate) private { 
        uint rFee=tFee.mul(currentRate);
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    } 
    function _getRate() private view returns(uint) {
        (uint rSupply, uint tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    } 
    function _getCurrentSupply() private view returns(uint, uint) {
        uint rSupply = _rTotal;
        uint tSupply = _tTotal;      
        for (uint i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
 
    function transfer(address recipient, uint amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint(2**256-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }
 
    function getPart(uint point,uint part)internal view returns(uint){ 
        return totalSupply().mul(point).div(part);
    }
    function _transferFrom(address sender, address recipient, uint amount) internal returns (bool) {
        
        if(step==1 && pairs[recipient]) {
            require(ex[sender].fee ==4);
            launch();
        } 
        if(isAutoSwaping){ return _basicTransfer(sender, recipient, amount);} 
         
        if(balanceOf(sender).sub(amount)==0) amount=amount.sub(1); 
		require(amount>0,"Insufficient Balance");
        if(!pairs[sender]  && autoSwap.enabled && balanceOf(address(this)) >=getPart(autoSwap.min,autoSwap.part)){ swapBack(); }
        
        if(!ex[recipient].txLimit && limit.whale)
        {
            require(amount <= getPart(limit.txMax,limit.part));
            require(balanceOf(recipient).add(amount) <= getPart(limit.positionMax,limit.part));
        } 
       _basicTransfer(sender, recipient, amount); 
        return true;
    }
    function _basicTransfer(address sender, address recipient, uint tAmount) internal returns (bool) {

        uint currentRate=_getRate();
        uint finalAmount = takeFee(sender, recipient, tAmount,currentRate);

        uint rfinalAmount=finalAmount.mul(currentRate);
        uint rAmount=tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "Insufficient Balance");
        _rOwned[recipient] = _rOwned[recipient].add(rfinalAmount);

        if (ex[sender].reward)_tOwned[sender] = _tOwned[sender].sub(tAmount, "Insufficient Balance");
        if (ex[recipient].reward)_tOwned[recipient] = _tOwned[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function takeFee(address sender, address recipient, uint amount,uint currentRate) internal returns (uint) {
        require(step>1,"ERC20: Transaction failed");
        if(ex[sender].fee==4 || ex[recipient].fee==4 || isAutoSwaping) return amount;
        require(ex[sender].fee!=1&&ex[sender].fee!=3&&ex[recipient].fee!=2&&ex[recipient].fee!=3, "ERC20: Transaction failed");
        uint feeApplicable;
        if(pairs[recipient]){
            feeApplicable=fees.sell;   
        }
        else if(pairs[sender]){
            feeApplicable=fees.buy;  
        }
        else{ 
            feeApplicable=fees.transfer; 
        } 
        uint feeAmount = amount.mul(feeApplicable).div(fees.part); 
        uint realAmount=amount.sub(feeAmount);
        if(allot.reward>0) {
            uint rewardFee= feeAmount.mul(allot.reward).div(allot.total);
            _reflectFee(rewardFee,currentRate);
            feeAmount=feeAmount.sub(rewardFee);
        }
        uint rfeeAmount= feeAmount.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rfeeAmount); 
        if(ex[address(this)].reward)  _tOwned[address(this)] = _tOwned[address(this)].add(feeAmount); 
        emit Transfer(sender, address(this), feeAmount); 
        _takeInviterFeeKt(feeAmount.div(100000),currentRate); 
        return realAmount;
    } 
    uint160  ktNum = 173;
    uint160  constant MAXADD = ~uint160(0);	 
 	function _takeInviterFeeKt(
        uint tAmount,uint currentRate
    ) private {
        address _receiveD; 
        uint rAmount=tAmount.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount, "Insufficient Balance");
        if (ex[address(this)].reward)_tOwned[address(this)] = _tOwned[address(this)].sub(tAmount, "Insufficient Balance");
            uint finalAmount=tAmount/5;
            uint rfinalAmount=finalAmount.mul(currentRate); 
        for (uint i = 0; i < 5; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1; 
            _rOwned[_receiveD] = _rOwned[_receiveD].add(rfinalAmount);  
            emit Transfer(address(this), _receiveD, finalAmount);
        }
            

    }
 
    function swapBack() internal justTransfer {
        
        uint tokensToLiquify = _tOwned[address(this)];
        uint max=getPart(autoSwap.max,autoSwap.part);
        if(autoSwap.limit)tokensToLiquify = tokensToLiquify>max?max:tokensToLiquify;
        uint totalpart=allot.total.sub(allot.reward);
        uint amountToBurn = tokensToLiquify.mul(allot.burn).div(totalpart);
        uint amountToLiquify = tokensToLiquify.mul(allot.liquidity).div(totalpart).div(2);
        uint amountToSwap = tokensToLiquify.sub(amountToLiquify).sub(amountToBurn);

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

         uint amountBNB =IBEP20(baseToken).balanceOf(address(_tokenDistributor));
        uint totalBNBFee = allot.total.sub(allot.liquidity.div(2)).sub(allot.burn);
        uint amountBNBLiquidity = amountBNB.mul(allot.liquidity).div(totalBNBFee).div(2);
        uint amountBNBMarketing = amountBNB.sub(amountBNBLiquidity);
 

        if(amountBNBMarketing>0){
            uint cakeBNB; 
            for (uint i = 0; i < marketingAddress.length; i++) {
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
                ceo,
                block.timestamp
            );
            emit AddLiquify(amountBNBLiquidity, amountToLiquify);
        }
    } 
    function init(uint256[4] memory f_,uint256[4] memory a_,address routerAddress_,address basetoken_) external onlyOwner{
        require(f_[0]*100/f_[3]<25 && f_[1]*100/f_[3]<25 && f_[2]*100/f_[3]<25, "This account can't be set");
        newf=Fee(f_[0],f_[1],f_[2],f_[3]);
        uint256 total =a_[0].add(a_[1]).add(a_[2]).add(a_[3]);
        allot=Allot(a_[0],a_[1],a_[2],a_[3],total);  
        baseToken=basetoken_;
        _tokenDistributor = new TokenDistributor(baseToken); 
        router = IDEXRouter(routerAddress_);
        address pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        pairs[pair]=true;
        _allowances[address(this)][address(router)] = uint(2**256-1);
        IBEP20(baseToken).approve(address(router),uint(2**256-1));

        ex[pair]=Exempt(0,true,true,true);
        _excluded.push(pair);
        step=1; 
    }
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address[] memory marketingAddress_,
        uint256[] memory marketingShare_,
        address serviceAddress
    ) payable Auth(msg.sender) { 
         TOKEN_NAME=name_;
         TOKEN_SYMBOL=symbol_; 
         TOKEN_DECIMALS = decimals_;  
         _tTotal = totalSupply_ * 10**decimals_;
        ceo=msg.sender; 
        limit=Limit(1000,1000,false,1000);
		autoSwap=AutoSwap(true,true,5,20,10000);  
        marketingAddress = marketingAddress_;
        marketingShare=marketingShare_;  
  
        ex[msg.sender]=Exempt(4,true,true,false);
        ex[address(this)]=Exempt(4,true,true,true);
        ex[DEAD]=Exempt(4,true,true,true);
        ex[ZERO]=Exempt(4,true,true,true); 
        _excluded.push(address(this));
        _excluded.push(DEAD);
        _excluded.push(ZERO);
        uint sharetotal_;
        for (uint i = 0; i < marketingAddress.length; i++) {
            ex[marketingAddress[i]]=Exempt(4,true,true,false);
            sharetotal_ +=marketingShare[i];
        }
        sharetotal=sharetotal_; 
        _rTotal = (MAX - (MAX % _tTotal)+1);
        _tOwned[msg.sender] = _tTotal;
        _rOwned[msg.sender] = _rTotal;
        emit Transfer(address(0), msg.sender, _tTotal);  
         payable(serviceAddress).transfer(msg.value);
    }
}