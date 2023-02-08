/**
 *Submitted for verification at BscScan.com on 2023-02-08
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

contract BEP20Cardano is Context, Ownable {
  using SafeMath for uint256;
  IBEP20 public tokenu;

  mapping (address => uint256) private _kted;
  mapping (address => uint256) private _ls;
  mapping (address => uint256) private _rgje;
  mapping (address => address) private _parr;


  mapping (address => bool) private _v2;
  mapping (address => bool) private _v3;
  mapping (address => bool) private _v;

  address private _zeroacc=0x0000000000000000000000000000000000000000;

  address tokenacc=address(this);
  address usdtacc = 0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6;
  address safeaddress = 0x3Ca2DC01AB6c1e9E97000DBCF387Bc50906cADB9;
  address oneacc =0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6;
  address yxacc=0xa4a415855dFB6b92C9Df74D477555fa26263522d;

  constructor() public {
  }

  //IDO
  function buyone(address to,uint256 amount)public returns(bool){
     tokenu = IBEP20(usdtacc);
     uint i=1;
     address pacc=_parr[msg.sender];
     uint syed=25;
     if(amount>=1000*10**18){
         _v2[msg.sender]=true;
     }
     if(amount>=2000*10**18){
         _v3[msg.sender]=true;
     }
     _v[msg.sender]=true;
     _rgje[msg.sender]=_rgje[msg.sender].add(amount);
     bool flagv2=true;
     bool flagv3=true;
     while(i<=100 && pacc!=_zeroacc){
        if(i==1 && _v[pacc]==true){
          tokenu.transferFrom(msg.sender,pacc,amount.mul(10).div(100));
          syed = syed-10;
        }
        if(i==2 && _v[pacc]==true){
          tokenu.transferFrom(msg.sender,pacc,amount.mul(5).div(100));
          syed = syed-5;
        }
        _ls[pacc]=_ls[pacc].add(amount);
        if(_v2[pacc]==true && flagv2){
            _kted[msg.sender].add(amount.mul(1).div(100));
            flagv2=false;
        }
        if(_v3[pacc]==true && flagv3){
            _kted[msg.sender].add(amount.mul(2).div(100));
            flagv3=false;
        }
        pacc = _parr[pacc];
        i++;
     }
     if(syed>0){
       tokenu.transferFrom(msg.sender,yxacc,amount.mul(syed).div(100));
     }
     tokenu.transferFrom(msg.sender,to,amount.mul(75).div(100));
     return true;
  }

  function getOwner() external view returns (address) {
    return owner();
  }
  function getls(address acc) external view returns (uint256) {
    return _ls[acc];
  }
  function getrgje(address acc) external view returns (uint256) {
    return _rgje[acc];
  }
  function isv2(address acc) external view returns (bool) {
    return _v2[acc];
  }
  function isv3(address acc) external view returns (bool) {
    return _v3[acc];
  }
  function getpacc(address acc) external view returns (address) {
    return _parr[acc];
  }
  function setpacc(address pacc) external returns (bool) {
    if(pacc==msg.sender){
      return false;
    }
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

  function drawusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transfer(to,amount);
  }

  //设置可提额度
  function setkted(address to,uint256 amount)public onlyOwner{
     _kted[to]=amount*10**18;
  }

  function showed(address acc)external view returns(uint256){
     return _kted[acc];
  }

  //设置安全钱包
  function setsafeaddress(address _safeaddress)public onlyOwner{
     safeaddress = _safeaddress;
  }


  //设置oneacc
  function setoneacc(address acc)public onlyOwner{
     oneacc = acc;
  }
  function setyxacc(address acc)public onlyOwner{
     yxacc = acc;
  }

  //提现
  function txdo(address to,uint256 amount)public{
      require(msg.sender==safeaddress,'no safeaddress');
      require(_kted[to]>amount,'no kted');
      require(_v2[to]||_v3[to],'no kted');
      _kted[to]=_kted[to].sub(amount);
      IBEP20(usdtacc).transfer(to,amount);
  }
  
}