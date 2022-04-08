/**
 *Submitted for verification at BscScan.com on 2022-04-08
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
}

contract PowerContract is  Context,  Ownable{
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

    uint256 public tatolpower;
    uint256 public otherProfit;
    mapping(address => UserPower) public _userpower;

    address public card;
    address public locker;
    address public IDO;
    address public token;
    address public datacontract;
    address public other;
    address[] public users;

    function isUser(address who) public view returns (bool) {
       
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == who) {
                return true;
            }
        }
        return false;
    }

    function getProfit(uint256 _token, uint256 _i) internal pure  returns (uint256 _profit) {
      if (_i == 0){
        _profit = _token.mul(30).div(100);
      }else if (_i < 5){
        _profit = _token.mul(5).div(100);
      }else {
        _profit = _token.mul(2).div(100);
      }
    }

    function SetContracts(address _card, address _locker, address _IDO, address _token, address _datacontract, address _other) public onlyOwner {
        require(_card != address(0), "Cannot set to the zero address");
        require(Address.isContract(_card), "Cannot set to a non-contract address");
        require(_locker != address(0), "Cannot set to the zero address");
        require(Address.isContract(_locker), "Cannot set to a non-contract address");
        require(_IDO != address(0), "Cannot set to the zero address");
        require(Address.isContract(_IDO), "Cannot set to a non-contract address");
        locker = _locker;
        card = _card;
        IDO = _IDO;
        token = _token;
        datacontract = _datacontract;
        other = _other;
    }

    function AddCardPower(address _user, uint256 _power) public {
        require(msg.sender == card, "only call by card-contract");
        _userpower[_user].cardpower = _userpower[_user].cardpower.add(_power);
        tatolpower = tatolpower.add(_power);
        if (!isUser(_user)) {
            users.push(_user);
        }
    }

    function AddLockerPower(address _user, uint256 _power) public {
        require(msg.sender == locker, "only call by card-contract");
        _userpower[_user].lockerpower = _userpower[_user].lockerpower.add(_power);
        tatolpower = tatolpower.add(_power);
        if (!isUser(_user)) {
            users.push(_user);
        }
    }

    function SubLockerPower(address _user, uint256 _power) public {
        require(msg.sender == locker, "only call by locker-contract");
        _userpower[_user].lockerpower = _userpower[_user].lockerpower.sub(_power);
        tatolpower = tatolpower.sub(_power);
    }

    function AddIDOPower(address _user, uint256 _power) public {
        require(msg.sender == IDO, "only call by IDO-contract");
        _userpower[_user].IDOpower = _userpower[_user].IDOpower.add(_power);
        tatolpower = tatolpower.add(_power);
        if (!isUser(_user)) {
            users.push(_user);
        }
    }
    function NewCardProfit(address _composer, uint256 _token, uint256 _busd, uint _price) public {
        require(msg.sender == card, "only call by card-contract");
        uint256 _retoken = _token;
        if (_busd >= 200 * 10**18){
          address[30] memory roots; uint256[30] memory recommends;
          uint256 _subpower = 0;uint256 _subrootpower = 0;uint256 _rootprofit = 0; 
          (roots,recommends) = DataContract(datacontract).GetRoots(token, _composer);
          for (uint i = 0; i < 30; i++){
            if (roots[i] != address(0) && recommends[i] > i){
              _rootprofit = getProfit(_token,i);
              _userpower[roots[i]].profit = _userpower[roots[i]].profit.add(_rootprofit);
              _userpower[roots[i]].recommendProfit = _userpower[roots[i]].recommendProfit.add(_rootprofit);
              _subrootpower = _rootprofit.mul(_price).div(100 * 10**18);

              if (_userpower[roots[i]].cardpower < _subrootpower){
                _subrootpower = _userpower[roots[i]].cardpower;
              }
              _userpower[roots[i]].cardpower = _userpower[roots[i]].cardpower.sub(_subrootpower);
              _userpower[roots[i]].powerUsed = _userpower[roots[i]].powerUsed.add(_subrootpower);
              _subpower =  _subpower.add(_subrootpower);
              _retoken = _retoken.sub(_rootprofit);
            }
          }
          tatolpower = tatolpower.sub(_subpower);
        }
        otherProfit = otherProfit.add(_retoken);
    }

    function NewMintProfit(uint256 _token, uint _price) public {
      IBEP20(token).transferFrom(msg.sender, address(this), _token);
      uint256 _subpower = 0;uint256 _subuserpower = 0;uint256 _useroldpower = 0;uint256 _userprofit = 0;
      for (uint i = 0; i < users.length; i++){
        _useroldpower = _userpower[users[i]].cardpower + _userpower[users[i]].lockerpower + _userpower[users[i]].IDOpower;
        _userprofit = _token.mul(_useroldpower).div(tatolpower);
        
        _subuserpower = _userprofit.mul(_price).div(100 * 10**18);
        if (_userpower[users[i]].cardpower < _subuserpower){
          _subuserpower = _userpower[users[i]].cardpower;
        }

        _userpower[users[i]].cardpower = _userpower[users[i]].cardpower.sub(_subuserpower);
        _userpower[users[i]].powerUsed = _userpower[users[i]].powerUsed.add(_subuserpower);
        _userpower[users[i]].profit = _userpower[users[i]].profit.add(_userprofit);
        _userpower[users[i]].cardProfit = _userpower[users[i]].cardProfit.add(_userprofit);
        _subpower =  _subpower.add(_subuserpower);
      }
      tatolpower = tatolpower.sub(_subpower);
    }

    function WithdrawOtherProfit() public onlyOwner{
        require(otherProfit > 0, "no Profit");
        uint256 _otherProfit = otherProfit;
        otherProfit = 0;
        IBEP20(token).transfer( other,_otherProfit);
    }

    function WithdrawProfit() public {
        uint256 _profits = _userpower[msg.sender].cardProfit.add(_userpower[msg.sender].recommendProfit);
        require(_profits > 0, "no Profit");
        _userpower[msg.sender].cardProfit = 0;
        _userpower[msg.sender].recommendProfit = 0;

        IBEP20(token).transfer( msg.sender,_profits);
    }

}