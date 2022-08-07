/**
 *Submitted for verification at BscScan.com on 2022-08-06
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

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => address) private _parr;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint256 private minlpje=100;

  address public mainrouter;

  //1% 回流底池
  address public dcacc = address(0x150438cFf419Aa06057Bb3022C5288f7cBAc5505);
  uint256 public dcnum=0;
  //1% NFT分红
  address public nftacc = address(0xf7BDed11421F814D1AABAf0E1f94506aFD1d8e1D);
  uint256 public nftnum=0;
  //1% LP共识股东
  address public lpgsacc = address(0x0978a13CE25b3996565214090240Cdf4786E1C70);
  uint256 public lpgsnum=0;
  //1% 生态基金
  address public stacc = address(0xc57B5bB72664bEd506950D18fDCcacD14EB7EEFA);
  uint256 public stnum=0;
  //营销
  address public yxacc = address(0x623ff5F86d82E21D4cA2843EA5F1b1f98BcB2187);
  // lp动态股东
  address public lpdtacc = address(0x3b8A82DbBB77311448Fbf5afa2F6F3ADFc2ebf63);
  uint256 public lpdtnum=0;
  // U库
  address public ukacc = address(0xc1E1077f694540C6a38d0D55C4154e21F5C660e0);
  uint256 public uknum = 0;
  // 回购WBD
  address public hgacc = address(0x7164e9Ab90b779fFc7a901aA8877c8a18955dc97);
  uint256 public hgnum = 0;

  address public usdtacc = address(0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6);
  address public lpacc = address(0x5b85D7768201f1A60c3e68Ade121627Be8A8ED68);
  address private _zeroacc=0x0000000000000000000000000000000000000000;

  address mainacc = 0x673b7B79e0316286b518a9944fc933E5b05142ae;

  uint starttime = 1659691800;
  uint closetime = 1859691815;

  constructor() public {
    _name = "WBD";
    _symbol = "WBD";
    _decimals = 18;
    _totalSupply = 10000000 * 10**18;
    _balances[mainacc] = _totalSupply;

    _whiteaddress[msg.sender]=true;
    _whiteaddress[mainacc]=true;
    _whiteaddress[dcacc]=true;
    _whiteaddress[nftacc]=true;
    _whiteaddress[lpgsacc]=true;
    _whiteaddress[stacc]=true;
    _whiteaddress[_zeroacc]=true;
    _whiteaddress[lpdtacc]=true;
    _whiteaddress[0x000000000000000000000000000000000000dEaD]=true;

    emit Transfer(address(0),mainacc, _totalSupply);
  }

  function buymh(address to,uint256 amount)public returns(bool){
      bool res;
      if(amount==300*10**18){
        res = buymhs(to,amount);
      }
      if(amount==1000*10**18){
         res = buymhsr(to,amount);
      }
      if(amount==5000*10**18){
        res = buymhssr(to,amount);
      }
      return res;
  }

  //买盲盒进行分配
  function buymhs(address to,uint256 amount)public returns(bool){
     tokenu = IBEP20(usdtacc);
     tokenlp = IBEP20(lpacc);
     tokenu.transferFrom(msg.sender,ukacc,20.7*10**18);
     uknum = uknum + 20.7*10**18;
     amount = amount - 20.7*10**18;
     tokenu.transferFrom(msg.sender,hgacc,150*10**18);
     amount = amount - 150*10**18;
     hgnum = hgnum + 150*10**18;

     uint i=1;
     address pacc=_parr[msg.sender];
     while(i<=20 && pacc!=_zeroacc){
        if(tokenlp.balanceOf(pacc)<minlpje){
          pacc = _parr[pacc];
          i++;
          continue;
        }
        if(i==1){
          tokenu.transferFrom(msg.sender,pacc,40*10**18);
          amount = amount - 40*10**18;
        }else{
          tokenu.transferFrom(msg.sender,pacc,4.7*10**18);
          amount = amount - 4.7*10**18;
        }
        pacc = _parr[pacc];
        i++;
     }
     tokenu.transferFrom(msg.sender,to,amount);
     return true;
  }
  //买盲盒进行分配
  function buymhsr(address to,uint256 amount)public returns(bool){
     tokenu = IBEP20(usdtacc);
     tokenlp = IBEP20(lpacc);
     tokenu.transferFrom(msg.sender,ukacc,85*10**18);
     uknum = uknum + 85*10**18;
     amount = amount - 85*10**18;
     tokenu.transferFrom(msg.sender,hgacc,500*10**18);
     amount = amount - 500*10**18;
     hgnum = hgnum + 500*10**18;

     uint i=1;
     address pacc=_parr[msg.sender];
     while(i<=20 && pacc!=_zeroacc){
        if(tokenlp.balanceOf(pacc)<minlpje){
          pacc = _parr[pacc];
          i++;
          continue;
        }
        if(i==1){
          tokenu.transferFrom(msg.sender,pacc,130*10**18);
          amount = amount - 130*10**18;
        }else{
          tokenu.transferFrom(msg.sender,pacc,15*10**18);
          amount = amount - 15*10**18;
        }
        pacc = _parr[pacc];
        i++;
     }
     tokenu.transferFrom(msg.sender,to,amount);
     return true;
  }
  //买盲盒进行分配
  function buymhssr(address to,uint256 amount)public returns(bool){
     tokenu = IBEP20(usdtacc);
     tokenlp = IBEP20(lpacc);
     tokenu.transferFrom(msg.sender,ukacc,406*10**18);
     uknum = uknum + 406*10**18;
     amount = amount - 406*10**18;
     tokenu.transferFrom(msg.sender,hgacc,2500*10**18);
     amount = amount - 2500*10**18;
     hgnum = hgnum + 2500*10**18;

     uint i=1;
     address pacc=_parr[msg.sender];
     while(i<=20 && pacc!=_zeroacc){
        if(tokenlp.balanceOf(pacc)<minlpje){
          pacc = _parr[pacc];
          i++;
          continue;
        }
        if(i==1){
          tokenu.transferFrom(msg.sender,pacc,650*10**18);
          amount = amount - 650*10**18;
        }else{
          tokenu.transferFrom(msg.sender,pacc,76*10**18);
          amount = amount - 76*10**18;
        }
        pacc = _parr[pacc];
        i++;
     }
     tokenu.transferFrom(msg.sender,to,amount);
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
  function getdcnum() external view returns (uint256) {
    return dcnum;
  }
  function getnftnum() external view returns (uint256) {
    return nftnum;
  }
  function getlpgsnum() external view returns (uint256) {
    return lpgsnum;
  }
  function getstnum() external view returns (uint256) {
    return stnum;
  }
  function getlpdtnum() external view returns (uint256) {
    return lpdtnum;
  }
  function getuknum() external view returns (uint256) {
    return uknum;
  }
  function gethgnum() external view returns (uint256) {
    return hgnum;
  }
  function getpacc(address acc) external view returns (address) {
    return _parr[acc];
  }
  function setpacc(address pacc) external returns (bool) {
    if(_parr[msg.sender]!=_zeroacc){
      return false;
    }else{
      bool flag=false;
      address ppacc=_parr[pacc];
      while(ppacc!=_zeroacc){
         if(ppacc==msg.sender){
           flag=true;
         }
         ppacc=_parr[ppacc];
      }
      if(flag!=true){
        _parr[msg.sender]=pacc;
      }
      return true;
    }
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
        if(block.timestamp>closetime && recipient==lpacc){
           require(recipient!=lpacc,"is close");
        }
     }

    if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true){
       _tokenTransfer(sender,recipient,amount.mul(100).div(100));
    }else{
       _tokenTransfer(sender,dcacc,amount.mul(1).div(100));
       _tokenTransfer(sender,nftacc,amount.mul(1).div(100));
       _tokenTransfer(sender,lpgsacc,amount.mul(1).div(100));
       _tokenTransfer(sender,yxacc,amount.mul(1).div(100));
       _tokenTransfer(sender,recipient,amount.mul(96).div(100));
       dcnum=dcnum+amount.mul(1).div(100);
       nftnum=nftnum+amount.mul(1).div(100);
       lpgsnum=lpgsnum+amount.mul(1).div(100);
    }
    if(recipient==lpdtacc){
      lpdtnum=lpdtnum+amount;
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
  function setminlpje(uint256 _minlpje) public onlyOwner{
        minlpje = _minlpje;
  }
  function adduk(uint256 _je) public returns(bool){
        require(msg.sender == mainrouter, "BEP20: only mainrouter can use");
        uknum = uknum+_je;
        return true;
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
  function setstarttime(uint _starttime) public onlyOwner{
      starttime = _starttime;
  }
  function setclosetime(uint _closetime) public onlyOwner{
      closetime = _closetime;
  }
}