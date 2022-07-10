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
    mapping(uint256=> ResData)  public resD;
    /*邀请数据*/
    struct InviteData  {  
        //重启数据
        mapping(address => bool) bePurchase;
        mapping(address => address) inviteAddress;
        mapping(address => uint256)  inviteNumber;
        mapping(address => mapping(address => bool))  beinviteList;
        mapping(address =>bool) beInvited;
        school.schoolData  school;
    }
    //Invite data
    mapping(uint256=> InviteData)   inData;
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

    mapping(uint8 => address) public addressList;
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
        if(updateInData.bePurchase[_address] == true) //下过单无需再计算
            return;
        /*更新、结算推荐地址数据*/
        _UpdateValidInvite(updateInData , _address);
        emit Invite(_address, updateInData.inviteAddress[_address]);
    }

    /*更新、结算推荐地址数据*/
    function _UpdateValidInvite(InviteData storage _data , address _address) private {
        address inviteAdress = _data.inviteAddress[_address]; //推荐地址
        /*更新下单地址有效性 */   
        _data.bePurchase[_address] = true;    //标志已下过单
        /*更新推荐地址数据*/
        uint256 invitenum = _data.inviteNumber[inviteAdress]; //推荐地址的有效推荐数
        _data.inviteNumber[inviteAdress] = invitenum.add(1); //更新推荐地址有效数
        _data.beinviteList[inviteAdress][_address] = true;  //更新邀请地址有效
        if(_data.inviteAddress[_address] == address(0)){
            return;
        }
        /*更新结算数据 user prif  */ 
        /*结算*/
        address oldTop1Address;
        address oldRankAddress;
        address newTop1Address;
        address newRankAddress;
        
        //结算历史
        if(roundId != userReward[inviteAdress].markerRound){
            UpdateEarning(inviteAdress, 0);
        }
        //获取历史排行榜地址 top1  maxrank  
        uint256 oldListSize = _data.school.listSize;
        if(oldListSize >= top1){
            oldTop1Address = _data.school.getRankBefore(top1);
        }
        if(oldListSize >= maxRank){
            oldRankAddress = _data.school.lastAddress;
        }
        //判断增加一个账户排名后是否刚好达到分配标准
        if(oldListSize == maxRank - 1){
            if( _data.inviteNumber[inviteAdress] > _data.school.scores[oldTop1Address]){
                UpdateEarning(inviteAdress, TOPWEIGHT);
            }else if(_data.inviteNumber[inviteAdress] > _data.school.scores[oldRankAddress]){
                UpdateEarning(inviteAdress, MAXRANKWEIGHT);
            }
        }
        //更新排行榜
        if(_data.school.getRankByAddress(inviteAdress) == 0){
            _data.school.addStudent(inviteAdress, _data.inviteNumber[inviteAdress]);
        }else{
            _data.school.updateScore(inviteAdress, _data.inviteNumber[inviteAdress]);
        }
        //对比历史 top1位置是否有发生变化
        if(oldTop1Address != address(0)){
            newTop1Address = _data.school.getRankBefore(top1);
            if(oldTop1Address != newTop1Address){
                UpdateEarning(oldTop1Address, MAXRANKWEIGHT);
            }
        }
        //对比历史 maxrank是否有发生变化
        if(oldRankAddress != address(0)){
            newRankAddress = _data.school.lastAddress;
            if(oldRankAddress != newRankAddress){
                UpdateEarning(oldRankAddress, LIMITWEIGHT);
            }
        }
        //更新自身排行榜
        uint256 selfRank = _data.school.getRankByAddress(inviteAdress);
        if(selfRank >= 1 && selfRank <= top1){
            UpdateEarning(inviteAdress, TOPWEIGHT);
        }else if(selfRank > top1 && selfRank <= maxRank){
            UpdateEarning(inviteAdress, MAXRANKWEIGHT);
        }else{
            UpdateEarning(inviteAdress, LIMITWEIGHT);
        }
        emit PrintUpdateValidInvite(inviteAdress, _data.school._nextStudents[inviteAdress], selfRank);
    }

    function UpdateEarning(address _address, uint8 _weight) private {
        InviteData storage data = inData[roundId];
        uint256 balanceU = _getBalance(usdtAddress);
        uint256 balanceE = _getBalance(xtokenAddress);
        (uint256 totalU, uint256 totalE ) = _countAddV(_address);

        if(roundId != userReward[_address].markerRound){
            userReward[_address].weight = 0;
        }
        else{
            userReward[_address].weight = _weight;
            if(data.school.listSize < maxRank){
                userReward[_address].markerUsdt = resD[roundId].startBalanceUsdt;
                userReward[_address].makerErc20 = resD[roundId].startBalanceErc20;
            }else{
                userReward[_address].markerUsdt = balanceU;
                userReward[_address].makerErc20 = balanceE;
            }
        }
        userReward[_address].rewardUsdt = totalU.add(userReward[_address].rewardUsdt);
        userReward[_address].rewardErc20 = totalE.add(userReward[_address].rewardErc20);
        userReward[_address].markerRound = roundId;
    }

    function Earning() payable public {
        //InviteData storage data = inData[roundId];
        uint256 balanceU = _getBalance(usdtAddress);
        uint256 balanceE = _getBalance(xtokenAddress);
        (uint256 totalU, uint256 earnU, uint256 totalE, uint256 earnE) = countEarningV(msg.sender);

        if(earnU > 0){
            usdtAddress.safeTransfer(msg.sender, earnU);
        }
        if(earnE > 0){
            xtokenAddress.safeTransfer(msg.sender, earnE);
        }
        if(roundId != userReward[msg.sender].markerRound){
            userReward[msg.sender].weight = 0;
        }
        if(inData[roundId].school.listSize < maxRank)
        {
            userReward[msg.sender].markerUsdt = resD[roundId].startBalanceUsdt; 
            userReward[msg.sender].makerErc20 = resD[roundId].startBalanceErc20; 

        }else{
            userReward[msg.sender].markerUsdt = balanceU; 
            userReward[msg.sender].makerErc20 = balanceE;  
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

    function countEarningV (address _address) public view returns (uint256, uint256, uint256, uint256){
        uint256 totalU;
        uint256 totalE;
        uint256 earnU;
        uint256 earnE;
        address countaddress = _address;
        AccountData storage accData = userReward[countaddress];
        //计算收益
        (uint256 countU, uint256 countE) = _countAddV(countaddress);
        totalU = accData.rewardUsdt.add(countU);
        totalE = accData.rewardErc20.add(countE);
        if(totalU >= accData.takeUsdt){
            earnU = totalU.sub(accData.takeUsdt);
        }
        if(totalE > accData.takeErc20){
            earnE = totalE.sub(accData.takeErc20);
        }
        return (totalU, earnU, totalE, earnE);
    }
   
    function _countAddV (address _address) private view returns (uint256, uint256){

        uint256 countUsdt = 0;
        uint256 countErc20 = 0;
        uint256 balanceU = _getBalance(usdtAddress);
        uint256 balanceE = _getBalance(xtokenAddress);
        AccountData storage accData = userReward[_address];
        ResData storage hisresData = resD[accData.markerRound];

        if(roundId != accData.markerRound){
            if(accData.weight != 0){
                if(hisresData.resBalanceUsdt > 0 && hisresData.allWeight > 0){
                    countUsdt = hisresData.resBalanceUsdt
                        .sub(accData.markerUsdt)
                        .div(hisresData.allWeight)
                        .mul(accData.weight);
                }
                if(hisresData.resBalanceErc20 > 0 && hisresData.allWeight > 0){
                    countErc20 = hisresData.resBalanceErc20
                        .sub(accData.makerErc20)
                        .div(hisresData.allWeight)
                        .mul(accData.weight);
                }
            }
        } 
        else if(accData.weight != 0 && inData[roundId].school.listSize >= maxRank){
            if(balanceU > 0){
                countUsdt = balanceU
                    .sub(accData.markerUsdt)
                    .div(MUSTSUREWEIGHT)
                    .mul(accData.weight);
            }
            if(balanceE > 0){
                countErc20 = balanceE
                    .sub(accData.makerErc20)
                    .div(MUSTSUREWEIGHT)
                    .mul(accData.weight);   
            }
        }
        return (countUsdt,countErc20);
    }

    function ReadRankByAddressV(address _address, uint256 _roundid) public view returns(uint256, address){
        address nextAddress = inData[_roundid].school._nextStudents[_address];
        uint256 rank = inData[_roundid].school.getRankByAddress(_address);
        return (rank, nextAddress);
    }

    function Restart(uint256 _round) public OnlyPledged{
        require(resD[_round].init != true,"round already restart");
        
        ResData storage res = resD[roundId];
        /*更新上一轮数据*/
        res.resBalanceUsdt = _getBalance(usdtAddress);
        res.resBalanceErc20 = _getBalance(xtokenAddress);
        if(inData[roundId].school.listSize < maxRank){
            res.allWeight = inData[roundId].school.listSize;
        }
        else{
            res.allWeight = MUSTSUREWEIGHT;
        }
        /*初始化新一轮数据*/
        _Restart(_round, res.resBalanceUsdt, res.resBalanceErc20);
    }

    /*初始化新一轮次数据*/
    function _Restart(uint256 _rounId, uint256 _startBalanceUsdt,uint256 _startBalanceErc20) private {
        /*写入新一轮数据*/
        roundId = _rounId;
        resD[roundId].init = true;
        resD[roundId].startBalanceUsdt = _startBalanceUsdt;
        resD[roundId].startBalanceErc20 = _startBalanceErc20;
        inData[roundId].school.init();
        inData[roundId].school.limitRank = maxRank;
        
        //emit Restart(_round);
    }
    //计算总余额
    function  _getBalance(address _address) private  view returns (uint256) {
        uint256 curbalance = IERC20(_address).balanceOf(address(this));
        return curbalance.add(profit[_address]);
    }

    

    function AddInvitedDataList() public {
        
    
        addressList[0]=0x2d13dCb85B0b06050C4fC2f5C8686A3Ea0dd4692;
        addressList[1]=0x2fCBD5a53C1D51ef30d5aC82D2bdBCE154e6170a;
        addressList[2]=0x85D07191554b006d985Cc9fbD124332f0d1aA622;
        addressList[3]=0x1ceFc81508ec74f8e95366EF0876469663B6FC9B;
        addressList[4]=0x017D0B3c488b835fd4f65739534c8DA32C91b064;
        addressList[5]=0xEdc03235c4233367b464E1158da34Ad8FBaA4cc4;
        addressList[6]=0x0824126849264A9CC02A423A9d87534671735015;
        addressList[7]=0x05312fC6174023F59C67a84dC04a8d80CCfE996D;
        addressList[8]=0xBcf704671d519eD6002BA6f2EC82444345C82777;
        addressList[9]=0xF3ff056dF7f71a7186c3bf4c7D0dC337CC0E9217;
        addressList[10]=0x1973B323038c3fF9E496160D9076509B4292133d;
        addressList[11]=0x5dfE8C847Aeb10194bb1e5c10EEbdC9eBe8bf0DA;
        
        InviteData storage newInData = inData[roundId];
        for(uint8 i = 1; addressList[i] != address(0);  i++){
            if(i <= 6){
                newInData.beInvited[addressList[i-1]] = true;
                newInData.inviteAddress[addressList[i]] = addressList[i-1];
                newInData.beinviteList[addressList[i-1]][addressList[i]] = false;//记录邀请地址已邀请地址，并标记无效
            }else if(i==7){
    
                newInData.inviteAddress[addressList[i]] = addressList[6];
                newInData.beinviteList[addressList[6]][addressList[i]] = false;//记录邀请地址已邀请地址，并标记无效
            }else if(i==8){
                newInData.inviteAddress[addressList[i]] = addressList[5];
                newInData.beinviteList[addressList[5]][addressList[i]] = false;//记录邀请地址已邀请地址，并标记无效
            }else if(i==9){
                newInData.inviteAddress[addressList[i]] = addressList[4];
                newInData.beinviteList[addressList[4]][addressList[i]] = false;//记录邀请地址已邀请地址，并标记无效
            }else if(i==10){
                newInData.inviteAddress[addressList[i]] = addressList[3];
                newInData.beinviteList[addressList[3]][addressList[i]] = false;//记录邀请地址已邀请地址，并标记无效
            }else if(i==11){
                newInData.beInvited[addressList[i-1]] = true;
                newInData.inviteAddress[addressList[i]] = addressList[i-1];
                newInData.beinviteList[addressList[i-1]][addressList[i]] = false;//记录邀请地址已邀请地址，并标记无效
            }

            
        }
    }

    function ReadInvitedDataList(address _address)public view returns(bool,address,uint256){
        InviteData storage viewInData = inData[roundId];

        return (viewInData.bePurchase[_address], viewInData.inviteAddress[_address], viewInData.inviteNumber[_address]);
    }
}