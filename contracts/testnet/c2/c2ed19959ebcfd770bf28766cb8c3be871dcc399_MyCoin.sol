/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

pragma solidity 0.5.16;

interface IMyCoin {
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

contract MyCoin is Context, IMyCoin, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private entryPrice;
  mapping (address => uint256) private _balances;
  mapping (address => bool) private excluded;  
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 public mintedProfits;
  uint256 public burnedTokens;

  uint8 public _decimals;
  uint8 public leverage = 2;
  string public _symbol;
  string public _name;
  IOracle private myOracle;
  address[] public path;
  bool private paused = true;

  uint256 constant internal MAGNITUDE = 2 ** 64;


  constructor() public {
    _name = "MyCoin";
    _symbol = "COIN";
    _decimals = 18;
    _totalSupply = 1000000 * (10 ** 18);
    _balances[msg.sender] = _totalSupply;
    excluded[msg.sender] = true;
    setOracle(0xb90b3521579a407F4863B1D07dEE5C0685729D78);
    emit Transfer(address(0), msg.sender, _totalSupply);
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
  }

  function removeLeverage(bool setting) public onlyOwner {
     paused = setting;
  }

  function setOracle(address setting) public onlyOwner {
     myOracle = IOracle(setting);
  }

  function setLeverage(uint8 setting) public onlyOwner {
    require (setting > 0);
    leverage = setting;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    uint256 r;
    if(!excluded[account]) {
      uint256 loss = getLoss(account);
      uint256 profit = getProfit(account);
      r = (loss > (_balances[account] + profit)) ? 0 : (_balances[account] + profit - loss);
    } else {
      r =  _balances[account];
    }
    return r;
  }

  function currentBalance(address account) external view returns (uint256) {
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

  function getCurrentPrice() public view returns (uint256) {
    return myOracle.getCurrentPrice();
  }

  function getLoss(address account) public view returns (uint256) {
    uint256 currentPrice = getCurrentPrice();
    uint256 loss;
    if(entryPrice[account] > currentPrice) {
     uint256 priceDiff = entryPrice[account] - currentPrice;
     loss = _balances[account] * (leverage - 1) * priceDiff / (priceDiff * leverage + currentPrice);

    } 
    return loss;
  }

  function getProfit(address account) public view returns (uint256) {
    uint256 currentPrice = getCurrentPrice();
    uint256 profit;
    if(currentPrice > entryPrice[account]) {
      profit = _balances[account] * (leverage -  entryPrice[account] * (leverage- 1) / currentPrice);
    } 
    return profit;
  }

  function calcBalance(address account) public {
    uint256 loss = getLoss(account);
    uint256 profit = getProfit(account);

    if(profit > 0) {
      _mint(account, profit);
      mintedProfits = mintedProfits.add(profit);
    }

    if(loss > _balances[account]) {
	    _balances[account] = 0;
	    entryPrice[account] = 0;
    } else { 
	    entryPrice[account] = getCurrentPrice();
	    _burn(account, loss);
    }

  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    
    if(!paused) {
      if(!excluded[sender]) {
        calcBalance(sender);
      }

      if(!excluded[recipient]) {
        calcBalance(recipient);
      }
    }
   _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
	  _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }
  
  function destroy(uint256 amount) external {
    address account = _msgSender();
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    burnedTokens = burnedTokens.add(amount);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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

}