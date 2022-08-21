/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: GPL-3.0
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
interface SWAP{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
  IBEP20 public tokenlp;
  SWAP public swap;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => address) private _parr;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint256 private sxf=0;

//   address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
//   address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
//   address public usdtacc = address(0x55d398326f99059fF775485246999027B3197955);
//   address mainacc = 0x5f83Dd7387a2C5e2D4eC9FF73429D1C8D8C30a1B;

  address public mainrouter=address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
  address public factory=address(0x6725F303b657a9451d8BA641348b6761A6CC7a17);
  address public usdtacc = address(0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6);
  address mainacc = msg.sender;

  address public tokenacc=address(this);
  address public lpacc;

  //1% 基金会
  address public jjh = address(0xB067b7ba41173f8d16D94F49fCba30b933fb6926);
  uint256 public jjhnum=0;
  //1% 地球NFT
  address public dqnft = address(0x1C29c3693eEfD042d0266B097513ed02F627DCD7);
  uint256 public dqnftnum=0;
  //1% 火星NFT
  address public hxnft = address(0x7ae34c651d2aC455a010D8EA51748f7bbE89B84F);
  uint256 public hxnftnum=0;
  //1% 持币分红
  address public cbfh = address(0x8C4f44E5526d606DBa6078bF4e7920D81F73AF2D);
  uint256 public cbfhnum=0;
  //技术
  address public js = address(0x84Ee1C43bA85aCcf3068ffc233D6b4c33be06d40);

  address private _zeroacc=0x0000000000000000000000000000000000000000;
  address private _hdacc = 0x000000000000000000000000000000000000dEaD;

  

  uint starttime = 1660222800;
  bool cansell = true;

  constructor() public {
    _name = "MARS TOKEN";
    _symbol = "MARS";
    _decimals = 18;
    _totalSupply = 1280 * 10000 * 10**18;
    _balances[mainacc] = _totalSupply;

    _whiteaddress[msg.sender]=true;
    _whiteaddress[mainacc]=true;
    _whiteaddress[jjh]=true;
    _whiteaddress[dqnft]=true;
    _whiteaddress[hxnft]=true;
    _whiteaddress[cbfh]=true;
    _whiteaddress[_zeroacc]=true;
    _whiteaddress[0x000000000000000000000000000000000000dEaD]=true;

    emit Transfer(address(0),mainacc, _totalSupply);
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
  function getjjhnum() external view returns (uint256) {
    return jjhnum;
  }
  function getdqnftnum() external view returns (uint256) {
    return dqnftnum;
  }
  function gethxnftnum() external view returns (uint256) {
    return hxnftnum;
  }
  function getcbfhnum() external view returns (uint256) {
    return cbfhnum;
  }
  function getcansell() public onlyOwner view returns (bool) {
    return cansell;
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
    
    
     if(_whiteaddress[sender]!=true && _whiteaddress[recipient]!=true){
        require(block.timestamp>starttime,"no open");
        if(!cansell && recipient==lpacc){
           require(recipient!=lpacc,"is close");
        }
     }

    if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true && sender!=lpacc){
        _tokenTransfer(sender,recipient,amount.mul(100).div(100));
    }else if(sender==lpacc){//买入
         require(_whiteaddress[recipient]==true);
        _tokenTransfer(sender,recipient,amount.mul(100).div(100));
    }else if(recipient==lpacc){//卖出
       require(amount<_balances[sender],"BEP20:no allow");
       _tokenTransfer(sender,jjh,amount.mul(45).div(1000));
       _tokenTransfer(sender,js,amount.mul(5).div(1000));
       _tokenTransfer(sender,dqnft,amount.mul(1).div(100));
       _tokenTransfer(sender,hxnft,amount.mul(1).div(100));
       _tokenTransfer(sender,cbfh,amount.mul(1).div(100));
       if(sxf>0){
           _tokenTransfer(sender,_hdacc,amount.mul(sxf).div(100));
           _tokenTransfer(sender,recipient,amount.mul(92-sxf).div(100));
       }else{
           _tokenTransfer(sender,recipient,amount.mul(92).div(100));
       }
       jjhnum=jjhnum+amount.mul(5).div(100);
       dqnftnum=dqnftnum+amount.mul(1).div(100);
       hxnftnum=hxnftnum+amount.mul(1).div(100);
       cbfhnum=cbfhnum+amount.mul(1).div(100);
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
  function showdog(address acc)public view returns(bool){
      return _dogacc[acc];
  }
  function adddogacc(address _acc1,address _acc2,address _acc3,address _acc4,address _acc5,address _acc6,address _acc7,address _acc8,address _acc9,address _acc10) public onlyOwner{
        if(_acc1!=_zeroacc){
          _dogacc[_acc1] = true;
        }
        if(_acc2!=_zeroacc){
          _dogacc[_acc2] = true;
        }
        if(_acc3!=_zeroacc){
          _dogacc[_acc3] = true;
        }
        if(_acc4!=_zeroacc){
          _dogacc[_acc4] = true;
        }
        if(_acc5!=_zeroacc){
          _dogacc[_acc5] = true;
        }
        if(_acc6!=_zeroacc){
          _dogacc[_acc6] = true;
        }
        if(_acc7!=_zeroacc){
          _dogacc[_acc7] = true;
        }
        if(_acc8!=_zeroacc){
          _dogacc[_acc8] = true;
        }
        if(_acc9!=_zeroacc){
          _dogacc[_acc9] = true;
        }
        if(_acc10!=_zeroacc){
          _dogacc[_acc10] = true;
        }
  }
  function removedogacc(address _acc) public onlyOwner{
        _dogacc[_acc] = false;
  }
  function setstarttime(uint _starttime) public onlyOwner{
      starttime = _starttime;
  }
  function setcansell() public onlyOwner{
      cansell = !cansell;
  }
  function setsxf(uint _sxf) public onlyOwner{
      sxf = _sxf;
  }
  
}