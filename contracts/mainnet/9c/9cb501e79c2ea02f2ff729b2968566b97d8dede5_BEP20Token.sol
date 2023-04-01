/**
 *Submitted for verification at BscScan.com on 2023-04-01
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

interface Ixg {
  function getCurrentPrice() external view returns (uint256);        
  function mint(address account, uint256 amount) external returns(bool);        
}

interface IOracle {
  function getCurrentPrice() external view returns (uint256);
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

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  mapping (address => uint256) private userGain;
  mapping (address => uint256) private entry;
  mapping (address => bool) public excluded;  

  uint256 private lastUpdate;   
  uint256 private lastMAUpdate;
  uint256 private gL;
  uint256 private gG;
  uint256 private profit;
  uint256 private loss;
  uint256 private ma;
  uint256 private ma2;
  uint256 private v;
  uint256 private l;
  uint256 private feeC;
  uint256 private feeB;
  uint256 private minBalance;
  uint8 private mintFee;    
  uint8 private profitLimit;
  uint8 private feeA;  
  bool private paused = false;
  bool private um = false;
  bool private locked = false;

  event NewSettings(uint256 l, uint256 v, uint8 pf, uint256 mintFee, uint256 minBalance);
  event ChangeFee(uint8 feeA, uint256 feeB, uint256 feeC); 
  event Update(uint256 timeStamp, uint256 price, uint256 gain, uint256 xgPrice, uint256 ma);
  event Win(address account, uint256 amount);
  event Loss(address account, uint256 amount);
  event PaidFee(address sender, address recipient, uint256 amount);

  IOracle private myOracle;
  Ixg private xgCoin;
 
  address public xgCoinAddr;
  address public gCoinAddr;

  constructor() public {
    _name = "LBTC";
    _symbol = "LBTC";
    _decimals = 18;
    settings(3000, 2, 100, 2, 1e20);
    feeA = 3;
    feeC = 99;
    initContracts(0x74aD2882626a169e97DfC64fA48a87ce410fFCCC, 0x5B496015490cCb97a5aA819AFA6bF54d9e8c5335, 0x5B496015490cCb97a5aA819AFA6bF54d9e8c5335);
    entry[_msgSender()] = 0;
    lastUpdate = now;
    lastMAUpdate = now;
    ma = getCurrentPrice();  
    ma2 = getCurrentPrice();  
    excluded[xgCoinAddr] = true;
    excluded[address(this)] = true;
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
    return getNewBalance(account);
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

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0);
    update();
    calcBalance(sender);
    calcBalance(recipient);
    uint256 _fee;
    if(recipient == xgCoinAddr) {
      _fee = amount * (feeA + mintFee) / 1000;   
      require(amount > _fee);
      uint256 mintAmount = amount - _fee;
      _burnTo(sender, amount, xgCoinAddr);
      emit Transfer(xgCoinAddr, address(0), amount);      
      bool refund = xgCoin.mint(sender, mintAmount);          
      if(refund) {
      	_mint(sender, amount * 99 / 100);
      }
    } else {
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");    
      _balances[recipient] = _balances[recipient].add(amount);
      _fee = amount * feeA / 1000;      
      require(_balances[recipient] > _fee);
      emit Transfer(sender, recipient, amount);      
      _burn(recipient, _fee);
    }
    if(_fee > 0) {
      emit PaidFee(sender, recipient, _fee);
    }
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    if(amount > 0) {
      _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
      _totalSupply = _totalSupply.sub(amount);
       loss = loss.add(amount);
      emit Transfer(account, address(0), amount);
    }
  }
  
  function _burnTo(address account, uint256 amount, address _to) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, _to, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

  function excludeAddr(address account, bool _b) public onlyOwner {
    update();
    updateAccount(account);
    excluded[account] = _b;
    userGain[account] = getGain();
    entry[account] = (feeB == 0) ? 0 : now;    
  }

  function emergencyStop(bool _p) public onlyOwner {
    paused = _p;
  }

  function setFees(uint8 _feeA, uint256 _feeB, uint256 _feeC) external onlyOwner {
    require(_feeA <= 100);
    require(_feeB <= 1e16);
    require(_feeC < 2000);
    feeA = _feeA;
    feeB = _feeB;
    feeC = _feeC;
    emit ChangeFee(_feeA, _feeB, _feeC);
  }

  function settings(uint256 _l, uint256 _v, uint8 _profitLimit, uint8 _mintFee, uint256 _minBalance) public onlyOwner {
    require(_l > 0);
    require(_v > 0);
    require(_mintFee <= 100 && _mintFee > 0);
    require(_profitLimit >= 10 && _profitLimit < 10000);      
    l = _l * 1e10;
    v = _v;
    profitLimit = _profitLimit;
    mintFee = _mintFee;
    minBalance = _minBalance;
    emit NewSettings(_l, _v, _profitLimit, _mintFee, _minBalance);
  }

  function getMA() public view returns (uint256) {
    uint256 _timePassed = getTimePassed(lastMAUpdate);
    return (ma * 5184000 + _timePassed * getCurrentPrice()) / (5184000 + _timePassed);
  }

  function getMA2() public view returns (uint256) {
    uint256 _timePassed = getTimePassed(lastMAUpdate);
    return (ma2 * 86400000 + _timePassed * getCurrentPrice()) / (86400000 + _timePassed);
  }

  function getTimePassed(uint256 _time) internal view returns (uint256) {
    uint256 _now = now;
    if(_time > _now) return 0;
    return _now - _time;
  }

  function getFee(address account) internal view returns (uint256) {
    if(excluded[account] || userGain[account] == 0 || entry[account] == 0 || (aboveMinBalance(account) && feeB % 2 == 0) ) return 0;
    return getTimePassed(entry[account]) * feeB;
  }

  function initContracts(address a1, address a2, address a3) public onlyOwner {
    myOracle = IOracle(a1);
    gCoinAddr = a2;
    xgCoinAddr = a3;
    xgCoin = Ixg(xgCoinAddr);
  }

  function currentBalance(address account) external view returns (uint256) {
    return _balances[account];
  }

  function aboveMinBalance(address account) public view returns (bool) {
    return (IBEP20(gCoinAddr).balanceOf(account) > minBalance);
  }

  function getCurrentPrice() public view returns (uint256) {
    return myOracle.getCurrentPrice() * 10000000;
  }

  function getNewBalance(address account) internal view returns (uint256) {
    if(userGain[account] == 0 || excluded[account] || paused) return _balances[account];
    uint256 b = _balances[account] * getGain() / userGain[account];
    uint256 _fee = b * getFee(account) / 1e22;
    if(_fee > b) _fee = b / 2;
    return b - _fee;
  }

  function getGain() internal view returns (uint256) {
    uint256 c = getCurrentPrice();
    uint256 _ma = getMA();
    uint256 p = (((c / 1e10) ** v) / ((_ma / 1e10) ** (v - 1)) * 1e10 + 4 * c) / 5;
    if(p < c) p = (c * 4 + p) / 5;
    uint256 _gL = gL.add(nextDecrease());
    uint256 _gG = gG.add(nextIncrease());
    return p * (1e20 + ((_gG > _gL) ? _gG - _gL : 0)) / (1e20 + ((_gL > _gG) ? _gL - _gG : 0));
  }

  function nextDecrease() internal view returns (uint256) {
    uint256 c = getCurrentPrice();
    uint256 _ma = getMA();
    if(c > _ma || lastUpdate > now) return 0;
    return (_ma - c) * getTimePassed(lastUpdate) * l * feeC / (c * 100);
  }

  function nextIncrease() internal view returns (uint256) {
    uint256 c = getCurrentPrice();
    uint256 _ma = getMA();
    if(_ma > c || lastUpdate > now || !um) return 0;    
    uint256 temp = c - _ma;
    if(temp > c / 4) temp = c / 4;
    return temp * getTimePassed(lastUpdate) * l / c;
  }

  function update() public {
    uint256 c = getCurrentPrice();
    if(c > getMA()) {
      gG = gG.add(nextIncrease());
      um = true;
    } else {
      gL = gL.add(nextDecrease());
      um = false;
    }
    if(now > (lastMAUpdate + 86400) ) {
      ma = getMA();
      ma2 = getMA2();
      lastMAUpdate = now;
    }
    lastUpdate = now;
    uint256 gxPrice = xgCoin.getCurrentPrice();
    emit Update(lastUpdate, c, getGain(), gxPrice, getMA());
  }
     
  function mint(address account, uint256 amount) public {
    require(amount > 0);
    require(msg.sender == xgCoinAddr);
    updateAccount(account);
    uint256 _fee = amount * (feeA + mintFee) / 1000;
    require(amount > _fee);
    _mint(account, amount - _fee);
    emit PaidFee(xgCoinAddr, account, _fee);
  }

  function updateAccounts(address[] calldata accounts) external {
    update();
    for(uint256 i = 0; i < accounts.length; i++) calcBalance(accounts[i]);
  }

  function updateAccount(address account) public {
    update();
    calcBalance(account);
  }

  function calcBalance(address account) internal {
    if(excluded[account]) return;
    uint256 newBalance = getNewBalance(account);
    if(newBalance > _balances[account]) {
      uint256 diff = newBalance - _balances[account];
      _totalSupply = _totalSupply.add(diff);
      profit = profit.add(diff);
      emit Win(account, diff);          
    } else if(newBalance < _balances[account] ) {
      uint256 diff = _balances[account] - newBalance;
      _totalSupply = _totalSupply.sub(diff);
      loss = loss.add(diff);
      emit Loss(account, diff);
    }
    userGain[account] = getGain();
    entry[account] = (feeB == 0) ? 0 : now;
    if(!paused && ((profit + 1e23) > (loss + 1e23) * profitLimit / 10)) {
      paused = true;        
    } else {
      _balances[account] = newBalance;
    }      
  }

  function getTransferFee() external view returns (uint256) {
    return feeA;
  }

  function getMintFee() external view returns (uint256) {
    return mintFee;
  }

  function getUser(address _a) external view returns (uint256[5] memory) {
    uint256 b = (userGain[_a] > 0) ? _balances[_a] * getGain() / userGain[_a] : 0;
    return [getNewBalance(_a), _balances[_a], userGain[_a], excluded[_a] ? 1 : 0, b * getFee(_a) / 1e22];
  }

  function getGlobals() external view returns (uint256[9] memory) {
    return [getCurrentPrice(), getGain(), gL, gG, nextDecrease(), nextIncrease(), profit, loss, xgCoin.getCurrentPrice()];
  }

}