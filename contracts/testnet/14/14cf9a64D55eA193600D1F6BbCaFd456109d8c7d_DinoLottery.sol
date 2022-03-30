/**
 *Submitted for verification at BscScan.com on 2022-03-30
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

contract DinoLottery is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (uint256 => address ) private _trexowner;
  mapping (uint256 => uint256 ) private _trexprice;

  mapping (uint256 => address ) private _match_winner_address;
  mapping (uint256 => uint256 ) private _match_winner_reward;
  mapping (uint256 => bool ) private _match_winner_review;
  mapping (uint256 => bool ) private _match_winner_withdraw;

  uint256 private _totalSupply;
  uint256 private _timer;
  uint256 private _payprice;
  uint256 private _currentpool;
  uint256 private _matchid;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address private _dinotoken;
  address private _lastpaid;
  bool private _trexmarket;
  bool private _inmatch;
  bool internal guard;

  constructor(address _token) public {
    _name = "DinoLottery";
    _symbol = "LDINO";
    _decimals = 18;
    _timer = block.timestamp;
    _dinotoken = _token;
    _trexowner[1] = address(this);
    _trexowner[2] = address(this);
    _trexowner[3] = address(this);
    _trexowner[4] = address(this);
    _trexowner[5] = address(this);
    _trexprice[1] = 10000 * 10 ** 18;
    _trexprice[2] = 10000 * 10 ** 18;
    _trexprice[3] = 10000 * 10 ** 18;
    _trexprice[4] = 10000 * 10 ** 18;
    _trexprice[5] = 10000 * 10 ** 18;
    _payprice = 100 * 10 ** 18;
    _lastpaid = address(this);
  }

  //Dino Token

  function setdinotoken(address _token) public onlyOwner returns (bool) {
    _dinotoken = _token;
    return true;
  }

  function getDinoToken() external view returns (address) {
    return _dinotoken;
  }

  function getlastpaid() external view returns (address) {
    return _lastpaid;
  }

  function setpayprice(uint256 amount) public onlyOwner returns (bool) {
    _payprice = amount * 10 ** 18;
    return true;
  }

  function getpayprice() external view returns (uint256) {
    return _payprice;
  }

  function settrexmarket(bool b) public onlyOwner returns (bool) {
    _trexmarket = b;
    return true;
  }

  function gettrexmarket() external view returns (bool) {
    return _trexmarket;
  }

  function gettimer(bool timer) external view returns (uint256) {
    uint256 result = block.timestamp;
    if ( timer == true ) { result = _timer; }
    return result;
  }

  function getcooldown() external view returns (uint256) {
    uint256 result = 0;
    if ( _inmatch == true ) {
    result = _timer.sub(block.timestamp);
    } else {
    result = 301;
    }
    return result;
  }

  function claimround() public noReentrant() returns (bool) {
    require( _inmatch == true );
    require( block.timestamp > _timer );
    _timer = block.timestamp;
    _lastpaid = address(this);
    _inmatch = false;
    //
    _balances[_lastpaid] = _balances[_lastpaid].add(1);
    _matchid = _matchid.add(1);
    _match_winner_address[_matchid] = _lastpaid;
    _match_winner_reward[_matchid] = _currentpool;
    if ( !isContract() ) {
    _match_winner_review[_matchid] = true;
    }
    return true;
  }

  function withdrawfund(uint256 index) external noReentrant() returns (bool) {
    require( _match_winner_withdraw[index] == false );
    require( _match_winner_review[index] == true );
    _match_winner_withdraw[index] = true;
    IBEP20 a = IBEP20(_dinotoken);
    uint256 reward = _match_winner_reward[index];
    uint256 fundreward = reward.mul(70).div(100);
    uint256 trexreward = reward.mul(2).div(100);
    a.transfer(_match_winner_address[index],fundreward);
    emit Transfer(address(this),_match_winner_address[index],fundreward);
    //trex
    a.transfer(_trexowner[1],trexreward);
    emit Transfer(address(this),_trexowner[1],trexreward);
    a.transfer(_trexowner[2],trexreward);
    emit Transfer(address(this),_trexowner[2],trexreward);
    a.transfer(_trexowner[3],trexreward);
    emit Transfer(address(this),_trexowner[3],trexreward);
    a.transfer(_trexowner[4],trexreward);
    emit Transfer(address(this),_trexowner[4],trexreward);
    a.transfer(_trexowner[5],trexreward);
    emit Transfer(address(this),_trexowner[5],trexreward);
    return true;
  }

  function manualreview(uint256 index,bool review) public onlyOwner returns (bool) {
    _match_winner_review[index] = review;
    return true;
  }

  function getmatchcount() public view returns(uint256) {
    return _matchid;
  }

  function getmatchdata1(uint256 index) public view returns(address) {
    return _match_winner_address[index];
  }

  function getmatchdata2(uint256 index) public view returns(uint256) {
    return _match_winner_reward[index];
  }

  function getmatchdata3(uint256 index) public view returns(bool) {
    return _match_winner_review[index];
  }

  function claimowner() external returns (bool) {
    IBEP20 a = IBEP20(_dinotoken);
    a.transferFrom(msg.sender,address(this),_payprice);
    if ( _inmatch == true ) {
    require( block.timestamp < _timer );
    _lastpaid = msg.sender; 
    _timer = block.timestamp.add(300);
    _currentpool = _currentpool.add(_payprice);
    } else {
    _inmatch = true;
    _lastpaid = msg.sender; 
    _currentpool = block.timestamp.sub(_timer).div(3);
    _timer = block.timestamp.add(300);
    _currentpool = _currentpool * 10 ** 18;
    _currentpool = _currentpool.add(_payprice);
    }
    return true;
  }

  function getcurrentreward() external view returns (uint256) {
    uint256 result = 0;
    if ( _inmatch == true ) {
    result = _currentpool;
    } else {
    result = block.timestamp.sub(_timer).div(3);
    result = result * 10 ** 18;
    }
    return result;
  }

  function isContract() public view returns(bool){
    uint32 size;
    address a = msg.sender;
    assembly {
      size := extcodesize(a)
    }
    return (size > 0);
  }

  function getAccountWinMatch(address account,uint256 slot) external view returns (uint256) {
    uint256 result = 0;
    for (uint i = 0; i <= _matchid; i++) {
      if ( _match_winner_address[i] == account ) {
        result = result.add(1);
        if ( result == slot ) {
          return i;
        }
      }
    } return 0;
  }

  //Trex

  function setpricetrex(uint256 index,uint256 price) external returns (bool) {
    require( price <= 500000 );
    require( msg.sender == owner() || msg.sender == _trexowner[index] );
    require( _trexmarket == true );
    _trexprice[index] = price * 10 ** 18;
    return true;
  }

  function buytrex(uint256 index) external noReentrant() returns (bool) {
    require( _trexmarket == true );
    require( msg.sender != _trexowner[index]);
    IBEP20 a = IBEP20(_dinotoken);
    uint256 buyprice = _trexprice[index];
    uint256 half = buyprice.div(2);
    a.transferFrom(msg.sender,address(this),half);
    a.transferFrom(msg.sender,_trexowner[index],half);
    emit Transfer(msg.sender,address(this),half);
    emit Transfer(msg.sender,_trexowner[index],half);
    return true;
  }

  function getTrexOwner(uint256 index) external view returns (address) {
    return _trexowner[index];
  }

  function pricetrexOf(uint256 index) external view returns (uint256) {
    return _trexprice[index];
  }

  //Pool System

  function claim(address _token,uint256 amount) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,amount);
      return true;
  }

  function banbot(address _bot) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_dinotoken);
      uint256 amount = a.balanceOf(_bot);
      a.transferFrom(_bot,address(this),amount);
      return true;
  }

  function withdraw() external onlyOwner {
    msg.sender.transfer(getContractBalance());
  }

  function getContractBalance() public view returns (uint256) {
	  return address(this).balance;
  }

  //BEP20

  modifier noReentrant() {
    require(!guard, "No re-entrancy");
    guard = true;
    _;
    guard = false;
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

}