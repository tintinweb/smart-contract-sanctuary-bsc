//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./library.sol";

contract invite  is Ownable {
    using SafeMath for uint256;
    using school for school.schoolData;
    //using Rank for Rank.rankDetail;
    using TransferHelper for address;

    uint256 public batchid=0;

    address public addressPledge;
    //测试网
    address public addressUsdt = 0xEDda29De6B3f43f9A5e0a30e0E74991AD826F7A6;
    address public addressERC20 = 0xDC66C2d6f45B9ef26EfA25c55bEBc935Ac910e0C;
    
    uint8 constant top1 = 5;
    //uint8 constant top2 = 15;

    uint256  MUSTSUREWEIGHT = 20;
    uint256 public constant  maxRank = 15;


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

        school.schoolData  school;

        uint256 lastToalBalanceUsdt;
        uint256 lastToalBalanceErc20;

        uint256 startToalBalanceUsdt;
        uint256 startToalBalanceErc20;

        uint256 runkNumber;
    }

    //邀请数据
    mapping(uint256=> inviteData)  inviteCenter;

    struct RewardData{
        uint256 RewardUsdt;
        uint256 RewardErc20;
        uint256 withdrawUsdt;
        uint256 withdrawErc20;

        uint256 curWeight;

        uint256 lastToalBalanceUsdt;
        uint256 lastToalBalanceErc20;

        uint256 currBatchid;
    }

    mapping(address => RewardData) public userReward;

    struct ProfitData{
        //已被领取的总的Usdt
        uint256 totalDrawU;
        //已被领取的总的token
        uint256 totalDrawT;
        //uint256 lastToalBalance;
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
        addressUsdt = _address;
    } 
    function setToken(address _address) public onlyOwner{
        addressERC20 = _address;
    } 


    constructor()   {
        _restart(0,0,0);
        addressPledge = msg.sender;
    }

    //查询指定用户的有效邀请人数
    function getInviteNumber(uint256 _bathch,address _address)  public view returns(uint){
        return inviteCenter[_bathch].inviteNumber[_address];
    }

    //function getUserBalance(uint )

  //查询指定用户是否有效的被邀请人以及被邀请人的对应的邀请人
    function getInviteIsValid(uint256 _bathch,address _address)  public view returns(bool,bool,address){

        address _inviteAdd = inviteCenter[_bathch].beInvited[_address];
        if (_inviteAdd == address(0)){
            return (inviteCenter[_bathch].pledgedAddress[_address],false,address(0));
        }
        return (inviteCenter[_bathch].pledgedAddress[_address],
            inviteCenter[_bathch].inviteList[_inviteAdd][_address],
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
    //查询 排名数据
    function getRanking(uint256 _bathch,address _address) public view returns(uint) {    
        //return _inviteData[_bathch].rankData._rank[_address]; 
        return inviteCenter[_bathch].school. getRankByAddress(_address);
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
     * @dev 建立新的邀请关系   被邀请者调用 
     * @param _address  邀请地址.
     */
    function inviteNew(address _address) public{
        require(_address != msg.sender,"address equivalent");
        inviteData storage e = inviteCenter[batchid];
        //地址未参与排单
        //require(e.pledgedAddress[_address],"the address is not listed ");
        //已质押过，不能再新建
        require(!e.pledgedAddress[msg.sender],"pledged");

        require(e.beInvited[msg.sender] == address(0),"exists");
        e.beInvited[msg.sender] = _address;
          //初始都是无效用户
        e.inviteList[_address][msg.sender] = false;
        emit SetInvite(batchid,_address,msg.sender, block.timestamp);
    }

    /**
    * @dev 设置有效邀请(质押过)  
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
        school.schoolData storage school =  inviteCenter[batchid].school;
        address nextAddress =  school._nextStudents[major];
        address before50;
        address before150;
        if (school.listSize>=top1){
           before50 = school.getRankBefore(top1);
        }
        if (school.listSize>=maxRank){
           before150 = school.lastAddress;
        }
        if ( nextAddress==address(0)){
            if (school.addStudent(major,count)){
                if (userReward[major].currBatchid != batchid){
                    _updateUserHistoryReward(major);
                }
                userReward[major].currBatchid = batchid;
            }
        }else{
             school.updateScore(major,count);
        }

        if (before50!=address(0)){
            address after50 = school.getRankBefore(top1);
            if(before50!=after50){
               _updateUserReward(before50,1); 
            } 
        }
        if (before150!=address(0)){
            if (before150!=school.lastAddress){
                _updateUserReward(before150,0);
            } 
        } 
        uint256 rank  = school.getRankByAddress(major);
        uint256 weight = _getWeight(rank);
        if (frontIsFull  ){
            if (weight != userReward[major].curWeight) {
                _updateUserReward(major,weight);
            }
        }else{
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
    }

    function _updateUserHistoryRewardV(address _user)internal view returns(uint,uint){
        uint u = _settlementUsdtHistoryV(_user);
        uint t = _settlementErc20HistoryV(_user);
        return (u,t);
        //userReward[_user].currBatchid = batchid;
    }


    function _settlementUsdtHistory(address _user) internal {
        RewardData storage r = userReward[_user];
        uint reward = _settlementUsdtHistoryV(_user);
        r.RewardUsdt =  r.RewardUsdt.add(reward);
        emit Reward(batchid,_user,1,2,reward);
        r.lastToalBalanceErc20  = 0;
    }
    function _settlementUsdtHistoryV(address _user) internal view returns(uint) {
        RewardData storage r = userReward[_user];
        uint batchidH = r.currBatchid;
        uint256 u = inviteCenter[batchidH].lastToalBalanceUsdt;
        uint reward = 0;
        if (isRankFull(batchidH)){
            if (r.curWeight > 0){
                uint diff = u.sub(r.lastToalBalanceUsdt);
                uint256 per = diff.div(MUSTSUREWEIGHT);
                reward = per.mul(r.curWeight);
            }
        }else{
            if (inviteCenter[batchidH].school.listSize != 0 && r.curWeight > 0){
                uint diff = u.sub(inviteCenter[batchidH].startToalBalanceUsdt);
                uint256 per = diff.div(inviteCenter[batchidH].school.listSize);
                reward = per;
            }
        }
        return reward;
        //  r.RewardUsdt =  r.RewardUsdt.add(reward);
        //emit Reward(batchid,_user,1,2,reward);
        //r.lastToalBalanceUsdt = 0;
    }

    function _settlementErc20History(address _user) internal {
        RewardData storage r = userReward[_user];
        uint reward = _settlementErc20HistoryV(_user);
        r.RewardErc20 =  r.RewardErc20.add(reward);
        emit Reward(batchid,_user,2,2,reward);
        r.lastToalBalanceErc20  = 0;
    }

    function _settlementErc20HistoryV(address _user) internal view returns(uint) {
        RewardData storage r = userReward[_user];
        uint batchidH = r.currBatchid;
        uint256 u = inviteCenter[r.currBatchid].lastToalBalanceErc20;
        uint reward = 0;
        if (isRankFull(batchidH)){
            if (r.curWeight > 0){
                uint diff = u.sub(r.lastToalBalanceErc20);
                uint256 per = diff.div(MUSTSUREWEIGHT);
                reward = per.mul(r.curWeight);
            }
            //r.RewardErc20 =  r.RewardErc20.add(per.mul(r.curWeight));
         }else{
            if (inviteCenter[batchidH].school.listSize != 0 && r.curWeight > 0){
                uint diff = u.sub(inviteCenter[batchidH].startToalBalanceErc20);
                uint256 per = diff.div(inviteCenter[batchidH].school.listSize);
                reward = per;
            }
           // r.RewardErc20 =  r.RewardErc20.add(per); 
        }
        return (reward);
    }


    function _settlementUsdt(address _user) internal {
        if (isRankFull()){
            RewardData storage r = userReward[_user];
            (uint ru,uint balance,uint per) = _settlementUsdtV(_user);
            r.RewardUsdt =  ru;
            r.lastToalBalanceUsdt = balance;
            emit Reward(batchid,_user,1,1,per);
        }
    }

    function _settlementUsdtV(address _user) internal  view returns(uint,uint,uint){
        //
        uint256 u = _getBalanceUsdt();
        RewardData storage r = userReward[_user];
        if (isRankFull()){
           // uint weight = r.curWeight;
            uint256 start = r.lastToalBalanceUsdt;
            if (r.lastToalBalanceUsdt == 0){
                start = inviteCenter[batchid].startToalBalanceUsdt;
            }
            uint256 diff = u.sub(start);
            uint256 per = diff.div(MUSTSUREWEIGHT);
           return (r.RewardUsdt.add(per.mul(r.curWeight)),u,per.mul(r.curWeight));
           //  return (r.RewardUsdt.add(per.mul(weight)),u,per.mul(weight));
        }
       // }
        return (r.RewardUsdt,u,0);
    }
 
    function _settlementErc20(address _user) internal {
        if (isRankFull()){
            (uint rt,uint balance,uint per) = _settlementErc20V(_user);
            RewardData storage r = userReward[_user];
            r.RewardErc20 = rt;// r.RewardErc20.add(per.mul(r.curWeight));
            r.lastToalBalanceErc20 = balance;
            emit Reward(batchid,_user,2,1,per);
        }
    }

    function _settlementErc20V(address _user) internal view returns(uint,uint,uint) {
        uint256 u = _getBalanceErc20();
        RewardData storage r = userReward[_user];
        if (isRankFull()){
            uint diff = u.sub(r.lastToalBalanceErc20);
            if (r.lastToalBalanceErc20 == 0){
                diff = u.sub(inviteCenter[batchid].startToalBalanceErc20);
            }
            uint256 per = diff.div(MUSTSUREWEIGHT);
            // r.RewardErc20 =  r.RewardErc20.add(per.mul(r.curWeight));
            //r.lastToalBalanceErc20 = u;
            // emit Reward(batchid,_user,2,1,per.mul(r.curWeight));
            return (r.RewardErc20.add(per.mul(r.curWeight)),u,per.mul(r.curWeight));
        }
        return  (r.RewardErc20,u,0);
    }

    function _getBalanceUsdt() internal view returns (uint256){
        uint256 curbalance = IERC20(addressUsdt).balanceOf(address(this));
        return curbalance.add(profit.totalDrawU);
    }

    function _getBalanceErc20() internal view returns (uint256){
        uint256 curbalance = IERC20(addressERC20).balanceOf(address(this));
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
    function isRankFull(uint _batchid) internal view returns(bool){
        return (inviteCenter[_batchid].school.listSize >= maxRank);
    }

    function settlement() public returns(uint,uint){
        if (userReward[msg.sender].currBatchid != batchid){
            _updateUserHistoryReward(msg.sender);
        }
        _settlementUsdt(msg.sender);
        _settlementErc20(msg.sender);
        uint u  = _withdrwdUsdt(msg.sender);
        uint t  = _withdrwdErc20(msg.sender);
        return(u,t);
    }

    function settlementV(address _address) public view returns(uint,uint){
        uint256 rewardU;
        uint256 rewardT;
        if (userReward[_address].currBatchid != batchid){
            (uint hU,uint hT) = _updateUserHistoryRewardV(_address);
            rewardU = rewardU.add(hU);
            rewardT = rewardT.add(hT);
        }
        (uint uu,,) =  _settlementUsdtV(_address);
        (uint ut,,) = _settlementErc20V(_address);
        rewardU = rewardU.add(uu);
        rewardT =  rewardT.add(ut);
        RewardData memory rd = userReward[_address];
        rewardU = rewardU.sub(rd.withdrawUsdt);
        rewardT = rewardT.sub(rd.withdrawErc20);
        return(rewardU,rewardT);
    }

    //用户领取自己的收益
    function earnings() public{
        (uint u,uint t) = settlement();
        require(u > 0 || t  > 0);
        //require(t != 0);
        if (u > 0){
            addressUsdt.safeTransfer(msg.sender,u);
            userReward[msg.sender].withdrawUsdt =   userReward[msg.sender].withdrawUsdt.add(u);
            profit.totalDrawU  = profit.totalDrawU.add(u);
        }
         if (t > 0){
            addressERC20.safeTransfer(msg.sender,t);
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