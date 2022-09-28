/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-09
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

interface DataContract{
  function GetRoots(address _token, address _userAddr) external view returns (address[30] memory roots, uint256[30] memory recommends);
  function UpdateUserData(address _token, address _userAddr, bool _valid) external;
}

interface OldPower{
  function tatolpower() external view returns (uint256);
  function otherProfit() external view returns (uint256);
  function card() external view returns (address);
  function locker() external view returns (address);
  function IDO() external view returns (address);
  function token() external view returns (address);
  function datacontract() external view returns (address);
  function other() external view returns (address);
  function MintProfitIndex() external view returns (uint);
  function limitBusd() external view returns (uint256);
  function users(uint) external view returns (address);
  function _userpower(address) external view returns ( uint256, uint256, uint256, uint256, uint256, uint256, uint256);
  function _mintProfitFraction(uint) external view returns ( uint256, uint256, uint);
  function GetUser(address who) external view returns (
        uint256 cardpower,
        uint256 lockerpower,
        uint256 IDOpower,
        uint256 powerUsed,
        uint256 profit,
        uint256 recommendProfit,
        uint256 cardProfit
    );
  function GetMintProfit(uint _index) external view returns (
        uint256 nowtatolpower,
        uint256 subtatolpower,
        uint256 profittoken,
        uint profitprice,
        uint blocknumber
    );
  function GetUserTips(address who) external view returns ( uint index, bool updated );
  function ToUpdate(address who) external;
}

contract PowerContract is  Context,  Pausable{
    using SafeMath for uint256;

    struct UserPower {
        uint256 cardpower;
        uint256 lockerpower;
        uint256 IDOpower;
        uint256 powerUsed;
        uint256 profit;
        uint256 recommendProfit;
        uint256 cardProfit;
    }

    struct UserTips {
        uint index;
        bool updated;
    }

    struct UserRProfit {
        uint256 profit;
        uint256 subpower;
    }

    struct MintProfit {
        uint256 nowtatolpower;
        uint256 subtatolpower;
        uint256 profittoken;
        uint profitprice;
        uint blocknumber;
    }

    struct MintProfitFraction {
        uint256 powerFraction;
        uint256 average;
        uint resetIndex;
    }

    string constant public Version = "STMPOWER V3";
    uint256 public tatolpower;
    uint256 public otherProfit;
    mapping(address => UserPower) public _userpower;

    mapping(uint => MintProfit) public _mintProfit;
    mapping(uint => MintProfitFraction) public _mintProfitFraction;
    uint public MintProfitIndex;

    mapping (address => UserTips) private _usertips;
    mapping (address => UserRProfit) private _userRp;

    address public card;
    address public locker;
    address public IDO;
    address public token;
    address public datacontract;
    address public other;
    address public dister;
    address[] public users;
    address public oldPowerAddr;
//    address public rawPowerAddr;

    uint256 public limitBusd = 200 * 10**18;
    uint256[] public recommendpoint = [30,5,5,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];

    uint256 public validPower = 200;
    address public dataToken;

    event Profit(uint256 _token, uint _price);
//**********************query function******************************* */
    function isUser(address who) public view returns (bool) {
       
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == who) {
                return true;
            }
        }
        return false;
    }

    function GetUserLen() public view returns (uint) {
        return users.length;
    }

    function GetMintProfit(uint _index) public view returns (
        uint256 nowtatolpower,
        uint256 subtatolpower,
        uint256 profittoken,
        uint profitprice,
        uint blocknumber
    ) { 
      nowtatolpower = _mintProfit[_index].nowtatolpower;
      subtatolpower = _mintProfit[_index].subtatolpower;
      profittoken = _mintProfit[_index].profittoken;
      profitprice = _mintProfit[_index].profitprice;
      blocknumber = _mintProfit[_index].blocknumber;
    }

    function GetUser(address who) public view returns (
        uint256 cardpower,
        uint256 lockerpower,
        uint256 IDOpower,
        uint256 powerUsed,
        uint256 profit,
        uint256 recommendProfit,
        uint256 cardProfit
    ) { 
        (cardpower, lockerpower, IDOpower, powerUsed, profit, recommendProfit, cardProfit) = getUserRawData(who);
        uint index = getUserRawTips(who);
        uint256 userpower = cardpower + IDOpower;
        uint256 _pUsed; uint256 _pf;

        if(index < MintProfitIndex){
          (_pUsed, _pf) = getProfitAndUsed(userpower, index);
          if (cardpower >= _pUsed) {
            cardpower = cardpower.sub(_pUsed); 
          }else{
            IDOpower = userpower.sub(_pUsed);
            cardpower = 0;
          }
          cardProfit = cardProfit.add(_pf);
          profit = profit.add(_pf);
          powerUsed = powerUsed.add(_pUsed);
          userpower = userpower.sub(_pUsed);
        }

        if(_userRp[who].profit > 0 && userpower != 0){
          (_pUsed, _pf) = getUserRpAndUsed(who, userpower);
          if(IDOpower >= _pUsed){
            IDOpower = IDOpower.sub(_pUsed);
          }else{
            cardpower = userpower.sub(_pUsed);
            IDOpower = 0;
          }
          profit = profit.add(_pf);
          recommendProfit = recommendProfit.add(_pf);
          powerUsed = powerUsed.add(_pUsed);
        }
    }

    function GetUserTips(address who) public view returns (uint index, bool updated) { 
        index = _usertips[who].index;
        updated = _usertips[who].updated;
    }

    function getFraction(uint index) public view  returns (uint256 powerFraction, uint256 profitFraction) {
      if(index >= MintProfitIndex) {
        return (0,0);
      } 
      uint lastIndex = getLastIndex(_mintProfitFraction[index].resetIndex,MintProfitIndex); 
      require(index <= lastIndex, "index data error");
      if(_mintProfitFraction[lastIndex].resetIndex == index){
        powerFraction = _mintProfitFraction[lastIndex].powerFraction;
        profitFraction = _mintProfitFraction[lastIndex].average;
      } else{
        powerFraction =(_mintProfitFraction[lastIndex].powerFraction.sub(_mintProfitFraction[index].powerFraction))
          .mul(1e18).div(uint256(1e18).sub(_mintProfitFraction[index].powerFraction)); //can be zero
        uint256 usedp = _mintProfitFraction[index].powerFraction.mul(1e18).div(_mintProfitFraction[lastIndex].powerFraction);//can be zero
        uint256 usedps = _mintProfitFraction[lastIndex].average.sub(usedp.mul(_mintProfitFraction[index].average).div(1e18));
        profitFraction = usedps.mul(1e18).div(uint256(1e18).sub(usedp));
      }              
    }

    function getLastIndex(uint index,uint lastIndex) public view  returns (uint newIndex) {
      if(index < _mintProfitFraction[lastIndex].resetIndex) {
        newIndex = getLastIndex(index,_mintProfitFraction[lastIndex].resetIndex);
      }else{
        newIndex = lastIndex;
      }
    }

/********************************internal function*********************************/
    function getProfit(uint256 _token, uint256 _i) internal view  returns (uint256 _profit) {
      if (_i < recommendpoint.length){
        _profit = _token.mul(recommendpoint[_i]).div(100);
      }else {
        _profit = 0;
      }
    }

    function getUserRawData(address who) internal view  returns (uint256 cardpower, uint256 lockerpower, uint256 IDOpower, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 cardProfit) {
      if (!_usertips[who].updated  && oldPowerAddr != address(0)){
        (cardpower, lockerpower, IDOpower, powerUsed, profit, recommendProfit,cardProfit) = OldPower(oldPowerAddr)._userpower(who);
      }else{
        cardProfit = _userpower[who].cardProfit;
        powerUsed = _userpower[who].powerUsed;
        cardpower = _userpower[who].cardpower;
        IDOpower = _userpower[who].IDOpower;
        lockerpower = _userpower[who].lockerpower;
        profit = _userpower[who].profit;
        recommendProfit = _userpower[who].recommendProfit;
      }
    }

    function getUserRawTips(address who) internal view  returns (uint index) {
      if (!_usertips[who].updated  && oldPowerAddr != address(0)){
        (index,) = OldPower(oldPowerAddr). GetUserTips(who);
        if(index == 38) index = 37;
      }else{
        index = _usertips[who].index;
      }
    }

    function getProfitAndUsed(uint256 power,uint index) internal view  returns (uint256 powerUsed, uint256 profit) {
      if(power == 0 || index >= MintProfitIndex) {
        return (0,0);
      }
      (uint256 powerFraction, uint256 profitFraction) = getFraction(index);             
      powerUsed = power.mul(powerFraction).div(1e18);
      profit = powerUsed.mul(profitFraction).div(1e18);
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
/*****************************************private function fraction*****************************/
    function updateUser(address who) private {
      (uint256 cardpower, uint256 lockerpower, uint256 IDOpower, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 cardProfit) = GetUser(who);
      if (_userpower[who].powerUsed != powerUsed || !_usertips[who].updated){
        _userpower[who] = UserPower({
          cardpower: cardpower,
          lockerpower: lockerpower,
          IDOpower: IDOpower,
          powerUsed: powerUsed,
          profit: profit,
          recommendProfit: recommendProfit,
          cardProfit: cardProfit
        });
      }

      if (!_usertips[who].updated){
          _usertips[who].updated = true;
          _usertips[who].index = MintProfitIndex;
          users.push(who);
      }
      if(_usertips[who].index < MintProfitIndex) _usertips[who].index = MintProfitIndex;

      if(_userRp[who].profit > 0){
          if((cardpower + IDOpower) > 0 ){
            tatolpower = tatolpower.sub(_userRp[who].subpower);
          }else{
            otherProfit = otherProfit.add(_userRp[who].profit);
          }        
          delete  _userRp[who];
      }     
    }

    function UpdateUserData(address _userAddr) private {
        bool valid = true;
        if( _userpower[_userAddr].cardpower < validPower){
            valid = false;
        }
        DataContract(datacontract).UpdateUserData(dataToken, _userAddr, valid);
    }

/*************************************public onlyOwner function**********************************/
    function SetContracts(address _card, address _locker, address _IDO, address _token, address _datacontract, address _other) public onlyOwner {
        locker = _locker;
        card = _card;
        IDO = _IDO;
        token = _token;
        datacontract = _datacontract;
        other = _other;
    }

    function SetOldPowerAddr(address _oldPowerAddr) public onlyOwner {
        oldPowerAddr = _oldPowerAddr;
    }

    function SetDisterAddr(address _DisterAddr) public onlyOwner {
        dister = _DisterAddr;
    }

    function SetDataToken(address _dataToken) public onlyOwner {
        dataToken = _dataToken;
    }

    function SetValidPower(uint256 _validPower) public onlyOwner {
        validPower = _validPower;
    }

    function SetLimitBusd(uint256 _limitBusd) public onlyOwner {
        limitBusd = _limitBusd;
    }

    function SetRecommendPoint(uint256[] memory _recommendpoint) public onlyOwner {
      uint256 all = 0;
      for(uint i = 0; i < _recommendpoint.length; i++){
        all += _recommendpoint[i];
      }
      require(all <= 100, "all big than 100");
      recommendpoint = _recommendpoint;
    }

    function ReadOldIn() public onlyOwner {
      tatolpower = OldPower(oldPowerAddr).tatolpower();
      otherProfit = OldPower(oldPowerAddr).otherProfit();
      card = OldPower(oldPowerAddr).card();
      locker = OldPower(oldPowerAddr).locker();
      IDO = OldPower(oldPowerAddr).IDO();
      token = OldPower(oldPowerAddr).token();
      datacontract = OldPower(oldPowerAddr).datacontract();
      other = OldPower(oldPowerAddr).other();
      limitBusd = OldPower(oldPowerAddr).limitBusd();
      dataToken = token;
      MintProfitIndex = OldPower(oldPowerAddr).MintProfitIndex();
    }

    function ReplaceIn(uint256 _tatolpower, address _dister, uint _MintProfitIndex) public onlyOwner {
      tatolpower = _tatolpower;
      dister = _dister;
      MintProfitIndex = _MintProfitIndex;
    }

    function ReplaceMintProfit(uint _index, uint256 _tatolpower, uint _blockNumber, uint256 _token, uint _price) public onlyOwner {
      require(_index > 0, "must form one");
      uint256 new_sub = _token.mul(_price).div(100 * 10**18);
      if(new_sub > _tatolpower){
        _token = _token.mul(_tatolpower).div(new_sub);
        new_sub = _tatolpower;
      }

      require(new_sub <= 1e56, "subpower too big");
      uint256 new_pf = new_sub.mul(1e18).div(_tatolpower);
      require(new_pf >= 1e9, "BaseFraction too small");
      uint256 new_ave = uint256(1e38).div(_price);
      uint new_re = _index;
      uint new_index = _index - 1;
      if(_index > 1 && _mintProfitFraction[new_index].powerFraction != 1e18){
        new_pf = _mintProfitFraction[new_index].powerFraction.mul(uint256(1e18).sub(new_pf)).div(1e18).add(new_pf);
        require(new_pf > _mintProfitFraction[new_index].powerFraction, "Fraction too small");
        uint256 old_pa = _mintProfitFraction[new_index].powerFraction.mul(1e18).div(new_pf);
        new_ave = (old_pa.mul(_mintProfitFraction[new_index].average).add((uint256(1e18).sub(old_pa)).mul(new_ave))).div(1e18);
        new_re = _mintProfitFraction[new_index].resetIndex;
      }
      if(new_pf > 1e18) new_pf = 1e18;

      _mintProfitFraction[_index] =MintProfitFraction({
          powerFraction: new_pf,
          average: new_ave,
          resetIndex: new_re
        });

      _mintProfit[_index] = MintProfit({
        nowtatolpower: _tatolpower,
        subtatolpower: new_sub,
        profittoken: _token,
        profitprice: _price,
        blocknumber: _blockNumber
        });
    }

    function ReadOldFractionIn() public onlyOwner {
      for (uint i = 1; i < MintProfitIndex +1; i++) {
        (_mintProfitFraction[i].powerFraction, _mintProfitFraction[i].average, _mintProfitFraction[i].resetIndex)
        = OldPower(oldPowerAddr)._mintProfitFraction(i);
      }
    }

    function ReadOldFractionInOf(address _oldPower, uint _start, uint _end) public onlyOwner {
      require(_end > _start, "end must big than start");
      require(_start > 0, "start must big than zero");
      for(uint i = _start; i < _end; i++){
        (_mintProfitFraction[i].powerFraction, _mintProfitFraction[i].average, _mintProfitFraction[i].resetIndex)
        = OldPower(_oldPower)._mintProfitFraction(i);
      }
    }

    function ReadOldMintProfitIn() public onlyOwner {
      for (uint i = 1; i < MintProfitIndex +1; i++) {
        (_mintProfit[i].nowtatolpower, _mintProfit[i].subtatolpower, _mintProfit[i].profittoken, _mintProfit[i].profitprice, _mintProfit[i].blocknumber)
        = OldPower(oldPowerAddr).GetMintProfit(i);
      }
    }

    function ReadInOldMintProfitOf(address _oldPower, uint _start, uint _end) public onlyOwner {
      require(_end > _start, "end must big than start");
      require(_start > 0, "start must big than zero");
      for(uint i = _start; i < _end; i++){
        (_mintProfit[i].nowtatolpower, _mintProfit[i].subtatolpower, _mintProfit[i].profittoken, _mintProfit[i].profitprice, _mintProfit[i].blocknumber)
        = OldPower(_oldPower).GetMintProfit(i);
      }
    }

    function ReadOldUserIn(address _oldPower, uint _start, uint _end) public onlyOwner {
      require(_end > _start, "end must big than start");
      for(uint i = _start; i < _end; i++){
        address user = OldPower(_oldPower).users(i);
        updateUser(user);
        UpdateUserData(user);
      }
    }

    function WriteInUser(address who, uint256 cardpower, uint256 lockerpower, uint256 IDOpower, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 cardProfit) public onlyOwner {
        _userpower[who] = UserPower({
          cardpower: cardpower,
          lockerpower: lockerpower,
          IDOpower: IDOpower,
          powerUsed: powerUsed,
          profit: profit,
          recommendProfit: recommendProfit,
          cardProfit: cardProfit
        });
        if (!_usertips[who].updated){
          _usertips[who].updated = true;
          users.push(who);
        }
        _usertips[who].index = MintProfitIndex;
    }

    function ReplaceUser(address[] memory who, uint256[] memory cardpower, uint256[] memory IDOpower, uint256[] memory powerUsed, uint256[] memory profit) public onlyOwner {
        for (uint i = 0; i < who.length; i++){
            _userpower[who[i]].cardpower = cardpower[i];
            _userpower[who[i]].IDOpower = IDOpower[i];
            _userpower[who[i]].powerUsed = powerUsed[i];
            _userpower[who[i]].profit = profit[i];
            if (!_usertips[who[i]].updated){
            _usertips[who[i]].updated = true;
            users.push(who[i]);
            }
            _usertips[who[i]].index = MintProfitIndex;
        }
    }

    function ReplaceEspUser(address[] memory who, uint256[] memory _powerUsed) public onlyOwner {
        uint256 addPowerAll;
        for (uint i = 0; i < who.length; i++){
            (uint256 cardpower, uint256 lockerpower, uint256 IDOpower, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 cardProfit) = GetUser(who[i]);
            if(powerUsed > _powerUsed[i]){
                cardpower = cardpower.add(powerUsed.sub(_powerUsed[i]));
                powerUsed = _powerUsed[i];
                addPowerAll = addPowerAll.add(powerUsed.sub(_powerUsed[i]));
            }
            _userpower[who[i]] = UserPower({
            cardpower: cardpower,
            lockerpower: lockerpower,
            IDOpower: IDOpower,
            powerUsed: powerUsed,
            profit: profit,
            recommendProfit: recommendProfit,
            cardProfit: cardProfit
            });

            if (!_usertips[who[i]].updated){
            _usertips[who[i]].updated = true;
            users.push(who[i]);
            }
            _usertips[who[i]].index = MintProfitIndex;
        }
        tatolpower = tatolpower.add(addPowerAll);
    }

    function WriteMintProfit(address[] memory _users, uint256[] memory _profitTokens, uint256[] memory _subPowers) public onlyOwner{
        require(_users.length == _profitTokens.length, "data len no eq");
        require(_users.length == _subPowers.length, "data len no eq");
        uint256 subPowerAll = 0;
        for (uint i = 0; i < _users.length; i++){
            _userpower[_users[i]].powerUsed = _userpower[_users[i]].powerUsed.add(_subPowers[i]);
            _userpower[_users[i]].profit = _userpower[_users[i]].profit.add(_profitTokens[i]);
            _userpower[_users[i]].cardProfit = _userpower[_users[i]].cardProfit.add(_profitTokens[i]);
            uint256 _useroldpower = _userpower[_users[i]].cardpower + _userpower[_users[i]].IDOpower;
            if (_userpower[_users[i]].IDOpower < _subPowers[i]){
                  _userpower[_users[i]].IDOpower = 0;
                  _userpower[_users[i]].cardpower = _useroldpower.sub(_subPowers[i]);
                  UpdateUserData(_users[i]);
              }else{
                  _userpower[_users[i]].IDOpower = _userpower[_users[i]].IDOpower.sub(_subPowers[i]);
              }
            subPowerAll += _subPowers[i];
         }
         tatolpower = tatolpower.sub(subPowerAll);
    }

    function WithdrawToken(address _token) public whenPaused onlyOwner{
        uint256 tokenvalue = IBEP20(_token).balanceOf(address(this));
        require(tokenvalue > 0, "no token");
        IBEP20(_token).transfer(msg.sender,tokenvalue);
    }    
/*********************************************public function for contract **************/
    function AddCardPower(address _user, uint256 _power) whenNotPaused public {
        require(msg.sender == card, "only call by card-contract");
        updateUser(_user);
        _userpower[_user].cardpower = _userpower[_user].cardpower.add(_power);
        tatolpower = tatolpower.add(_power);
        UpdateUserData(_user);
    }

    function AddLockerPower(address _user, uint256 _power) whenNotPaused public {
        require(msg.sender == locker, "only call by card-contract");
        updateUser(_user);
        _userpower[_user].lockerpower = _userpower[_user].lockerpower.add(_power);
        UpdateUserData(_user);
    }

    function SubLockerPower(address _user, uint256 _power) whenNotPaused public {
        require(msg.sender == locker, "only call by locker-contract");
        updateUser(_user);
        _userpower[_user].lockerpower = _userpower[_user].lockerpower.sub(_power);
        UpdateUserData(_user);
    }

    function AddIDOPower(address _user, uint256 _power) whenNotPaused public {
        require(msg.sender == IDO, "only call by IDO-contract");
        updateUser(_user);
        _userpower[_user].IDOpower = _userpower[_user].IDOpower.add(_power);
        tatolpower = tatolpower.add(_power);
        UpdateUserData(_user);
    }

    function NewCardProfit(address _composer, uint256 _token, uint256 _busd, uint _price) whenNotPaused public {
        require(msg.sender == card, "only call by card-contract");
        uint256 retoken;
        if (_busd >= limitBusd){
          address[30] memory roots; uint256[30] memory recommends;
          uint256 _subrootpower;uint256 _rootprofit;
          (roots,recommends) = DataContract(datacontract).GetRoots(dataToken, _composer);
          for (uint i = 0; i < 30; i++){
            if (roots[i] == address(0)) break;
            if (recommends[i] > i){              
              _rootprofit = getProfit(_token,i);
              _subrootpower = _rootprofit.mul(_price).div(100 * 10**18);
              _userRp[roots[i]].profit = _userRp[roots[i]].profit.add(_rootprofit);
              _userRp[roots[i]].subpower = _userRp[roots[i]].subpower.add(_subrootpower);
              retoken = retoken.add(_rootprofit);
            }
          }
        }
        if(_token > retoken){
          otherProfit = otherProfit.add(_token.sub(retoken));
        }
        emit Profit(_token, _price);
    }
/*******************************************public function************************************ */
    function NewMintProfit(uint256 _token, uint _price) whenNotPaused public {
      require(msg.sender == dister, "only call by other");
      IBEP20(token).transferFrom(msg.sender, address(this), _token);
      if (tatolpower == 0){
        otherProfit = otherProfit.add(_token);
        return;
      }

      uint256 new_sub = _token.mul(_price).div(100 * 10**18);
      if(new_sub > tatolpower){
        _token = _token.mul(tatolpower).div(new_sub);
        new_sub = tatolpower;
      }

      require(new_sub <= 1e56, "subpower too big");
      uint256 new_pf = new_sub.mul(1e18).div(tatolpower);
      require(new_pf >= 1e9, "BaseFraction too small");
      uint256 new_ave = uint256(1e38).div(_price);
      uint new_re = MintProfitIndex;
      if(MintProfitIndex != 0 && _mintProfitFraction[MintProfitIndex].powerFraction != 1e18){
        new_pf = _mintProfitFraction[MintProfitIndex].powerFraction.mul(uint256(1e18).sub(new_pf)).div(1e18).add(new_pf);
        require(new_pf > _mintProfitFraction[MintProfitIndex].powerFraction, "Fraction too small");
        uint256 old_pa = _mintProfitFraction[MintProfitIndex].powerFraction.mul(1e18).div(new_pf);
        new_ave = (old_pa.mul(_mintProfitFraction[MintProfitIndex].average).add((uint256(1e18).sub(old_pa)).mul(new_ave))).div(1e18);
        new_re = _mintProfitFraction[MintProfitIndex].resetIndex;
      }
      if(new_pf > 1e18) new_pf = 1e18;

      MintProfitIndex +=1;

      _mintProfitFraction[MintProfitIndex] =MintProfitFraction({
          powerFraction: new_pf,
          average: new_ave,
          resetIndex: new_re
        });

      _mintProfit[MintProfitIndex] = MintProfit({
        nowtatolpower: tatolpower,
        subtatolpower: new_sub,
        profittoken: _token,
        profitprice: _price,
        blocknumber: block.number
        });

      tatolpower = tatolpower.sub(new_sub);
      emit Profit(_token, _price);
    }

    function WithdrawProfit(address who) whenNotPaused public {
        updateUser(who);
        uint256 _profits = _userpower[who].cardProfit.add(_userpower[who].recommendProfit);
        require(_profits > 0, "no Profit");
        _userpower[who].cardProfit = 0;
        _userpower[who].recommendProfit = 0;

        UpdateUserData(who);

        IBEP20(token).transfer( who,_profits);
    }

    function WithdrawOtherProfit() public{
        require(otherProfit > 0, "no Profit");
        uint256 _otherProfit = otherProfit;
        otherProfit = 0;
        IBEP20(token).transfer( other,_otherProfit);
    }

    function ToUpdate(address who) public {
      updateUser(who);
      UpdateUserData(who);
    }

    function ToUpdateOnly(address who) public {
      updateUser(who);
    }
}