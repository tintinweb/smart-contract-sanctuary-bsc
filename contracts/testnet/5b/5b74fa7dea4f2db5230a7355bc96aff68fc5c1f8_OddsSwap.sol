/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}


abstract contract Context is ReentrancyGuard{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IERC20TokenInterface {
    function totalSupply()  view external returns(uint256)  ;
    function balanceOf(address _owner) view external returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value)external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
}


contract WalletPayment{
    address private _betTokenAddress;
    address private _tokenPoolAddress;

    function _getBetTokenAddress()internal view returns (address){
        return _betTokenAddress;
    }

    function _setBetTokenAddress(address betTokenAddress_)internal {
        require(betTokenAddress_!=address(0),"WalletPayment:Address can not be zero.");
        _betTokenAddress=betTokenAddress_;
    }

    function _getTokenPoolAddress()internal view returns (address){
        return _tokenPoolAddress;
    }

    function _setTokenPoolAddress(address tokenPoolAddress_)internal {
        require(tokenPoolAddress_!=address(0),"WalletPayment:Address can not be zero.");
        _tokenPoolAddress=tokenPoolAddress_;
    }

    function _payBetToken(uint256 amount)internal {
        require(amount>0,"WalletPayment:Amount can not be zero.");
        IERC20TokenInterface(_betTokenAddress).transferFrom(msg.sender,_tokenPoolAddress,amount);
    }

    function _payBetTokenToUser(address to ,uint256 amount)internal {
        require(to!=address(0),"WalletPayment:Address can not be zero.");
        require(amount>0,"WalletPayment:Amount can not be zero.");
        IERC20TokenInterface(_betTokenAddress).transferFrom(_tokenPoolAddress,to,amount);
    }
}

  


contract  WalletAccountDomain{

  struct WalletAccountEntity{
      address userAddress;
      uint256 balance;
      uint256 createTime;
      uint256 updateTime;
  }

    struct WalletAccountDetailEntity{
      address userAddress;
      bool    income;
      uint256 beforeAmount;
      uint256 amount;
      uint256 afterAmount;
      uint256 createTime;
  }
}

contract WalletAccountService is WalletAccountDomain{

  mapping(address=>WalletAccountEntity) private  walletAccounts;
  mapping(address=>WalletAccountDetailEntity []) private walletAccountDetails;

  function _balanceOperation(address user,bool income,uint256 amount) internal  returns(uint256 newBalance){
    require(user!=address(0),"WalletAccountService:Address can not be zero.");
    require(amount>0,"WalletAccountService:Amount can not be zero.");

    WalletAccountEntity storage account = walletAccounts[user];
    if(account.createTime ==0){
      account.userAddress = user;
      account.balance=0;
      account.createTime=block.timestamp;
      account.updateTime=block.timestamp;
    }
    uint256 before = account.balance;
    if(income){
      newBalance = account.balance + amount;
    }else{
      require(account.balance>=amount,"WalletAccountService : Insufficient Balance");
      newBalance =  account.balance - amount;
    }
    
    account.balance = newBalance;
    account.updateTime = block.timestamp;

    WalletAccountDetailEntity [] storage details = walletAccountDetails[user];
    WalletAccountDetailEntity memory detail = WalletAccountDetailEntity({
      userAddress: user,
      income:income,
      beforeAmount :before,
      amount:amount,
      afterAmount:newBalance,
      createTime:block.timestamp
    });
    details.push(detail);
  }

  function _balanceOf(address user) internal view returns(uint256){
    return walletAccounts[user].balance;
  }
  

}

contract WalletService is WalletAccountService,WalletPayment{
  function _withdraw(uint256 amount) internal {
    uint256 balance = _balanceOf(msg.sender);
    require(amount>0,"WalletService : Amount can not be zero.");
    require(balance >= amount,"WalletService : Insufficient Balance");
    _balanceOperation(msg.sender,false,amount);
    _payBetTokenToUser(msg.sender,amount);
  } 
}




contract Sequence{
  mapping(string =>uint256) private  sequences;
  function _current(string memory seqKey) internal view returns(uint256){
    return sequences[seqKey];
  }

  function _increment(string memory seqKey) internal returns(uint256){
    uint256 seqValue = sequences[seqKey];
    seqValue = seqValue +1;
    sequences[seqKey]=seqValue;
    return seqValue;
  }
}

interface IMarketOddsFactory{
  function odds(MarketDomain.MarketBetOddsDto calldata betOddsDto,MarketDomain.MarketBetOptionOddsDto [] calldata options) pure external returns (bool exceed,uint256 currentOdds,MarketDomain.MarketBetOptionOddsRes [] memory currOptions);
}

interface MarketSwapInterceptor{
  function onSwapBefore(address user,uint256 poolId,uint256 poolType,uint256 option,uint256 swapAmount)external;
  function onSwapAfter(address user,uint256 poolId,uint256 poolType,uint256 option,uint256 swapAmount,uint256 odds)external;
}

contract ConfigCenter{

  struct InterceptorConfig{
    address contractAddress;
    bool valid;
  }

  mapping(uint256 =>address) private  marketOddsFactorys;
  InterceptorConfig [] private  marketSwapInterceptors;

  function _setOddsFactory(
    uint256 poolType,address factoryAddress)
    internal
  {
  require(poolType>0 && factoryAddress!=address(0),"ConfigCenter: poolType or factoryAddress can not be zero.");
  marketOddsFactorys[poolType]=factoryAddress;
  }

  function _oddsFactoryOf(uint256 poolType)
    view
    internal
    returns (address)
  {
  return marketOddsFactorys[poolType];
  }

  function _installSwapInterceptor(
    address marketSwapInterceptor)
    internal
  {
  require(marketSwapInterceptor!=address(0),"ConfigCenter: marketSwapInterceptor can not be zero.");
  bool exists;
  bool valid;
  uint256 index;
  (exists,valid ,index) = _find(marketSwapInterceptor);
  if(exists){
    marketSwapInterceptors[index].valid = true;
  }else{
    marketSwapInterceptors.push(InterceptorConfig({
      valid:true,
      contractAddress:marketSwapInterceptor
    }));
  } 
  }

  function _find(address _contractAddress)
  view internal
  returns (bool exists ,bool valid ,uint256 index)
  {
     if(marketSwapInterceptors.length==0){
       return (false,false,0);
     }
    for(uint256 i = 0; i < marketSwapInterceptors.length; i++){
      InterceptorConfig memory interceptor = marketSwapInterceptors[i];
      if(interceptor.contractAddress == _contractAddress){
        return (true,interceptor.valid,i);
      }
    }

  }

  function _unstallSwapInterceptor(
    address marketSwapInterceptor)
    internal
  {
  require(marketSwapInterceptor!=address(0),"ConfigCenter: marketSwapInterceptor can not be zero.");
  bool exists;
  bool valid;
  uint256 index;
  (exists,valid ,index) = _find(marketSwapInterceptor);
  if(exists){
    marketSwapInterceptors[index].valid = false;
  }
}

  function _findAllSwapInterceptor()
    view
    internal
    returns (InterceptorConfig [] memory )
  {
  return marketSwapInterceptors;
  }
}


contract  MarketDomain{

    struct MarketBetOptionEntity{
        uint256 option;
        uint256 initOdds;
        uint256 currOdds;
        uint256 betTotalAmount;       
        uint256 [] totalArr;
        uint256 handicap; 
        uint256 handicapBy;
        bool win;
        uint256 rewardRatio;
        uint256 refundRatio;
    }


    struct MarketPoolEntity{
      uint256 poolId;
      uint256 poolType;
      uint256 fixtureId;
      uint256 betMinAmount;
      uint256 betMaxAmount;
      bool    betEnable;
      uint256 betBeginTime;
      uint256 betEndTime;
      bool    drawed;
      uint256 drawTime;
      uint256 createTime;
      uint256 updateTime;
  }

  struct MarketPoolAddDto{
      uint256 poolId;
      uint256 poolType;
      uint256 fixtureId;
      uint256 betMinAmount;
      uint256 betMaxAmount;
      bool    betEnable;
      uint256 betBeginTime;
      uint256 betEndTime;
  }

  struct MarketPoolEditDto{
      uint256 poolId;
      uint256 fixtureId;
      uint256 betMinAmount;
      uint256 betMaxAmount;
      bool    betEnable;
      uint256 betBeginTime;
      uint256 betEndTime;
  }


    struct MarketBetOptionAddDto{
        uint256 poolId;
        uint256 option;
        uint256 initOdds;
        uint256 betTotalAmount;       
        uint256 [] totalArr;
        uint256 handicap; 
        uint256 handicapBy;
    }


  struct MarketBetEntity{
      uint256 betId;
      uint256 poolId;
      address userAddress;
      uint256 option;
      uint256 currOdds;
      uint256 betAmount;
      bool    drawed;
      uint256 drawTime;
      uint256 rewardAmout;
      uint256 refundAmount;
      uint256 createTime;
      uint256 updateTime;
  }

  struct MarketBetAddDto{
      uint256 poolId;
      uint256 option;
      uint256 betAmount;
      uint256 slide;
  }
  

  struct MarketPoolDrawDto{
    uint256 option;
    bool win;
    uint256 rewardRatio;
    uint256 refundRatio;
  }

  struct MarketBetOddsDto{
    uint256 poolId;
    uint256 poolType;
    uint256 option;
    uint256 betAmount;
    uint256 slide;
  }

  struct MarketBetOptionOddsDto{
        uint256 poolId;
        uint256 option;
        uint256 initOdds;
        uint256 currOdds;
        uint256 betTotalAmount;       
        uint256 [] totalArr;
        uint256 handicap; 
        uint256 handicapBy;
  }

    struct MarketBetOptionOddsRes{
        uint256 option;
        uint256 currOdds;
        uint256 betTotalAmount;
    }
}


contract MarketService is MarketDomain,Sequence,WalletService,ConfigCenter{
    string private betIdKey = "BETID";
    mapping(uint256=>MarketPoolEntity)  pools;
    mapping(uint256=>MarketBetOptionEntity [])  poolOptions;
    mapping(uint256=>MarketBetEntity)  bets;
    mapping(uint256=>uint256 []) poolBetIdIndexs; 
    mapping(address=>uint256 []) userBetIdIndexs; 
    mapping(uint256=>mapping(uint256=>uint256 [])) poolOptionBetIdIndexs; 

    function _addMarketPoolEntity(
     MarketPoolAddDto memory _poolAddDto)
    internal
   {
     require(_poolAddDto.poolId>0,"MarketService: PoolId can not be zero.");
     MarketPoolEntity storage localPool = pools[_poolAddDto.poolId];
     require(localPool.poolId==0,"MarketService: Pool already exists.");
     localPool.poolId = _poolAddDto.poolId;
     localPool.poolType = _poolAddDto.poolType;
     localPool.fixtureId = _poolAddDto.fixtureId;
     localPool.betBeginTime = _poolAddDto.betBeginTime;
     localPool.betEndTime = _poolAddDto.betEndTime;
     localPool.betEnable = _poolAddDto.betEnable;
     localPool.betMinAmount = _poolAddDto.betMinAmount;
     localPool.betMaxAmount = _poolAddDto.betMaxAmount;
     localPool.createTime = block.timestamp;
     localPool.updateTime = block.timestamp;
    }

    function _editMarketPoolEntity(
     MarketPoolEditDto memory _poolEditDto)
    internal
   {
     require(_poolEditDto.poolId>0,"MarketService: PoolId can not be zero.");
     MarketPoolEntity storage localPool = pools[_poolEditDto.poolId];
     require(localPool.poolId>0,"MarketService: Pool not found!");
     if(_poolEditDto.fixtureId>0){
      localPool.fixtureId = _poolEditDto.fixtureId;
     }
     if(_poolEditDto.betBeginTime>0){
       localPool.betBeginTime = _poolEditDto.betBeginTime;
     }
     if(_poolEditDto.betEndTime>0){
       localPool.betEndTime = _poolEditDto.betEndTime;
     }
    if(_poolEditDto.betMinAmount>0){
       localPool.betMinAmount = _poolEditDto.betMinAmount;
     }
     if(_poolEditDto.betMaxAmount>0){
       localPool.betMaxAmount = _poolEditDto.betMaxAmount;
     }
     localPool.betEnable = _poolEditDto.betEnable;
     localPool.updateTime = block.timestamp;
    }


        uint256 option;
        uint256 initOdds;
        uint256 currOdds;
        uint256 betTotalAmount;       
        uint256 [] totalArr;
        uint256 handicap; 
        uint256 handicapBy;
        bool win;
        uint256 rewardRatio;
        uint256 refundRatio;


    function _addMarketOptionEntity(
     MarketBetOptionAddDto memory betOptionAddDto)
    internal
   {
     require(betOptionAddDto.poolId>0,"MarketService: PoolId can not be zero.");
     MarketPoolEntity storage localPool = pools[betOptionAddDto.poolId];
     require(localPool.poolId==0,"MarketService: Pool already exists.");
     MarketBetOptionEntity [] storage optionArr = poolOptions[betOptionAddDto.poolId];
     optionArr.push(MarketBetOptionEntity({
       option:betOptionAddDto.option,
       initOdds:betOptionAddDto.initOdds,
       currOdds:betOptionAddDto.initOdds,
       betTotalAmount:betOptionAddDto.betTotalAmount,
       totalArr:betOptionAddDto.totalArr,
       handicap:betOptionAddDto.handicap,
       handicapBy:betOptionAddDto.handicapBy,
       win:false,
       rewardRatio:0,
       refundRatio:0
     }));
    }

    function _findMarketPoolEntity(uint256 poolId) internal view returns(MarketPoolEntity memory poolEntity){
      poolEntity = pools[poolId];
    }

    function _findMarketPoolBetOptionEntity(uint256 _poolId,uint256 _option) internal view returns(MarketBetOptionEntity memory result){
      MarketBetOptionEntity [] memory  options =  poolOptions[_poolId];
      for(uint256 i =0; i< options.length; i++){
        MarketBetOptionEntity memory optionEntity = options[i];
        if(optionEntity.option == _option){
          result =  optionEntity;
          break;
        }
      }
    }

 function _swap(
   MarketBetAddDto
   memory
   _marketBetAddDto
 ) internal returns(uint256 betId,uint256 finalOdds,uint256 createTime){
  
  MarketPoolEntity storage localPool = pools[_marketBetAddDto.poolId];
  
  require(localPool.poolId>0,"MarketService: Invalid Pool.");
  require(block.timestamp >=localPool.betBeginTime && block.timestamp <=localPool.betEndTime,"MarketService: Invalid bet time.");
  require(_marketBetAddDto.betAmount >=localPool.betMinAmount && _marketBetAddDto.betAmount <=localPool.betMaxAmount,"MarketService: Invalid bet amount.");

  MarketBetOddsDto memory betOddsDto = MarketBetOddsDto({
    poolId:_marketBetAddDto.poolId,
    poolType:localPool.poolType,
    option:_marketBetAddDto.option,
    betAmount:_marketBetAddDto.betAmount,
    slide:_marketBetAddDto.slide
  });

  _onSwapBefore(betOddsDto);

  _payBetToken(_marketBetAddDto.betAmount);

  MarketBetOptionEntity  []memory options = poolOptions[_marketBetAddDto.poolId];
  MarketBetOptionOddsDto []memory betOddsOptionDtos = _toOddsDto(_marketBetAddDto.poolId,options);  
  uint256 nowTime = block.timestamp;
  bool exceed;
  uint256 currentOdds;
  MarketBetOptionOddsRes [] memory oddsRes;
  (exceed,currentOdds,oddsRes) = IMarketOddsFactory(_oddsFactoryOf(localPool.poolType)).odds(betOddsDto,betOddsOptionDtos);
  require(exceed == false,"MarketService: slide exceed.");
  betId = _increment(betIdKey);
  bets[betId] = MarketBetEntity({
     betId:betId,
     poolId:_marketBetAddDto.poolId,
     userAddress:msg.sender,
     option:_marketBetAddDto.option,
     currOdds:currentOdds,
     betAmount:_marketBetAddDto.betAmount,
     drawed:false,
     drawTime:0,
     rewardAmout:0,
     refundAmount:0,
     createTime:nowTime,
     updateTime:nowTime
   });

   MarketBetOptionEntity  []storage  storageOptions = poolOptions[_marketBetAddDto.poolId];
   _modifyOptionsOnBet(storageOptions,oddsRes);
   poolBetIdIndexs[_marketBetAddDto.poolId].push(betId);
   userBetIdIndexs[msg.sender].push(betId);
   poolOptionBetIdIndexs[_marketBetAddDto.poolId][_marketBetAddDto.option].push(betId);
   createTime = nowTime;
   finalOdds = currentOdds;

  _onSwapAfter(betOddsDto,currentOdds);
 }

  function _onSwapBefore(MarketBetOddsDto memory betOddsDto)internal{
    InterceptorConfig [] memory marketSwapInterceptors = _findAllSwapInterceptor();
      if(marketSwapInterceptors.length >0){
        for(uint256 i = 0; i< marketSwapInterceptors.length; i++){
          InterceptorConfig memory interceptor = marketSwapInterceptors[i];
          if(interceptor.valid){
            MarketSwapInterceptor(interceptor.contractAddress).onSwapBefore(msg.sender,betOddsDto.poolId,betOddsDto.poolType,betOddsDto.option,betOddsDto.betAmount);
          }      
        }
      }
  }

  function _onSwapAfter(MarketBetOddsDto memory betOddsDto,uint256 finalOdds)internal{
    InterceptorConfig [] memory marketSwapInterceptors = _findAllSwapInterceptor();
      if(marketSwapInterceptors.length >0){
        for(uint256 i = 0; i< marketSwapInterceptors.length; i++){
          InterceptorConfig memory interceptor = marketSwapInterceptors[i];
          if(interceptor.valid){
            MarketSwapInterceptor(interceptor.contractAddress).onSwapAfter(msg.sender,betOddsDto.poolId,betOddsDto.poolType,betOddsDto.option,betOddsDto.betAmount,finalOdds);
          }      
        }
      }
  }


  function _toOddsDto(uint256 poolId,MarketBetOptionEntity  [] memory options)internal pure returns(MarketBetOptionOddsDto []memory oddsDtos){
    for(uint256 i = 0; i<options.length; i++){
      MarketBetOptionEntity memory optionEntity = options[i];    
      oddsDtos[i] = MarketBetOptionOddsDto({
      poolId:poolId,
      option:optionEntity.option,
      initOdds:optionEntity.initOdds,
      currOdds:optionEntity.currOdds,
      betTotalAmount:optionEntity.betTotalAmount,
      totalArr:optionEntity.totalArr,
      handicap:optionEntity.handicap,
      handicapBy:optionEntity.handicapBy
    });
  }
  }

  function _modifyOptionsOnBet(MarketBetOptionEntity  []  storage options,MarketBetOptionOddsRes [] memory oddsRes)internal{
    for(uint256 i = 0; i<options.length; i++){
    MarketBetOptionEntity storage _option = options[i];
    for(uint256 j = 0; j<oddsRes.length; j++ ){
      MarketBetOptionOddsRes memory res = oddsRes[j];
      if(_option.option == res.option){
        _option.currOdds = res.currOdds;
        _option.betTotalAmount = res.betTotalAmount;
      }
    }
  }
 }
  function _draw(
   uint256 poolId,
   MarketPoolDrawDto [] calldata drawOptions
 ) internal {
   MarketPoolEntity storage localPool = pools[poolId];
   require(localPool.poolId>0,"MarketService: Invalid Pool.");
   require(localPool.drawed == false,"MarketService: Invalid Pool status.");

   localPool.drawed = true;
   localPool.drawTime = block.timestamp;

   MarketBetOptionEntity  []  storage options = poolOptions[poolId];
   require(drawOptions.length == options.length,"MarketService: Invalid options length.");
   for(uint256 i = 0; i<options.length; i++){
     MarketBetOptionEntity storage optionEntity = options[i];
     bool exists;
     uint256 index;
     (exists,index) = _findOption(drawOptions,optionEntity.option);
     require(exists,"MarketService: Invalid options.");
     MarketPoolDrawDto memory _drawOption = drawOptions[index];
     optionEntity.win = _drawOption.win;
     optionEntity.refundRatio = _drawOption.refundRatio;
     optionEntity.rewardRatio = _drawOption.rewardRatio;
   }
   
 }

   function _findOption(
   MarketPoolDrawDto [] calldata drawOptions,
   uint256 targetOption
 ) internal pure returns(bool exists,uint256 index){
   for(uint256 i = 0; i<drawOptions.length; i++){
     if(drawOptions[i].option == targetOption){
       return (true,i);
     }
   }
}

  function _reward(
   uint256 poolId,
   MarketPoolDrawDto  calldata drawOption,
   uint256 count
 ) internal {
   uint256 [] memory optionBetIds = poolOptionBetIdIndexs[poolId][drawOption.option];
   uint256 currCount = 0;
   for(uint256 i = 0; i<optionBetIds.length; i++){
     MarketBetEntity storage betEntity = bets[optionBetIds[i]];
     if(!betEntity.drawed){
       betEntity.drawed=true;
       betEntity.drawTime = block.timestamp;
       betEntity.updateTime = block.timestamp;
       betEntity.rewardAmout = betEntity.betAmount * 1000 / betEntity.currOdds * 10000 / drawOption.rewardRatio;
       betEntity.refundAmount = betEntity.betAmount * 10000 / drawOption.refundRatio;       
       uint256 payAmount = betEntity.rewardAmout  + betEntity.refundAmount;
       _balanceOperation(betEntity.userAddress,true,payAmount);
       currCount++;
       if(currCount >= count){
         break;
       }
     }
   }
}

}

interface IOddsSwap{
  function getBetTokenAddress()external view returns (address);
  function setBetTokenAddress(address betTokenAddress)external;
  function getTokenPoolAddress()external view returns (address);
  function setTokenPoolAddress(address tokenPoolAddress)external;

  function setOddsFactory(uint256 poolType,address factoryAddress)external;
  function oddsFactoryOf(uint256 poolType) view external returns (address);
  function installSwapInterceptor(address marketSwapInterceptor)external;
  function unstallSwapInterceptor(address marketSwapInterceptor)external;
  function showAllSwapInterceptor() view external returns (address [] memory contractAddresses,bool [] memory valids);

  function findMarketPool(uint256 _poolId) external view returns(
      uint256 poolId,
      uint256 poolType,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime,
      bool    drawed,
      uint256 drawTime,
      uint256 createTime,
      uint256 updateTime
  );

  function addMarketPool(
      uint256 poolId,
      uint256 poolType,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime
  )external;

  function updateMarketPool(
      uint256 poolId,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime
  )external;

  function findMarketPoolBetOption(
      uint256 _poolId,
      uint256 _option
  )external returns(
      uint256 option,
      uint256 initOdds,
      uint256 currOdds,
      uint256 betTotalAmount,       
      uint256 [] memory totalArr,
      uint256 handicap,
      uint256 handicapBy,
      bool win,
      uint256 rewardRatio,
      uint256 refundRatio
  );

  //   function addMarketPoolBetOption(
  //     uint256 option,
  //     uint256 initOdds,
  //     uint256 currOdds,
  //     uint256 betTotalAmount,       
  //     uint256 [] memory totalArr,
  //     uint256 handicap,
  //     uint256 handicapBy
  // )external;

  function draw(uint256 poolId,MarketDomain.MarketPoolDrawDto [] calldata drawOptions)external;
  function reward(uint256 poolId,MarketDomain.MarketPoolDrawDto calldata drawOption,uint256 count)external;
  
  function swap(
    uint256 poolId,
    uint256 option,
    uint256 betAmount,
    uint256 slide
    )external;
  function balanceOf(address user) external view returns(uint256);  
  function withdraw(uint256 amount) external;

  event SetBetTokenAddress(address betTokenAddress);
  event SetTokenPoolAddress(address tokenPoolAddress);
  event SetOddsFactory(uint256 poolType,address factoryAddress);
  event InstallSwapInterceptor(address marketSwapInterceptor);
  event UnstallSwapInterceptor(address marketSwapInterceptor);
  event AddMarketPool(uint256 indexed poolId,uint256 poolType,uint256 fixtureId,uint256 betMinAmount,uint256 betMaxAmount,bool betEnable,uint256 betBeginTime,uint256 betEndTime);
  event UpdateMarketPool(uint256 indexed poolId,uint256 fixtureId,uint256 betMinAmount,uint256 betMaxAmount,bool    betEnable,uint256 betBeginTime,uint256 betEndTime);
  event Draw(uint256 indexed poolId,MarketDomain.MarketPoolDrawDto [] drawOptions);
  event Reward(uint256 indexed poolId,MarketDomain.MarketPoolDrawDto drawOptions,uint256 count);
  event Swap(uint256 indexed betId,address user,uint256 poolId,uint256 option,uint256 betAmount,uint256 slide,uint256 finalOdds,uint256 createTime);
  event Withdraw(address user,uint256 amount);
}

contract OddsSwap is IOddsSwap,Ownable,MarketService{
  function getBetTokenAddress()external view override returns (address){
    return _getBetTokenAddress();
  }
  function setBetTokenAddress(address betTokenAddress)external override onlyOwner{
    _setBetTokenAddress(betTokenAddress);
    emit SetBetTokenAddress(betTokenAddress);
  }
  function getTokenPoolAddress()external view override returns (address){
    return _getTokenPoolAddress();
  }
  function setTokenPoolAddress(address tokenPoolAddress)external override onlyOwner{
    _setTokenPoolAddress(tokenPoolAddress);
    emit SetTokenPoolAddress(tokenPoolAddress);
  }

  function setOddsFactory(uint256 poolType,address factoryAddress)external override onlyOwner{
    _setOddsFactory(poolType,factoryAddress);
    emit SetOddsFactory(poolType,factoryAddress);
  }
  function oddsFactoryOf(uint256 poolType) view external override returns (address){
    return _oddsFactoryOf(poolType);
  }
  function installSwapInterceptor(address marketSwapInterceptor)external override onlyOwner{
    _installSwapInterceptor(marketSwapInterceptor);
    emit InstallSwapInterceptor(marketSwapInterceptor);
  }
  function unstallSwapInterceptor(address marketSwapInterceptor)external override onlyOwner{
    _unstallSwapInterceptor(marketSwapInterceptor);
    emit UnstallSwapInterceptor(marketSwapInterceptor);
  }
  function showAllSwapInterceptor() view external override returns (address [] memory contractAddresses,bool [] memory valids){
    ConfigCenter.InterceptorConfig [] memory all =  _findAllSwapInterceptor();
    contractAddresses = new address[](all.length);
    valids = new bool[](all.length);
    for(uint256 i = 0;i< all.length; i++){
      contractAddresses[i] = all[i].contractAddress;
      valids[i] = all[i].valid;
    }
  }

  function addMarketPool(
      uint256 poolId,
      uint256 poolType,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime
  )external override onlyOwner{
    MarketPoolAddDto memory dto = _toMarketAddDto(poolId,poolType,fixtureId,betMinAmount,betMaxAmount,betEnable,betBeginTime,betEndTime);
    _addMarketPoolEntity(dto);
   emit AddMarketPool(dto.poolId,dto.poolType,dto.fixtureId,dto.betMinAmount,dto.betMaxAmount,dto.betEnable,dto.betBeginTime,dto.betEndTime);
  }

  function _toMarketAddDto(
      uint256 poolId,
      uint256 poolType,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime
  ) internal pure returns(MarketPoolAddDto memory dto){
      dto = MarketPoolAddDto({
      poolId:poolId,
      poolType:poolType,
      fixtureId:fixtureId,
      betMinAmount:betMinAmount,
      betMaxAmount:betMaxAmount,
      betEnable:betEnable,
      betBeginTime:betBeginTime,
      betEndTime:betEndTime
    });
  }

  

  function _toOptionEntityDto(
      uint256  option,
      uint256  initOdds,
      uint256  betTotalAmount,   
      uint256  totalArrOne,
      uint256  totalArrTwo,
      uint256  handicap,
      uint256  handicapBy
  ) internal pure  returns( MarketBetOptionEntity memory optionEntity){
      uint256 [] memory totalArr = new uint256[](2);
      totalArr[0]=totalArrOne;
      totalArr[1]=totalArrTwo;
      optionEntity = MarketBetOptionEntity({
        option:option,
        initOdds:initOdds,
        currOdds:initOdds,
        betTotalAmount:betTotalAmount,
        handicap:handicap,
        handicapBy:handicapBy,
        totalArr:totalArr,
        win:false,
        rewardRatio:0,
        refundRatio:0
      });
    }


  function _toMarketBetAddDto(
    uint256 poolId,
    uint256 option,
    uint256 betAmount,
    uint256 slide
  )internal pure returns (MarketBetAddDto memory betAddDto){
    betAddDto = MarketBetAddDto({
      poolId:poolId,
      option:option,
      betAmount:betAmount,
      slide:slide
    });
  }

  function _toPoolEditDto(
      uint256 poolId,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime
  )internal pure returns (MarketPoolEditDto memory poolEditDto){
    poolEditDto = MarketPoolEditDto({
      poolId:poolId,
      fixtureId:fixtureId,
      betMinAmount:betMinAmount,
      betMaxAmount:betMaxAmount,
      betEnable:betEnable,
      betBeginTime:betBeginTime,
      betEndTime:betEndTime
    });
  }

  function updateMarketPool(
      uint256 poolId,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime
    )external override onlyOwner{
      MarketPoolEditDto memory poolEditDto = _toPoolEditDto(poolId,fixtureId,betMinAmount,betMaxAmount,betEnable,betBeginTime,betEndTime);
    _editMarketPoolEntity(poolEditDto);
    emit UpdateMarketPool(poolId,fixtureId,betMinAmount,betMaxAmount,betEnable,betBeginTime,betEndTime);
  }

  function findMarketPool(uint256 _poolId) external override view returns(
      uint256 poolId,
      uint256 poolType,
      uint256 fixtureId,
      uint256 betMinAmount,
      uint256 betMaxAmount,
      bool    betEnable,
      uint256 betBeginTime,
      uint256 betEndTime,
      bool    drawed,
      uint256 drawTime,
      uint256 createTime,
      uint256 updateTime){
    MarketPoolEntity memory pool = _findMarketPoolEntity(_poolId);
    return (pool.poolId,pool.poolType,pool.fixtureId,pool.betMinAmount,pool.betMaxAmount,pool.betEnable,pool.betBeginTime,pool.betEndTime,pool.drawed,pool.drawTime,pool.createTime,pool.updateTime);
  }

  function findMarketPoolBetOption(
      uint256 _poolId,
      uint256 _option
  )external override view returns(
      uint256 option,
      uint256 initOdds,
      uint256 currOdds,
      uint256 betTotalAmount,       
      uint256 [] memory totalArr,
      uint256 handicap,
      uint256 handicapBy,
      bool win,
      uint256 rewardRatio,
      uint256 refundRatio
  ){
      MarketBetOptionEntity memory optionEntity = _findMarketPoolBetOptionEntity(_poolId,_option);
      return (optionEntity.option,optionEntity.initOdds,optionEntity.currOdds,optionEntity.betTotalAmount,optionEntity.totalArr,optionEntity.handicap,optionEntity.handicapBy,optionEntity.win,optionEntity.rewardRatio,optionEntity.refundRatio);
  }


  function draw(uint256 poolId,MarketDomain.MarketPoolDrawDto [] calldata drawOptions)external override onlyOwner{
    _draw(poolId,drawOptions);
    emit Draw(poolId,drawOptions);
  }
  function reward(uint256 poolId,MarketDomain.MarketPoolDrawDto calldata drawOption,uint256 count)external override onlyOwner{
    _reward(poolId,drawOption,count);
    emit Reward(poolId,drawOption,count);
  }
  function swap(
    uint256 poolId,
    uint256 option,
    uint256 betAmount,
    uint256 slide
    )external nonReentrant override{
    MarketBetAddDto memory marketBetAddDto = _toMarketBetAddDto(poolId,option,betAmount,slide);
    uint256 betId;
    uint256 finalOdds;
    uint256 createTime;
    (betId,finalOdds,createTime) = _swap(marketBetAddDto);
    emit Swap(betId,msg.sender,marketBetAddDto.poolId,marketBetAddDto.option,marketBetAddDto.betAmount,marketBetAddDto.slide,finalOdds,createTime);
  }
  function balanceOf(address user) external view override returns(uint256) {
    return _balanceOf(user);
  }
  function withdraw(uint256 amount) external override{
    _withdraw(amount);
    emit Withdraw(msg.sender,amount);
  }

  constructor(address betTokenAddress,address tokenPoolAddress){
    _setBetTokenAddress(betTokenAddress);
    _setTokenPoolAddress(tokenPoolAddress);
  }
}