// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Include.sol";

struct SMake {
    address maker;
    bool    isBid;
    address asset;
    uint    volume;
    bytes32 currency;
    uint    price;
    uint    payType;
    uint    pending;
    uint    remain;
    uint    minVol;
    uint    maxVol;
    string  link;
    uint    adPex;
}

struct STake {
    uint    makeID;
    address taker;
    uint    vol;
    Status  status;
    uint    expiry;
    string  link;
    uint    realPrice;
    address recommender;
}

enum Status { None, Paid, Cancel, Done, Appeal, Buyer, Seller,Vault,MerchantOk,MerchantAppeal,MerchantAppealDone,ClaimTradingMargin} 

struct AppealInfo{
    uint takeID;
    address appeal;
    address arbiter;
    Status winner;   //0 Status.None  Status.Buyer Status.seller  assetTo
    //Status assetTo;  //buyer seller
    Status appealFeeTo;   //vault  buyer seller
   
    //address buyStakeTo;  //LP punish always to vault
    //buystaking  lp punish to vault
    Status punishSide;  //0 Status.None  Status.Buyer Status.seller
    uint punishVol;
    Status punishTo; //other side or vault
    bool isDeliver;
}

struct ArbiterPara{
    uint takeID;
    Status winner;
    //Status assetTo;
    Status appealFeeTo;
    Status punishSide;
    uint punishVol;
    Status punishTo; //other side or vault
}

struct SMakeEx {
    bool    isPrivate;
    string  memo;
    uint    tradingMargin;
    uint    priceType;  //0:fix  1:float plus 2:float %
    int    floatVal; //plus or %
}

struct TakePara{
    uint makeID;
    uint volume;
    string link;
    uint price;
    address recommender;
}

contract DOTC is Configurable {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    bytes32 internal constant _expiry_      = "expiry";
    //bytes32 internal constant _feeTo_       = "feeTo";
    bytes32 internal constant _feeToken_    = "feeToken";
    bytes32 internal constant _feeVolume_   = "feeVolume";
    bytes32 internal constant _feeRate_     = "feeRate";
    bytes32 internal constant _feeRatio1_   = "feeRatio1";
    bytes32 internal constant _feeBuf_      = "feeBuf";
    bytes32 internal constant _lastUpdateBuf_= "lastUpdateBuf";
    bytes32 internal constant _spanBuf_     = "spanBuf";
    bytes32 internal constant _spanLock_    = "spanLock";
    bytes32 internal constant _rewardOfSpan_= "rewardOfSpan"; 
    bytes32 internal constant _rewardRatioMaker_    = "rewardRatioMaker";
    bytes32 internal constant _rewardToken_ = "rewardToken";
    bytes32 internal constant _rewards_     = "rewards";
    bytes32 internal constant _locked_      = "locked";
    bytes32 internal constant _lockEnd_     = "lockEnd";
/*  bytes32 internal constant _rebaseTime_  = "rebaseTime";
    bytes32 internal constant _rebasePeriod_= "rebasePeriod";
    bytes32 internal constant _factorPrice20_   = "factorPrice20";
    bytes32 internal constant _lpTknMaxRatio_   = "lpTknMaxRatio";
    bytes32 internal constant _lpCurMaxRatio_   = "lpCurMaxRatio";*/
    bytes32 internal constant _vault_  = "vault";
    bytes32 internal constant _pairTokenA_  = "pairTokenA";
    bytes32 internal constant _swapFactory_ = "swapFactory";
    bytes32 internal constant _swapRouter_  = "swapRouter";
    bytes32 internal constant _mine_        = "mine";
    bytes32 internal constant _assetList_   = "assetList";
    bytes32 internal constant _assetFreeLimit_   = "assetFreeLimit";
    bytes32 internal constant _usd_   = "usd";
    bytes32 internal constant _bank_   = "bank";
    bytes32 internal constant _merchantPool_   = "merchantPool";
    bytes32 internal constant _tradingPool_   = "tradingPool";
    bytes32 internal constant _preDoneExpiry_   = "preDoneExpiry";//7days
    bytes32 internal constant _priceAndRate_  = "priceAndRate";
    bytes32 internal constant _babtoken_ = "babtoken";
    

    address public staking;
    address[] public arbiters;
    mapping (address => bool) public    isArbiter;
    mapping (address => uint) public    biddingN;
   
    mapping (uint => SMake) public makes;
    mapping (uint => STake) public takes;
    uint public makesN;
    uint public takesN;
    
    mapping(uint =>address) public appealAddress; //takeID=> appeal address  //obs    new  appealInfos
    mapping(uint =>bool) public makePrivate; //makeID=> public or private; //obs    new makeExs

    uint private _entered;
    modifier nonReentrant {
        require(_entered == 0, "reentrant");
        _entered = 1;
        _;
        _entered = 0;
    }

    mapping (address => string) public links; //tg link
    mapping(uint =>AppealInfo) public appealInfos; //takeID=> AppealInfo

    mapping(uint =>SMakeEx) public  makeExs; //makeID=>SMakeEx



    function __DOTC_init(address governor_, address staking_,address feeTo_, address feeToken_,uint feeVolume_) public initializer {
        __Governable_init_unchained(governor_);
        __DOTC_init_unchained(staking_,feeTo_,feeToken_,feeVolume_);
    }

    function __DOTC_init_unchained(address staking_,address vault_, address feeToken_,uint feeVolume_) internal governance initializer{
        staking = staking_;
        config[_expiry_]    = 30 minutes;
        config[_vault_] = uint(vault_);
        config[_feeToken_] = uint(feeToken_);
        config[_feeVolume_] = feeVolume_;

        __DOTC_init_reward();
    }

    function __DOTC_init_reward() public governance {
        config[_feeRate_    ] = 0.01e18;        //  1%
        config[_feeRatio1_  ] = 1e18;//0.10e18;        // 10% 100%
        config[_feeBuf_     ] = 1_000_000e18;
        config[_lastUpdateBuf_]= now;
        config[_spanBuf_    ] = 5 days;
        config[_spanLock_   ] = 5 days;
        config[_rewardOfSpan_]= 0;//1_000_000e18;
        config[_rewardRatioMaker_] = 0.25e18;   // 25%
        config[_rewardToken_] = uint(0x5b78d9310Aab5b615Bed73E66048a4F55466e70F);      // tPear
        config[_pairTokenA_ ] = uint(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);      // BUSD
        config[_swapFactory_] = uint(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);      // PancakeFactory V2
        config[_swapRouter_ ] = uint(0x10ED43C718714eb63d5aA57B78B54704E256024E);      // PancakeRouter V2
        config[_mine_       ] = uint(0xafe16b5b7026B60AC36944B9F7B5B078E5ce4a03);
        _setConfig(_assetList_, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, 1);    // BUSD
        _setConfig(_assetList_, 0x55d398326f99059fF775485246999027B3197955, 1);    // USDT
        _setConfig(_assetList_, 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, 1);    // USDC
		__DOTC_init_reward2();
    }
	
	function __DOTC_init_reward2() public governance {
      //  _setConfig(_assetFreeLimit_, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, 1e18);    // BUSD //test 1
      //  _setConfig(_assetFreeLimit_, 0x55d398326f99059fF775485246999027B3197955, 1e18);    // USDT 
      //  _setConfig(_assetFreeLimit_, 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, 1e18);    // USDC
        config[_usd_ ] = uint(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);      // BUSD
        config[_rewardToken_] = uint(0x6a0b66710567b6beb81A71F7e9466450a91a384b);      // pear
        
		/*config[_rebaseTime_      ] = now.add(0 days).add(8 hours).sub(now % 8 hours);
        config[_rebasePeriod_    ] = 8 hours;
        config[_factorPrice20_   ] = 1.1e18;           // price20 = price1 * 1.1
        config[_lpTknMaxRatio_   ] = 0.10e18;        // 10%
        config[_lpCurMaxRatio_   ] = 0.50e18;        // 50% */
        config[_pairTokenA_ ] = uint(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);      // WBNB
		//config[_feeTo_] = uint(address(this));
        (,uint p2) = priceEth();
        p2 = p2.div(2); //50% off
        config[_feeBuf_     ] = config[_rewardOfSpan_].mul(p2).div(1e18);

	}


   /* function migrate(address vault_) external governance {
        config[_vault_] = uint(vault_);
        __DOTC_init_reward2();
    }*/	

    function setBiddingN_(address account,uint biddingN_) external governance {
        biddingN[account] = biddingN_;
    }

    function setVault_(address vault_) public {
        require(msg.sender == 0x2CcF6beEa31e2e68A84117C131cCD1d0acBA6353,"only manage 0x2CCF");
        config[_vault_] = uint(vault_);
    }

    function setBABToken_(address babtoken_) external governance {
        config[_babtoken_] = uint(babtoken_);
    }

    function setArbiters_(address[] calldata arbiters_,string[] calldata links_) external governance {
        for(uint i=0; i<arbiters.length; i++)
            isArbiter[arbiters[i]] = false;
            
        arbiters = arbiters_;
        
        for(uint i=0; i<arbiters.length; i++){
            isArbiter[arbiters[i]] = true;
            links[arbiters[i]] = links_[i];
        }
            
        emit SetArbiters(arbiters_);
    }
    event SetArbiters(address[] arbiters_);



    function make(SMake memory make_,SMakeEx memory makeEx_/*bool isPrivate*/) virtual external nonReentrant returns(uint makeID) { 
        require(make_.volume > 0, 'volume should > 0');
        require(make_.minVol <= make_.maxVol , 'minVol must <= maxVol');
        require(make_.maxVol <= make_.volume, 'maxVol must <= volume');
        if (makeEx_.tradingMargin>0){
            require(IMerchantStakePool(address(config[_merchantPool_])).isMerchant(msg.sender),"must merchant");
        }else if (make_.volume > getConfigA(_assetFreeLimit_,make_.asset) && ISBT721(address(config[_babtoken_])).balanceOf(msg.sender) == 0){
            require(IStaking(staking).enough(msg.sender),"make ad GT Limit,must stake");
        }
        if(make_.isBid) {
            //require(staking == address(0) || IStaking(staking).enough(msg.sender));
            biddingN[msg.sender]++;
        } else
            IERC20(make_.asset).safeTransferFrom(msg.sender, address(this), make_.volume);
        if (make_.adPex>0)
            IERC20(address(config[_rewardToken_])).safeTransferFrom(msg.sender, address(config[_vault_]), make_.adPex);
        makeID = makesN;
        make_.maker = msg.sender;
        make_.pending = 0;
        make_.remain = make_.volume;
        makes[makeID]=make_; //SMake(msg.sender, isBid, asset, volume, currency, price,payType, 0, volume,minVol,maxVol,link,adPex,isPrivate);
        //makePrivate[makeID] = isPrivate; 
        makeExs[makeID] = makeEx_;
        makesN++;
        emit Make(makeID, msg.sender, make_.isBid, make_.asset, make_,makeEx_.isPrivate);
        emit MakeEx(makeID,makeEx_);
    }
    event Make(uint indexed makeID, address indexed maker, bool isBid, address indexed asset, SMake smake,bool isPrivate);
    event MakeEx(uint indexed makeID,SMakeEx makeExs);

    function cancelMake(uint makeID) virtual external nonReentrant returns (uint vol) {
        require(makes[makeID].maker != address(0), 'Nonexistent make order');
        require(makes[makeID].maker == msg.sender, 'only maker');
        require(makes[makeID].remain > 0, 'make.remain should > 0');
        //require(config[_disableCancle_] == 0, 'disable cancle');
        
        vol = makes[makeID].remain;
        if (!makes[makeID].isBid)
            IERC20(makes[makeID].asset).safeTransfer(msg.sender, vol);
        else{
            if(makes[makeID].pending ==0)
                biddingN[msg.sender] = biddingN[msg.sender].sub(1);
        }
        makes[makeID].remain = 0;
        emit CancelMake(makeID, msg.sender, makes[makeID].asset, vol);
    }
    event CancelMake(uint indexed makeID, address indexed maker, address indexed asset, uint vol);
    
    function reprice(uint makeID, uint newPrice) virtual external returns (uint vol, uint newMakeID) {
        require(makes[makeID].maker != address(0), 'Nonexistent make order');
        require(makes[makeID].maker == msg.sender, 'only maker');
        require(makes[makeID].remain > 0, 'make.remain should > 0');
        
        vol = makes[makeID].remain;
        //bool makePri = makePrivate[makeID];
        newMakeID = makesN;
        SMake memory  newMake;
        newMake = makes[makeID];
        newMake.volume = vol;
        newMake.price = newPrice;
        newMake.pending = 0;
        newMake.remain = vol;
        makes[newMakeID] =newMake; 
        //makePrivate[newMakeID] = makePri;
        makeExs[newMakeID] = makeExs[makeID];
        makesN++;
        makes[makeID].remain = 0;
        if (makes[makeID].isBid && makes[makeID].pending > 0){
            biddingN[msg.sender] = biddingN[msg.sender].add(1);
        }
        emit CancelMake(makeID, msg.sender, makes[makeID].asset, vol);
        emit Make(newMakeID, msg.sender, makes[newMakeID].isBid, makes[newMakeID].asset, makes[newMakeID], makeExs[newMakeID].isPrivate);
        emit Reprice(makeID, newMakeID, msg.sender, newMake,makeExs[newMakeID].isPrivate);

    }
    event Reprice(uint indexed makeID, uint indexed newMakeID, address indexed maker, SMake smake,bool makePri);

 
    function take(uint makeID, uint volume,string memory link,uint price,address recommender) virtual external nonReentrant returns (uint takeID, uint vol) {
        //(takeID,vol) = ArbitrateLib.takeLib(makes,makeExs,takes,config,biddingN,makeID,volume,link,price,recommender);
        (takeID,vol) = ArbitrateLib.takeLib(makes,makeExs,takes,config,biddingN,TakePara(makeID,volume,link,price,recommender));
        
        takesN++;

        /*require(makes[makeID].maker != address(0), 'Nonexistent make order');
        require(makes[makeID].remain > 0, 'make.remain should > 0');
        require(makes[makeID].minVol <= volume , 'volume must > minVol');
        require(makes[makeID].maxVol >= volume, 'volume must < maxVol');
        if (makeExs[makeID].tradingMargin>0){//config[_tradingPool_]
            IERC20(address(config[_feeToken_])).safeTransferFrom(msg.sender, address(this), makeExs[makeID].tradingMargin);
            if(IERC20(address(config[_feeToken_])).allowance(address(this),address(config[_tradingPool_]))<makeExs[makeID].tradingMargin)
                IERC20(address(config[_feeToken_])).approve(address(config[_tradingPool_]),uint(-1));
            ITradingStakePool(address(config[_tradingPool_])).stake(msg.sender,makeExs[makeID].tradingMargin);
        }else if (volume > getConfigA(_assetFreeLimit_,makes[makeID].asset))
            require(IStaking(staking).enough(msg.sender),"GT Limit,must stake");
        vol = volume;
        if(vol > makes[makeID].remain)
            vol = makes[makeID].remain;
        if(!makes[makeID].isBid) {
            //require(staking == address(0) || IStaking(staking).enough(msg.sender));
            biddingN[msg.sender]++;
        } else
            IERC20(makes[makeID].asset).safeTransferFrom(msg.sender, address(this), vol);

        makes[makeID].remain = makes[makeID].remain.sub(vol);
        makes[makeID].pending = makes[makeID].pending.add(vol);
        
        uint realPrice;
        uint priceType = makeExs[makeID].priceType;
        if(priceType!=0){
            (uint price1,uint8 decimals,uint rate) = IPriceAndRate(address(config[_priceAndRate_])).getPriceAndRate(makes[makeID].asset,makes[makeID].currency);
            require(price1>0,"No the asset");
            require(rate>0,"No the currency");
            if (priceType ==1)
                realPrice = price1.mul(rate).div(uint(decimals)).add(makeExs[makeID].floatVal);//1170e18 *6.71e18
            else if(priceType ==2)
                realPrice = price1.mul(rate).div(uint(decimals)).mul(1e18+makeExs[makeID].floatVal).div(1e18);//
            uint diff = realPrice>price? realPrice-price:price-realPrice;
            require(diff.mul(1000)<realPrice.mul(5),"price not match chainlink");
            realPrice = price;
        }else{
            realPrice  = makes[makeID].price;
        }
        takeID = takesN;
        takes[takeID] = STake(makeID, msg.sender, vol, Status.None, now.add(config[_expiry_]),link,realPrice);
        takesN++;
        emit Take(takeID, makeID, msg.sender, vol, takes[takeID].expiry,link,realPrice);*/
    }
    //event Take(uint indexed takeID, uint indexed makeID, address indexed taker, uint vol, uint expiry,string link,uint realPrice);

    function cancelTake(uint takeID) virtual external nonReentrant returns(uint vol) {
        require(takes[takeID].taker != address(0), 'Nonexistent take order');
        uint makeID = takes[takeID].makeID;
        (address buyer, address seller) = makes[makeID].isBid ? (makes[makeID].maker, takes[takeID].taker) : (takes[takeID].taker, makes[makeID].maker);

        if(msg.sender == buyer) {
            require(takes[takeID].status <= Status.Paid, 'buyer can cancel neither Status.None nor Status.Paid take order');
        } else if(msg.sender == seller) {
            require(takes[takeID].status == Status.None, 'seller can only cancel Status.None take order');
            require(takes[takeID].expiry < now, 'seller can only cancel expired take order');
        } else
            revert('only buyer or seller');
        if (!makes[makeID].isBid)
            biddingN[buyer] = biddingN[buyer].sub(1);
        vol = takes[takeID].vol;
        IERC20(makes[makeID].asset).safeTransfer(seller, vol);

        makes[makeID].pending = makes[makeID].pending.sub(vol);
        takes[takeID].status = Status.Cancel;

        if (makes[makeID].isBid){
            if(makes[makeID].pending==0 && makes[makeID].remain == 0)
                biddingN[buyer] = biddingN[buyer].sub(1);
        }

        emit CancelTake(takeID, makeID, msg.sender, vol);
    }
    event CancelTake(uint indexed takeID, uint indexed makeID, address indexed sender, uint vol);
    
    function paid(uint takeID) virtual external {
        require(takes[takeID].taker != address(0), 'Nonexistent take order');
        require(takes[takeID].status == Status.None, 'only Status.None');
        uint makeID = takes[takeID].makeID;
        address buyer = makes[makeID].isBid ? makes[makeID].maker : takes[takeID].taker;
        require(msg.sender == buyer, 'only buyer');

        takes[takeID].status = Status.Paid;
        takes[takeID].expiry = now.add(config[_expiry_]);

        emit Paid(takeID, makeID, buyer);
    }
    event Paid(uint indexed takeID, uint indexed makeID, address indexed buyer);

    function deliver(uint takeID) virtual external nonReentrant returns(uint vol) {
        require(takes[takeID].taker != address(0), 'Nonexistent take order');
        require(takes[takeID].status <= Status.Paid, 'only Status.None or Paid');
        uint makeID = takes[takeID].makeID;
        (address buyer, address seller) = makes[makeID].isBid ? (makes[makeID].maker, takes[takeID].taker) : (takes[takeID].taker, makes[makeID].maker);
        require(msg.sender == seller, 'only seller');
        vol = takes[takeID].vol;
        uint fee = _payFee(takeID, makes[makeID].asset, vol);
        IERC20(makes[makeID].asset).safeTransfer(buyer, vol.sub(fee));
        makes[makeID].pending = makes[makeID].pending.sub(vol);
        takes[takeID].status = Status.Done;
        takes[takeID].expiry =now.add(config[_preDoneExpiry_]);

        if ((!makes[makeID].isBid) || (makes[makeID].remain==0 && makes[makeID].pending == 0))
            biddingN[buyer] = biddingN[buyer].sub(1);

        emit Deliver(takeID, makeID, seller, vol);
        emit ArbitrateLib.Deal(takeID,makes[makeID].asset,vol);
    }
    event Deliver(uint indexed takeID, uint indexed makeID, address indexed seller, uint vol);
    //event Deal(uint indexed takeID, address indexed asset, uint vol);

    function merchantOk(uint takeID) virtual external nonReentrant {
        ArbitrateLib.merchantOk(makes,makeExs,takes,config,takeID);
        /*uint makeID = takes[takeID].makeID;
        require(makes[makeID].maker == msg.sender, 'must be maker');
        require(takes[takeID].status == Status.Done, 'only Status.Done');
        takes[takeID].status == Status.MerchantOk;   */  
    }

    function claimTradingMargin(uint takeID) virtual external nonReentrant {
        ArbitrateLib.claimTradingMargin(makes,makeExs,takes,config,takeID);
        /*require(takes[takeID].taker == msg.sender, 'must be taker');
        require(takes[takeID].status == Status.MerchantOk ||((takes[takeID].status == Status.Done)&&(now>takes[takeID].expiry)&&makeExs[takes[takeID].makeID].tradingMargin>0),"No claimTradingMargin");
        takes[takeID].status == Status.ClaimTradingMargin; 
        ITradingStakePool(config[_tradingPool_]).withdraw(msg.sender,makeExs[takes[takeID].makeID].tradingMargin); */
    }

    function appeal(uint takeID) virtual external nonReentrant {
        ArbitrateLib.appeal(makes,makeExs,takes,config,appealInfos,takeID,arbiters,isArbiter);//mapping(uint =>AppealInfo) public appealInfos
       /*require(takes[takeID].taker != address(0), 'Nonexistent take order');
        require(takes[takeID].status == Status.Paid, 'only Status.Paid');
        uint makeID = takes[takeID].makeID;
        require(msg.sender == makes[makeID].maker || msg.sender == takes[takeID].taker, 'only maker or taker');
        require(takes[takeID].expiry < now, 'only expired');
        IERC20(address(config[_feeToken_])).safeTransferFrom(msg.sender, address(config[_vault_]), config[_feeVolume_]);
        takes[takeID].status = Status.Appeal;
        appealAddress[takeID] = msg.sender; 
        emit Appeal(takeID, makeID, msg.sender, takes[takeID].vol);*/
    }
    //event Appeal(uint indexed takeID, uint indexed makeID, address indexed sender, uint vol);



    function arbitrate(uint takeID, Status winner,Status appealFeeTo,Status punishSide,uint punishVol,Status punishTo) virtual external nonReentrant returns(uint vol) {
        ArbiterPara memory arbiterPara=ArbiterPara(takeID,winner,appealFeeTo,punishSide,punishVol,punishTo);

        vol = ArbitrateLib.arbitrate(makes,makeExs,takes,config,appealInfos,biddingN,arbiterPara);
  /*      require(takes[takeID].taker != address(0), 'Nonexistent take order');
        require(takes[takeID].status == Status.Appeal, 'only Status.Appeal');
        require(isArbiter[msg.sender], 'only arbiter');

        uint makeID = takes[takeID].makeID;
        (address buyer, address seller) = makes[makeID].isBid ? (makes[makeID].maker, takes[takeID].taker) : (takes[takeID].taker, makes[makeID].maker);

        
        vol = takes[takeID].vol;
        if(status == Status.Buyer) {
            uint fee = _payFee(takeID, makes[makeID].asset, vol);
            IERC20(makes[makeID].asset).safeTransfer(buyer, vol.sub(fee));
            emit Deal(takeID,makes[makeID].asset,vol);
        } else if(status == Status.Seller) {
            IERC20(makes[makeID].asset).safeTransfer(seller, vol);
            if(staking.isContract())
                IStaking(staking).punish(buyer);
        } else
            revert('status should be Buyer or Seller');

        makes[makeID].pending = makes[makeID].pending.sub(vol);
        takes[takeID].status = status;

        if ((!makes[makeID].isBid) || (makes[makeID].remain==0 && makes[makeID].pending == 0))
            biddingN[buyer] = biddingN[buyer].sub(1);

        emit Arbitrate(takeID, makeID, msg.sender, vol, status);*/
   }
//    event Arbitrate(uint indexed takeID, uint indexed makeID, address indexed arbiter, uint vol, Status status);



    function _feeBuf() internal view returns(uint) {
        uint spanBuf = config[_spanBuf_];
        return spanBuf.sub0(now.sub(config[_lastUpdateBuf_])).mul(config[_feeBuf_]).div(spanBuf);
    }
    
    function price1() public view returns(uint) {
        return _feeBuf().mul(1e18).div0(config[_rewardOfSpan_]);
    }
    
    function price() public view returns(uint p1, uint p2) {
        (p1,p2) = ArbitrateLib.price(config);
        /*(p1,p2) = priceEth();
        address tokenA = address(config[_pairTokenA_]);
        address usd = address(config[_usd_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA,usd);
        uint volA = IERC20(tokenA).balanceOf(pair);
        uint volU = IERC20(usd).balanceOf(pair);
        p1 = p1.mul(volU).div(volA);
        p2 = p2.mul(volU).div(volA);*/
    }

    function priceEth() public view returns(uint p1, uint p2) {
        (p1,p2) = ArbitrateLib.priceEth(config);
        /*p1 = price1();
        
        address tokenA = address(config[_pairTokenA_]);
        address tokenR = address(config[_rewardToken_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA, tokenR);
        if(pair == address(0) || IERC20(tokenA).balanceOf(pair) == 0)
            p2 = 0;
        else
            p2 = IERC20(tokenA).balanceOf(pair).mul(1e18).div(IERC20(tokenR).balanceOf(pair));*/
    }


    function earned(address acct) public view returns(uint) {
        return getConfigA(_rewards_, acct);
    }

    function lockEnd(address acct) public view returns(uint) {
        return getConfigA(_lockEnd_, acct);
    }
    
    function locked(address acct) public view returns(uint) {
        uint end = lockEnd(acct);
        return getConfigA(_locked_, acct).mul(end.sub0(now)).div0(end);
    }

    function hasBABToken(address acct) public view returns(bool) {
        return ISBT721(address(config[_babtoken_])).balanceOf(acct) != 0;
    }

    function claimable(address acct) public view returns (uint) {
        return earned(acct).sub(locked(acct));
    }

    function claim() external {
        claimFor(msg.sender);
    }

    function claimFor(address acct) internal nonReentrant {
        IERC20(config[_rewardToken_]).safeTransfer(acct, claimable(acct));
        _setConfig(_rewards_, acct, locked(acct));
    }

    function payFee(uint takeID, address asset, uint vol) public returns(uint fee) {
        require(msg.sender == address(this),"must msg.sender == address(this)");
        fee =  _payFee(takeID, asset, vol) ;
    }


    function _payFee(uint takeID, address asset, uint vol) internal returns(uint fee) {
        fee = vol.mul(config[_feeRate_]).div(1e18);
        if(fee == 0)
            return fee;
        address rewardToken = address(config[_rewardToken_]);
        (IUniswapV2Router01 router, address tokenA, uint amt) = _swapToPairTokenA(asset, fee);

        uint amt1 = amt.mul(config[_feeRatio1_]).div(1e18);
        IERC20(tokenA).safeTransfer(address(config[_vault_]), amt1);
        uint feeBuf = _feeBuf();
        vol  = amt1.mul(config[_rewardOfSpan_]).div0(feeBuf);
        IERC20(rewardToken).safeTransferFrom(address(config[_mine_]), address(this), vol);
        config[_feeBuf_] = feeBuf.add(amt1);
        config[_lastUpdateBuf_] = now;

        if(amt.sub(amt1)>0){
            address[] memory path = new address[](2);
            path[0] = tokenA;
            path[1] = rewardToken;
            IERC20(tokenA).safeApprove_(address(router), amt.sub(amt1));
            uint[] memory amounts = router.swapExactTokensForTokens(amt.sub(amt1), 0, path, address(this), now);
            payFee2(takeID,vol,amounts[1]);
        }
        IVault(config[_vault_]).rebase();
    }
    event FeeReward(uint indexed takeID, uint makeVol,uint takeVol);
    event RecommendReward(uint indexed takeID, uint vol);
    function payFee2(uint takeID,uint v1,uint v2) internal {
        uint ratio = config[_rewardRatioMaker_];
        uint v = v1.add(v2);
        if (takes[takeID].recommender!=address(0)){
            uint vRecommender = v.mul(ratio).div(2e18); //==maker vol   50%
            emit FeeReward(takeID,vRecommender,v.mul(uint(1e18).sub(ratio)).div(1e18));
            emit RecommendReward(takeID,vRecommender);
            //address rewardToken = address(config[_rewardToken_]);
            //IERC20(rewardToken).safeTransfer(takes[takeID].recommender,vRecommender);
            uint recommReward = getConfigA(_rewards_, takes[takeID].recommender);
            _setConfig(_rewards_, takes[takeID].recommender, recommReward.add(vRecommender));
            v1 = v;
            v2 = 0;
            _updateReward(makes[takes[takeID].makeID].maker, v1, v2, ratio.div(2));
            _updateReward(takes[takeID].taker, v1, v2, uint(1e18).sub(ratio)); 
        }else{
            emit FeeReward(takeID,v.mul(ratio).div(1e18),v.mul(uint(1e18).sub(ratio)).div(1e18));
            v1 = v;
            v2 = 0;
            _updateReward(makes[takes[takeID].makeID].maker, v1, v2, ratio);
            _updateReward(takes[takeID].taker, v1, v2, uint(1e18).sub(ratio)); 
        }
    }
     

    function _updateReward(address acct, uint v1, uint v2, uint ratio) internal {
        v1 = v1.mul(ratio).div(1e18);
        v2 = v2.mul(ratio).div(1e18);
        uint lkd = locked (acct);
        uint end = lockEnd(acct);
        end = end.sub0(now).mul(lkd).add(getConfig(_spanLock_).mul(v1)).div(lkd.add(v1)).add(now);
        _setConfig(_locked_ , acct, lkd.add(v1).mul(end).div(end.sub(now)));
        _setConfig(_lockEnd_, acct, end);
        _setConfig(_rewards_, acct, earned(acct).add(v1).add(v2));
    }

    function _swapToPairTokenA(address asset, uint fee) internal returns(IUniswapV2Router01 router, address tokenA, uint amt) {
        (router,tokenA,amt) = ArbitrateLib._swapToPairTokenA(config,asset,fee);
        /*router = IUniswapV2Router01(config[_swapRouter_]);
        tokenA = address(config[_pairTokenA_]);
        if(tokenA == asset)
            return (router, asset, fee);
        IERC20(asset).safeApprove_(address(router), fee);
        if(IUniswapV2Factory(config[_swapFactory_]).getPair(asset, tokenA) != address(0)) {
            address[] memory path = new address[](2);
            path[0] = asset;
            path[1] = tokenA;
            uint[] memory amounts = router.swapExactTokensForTokens(fee, 0, path, address(this), now);
            amt = amounts[1];
        } else {
            address[] memory path = new address[](3);
            path[0] = asset;
            path[1] = router.WETH();
            path[2] = tokenA;
            uint[] memory amounts = router.swapExactTokensForTokens(fee, 0, path, address(this), now);
            amt = amounts[2];
        }*/
    }
 
    // Reserved storage space to allow for layout changes in the future.
    uint256[41] private ______gap;
}


library ArbitrateLib {

    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    bytes32 internal constant _expiry_      = "expiry";
    //bytes32 internal constant _feeTo_       = "feeTo";
    bytes32 internal constant _feeToken_    = "feeToken";
    bytes32 internal constant _feeVolume_   = "feeVolume";
    bytes32 internal constant _feeRate_     = "feeRate";
    bytes32 internal constant _feeRatio1_   = "feeRatio1";
    bytes32 internal constant _feeBuf_      = "feeBuf";
    bytes32 internal constant _lastUpdateBuf_= "lastUpdateBuf";
    bytes32 internal constant _spanBuf_     = "spanBuf";
    bytes32 internal constant _spanLock_    = "spanLock";
    bytes32 internal constant _rewardOfSpan_= "rewardOfSpan"; 
    bytes32 internal constant _rewardRatioMaker_    = "rewardRatioMaker";
    bytes32 internal constant _rewardToken_ = "rewardToken";
    bytes32 internal constant _rewards_     = "rewards";
    bytes32 internal constant _locked_      = "locked";
    bytes32 internal constant _lockEnd_     = "lockEnd";
/*  bytes32 internal constant _rebaseTime_  = "rebaseTime";
    bytes32 internal constant _rebasePeriod_= "rebasePeriod";
    bytes32 internal constant _factorPrice20_   = "factorPrice20";
    bytes32 internal constant _lpTknMaxRatio_   = "lpTknMaxRatio";
    bytes32 internal constant _lpCurMaxRatio_   = "lpCurMaxRatio";*/
    bytes32 internal constant _vault_  = "vault";
    bytes32 internal constant _pairTokenA_  = "pairTokenA";
    bytes32 internal constant _swapFactory_ = "swapFactory";
    bytes32 internal constant _swapRouter_  = "swapRouter";
    bytes32 internal constant _mine_        = "mine";
    bytes32 internal constant _assetList_   = "assetList";
    bytes32 internal constant _assetFreeLimit_   = "assetFreeLimit";
    bytes32 internal constant _usd_   = "usd";
    bytes32 internal constant _bank_   = "bank";
    bytes32 internal constant _merchantPool_   = "merchantPool";
    bytes32 internal constant _tradingPool_   = "tradingPool";
    bytes32 internal constant _preDoneExpiry_   = "preDoneExpiry";//7days
    bytes32 internal constant _priceAndRate_  = "priceAndRate";
    bytes32 internal constant _babtoken_ = "babtoken";

    struct Tmpval{
        address buyer;
        address seller;
        uint  tradingMargin;  
    }

 

    function getRandArbiter(address[] storage arbiters,mapping (address => bool) storage isArbiter) public view returns(address randArbiter) {
        uint hash = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty,blockhash(block.number -1 - block.difficulty%100))));
        hash = hash%arbiters.length;
        uint cnt = 0;
        randArbiter=address(0);
        while(true){
            if (isArbiter[arbiters[hash]]){
                randArbiter = arbiters[hash];
                break;
            }
            hash = (hash+1)%arbiters.length;
            cnt++;
            if (cnt>=arbiters.length)
                break;
        }
    }

    function appeal(mapping (uint => SMake) storage makes,mapping(uint =>SMakeEx) storage makeExs,mapping (uint => STake) storage takes,mapping (bytes32 => uint) storage config,mapping(uint =>AppealInfo) storage appealInfos,uint takeID,address[] storage arbiters,mapping (address => bool) storage isArbiter) virtual external /*nonReentrant*/ {
       // DOTC dotc = DOTC(address(this));
        STake memory take = takes[takeID];
        require(take.taker != address(0), 'Nonexistent take order');
        if(take.status == Status.Paid) { //normal appeal or merchant appeal
            uint makeID = take.makeID;
            require(msg.sender == makes[makeID].maker || msg.sender == take.taker, 'only maker or taker');
            
            (, address seller) = makes[makeID].isBid ? (makes[makeID].maker, takes[takeID].taker) : (takes[takeID].taker, makes[makeID].maker);
            if(msg.sender != seller)
                require(take.expiry < now, 'only expired');
            IERC20(address(config[_feeToken_])).safeTransferFrom(msg.sender, address(config[_bank_]), config[_feeVolume_]); //tmp bank ,appeal 5PEX, arbitrate to vault or seller or buyer
            if (makeExs[makeID].tradingMargin == 0)
                takes[takeID].status = Status.Appeal;
            else
                takes[takeID].status = Status.MerchantAppeal;
            //appealAddress[takeID] = msg.sender; 
            appealInfos[takeID].takeID = takeID;
            appealInfos[takeID].appeal = msg.sender;
            appealInfos[takeID].arbiter = getRandArbiter(arbiters,isArbiter);
            appealInfos[takeID].isDeliver=false;


            emit Appeal(takeID, makeID, msg.sender, take.vol,appealInfos[takeID].arbiter);
        }
        else{//merchant appeal
            require(take.status == Status.Done, 'only Status.Done');
            uint makeID = take.makeID;
            require(msg.sender == makes[makeID].maker || msg.sender == take.taker, 'only maker or taker');
            
    //        (, address seller) = makes[makeID].isBid ? (makes[makeID].maker, takes[takeID].taker) : (takes[takeID].taker, makes[makeID].maker);
            require(makeExs[makeID].tradingMargin>0 && msg.sender==makes[makeID].maker,"must be merchat");
            require(now < take.expiry, 'only expired');
            IERC20(address(config[_feeToken_])).safeTransferFrom(msg.sender, address(config[_bank_]), config[_feeVolume_]); //tmp bank ,appeal 5PEX, arbitrate to vault or seller or buyer
            takes[takeID].status = Status.MerchantAppeal;
            //appealAddress[takeID] = msg.sender; 
            appealInfos[takeID].takeID = takeID;
            appealInfos[takeID].appeal = msg.sender;
            appealInfos[takeID].arbiter = getRandArbiter(arbiters,isArbiter);
            appealInfos[takeID].isDeliver=true;


            emit Appeal(takeID, makeID, msg.sender, take.vol,appealInfos[takeID].arbiter);
        }
    }
    event Appeal(uint indexed takeID, uint indexed makeID, address indexed sender, uint vol,address arbiter);

    function merchantOk(mapping (uint => SMake) storage makes,mapping(uint =>SMakeEx) storage makeExs,mapping (uint => STake) storage takes,mapping (bytes32 => uint) storage config,uint takeID) virtual external  {
        uint makeID = takes[takeID].makeID;
        require(makes[makeID].maker == msg.sender, 'must be maker');
        require(takes[takeID].status == Status.Done, 'only Status.Done');
        uint tradingMargin = makeExs[makeID].tradingMargin;
        require(tradingMargin>0,"only tradingMargin>0");
        require(now < takes[takeID].expiry,"now must < expiry");
        //takes[takeID].status = Status.MerchantOk;
        emit MerchantOk(takeID);
        takes[takeID].status = Status.ClaimTradingMargin; 
        ITradingStakePool(config[_tradingPool_]).withdraw(takes[takeID].taker,tradingMargin); 
        emit ClaimTradingMargin(takeID,tradingMargin);
    }
    event MerchantOk(uint takeID);


    struct DataTmp{   //stack too deep
        uint realPrice;
        uint priceType;
        uint price;
        uint8 decimals;
        uint rate;
    }
    function takeLib(mapping (uint => SMake) storage makes,mapping(uint =>SMakeEx) storage makeExs,mapping (uint => STake) storage takes,mapping (bytes32 => uint) storage config,mapping (address => uint) storage biddingN,TakePara memory takePara/*uint makeID, uint volume,string memory link,uint price,address recommender*/) virtual external returns (uint takeID, uint vol) {
        DOTC dotc = DOTC(address(this));
        //uint makeID, uint volume,string memory link,uint price,address recommender;
        uint makeID = takePara.makeID;
        require(makes[makeID].maker != address(0), 'Nonexistent make order');
        require(makes[makeID].remain > 0, 'make.remain should > 0');
        require(makes[makeID].minVol <= takePara.volume , 'volume must > minVol');
        require(makes[makeID].maxVol >= takePara.volume, 'volume must < maxVol');
        //require((makes[makeID].maker != takePara.recommender)&&(msg.sender != takePara.recommender), 'recommender must not maker or taker');
        if (makeExs[makeID].tradingMargin>0){//config[_tradingPool_]
            IERC20(address(config[_feeToken_])).safeTransferFrom(msg.sender, address(this), makeExs[makeID].tradingMargin);
            if(IERC20(address(config[_feeToken_])).allowance(address(this),address(config[_tradingPool_]))<makeExs[makeID].tradingMargin)
                IERC20(address(config[_feeToken_])).approve(address(config[_tradingPool_]),uint(-1));
            ITradingStakePool(address(config[_tradingPool_])).stake(msg.sender,makeExs[makeID].tradingMargin);
        }else if (takePara.volume > dotc.getConfigA(_assetFreeLimit_,makes[makeID].asset) && ISBT721(address(config[_babtoken_])).balanceOf(msg.sender) == 0)
            require(IStaking(dotc.staking()).enough(msg.sender),"GT Limit,must stake");
        vol = takePara.volume;
        if(vol > makes[makeID].remain)
            vol = makes[makeID].remain;
        if(!makes[makeID].isBid) {
            //require(staking == address(0) || IStaking(staking).enough(msg.sender));
            biddingN[msg.sender]++;
        } else
            IERC20(makes[makeID].asset).safeTransferFrom(msg.sender, address(this), vol);
        

        makes[makeID].remain = makes[makeID].remain.sub(vol);
        makes[makeID].pending = makes[makeID].pending.add(vol);
        
        DataTmp memory dataTmp;
        dataTmp.priceType = makeExs[makeID].priceType;
        if(dataTmp.priceType!=0){
            (dataTmp.price,dataTmp.decimals,dataTmp.rate) = IPriceAndRate(address(config[_priceAndRate_])).getPriceAndRate(makes[makeID].asset,makes[makeID].currency);
            require(dataTmp.price>0,"No the asset");
            require(dataTmp.rate>0,"No the currency");
            if (dataTmp.priceType ==1){
                if (makeExs[makeID].floatVal>=0)
                    dataTmp.realPrice = dataTmp.price.mul(dataTmp.rate).div(uint128(10)**(dataTmp.decimals)).add(uint(makeExs[makeID].floatVal));//1170e18 *6.71e18
                else
                    dataTmp.realPrice = dataTmp.price.mul(dataTmp.rate).div(uint128(10)**(dataTmp.decimals)).sub(uint(0-makeExs[makeID].floatVal));//1170e18 *6.71e18
            }
            else if(dataTmp.priceType ==2){
                if (makeExs[makeID].floatVal>=0)
                    dataTmp.realPrice = dataTmp.price.mul(dataTmp.rate).div(uint128(10)**(dataTmp.decimals)).mul(uint(1e18).add(uint(makeExs[makeID].floatVal))).div(1e18);//
                else
                    dataTmp.realPrice = dataTmp.price.mul(dataTmp.rate).div(uint128(10)**(dataTmp.decimals)).mul(uint(1e18).sub(uint(0-makeExs[makeID].floatVal))).div(1e18);//
            }
            uint diff = dataTmp.realPrice>takePara.price? dataTmp.realPrice-takePara.price:takePara.price-dataTmp.realPrice;
            require(diff.mul(1000)<dataTmp.realPrice.mul(5),"price not match chainlink");
            dataTmp.realPrice = takePara.price;
        }else{
            dataTmp.realPrice  = makes[makeID].price;
        }
        takeID = dotc.takesN();
        takes[takeID] = STake(makeID, msg.sender, vol, Status.None, now.add(config[_expiry_]),takePara.link,dataTmp.realPrice,takePara.recommender);
        //takesN++;
        emit Take(takeID, makeID, msg.sender, vol, takes[takeID].expiry,takePara.link,dataTmp.realPrice,takePara.recommender);
    }
    event Take(uint indexed takeID, uint indexed makeID, address indexed taker, uint vol, uint expiry,string link,uint realPrice,address recommender);


    function claimTradingMargin(mapping (uint => SMake) storage makes,mapping(uint =>SMakeEx) storage makeExs,mapping (uint => STake) storage takes,mapping (bytes32 => uint) storage config,uint takeID) virtual external {
        makes;
        require(takes[takeID].taker == msg.sender, 'must be taker');
        uint tradingMargin = makeExs[takes[takeID].makeID].tradingMargin;
        require(takes[takeID].status == Status.MerchantOk ||((takes[takeID].status == Status.Done)&&(now>takes[takeID].expiry)&&tradingMargin>0),"No claimTradingMargin");
        takes[takeID].status = Status.ClaimTradingMargin; 
        ITradingStakePool(config[_tradingPool_]).withdraw(msg.sender,tradingMargin); 
        emit ClaimTradingMargin(takeID,tradingMargin);
    }
    event ClaimTradingMargin(uint takeID,uint tradingMargin);


   
    function arbitrate(mapping (uint => SMake) storage makes,mapping(uint =>SMakeEx) storage makeExs,mapping (uint => STake) storage takes,mapping (bytes32 => uint) storage config,mapping(uint =>AppealInfo) storage ais, mapping (address => uint) storage biddingN,ArbiterPara memory ap/*uint takeID, Status winner,Status assetTo,Status appealFeeTo,Status punishSide,uint punishVol*/) virtual external /*nonReentrant*/ returns(uint vol) {
        DOTC dotc = DOTC(address(this));
        uint takeID = ap.takeID;
        STake memory take = takes[takeID];
        uint makeID = take.makeID;
        SMake memory make = makes[makeID];
        require(take.taker != address(0), 'Nonexistent take order');
        require(take.status == Status.Appeal||take.status == Status.MerchantAppeal, 'only Status.Appeal or Status.MerchantAppeal');
        require(dotc.isArbiter(msg.sender), 'only arbiter');
        require(ais[takeID].arbiter == msg.sender, 'only the arbiter');
        require(ap.winner != ap.punishSide,"Can't punish winner");
        ais[takeID].winner = ap.winner;
        ais[takeID].appealFeeTo = ap.appealFeeTo;
        ais[takeID].punishSide = ap.punishSide;
        ais[takeID].punishVol = ap.punishVol;
        ais[takeID].punishTo = ap.punishTo;
        
        Tmpval memory tmpval;   //deep stack
        {
        (tmpval.buyer, tmpval.seller) = make.isBid ? (make.maker, take.taker) : (take.taker, make.maker);
        tmpval.tradingMargin = makeExs[makeID].tradingMargin;
        }
        if (take.status == Status.Appeal){
            
            vol = take.vol;
            if( ap.winner == Status.Buyer) {
                uint fee = dotc.payFee(takeID, make.asset, vol);
                IERC20(make.asset).safeTransfer(tmpval.buyer, vol.sub(fee));
                emit Deal(takeID,make.asset,vol);
            } else if( ap.winner == Status.Seller) {
                IERC20(make.asset).safeTransfer(tmpval.seller, vol);
                //if(dotc.staking().isContract())
                //    IStaking(dotc.staking()).punish(buyer);
            } else
                revert('status should be Buyer or Seller');
            
            //appeal fee 5PEX to:
            { 
                //address appealFeeToAddr;
                if  (ap.appealFeeTo == Status.Buyer)
                    IERC20(address(config[_feeToken_])).safeTransferFrom(address(config[_bank_]),tmpval.buyer,config[_feeVolume_]); // bank ,appeal 5PEX, arbitrate to vault or seller or buyer
                else if  (ap.appealFeeTo == Status.Seller)
                    IERC20(address(config[_feeToken_])).safeTransferFrom(address(config[_bank_]),tmpval.seller,config[_feeVolume_]); // bank ,appeal 5PEX, arbitrate to vault or seller or buyer
                else if (ap.appealFeeTo == Status.Vault)
                    IERC20(address(config[_feeToken_])).safeTransferFrom(address(config[_bank_]),address(config[_vault_]),config[_feeVolume_]); // bank ,appeal 5PEX, arbitrate to vault or seller or buyer
            }

            if(dotc.staking().isContract()){   //punish PEX
                if (ap.punishSide == Status.Buyer)
                    IStaking(dotc.staking()).punish(tmpval.buyer,ap.punishVol);
                else if (ap.punishSide == Status.Seller)
                    IStaking(dotc.staking()).punish(tmpval.seller,ap.punishVol);
            }

 
              
            makes[makeID].pending = makes[makeID].pending.sub(vol);
            takes[takeID].status =  ap.winner;

            if ((!makes[makeID].isBid) || (makes[makeID].remain==0 && makes[makeID].pending == 0))
                biddingN[tmpval.buyer] = biddingN[tmpval.buyer].sub(1);

            emit Arbitrate1(takeID, makeID, msg.sender, vol, ap.winner, ap/*ap.winner,ap.appealFeeTo,ap.punishSide,ap.punishVol*/);
            
        }
        else{
            if (!ais[takeID].isDeliver){
                vol = take.vol;
                if( ap.winner == Status.Buyer) {
                    uint fee = dotc.payFee(takeID, make.asset, vol);
                    IERC20(make.asset).safeTransfer(tmpval.buyer, vol.sub(fee));
                    emit Deal(takeID,make.asset,vol);
                } else if( ap.winner == Status.Seller) {
                    IERC20(make.asset).safeTransfer(tmpval.seller, vol);
                    //if(dotc.staking().isContract())
                    //    IStaking(dotc.staking()).punish(buyer);
                } else
                    revert('status should be Buyer or Seller');
            }


            //appeal fee 5PEX to:
            { 
                //address appealFeeToAddr;
                if  (ap.appealFeeTo == Status.Buyer)
                    IERC20(address(config[_feeToken_])).safeTransferFrom(address(config[_bank_]),tmpval.buyer,config[_feeVolume_]); // bank ,appeal 5PEX, arbitrate to vault or seller or buyer
                else if  (ap.appealFeeTo == Status.Seller)
                    IERC20(address(config[_feeToken_])).safeTransferFrom(address(config[_bank_]),tmpval.seller,config[_feeVolume_]); // bank ,appeal 5PEX, arbitrate to vault or seller or buyer
                else if (ap.appealFeeTo == Status.Vault)
                    IERC20(address(config[_feeToken_])).safeTransferFrom(address(config[_bank_]),address(config[_vault_]),config[_feeVolume_]); // bank ,appeal 5PEX, arbitrate to vault or seller or buyer
            }
            address punishTo;
            if (ap.punishTo == Status.Buyer)
                punishTo = tmpval.buyer;
            else if (ap.punishTo == Status.Seller)
                punishTo = tmpval.seller;
            else 
                punishTo = address(config[_vault_]);

            if (ap.punishSide == Status.Buyer){
                if (make.maker == tmpval.buyer)   
                      IMerchantStakePool(config[_merchantPool_]).punish(tmpval.buyer,punishTo,ap.punishVol);
                else{
                      ITradingStakePool(config[_tradingPool_]).punish(tmpval.buyer,punishTo,ap.punishVol);
                      ITradingStakePool(config[_tradingPool_]).withdraw(tmpval.buyer,tmpval.tradingMargin.sub(ap.punishVol));
                }
            }
            else if (ap.punishSide == Status.Seller){
                if (make.maker == tmpval.seller)
                      IMerchantStakePool(config[_merchantPool_]).punish(tmpval.seller,punishTo,ap.punishVol);
                else{
                      ITradingStakePool(config[_tradingPool_]).punish(tmpval.seller,punishTo,ap.punishVol);
                      ITradingStakePool(config[_tradingPool_]).withdraw(tmpval.seller,tmpval.tradingMargin.sub(ap.punishVol));
                }
            }
            takes[takeID].status =  Status.MerchantAppealDone;
            emit Arbitrate1(takeID, makeID, msg.sender, vol, ap.winner, ap/*ap.winner,ap.appealFeeTo,ap.punishSide,ap.punishVol*/);

        }
   }
    event Arbitrate1(uint indexed takeID, uint indexed makeID, address indexed arbiter, uint vol,Status winner,ArbiterPara arbiterPara/* Status status,Status appealFeeTo,Status punishSide,uint punishVol*/);
    event Deal(uint indexed takeID, address indexed asset, uint vol);

    function _swapToPairTokenA(mapping (bytes32 => uint) storage config,address asset, uint fee) internal returns(IUniswapV2Router01 router, address tokenA, uint amt) {
        router = IUniswapV2Router01(config[_swapRouter_]);
        tokenA = address(config[_pairTokenA_]);
        if(tokenA == asset)
            return (router, asset, fee);
        IERC20(asset).safeApprove_(address(router), fee);
        if(IUniswapV2Factory(config[_swapFactory_]).getPair(asset, tokenA) != address(0)) {
            address[] memory path = new address[](2);
            path[0] = asset;
            path[1] = tokenA;
            uint[] memory amounts = router.swapExactTokensForTokens(fee, 0, path, address(this), now);
            amt = amounts[1];
        } else {
            address[] memory path = new address[](3);
            path[0] = asset;
            path[1] = router.WETH();
            path[2] = tokenA;
            uint[] memory amounts = router.swapExactTokensForTokens(fee, 0, path, address(this), now);
            amt = amounts[2];
        }
    }

    function price(mapping (bytes32 => uint) storage config) public view returns(uint p1, uint p2) {
        DOTC dotc = DOTC(address(this));
        (p1,p2) = dotc.priceEth();
        address tokenA = address(config[_pairTokenA_]);
        address usd = address(config[_usd_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA,usd);
        uint volA = IERC20(tokenA).balanceOf(pair);
        uint volU = IERC20(usd).balanceOf(pair);
        p1 = p1.mul(volU).div(volA);
        p2 = p2.mul(volU).div(volA);
    }

    function priceEth(mapping (bytes32 => uint) storage config) public view returns(uint p1, uint p2) {
        DOTC dotc = DOTC(address(this));
        p1 = dotc.price1();
        
        address tokenA = address(config[_pairTokenA_]);
        address tokenR = address(config[_rewardToken_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA, tokenR);
        if(pair == address(0) || IERC20(tokenA).balanceOf(pair) == 0)
            p2 = 0;
        else
            p2 = IERC20(tokenA).balanceOf(pair).mul(1e18).div(IERC20(tokenR).balanceOf(pair));
    }



}

interface IPriceAndRate {
    function getPriceAndRate(address token,bytes32 currency) external view returns (uint price,uint8 decimals,uint rate);
}

interface ISBT721 {
    function balanceOf(address owner) external view returns (uint256);
}

interface IStaking {
    function enough(address buyer) external view returns(bool);
    function punish(address buyer,uint vol) external;
}

interface IMerchantStakePool{
    function isMerchant(address account) external view returns(bool);
    function punish(address from,address to, uint vol)  external;
}

interface ITradingStakePool{
    function punish(address from,address to, uint vol)  external ;
    function stake(address account,uint amount)  external;
    function withdraw(address account,uint amount)  external ;
}


interface IVault {
    function rebase() external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router01 {
    //function factory() external pure returns (address);
    function WETH() external pure returns (address);
    //function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
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
}