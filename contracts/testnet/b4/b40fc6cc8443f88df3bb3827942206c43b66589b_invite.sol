//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.7;

import "./library.sol";

interface IERC721 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 id) external view returns (address);
    function limit() external view returns (uint256);
    function tokenOfOwnerByIndex(address account, uint256 index) external view returns (uint256);
}

library batch{
    using school for school.schoolData;
    using batch for batch.inviteData;
    using SafeMath for uint256;
    //forward
    //邀请的正向关系 
    struct inviteForward{
        //有效数量
        uint256 number;
        //是否有质押
        bool pledge;
        //是否邀请人
        bool invite;
        //所有的邀请地址
        mapping(address => bool) list;
    }
    struct inviteNFT{
        //所有的邀请地址
        mapping(address => bool) list;
    }
    struct inviteData  {  
         //邀请的正向关系
        mapping(address => inviteForward)  forward;
        //邀请反向关系 
        mapping(address => address) backward;
        //NFT的正向绑定关系
        mapping(uint256=> mapping(address => bool)) nftForward;
        //NFT邀请反向关系
        mapping(address => uint256) nftBackward;
    }
    //相关的Token数量
    struct tokenPool_old {
        //school.schoolData  school;
        //当前批次最后结束时USdt Pool 总量
        uint256 lastPoolTotalUsdt;
        //当前批次最后结束时 TokenX Pool 总量
        uint256 lastPoolTotalTokenX;
        //当前批次开如时USdt Pool 总量
        uint256 startPoolTotalUsdt;
        //当前批次开始时tokenX Pool总量
        uint256 startPoolTotalTokenX;
        // uint256 rankNumber;
    }
   struct tokenPool {
        //school.schoolData  school;
        //当前批次最后结束时Pool
        uint256 lastPoolTotal;
        //当前批次最后结束时 TokenX Pool 总量
       // uint256 lastPoolTotalTokenX;
        //当前批次开始时 Pool 总量
        uint256 startPoolTotal;
        //当前批次开始时tokenX Pool总量
 
    }
    struct batchData {
        //是否初始化过
        bool init;
        //当前批次的邀请关系
        batch.inviteData inviteData;
        //当前批次的Token相关的数量
       // tokenPool tokenNum;
        mapping(uint8=>tokenPool) pool;
        //当前批次的排名相关的数据
        school.schoolData  rankData;
    }
    //是否是指定NFT的管理员
    function IsNftOwner(address _nft,address _user,uint256 _nftid) internal view returns(bool){
        address _address = IERC721(_nft).ownerOf(_nftid);
        return (_address == _user);
    }

     //_inviter:邀请人
    //_invitee:被邀请人
    function createInvite(batch.inviteData storage data,address _inviter, address _invitee,uint256 _nftid,address _nftAddress) internal returns(bool){
        require(_inviter != _invitee,"address equivalent");
      //  require(!data.pledgedAddress[_invitee],"pledged");
        require(!data.forward[_invitee].pledge,"pledged");
        //被邀请人已有邀请关系
      //  require(data.beInvited[_invitee] == address(0),"exists"); 
        require(data.backward[_invitee] == address(0),"exists"); 
        //被邀请人 地址已经是邀请人
      //  require(!data.inviteAddress[_invitee],"The address is already the inviter");
        require(!data.forward[_invitee].invite,"The address is already the inviter");
        if (_nftid != 0){
            //check nft
            bool isOwner = IsNftOwner(_nftAddress,_inviter,_nftid);
            if (!isOwner){
            // require(!data.forward[_invitee].invite,"The address is already the inviter");
            require(data.nftBackward[_inviter] == _nftid,"NFT does not belong to the inviter");
            }
            data.nftBackward[_invitee] = _nftid;
            data.nftForward[_nftid][_invitee] = true;
        }

        if (!data.forward[_inviter].invite){
            data.forward[_inviter].invite = true;
        }
        data.backward[_invitee] = _inviter;
        return true;
    }
    //设置有效的邀请  //setValidInvite
    //增加有效邀请数量
    //_invitee:被邀请人
    function addValidInviteNum(batch.inviteData storage data, address _invitee) internal returns(bool){
        require(data.forward[_invitee].pledge ==false,"must new address");
        data.forward[_invitee].pledge =true;
        address major = data.getInviter(_invitee);// data.beInvited[_invitee];
        if (major == address(0)){
            return false;
        }
   
        data.forward[major].list[_invitee]=true;
        data.forward[major].number = data.forward[major].number.add(1);
        return true;
    }
    //获取用户的邀请人
    function getInviter(batch.inviteData storage data, address _invitee) internal view returns(address){
        return (data.backward[_invitee]);
    }

    //创建邀请关系
    function createInviteBatch(batchData storage data,address _inviter, address _invitee,uint256 _nftid,address _nftAddress) internal returns(bool){
       return  data.inviteData.createInvite(_inviter,_invitee,_nftid, _nftAddress);
    }

  //设置有效的邀请  //setValidInvite
    //增加有效邀请数量
    //_invitee:被邀请人
    function addValidInviteNum(batchData storage data, address _invitee) internal returns(bool){
        return data.inviteData.addValidInviteNum(_invitee);
    }
   //获取用户的邀请人
    function getInviter(batchData storage data, address _invitee) internal view returns(address){
        return (data.inviteData.backward[_invitee]);
    }

    function getAddressByRankNumber(batchData storage data,uint256 rankNum) internal view returns(address){
       if (data.rankData.listSize >= rankNum){
           return data.rankData.getRankBefore(rankNum);
       }
       return address(0);
    }
}

contract GasSuper is Ownable {
    uint256 public numGas = 1E15;
    address public addressGas;
    modifier payGas()  { 
        require(addressGas != address(0),"gsa address 0");
        require(msg.value == numGas,"check value");
        _;
       payable(addressGas).transfer(numGas);
    }
    function setAddressGas(address _address) public onlyOwner{
        addressGas = _address;
    }
    function setNumGas(uint256 _numGas) public onlyOwner {
        numGas = _numGas;
    } 
}
contract invite is GasSuper {
    using batch for batch.batchData;
    using batch for batch.tokenPool;
    using school for school.schoolData;
    using SafeMath for uint256; 
    using TransferHelper for address;
    modifier onlyAddress(address _checkAddress,string memory message) {
        require(_checkAddress ==_msgSender(),message);
        _;
    }
   
    modifier checkKeyToken(uint8 _tokenKey) {
        require(_tokenKey == KeyUsdt ||  _tokenKey == KeyTokenX,"token Undefined ");
        _;
    }
    /*
    uint8  public constant top1 = 50;
    uint256 public constant  MUSTSUREWEIGHT = 200;
    uint256 public  constant  maxRank = 150;   
    */
    //2*2+（4-2）
    //4+2
    uint8 public constant top1 = 2;
    uint8 public constant MUSTSUREWEIGHT = 6;
    uint8 public constant  maxRank = 4;   

    uint8 KeyUsdt= 1;//"usdt";
    uint8 KeyTokenX = 2;//"x";
    struct TokenBase {
        //Token总的被领取的值 
        uint256 totalDraw;
        //TOken地址
        address token;
     }
    struct GlobalData {
        uint256 batchid;
        address pledge;
        mapping(uint8=>TokenBase) tokenInfo;
        address nft;
    }
    GlobalData public global;
   //invite data
    mapping(uint256=> batch.batchData)   inviteCenter;

    struct RewardToken{
        //奖历
        uint256 reward;
        //已经领取
        uint256 withdraw;
        //最后一次结算时
        uint256 lastPoolTotal;
    }
    struct RewardData{
        mapping(uint8 =>RewardToken) rewards;
        //当前批次
        uint256 currBatchid;
        //当前权重
        uint256 curWeight;
    }

    mapping(address => RewardData) public userReward;

    event SetInvite(uint,address,address,uint256);
    event SetValidInvite(uint,address,address,uint256);
    //batchid,user,u/t, c/h,amount
    event Reward(uint,address,uint,uint, uint,
        uint,uint,uint,uint);
    
    event Restart(uint,uint);
    constructor(address _usdt,address _x,address _nft)   {
        global.tokenInfo[KeyUsdt].token= _usdt;
        global.tokenInfo[KeyTokenX].token = _x;
        global.nft = _nft;
        global.pledge = msg.sender;
        addressGas = msg.sender;
        _restart(0,0,0);
    }
    /************查询 start *******************/
    function getTokenPoolByBatch(uint256 _bathch,uint8 _keyToken)  external  view  returns(batch.tokenPool memory) {
        return  inviteCenter[_bathch].pool[_keyToken];
    }
    function getUserRewardByToken(address _user,uint8 _keyToken)  external view returns(RewardToken memory){
        return userReward[_user].rewards[_keyToken];
    }
    function getTokenInfo(uint8 _keyToken)  external view returns(TokenBase memory){
        return global.tokenInfo[_keyToken];
    }
    //查询指定用户的有效邀请人数
    function getInviteNumber(uint256 _bathch,address _address)  external view returns(uint){
         return (inviteCenter[_bathch].inviteData.forward[_address].number); 
    }
    function getIsInviteAddress(uint256 _bathch,address _address) external view returns(bool){
        return (inviteCenter[_bathch].inviteData.forward[_address].invite);//    inviteAddress[_address]);
    }
   //查询指定用户是否有效的被邀请人以及被邀请人的对应的邀请人
    function getInviteIsValid(uint256 _bathch,address _address)  external view returns(bool,bool,bool,address,uint256){
        address _inviteAdd = inviteCenter[_bathch].inviteData.backward[_address];//   .beInvited[_address];
        if (_inviteAdd == address(0)){
            return (inviteCenter[_bathch].inviteData.forward[_address].pledge,
            false,
            false,
            address(0),
            inviteCenter[_bathch].inviteData.nftBackward[_address]);
        }
        return (inviteCenter[_bathch].inviteData.forward[_address].pledge,
            inviteCenter[_bathch].inviteData.forward[_inviteAdd].invite,//  .inviteList[_inviteAdd][_address],
            inviteCenter[_bathch].inviteData.forward[_inviteAdd].pledge,//     pledgedAddress[_inviteAdd],
            _inviteAdd,
             inviteCenter[_bathch].inviteData.nftBackward[_address]); 
    }
    function nextStudents(uint _batchid,address _address ) external view returns(address) {
         address nextAddress =  inviteCenter[_batchid].rankData._nextStudents[_address];
         return nextAddress;   
    }
    function getRankBefore(uint _batchid,uint top)public view returns(address) {
        return inviteCenter[_batchid].rankData.getRankBefore(top);
    }
    function findIndex(uint _batchid,uint256 num) public view returns(address){
        return inviteCenter[_batchid].rankData._findIndex(num);
    }
    function size(uint _batchid) public view returns(uint){
        return  inviteCenter[_batchid].rankData.listSize;
    }
    function lastScore(uint _batchid) public view returns(uint){
        return  inviteCenter[_batchid].rankData.lastScore;
    }
    function lastAddress(uint _batchid) public view returns(address){
        return  inviteCenter[_batchid].rankData.lastAddress;
    }
 
    function getRank(uint _batchid,uint top) public view  returns(school.rankDetail[] memory,uint){
        if (top > inviteCenter[_batchid].rankData.listSize){
            top = inviteCenter[_batchid].rankData.listSize;
        }
        return (inviteCenter[_batchid].rankData.getTopDetail(top),top);
    }
    //Query ranking data
    function getRanking(uint256 _bathch,address _address) public view returns(uint) {    
        return inviteCenter[_bathch].rankData.getRankByAddress(_address);
    }

    function getBatchInfo(uint256 _bathch)
    external  view 
    returns(uint,uint,uint,uint,uint) {
        batch.batchData storage data = inviteCenter[_bathch];
          return(data.pool[KeyUsdt].lastPoolTotal,//    data.   tokenNum.lastPoolTotalUsdt,//  lastToalBalanceUsdt,
            data.pool[KeyTokenX].lastPoolTotal,//       data.tokenNum.lastPoolTotalTokenX,
            data.pool[KeyUsdt].startPoolTotal,//    tokenNum.startPoolTotalUsdt,
            data.pool[KeyTokenX].startPoolTotal,//   tokenNum.startPoolTotalTokenX, 
            data.rankData.listSize//.runkNumber
         );
    }
    /************查询 End *******************/
    function setUsdt(address _usdt) public onlyOwner{
        global.tokenInfo[KeyUsdt].token = _usdt;
    }
    function setTokenX(address _token) public onlyOwner{
        global.tokenInfo[KeyTokenX].token = _token;
    }
    function setNft(address _nft) public onlyOwner{
        global.nft = _nft;
    }
    function setPledgeAddress(address _address) public onlyOwner{
        global.pledge = _address;
    }
    //创建新的邀请关系
    function inviteNew(address _inviter,uint256 _nftid) public {
        inviteNew(_inviter,_msgSender(),_nftid);
    }
    function inviteNew(address _inviter, address _invitee,uint256 _nftid) internal{
        require(_inviter != _invitee,"address equivalent");
        inviteCenter[global.batchid].createInviteBatch(_inviter,_invitee,_nftid,global.nft);
        emit SetInvite(global.batchid,_inviter,_invitee, block.timestamp);
    }
    /**
    * @dev Set up a valid invitation (pledged)    _invitee:被邀请者
    */
    function setValidInvite(address _invitee) public onlyAddress(global.pledge,"pledge address") {
        //更新有效邀请数据
        inviteCenter[global.batchid].addValidInviteNum(_invitee);
        address major = inviteCenter[global.batchid].getInviter(_invitee);
        emit SetValidInvite(global.batchid,
            major,
            _invitee,
            block.timestamp);
        //更新排名
        bool frontIsFull =  isRankFull();
        address before50 = inviteCenter[global.batchid].getAddressByRankNumber(top1);
        address before150 = inviteCenter[global.batchid].getAddressByRankNumber(maxRank);
        school.schoolData storage rankData = inviteCenter[global.batchid].rankData;
        address nextAddress =  rankData._nextStudents[major];
        uint256 num = inviteCenter[global.batchid].inviteData.forward[major].number;
        if ( nextAddress==address(0)){
            if (rankData.addStudent(major,num)){
                if (userReward[major].currBatchid != global.batchid){
                    //更新历史收益
                    _updateHistoryReward(major);
                }
                userReward[major].currBatchid = global.batchid;
            }
        }else{
             rankData.updateScore(major,num);
        }

        if (before50!=address(0)){
            address after50 = rankData.getRankBefore(top1);
            if(before50!=after50){
                _updateUserReward(before50,1); 
            } 
        }
        if (before150!=address(0)){
            if (before150!=rankData.lastAddress){
                _updateUserReward(before150,0);
            } 
        } 
        uint256 rank  = rankData.getRankByAddress(major);
        uint256 weight = _getWeight(rank);
        if (frontIsFull){
            if (weight != userReward[major].curWeight) {
                _updateUserReward(major,weight);
            }
        }else{
             if  ( 0 == userReward[major].curWeight) { 
                userReward[major].rewards[KeyUsdt].lastPoolTotal = inviteCenter[global.batchid].pool[KeyUsdt].startPoolTotal;
                userReward[major].rewards[KeyTokenX].lastPoolTotal = inviteCenter[global.batchid].pool[KeyTokenX].startPoolTotal;
             }
             userReward[major].curWeight = weight;
        }
    }
 
    //更新用户收益
    function _updateUserReward(
        address _user,
        uint256 _newWeight) 
    internal{
        (uint256 rewardAddedUsdt,uint256 poolUsdt) = _queryAddedReward(_user,KeyUsdt);
        //新增加的收益
        userReward[_user].rewards[KeyUsdt].reward = userReward[_user].rewards[KeyUsdt].reward.add(rewardAddedUsdt);
         userReward[_user].rewards[KeyUsdt].lastPoolTotal = poolUsdt;

       (uint256 rewardAddedTokenX,uint256 poolTokenX) = _queryAddedReward(_user,KeyTokenX);
        userReward[_user].rewards[KeyTokenX].reward = userReward[_user].rewards[KeyTokenX].reward.add(rewardAddedTokenX);
         userReward[_user].rewards[KeyTokenX].lastPoolTotal = poolTokenX;
        userReward[_user].curWeight = _newWeight;
    }
    function _updateHistoryReward(address _user) internal {
        RewardData storage udata =  userReward[_user];//   inviteCener[global.bathchid];
        //用户已结算的批次与当前批次相同，不需要结算历史收益
        uint256 batchidUser = udata.currBatchid;
        if (batchidUser == global.batchid){
            return;
        }
        //查询历史结算的Usdt与Token
        batch.tokenPool storage poolBatchUsdt  = inviteCenter[batchidUser].pool[KeyUsdt];
        batch.tokenPool storage poolBatchTokenX  = inviteCenter[batchidUser].pool[KeyTokenX];
        //查询上一个批次用户的奖励的USDT
        uint256 rewardUsdt = _queryHistorySettlement(udata,
                                poolBatchUsdt.lastPoolTotal,//  poolBatch.lastPoolTotalUsdt,
                                udata.rewards[KeyUsdt].lastPoolTotal,//  .lastPoolTotalUsdt,
                                poolBatchUsdt.startPoolTotal);//    poolBatch.startPoolTotalUsdt);
        //查询上一个批次用户的奖励的TokenX
        uint256 rewardTokenX = _queryHistorySettlement(udata,
                    poolBatchTokenX.lastPoolTotal,//  poolBatch.lastPoolTotalTokenX,
                    udata.rewards[KeyTokenX].lastPoolTotal,//.lastPoolTotalTokenX,
                    poolBatchTokenX.startPoolTotal);//  poolBatch.startPoolTotalTokenX);
        //更新应该奖励的值Usdt  
        udata.rewards[KeyUsdt].reward = udata.rewards[KeyUsdt].reward.add(rewardUsdt);
        emit Reward(batchidUser,_user,1,2,rewardUsdt,
            udata.rewards[KeyUsdt].lastPoolTotal,//    udata.lastPoolTotalUsdt,//  udata.lastToalBalanceUsdt,
            inviteCenter[batchidUser].pool[KeyUsdt].lastPoolTotal,// .lastPoolTotalUsdt,//   lastToalBalanceUsdt,
            udata.curWeight,
            inviteCenter[batchidUser].rankData.listSize 
        );

        //
        udata.rewards[KeyUsdt].lastPoolTotal = poolBatchUsdt.lastPoolTotal;

        //更新应该奖励的值TokenX
        udata.rewards[KeyTokenX].reward = udata.rewards[KeyTokenX].reward.add(rewardTokenX);
        emit Reward(batchidUser,_user,2,2,rewardTokenX,
            udata.rewards[KeyTokenX].lastPoolTotal,//          udata.lastPoolTotalTokenX,//  udata.lastToalBalanceUsdt,
            inviteCenter[batchidUser].pool[KeyTokenX].lastPoolTotal,// inviteCenter[batchidUser].tokenNum.lastPoolTotalTokenX,
            udata.curWeight,
            inviteCenter[batchidUser].rankData.listSize 
        );
        udata.rewards[KeyTokenX].lastPoolTotal = poolBatchTokenX.lastPoolTotal;
    }
   
    //查询用户应该新增的收益
    //返回：新增的收益，当前池大小
    function _queryAddedReward(
        address _user,
        uint8 _tokenKey)
    internal view checkKeyToken(_tokenKey)
    returns(uint256,uint256){
        RewardData storage udata = userReward[_user];
      //  uint pool = _getPoolNumber(_token);
        uint pool = _getPoolNumber(_tokenKey);
        if(isRankFull() && udata.curWeight> 0){
            uint256 start = userReward[_user].rewards[_tokenKey].lastPoolTotal;// lastPool
            uint256 startPoolBatch  = inviteCenter[global.batchid].pool[_tokenKey].startPoolTotal;  
            if (start < startPoolBatch) { //inviteCenter[global.batchid].startPoolTotalUsdt){
                start = startPoolBatch ;//inviteCenter[global.batchid].startPoolTotalUsdt;
            }
            uint256 diff = pool.sub(start);
            uint256 per = diff.div(MUSTSUREWEIGHT);
            return (per.mul(udata.curWeight),
                    pool);
        }
        return (0,pool);
    }
    
    //查询历史能够结算的值
    //lastPoolTotalBatch:结算批次最后的池总额
    //lastPoolTotalUser:结算批次用户的最后的池总额 
     //startPoolTotalUser：结算批次用户的起始的池总额 
    function _queryHistorySettlement(RewardData storage _udata,
            uint256 _lastPoolTotalBatch,
            uint256 _lastPoolTotalUser,
            uint256 _startPoolTotalBatch ) 
    internal view
    returns(uint)  { 
        uint batchidH = _udata.currBatchid;
        uint reward = 0;
        if (isRankFullByBatch(batchidH)){
            if (_udata.curWeight > 0){
                uint diff = _lastPoolTotalBatch.sub(_lastPoolTotalUser);
                uint256 per = diff.div(MUSTSUREWEIGHT);
                reward = per.mul(_udata.curWeight);
            }
        }else{
            if (inviteCenter[batchidH].rankData.listSize != 0 && _udata.curWeight > 0){
                uint diff = _lastPoolTotalBatch.sub(_startPoolTotalBatch);
                uint256 per = diff.div(inviteCenter[batchidH].rankData.listSize);
                reward = per;
            }
        }
        return reward;
    }

    function _getPoolNumber(uint8 _tokenKey)   internal view  checkKeyToken(_tokenKey)  returns (uint256){
        uint256 balance = IERC20(global.tokenInfo[_tokenKey].token).balanceOf(address(this));
        return balance.add(global.tokenInfo[_tokenKey].totalDraw);
    }
    /*
    function _getTokenPoolByBatch(
        uint256 _bathch,
        uint8 _tokenKey)
    internal view checkKeyToken(_tokenKey) 
    returns(uint256,uint256){
        return(inviteCenter[_bathch].pool[_tokenKey].startPoolTotal,
            inviteCenter[_bathch].pool[_tokenKey].lastPoolTotal);
    } 
    /*
    //根据不同的token币获取用户奖励数据 
    //返回值（奖励的数量，已领取的数量，最后结算时的池数量)
    function _getUserRewardByToken(
        address _user,
        uint8 _tokenKey)
    internal view checkKeyToken(_tokenKey)
    returns (uint256,uint256,uint256){
        RewardData storage udata = userReward[_user];
        return (udata.rewards[_tokenKey].reward,
            udata.rewards[_tokenKey].withdraw,
            udata.rewards[_tokenKey].lastPoolTotal  );
    }
    */
    function earnings() payable public payGas  {
        address _user = msg.sender;
        RewardData storage udata =  userReward[_user];
        (uint256 drawU,uint256 drawX,uint256 poolU,uint256 poolX) = _queryWithdraw(_user);
        //设置相关数据状态
        require(drawU > 0 || drawX  > 0,"There is no income to draw");

        if (drawU > 0){
            global.tokenInfo[KeyUsdt].token.safeTransfer(_user,drawU);
            udata.rewards[KeyUsdt].reward = udata.rewards[KeyUsdt].reward.add(drawU);
            udata.rewards[KeyUsdt].withdraw = udata.rewards[KeyUsdt].withdraw.add(drawU);
            global.tokenInfo[KeyUsdt].totalDraw = global.tokenInfo[KeyUsdt].totalDraw.add(drawU);
        }
         if (drawX > 0){
            global.tokenInfo[KeyTokenX].token.safeTransfer(_user,drawX);
            udata.rewards[KeyTokenX].reward = udata.rewards[KeyTokenX].reward.add(drawX);
            udata.rewards[KeyTokenX].withdraw = udata.rewards[KeyTokenX].withdraw.add(drawX);
            global.tokenInfo[KeyTokenX].totalDraw = global.tokenInfo[KeyTokenX].totalDraw.add(drawX);
        }
        udata.rewards[KeyUsdt].lastPoolTotal = poolU;// .lastPoolTotalUsdt = poolU;
        udata.rewards[KeyTokenX].lastPoolTotal = poolX;
        udata.currBatchid = global.batchid;
    }

    function _queryWithdraw(address _user) 
    internal view 
    returns(uint256,uint256,uint256,uint256){
        RewardData storage udata =  userReward[_user];//   inviteCener[global.bathchid];
        uint256 drawU  = udata.rewards[KeyUsdt].reward;
        uint256 drawT = udata.rewards[KeyTokenX].reward;
        //用户已结算的批次与当前批次相同，不需要结算历史收益
        uint256 batchidUser = udata.currBatchid;
        if (udata.currBatchid != global.batchid){
            batch.tokenPool storage poolBatchUsdt  = inviteCenter[batchidUser].pool[KeyUsdt];
            uint256 drawUH = _queryHistorySettlement(udata,
                                    poolBatchUsdt.lastPoolTotal,//   poolBatch.lastPoolTotalUsdt,
                                    udata.rewards[KeyUsdt].lastPoolTotal,//   .lastPoolTotalUsdt,
                                    poolBatchUsdt.startPoolTotal);//  poolBatch.startPoolTotalUsdt);
            drawU = drawU.add(drawUH);
            batch.tokenPool storage poolBatchTokenX  = inviteCenter[batchidUser].pool[KeyTokenX];
            uint256 drawTH = _queryHistorySettlement(udata,
                                        poolBatchTokenX.lastPoolTotal,//   poolBatch.lastPoolTotalTokenX,
                                        udata.rewards[KeyTokenX].lastPoolTotal,// udata.lastPoolTotalTokenX,
                                        poolBatchTokenX.startPoolTotal);//  poolBatch.startPoolTotalTokenX);
            drawT = drawT.add(drawTH);
        }
        (uint256 currUsdt,uint256 poolUsdt) = _queryAddedReward(_user,KeyUsdt);// _queryAddedReward(_user,global.usdt);
        (uint256 currToken,uint256 poolToken) = _queryAddedReward(_user,KeyTokenX);// _queryAddedReward(_user,global.tokenX);
        drawU = drawU.add(currUsdt);
        drawT = drawT.add(currToken); 
        
        drawU = drawU.sub(udata.rewards[KeyUsdt].withdraw);//   .withdrawUsdt);
        drawT = drawT.sub(udata.rewards[KeyTokenX].withdraw);//    withdrawTokenX);
        return(drawU,drawT,
                poolUsdt,poolToken);
    }
    //查询用户结算能领取的币数量 
    function settlementV(address _user) 
    public view 
    returns(uint,uint){
        (uint256 drawU,uint256 drawT,,) = _queryWithdraw(_user);
        return(drawU,drawT);
    }
   
    function _restart(uint256 _batchid,uint startU,uint startT) internal   {
        batch.batchData storage newInvite = inviteCenter[_batchid];
        newInvite.rankData.init();
        newInvite.init = true;
        newInvite.pool[KeyTokenX].startPoolTotal = startT;//  .startPoolTotalTokenX =startT;
        newInvite.pool[KeyUsdt].startPoolTotal = startU;//     .tokenNum.startPoolTotalUsdt = startU;
        newInvite.rankData.limitRank = maxRank;
        emit Restart(global.batchid,_batchid);
        global.batchid = _batchid;
    }
    function restart(uint256 _batchid) public onlyAddress(global.pledge,"pledge address")
    {
        require(!inviteCenter[_batchid].init,"Reset completed");
        inviteCenter[global.batchid].pool[KeyUsdt].lastPoolTotal = _getPoolNumber(KeyUsdt);
        inviteCenter[global.batchid].pool[KeyTokenX].lastPoolTotal = _getPoolNumber(KeyTokenX);
        uint startUsdt =  inviteCenter[global.batchid].pool[KeyUsdt].lastPoolTotal;// .lastPoolTotalUsdt;//  inviteCenter[batchid].lastToalBalanceUsdt;
        uint startToken = inviteCenter[global.batchid].pool[KeyTokenX].lastPoolTotal;//inviteCenter[batchid].lastToalBalanceErc20;
        if (inviteCenter[global.batchid].rankData.listSize == 0 ){
            startUsdt = inviteCenter[global.batchid].pool[KeyUsdt].startPoolTotal;//    tokenNum.startPoolTotalUsdt;//    startToalBalanceUsdt;
            startToken = inviteCenter[global.batchid].pool[KeyTokenX].startPoolTotal;//  .startPoolTotalTokenX;//  startToalBalanceErc20;
        }
        _restart(_batchid,startUsdt,startToken);
    }
    function isRankFull() 
    internal view 
    returns(bool){
        return (inviteCenter[global.batchid].rankData.listSize >= maxRank);
    }
    function isRankFullByBatch(uint _batchid) 
    internal view 
    returns(bool){
        return (inviteCenter[_batchid].rankData.listSize >= maxRank);
    }
    function _getWeight(uint rank)
    internal  pure
    returns(uint256){
        if (rank >= 1 && rank <= top1){
            return 2;
        } 
        if (rank >= top1 && rank <=maxRank){
            return 1;
        }
        return 0;
    }
}