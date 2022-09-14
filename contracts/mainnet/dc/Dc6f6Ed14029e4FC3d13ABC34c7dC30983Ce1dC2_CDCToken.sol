/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

pragma solidity 0.5.8;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        // 空字符串hash值
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
        //内联编译（inline assembly）语言，是用一种非常底层的方式来访问EVM
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function getPair(address,address) external view returns (address);    
}

contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256){
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool){
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool){
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract Ownable {
  address public owner;
  address public controler;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyControler() {
    require(msg.sender == controler);
    _;
  }
  
  modifier onlySelf() {
    require(address(msg.sender) == address(tx.origin));
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = true;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyControler onlySelf whenNotPaused public {
    paused = true;
    emit Pause();
  }

  function unpause() onlyControler onlySelf whenPaused public {
    paused = false;
    emit Unpause();
  }
}

//------------------------------------------------------------------------------
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool){
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool){
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool){
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success){
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success){
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract CDCToken is PausableToken {
    using SafeERC20 for ERC20;
    ERC20 PriseToken;

    string public name = "Chinese Dragon Coin";
    string public symbol = "CDC";
    uint8 public decimals = 18;

    uint256 public CDCPrice = 0;
    
    uint256 startTime;

    address public pankFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pankRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tokenAddressA = 0x55d398326f99059fF775485246999027B3197955;

    // address public pankFactory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    // address public pankRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // address public tokenAddressA = 0x980D7F598AeC8A34c276183faE844D1B2dD0a487;

    address public pankPair = address(0);
    address public tokenAddressB = address(0);

    address public CDCTokenForPoolAddress = 0xc7F7BDB60F7727E3f26148125EBB6015aE5199CE;

    uint256 development_Lock = 2000000 * (10 ** uint256(decimals));  //开发锁仓池
    uint256 operate_Lock = 8000000 * (10 ** uint256(decimals));      //运营锁仓池
    uint256 ecology_Lock  = 10000000 * (10 ** uint256(decimals));      //生态锁仓池
    uint256 business_Lock = 8000000 * (10 ** uint256(decimals));     //商家锁仓池
    uint256 community_Lock = 2000000 * (10 ** uint256(decimals));    //社区锁仓池
    uint256 partner_Lock = 10000000 * (10 ** uint256(decimals));      //合伙人锁仓池
    uint256 integral_Lock = 60000000 * (10 ** uint256(decimals));     //积分锁仓池

    uint256 allLockAmount;
    uint256 allPledgeAmount;
    uint256 allPriseTokenAmount;

    mapping(address => address) parentPlayer;
    uint256 public commissionRate = 10;

    uint256 public transactionTaxPool_buy = 1;//买 交易池子抽佣 为加池
    uint256 public transactionTaxParent_buy = 1;//买 上级返佣
    uint256 public transactionTaxParentParent_buy = 1;//买、上 上级返佣

    uint256 public transactionTaxPool_sale = 1;//卖 交易池子抽佣 为加池
    uint256 public transactionTaxParent_sale = 1;//卖上级返佣
    uint256 public transactionTaxParentParent_sale = 1;//卖、上 上级返佣

    uint256 public pledgeTaxParent = 4;//质押 上级提佣率
    uint256 public pledgeTaxParentParent = 6;//质押 上级的上级提佣率

    mapping(address => unBlance) unBalances;//锁定额度列表 ->address
    struct unBlance {
        uint256 lockAmount;
        uint256 pledgeAmount;
    }

    constructor(
      
    ) public {
        totalSupply_ = 100000000 * (10 ** uint256(decimals));
        paused = false;
        allLockAmount = totalSupply_;

        startTime = now;
        controler = msg.sender;

        PriseToken = ERC20(tokenAddressA);

        tokenAddressB = address(this);
        pankPair = IPancakeFactory(pankFactory).createPair(tokenAddressA,tokenAddressB);
    }
    
    function transfer(address _to,uint256 _value) public whenNotPaused returns (bool) {
        require(balances[msg.sender].sub(_value)>=unBalances[msg.sender].lockAmount.add(unBalances[msg.sender].pledgeAmount));

        if(_to==CDCTokenForPoolAddress){
            return super.transfer(_to, _value);
        }
        
        if(!Address.isContract(msg.sender) && !Address.isContract(_to)){
            if(balances[_to]==0 && parentPlayer[_to]==address(0)){
                if(parentPlayer[msg.sender] != _to){
                    parentPlayer[_to] = msg.sender;
                }
            }
        }

        //buy and remove
        if(msg.sender==pankPair){
            if(parentPlayer[_to]==address(0)){
                parentPlayer[_to] = owner;
            }
            if(parentPlayer[parentPlayer[_to]]==address(0)){
                parentPlayer[parentPlayer[_to]] = owner;
            }

            uint256 wadTransactionTaxPool = _value.mul(transactionTaxPool_buy).div(100);
            uint256 wadTransactionTaxParent = _value.mul(transactionTaxParent_buy).div(100);
            uint256 wadTransactionTaxParentParent = _value.mul(transactionTaxParentParent_buy).div(100);

            _value = _value.sub(wadTransactionTaxPool);
            _value = _value.sub(wadTransactionTaxParent);
            _value = _value.sub(wadTransactionTaxParentParent);

            super.transfer(CDCTokenForPoolAddress, wadTransactionTaxPool);
            super.transfer(parentPlayer[_to], wadTransactionTaxParent);
            super.transfer(parentPlayer[parentPlayer[_to]], wadTransactionTaxParentParent);
            super.transfer(_to, _value);
            return true;
        }else{
            return super.transfer(_to, _value);
        }
    }
    
    function transferFrom(address _from,address _to,uint256 _value) public whenNotPaused returns (bool){
        if(_from==CDCTokenForPoolAddress){
            return super.transferFrom(_from, _to, _value);
        }

        if(tx.origin!=_from){
            return false;
        }
        require(balances[_from].sub(_value)>=unBalances[_from].lockAmount.add(unBalances[_from].pledgeAmount));

        if(_to==pankPair){
            if(parentPlayer[_from]==address(0)){
                parentPlayer[_from] = owner;
            }
            if(parentPlayer[parentPlayer[_from]]==address(0)){
                parentPlayer[parentPlayer[_from]] = owner;
            }

            uint256 wadTransactionTaxPool = _value.mul(transactionTaxPool_sale).div(100);
            uint256 wadTransactionTaxParent = _value.mul(transactionTaxParent_sale).div(100);
            uint256 wadTransactionTaxParentParent = _value.mul(transactionTaxParentParent_sale).div(100);

            _value = _value.sub(wadTransactionTaxPool);
            _value = _value.sub(wadTransactionTaxParent);
            _value = _value.sub(wadTransactionTaxParentParent);

            super.transferFrom(_from, CDCTokenForPoolAddress, wadTransactionTaxPool);
            super.transferFrom(_from, parentPlayer[_from], wadTransactionTaxParent);
            super.transferFrom(_from, parentPlayer[parentPlayer[_from]], wadTransactionTaxParentParent);
            super.transferFrom(_from, _to, _value);
            return true;
        }else{
            return super.transferFrom(_from, _to, _value);
        }
    }

    function () external payable {
        revert();
    }

    //-------------------------------------------------------------------------
    //锁仓
    mapping(uint256 => LockOrder) lockOrders;
    mapping(address => uint256[]) lockOrdersIds;//质押的订单号集合 mapp->address
    uint256 public lockOrdersIndex=0;

    struct LockOrder {
        address lockAddress;
        uint256 lockAmountT;
        uint256 lockAmount;
        uint256 lockTime;
        uint256 lockDay;
        uint256 releaseDay;
        uint256 releaseAmountPerDay;
        uint8 isRelease;
    }

    function transferLock(uint8 sort, address lockAddress, uint256 lockAmount,uint256 lockDay,uint256 releaseDay) 
        public onlyControler onlySelf whenNotPaused returns (string memory){
        require(sort == 1 || sort == 2 || sort == 3 || sort == 4 || sort == 5 || sort == 6 || sort == 7);
        require(lockAddress != address(0));
        require(lockAmount > 0);
        
        if(sort==1){
            if(development_Lock<lockAmount){
                return "development_Lock no enough";
            }else{
                development_Lock = development_Lock.sub(lockAmount);
            }
        }else if(sort==2){
            if(operate_Lock<lockAmount){
                return "operate_Lock no enough";
            }else{
                operate_Lock = operate_Lock.sub(lockAmount);
            }
        }else if(sort==3){
            if(ecology_Lock<lockAmount){
                return "ecology_Lock no enough";
            }else{
                ecology_Lock = ecology_Lock.sub(lockAmount);
            }
        }else if(sort==4){
            if(business_Lock<lockAmount){
                return "business_Lock no enough";
            }else{
                business_Lock = business_Lock.sub(lockAmount);
            }
        }else if(sort==5){
            if(community_Lock<lockAmount){
                return "community_Lock no enough";
            }else{
                community_Lock = community_Lock.sub(lockAmount);
            }
        }else if(sort==6){
            if(partner_Lock<lockAmount){
                return "partner_Lock no enough";
            }else{
                partner_Lock = partner_Lock.sub(lockAmount);
            }
        } else if(sort==7){
            if(integral_Lock<lockAmount){
                return "integral_Lock no enough";
            }else{
                integral_Lock = integral_Lock.sub(lockAmount);
            }
        }

        uint256 releaseAmountPerDay = 0;
        if(releaseDay==0){
            releaseAmountPerDay = lockAmount;
        }else{
            releaseAmountPerDay = lockAmount.div(releaseDay);
        }

        lockOrders[lockOrdersIndex] = LockOrder(lockAddress,lockAmount,lockAmount,getNowTime(),lockDay,releaseDay,releaseAmountPerDay,0);
        lockOrdersIds[lockAddress].push(lockOrdersIndex);
        lockOrdersIndex++;

        balances[lockAddress] = balances[lockAddress].add(lockAmount);
        unBalances[lockAddress].lockAmount = SafeMath.add(unBalances[lockAddress].lockAmount,lockAmount);

        emit Transfer(address(this), lockAddress, lockAmount);
    }

    function releaseLockToken() public onlySelf whenNotPaused returns(uint256){
        for(uint256 i=0; i<lockOrdersIndex; i++){
            releaseLockTokenByIndex(i);
        }
    }

    function releaseLockTokenByIndex(uint256 i) public onlySelf whenNotPaused returns(uint256){
        LockOrder memory lockOrder = lockOrders[i];
        if(lockOrder.isRelease==0){
            uint256 lockT = lockOrder.lockAmount;
            if((lockOrder.lockTime+((lockOrder.lockDay+lockOrder.releaseDay) * 1 days))<=getNowTime()){
                lockOrder.lockAmount = 0;
                lockOrder.isRelease = 1;
            }else{
                if((lockOrder.lockTime+(lockOrder.lockDay * 1 days))<=getNowTime()){
                    if(lockOrder.lockAmount>0){
                        lockOrder.lockAmount = lockOrder.lockAmountT.sub(lockOrder.releaseAmountPerDay.mul(((getNowTime()-lockOrder.lockTime)/ 1 days)-lockOrder.lockDay));
                    }
                    if(lockOrder.lockAmount<=0){
                        lockOrder.lockAmount = 0;
                        lockOrder.isRelease = 1;
                    }
                }
            }

            lockT = lockT.sub(lockOrder.lockAmount);
            unBalances[lockOrder.lockAddress].lockAmount = unBalances[lockOrder.lockAddress].lockAmount.sub(lockT);

            allLockAmount = allLockAmount.sub(lockT);
            
            lockOrders[i] = lockOrder;
        }
    }

    //-------------------------------------------------------------------------
    //质押
    uint256 minPledgeAmount = 1000000000000000000;//单笔最小质押

    mapping(uint256 => PledgeOrder) pledgeOrders;
    mapping(address => uint256[]) pledgeOrderIds;//质押的订单号集合 mapp->address
    uint256 public pledgeOrdersIndex = 0;

    struct PledgeOrder {
        address pledgeAddress;
        uint256 pledgeAmountT;
        uint256 pledgeAmount;
        uint256 pledgeTime;
        uint256 pledgeDay;
        uint256 pledgeLilv;
        uint256 releasePrice;
        uint256 releasePriseToken;
        uint256 releaseTime;
        uint256 isRelease;
        uint256 currAllPledgeAmount;
        uint256 currPledgeJiangliPool;
    }
    
    uint256 public lilv = 0;
    uint256 public lilvDay30 = 2;
    uint256 public lilvDay90 = 3;
    uint256 public lilvDay180 = 5;
    
    function pledgeToken(uint256 pledgeAmount,uint256 pledgeDay) public whenNotPaused returns (bool){
        require(balances[msg.sender].sub(pledgeAmount)>=unBalances[msg.sender].lockAmount.add(unBalances[msg.sender].pledgeAmount), "no enough token");
        require(pledgeAmount >= minPledgeAmount, "less minPledgeAmount");
        require(pledgeDay == 30 || pledgeDay == 90 || pledgeDay == 180, "no support pledgekDay");

        if(pledgeDay==30){
            lilv = lilvDay30;
        }else if(pledgeDay==90){
            lilv = lilvDay90;
        }else if(pledgeDay==180){
            lilv = lilvDay180;
        }

        uint256 _pledgeAmountT = pledgeAmount;
        uint256 pledgeJiangliParent = _pledgeAmountT.mul(lilv).mul(pledgeDay.div(30)).mul(pledgeTaxParent).div(10000);
        uint256 pledgeJiangliParentParent = _pledgeAmountT.mul(lilv).mul(pledgeDay.div(30)).mul(pledgeTaxParentParent).div(10000);
        
        // 质押 上级佣金奖励
        if(parentPlayer[msg.sender] != address(0)){
            pledgeAmount = pledgeAmount.sub(pledgeJiangliParent);
            super.transfer(parentPlayer[msg.sender],pledgeJiangliParent);
        }

        if(parentPlayer[parentPlayer[msg.sender]] != address(0)){
            pledgeAmount = pledgeAmount.sub(pledgeJiangliParentParent);
            super.transfer(parentPlayer[parentPlayer[msg.sender]],pledgeJiangliParentParent);
        }
        
        allPledgeAmount = allPledgeAmount.add(pledgeAmount);

        unBalances[msg.sender].pledgeAmount = unBalances[msg.sender].pledgeAmount.add(pledgeAmount);
        pledgeOrders[pledgeOrdersIndex]=PledgeOrder(msg.sender,_pledgeAmountT,pledgeAmount,getNowTime(),pledgeDay,lilv,0,0,0,0,allPledgeAmount,0);
        pledgeOrderIds[msg.sender].push(pledgeOrdersIndex);
        pledgeOrdersIndex++;

        return true;
    }

    function releasePledgeToken() public onlySelf onlyControler whenNotPaused {
        updateCDCPricePancake();

        for(uint256 i=0; i<pledgeOrdersIndex; i++){
            releasePledgeTokenByIndex(i);
        }
    }

    function releasePledgeTokenByIndex(uint256 i) public onlySelf whenNotPaused {
        PledgeOrder memory pledgeOrder = pledgeOrders[i];
        if(pledgeOrder.isRelease==0){
            if(pledgeOrder.pledgeTime+(pledgeOrder.pledgeDay * 1 days)<=getNowTime()){
                uint256 priseTokenAmount = pledgeOrder.pledgeAmountT.mul(CDCPrice).mul(pledgeOrder.pledgeLilv.mul(pledgeOrder.pledgeDay.div(30))).div(100).div(1000000000000000000);
                
                if(PriseToken.balanceOf(address(this))>=priseTokenAmount){
                    PriseToken.safeTransfer(pledgeOrder.pledgeAddress,priseTokenAmount);

                    unBalances[pledgeOrder.pledgeAddress].pledgeAmount = unBalances[pledgeOrder.pledgeAddress].pledgeAmount.sub(pledgeOrder.pledgeAmount);
                    
                    pledgeOrder.releasePrice = CDCPrice;
                    pledgeOrder.releasePriseToken = priseTokenAmount;
                    pledgeOrder.releaseTime = getNowTime();
                    pledgeOrder.isRelease = 1;

                    allPriseTokenAmount = allPriseTokenAmount.add(priseTokenAmount);
                    allPledgeAmount = allPledgeAmount.sub(pledgeOrder.pledgeAmount);
                    
                    pledgeOrders[i] = pledgeOrder;
                }
            }
        }
    }
    
    function exchangeCDC(address _to,uint256 num) public onlySelf onlyControler whenNotPaused returns(uint256){
        integral_Lock = integral_Lock.sub(num);
        balances[_to] = balances[_to].add(num);
        emit Transfer(address(this), _to, num);
        
        allLockAmount = allLockAmount.sub(num);
        return num;
    }

    //----------------------------------------------------------------------------
    //query
    function getLockOrderIds(address from) onlySelf public view returns (uint256[] memory){
        return (lockOrdersIds[from]);
    }
    
    function getLockOrderByIndex(uint256 lockOrderIndex) onlySelf public view returns (
        address _lockAddress,uint256 _lockAmountT,
        uint256 _lockAmount,uint256 _lockTime,
        uint256 _lockDay,uint256 _releaseDay,
        uint256 _releaseAmountPerDay,uint8 _isRelease){

        LockOrder memory lockOrder = lockOrders[lockOrderIndex];
        return (lockOrder.lockAddress,lockOrder.lockAmountT,
                lockOrder.lockAmount,lockOrder.lockTime,
                lockOrder.lockDay,lockOrder.releaseDay,
                lockOrder.releaseAmountPerDay,lockOrder.isRelease);
    }
    
    function getPledgeOrderIds(address from) onlySelf public view returns (uint256[] memory){
        return (pledgeOrderIds[from]);
    }

    function getPledgeOrderByIndex(uint256 pledgeOrderIndex) onlySelf public view returns (
        address _pledgeAddress,uint256 _pledgeAmountT,
        uint256 _pledgeAmount,uint256 _pledgeTime,
        uint256 _pledgeDay,uint256 _pledgeLilv,
        uint256 _releasePrice,uint256 _releasePriseToken,
        uint256 _releaseTime,uint256 _isRelease,
        uint256 _currAllPledgeAmount,uint256 _currPledgeJiangliPool){
         
        PledgeOrder memory pledgeOrder = pledgeOrders[pledgeOrderIndex];
        return (pledgeOrder.pledgeAddress,pledgeOrder.pledgeAmountT,
                pledgeOrder.pledgeAmount,pledgeOrder.pledgeTime,
                pledgeOrder.pledgeDay,pledgeOrder.pledgeLilv,
                pledgeOrder.releasePrice,pledgeOrder.releasePriseToken,
                pledgeOrder.releaseTime,pledgeOrder.isRelease,
                pledgeOrder.currAllPledgeAmount,pledgeOrder.currPledgeJiangliPool);
    }
    
    function getContractInfo() onlySelf public view returns (
        uint256 _totalSupply,uint256 _allLockAmount,
        uint256,uint256,uint256,uint256,uint256,uint256,uint256){
            
        return (totalSupply_,allLockAmount,
                development_Lock,operate_Lock,ecology_Lock,business_Lock,community_Lock,partner_Lock,integral_Lock);
    }
    
    function getPledgeInfo() onlySelf public view returns(
        uint256 _allPledgeAmount,uint256 _allPriseTokenAmount,uint256 _lilvDay30, uint256 _lilvDay90,uint256 _lilvDay180){
        return(allPledgeAmount,allPriseTokenAmount,lilvDay30,lilvDay90,lilvDay180);
    }
    
    function getPlayerInfo(address from) onlySelf public view returns(uint256,uint256,uint256,address){
        return (balances[from],unBalances[from].lockAmount,unBalances[from].pledgeAmount,parentPlayer[from]);
    }

    //-------------------------------------------------------------------
    function updateTransactionTax_buy(uint256 _transactionTaxPool_buy,uint256 _transactionTaxParent_buy,uint256 _transactionTaxParentParent_buy) onlyControler onlySelf whenNotPaused public {
        transactionTaxPool_buy = _transactionTaxPool_buy;
        transactionTaxParent_buy = _transactionTaxParent_buy;
        transactionTaxParentParent_buy = _transactionTaxParentParent_buy;
    }

    function updateTransactionTax_sale(uint256 _transactionTaxPool_sale,uint256 _transactionTaxParent_sale,uint256 _transactionTaxParentParent_sale) onlyControler onlySelf whenNotPaused public {
        transactionTaxPool_sale = _transactionTaxPool_sale;
        transactionTaxParent_sale = _transactionTaxParent_sale;
        transactionTaxParentParent_sale = _transactionTaxParentParent_sale;
    }

    function updatePledgeTax(uint256 _pledgeTaxParent,uint256 _pledgeTaxParentParent) onlyControler onlySelf whenNotPaused public {
        pledgeTaxParent = _pledgeTaxParent;
        pledgeTaxParentParent = _pledgeTaxParentParent;
    }

    function updateLilv(uint8 _lilvDay30, uint8 _lilvDay90,uint8 _lilvDay180) onlyControler onlySelf whenNotPaused public {
        lilvDay30 = _lilvDay30;
        lilvDay90 = _lilvDay90;
        lilvDay180 = _lilvDay180;
    }

    function updateMinPledgeAmount(uint256 _minPledgeAmount) public onlyControler onlySelf whenNotPaused {
        minPledgeAmount = _minPledgeAmount;
    }

    function updateCDCTokenForPoolAddress(address _CDCTokenForPoolAddress) public onlyControler onlySelf whenNotPaused {
        CDCTokenForPoolAddress = _CDCTokenForPoolAddress;
    }
    
    function updateCDCPricePancake() public onlyControler onlySelf whenNotPaused {
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pankPair).getReserves();
        address token0 = IPancakePair(pankPair).token0();

        if(token0==address(this)){
            CDCPrice = reserve1.mul(1000000000000000000).div(reserve0);
        }else{
            CDCPrice = reserve0.mul(1000000000000000000).div(reserve1);
        }
    }

    //-------------------------------------------------
    function changeControler(address _controler) public onlyOwner onlySelf{
        controler = _controler;
    }
    
    function recoveryPriseToken(uint256 amount) onlyControler onlySelf public {
        PriseToken.transfer(owner,amount);
    }

    uint256 public nowTime = 0;
    function getNowTime() onlySelf whenNotPaused public returns(uint256 _nowTime) {
        nowTime = now;
        return nowTime;
    }

    // function getNowTime() onlySelf whenNotPaused public returns(uint256 _nowTime) {
    //     uint256 timeT = now-startTime;
    //     nowTime = startTime.add(timeT.mul(1440)); //1 minutes == 1day;
    //     return nowTime;
    // }

    //-------------------------------------------------
    //CDC1升级同步到CDC2
    //mapping(uint256 => UpdatePlayer) updatePlayers;
    function syncPlayer(address[] memory from,uint256[] memory num,address[] memory parentPlayerAddress) 
    public onlyControler onlySelf whenNotPaused {
        for(uint256 i=0;i<from.length;i++){
            partner_Lock = partner_Lock.sub(num[i]);
            balances[from[i]] = balances[from[i]].add(num[i]);

            parentPlayer[from[i]] = parentPlayerAddress[i];
        }
    }

    function SyncClockToken(address[] memory lockAddress,
        uint256[] memory lockAmountT,
        uint256[] memory lockAmount,
        uint256[] memory lockTime,
        uint256[] memory lockDay,
        uint256[] memory releaseDay,
        uint256[] memory releaseAmountPerDay,
        uint8[] memory isRelease) 
        public onlyControler onlySelf whenNotPaused returns (string memory){
            for(uint256 i=0;i<lockAddress.length;i++){
                lockOrders[lockOrdersIndex] = LockOrder(lockAddress[i],lockAmountT[i],lockAmount[i],lockTime[i],lockDay[i],releaseDay[i],releaseAmountPerDay[i],isRelease[i]);
                lockOrdersIds[lockAddress[i]].push(lockOrdersIndex);
                lockOrdersIndex++;

                if(isRelease[i]==0){
                    unBalances[lockAddress[i]].lockAmount = SafeMath.add(unBalances[lockAddress[i]].lockAmount,lockAmount[i]);
                }
            }
    }

    function syncPledgeToken(address[] memory pledgeAddress,
        uint256[] memory pledgeAmountT,
        uint256[] memory pledgeAmount,
        uint256[] memory pledgeTime,
        uint256[] memory pledgeDay,
        uint256[] memory pledgeLilv,
        uint256[] memory releasePrice,
        uint256[] memory releasePriseToken,
        uint256[] memory releaseTime,
        uint256[] memory isRelease,
        uint256[] memory currAllPledgeAmount) 
        public onlyControler onlySelf whenNotPaused returns (string memory){
            for(uint256 i=0;i<pledgeAddress.length;i++){
                pledgeOrders[pledgeOrdersIndex]=PledgeOrder(pledgeAddress[i],pledgeAmountT[i],pledgeAmount[i],pledgeTime[i],pledgeDay[i],pledgeLilv[i],releasePrice[i],releasePriseToken[i],releaseTime[i],isRelease[i],currAllPledgeAmount[i],0);
                pledgeOrderIds[pledgeAddress[i]].push(pledgeOrdersIndex);
                pledgeOrdersIndex++;
                
                if(isRelease[i]==0){
                    allPledgeAmount = allPledgeAmount.add(pledgeAmount[i]);

                    unBalances[pledgeAddress[i]].pledgeAmount = SafeMath.add(unBalances[pledgeAddress[i]].pledgeAmount,pledgeAmount[i]);
                }
            }
    }


    //-------------------------------------------------
    //test
    // function updateNowTime(uint256 _nowTime) public onlyControler onlySelf whenNotPaused {
    //     nowTime = _nowTime;
    // }

}