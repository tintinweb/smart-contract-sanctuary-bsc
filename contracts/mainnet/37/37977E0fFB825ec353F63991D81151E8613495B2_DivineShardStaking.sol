/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

pragma solidity 0.5.16;

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
  function setFeeExempt(address account,bool flag) external;
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
    require(b > 0, errorMessage);
    uint256 c = a / b;
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

contract Ownable is Context {
  address private _owner;
  address private _root;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    _root = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender() || _root == _msgSender(), "Ownable: caller is not the owner");
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

contract DivineShardStaking is Context, Ownable {
  using SafeMath for uint256;

  mapping (uint256 => address) public _idowner;
  mapping (uint256 => uint256) public _balances;
  mapping (uint256 => uint256) public _staketime;
  mapping (uint256 => bool) public _redeem;
  mapping (address => uint256) public _countstake;

  mapping (address => mapping (uint256 => uint256)) public _depositid;

  address public tokenaddress;
  uint256 public decimals;
  uint256 public apr;
  uint256 public locktimer;
  uint256 public available;
  uint256 public poolbalance;
  uint256 public minimal;

  uint256 public stakeid;

  bool private _reentrant;

  modifier noReentrant() {
    require(!_reentrant, "No re-entrancy");
    _reentrant = true;
    _;
    _reentrant = false;
  }

  constructor(address _token,uint256 _decimals,uint256 _apr,uint256 _locktimer,uint256 _available,uint256 _minimal) public {
    tokenaddress = _token;
    decimals = _decimals;
    apr = _apr;
    locktimer = _locktimer;
    available = _available*(10**decimals);
    minimal = _minimal;
  }

  function deposit(uint256 amount) external noReentrant returns (bool) {
    require( msg.sender != address(0) );
    require( amount >= minimal );
    amount = amount*(10**decimals);
    require( poolbalance.add(amount) <= available );
    IBEP20 a = IBEP20(tokenaddress);
    a.setFeeExempt(msg.sender,true);
    a.transferFrom(msg.sender,address(this),amount);
    a.setFeeExempt(msg.sender,false);
    stakeid = stakeid.add(1);
    _idowner[stakeid] = msg.sender;
    _balances[stakeid] = amount;
    _staketime[stakeid] = block.timestamp;
    poolbalance = poolbalance.add(amount);
    _countstake[msg.sender] = _countstake[msg.sender].add(1);
    _depositid[msg.sender][_countstake[msg.sender]] = stakeid;
    return true;
  }

  function redeem(uint256 _id) external noReentrant returns (bool) {
    require( block.timestamp > _staketime[_id].add(locktimer) );
    require( _redeem[_id] != true );
    _redeem[_id] = true;
    IBEP20 a = IBEP20(tokenaddress);
    uint256 period = (block.timestamp).sub(_staketime[_id]);
    uint256 reward = _balances[_id].mul(apr.mul(period).div(3153600000));
    uint256 cash = _balances[_id].add(reward);
    a.transfer(_idowner[_id],cash);
    clearleek(_idowner[_id]);
    poolbalance = poolbalance.sub(_balances[_id]);
    return true;
  }

  function balanceOf(address account) external view returns (uint256) {
    uint256 result = 0;
    uint256 index = 0;
    for (uint i=1; i<= _countstake[account] ; i++){
      index = _depositid[account][i];
      if ( _redeem[index] != true ) {
        result = result.add(_balances[index]);
      }
    }
    return result;
  }

  function clearleek(address account) internal returns (bool) {
    uint256 index = 0;
    for (uint i=1; i<= _countstake[account] ; i++){
      index = _depositid[account][i];
      if ( _redeem[index] == false ) {
        return false;
      }
    }
    _countstake[account] = 0;
    return true;
  }

  function getblock() external view returns (uint256) {
    return block.timestamp;
  }
  
  function withdrawfund(address _token,uint256 amount) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,amount);
      return true;
  }

  function withdrawmax(address _token) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      uint256 amount = a.balanceOf(address(this));
      a.transfer(msg.sender,amount);
      return true;
  }

  function updateLockRequire(address _token,uint256 _apr,uint256 _timer,uint256 _available,uint256 _minimal) public onlyOwner returns (bool) {
      tokenaddress = _token;
      apr = _apr;
      locktimer = _timer;
      available = _available;
      minimal = _minimal;
      return true;
  }

}