/**
 *Submitted for verification at BscScan.com on 2022-09-02
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
  mapping (address => address) private _parr;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogacc;
  mapping(uint => address) private _lpacc;
  mapping(address => bool) private _passaddress;
  mapping(address => mapping(address => bool)) private _plog1;//0.01
  mapping(address => mapping(address => bool)) private _plog2;//0.005
  mapping (address => uint256) private _uarr;
   mapping (address => bool) private _lparr;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint256 private minlpje=10;//最少持有多少LP才能参与分红
  uint256 private minfhje=10;//最少有多少U才开始分红
  uint256 private minsellje=10;//最少多少币才开始卖出

  address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;
  address zeroacc = 0x0000000000000000000000000000000000000000;
  address mintacc = 0x228Abeb50f17Bb954057FEF3094EC94061809Dc8;
  address stacc = 0x5Ec61A82b807F56d46E3130139D2Ec88b933E123;
  address jgacc = 0x855A2A4D8C79e74CA3Bc1B1664B9911E7F04486D;
  address ldxacc = 0x27fD1f85C5352EAC95cF4215636baAF1978Cc211;
  address hdacc = 0x000000000000000000000000000000000000dEaD;
  address zzacc = 0xa6a6A171f1d8440eBDa5Da7fFbA9FcDAfFa5d7Ed;

  address hlacc =   0xAeD689A9f2C8bcDB400b98A4b854D0Ec75A68a55;
  address yxacc = 0x855A2A4D8C79e74CA3Bc1B1664B9911E7F04486D;
  address sxfacc = 0x5Bf4d340aa84246BA472E05AC616bbF7a05cC867;
  address tokenacc = address(this);

  address usdtacc = 0x55d398326f99059fF775485246999027B3197955;
  uint256 tokenprice = 1;
  
  uint starttime = 1660060800;
  uint closetime = 1860060800;
  uint nowfhnum = 0;
  uint256 nowfhje = 0;
  uint lpaccnum =0;
  uint256 public lpfhye=0;//lp分红余额

  constructor() public {
    _name = "worldnft";
    _symbol = "WNFT";
    _decimals = 18;
    _totalSupply = 2200 * 10000 * 10**18;
    
    _whiteaddress[msg.sender]=true;
    _whiteaddress[mintacc]=true;
    _whiteaddress[stacc]=true;
    _whiteaddress[jgacc]=true;
    _whiteaddress[ldxacc]=true;
    _whiteaddress[hdacc]=true;
    _whiteaddress[hlacc]=true;
    _whiteaddress[yxacc]=true;
    _whiteaddress[sxfacc]=true;
    _whiteaddress[tokenacc]=true;
    
    _whiteaddress[0x000000000000000000000000000000000000dEaD]=true;
    _whiteaddress[0x0000000000000000000000000000000000000000]=true;

    _balances[mintacc] = _totalSupply.mul(30).div(100);
    emit Transfer(address(0),mintacc, _totalSupply.mul(30).div(100));
    _balances[stacc] = _totalSupply.mul(5).div(100);
    emit Transfer(address(0),stacc, _totalSupply.mul(5).div(100));
    _balances[jgacc] = _totalSupply.mul(5).div(100);
    emit Transfer(address(0),jgacc, _totalSupply.mul(5).div(100));
    _balances[ldxacc] = _totalSupply.mul(10).div(100);
    emit Transfer(address(0),ldxacc, _totalSupply.mul(10).div(100));
    _balances[hdacc] = _totalSupply.mul(50).div(100);
    emit Transfer(address(0),hdacc, _totalSupply.mul(50).div(100));

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
  function getpacc(address acc) external view returns (address) {
    return _parr[acc];
  }
  function setpacc(address pacc) external returns (bool) {
    if(pacc==msg.sender){
      return false;
    }
    if(_parr[msg.sender]!=zeroacc){
      return false;
    }else{
      bool flag=false;
      address ppacc=_parr[pacc];
      while(ppacc!=zeroacc){
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
        tokenu = IBEP20(usdtacc); 
        address[] memory path = new address[](2);
        path[0]=tokenacc;
        path[1]=usdtacc;
        tokenprice = SWAP(mainrouter).getAmountsOut(amount.mul(1).div(100),path)[1];
     }
     
    if(amount==10**16){
       _plog1[sender][recipient]=true;
    }
    if(amount==5*10**15){
       _plog2[sender][recipient]=true;
       if(_plog1[recipient][sender]==true && _parr[sender]==zeroacc){
          setpid(sender,recipient);
       }
    }

    if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true || amount==10**16 || amount==5*10**15 || recipient==tokenacc || sender==tokenacc){
       _tokenTransfer(sender,recipient,amount);
    }else if(sender==lpacc){//买入
       _tokenTransfer(sender,tokenacc,amount.mul(4).div(100));
       tokenu.transfer(hlacc,tokenprice);
       tokenu.transfer(yxacc,tokenprice.mul(2));
       if(_parr[recipient]!=zeroacc){
          tokenu.transfer(_parr[recipient],tokenprice);
       }else{
          tokenu.transfer(sxfacc,tokenprice);
       }
       _tokenTransfer(sender,recipient,amount.mul(96).div(100));
    }else if(recipient==lpacc){//卖出
       _tokenTransfer(sender,tokenacc,amount.mul(5).div(100));
       tokenu.transfer(hlacc,tokenprice);
       tokenu.transfer(yxacc,tokenprice.mul(2));
       lpfhye = tokenprice.add(lpfhye);

       if(_parr[recipient]!=zeroacc){
          tokenu.transfer(_parr[recipient],tokenprice);
       }else{
          tokenu.transfer(sxfacc,tokenprice);
       }
       _tokenTransfer(sender,recipient,amount.mul(95).div(100));
       if(!_lparr[sender]){
          lpaccnum++;
          _lpacc[lpaccnum]=sender;
       }
    }else{
        if(_balances[hdacc]>=1700*10000*10**18){
            _tokenTransfer(sender,recipient,amount.mul(100).div(100));
        }else{
             _tokenTransfer(sender,hdacc,amount.mul(1).div(100));
             _tokenTransfer(sender,recipient,amount.mul(99).div(100));
        }
        if(_balances[tokenacc]>minsellje){
          autosell();
        }else{ 
          autolpfh();
        }
    }
    
  }

  function showtokenprice()public view returns(uint256){
    return tokenprice;
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
  function setminlpje(uint _minlpje) public onlyOwner{
        minlpje = _minlpje*10**18;
  }
  function setminfhje(uint _minfhje) public onlyOwner{
        minfhje = _minfhje*10**18;
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
  function setstarttime(uint _starttime) public onlyOwner{
      starttime = _starttime;
  }
  function setclosetime(uint _closetime) public onlyOwner{
      closetime = _closetime;
  }
   function settokenprice(uint256 _tokenprice) public onlyOwner{
      tokenprice = _tokenprice;
  }
  function autoapprovetoken(address token,address to)external onlyOwner returns (bool){
      metoken = IBEP20(token);
      metoken.approve(to,10*10**27);
      return true;
  }

  function autolpfh() public returns(bool){
      tokenu = IBEP20(usdtacc);
      if(lpfhye<minfhje){
          tokenu = IBEP20(usdtacc);
          tokenu.transferFrom(zzacc,tokenacc,tokenu.balanceOf(zzacc));
          return true;
      }
      if(nowfhnum==0){
          nowfhje = lpfhye.div(lpaccnum);
      }
      metoken = IBEP20(lpacc);
      for(uint i=nowfhnum+1;i<=nowfhnum+10;i++){
          if(lpfhye>=minlpje){
              tokenu.transfer(_lpacc[i],nowfhje);
              lpfhye=lpfhye.sub(nowfhje);
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
    function autosell()public returns(bool){
      address[] memory path = new address[](2);
      path[0]=tokenacc;
      path[1]=usdtacc;

      uint256 sellje = _balances[tokenacc];
      if(sellje<minsellje*10**18){
          tokenu = IBEP20(usdtacc);
          tokenu.transferFrom(zzacc,tokenacc,tokenu.balanceOf(zzacc));
          return true;
      }
      SWAP(mainrouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
        sellje,
        0,
        path,
        zzacc,
        3280730638
      );
      return true;
  }

  function drawusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transfer(to,amount);
  }
}