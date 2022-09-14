/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;
interface SWAP{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
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
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

contract BEP20Cardano is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  IBEP20 public tokenu;

  mapping (address => uint256) private _balances;
  mapping (address => bool) private _whiteaddress;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  address public usdtacc = address(0x55d398326f99059fF775485246999027B3197955);
  address public tokenacc = address(this);
  address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public hdacc = 0x000000000000000000000000000000000000dEaD;
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;

  address public szacc=0xf890DeB81AD1338816939569D1500ee5a3ba7bDB;
  address public yyacc=0xfDaeA4D695cb4c54B2e5c23403651b40048Ce762;
  address public yxacc=0x1Fc209e3fbb07EAAE14Ab55E0c00A8B8D4C2547C;
  address public teamacc=0x2023B304c818d578a5713b46293bd2Fd7b759941;
  address public feeacc=0x25af1b7A0710b541067191D5Df70Ea48447AaA28;
  address public mainacc=0x82d545C4F563a1c25328Ac159804AD8402E6146b;

  constructor() public {
    _name = "BTCS TOKEN";
    _symbol = "BTCS";
    _decimals = 18;
    _totalSupply = 21000000 * 10**18;
    _balances[mainacc] = _totalSupply;

    _whiteaddress[msg.sender]=true;
    _whiteaddress[mainacc]=true;
    _whiteaddress[tokenacc]=true;

    emit Transfer(address(0), mainacc, _totalSupply);
    lpacc = IUniswapV2Factory(factory).createPair(tokenacc,usdtacc);
  }

  function buysl(address pacc,uint256 amount)public returns(bool){
     tokenu = IBEP20(usdtacc);
     tokenu.transferFrom(msg.sender,pacc,amount.mul(45).div(100));
     tokenu.transferFrom(msg.sender,tokenacc,amount.mul(45).div(100));
     tokenu.transferFrom(msg.sender,szacc,amount.mul(5).div(100));
     tokenu.transferFrom(msg.sender,yyacc,amount.mul(3).div(100));
     tokenu.transferFrom(msg.sender,teamacc,amount.mul(2).div(100));

     autosell(amount.mul(45).div(100));
     return true;
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
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

     if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true){
       _tokenTransfer(sender,recipient,amount);
    }else if(sender==lpacc){//买入
       require(sender != lpacc, "BEP20: transfer from the zero address");
    }else if(recipient==lpacc){//卖出
       _tokenTransfer(sender,yxacc,amount.mul(5).div(100));
       _tokenTransfer(sender,recipient,amount.mul(95).div(100));
    }else{
      _tokenTransfer(sender,recipient,amount.mul(100).div(100));
    }
  }
  function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
  function addwhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = true;
  }
  function removewhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = false;
  }
  //授权
   function safeapprove()public onlyOwner{
        IBEP20(usdtacc).approve(mainrouter,50*10**30);
   }
  function setmainrouter(address mainrouter_,address tokenacc_,address usdtacc_)public onlyOwner{
     mainrouter = mainrouter_;
     tokenacc = tokenacc_;
     usdtacc = usdtacc_;
  }
  function autosell(uint256 amount)public returns(bool){
      address[] memory path = new address[](2);
      path[0]=usdtacc;
      path[1]=tokenacc;

      SWAP(mainrouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
        amount,
        0,
        path,
        hdacc,
        3280730638
      );
      return true;
  }
  function drawusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transfer(to,amount);
  }
  function drawtokenusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transferFrom(tokenacc,to,amount);
  }
}