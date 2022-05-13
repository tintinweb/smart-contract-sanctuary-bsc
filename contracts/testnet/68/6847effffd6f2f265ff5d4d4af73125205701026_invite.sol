//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./library.sol";
import "./owner.sol";

contract invite  is Ownable{
    using Rank for Rank.RankObj; 
    using Rank for Rank.rankData; 
    using Rank for Rank.rankChange; 
    
    using Earnings for Earnings.Earning;
    using SafeMath for uint256;
    using TransferHelper for address;
    
    uint256 public batchindex=0;
    //质押合约    
    address public addressPledge;
    address public addressUsdt = 0xEDda29De6B3f43f9A5e0a30e0E74991AD826F7A6;
    address public addressERC20 = 0x089460Ddb084DE5D7e7483417719C6bA10a2B77b;

    //address public usdt = 0xEDda29De6B3f43f9A5e0a30e0E74991AD826F7A6;
    //address public token = 0x089460Ddb084DE5D7e7483417719C6bA10a2B77b;

   // address public addressErc721_c;
    
    struct inviteData  {
         bool init;
        //待分发的U
        uint256  OddAllotUsdt;
        //待分发的token
        uint256  OddAllotErc20;
        //有效邀请数
        mapping(address => uint256)  inviteNumber;
        //对应地址所有的邀请记录
        mapping(address => mapping(address => bool))  inviteList;
        //邀请反向关系 
        mapping(address => address) beInvited;
        //已质押过的地址
        mapping(address => bool) pledgedAddress;
        //排行数据
        Rank.RankObj rankData;
        //U的收益
        //  Earnings.Earning  earningUsdt;
        //token的收益
        //   Earnings.Earning  earningErc20;
    }

    struct EarningInfo{
       //待领取
        uint wait;
        //已领取
        uint finish;
    }

    struct EarningG {
        //   //U的收益
        mapping(uint256=> Earnings.Earning) earningUsdt;
        mapping(uint256=> Earnings.Earning) earningErc20;
       // Earnings.Earning[]  earningUsdts;
        //token的收益
       // Earnings.Earning[]  earningErc20s;
        //地址对应的总收益 USDT
        mapping(address=>EarningInfo) addressEarningU;
        //地址对应的总收益 Token
        mapping(address=>EarningInfo) addressEarningT;

        //已被领取的总的Usdt
        uint totalDrawU;
        //已被领取的总的token
        uint totalDrawT;

        mapping(address=>uint) allotterBatchindex;
    }
    //收益
    EarningG  globalEarning;

    //邀请数据
    mapping(uint256=> inviteData)  _inviteData;
    //待领取的U
    mapping(address => uint256) public waitReceiveUsdt;
    //待领取的币
    mapping(address => uint256) public waitReceiveErc20;
    //已领取的U
    mapping(address => uint256) public receivedUsdt;
    //已领取的币
    mapping(address => uint256) public receivedErc20;    
   
    event SetInvite(uint,address,address);
    event SetValidInvite(uint,address,address);

    //分发奖励
    event Award(uint,address,uint256,uint8);
    constructor () {
         _restart(0);
         addressPledge = msg.sender;
    }

    function getWeight(uint rank) internal  pure returns(uint8){
        if (rank >= 1 && rank <=50){
            return 2;
        } 
        if (rank >= 51 && rank <=150){
            return 1;
        }
        return 0;
    }

    //查询指定用户的有效邀请人数
    function getInviteNumber(uint256 _bathch,address _address)  public view returns(uint){
        return _inviteData[_bathch].inviteNumber[_address];
    }
    //查询指定用户是否有效的被邀请人以及被邀请人的对应的邀请人
    function getInviteIsValid(uint256 _bathch,address _address)  public view returns(bool,bool,address){
        address _inviteAdd =  _inviteData[_bathch].beInvited[_address];
        if (_inviteAdd == address(0)){
            return (_inviteData[_bathch].pledgedAddress[_address],false,address(0));
            //_inviteData[batchindex].pledgedAddress[_address]
        }
        return (_inviteData[_bathch].pledgedAddress[_address],
            _inviteData[_bathch].inviteList[_inviteAdd][_address],
            _inviteAdd);
    }

    //查询未分发的Usdt与 币
    function getOddNumber(uint256 _bathch) public view returns(uint,uint){
        return (_inviteData[_bathch].OddAllotUsdt,_inviteData[_bathch].OddAllotErc20);
    }
    //查询 排名数据
    function getRank(uint256 _bathch) public view returns(Rank.rankData[] memory) {
        return   _inviteData[_bathch].rankData._entries;
    }
    //查询 排名数据
    function getRanking(uint256 _bathch,address _address) public view returns(uint) {    
        return _inviteData[_bathch].rankData._indexes[_address]; 
    }
    //设置质压合约 
    function setAddPledge(address _address) public onlyOwner{
        addressPledge = _address;
    }
    function setAddUsdt(address _address) public onlyOwner {
        addressUsdt = _address;
    }
    function setAddErc20(address _address) public onlyOwner {
        addressERC20 = _address;
    }
    /*
    function setAddressErc721_C(address _address) public onlyOwner{
        addressErc721_c =_address;
    }
    */
     /**
     * @dev 建立新的邀请关系   被邀请者调用 
     * @param _address  邀请地址.
     */
    function inviteNew(address _address) public{
        //已质押过，不能再新建
        require(!_inviteData[batchindex].pledgedAddress[msg.sender],"pledged");
        require(_inviteData[batchindex].beInvited[msg.sender] == address(0),"exists");

        _inviteData[batchindex].beInvited[msg.sender] = _address;
          //初始都是无效用户
        _inviteData[batchindex].inviteList[_address][msg.sender] = false;
        emit SetInvite(batchindex,_address,msg.sender);
    }
     /**
     * @dev 设置有效邀请(质押过)  
     */
    function setValidInvite(address _address) public {
        require(addressPledge == msg.sender,"pledge address");
        //已质压过
        _inviteData[batchindex].pledgedAddress[_address] = true;
        address _AddBeInvited =_inviteData[batchindex].beInvited[_address];
        //require(_AddBeInvited != address(0),"AddBeInvited is empty");
        //AddBeInvited is empty
        if (_AddBeInvited == address(0)){
            return;
        }
        //Has been activated
        if ( _inviteData[batchindex].inviteList[_AddBeInvited][_address]){
            return;
        } 
        //_inviteData[_bathch].pledgedAddress[_address]
        _inviteData[batchindex].inviteList[_AddBeInvited][_address] = true;
        _inviteData[batchindex].inviteNumber[_AddBeInvited] ++;    
        
        emit SetValidInvite(batchindex,_AddBeInvited,_address);
        //计算排序 //bool isfull
        (Rank.rankChange[] memory changes, ) = _inviteData[batchindex].rankData.updateRank(_AddBeInvited,_inviteData[batchindex].inviteNumber[_AddBeInvited]);

        return;
        //recordPool
        bool recordPool = false; 
        for (uint i = 0;i< changes.length;i++){ 
            uint8 newWeight = getWeight(changes[i]._new);
            uint8 oldWeight = getWeight(changes[i]._old); 
            if (oldWeight != newWeight) {
                if (!recordPool){ 
                   // uint _balances = IERC20(data.token).balanceOf(address(this)); 
                    globalEarning.earningUsdt[batchindex].recordPool(IERC20(addressUsdt).balanceOf(address(this)));
                    globalEarning.earningErc20[batchindex].recordPool(IERC20(addressERC20).balanceOf(address(this)));
                   // _inviteData[batchindex].earningUsdt.recordPool();//IERC20(addressUsdt).balanceOf(address(this)));
                   // _inviteData[batchindex].earningErc20.recordPool();//IERC20(addressERC20).balanceOf(address(this)));
                    recordPool = true;
                }
               // _inviteData[batchindex].earningUsdt.allotter(changes[i]._address,oldWeight,newWeight); 
                uint  waitU = globalEarning.earningUsdt[batchindex].allotter(changes[i]._address,oldWeight,newWeight); 
                globalEarning.addressEarningU[changes[i]._address].wait.add(waitU);

                uint  waitT = globalEarning.earningErc20[batchindex].allotter(changes[i]._address,oldWeight,newWeight);
                globalEarning.addressEarningT[changes[i]._address].wait.add(waitT);

                //增加结算上一个批次的方法 
                //新加
                //是一个批次未结清
                if (globalEarning.allotterBatchindex[changes[i]._address]  != batchindex){
                    waitU =  globalEarning.earningUsdt[globalEarning.allotterBatchindex[changes[i]._address]]
                        .Settlement(changes[i]._address); 
                    globalEarning.addressEarningU[changes[i]._address].wait.add(waitU);

                    waitT = globalEarning.earningErc20[globalEarning.allotterBatchindex[changes[i]._address]]
                        .Settlement(changes[i]._address); 
                    globalEarning.addressEarningT[changes[i]._address].wait.add(waitT);   
                    globalEarning.allotterBatchindex[changes[i]._address] = batchindex;
                }else{
                    if (oldWeight == 0){    
                        globalEarning.allotterBatchindex[changes[i]._address] = batchindex;     
                    }
                }
            }
        }
        if (recordPool){
          //  _inviteData[batchindex].earningUsdt.finish();
            globalEarning.earningUsdt[batchindex].finish();
            globalEarning.earningErc20[batchindex].finish();
        }
    }
    
    //用户领取自己的收益
    function earnings() public{
        //先计算
        if (globalEarning.allotterBatchindex[msg.sender] != batchindex ) {
            globalEarning.earningUsdt[globalEarning.allotterBatchindex[msg.sender]].Settlement(msg.sender);
            globalEarning.earningErc20[globalEarning.allotterBatchindex[msg.sender]].Settlement(msg.sender);
            globalEarning.allotterBatchindex[msg.sender] = batchindex;
        }else{
            globalEarning.earningUsdt[batchindex].recordPool(IERC20(addressUsdt).balanceOf(address(this)));
            globalEarning.earningUsdt[batchindex].allotterDraw(msg.sender);
            globalEarning.earningUsdt[batchindex].finish();

            globalEarning.earningUsdt[batchindex].recordPool(IERC20(addressERC20).balanceOf(address(this)));
            globalEarning.earningUsdt[batchindex].allotterDraw(msg.sender);
            globalEarning.earningUsdt[batchindex].finish();
        }

        addressUsdt.safeTransfer(msg.sender,  globalEarning.addressEarningU[msg.sender].wait);
        addressERC20.safeTransfer(msg.sender,  globalEarning.addressEarningT[msg.sender].wait);

        globalEarning.addressEarningU[msg.sender].finish.add(globalEarning.addressEarningU[msg.sender].wait);
        globalEarning.addressEarningT[msg.sender].finish.add(globalEarning.addressEarningT[msg.sender].wait);

        globalEarning.addressEarningU[msg.sender].wait = 0;
        globalEarning.addressEarningT[msg.sender].wait = 0;
    }
   
    /**
     * @dev 回收
    */
    function withdraw() public  {
      addressUsdt.safeTransfer(msg.sender,waitReceiveUsdt[msg.sender]);
      addressERC20.safeTransfer(msg.sender,waitReceiveErc20[msg.sender]);

      receivedUsdt[msg.sender] +=  waitReceiveUsdt[msg.sender];
      receivedErc20[msg.sender] += waitReceiveErc20[msg.sender];
      waitReceiveUsdt[msg.sender] = 0;
      waitReceiveErc20[msg.sender] = 0;
    }
    function _restart(uint256 _batchindex) internal  {
        require(!_inviteData[_batchindex].init,"Reset completed");
        //_inviteData[batchindex].a  indexEnd = _inviteData[batchindex].index;
        globalEarning.earningUsdt[_batchindex].indexEnd = globalEarning.earningUsdt[_batchindex].index;
        globalEarning.earningErc20[_batchindex].indexEnd = globalEarning.earningErc20[_batchindex].index;
      
        batchindex = _batchindex;
        inviteData storage newInvite = _inviteData[batchindex];
        newInvite.OddAllotUsdt= 0;
        newInvite.OddAllotErc20 = 0;
        newInvite.init = true;
    }

    /**
     * @dev 重置
    */
    function restart(uint256 _batchindex) public {
        require(addressPledge == msg.sender,"pledge address");
        //强制分发奖励
       // awardForce();
       // batchindex++;
        _restart(_batchindex);
    }
     /**
     * @dev 奖励分发(4%超级节点奖利 前50分一半，后51-250分一半)
    */
    /*
    function award( uint _usdt,uint _erc20 ) public {
        //用户不够 150，存起来暂时不分
        if (_inviteData[batchindex].rankData.length() < 150){
            _inviteData[batchindex].OddAllotErc20 += _erc20;
            _inviteData[batchindex].OddAllotUsdt += _usdt;
            return;
        }
        //前50分一半，后51-250分一半 
        uint256 frontUsdtAvg = _usdt.add(_inviteData[batchindex].OddAllotUsdt).div(2).div(50);
        uint256 backUsdtAvg = _usdt.add(_inviteData[batchindex].OddAllotUsdt).div(2).div(_inviteData[batchindex].rankData.length()-50);
        uint256 frontTokenAvg = _erc20.add(_inviteData[batchindex].OddAllotErc20).div(2).div(50);
        uint256 backTokenAvg = _erc20.add(_inviteData[batchindex].OddAllotErc20).div(2).div(_inviteData[batchindex].rankData.length()-50);

       // for(   _inviteData[batchindex].rankData._indexes)
        for (uint i= 0;i< _inviteData[batchindex].rankData.length();i++){
            if (i < 50){
                //0-49
                waitReceiveUsdt[_inviteData[batchindex].rankData._entries[i]._key]+= frontUsdtAvg;
                waitReceiveErc20[_inviteData[batchindex].rankData._entries[i]._key] += frontTokenAvg;
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,frontUsdtAvg,1);
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,frontTokenAvg,2);
            }else{
                //50-249
                waitReceiveUsdt[_inviteData[batchindex].rankData._entries[i]._key]+= backUsdtAvg;
                waitReceiveErc20[_inviteData[batchindex].rankData._entries[i]._key] += backTokenAvg;
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,backUsdtAvg,1);
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,backTokenAvg,2);
            }
        }
        //待分发的数据清零
        _inviteData[batchindex].OddAllotErc20 = 0;
        _inviteData[batchindex].OddAllotUsdt = 0;
    }
    */
    /**
     * @dev 强制分发奖励(一般在有效排行用户没有150时发生)
    */
    /*
    function awardForce() private{
        //没有可分的
        if (_inviteData[batchindex].OddAllotUsdt < 1 || _inviteData[batchindex].OddAllotErc20 < 1){
            return;
        }

        //addressErc721_c
        //无有效邀请排行数，将U与币转给erc721控制合约
        if (_inviteData[batchindex].rankData.length() < 1){
            require(addressErc721_c != address(0),"721 empty");
            addressUsdt.safeTransfer(addressErc721_c,_inviteData[batchindex].OddAllotUsdt);
            addressERC20.safeTransfer(addressErc721_c,_inviteData[batchindex].OddAllotErc20);
            _inviteData[batchindex].OddAllotErc20 = 0;
            _inviteData[batchindex].OddAllotUsdt = 0;
            return;
        }

        uint256 frontUsdtAvg = 0;
        uint256 backUsdtAvg = 0;
        uint256 frontTokenAvg = 0;
        uint256 backTokenAvg = 0;
        //小于150，全部平分
         if (_inviteData[batchindex].rankData.length() <= 150){ 
            frontUsdtAvg = _inviteData[batchindex].OddAllotUsdt.div(_inviteData[batchindex].rankData.length());
            backUsdtAvg = frontUsdtAvg;
            frontTokenAvg = _inviteData[batchindex].OddAllotErc20.div(_inviteData[batchindex].rankData.length());
            backTokenAvg = frontTokenAvg;
        }else{
            frontUsdtAvg = _inviteData[batchindex].OddAllotUsdt.div(2).div(50);
            backUsdtAvg = _inviteData[batchindex].OddAllotUsdt.div(2).div(_inviteData[batchindex].rankData.length()-50);
            frontTokenAvg = _inviteData[batchindex].OddAllotErc20.div(2).div(50);
            backTokenAvg = _inviteData[batchindex].OddAllotErc20.div(2).div(_inviteData[batchindex].rankData.length()-50);
        }
        for (uint i= 0;i< _inviteData[batchindex].rankData.length();i++){
            if (i < 50){
                //0-49
                waitReceiveUsdt[_inviteData[batchindex].rankData._entries[i]._key]+= frontUsdtAvg;
                waitReceiveErc20[_inviteData[batchindex].rankData._entries[i]._key] += frontTokenAvg;
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,frontUsdtAvg,1);
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,frontTokenAvg,2);
            }else{
                //50-249
                waitReceiveUsdt[_inviteData[batchindex].rankData._entries[i]._key]+= backUsdtAvg;
                waitReceiveErc20[_inviteData[batchindex].rankData._entries[i]._key] += backTokenAvg;
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,backUsdtAvg,1);
                emit Award(batchindex,_inviteData[batchindex].rankData._entries[i]._key,backTokenAvg,2);
            }
        }
        //待分发的数据清零
        _inviteData[batchindex].OddAllotErc20 = 0;
        _inviteData[batchindex].OddAllotUsdt = 0;
    }
    */
    
}