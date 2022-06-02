/**
 *Submitted for verification at BscScan.com on 2022-06-02
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
  address private _authorize;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    _authorize = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender() || _authorize == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  modifier authorize() {
    require(_authorize == _msgSender());
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

contract MoonBirdPresale is Context, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public _balances;
  mapping (address => uint256) public _unclaimtoken;
  mapping (address => bool) public _isRegister;
  mapping (address => bool) public _isWhitlist;

  mapping (uint256 => address) public _getBuyer;

  address public busd;
  address public saletoken;
  address public recaiveAddress;

  uint256 public pricepertoken;
  uint256 public minbuy;
  uint256 public maxsold;
  uint256 public maxhold;
  uint256 public starttimer;
  uint256 public endtimer;

  uint256 public soldout;
  uint256 public contributors;

  bool public finalize;
  bool private _reentrant;
  bool private _seedround;

  constructor(bool _seed,address _token,address _busd,uint256 _price,uint256 _minbuy,uint256 _maxsold,uint256 _maxhold,address _recaiver) public {
      saletoken = _token;
      //APEX TOKEN PRESALE
      busd = _busd;
      //BUSD REQUIRE
      pricepertoken = _price;
      //ROUND1 : 0.1$ ROUND2 : 0.2$
      minbuy = _minbuy;
      //ROUND1 Min 50$ ROUND2 UNLIMIT
      maxsold = _maxsold;
      //ROUND1 7.5m ROUND2 5.0m
      maxhold = _maxhold;
      //ROUND1 Max 5000$ ROUND2 UNLIMIT
      recaiveAddress = _recaiver;
      _seedround = _seed;
      //ROUND1 REQUIRE ROUND2 NO REQUIRE
  }

  modifier noReentrant() {
    require(!_reentrant, "No re-entrancy");
    _reentrant = true;
    _;
    _reentrant = false;
  }

  function balancesOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function getblock() external view returns (uint256) {
    return block.timestamp;
  }

  function getContractBNB() public view returns (uint256) {
	return address(this).balance;
  }

  function getBlock() public view returns (uint256) {
	return block.timestamp;
  }

  function withdraw() external authorize {
    msg.sender.transfer(getContractBNB());
  }

  function settime(uint256 _timerA,uint256 _timerB) public onlyOwner returns (bool) {
    starttimer = _timerA;
    endtimer = _timerB;
    return true;
  }

  function whitelist(address[] memory accounts) public onlyOwner returns (bool) {
    for(uint i = 0; i< accounts.length; i++){
      _isWhitlist[accounts[i]] = true;
    }
    return true;
  }

  function delist(address[] memory accounts) public onlyOwner returns (bool) {
    for(uint i = 0; i< accounts.length; i++){
      _isWhitlist[accounts[i]] = false;
    }
    return true;
  }

  function distribution() public onlyOwner returns (bool) {
    require(finalize==false);
    IBEP20 a = IBEP20(saletoken);
    for (uint i = 1; i <= contributors; i++) {
        uint256 spendertoken = _unclaimtoken[_getBuyer[i]].mul(10**18);
        a.transfer(_getBuyer[i],spendertoken);
        _unclaimtoken[_getBuyer[i]] = 0;
    }
    a.transfer(address(0xdead),a.balanceOf(address(this)));
    IBEP20 b = IBEP20(busd);
    b.transfer(recaiveAddress,b.balanceOf(address(this)));
    finalize = true;
    return true;
  }

  function buy(uint256 amount) external noReentrant returns (bool) {
      require(finalize==false);
      if (_seedround) { require(_isWhitlist[msg.sender]); }
      require(amount>=minbuy);
      require(block.timestamp>=starttimer);
      require(block.timestamp<=endtimer);
      uint256 tokenbought = amount.div(pricepertoken);
      require(_unclaimtoken[msg.sender].add(tokenbought)<=maxhold);
      require(soldout.add(tokenbought)<=maxsold);
      if (!_isRegister[msg.sender]) {
          _isRegister[msg.sender] = true;
          contributors = contributors.add(1);
          _getBuyer[contributors] = msg.sender;
      }
      IBEP20 a = IBEP20(busd);
      a.transferFrom(msg.sender,address(this),amount);
      _balances[msg.sender] = _balances[msg.sender].add(amount);
      _unclaimtoken[msg.sender] = _unclaimtoken[msg.sender].add(tokenbought);
      soldout = soldout.add(tokenbought);
      return true;
  }

  function EmergencyWithdraw(address _token,uint256 amount) public onlyOwner returns (bool) {
      require(finalize==true);
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,amount);
      return true;
  }
}