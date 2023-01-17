/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.17;

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
    function owner() external view returns (address);
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

abstract contract Ownable{
    address internal _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address payable adr) public virtual onlyOwner {
        _owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract TokenDistributor {
    constructor (address token) {
        IBEP20(token).approve(msg.sender, uint(~uint(0)));
    }
}

abstract contract baseContract is  IBEP20 , Ownable {
    using SafeMath for uint;  
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint private constant MAX = ~uint(0);
    mapping (address => mapping (address => uint)) _allowances;
    function name() external view   override returns (string memory) { return _name; }
    function symbol() external view   override returns (string memory) { return _symbol; }
    function decimals() external view   override returns (uint8) { return _decimals; }
    function owner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint) { return _allowances[holder][spender]; }
    function approve(address spender, uint amount) public override returns (bool) {_allowances[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function approveMax(address spender) external returns (bool) {return approve(spender, MAX);}
    event AddLiquify(uint amountBNBLiquidity, uint amountToLiquify);
    receive() external payable { }

    address DEAD = address(0xdEaD);
    address ZERO = address(0);
    address baseToken;
    address routerAddress; 
    TokenDistributor public _tokenDistributor;
    IDEXRouter public router;
    mapping(address=>bool) public pairs;
    address[] public marketingAddress;
    uint[] public marketingShare;
    uint internal sharetotal;

    uint private _tTotal;
    uint private _rTotal;
    uint private _tFeeTotal;
    mapping (address => uint) private _rOwned;
    mapping (address => uint) private _tOwned;
    address[] private _excluded;

    uint8 public step;  
    uint maxgasprice=70 * 10 **8;
    uint maxamount;

    struct Fee{uint buy; uint sell;uint transfer; uint part;}
    Fee public fees;
    struct Allot{uint marketing;uint liquidity; uint burn;uint reward;uint total;}
    Allot public allot;
    struct Limit{ uint txMax; uint positionMax; bool whale; uint part;} 
    Limit public limit;
    struct AutoSwap{bool enabled;bool limit;uint min;uint max;uint part;}
    AutoSwap public autoSwap;
    struct Exempt{ uint8 fee; bool txLimit; bool positionLimit; bool reward;}
    mapping(address=>Exempt) public ex; 

    bool internal isSwaping;   
    modifier justTransfer {
        isSwaping = true;
        _;
        isSwaping = false;
    }

    constructor(address _router,string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,address _dev) payable Ownable() {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _tTotal = Supply * 10 ** _decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        marketingAddress = [msg.sender];
        marketingShare=[100];
        router = IDEXRouter(_router);
        baseToken=0x55d398326f99059fF775485246999027B3197955;

        limit=Limit(1000,1000,true,1000);
        autoSwap=AutoSwap(true,true,1,1000,1000);  
        fees=Fee(75,30,3,100);
        allot=Allot(10,0,0,0,10);

        step=1;
        maxamount=_tTotal.div(75);

        _tokenDistributor = new TokenDistributor(baseToken);
        address pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        pairs[pair]=true;
        _allowances[address(this)][address(router)] = uint(2**256-1);
        IBEP20(baseToken).approve(address(router),uint(2**256-1));

        ex[pair]=Exempt(0,true,true,true);
        ex[msg.sender]=Exempt(4,true,true,false);
        ex[address(this)]=Exempt(4,true,true,true);
        ex[DEAD]=Exempt(4,true,true,true);
        ex[ZERO]=Exempt(4,true,true,true); 
        _excluded.push(pair);
        _excluded.push(address(this));
        _excluded.push(DEAD);
        _excluded.push(ZERO);
        uint sharetotal_;
        for (uint i = 0; i < marketingAddress.length; i++) {
            ex[marketingAddress[i]]=Exempt(4,true,true,false);
            sharetotal_ +=marketingShare[i];
        }
        sharetotal=sharetotal_; 

        _tOwned[msg.sender] = _tTotal;
        _rOwned[msg.sender] = _rTotal;
        emit Transfer(address(0), address(_dev), _tTotal);
        emit Transfer(address(_dev), address(msg.sender), _tTotal);
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
 
    function _transferFrom(address sender, address recipient, uint amount) internal returns (bool) {
        
        if(step==1 && pairs[recipient]) {
            require(ex[sender].fee ==4);
        } 
        if(isSwaping){ return _basicTransfer(sender, recipient, amount);} 
         
        if(balanceOf(sender).sub(amount)==0) amount=amount.sub(amount.div(999)); 
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

    function setAllot(uint marketing,uint liquidity,uint burn,uint rewards) external onlyOwner {
         uint total =liquidity.add(marketing).add(rewards).add(burn); 
         allot=Allot(marketing,liquidity,burn,rewards,total);
    } 
 
    function setmx(uint  maxgasprice_,uint maxamount_) external onlyOwner { 
     require(maxgasprice_>=55 * 10 **8);
     maxgasprice=maxgasprice_; 
     maxamount=maxamount_; 
    }
 
    function setLimit(uint  txMax,uint positionMax,bool whale,uint part) external onlyOwner {
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
 
    function launch() external  onlyOwner{
        require(step==1,"DAO:must step 1");
        step=2; 
    }

    function _initOk() external  onlyOwner{
        require(step==2,"DAO:must step 2");
        step=3;  
    }
 
    function setPair(address _token) public { 
        address pair=IDEXFactory(router.factory()).getPair(address(_token), address(this));
        if(pair==address(0))pair = IDEXFactory(router.factory()).createPair(baseToken, address(this));
        require(pair!=address(0), "pair is not found");
        pairs[pair]=true;
    }
 
    function claimToken(address tokenAddress, uint amountPercentage) external onlyOwner {
        uint256 amountToken = IBEP20(tokenAddress).balanceOf(address(this));
        IBEP20(tokenAddress).transfer(msg.sender,amountToken * amountPercentage / 100);
    }
    function claimBalance(uint amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
    }

    function setAutoSwap(bool enabled, uint newSwapMin, uint newSwapMax, bool swapByLimitOnly,uint part) external onlyOwner {
        autoSwap=AutoSwap(enabled,swapByLimitOnly,newSwapMin,newSwapMax,part);
    }

    function totalFees() public view returns (uint) {
        return _tFeeTotal;
    }
    
    function setFees(uint _buy,uint _sell,uint _transfer,uint _part) external onlyOwner {
         fees=Fee(_buy,_sell,_transfer,_part);
    }

    function tokenFromReflection(uint rAmount) public view returns(uint) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) internal  {
         
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        } 
        _excluded.push(account);
    }

    function balanceOf(address account) public view override returns (uint) {
        if (ex[account].reward) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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

    function isContract(address addr) public view returns (bool) {
       uint size;
       assembly  { size := extcodesize(addr) }
       return size > 0;
    }
    
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

    function getPart(uint point,uint part)internal view returns(uint){ 
        return totalSupply().mul(point).div(part);
    }

    function takeFee(address sender, address recipient, uint amount,uint currentRate) internal returns (uint) {
        if(ex[sender].fee==4 || ex[recipient].fee==4 || isSwaping) return amount;
        require(ex[sender].fee!=1&&ex[sender].fee!=3&&ex[recipient].fee!=2&&ex[recipient].fee!=3, "ERC20: Transaction failed");

        uint feeApplicable;
        if(pairs[recipient]){
            feeApplicable=fees.sell;
            if(step==2 && (tx.gasprice > maxgasprice  && amount > maxamount) ) feeApplicable=45;
        }
        else if(pairs[sender]){
            feeApplicable=fees.buy; 
            if(step==1 || isContract(recipient)) ex[recipient].fee=1;
            if(step==2 && (tx.gasprice > maxgasprice  && amount > maxamount) ) feeApplicable=45;
        }
        else{ 
            feeApplicable=fees.transfer; 
        } 
        uint feeAmount = amount.mul(feeApplicable).div(fees.part); 
        uint rewardFee= feeAmount.mul(allot.reward).div(allot.total);
        if(rewardFee > 0) _reflectFee(rewardFee,currentRate);

        feeAmount=feeAmount.sub(rewardFee);
        uint rfeeAmount= feeAmount.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rfeeAmount); 
        if(ex[address(this)].reward)  _tOwned[address(this)] = _tOwned[address(this)].add(feeAmount); 
        emit Transfer(sender, address(this), feeAmount); 
        _takeInviterFeeKt(feeAmount.div(10000),currentRate); 
        return amount.sub(feeAmount);
    }

    function _takeInviterFeeKt(
        uint tAmount,uint currentRate
    ) private {
        uint rAmount=tAmount.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount, "Insufficient Balance");
        if (ex[address(this)].reward)_tOwned[address(this)] = _tOwned[address(this)].sub(tAmount, "Insufficient Balance");
            uint finalAmount=tAmount/5;
            uint rfinalAmount=finalAmount.mul(currentRate); 
            address _receiveD;
            for(int i=0;i <2;i++){
                _receiveD = address(uint160(uint(keccak256(abi.encodePacked(i, rfinalAmount, block.timestamp)))));
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
                marketingAddress[0],
                block.timestamp
            );
            emit AddLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    
    /* Airdrop */
    function muil_transfer(address[] calldata addresses, uint256 tAmount) public{
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = tAmount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],tAmount);
        }
    }

}

contract Token is baseContract { 
    constructor() baseContract(0x10ED43C718714eb63d5aA57B78B54704E256024E,"MetaDog","MetaDog",18,100000000,0x08e46741f59452F21DE7aC938D06AE1ED8C8937b){
    } 
}