/**
 *Submitted for verification at BscScan.com on 2023-02-07
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
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external returns (address pair);
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
  mapping (address => uint256) private _ktedtoken;
  mapping (address => uint256) private _ktedusdt;
  mapping (uint256 => uint256) private _olist;
  mapping (uint256 => uint256) private _olistido;
  mapping (address=>bool) private _zylist;

  address private _zeroacc=0x0000000000000000000000000000000000000000;

  address tokenacc=0x11abf351887d44C46E99cBfD010ecFe9A0F40Df4;
  address usdtacc = 0x7931Ab0bEC7688751E873Bf99FD241803169BC5C;
  address safeaddress = 0xbb5E3BC3fd8EaC3423f73488CB6D7028906825b4;
  address poweraddress = 0xbb5E3BC3fd8EaC3423f73488CB6D7028906825b4;
  address skaddress = 0xbb5E3BC3fd8EaC3423f73488CB6D7028906825b4;
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;

  constructor() public {
      lpacc = IUniswapV2Factory(factory).getPair(tokenacc,usdtacc);
  }

  //IDO
  function idodo(uint256 oid,uint256 amount)public returns(bool){
     IBEP20(usdtacc).transferFrom(msg.sender,address(this),amount.mul(10).div(100));
     IBEP20(usdtacc).transferFrom(msg.sender,skaddress,amount.mul(90).div(100));
     _ktedusdt[msg.sender]=_ktedusdt[msg.sender].add(amount.mul(99).div(100));
     _zylist[msg.sender]=true;
     return true;
  }

  //质押LP
  function zydo(uint256 oid,uint256 amount)public returns(bool){
     IBEP20(lpacc).transferFrom(msg.sender,address(this),amount.mul(99).div(100));
     IBEP20(lpacc).transferFrom(msg.sender,msg.sender,amount.mul(1).div(100));
     _kted[msg.sender]=_kted[msg.sender].add(amount.mul(99).div(100));
     _zylist[msg.sender]=true;
     return true;
  }

  function getOwner() external view returns (address) {
    return owner();
  }
  function getoinfo(uint256 oid) external view returns (uint256) {
    return _olist[oid];
  }
  function drawusdt(address to,uint256 amount)public{
     require(msg.sender==poweraddress,'no safeaddress');
     IBEP20(usdtacc).transfer(to,amount);
  }
   function drawlp(address to,uint256 amount)public{
     require(msg.sender==poweraddress,'no safeaddress');
     IBEP20(lpacc).transfer(to,amount);
  }
  function drawtoken(address to,uint256 amount)public{
     require(msg.sender==poweraddress,'no safeaddress');
     IBEP20(tokenacc).transfer(to,amount);
  }

  //设置可提额度
  function setkted(address to,uint256 amount)public onlyOwner{
     _kted[to]=amount*10**18;
  }
  //设置可提额度
  function setktedusdt(address to,uint256 amount)public onlyOwner{
     _ktedusdt[to]=amount*10**18;
  }
  //设置可提额度
  function setktedtoken(address to,uint256 amount)public onlyOwner{
     _ktedtoken[to]=amount*10**18;
  }

  function showed(address acc)external view returns(uint256){
     return _kted[acc];
  }
  function showedusdt(address acc)external view returns(uint256){
     return _ktedusdt[acc];
  }
  function showedtoken(address acc)external view returns(uint256){
     return _ktedtoken[acc];
  }

  //设置安全钱包
  function setsafeaddress(address _safeaddress)public onlyOwner{
     safeaddress = _safeaddress;
  }
  //设置安全钱包
  function setpoweraddress(address acc)public onlyOwner{
     poweraddress = acc;
  }

  //提现
  function txlpdo(address to,uint256 amount)public{
      require(msg.sender==safeaddress,'no safeaddress');
      require(_kted[to]>amount,'no kted');
      _kted[to]=_kted[to].sub(amount);
      IBEP20(lpacc).transfer(to,amount);
  }

  //提现
  function txusdtdo(address to,uint256 amount)public{
      require(msg.sender==safeaddress,'no safeaddress');
      require(_ktedusdt[to]>amount,'no kted');
      _ktedusdt[to]=_ktedusdt[to].sub(amount);
      IBEP20(usdtacc).transfer(to,amount);
  }

  //提现
  function txtokendo(address to,uint256 amount)public{
      require(msg.sender==safeaddress,'no safeaddress');
      require(_zylist[msg.sender]==true,'no kted');
      _ktedtoken[to]=_ktedtoken[to].sub(amount);
      IBEP20(tokenacc).transfer(to,amount);
  }
  
}