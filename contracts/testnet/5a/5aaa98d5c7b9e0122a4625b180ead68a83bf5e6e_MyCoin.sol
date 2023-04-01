/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-01
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
    uint256 private lastUpdate;   
    uint256 private gL;
    uint256 private gG;
    uint256 private profit;
    uint256 private loss;
    uint256 private ma;
    uint256 private ma2;
    uint256 private lastMAUpdate;
    uint256 private profitLimit;
    uint256 private v;
    uint256 private l;
    uint256 private N;
    uint256 private C = 16000000000000000000000;   
    uint256 private minPrice;
    uint256 private feeC;
    uint256 private feeB;
    uint8 private feeA;  
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    bool private paused = false;
    bool private um = false;

    event UpdatePrice(uint256 timestamp, uint256 price);
    event NewSettings(uint256 l, uint256 v, uint256 mp);
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
      settings(60000000000000, 2, 1e20);
      setFees(5, 0, 80);
      initContracts(0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B, 0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B, 0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B);
      uint256 startTime = now;
      entry[_msgSender()] = 0;
      lastUpdate = startTime;
      lastMAUpdate = startTime;
      N = startTime;
      ma = 1;
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

    function excludeAddr(address account, bool _b) public onlyOwner {
      updateAccount(account);
      excluded[account] = _b;
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

    function settings(uint256 _l, uint256 _v, uint256 _mp) public onlyOwner {
      require(_l > 0);
      require(_v > 0);
      require(_mp > 0);

      l = _l;
      v = _v;
      minPrice = _mp;
      emit NewSettings(_l, _v, _mp);
    }

    function getMA() internal view returns (uint256) {
      uint256 _timePassed = getTimePassed(lastMAUpdate);
      return (ma * 102594870 + _timePassed * getCurrentPrice()) / (102594870 + _timePassed);
    }

    function getMA2() internal view returns (uint256) {
      uint256 _timePassed = getTimePassed(lastMAUpdate);
      return (ma2 * 5259487 + _timePassed * getCurrentPrice()) / (5259487 + _timePassed);
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

    function getGain() internal view returns (uint256) {
      uint256 _gL = gL.add(nextDecrease());
      uint256 _gG = gG.add(nextIncrease());
      uint256 c = getCurrentPrice();
      uint256 p = (((c / 1e10) ** 2) / (getMA2() / 1e10) * 1e10 + c) / 2;
      if(p > c * 11 / 10) p = c * 11 / 10;
      if(p < c * 7 / 10 ) p = c * 7 / 10;
      uint256 g = getMA().add(p).add(minPrice);
      uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
      g = g * (1e20 + ((_gG > _gL) ? _gG - _gL : 0) ) / (1e20 + ((_gL > _gG) ? _gL - _gG : 0));
      return MAX_INT / g;
    }

    function nextDecrease() internal view returns (uint256) {
      uint256 c = getCurrentPrice();
      uint256 _ma = getMA2();
      if(c > _ma || lastUpdate > getNow() || um) return 0;
      return (_ma - c) * getTimePassed(lastUpdate) * l * feeC / (c * 100);
    }

    function nextIncrease() internal view returns (uint256) {
      uint256 c = getCurrentPrice();
      uint256 _ma = getMA2();
      if(_ma > c || lastUpdate > getNow()) return 0;
      return (c - _ma) * getTimePassed(lastUpdate) * l / c;
    }

    function reset(uint256 newTime, uint256 newPrice) onlyOwner public {
      lastUpdate = newTime;
      lastMAUpdate = newTime;
      N = newTime;
      C = newPrice;
      ma = newPrice;
      ma2 = newPrice;
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

      uint256 c = getCurrentPrice();

      if(c > getMA()) {
        gG = gG.add(nextIncrease());
        um = true;
      } else {
        gL = gL.add(nextDecrease());
        um = false;
      }
      
      if(getNow() > (lastMAUpdate + 86400) ) {
        ma = getMA();
        ma2 = getMA();
        lastMAUpdate = getNow();
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
      if(!excluded[account]) return;
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
      userGain[account] = getGain();
      entry[account] = (feeB == 0) ? 0 : getNow();

      if(!paused && ((profit + 1e22) > (loss + 1e22) * profitLimit / 10)) {
        paused = true;
      } else {
        _balances[account] = newBalance;
      }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
      require(!paused);
      update();
      
      calcBalance(sender);
      calcBalance(recipient);

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
         loss = loss.add(amount);
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

    function getGlobals() external view returns (uint256[13] memory) {
      return [getCurrentPrice(), getGain(), gL, gG, nextDecrease(), nextIncrease(), getNow(), profit, loss, lastUpdate, lastMAUpdate, getMA(), getMA2()];
    }

  }