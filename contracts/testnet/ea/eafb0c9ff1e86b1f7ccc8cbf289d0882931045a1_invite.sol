//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.7;

import "./library.sol";

contract invite  is Ownable {
    using SafeMath for uint256;
    using school for school.schoolData;
    using TransferHelper for address;
    uint256 public batchid=0;
    address public addressPledge;

    address public usdt;// =0xEDda29De6B3f43f9A5e0a30e0E74991AD826F7A6;
    address public xtoken;// = 0x1d25E978BA0DAa701F10EbeffA64cCC20D82d8d3;
    /*
    uint8 constant top1 = 50;
    uint256  MUSTSUREWEIGHT = 200;
    uint256 public constant  maxRank = 150;   
  
    */
    //2*2+（4-2）
    //4+2
    uint8 constant top1 = 2;
    uint256  MUSTSUREWEIGHT = 6;
    uint256 public constant  maxRank = 4;   
    //0.001
    uint256 public numGas = 1E15;
    address public addressGas;
    modifier payGas()  { 
        require(addressGas != address(0));
        require(msg.value == numGas);
        _;
       payable(addressGas).transfer(numGas);
    }

    struct inviteData  {  
        bool init;
        //有效邀请数
        mapping(address => uint256)  inviteNumber;
        //对应地址所有的邀请记录
        mapping(address => mapping(address => bool))  inviteList;
        //邀请反向关系 
        mapping(address => address) beInvited;
        //已质押过的地址
        mapping(address => bool) pledgedAddress;

        //是否邀请人
         mapping(address =>bool) inviteAddress;

        school.schoolData  school;

        uint256 lastToalBalanceUsdt;
        uint256 lastToalBalanceErc20;

        uint256 startToalBalanceUsdt;
        uint256 startToalBalanceErc20;

        uint256 runkNumber;
    }

    //invite data
    mapping(uint256=> inviteData)    inviteCenter;

    struct RewardData{
        //奖历的U
        uint256 RewardUsdt;
        //奖历的U
        uint256 RewardErc20;
        //已经领取的U
        uint256 withdrawUsdt;
        //已经领取的T
        uint256 withdrawErc20;
        //当前权重
        uint256 curWeight;
        //最后一次结算时的U余额
        uint256 lastToalBalanceUsdt;
        //最后一次结算时的T余额
        uint256 lastToalBalanceErc20;
        //当前批次
        uint256 currBatchid;
    }

    mapping(address => RewardData) public userReward;

    struct ProfitData{
        //Total Usdt that have been claimed
        uint256 totalDrawU;
        //Total tokens that have been claimed
        uint256 totalDrawT;
    }

    ProfitData public profit;

    event SetInvite(uint,address,address,uint256);
    event SetValidInvite(uint,address,address,uint256);
    //batchid,user,u/t, c/h,amount
    event Reward(uint,address,uint,uint, uint);
    
    event Restart(uint);
    modifier onlyPledged() {
         require(addressPledge == msg.sender,"pledge address");
        _;
    }

    function setPledged(address _address) public onlyOwner{
        addressPledge = _address;
    } 
    function setUsdt(address _address) public onlyOwner{
        usdt = _address;
    } 
    function setToken(address _address) public onlyOwner{
        xtoken = _address;
    } 

    function setAddressGas(address _address) public onlyOwner{
        addressGas = _address;
    }
   function setNumGas(uint256 _numGas) public onlyOwner {
        numGas = _numGas;
    } 
   
    constructor(address _usdt,address _x)   {
        usdt = _usdt;
        xtoken = _x;
        _restart(0,0,0);
        addressPledge = msg.sender;
    }

    //查询指定用户的有效邀请人数
    function getInviteNumber(uint256 _bathch,address _address)  external view returns(uint){
        return (inviteCenter[_bathch].inviteNumber[_address]);
              //  inviteCenter[_bathch].inviteNumber[_address].numValid);
    }

    function getIsInviteAddress(uint256 _bathch,address _address) external view returns(bool){
         return (inviteCenter[_bathch].inviteAddress[_address]);
    }
 
   //查询指定用户是否有效的被邀请人以及被邀请人的对应的邀请人
    function getInviteIsValid(uint256 _bathch,address _address)  external view returns(bool,bool,bool,address){
        address _inviteAdd = inviteCenter[_bathch].beInvited[_address];
        if (_inviteAdd == address(0)){
            return (inviteCenter[_bathch].pledgedAddress[_address],false,false,address(0));
        }
        return (inviteCenter[_bathch].pledgedAddress[_address],
            inviteCenter[_bathch].inviteList[_inviteAdd][_address],
            inviteCenter[_bathch].pledgedAddress[_inviteAdd],
            _inviteAdd); 
    }
     
    function nextStudents(uint _batchid,address _address ) public view returns(address) {
         address nextAddress =  inviteCenter[_batchid].school._nextStudents[_address];
         return nextAddress;   
    }
    function getRankBefore(uint _batchid,uint top)public view returns(address) {
        return inviteCenter[_batchid].school.getRankBefore(top);
    }
    function findIndex(uint _batchid,uint256 num) public view returns(address){
        return inviteCenter[_batchid].school._findIndex(num);
    }
    function size(uint _batchid) public view returns(uint){
        return  inviteCenter[_batchid].school.listSize;
    }
    function lastScore(uint _batchid) public view returns(uint){
        return  inviteCenter[_batchid].school.lastScore;
    }
    function lastAddress(uint _batchid) public view returns(address){
        return  inviteCenter[_batchid].school.lastAddress;
    }
 
    function getRank(uint _batchid,uint top) public view  returns(school.rankDetail[] memory,uint){
        if (top > inviteCenter[_batchid].school.listSize){
            top = inviteCenter[_batchid].school.listSize;
        }
        return (inviteCenter[_batchid].school.getTopDetail(top),top);
    }
    //Query ranking data
    function getRanking(uint256 _bathch,address _address) public view returns(uint) {    
        //return _inviteData[_bathch].rankData._rank[_address]; 
        return inviteCenter[_bathch].school.getRankByAddress(_address);
    }

    function getBatchInfo(uint256 _bathch)
         public view returns(uint,uint,uint,uint,uint) {
        inviteData  storage data = inviteCenter[_bathch];
        return(data.lastToalBalanceUsdt,
            data.lastToalBalanceErc20,
            data.startToalBalanceUsdt,
            data.startToalBalanceErc20,
           // data.startToalBalanceErc20,
            data.runkNumber
         );
    }

    function _getWeight(uint rank) internal  pure returns(uint256){
        if (rank >= 1 && rank <= top1){
            return 2;
        } 
        if (rank >= top1 && rank <=maxRank){
            return 1;
        }
        return 0;
    }
  
    /**
     * @dev Establish a new invitation relationship, called by the invitee 
     * @param _address  invitee address.
     */
    function inviteNew(address _address) public{
        require(_address != msg.sender,"address equivalent");
        inviteData storage e = inviteCenter[batchid];
        //It has been pledged and cannot be built again
        require(!e.pledgedAddress[msg.sender],"pledged");
        require(e.beInvited[msg.sender] == address(0),"exists"); 

        require(!e.inviteAddress[msg.sender],"The address is already the inviter");
        if (!e.inviteAddress[_address]){
            e.inviteAddress[_address] = true;
        }
        e.beInvited[msg.sender] = _address;
        e.inviteList[_address][msg.sender] = false;
       
       // e.inviteNumber[_address].numInvite = e.inviteNumber[_address].numInvite.add(1);
        emit SetInvite(batchid,_address,msg.sender, block.timestamp);
    }

    /**
    * @dev Set up a valid invitation (pledged)  
    */
    function setValidInvite(address _address) public onlyPledged{
        inviteData storage e = inviteCenter[batchid];
        _updateAssioc(e,_address);
    }
    
    function _updateAssioc(inviteData storage e,address _address) internal{
        require(e.pledgedAddress[_address] ==false,"must new address");

        e.pledgedAddress[_address] =true;

        address major = e.beInvited[_address];
        if (major == address(0)){
            return;
        }
        e.inviteList[major][_address]=true;

        e.inviteNumber[major]= e.inviteNumber[major].add(1);

        emit SetValidInvite(batchid,major,_address,block.timestamp);

        _updateRank(major,e.inviteNumber[major]);
    }

    function _updateRank(address major ,uint256 count) internal{
        bool frontIsFull =  isRankFull();
        school.schoolData storage rankData =  inviteCenter[batchid].school;
        address nextAddress =  rankData._nextStudents[major];
        address before50;
        address before150;
        if (rankData.listSize>=top1){
           before50 = rankData.getRankBefore(top1);
        }
        if (rankData.listSize>=maxRank){
           before150 = rankData.lastAddress;
        }
        if ( nextAddress==address(0)){
            if (rankData.addStudent(major,count)){
                if (userReward[major].currBatchid != batchid){
                    _updateUserHistoryReward(major);
                }
                userReward[major].currBatchid = batchid;
            }
        }else{
             rankData.updateScore(major,count);
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
            //(weight != 0 && 
             if  ( 0 == userReward[major].curWeight) {
                userReward[major].lastToalBalanceUsdt =  inviteCenter[batchid].startToalBalanceUsdt;    //_getBalanceUsdt();
                userReward[major].lastToalBalanceErc20 =inviteCenter[batchid].startToalBalanceErc20; //_getBalanceErc20();
             }
             userReward[major].curWeight = weight;
        }
    }

    function _updateUserReward(address _user,uint256 weight)internal{
        _settlementUsdt(_user);
        _settlementErc20(_user);
        userReward[_user].curWeight = weight;
    }
    function _updateUserHistoryReward(address _user)internal{
        _settlementUsdtHistory(_user);
        _settlementErc20History(_user);
        userReward[_user].currBatchid = batchid;
        userReward[_user].curWeight = 0;
    }

    function _updateUserHistoryRewardV(address _user)internal view returns(uint,uint){
        uint u = _settlementUsdtHistoryV(_user);
        uint t = _settlementErc20HistoryV(_user);
        return (u,t); 
    }

    function _settlementUsdtHistory(address _user) internal {
        RewardData storage udata = userReward[_user];
        uint reward = _settlementUsdtHistoryV(_user);
        udata.RewardUsdt =  udata.RewardUsdt.add(reward);
        emit Reward(batchid,_user,1,2,reward);
        udata.lastToalBalanceUsdt = inviteCenter[udata.currBatchid].lastToalBalanceUsdt;
        //r.lastToalBalanceErc20  = 0;
    }
    function _settlementUsdtHistoryV(address _user) internal view returns(uint) {
        RewardData storage udata = userReward[_user];
        uint batchidH = udata.currBatchid;
        uint256 balance = inviteCenter[batchidH].lastToalBalanceUsdt;
        uint reward = 0;
        if (isRankFullByBatch(batchidH)){
            if (udata.curWeight > 0){
                uint diff = balance.sub(udata.lastToalBalanceUsdt);
                uint256 per = diff.div(MUSTSUREWEIGHT);
                reward = per.mul(udata.curWeight);
            }
        }else{
            if (inviteCenter[batchidH].school.listSize != 0 && udata.curWeight > 0){
                uint diff = balance.sub(inviteCenter[batchidH].startToalBalanceUsdt);
                uint256 per = diff.div(inviteCenter[batchidH].school.listSize);
                reward = per;
            }
        }
        return reward; 
    }

    function _settlementErc20History(address _user) internal {
        RewardData storage udata = userReward[_user];
        uint reward = _settlementErc20HistoryV(_user);
        udata.RewardErc20 =  udata.RewardErc20.add(reward);
        emit Reward(batchid,_user,2,2,reward);
       // r.lastToalBalanceErc20  = 0;
        udata.lastToalBalanceErc20 = inviteCenter[udata.currBatchid].lastToalBalanceErc20;
    }

    function _settlementErc20HistoryV(address _user) internal view returns(uint) {
        RewardData storage udata = userReward[_user];
        uint batchidH = udata.currBatchid;
        uint256 balance = inviteCenter[batchidH].lastToalBalanceErc20;
        uint reward = 0;
        if (isRankFullByBatch(batchidH)){
            if (udata.curWeight > 0){
                uint diff = balance.sub(udata.lastToalBalanceErc20);
                uint256 per = diff.div(MUSTSUREWEIGHT);
                reward = per.mul(udata.curWeight);
            }
         }else{
            if (inviteCenter[batchidH].school.listSize != 0 && udata.curWeight > 0){
                uint diff = balance.sub(inviteCenter[batchidH].startToalBalanceErc20);
                uint256 per = diff.div(inviteCenter[batchidH].school.listSize);
                reward = per;
            } 
        }
        return (reward);
    }

    function _settlementUsdt(address _user) internal {
        if (isRankFull()){
            RewardData storage udata = userReward[_user];
            (uint ru,uint balance,uint per) = _settlementUsdtV(_user);
            udata.RewardUsdt =  ru;
            udata.lastToalBalanceUsdt = balance;
            emit Reward(batchid,_user,1,1,per);
        }
    }

    function _settlementUsdtV(address _user) internal  view returns(uint,uint,uint){
        uint256 u = _getBalanceUsdt();
        RewardData storage r = userReward[_user];
        if (isRankFull()){
            uint256 start = r.lastToalBalanceUsdt;
            //if (r.lastToalBalanceUsdt == 0){
            if (start == 0){
                start = inviteCenter[batchid].startToalBalanceUsdt;
            }
            uint256 diff = u.sub(start);
            uint256 per = diff.div(MUSTSUREWEIGHT);
           return (r.RewardUsdt.add(per.mul(r.curWeight)),u,per.mul(r.curWeight));
         }
        return (r.RewardUsdt,u,0);
    }
 
    function _settlementErc20(address _user) internal {
        if (isRankFull()){
            (uint rt,uint balance,uint per) = _settlementErc20V(_user);
            RewardData storage udata = userReward[_user];
            udata.RewardErc20 = rt;// r.RewardErc20.add(per.mul(r.curWeight));
            udata.lastToalBalanceErc20 = balance;
            emit Reward(batchid,_user,2,1,per);
        }
    }

    function _settlementErc20V(address _user) internal view returns(uint,uint,uint) {
        uint256 balance = _getBalanceErc20();
        RewardData storage r = userReward[_user];
        if (isRankFull()){
            uint diff = balance.sub(r.lastToalBalanceErc20);
            if (r.lastToalBalanceErc20 == 0){
                diff = balance.sub(inviteCenter[batchid].startToalBalanceErc20);
            }
            uint256 per = diff.div(MUSTSUREWEIGHT);
            return (r.RewardErc20.add(per.mul(r.curWeight)),balance,per.mul(r.curWeight));
        }
        return  (r.RewardErc20,balance,0);
    }

    function _getBalanceUsdt() internal view returns (uint256){
        uint256 curbalance = IERC20(usdt).balanceOf(address(this));
        return curbalance.add(profit.totalDrawU);
    }

    function _getBalanceErc20() internal view returns (uint256){
        uint256 curbalance = IERC20(xtoken).balanceOf(address(this));
        return curbalance.add(profit.totalDrawT);
    }

    function _withdrwdUsdt(address _user) internal view returns (uint256){
        RewardData memory rd = userReward[_user];
        return rd.RewardUsdt.sub(rd.withdrawUsdt);
    }
 
    function _withdrwdErc20(address _user) internal view returns (uint256){
        RewardData memory rd = userReward[_user];
        return rd.RewardErc20.sub(rd.withdrawErc20);
    }

    function isRankFull() internal view returns(bool){
        return (inviteCenter[batchid].school.listSize >= maxRank);
    }
    function isRankFullByBatch(uint _batchid) internal view returns(bool){
        return (inviteCenter[_batchid].school.listSize >= maxRank);
    }

    function settlement() internal returns(uint,uint){
        if (userReward[msg.sender].currBatchid != batchid){
            _updateUserHistoryReward(msg.sender);
        }else{
            _settlementUsdt(msg.sender);
            _settlementErc20(msg.sender);
        }
        uint u  = _withdrwdUsdt(msg.sender);
        uint t  = _withdrwdErc20(msg.sender);
        return(u,t);
    }

    function settlementV(address _address) public view returns(uint,uint){
       // uint256 rewardU;
       // uint256 rewardT;
        if (userReward[_address].currBatchid != batchid){
            (uint hU,uint hT) = _updateUserHistoryRewardV(_address);
            //rewardU = hU;// rewardU.add(hU);
            //rewardT = hT;// rewardT.add(hT);
            return(hU,hT); 
        }else{
            (uint rewardU,,) = _settlementUsdtV(_address);
            (uint rewardT,,) = _settlementErc20V(_address);
          //  rewardU = rewardU.add(uu);
           // rewardT =  rewardT.add(ut);
            RewardData memory rd = userReward[_address];
            rewardU = rewardU.sub(rd.withdrawUsdt);
            rewardT = rewardT.sub(rd.withdrawErc20);
            return(rewardU,rewardT);
        }
    }


    function earnings() payable public payGas  {
        (uint u,uint t) = settlement();
        require(u > 0 || t  > 0,"There is no income to draw");
        if (u > 0){
            usdt.safeTransfer(msg.sender,u);
            userReward[msg.sender].withdrawUsdt =  userReward[msg.sender].withdrawUsdt.add(u);
            profit.totalDrawU  = profit.totalDrawU.add(u);
        }
         if (t > 0){
            xtoken.safeTransfer(msg.sender,t);
            userReward[msg.sender].withdrawErc20 =   userReward[msg.sender].withdrawErc20.add(t);
            profit.totalDrawT  = profit.totalDrawT.add(t);
         }
    }
 
    function _restart(uint256 _batchid,uint startU,uint startT) internal   {
        require(!inviteCenter[_batchid].init,"Reset completed");
        batchid = _batchid;
        inviteData storage newInvite = inviteCenter[batchid];
        newInvite.school.init();
        newInvite.init = true;
        newInvite.startToalBalanceErc20 = startT;
        newInvite.startToalBalanceUsdt = startU;
        newInvite.school.limitRank = maxRank;
        emit Restart(_batchid);
    }
    function restart(uint256 _batchid) public onlyPledged  {
        inviteCenter[batchid].lastToalBalanceUsdt = _getBalanceUsdt();
        inviteCenter[batchid].lastToalBalanceErc20 = _getBalanceErc20();     
        inviteCenter[batchid].runkNumber = inviteCenter[batchid].school.listSize;
        uint startUsdt = inviteCenter[batchid].lastToalBalanceUsdt;
        uint startToken = inviteCenter[batchid].lastToalBalanceErc20;
        if (inviteCenter[batchid].school.listSize == 0 ){
            startUsdt = inviteCenter[batchid].startToalBalanceUsdt;
            startToken = inviteCenter[batchid].startToalBalanceErc20;
        }
         _restart(_batchid,startUsdt,startToken);
    }
}