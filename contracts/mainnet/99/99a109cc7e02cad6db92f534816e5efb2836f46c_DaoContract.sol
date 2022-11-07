/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;

contract Context {

  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IReward{
  function GetUserData(address _token, address _userAddr) external view returns (
      address rootAddr,
      uint256 recommend,
      uint256 validnumber,
      bool valid,
      address[] memory validrecommends);
}

contract DaoContract is  Context,  Pausable{
    using SafeMath for uint256;

    struct DaoUser {
        uint index;  //list的索引
        uint256 status; //状态 0,默认，无名额；1，预备，占名额（改为：1，VIP，占名额，不计推荐，计算收益）；2，正式，占名额，推荐不够；3，待激活，占名额；10，有效，占名额，推荐够，计算收益
        uint256 daoLv;  //dao等级
        uint256 profited;//失效收益
        uint256 withdawedProfit;//已提取收益
    }

    string constant public Version = "BASEDAO V0.1.1"; //预备改VIP

    mapping(address => DaoUser) public daoUserData;

    address private token;
    address private rewardAddr;
    address private deadWallet = 0x000000000000000000000000000000000000dEaD;
    address[] public userList;
    uint256 private maxUser = 432;
    uint256 private maxLv = 30;
    uint256 private minValid = 30;
    uint256 private lvUpUsed = 1e20;
    uint256 private activatePoint = 6e18;
    uint256 public totalUsers;
    uint256 private TPFU;    
    uint256 private TUL; 
    uint256 private TAU; 

    event Profit(uint256 _token, uint _price);

/*************************************public onlyOwner function**********************************/
//限制
    function setMinMax(uint256 _minValid, uint256 _maxLv, uint256 _maxUser) public onlyOwner {
        require(totalUsers <= _maxUser, "MAXUSER-MUST-LAGER-THAN-TOTAL");
        require(_maxLv >= maxLv, "MAXLV-MUST-LAGER-THAN-NOW");
        maxUser = _maxUser;
        maxLv = _maxLv;
        minValid = _minValid;
    }
//关联地址
    function setAddress(address _token, address _rewardAddr, address _deadWallet) public onlyOwner {
        token = _token;
        rewardAddr = _rewardAddr;
        deadWallet = _deadWallet;
    }
//参数
    function setParameter(uint256 _lvUpUsed, uint256 _activatePoint) public onlyOwner {
        lvUpUsed = _lvUpUsed;
        activatePoint = _activatePoint;
    }
//写入、添加,写入地址为1级VIP
    function writerUser(address[] memory who) public onlyOwner {
        require(totalUsers.add(who.length) <= maxUser, "OUT-OF-MAX");
        uint adj = totalUsers;
        for (uint256 i = 0; i < who.length; i++) {
            if (daoUserData[who[i]].status == 0) {
                daoUserData[who[i]].index = adj;
                daoUserData[who[i]].status = 1;
                daoUserData[who[i]].daoLv = 1;
                userList.push(who[i]);
                adj++;
            }
        }
        TUL = TUL.add(adj).sub(totalUsers);
        totalUsers = adj;
    }
//移除
    function deleteUser(address[] memory who) public onlyOwner {
        uint subn = totalUsers;
        uint subLv;
        for (uint256 i = 0; i < who.length; i++) {
            if (daoUserData[who[i]].status > 0) {
                subn--;
                if (daoUserData[who[i]].daoLv > 0) subLv = subLv.add(daoUserData[who[i]].daoLv);
                transferProfit(who[i]);
                RemoveUser(daoUserData[who[i]].index, subn);
                delete daoUserData[who[i]];                
            }
        }
        TUL = TUL.sub(subLv);
        totalUsers = subn;
    }
//提取
    function WithdrawToken(address _token) public whenPaused onlyOwner{
        uint256 tokenvalue = IBEP20(_token).balanceOf(address(this));
        require(tokenvalue > 0, "no token");
        IBEP20(_token).transfer(msg.sender,tokenvalue);
    }

/*******************************************public function*************************************/
//用户提取，收益是自提，仅有效/VIP成员有收益发放，正式成员或有效成员提取时触发推荐检查
    function WithdrawProfit(address who) whenNotPaused public {
        transferProfit(who);
        if(daoUserData[who].status == 1 && daoUserData[who].profited != TPFU) daoUserData[who].profited = TPFU;
        if(daoUserData[who].status == 2 || daoUserData[who].status == 10) UpdateUserData(who);
    }
//用户升级，用户销毁lvUpUsed数量token至deadWallet地址（授权合约销毁）,先自动提取未提取的收益，正式成员或有效成员会触发推荐检查，然后提升成员等级1 级，30级封顶，待激活成员不能操作
//用户申请，推荐有效地址>=30且非DAO组织成员时，当DAO组织成员名额未满，可申请成为DAO 组织成员（销毁lvUpUsed数量token至deadWallet地址（授权合约销毁），成为1级有效成员）
    function DaoLvUpdate(address who) whenNotPaused public {       
        if (daoUserData[who].status > 0){    //升级
            require(daoUserData[who].daoLv < maxLv, "LV-IS-MAX");
            require(daoUserData[who].status != 3, "WAIT-ACTIVATE-USER");
            //transferProfit(who);
            //UpdateUserData(who);
            WithdrawProfit(who);
            daoUserData[who].daoLv = daoUserData[who].daoLv.add(1);
        }else{  //申请
            require(totalUsers.add(1) <= maxUser, "OUT-OF-MAX");
            (,,uint256 VN,,) = IReward(rewardAddr).GetUserData(token,who);
            require(VN >= minValid, "NO-ENIUGH-VALIDNUMBER");
            daoUserData[who].status = 10;
            daoUserData[who].profited = TPFU;
            daoUserData[who].daoLv = 1;
            daoUserData[who].index = totalUsers;
            userList.push(who);
            totalUsers = totalUsers.add(1);
        }        
        TUL = TUL.add(1);
        IBEP20(token).transferFrom(who, deadWallet, lvUpUsed);
    }
//用户转移，就是只有正式或有效成员才能转移，转移后失去名额，记录清空，未提取的收益将自动发放，受让者成为待激活，继承转移者等级和名额
    function transferDaoUser(address who) whenNotPaused public {
        require(daoUserData[who].status == 0 && daoUserData[msg.sender].status > 0, "ONLY-DAO-TO-NODAO");
        require(daoUserData[msg.sender].status != 3, "WAIT-ACTIVATE-USER");
        uint256 lv = daoUserData[msg.sender].daoLv;
        uint _index = daoUserData[msg.sender].index;
        uint256 _profits = getProfit(msg.sender);
        if(_profits > 0) IBEP20(token).transfer(msg.sender,_profits);

        daoUserData[who].status = 3;
        daoUserData[who].daoLv = lv;
        daoUserData[who].index = _index;
        userList[_index] = who;
        delete daoUserData[msg.sender];
    }
//用户激活,受让者（待激活）需支付activatePoint*N的TOKEN到合约，激活成员身份，N(代表成员等级),激活后成为正式成员或有效成员（推荐超过30）
    function ActivateUser(address who) whenNotPaused public {
        require(daoUserData[who].status == 3, "NO-WAIT-ACTIVATE-USER");
        uint256 AU = daoUserData[who].daoLv.mul(activatePoint);
        TAU = TAU.add(AU);
        UpdateUserData(who);
        IBEP20(token).transferFrom(who, address(this), AU);
    }
//IRewardPool接口，用于收益发放，DAO 组织成员激活使用的TOKEN，每次结清
    function DoReward(uint256 _token, uint _price) whenNotPaused public {
      require(TUL > 0 && _token.add(TAU).div(TUL) > 0 && _price != 0, "CAN-NOT-DO-REWARD");
      if(_token > 0) IBEP20(token).transferFrom(msg.sender, address(this), _token);
      TPFU = TPFU.add(_token.add(TAU).div(TUL));
      if(TAU > 0) TAU = 0;
      emit Profit(_token, _price);
    }

//**********************query function******************************* */
//查询设置参数
    function GetConfigParam() public view returns (
        uint256 _maxUser,
        uint256 _maxLv,
        uint256 _minValid,
        uint256 _lvUpUsed,
        uint256 _activatePoint
    ) { 
        return (maxUser, maxLv, minValid, lvUpUsed, activatePoint);
    }
//查询设置地址
    function GetConfigAddr() public view returns (
        address _token,
        address _rewardAddr,
        address _deadWallet
    ) { 
        return (token, rewardAddr, deadWallet);
    }
//查询全局状态
    function GetConfigTotal() public view returns (
        uint256 _totalProForLv,    //每级份累积收益
        uint256 _totalLv, //总等级
        uint256 _totalActUsed //未结算激活销耗
    ) { 
        return (TPFU, TUL, TAU);
    }
//查询dao用户
    function GetDaoUser(address who) public view returns (
        uint256 status, //状态
        uint256 daoLv,  //dao等级
        uint256 profit,//未提取收益
        uint256 withdawedProfit //已提取收益
    ) { 
        status = daoUserData[who].status;
        daoLv = daoUserData[who].daoLv;
        withdawedProfit = daoUserData[who].withdawedProfit;
        profit = getProfit(who);
        return (status, daoLv, profit, withdawedProfit);
    }
//IRewardPool接口，检查是否可以发放收益
    function IsCandReward(uint256 _token, uint _price) public view returns (bool) {     
      return (TUL > 0 && _token.add(TAU).div(TUL) > 0 && _price != 0);
    }

/********************************internal function*********************************/
//计算收益
    function getProfit(address who) internal view  returns (uint256 _profit) {
        _profit = (daoUserData[who].status == 10 || daoUserData[who].status == 1) ? TPFU.sub(daoUserData[who].profited) : 0;
        return _profit.mul(daoUserData[who].daoLv);
    }

/*****************************************private function fraction*****************************/
//更新状态
    function UpdateUserData(address _userAddr) private {
        if(daoUserData[_userAddr].profited != TPFU) daoUserData[_userAddr].profited = TPFU;
        (,,uint256 VN,,) = IReward(rewardAddr).GetUserData(token,_userAddr);
        uint _status = (VN >= minValid) ? 10 : 2;
        if( daoUserData[_userAddr].status == _status) return;
        daoUserData[_userAddr].status = _status;
    }
//移除用户
    function RemoveUser(uint _index, uint _Tindex) private {
        if(_index != _Tindex){
            daoUserData[userList[_Tindex]].index = _index;
            userList[_index] = userList[_Tindex];
        }
        userList.pop();
    }
//发送收益
    function transferProfit(address who) private {
        uint256 _profits = getProfit(who);
        if(_profits > 0) {
            daoUserData[who].withdawedProfit = daoUserData[who].withdawedProfit.add(_profits);
            IBEP20(token).transfer( who,_profits);
        }
    }
}