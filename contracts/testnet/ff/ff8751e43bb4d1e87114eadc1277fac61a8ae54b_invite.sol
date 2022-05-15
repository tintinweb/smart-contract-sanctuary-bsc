//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
//pragma solidity >=0.6.12;
//pragma experimental ABIEncoderV2;

import "./library.sol";

contract invite  is Ownable {
    using SafeMath for uint256;
    using Rank for Rank.schoolData;
    using Rank for Rank.rankDetail;
    using TransferHelper for address;

    uint256 public batchid=0;

    address public addressPledge;
    address public addressUsdt = 0xEDda29De6B3f43f9A5e0a30e0E74991AD826F7A6;
    address public addressERC20 = 0x089460Ddb084DE5D7e7483417719C6bA10a2B77b;

     uint256  MUSTSUREWEIGHT = 200;
    // uint256  DIVLEN=1e18;

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
        Rank.schoolData  school;
    }

    //邀请数据
    mapping(uint256=> inviteData)  inviteCenter;

    struct RewardData{
        uint256 RewardUsdt;
        uint256 RewardErc20;
        uint256 withdrawdUsdt;
        uint256 withdrawErc20;

        uint256 curWeight;

        uint256 lastToalBalanceUsdt;
        uint256 lastToalBalanceErc20;
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

    event SetInvite(uint,address,address);

    event SetValidInvite(uint,address);

    modifier onlyPledged() {
         require(addressPledge == msg.sender,"pledge address");
        _;
    }

    function setPledged(address _address) public onlyOwner{
        addressPledge = _address;
    }
//Warning: Visibility for constructor is ignored. If you want the contract to be non-deployable, making it "abstract" is sufficient.
    constructor()   {
        _restart(0);
        addressPledge = msg.sender;
    }

    //查询指定用户的有效邀请人数
    function getInviteNumber(uint256 _bathch,address _address)  public view returns(uint){
        return inviteCenter[_bathch].inviteNumber[_address];
    }

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

    /*
    function getRank(uint _batchid) public view returns(Rank.rankDetail[] memory){
        return inviteCenter[_batchid].school.getTopDetail(150);
    }
    */
    function _getWeight(uint rank) internal  pure returns(uint256){
        if (rank >= 1 && rank <=50){
            return 2;
        } 
        if (rank >= 51 && rank <=150){
            return 1;
        }
        return 0;
    }
  
    /**
     * @dev 建立新的邀请关系   被邀请者调用 
     * @param _address  邀请地址.
     */
    function inviteNew(address _address) public{
        inviteData storage e = inviteCenter[batchid];
        //已质押过，不能再新建
        require(!e.pledgedAddress[msg.sender],"pledged");
        require(e.beInvited[msg.sender] == address(0),"exists");
        e.beInvited[msg.sender] = _address;
          //初始都是无效用户
        e.inviteList[_address][msg.sender] = false;
        emit SetInvite(batchid,_address,msg.sender);
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

        address major = e.beInvited[msg.sender];
 
        e.inviteList[major][_address]=true;
        e.inviteNumber[major].add(1);

        e.inviteNumber[major]= e.inviteNumber[major].add(1);

        emit SetValidInvite(batchid,_address);

        _updateRank(major,e.inviteNumber[major]);
    }

    function _updateRank(address major ,uint256 count) internal{
        /*
        Rank.schoolData storage school =  inviteCenter[batchid].school;
        address nextAddress =  school._nextStudents[major];

        address before50;
        address before150;
        if (school.listSize>=50){
           before50 = school.getRankBefore(50);
        }

        if (school.listSize>=150){
           before150 = school.lastAddress;
        }

        if ( nextAddress==address(0)){
            school.addStudent(major,count);
        }else{
            school.updateScore(major,count);
        }


        if (before50!=address(0)){
            address after50 = school.getRankBefore(50);
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
        _updateUserReward(major,weight);
        */
    }

    function _updateUserReward(address _user,uint256 weight)internal{
        _settlementUsdt(_user);
        _settlementErc20(_user);
        userReward[_user].curWeight = weight;
    }
   
    function _settlementUsdt(address _user) internal {
        uint256 u = _getBalanceUsdt();
        RewardData storage r = userReward[_user];
        uint diff = u.sub(r.lastToalBalanceUsdt);
        uint256 per = diff.div(MUSTSUREWEIGHT);
        r.RewardUsdt =  r.RewardUsdt.add(per.mul(r.curWeight));
        r.lastToalBalanceUsdt = u;
    }

    function _settlementErc20(address _user) internal {
        uint256 u = _getBalanceErc20();
        RewardData storage r = userReward[_user];
        uint diff = u.sub(r.lastToalBalanceErc20);
        uint256 per = diff.div(MUSTSUREWEIGHT);
        r.RewardErc20 =  r.RewardErc20.add(per.mul(r.curWeight));
        r.lastToalBalanceUsdt = u;
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
        return rd.RewardUsdt.sub(rd.withdrawdUsdt);
    }
 
    function _withdrwdErc20(address _user) internal view returns (uint256){
        RewardData memory rd = userReward[_user];
        return rd.RewardErc20.sub(rd.withdrawErc20);
    }
    //用户领取自己的收益
    function earnings() public{
        _settlementUsdt(msg.sender);
        _settlementErc20(msg.sender);
        uint u  = _withdrwdUsdt(msg.sender);
        uint t  = _withdrwdErc20(msg.sender);
        require(u != 0);
        require(t != 0);
        addressUsdt.safeTransfer(msg.sender,u);
        addressERC20.safeTransfer(msg.sender,t);

        userReward[msg.sender].withdrawdUsdt =   userReward[msg.sender].withdrawdUsdt.add(u);
        userReward[msg.sender].withdrawErc20 =   userReward[msg.sender].withdrawErc20.add(t);

        profit.totalDrawU  = profit.totalDrawU.add(u);
        profit.totalDrawT  = profit.totalDrawT.add(u);
    }
 

    function _restart(uint256 _batchid) internal   {
        require(!inviteCenter[_batchid].init,"Reset completed");
         batchid = _batchid;
         inviteData storage newInvite = inviteCenter[batchid];
         newInvite.init = true;
    }
     function restart(uint256 _batchid) internal onlyPledged  {
         _restart(_batchid);
     }
}