/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;

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

  function burn(uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

library Uint8a32 {
  uint constant bits = 8;
  uint constant elements = 32;
  //require(bits * elements <= 256);
  uint constant range = 1 << bits;
  uint constant max = range - 1;

  function get(uint va, uint index) internal pure returns (uint){
    require(index < elements);
    return (va >>(bits * index)) & max;
  }

  function set(uint va, uint index, uint ev) internal pure returns (uint){
    require(index < elements);
    require(ev < range);
    index *= bits;
    return (va & ~(max << index)) | (ev << index);
  }
}

interface IDataContract{
  function GetRoots(address _token, address _userAddr) external view returns (address[30] memory roots, uint256[30] memory recommends);
  function UpdateUserData(address _token, address _userAddr, bool _valid) external;
}

contract BusinessPower is  Context,  Pausable{
    using SafeMath for uint256;
/*********************************************struct ******************************************************************/
    struct UserPower {
        uint256 power;  //实体额度/算力
        uint256 powerUsed;  //累计消耗
        uint256 profited; //累计提取
        uint256 powerProfit;    //待提取
    }

    struct UserTips {
        uint index; //用户当前索引
        bool updated;   //有无固化数据
    }

    struct UserRProfit {
        uint256 profit;
        uint256 subpower;
    }

    struct MintProfitAndFraction {
        uint256 nowtatolpower;  //当时总算力
        uint256 profittoken;    //分发总数
        uint256 powerFraction;  //累比值
        uint256 average;        //均分值
        uint resetIndex;        //最近重置索引
        uint profitprice;       //分发时价格
    }
/********************************************mapping *****************************/
    mapping(uint => MintProfitAndFraction) private _MPAF;
    mapping(address => UserPower) private _userpower;
    mapping(address => UserTips) private _usertips;    
    mapping(address => UserRProfit) private _userRp;
/**********************************************values **********************************************/
    string constant public Version = "STMBUSINESSPOWER V0.1.0";

    uint public MintProfitIndex;   
    uint256 public tatolpower;
    uint256 private otherProfit;
    uint256 private recommendpoint = 13857624037477524153594490201905243261392030563730344769581238043608350;//0x000002020202020202020202020202020202020202020202020202050505051e，[30,5,5,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]

    address private dister;
    address private other;    
    address private rewardAddr;          //关系合约地址
    address private businessAddr;          //主合约地址
    address private token;
    address[] public users;

/*****************************************************events ****************************************************/
    event Profit(address indexed _form,uint256 _token, uint _price);
/**************************************************** constructor *************************************/
    constructor() public {}
/**************************************************** public view function *************************************/
    //**获取固化算力数据
    function getUserRawData(address who) public view  returns (uint256 power, uint256 powerUsed, uint256 profited, uint256 powerProfit) {
        powerProfit = _userpower[who].powerProfit;
        powerUsed = _userpower[who].powerUsed;
        power = _userpower[who].power;
        profited = _userpower[who].profited;
        return (power, powerUsed, profited, powerProfit);      
    }
    //**获取额外数据
    function GetUserTips(address who) public view returns (uint _index, bool _updated) { 
        return (_usertips[who].index, _usertips[who].updated);
    }
    //**获取将加速数据
    function GetUserRp(address who) public view returns (uint256 _profit,uint256 _subpower) { 
        return (_userRp[who].profit, _userRp[who].subpower);
    }
    //获取累比均分数据
    function getFraction(uint _index) public view  returns (uint256 powerFraction, uint256 profitFraction, uint lastIndex) {
      if(_index >= MintProfitIndex) {
        return (0,0,MintProfitIndex);
      } 
      lastIndex = getLastIndex(_MPAF[_index].resetIndex,MintProfitIndex); 
      require(_index <= lastIndex, "index data error");
      if(_MPAF[lastIndex].resetIndex == _index){
        powerFraction = _MPAF[lastIndex].powerFraction;
        profitFraction = _MPAF[lastIndex].average;
      } else{
        powerFraction =(_MPAF[lastIndex].powerFraction.sub(_MPAF[_index].powerFraction)).mul(1e18).div(uint256(1e18).sub(_MPAF[_index].powerFraction)); //can be zero
        uint256 usedp = _MPAF[_index].powerFraction.mul(1e18).div(_MPAF[lastIndex].powerFraction);//can be zero
        uint256 usedps = _MPAF[lastIndex].average.sub(usedp.mul(_MPAF[_index].average).div(1e18));
        profitFraction = usedps.mul(1e18).div(uint256(1e18).sub(usedp));
      }              
    }
    //**获取分发数据
    function getMitAndFraction(uint _index) public view  returns (
        uint256 _nowtatolpower, 
        uint256 _profittoken, 
        uint256 _powerFraction,
        uint256 _average,
        uint _resetIndex,
        uint _profitprice ) {
        return (_MPAF[_index].nowtatolpower,_MPAF[_index].profittoken,_MPAF[_index].powerFraction,_MPAF[_index].average,_MPAF[_index].resetIndex,_MPAF[_index].profitprice);
    }
    //获取最新算力数据
    function GetUser(address who) public view returns (
        uint256 power,
        uint256 powerUsed,
        uint256 profited,
        uint256 powerProfit
    ) { 
        (power, powerUsed, profited, powerProfit) = getUserRawData(who);
        uint _index = _usertips[who].index;
        uint256 _pUsed; uint256 _pf;

        if(_index < MintProfitIndex){
          (_pUsed, _pf) = getProfitAndUsed(power, _index);
          power = power.sub(_pUsed); 
          powerProfit = powerProfit.add(_pf);
          profited = profited.add(_pf);
          powerUsed = powerUsed.add(_pUsed);
        }

        if(_userRp[who].profit > 0 && power != 0){
          (_pUsed, _pf) = getUserRpAndUsed(who, power);
          power = power.sub(_pUsed);
          profited = profited.add(_pf);
          powerProfit = powerProfit.add(_pf);
          powerUsed = powerUsed.add(_pUsed);
        }        
    }

    //获取全局设置信息
    function getConfig() public view returns (uint256 _userLen,uint256 _otherProfit, address _dister, address _other, address _rewardAddr, address _token,address _businessAddr) {
        return (users.length,otherProfit,dister,other,rewardAddr,token,businessAddr);
    }
    function getRecommendPoint(uint index) public view returns (uint){
      return Uint8a32.get(recommendpoint,index);
    }

/************************************************* onlyOwner Set function **********************************************/
    //设置关联合约
    function SetContracts(address _token, address _rewardAddr,address _businessAddr) public onlyOwner {
        token = _token;
        rewardAddr = _rewardAddr;
        businessAddr = _businessAddr;
    }
    //设置关联地址
    function SetAddress(address _dister, address _other) public onlyOwner {
        dister = _dister;
        other = _other;
    }
    //设置层级收益点
    function SetRecommendPoints(uint[] memory rp) public onlyOwner{
      require(rp.length <= 32);
      uint256 all = 0;
      for(uint i = 0; i < rp.length; i++){
        all += rp[i];
      }
      require(all <= 100, "all big than 100");
      for (uint j = 0; j < rp.length; ++j){
        all = Uint8a32.set(all,j,rp[j]);
      }
      recommendpoint = all;
    }
    //重置累比均分模型
    function ResetFraction() public onlyOwner {
        _MPAF[MintProfitIndex].resetIndex = MintProfitIndex;
    }
    //提取指定
    function WithdrawToken(address _token) public onlyOwner{
        IBEP20(_token).transfer(msg.sender,IBEP20(_token).balanceOf(address(this)));
    }
    //数据修正方法一
    function ReplaceIn(uint256 _tatolpower, uint _MintProfitIndex) public onlyOwner {
      tatolpower = _tatolpower;
      MintProfitIndex = _MintProfitIndex;
    }
    //数据修正方法二
    function ReplaceMintProfit(uint _index, uint256 _tatolpower, uint256 _token, uint _price) public onlyOwner {
      require(_index > 0, "must form one");
      uint256 new_sub = _token.mul(_price).div(1e18);
      if(new_sub > _tatolpower){
        otherProfit = otherProfit.add(_token.mul(new_sub.sub(_tatolpower)).div(new_sub));
        _token = _token.mul(_tatolpower).div(new_sub);
        new_sub = _tatolpower;
      }

      (uint256 new_pf,uint256 new_ave,uint new_re) = GetNewFraction(new_sub,_price,(_index - 1));

      _MPAF[_index] =MintProfitAndFraction({
        nowtatolpower: tatolpower,
        profittoken: _token,
        powerFraction: new_pf,
        average: new_ave,
        resetIndex: new_re,
        profitprice: _price
      });
    }
    //数据修正方法三
    function ReplaceUser(address[] memory who, uint256[] memory power, uint256[] memory powerUsed, uint256[] memory profited, uint256[] memory powerProfit) public onlyOwner {
        for (uint i = 0; i < who.length; i++){
            _userpower[who[i]].power = power[i];            
            _userpower[who[i]].powerUsed = powerUsed[i];
            _userpower[who[i]].profited = profited[i];
            _userpower[who[i]].powerProfit = powerProfit[i];
            if (!_usertips[who[i]].updated){
            _usertips[who[i]].updated = true;
            users.push(who[i]);
            }
            _usertips[who[i]].index = MintProfitIndex;
        }
    }

/**************************************************************public function *****************************************************************/
    //分发
    function DoReward(uint256 _token, uint _price) whenNotPaused public {
      require(msg.sender == dister, "only call by dister");
      IBEP20(token).transferFrom(msg.sender, address(this), _token);
      if (tatolpower == 0){
        otherProfit = otherProfit.add(_token);
        return;
      }

      uint256 new_sub = _token.mul(_price).div(1e18);
      if(new_sub > tatolpower){
        otherProfit = otherProfit.add(_token.mul(new_sub.sub(tatolpower)).div(new_sub));
        _token = _token.mul(tatolpower).div(new_sub);
        new_sub = tatolpower;
      }

      (uint256 new_pf,uint256 new_ave,uint new_re) = GetNewFraction(new_sub,_price,MintProfitIndex);

      MintProfitIndex +=1;

      _MPAF[MintProfitIndex] =MintProfitAndFraction({
        nowtatolpower: tatolpower,
        profittoken: _token,
        powerFraction: new_pf,
        average: new_ave,
        resetIndex: new_re,
        profitprice: _price
      });

      tatolpower = tatolpower.sub(new_sub);
      emit Profit(token,_token, _price);
    }
    //提取
    function WithdrawProfit(address who) whenNotPaused public {
        updateUser(who);
        uint256 _profits = _userpower[who].powerProfit;
        if (_profits == 0) return;
        _userpower[who].powerProfit = 0;
        IBEP20(token).transfer(who,_profits);
    }
    //提取额外
    function WithdrawOtherProfit() public{
        require(otherProfit > 0, "no Profit");
        uint256 _otherProfit = otherProfit;
        otherProfit = 0;
        IBEP20(token).transfer( other,_otherProfit);
    } 

/****************************************************** private function **********************************************************/
    function AddPowerAndProfit(address _storeWallet, address _userAddr, uint256 _power, uint256 _token, uint _price) public {
        require(msg.sender == businessAddr, "only call by businessAddr");
        updateUser(_userAddr);
        updateUser(_storeWallet);
        _userpower[_userAddr].power = _userpower[_userAddr].power.add(_power);
        _userpower[_storeWallet].power = _userpower[_storeWallet].power.add(_power.mul(20).div(100));
        tatolpower = tatolpower.add(_power.mul(120).div(100));

        uint256 retoken;
        address[30] memory roots; uint256[30] memory recommends;
        (roots,recommends) = IDataContract(rewardAddr).GetRoots(token,_storeWallet);
        uint256 _subrootpower;uint256 _rootprofit;
        for (uint i = 0; i < 30; i++){
          if (roots[i] == address(0)) break;
          if (recommends[i] > i){              
            _rootprofit = getProfit(_token,i);
            _subrootpower = _rootprofit.mul(1e18).div(_price);
            _userRp[roots[i]].profit = _userRp[roots[i]].profit.add(_rootprofit);
            _userRp[roots[i]].subpower = _userRp[roots[i]].subpower.add(_subrootpower);
            retoken = retoken.add(_rootprofit);
          }
        }
        if(_token > retoken){
          otherProfit = otherProfit.add(_token.sub(retoken));
        }
        emit Profit(_storeWallet,_token, _price);
    }

    function updateUser(address who) private {
      (uint256 power, uint256 powerUsed, uint256 profited, uint256 powerProfit) = GetUser(who);
      if (_userpower[who].powerUsed != powerUsed || !_usertips[who].updated){
        _userpower[who] = UserPower({
          power: power,
          powerUsed: powerUsed,
          profited: profited,
          powerProfit: powerProfit
        });
      }

      if (!_usertips[who].updated){
          _usertips[who].updated = true;
          _usertips[who].index = MintProfitIndex;
          users.push(who);
      }
      if(_usertips[who].index < MintProfitIndex) _usertips[who].index = MintProfitIndex;
      if(_userRp[who].profit > 0 && power > 0) tatolpower = tatolpower.sub(_userRp[who].subpower);

      delete  _userRp[who];     
    }
/****************************************************** internal view function **********************************************************/
    function getLastIndex(uint _index,uint lastIndex) internal view  returns (uint newIndex) {
      if(_index < _MPAF[lastIndex].resetIndex) {
        newIndex = getLastIndex(_index,_MPAF[lastIndex].resetIndex);
      }else{
        newIndex = lastIndex;
      }
    }

    function GetNewFraction(uint256 new_sub, uint _price, uint _index) internal view returns (uint256 new_pf, uint256 new_ave, uint new_re) {
      require(new_sub <= 1e56, "subpower too big");
      new_pf = new_sub.mul(1e18).div(tatolpower);
      require(new_pf >= 1e9, "BaseFraction too small");
      new_ave = uint256(1e36).div(_price);
      if(_index != 0 && _MPAF[_index].resetIndex != _index){
        new_pf = _MPAF[_index].powerFraction.mul(uint256(1e18).sub(new_pf)).div(1e18).add(new_pf);
        require(new_pf > _MPAF[_index].powerFraction, "Fraction too small");
        uint256 old_pa = _MPAF[_index].powerFraction.mul(1e18).div(new_pf);
        new_ave = (old_pa.mul(_MPAF[_index].average).add((uint256(1e18).sub(old_pa)).mul(new_ave))).div(1e18);
      }
      if(new_pf < 1e18) {          
          new_re = _MPAF[_index].resetIndex; 
       }else{
          new_pf = 1e18;
          new_re = _index + 1;
       }       

      return (new_pf,new_ave,new_re);
    }

    function getProfitAndUsed(uint256 power,uint _index) internal view  returns (uint256 powerUsed, uint256 profit) {
      if(power == 0 || _index >= MintProfitIndex) {
        return (0,0);
      }
      (uint256 powerFraction, uint256 profitFraction, uint lastIndex) = getFraction(_index);             
      powerUsed = power.mul(powerFraction).div(1e18);
      profit = powerUsed.mul(profitFraction).div(1e18);
      if(lastIndex < MintProfitIndex && powerFraction != 1e18){
          (uint256 _pUsed, uint256 _pf) = getProfitAndUsed(power.sub(powerUsed), lastIndex);
          powerUsed = powerUsed.add(_pUsed);
          profit = profit.add(_pf);
      }
      return (powerUsed,profit);
    }

    function getUserRpAndUsed(address who, uint256 power) internal view  returns (uint256 powerUsed, uint256 profit) {     
      if(power < _userRp[who].subpower){
        profit = _userRp[who].profit.mul(power).div(_userRp[who].subpower);
        powerUsed = power;
      }else{
        profit = _userRp[who].profit;
        powerUsed = _userRp[who].subpower;
      }
    }

    function getProfit(uint256 _token, uint256 _i) internal view  returns (uint256 _profit) {
      if (_i < 32){
        return _token.mul(getRecommendPoint(_i)).div(100);
      }else {
        return 0;
      }
    }
}