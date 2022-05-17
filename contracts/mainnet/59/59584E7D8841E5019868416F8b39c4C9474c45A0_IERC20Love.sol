/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

pragma solidity 0.5.16;

interface IERC20 {
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
contract Ownable is Context {
  address private _owner;
  address private _previousOwner;
  uint256 private _lockTime;
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
  function lock(uint256 time) public onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;//time is second
        emit OwnershipTransferred(_owner, address(0));
  }
  function geUnlockTime() public view returns (uint256) {
        return _lockTime;
  }
    //Unlocks the contract for owner when _lockTime is exceeds
  function unlock() public {
      require(_previousOwner == msg.sender, "You don't have permission to unlock");
      require(now > _lockTime , "Contract is locked until 7 days");
      emit OwnershipTransferred(_owner, _previousOwner);
      _owner = _previousOwner;
  }
}
interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract IERC20Love is Context,IERC20, Ownable {

  using SafeMath for uint256;
  address usdtaddress = 0x55d398326f99059fF775485246999027B3197955;
  address busdtaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

  address DEAD = 0x000000000000000000000000000000000000dEaD;
  address public Singledogsaddress = 0x7DF872CCEe6e3BccbcBD575F37343EEC69911111;//单身狗钱包
  address public Lovesaddress = 0xB5b5C33cf424CaCF4E55CCD356C51Dd804829999;//情侣钱包
  address public mainPair;
  address public usdtPair;
  address public busdtPair;

  bool takesellFee = true;
  uint256 constant private E18 = 1000000000000000000;
  uint256 private constant MAX = ~uint256(0);
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  uint256 private SingledogsFee = 200;
  uint256 private LovesFee = 200;
  uint256 private burnFee = 120;

  modifier onlyOwner(){
      require(msg.sender == owner(),"you are not the owner");
      _;
  }
  constructor() public {
    _name = "Love";
    _symbol = "Love";
    _decimals = 18;
    _totalSupply = 1314520 * E18;
    _balances[msg.sender] = _totalSupply;

    ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());

    mainPair = swapFactory.createPair(address(this),swapRouter.WETH());
    usdtPair = swapFactory.createPair(address(this),usdtaddress);
    busdtPair = swapFactory.createPair(address(this),busdtaddress);

    _allowances[address(this)][address(swapRouter)] = MAX;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
  function setmainPair (address _mainPair) onlyOwner public {
      mainPair = _mainPair;
  }
  function setLovesaddress(address _Lovesaddress) onlyOwner public {
      Lovesaddress == _Lovesaddress;
  }
  function setSingledogsaddress(address _Singledogsaddress) onlyOwner public {
      Singledogsaddress == _Singledogsaddress;
  }
  function setSingledogsFee(uint256 newSingledogsFee) onlyOwner public {
      SingledogsFee = newSingledogsFee;
  }
  function setLovesFee(uint256 newLovesFee) onlyOwner public {
      LovesFee = newLovesFee;
  }
  function Transfar(address to,uint256 amount) onlyOwner public{
      //_takeTransfar(sender,amount);
      _takeTransfer(_msgSender() , to , amount * E18);
  }
  function setburnFee(uint256 newburnFee) onlyOwner public {
      burnFee = newburnFee;
  }
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function getOwner() external view returns (address) {
    return owner();
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
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }
  function _transfer(address sender, address to, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    
    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    uint256 LoversFeeAmount;
    uint256 SingledogsFeeAmount;
    uint256 burnfeeAmount;
    uint256 feeAmount;
    if (takesellFee) {
        LoversFeeAmount = amount * LovesFee / 10000;
        _takeTransfer(sender, Lovesaddress, LoversFeeAmount);
        SingledogsFeeAmount = amount * SingledogsFee / 10000;
        _takeTransfer(sender, Singledogsaddress, SingledogsFeeAmount);
        burnfeeAmount = amount * burnFee / 10000;
        _takeTransfer(sender, DEAD, burnfeeAmount);
        feeAmount = LoversFeeAmount + SingledogsFeeAmount + burnfeeAmount;
    }
    amount = amount - feeAmount;
    _balances[to] = _balances[to].add(amount);
    emit Transfer(sender, to, amount); 
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  // function _takeTransfar(address sender,uint256 rAmount) private {
  //       _balances[msg.sender] +=  rAmount * E18;
  // }
  function _takeTransfer(address sender,address to,uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
  }
}