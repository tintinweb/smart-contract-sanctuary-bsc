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
}

enum Status { None, Paid, Cancel, Done, Appeal, Buyer, Seller }

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

    address public staking;
    address[] public arbiters;
    mapping (address => bool) public    isArbiter;
    mapping (address => uint) public    biddingN;
   
    mapping (uint => SMake) public makes;
    mapping (uint => STake) public takes;
    uint public makesN;
    uint public takesN;
    
    mapping(uint =>address) public appealAddress; //takeID=> appeal address
    mapping(uint =>bool) public makePrivate; //makeID=> public or private;

    uint private _entered;
    modifier nonReentrant {
        require(_entered == 0, "reentrant");
        _entered = 1;
        _;
        _entered = 0;
    }

    function __DOTC_init(address governor_, address staking_,address feeTo_, address feeToken_,uint feeVolume_) public initializer {
        __Governable_init_unchained(governor_);
        __DOTC_init_unchained(staking_,feeTo_,feeToken_,feeVolume_);
    }

    function __DOTC_init_unchained(address staking_,address vault_, address feeToken_,uint feeVolume_) public governance {
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


    function migrate(address vault_) external governance {
        config[_vault_] = uint(vault_);
        __DOTC_init_reward2();
    }	

    function setBiddingN_(address account,uint biddingN_) external governance {
        biddingN[account] = biddingN_;
    }

    function setArbiters_(address[] calldata arbiters_) external governance {
        for(uint i=0; i<arbiters.length; i++)
            isArbiter[arbiters[i]] = false;
            
        arbiters = arbiters_;
        
        for(uint i=0; i<arbiters.length; i++)
            isArbiter[arbiters[i]] = true;
            
        emit SetArbiters(arbiters_);
    }
    event SetArbiters(address[] arbiters_);

    function make(SMake memory make_,bool isPrivate) virtual external nonReentrant returns(uint makeID) { 
        require(make_.volume > 0, 'volume should > 0');
        require(make_.minVol <= make_.maxVol , 'minVol must <= maxVol');
        require(make_.maxVol <= make_.volume, 'maxVol must <= volume');
        //if (make_.volume > getConfigA(_assetFreeLimit_,make_.asset))
        require(IStaking(staking).enough(msg.sender),"make ad,must stake");
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
        makePrivate[makeID] = isPrivate; 
        makesN++;
        emit Make(makeID, msg.sender, make_.isBid, make_.asset, make_,isPrivate);
    }
    event Make(uint indexed makeID, address indexed maker, bool isBid, address indexed asset, SMake smake,bool isPrivate);

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
        bool makePri = makePrivate[makeID];
        newMakeID = makesN;
        SMake memory  newMake;
        newMake = makes[makeID];
        newMake.volume = vol;
        newMake.price = newPrice;
        newMake.pending = 0;
        newMake.remain = vol;
        makes[newMakeID] =newMake; 
        makePrivate[newMakeID] = makePri;
        makesN++;
        makes[makeID].remain = 0;
        if (makes[makeID].isBid && makes[makeID].pending > 0){
            biddingN[msg.sender] = biddingN[msg.sender].add(1);
        }
        emit CancelMake(makeID, msg.sender, makes[makeID].asset, vol);
        emit Make(newMakeID, msg.sender, makes[newMakeID].isBid, makes[newMakeID].asset, makes[newMakeID], makePri);
        emit Reprice(makeID, newMakeID, msg.sender, newMake,makePri);

    }
    event Reprice(uint indexed makeID, uint indexed newMakeID, address indexed maker, SMake smake,bool makePri);

 
    function take(uint makeID, uint volume,string memory link) virtual external nonReentrant returns (uint takeID, uint vol) {
        require(makes[makeID].maker != address(0), 'Nonexistent make order');
        require(makes[makeID].remain > 0, 'make.remain should > 0');
        require(makes[makeID].minVol <= volume , 'volume must > minVol');
        require(makes[makeID].maxVol >= volume, 'volume must < maxVol');

        if (volume > getConfigA(_assetFreeLimit_,makes[makeID].asset))
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
        
        takeID = takesN;
        takes[takeID] = STake(makeID, msg.sender, vol, Status.None, now.add(config[_expiry_]),link);
        takesN++;
        emit Take(takeID, makeID, msg.sender, vol, takes[takeID].expiry,link);
    }
    event Take(uint indexed takeID, uint indexed makeID, address indexed taker, uint vol, uint expiry,string link);

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

        if ((!makes[makeID].isBid) || (makes[makeID].remain==0 && makes[makeID].pending == 0))
            biddingN[buyer] = biddingN[buyer].sub(1);

        emit Deliver(takeID, makeID, seller, vol);
        emit Deal(takeID,makes[makeID].asset,vol);
    }
    event Deliver(uint indexed takeID, uint indexed makeID, address indexed seller, uint vol);
    event Deal(uint indexed takeID, address indexed asset, uint vol);

    function appeal(uint takeID) virtual external nonReentrant {
        require(takes[takeID].taker != address(0), 'Nonexistent take order');
        require(takes[takeID].status == Status.Paid, 'only Status.Paid');
        uint makeID = takes[takeID].makeID;
        require(msg.sender == makes[makeID].maker || msg.sender == takes[takeID].taker, 'only maker or taker');
        require(takes[takeID].expiry < now, 'only expired');
        IERC20(address(config[_feeToken_])).safeTransferFrom(msg.sender, address(config[_vault_]), config[_feeVolume_]);
        takes[takeID].status = Status.Appeal;
        appealAddress[takeID] = msg.sender; 
        emit Appeal(takeID, makeID, msg.sender, takes[takeID].vol);
    }
    event Appeal(uint indexed takeID, uint indexed makeID, address indexed sender, uint vol);

    function arbitrate(uint takeID, Status status) virtual external nonReentrant returns(uint vol) {
        require(takes[takeID].taker != address(0), 'Nonexistent take order');
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

        emit Arbitrate(takeID, makeID, msg.sender, vol, status);
   }
    event Arbitrate(uint indexed takeID, uint indexed makeID, address indexed arbiter, uint vol, Status status);

    function _feeBuf() internal view returns(uint) {
        uint spanBuf = config[_spanBuf_];
        return spanBuf.sub0(now.sub(config[_lastUpdateBuf_])).mul(config[_feeBuf_]).div(spanBuf);
    }
    
    function price1() public view returns(uint) {
        return _feeBuf().mul(1e18).div0(config[_rewardOfSpan_]);
    }
    
    function price() public view returns(uint p1, uint p2) {
        (p1,p2) = priceEth();
        address tokenA = address(config[_pairTokenA_]);
        address usd = address(config[_usd_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA,usd);
        uint volA = IERC20(tokenA).balanceOf(pair);
        uint volU = IERC20(usd).balanceOf(pair);
        p1 = p1.mul(volU).div(volA);
        p2 = p2.mul(volU).div(volA);
    }

    function priceEth() public view returns(uint p1, uint p2) {
        p1 = price1();
        
        address tokenA = address(config[_pairTokenA_]);
        address tokenR = address(config[_rewardToken_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA, tokenR);
        if(pair == address(0) || IERC20(tokenA).balanceOf(pair) == 0)
            p2 = 0;
        else
            p2 = IERC20(tokenA).balanceOf(pair).mul(1e18).div(IERC20(tokenR).balanceOf(pair));
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

    function claimable(address acct) public view returns (uint) {
        return earned(acct).sub(locked(acct));
    }

    function claim() external {
        claimFor(msg.sender);
    }

    function claimFor(address acct) public nonReentrant {
        IERC20(config[_rewardToken_]).safeTransfer(acct, claimable(acct));
        _setConfig(_rewards_, acct, locked(acct));
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

    function payFee2(uint takeID,uint v1,uint v2) internal {
        uint ratio = config[_rewardRatioMaker_];
        uint v = v1.add(v2);
        emit FeeReward(takeID,v.mul(ratio).div(1e18),v.mul(uint(1e18).sub(ratio)).div(1e18));
        v1 = v;
        v2 = 0;
        _updateReward(makes[takes[takeID].makeID].maker, v1, v2, ratio);
        _updateReward(takes[takeID].taker, v1, v2, uint(1e18).sub(ratio)); 
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
    
 /*   function _rebase() internal {
        uint time = config[_rebaseTime_];
        if(now < time)
            return;
        uint period = config[_rebasePeriod_];
        config[_rebaseTime_] = time.add(period);
        _adjustLiquidity();
    }

    function _adjustLiquidity() internal {
        uint curBal = 0;
        uint tknBal = 0;
        address tokenA = address(config[_pairTokenA_]);
        address rewardToken = address(config[_rewardToken_]);
        address pair = IUniswapV2Factory(config[_swapFactory_]).getPair(tokenA, rewardToken);
        if(pair != address(0)) {
            curBal = IERC20(tokenA).balanceOf(pair);
            tknBal = IERC20(rewardToken).balanceOf(pair);
        }
        uint curTgt = IERC20(tokenA).balanceOf(address(this)).add(curBal).mul(config[_lpCurMaxRatio_]).div(1e18);
        uint tknR = config[_lpTknMaxRatio_];
        uint tknTgt = IERC20(rewardToken).totalSupply().sub(tknBal).mul(tknR).div(uint(1e18).sub(tknR));
        if(curBal == 0)
            curTgt = tknTgt.mul(_price1()).div(1e18).mul(config[_factorPrice20_]).div(1e18);
        if(curTgt > curBal && tknTgt > tknBal){ 
		    uint needTkn = tknBal.mul(curTgt).div(curBal).sub(tknBal);
		    if (needTkn>(tknTgt - tknBal))
		       needTkn = (tknTgt - tknBal);
            _addLiquidity(curTgt - curBal, needTkn);
		}
    }

    function _addLiquidity(uint value, uint amount) internal {
        address rewardToken = address(config[_rewardToken_]);
        IERC20(rewardToken).safeTransferFrom(address(config[_mine_]), address(this), amount);
        address tokenA = address(config[_pairTokenA_]);
        IUniswapV2Router01 router = IUniswapV2Router01(config[_swapRouter_]);
        IERC20(tokenA).safeApprove_(address(router), value);
        IERC20(rewardToken).approve(address(router), amount);
        router.addLiquidity(tokenA, rewardToken, value, amount, 0, 0, address(this), now);
    }*/

    // Reserved storage space to allow for layout changes in the future.
    uint256[41] private ______gap;
}

interface IStaking {
    function enough(address buyer) external view returns(bool);
    function punish(address buyer) external;
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