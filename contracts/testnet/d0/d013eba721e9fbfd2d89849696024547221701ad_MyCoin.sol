/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

pragma solidity 0.5.16;

  interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
  }

  interface Ig {
    function inDAO(address a) external view returns (bool);
  }

  interface IOracle {
    function getCurrentPrice() external view returns (uint256);
  }


  contract Context {
    constructor () internal { 
    }

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

  contract MyCoin is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) public userGain;
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private entry;
    mapping (address => bool) public excluded;  
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private timeStamp;
    uint256 private lastUpdate;   
    uint256 private gL;
    uint256 private gG;
    uint256 private profit;
    uint256 private loss;
    uint256 private w;
    uint256 private v;
    uint256 private m;
    uint256 private l;
    uint256 private N;
    uint256 private C = 16000000000000000000000;   
    uint256 private prevPrice = C;
    uint256 private feeC;
    uint256 private feeB;
    uint8 private feeA;  
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    bool private paused = false;

    event UpdatePrice(uint256 timestamp, uint256 price);
    event NewSettings(uint256 l, uint256 w, uint256 v, uint256 m);
    event ChangeFee(uint8 feeA, uint256 feeB, uint256 feeC); 
    event Update(uint256 timeStamp, uint256 price, uint256 gain, uint256 gL, uint256 gG);

    Ig private gCoin;
    IBEP20 private xgCoin;
    IOracle private myOracle;
    
    constructor() public {
      _name = "MyCoin";
      _symbol = "COIN";
      _decimals = 18;
      _totalSupply = 1e23;
      _balances[_msgSender()] = _totalSupply;
      settings(1e10, 20000, 5, 10);
      setFees(5, 0, 1000);
      initContracts(0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B, 0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B, 0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B);
      uint256 startTime = now;
      entry[_msgSender()] = 0;
      timeStamp = startTime;
      lastUpdate = startTime;
      N = startTime;
      excluded[address(this)] = true;
      excluded[_msgSender()] = true;
      emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function excludeAddr(address account, bool setting) public onlyOwner {
      excluded[account] = setting;
      updateAccount(account);
    }

    function emergencyStop(bool _p) public onlyOwner {
      paused = _p;
    }

    function setFees(uint8 _feeA, uint256 _feeB, uint256 _feeC) public onlyOwner {
      require(_feeA <= 100);
      feeA = _feeA;
      feeB = _feeB;
      feeC = _feeC;
      emit ChangeFee(_feeA, _feeB, _feeC);
    }

    function settings(uint256 _l, uint256 _w, uint256 _v, uint256 _m) public onlyOwner {
      require(_l > 1000);
      require(_w > 1000);
      l = _l;
      w = _w;
      v = _v;
      m = _m;
      emit NewSettings(_l, _w, _v, _m);
    }

    function getTimePassed(uint256 _time) internal view returns (uint256) {
      uint256 _now = getNow();
      if(_time > _now) return 0;
      return _now - _time;
    }

    function totalSupply() external view returns (uint256) {
      return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
      return getNewBalance(account);
    }
    
    function getFee(address account) internal view returns (uint256) {
      if(excluded[account] || userGain[account] == 0 || entry[account] == 0 || inDao(account)) return 0;
      return getTimePassed(entry[account]) * feeB;
    }

    function initContracts(address a1, address a2, address a3) public onlyOwner {
      myOracle = IOracle(a1);
      gCoin = Ig(a2);
      xgCoin = IBEP20(a3);
    }

    function currentBalance(address account) external view returns (uint256) {
      return _balances[account];
    }

    function inDao(address account) public view returns (bool) {
      //return gCoin.inDAO(account);
      return false;
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
      if(recipient != address(xgCoin)) {
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
      }
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

    function getNow() public view returns (uint256) {
      return N;
    }

    function getCurrentPrice() public view returns (uint256) {
      //return myOracle.getCurrentPrice() * 10000000000;
      return C;
    }

    function getNewBalance(address account) internal view returns (uint256) {
      if(userGain[account] == 0 || excluded[account] || paused) return _balances[account];
      uint256 b = _balances[account] * getGain() / userGain[account];
      uint256 _fee = b * getFee(account) / 1e22;
      if(_fee > b) _fee = b / 2;
      return b - _fee;
    }

    function getVars() internal view returns (uint256, uint256, uint256) {
      uint256 c = getCurrentPrice();
      uint256 x = c * m / prevPrice;
      uint256 s = x * getTimePassed(timeStamp) * w / 1e12;
      uint256 r = x - s;
      if(s > x || r < c) r = c;
      else if(r > c * 20) r = c * 20;
      return (r * 80 / 100, c, r);
    }

    function getGain() internal view returns (uint256) {
      (uint256 R, uint256 c,) = getVars();
      uint256 g = (c * v + R) / (v + 1);
      uint256 _gL = gL + nextDecrease(R);
      uint256 _gG = gG + nextIncrease(R);
      uint256 diffA = (_gG > _gL) ? _gG - _gL : 0;
      uint256 diffB = (_gL > _gG) ? _gL - _gG : 0;
      return g * (1e20 + diffA) / (1e20 + diffB);
    }

    function nextDecrease(uint256 R) internal view returns (uint256) {
      uint256 c = getCurrentPrice();
      if(R > c || lastUpdate > now) return 0;
      uint256 diffA = (gG > gL) ? gG - gL : 0;
      uint256 diffB = (gL > gG) ? gL - gG : 0;
      uint256 temp = c - R; 
      if(temp > c / 5) temp = c / 5;
      uint256 d = temp * feeC * getTimePassed(lastUpdate) * l / (1000 * c);
      if(feeC % 2 == 0) d = d * (1e20 + diffA) / (1e20 + diffB);
      if(gG == 0) return d / 100;
      return d;
    }

    function nextIncrease(uint256 R) internal view returns (uint256) {
      uint256 c = getCurrentPrice();
      if(c > R || lastUpdate > getNow()) return 0;
      uint256 temp = (R - c);
      if(temp > c / 5) temp = c / 5;      
      return temp * getTimePassed(lastUpdate) * l / c;
    }

    function reset(uint256 newTime, uint256 newPrice) onlyOwner public {
      timeStamp = newTime;
      lastUpdate = newTime;
      N = newTime;
      C = newPrice;
      prevPrice = newPrice;
      gL = 0;
      gG = 0;
    }

    function setPrice(uint256 newTime, uint256 newPrice) public onlyOwner {
      N = newTime;
      C = newPrice;   
      update();   
    }

    function increaseTime(uint256 newTime) public onlyOwner {
      N += newTime;
    }

    function update() public {
      (uint256 R, uint256 c, uint256 r) = getVars();

      if(r == c) {
        prevPrice = c;
        timeStamp = getNow();
        emit UpdatePrice(timeStamp, prevPrice);        
      }

      if(R > c) {
        gG = gG.add(nextIncrease(R));
      } else {
        gL = gL.add(nextDecrease(R));
      }

      lastUpdate = getNow();
      
      emit Update(lastUpdate, c, getGain(), gL, gG);
    }

    function mint(uint256 _amount) public {
      require(_amount > 0);
      updateAccount(_msgSender());
      uint256 balanceBefore = xgCoin.balanceOf(address(this));
      xgCoin.transferFrom(_msgSender(), address(this), _amount);
      uint256 balanceAfter = xgCoin.balanceOf(address(this));
      uint256 diff = balanceAfter.sub(balanceBefore);
      require(diff > 0); 
      uint256 amount2 = diff * (1000 - getAccountFee(_msgSender())) / 1000;
      _mint(_msgSender(), amount2);
      xgCoin.burn(balanceAfter);
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
      uint256 newBalance = getNewBalance(account);
      if(newBalance > _balances[account]) {
        uint256 diff = newBalance - _balances[account];
        _totalSupply = _totalSupply.add(diff);
        profit = profit.add(diff);
        emit Transfer(address(0), account, diff);          
      } else if(newBalance < _balances[account] ) {
        uint256 diff = _balances[account] - newBalance;
        _totalSupply = _totalSupply.sub(diff);
        loss = loss.add(diff);
        emit Transfer(account, address(0), diff);  
      }
      _balances[account] = newBalance;
      userGain[account] = getGain();
      entry[account] = (feeB == 0) ? 0 : getNow();
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
      require(!paused);
      update();

      if(!excluded[sender]) {
        calcBalance(sender);
      }

      if(!excluded[recipient]) {
        calcBalance(recipient);
      }
      
      uint256 _fee = amount * getAccountFee(recipient) / 1000;
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);

      if(!excluded[recipient]) {
        require(_balances[recipient] > _fee);
        _burn(recipient, _fee);
      }
      
      emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
      require(account != address(0), "BEP20: burn from the zero address");
      if(amount > 0) {
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
      }
    }

    function burn(uint256 amount) public returns (bool) {
      _burn(_msgSender(), amount);
      return true;
    }

    function _mint(address account, uint256 amount) internal {
      require(account != address(0), "BEP20: mint to the zero address");
      _totalSupply = _totalSupply.add(amount);
      _balances[account] = _balances[account].add(amount);
      emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }

    function getTransferFee() external view returns (uint256) {
      return feeA;
    }

    function getAccountFee(address account) public view returns (uint256) {
      if(inDao(account)) return feeA * 2 / 3;
      return feeA;
    }

    function getUser(address _a) external view returns (uint256[6] memory) {
      uint256 b = _balances[_a] * getGain() / userGain[_a];
      return [_balances[_a], userGain[_a], excluded[_a] ? 1 : 0, b * getFee(_a) / 1e22, getAccountFee(_a), b];
    }

    function getGlobals() external view returns (uint256[14] memory) {
      (uint256 R, uint256 c, uint256 r) = getVars();
      return [c, R, r, getGain(), prevPrice, gL, gG, nextDecrease(R), nextIncrease(R), getNow(), profit, loss, timeStamp, lastUpdate];
    }

  }