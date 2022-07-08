//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.7;

import  "./library.sol";

contract invite  is Ownable {
    using SafeMath for uint256;
    using school for school.schoolData;
    using TransferHelper for address;

    uint256 public roundId=0;
    address public addressPledge;

    address public usdtAddress;// =0xEDda29De6B3f43f9A5e0a30e0E74991AD826F7A6;
    address public xtokenAddress;// = 0x1d25E978BA0DAa701F10EbeffA64cCC20D82d8d3;

    uint8 constant top1 = 2;  //50
    uint8  MUSTSUREWEIGHT = 12;  //200
    uint8 public constant  maxRank = 6; //150
    uint8 TOPWEIGHT = 2;
    uint8 MAXRANKWEIGHT = 1;
    uint8 LIMITWEIGHT = 0;
  
    //0.001
    uint256 public numGas = 1E15;
    address public addressGas;
 
    event SetInvite(uint,address,address,uint256);
    event PrintUpdateValidInvite(address, address, uint256);
    event PrintEarning(uint, uint, uint, uint, uint);
    event Invite(address, address);
    //event Restart(uint);

    modifier payGas()  { 
        require(addressGas != address(0));
        require(msg.value == numGas);
        _;
       payable(addressGas).transfer(numGas);
    }

  /*重启数据*/
    struct ResData  {  
        bool init;
        uint256 resBalanceUsdt;
        uint256 resBalanceErc20;
        uint256 startBalanceUsdt;
        uint256 startBalanceErc20;
        uint256 allWeight;

    }

    /*邀请数据*/
    struct InviteData  {  
        //重启数据
        ResData  _resData;
        mapping(address => bool) bePurchase;
        mapping(address => address) inviteAddress;
        mapping(address => uint256)  inviteNumber;
        mapping(address => mapping(address => bool))  beinviteList;
        mapping(address =>bool) beInvited;
        school.schoolData  school;
    }

    //Invite data
    mapping(uint256=> InviteData)    inData;

    /*账户数据*/
    struct AccountData{
        uint256 rewardUsdt;
        uint256 rewardErc20;
        uint256 takeUsdt;
        uint256 takeErc20;
        uint8 weight;
        uint256 markerUsdt;
        uint256 makerErc20;
        uint256 markerRound;
    }

    mapping(address => AccountData) public userReward;

    mapping(address => uint256)  public profit;

   /*初始化*/
    constructor(address _usdt,address _x){
        usdtAddress = _usdt;
        xtokenAddress = _x;
        _Restart(0,0,0);
        addressPledge = msg.sender;
    }

    /*调用权限管理*/
    modifier OnlyPledged() {
        require(addressPledge == msg.sender,"pledge address");
        _;
    }

    function SetPledged(address _address) public onlyOwner{
        addressPledge = _address;
    } 

    /*相关设置*/
    function SetUsdt(address _address) public onlyOwner{
        usdtAddress = _address;
    } 
    function SetToken(address _address) public onlyOwner{
        xtokenAddress = _address;
    } 

    function SetAddressGas(address _address) public onlyOwner{
        addressGas = _address;
    }
    function SetNumGas(uint256 _numGas) public onlyOwner {
        numGas = _numGas;
    } 

    /*邀请签名授权，传入上级地址*/
    function InviteNew(address _address) public{
       
        require(_address != msg.sender,"address equivalent");//不能自己邀请自己
        InviteData storage newInData = inData[roundId];
        require(newInData.inviteAddress[msg.sender] == address(0),"has been invited");
        require(newInData.bePurchase[msg.sender] == false,"Purchase already");
        require(newInData.beInvited[msg.sender] == false,"invited already");
  
      
        newInData.beInvited[_address] = true;  //标记邀请地址已有邀请其他地址
        newInData.inviteAddress[msg.sender] = _address; //记录当前地址的邀请地址地址
        newInData.beinviteList[_address][msg.sender] = false;//记录邀请地址已邀请地址，并标记无效
       
        emit SetInvite(roundId, _address, msg.sender, block.timestamp);

    }

    /*用户地址有下单更新邀请数据，传入下单地址 Identifier not found or not unique*/
    function SetValidInvite(address _address) public OnlyPledged {
        require(_address != address(0),"address 0");
        
        InviteData storage updateInData = inData[roundId];
        
        if(updateInData.inviteAddress[_address] == address(0))//若下单地址不存在上级推荐无需更新数据
            return;
        if(updateInData.bePurchase[_address] == true) //下过单无需再计算
            return;
        /*更新、结算推荐地址数据*/

        _UpdateValidInvite(updateInData , _address);
        emit Invite(_address, updateInData.inviteAddress[_address]);
    }

    /*更新、结算推荐地址数据*/
    function _UpdateValidInvite(InviteData storage data , address _address) private {
        address inviteAdress = data.inviteAddress[_address]; //推荐地址
        /*更新下单地址有效性 */   
        data.bePurchase[_address] = true;    //标志已下过单
        /*更新推荐地址数据*/
        uint256 invitenum = data.inviteNumber[inviteAdress]; //推荐地址的有效推荐数
        data.inviteNumber[inviteAdress] = invitenum.add(1); //更新推荐地址有效数
        data.beinviteList[inviteAdress][_address] = true;  //更新邀请地址有效

        /*更新结算数据 user prif  */ 
        /*结算*/
        address oldTop1Address;
        address oldRankAddress;
        address newTop1Address;
        address newRankAddress;
        //结算历史
        if(roundId != userReward[inviteAdress].markerRound){
            UpdateEarning(inviteAdress, userReward[inviteAdress].weight);
        }

        //获取历史排行榜地址 top1  maxrank  
        if(data.school.listSize >= top1){
            oldTop1Address = data.school.getRankBefore(top1);
        }
        if(data.school.listSize >= maxRank){
            oldRankAddress = data.school.lastAddress;
        }
        
        //更新排行榜
        if(data.school.getRankByAddress(inviteAdress) == 0){
            data.school.addStudent(inviteAdress, data.inviteNumber[inviteAdress]);
        }else{
            data.school.updateScore(inviteAdress, data.inviteNumber[inviteAdress]);
        }

        //对比历史 top1位置是否有发生变化
        if(oldTop1Address != address(0)){
            newTop1Address = data.school.getRankBefore(top1);
            if(oldTop1Address != newTop1Address){
                UpdateEarning(oldTop1Address, MAXRANKWEIGHT);
            }
        }

        //对比历史 maxrank是否有发生变化
        if(oldRankAddress != address(0)){
            newRankAddress = data.school.lastAddress;
            if(oldRankAddress != newRankAddress){
                UpdateEarning(oldRankAddress, LIMITWEIGHT);
            }
        }
        
        //更新自身排行榜
        uint256 selfRank = data.school.getRankByAddress(inviteAdress);

        if(selfRank >= 1 && selfRank <= top1){
            UpdateEarning(inviteAdress, TOPWEIGHT);
        }else if(selfRank > top1 && selfRank <= maxRank){
            UpdateEarning(inviteAdress, MAXRANKWEIGHT);
        }else{
            UpdateEarning(inviteAdress, LIMITWEIGHT);
        }

        emit PrintUpdateValidInvite(inviteAdress, data.school._nextStudents[inviteAdress], selfRank);
    }


    function UpdateEarning(address _address, uint8 _weight) private {
        InviteData storage data = inData[roundId];

        (uint256 totalU, uint256 totalE ) = _countEarningV(_address);

        if(roundId != userReward[_address].markerRound){
            userReward[_address].weight = 0;
        }
        else{
            userReward[_address].weight = _weight;
            if(data.school.listSize < maxRank){
                userReward[_address].markerUsdt = data._resData.resBalanceUsdt;
                userReward[_address].makerErc20 = data._resData.resBalanceErc20;
            }else{
                userReward[_address].markerUsdt = _getBalance(usdtAddress);
                userReward[_address].makerErc20 = _getBalance(xtokenAddress);
            }
        }
        userReward[_address].rewardUsdt = totalU.add(userReward[_address].rewardUsdt);
        userReward[_address].rewardErc20 = totalE.add(userReward[_address].rewardErc20);
        userReward[_address].markerRound = roundId;
    }

    function Earning() payable public {
        //InviteData storage data = inData[roundId];

        (uint256 totalU, uint256 earnU, uint256 totalE, uint256 earnE,  ,  ,  , ) = countEarningV(msg.sender);

        if(earnU > 0){
            usdtAddress.safeTransfer(msg.sender, earnU);
        }
        if(earnE > 0){
            xtokenAddress.safeTransfer(msg.sender, earnE);
        }

        if(roundId != userReward[msg.sender].markerRound){
            userReward[msg.sender].weight = 0;
        }
//?
        if(inData[roundId].school.listSize >= maxRank)
        {
            userReward[msg.sender].markerUsdt = _getBalance(usdtAddress); 
            userReward[msg.sender].makerErc20 = _getBalance(xtokenAddress);  
        }else{
            userReward[msg.sender].markerUsdt = inData[roundId]._resData.resBalanceUsdt; 
            userReward[msg.sender].makerErc20 = inData[roundId]._resData.resBalanceErc20;        
        }   
        userReward[msg.sender].rewardUsdt = totalU;
        userReward[msg.sender].rewardErc20 = totalE;
        userReward[msg.sender].markerRound = roundId;
        userReward[msg.sender].takeUsdt = earnU.add(userReward[msg.sender].takeUsdt);
        userReward[msg.sender].takeErc20 = earnE.add(userReward[msg.sender].takeErc20);

        profit[usdtAddress] = earnU.add(profit[usdtAddress]);
        profit[xtokenAddress] = earnE.add(profit[xtokenAddress]);

        emit PrintEarning(totalU, totalE, roundId, userReward[msg.sender].markerUsdt, userReward[msg.sender].makerErc20);
    }

    function countEarningV (address _address) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        uint256 totalU;
        uint256 totalE;
        uint256 earnU;
        uint256 earnE;
        address countaddress = _address;
        AccountData storage accdata = userReward[countaddress];

        //计算收益
        (uint256 countU, uint256 countE) = _countEarningV(countaddress);
        totalU = accdata.rewardUsdt.add(countU);
        totalE = accdata.rewardErc20.add(countE);
        if(totalU >= accdata.takeUsdt){
            earnU = totalU.sub(accdata.takeUsdt);
        }
        if(totalE > accdata.takeErc20){
            earnE = totalE.sub(accdata.takeErc20);
        }
        return (totalU, earnU, totalE, earnE, 
        accdata.rewardUsdt, accdata.takeUsdt,
        accdata.rewardErc20, accdata.takeErc20);
    }

    function _countEarningV (address _address) private view returns (uint256, uint256){

        InviteData storage data = inData[roundId];
        uint256 countUsdt = 0;
        uint256 countErc20 = 0;
        AccountData storage accdata = userReward[_address];

        if(roundId != accdata.markerRound){
            if(accdata.weight != 0){
                if(data._resData.resBalanceUsdt > 0 && data._resData.allWeight > 0){
                    countUsdt = data._resData.resBalanceUsdt
                        .sub(accdata.markerUsdt)
                        .div(data._resData.allWeight)
                        .mul(accdata.weight);
                }
                if(data._resData.resBalanceErc20 > 0 && data._resData.allWeight > 0){
                    countErc20 = data._resData.resBalanceErc20
                        .sub(accdata.makerErc20)
                        .div(data._resData.allWeight)
                        .mul(accdata.weight);
                }
            }
        } 
        else if(accdata.weight != 0 && data.school.listSize >= maxRank){
            (uint256 balanceU) = _getBalance(usdtAddress);
            (uint256 balanceE) = _getBalance(xtokenAddress);
            if(balanceU > 0){
                countUsdt = balanceU
                    .sub(accdata.markerUsdt)
                    .div(MUSTSUREWEIGHT)
                    .mul(accdata.weight);
            }
            if(balanceE > 0){
                countErc20 = balanceE
                    .sub(accdata.makerErc20)
                    .div(MUSTSUREWEIGHT)
                    .mul(accdata.weight);   
            }
        }
        return (countUsdt,countErc20);
    }

    function ReadRankByAddressV(address _address, uint256 _roundid) public view returns(uint256, address){
        address nextAddress = inData[_roundid].school._nextStudents[_address];
        uint256 rank = inData[_roundid].school.getRankByAddress(_address);
        return (rank, nextAddress);
    }

    /*重启，传入轮次ID*/
    function Restart(uint256 _round) public OnlyPledged{
        //重启的轮次id已被使用
        require(inData[_round]._resData.init != true,"round already restart");
        /*定义内部变量*/
        InviteData storage res = inData[roundId];

        /*更新上一轮数据*/
        res._resData.resBalanceUsdt = _getBalance(usdtAddress);
        res._resData.resBalanceErc20 = _getBalance(xtokenAddress);
        if(res.school.listSize < maxRank){
            res._resData.allWeight = res.school.listSize;
        }
        else{
            res._resData.allWeight = MUSTSUREWEIGHT;
        }
        
        /*初始化新一轮数据*/
        _Restart(_round, res._resData.resBalanceUsdt, res._resData.resBalanceErc20);

    }

    /*初始化新一轮次数据*/
    function _Restart(uint256 _round,uint256 _startBalanceUsdt,uint256 _startBalanceErc20) private {
        /*定义内部变量*/

        /*写入新一轮数据*/
        roundId = _round;
        inData[roundId]._resData.init = true;
        inData[roundId]._resData.startBalanceUsdt = _startBalanceUsdt;
        inData[roundId]._resData.startBalanceErc20 = _startBalanceErc20;
        inData[roundId].school.init();
        inData[roundId].school.limitRank = maxRank;
        //emit Restart(_round);
    }
    //计算总余额
    function  _getBalance(address _address) private  view returns (uint256) {
        uint256 curbalance = IERC20(_address).balanceOf(address(this));
        return curbalance.add(profit[_address]);
    }
}