/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: Apache 2.0

interface BEP20_Interface {
  function allowance(address _owner, address _spender) external view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _value) external returns (bool);
  function transfer(address direccion, uint cantidad) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function decimals() external view returns(uint);
}

interface Staking_Interface {
  function recargarPool(uint _value) external;
}

library SafeMath {

  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
        return 0;
    }

    uint c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);
    uint c = a / b;

    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    uint c = a - b;

    return c;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);

    return c;
  }

}

abstract contract Context {

  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Admin is Context{
  mapping (address => bool) public admin;

  event NewAdmin(address indexed admin);
  event AdminRemoved(address indexed admin);

  constructor(){
    admin[_msgSender()] = true;
  }

  modifier onlyAdmin() {
    if(!admin[_msgSender()])revert();
    _;
  }

  function makeNewAdmin(address payable _newadmin) public onlyAdmin {
    if(_newadmin == address(0))revert();
    emit NewAdmin(_newadmin);
    admin[_newadmin] = true;
  }

  function makeRemoveAdmin(address payable _oldadmin) public onlyAdmin {
    if(_oldadmin == address(0))revert();
    emit AdminRemoved(_oldadmin);
    admin[_oldadmin] = false;
  }

}

contract Voter is Context, Admin{
  using SafeMath for uint256;

  address public token = 0xb775Aa16C216E34392e91e85676E58c3Ad72Ee77;
  uint256 public inicio = 1667937600;
  uint256 public fin = 1670011200;
  uint256 public precio = 50*10**18; 
  uint256 public aumento = 7*10**18; 

  BEP20_Interface BEP20_Contract = BEP20_Interface(token);

  mapping (address => bool[]) public fans;

  bool[] public items;
  uint256[] public votos;

  bool[] private base;
  uint256 public pool;

  address public contractStaking = 0xDd5CFf7fCCfd386E857ED03DB574Ed65e6941E98;
  uint256 public porcentStaking = 20;

  Staking_Interface  Staking_Contract = Staking_Interface(contractStaking);

  address[] wallets = [0x3490E37E4791B95c1aF4CdA85c1d17f11673ff9a,0x9565eFF8Ade3A9AA0a8059EA68d4f32787e1628b,0xBA286Cc49b88e2552Cbe07440765eC8120cC71A3];
  uint256[] porcents = [25,10,45];

  constructor() {

    for (uint256 index = 0; index < 32; index++) {
      items.push(false);
      votos.push(0);
    }

    base = items;
      
    fans[_msgSender()] = base;

  }
  
  function largoItems() public view returns(uint256){
      return items.length;
  }
  
  function largoFanItems(address _fan) public view returns(uint256){
      return fans[_fan].length;
  }
  
  function verFanItems(address _fan, uint256 _i) public view returns(bool){
      return fans[_fan][_i];
  }

  function verGanador() public view returns(uint256){

    uint256 resultado = items.length;

    for (uint256 index = 0; index < items.length; index++) {
      if(items[index])resultado = index;
    }

    return resultado;
  }
  
  function setGanador(uint256 _item) public onlyAdmin {  
    items[_item] = true;
  }
  
  function tiempo() public view returns(uint256){
      return block.timestamp;
  }

  function valor() public view returns(uint256) {
    uint256 costo = precio;
    if(aumento != 0){
      if(block.timestamp > inicio ){
        costo = ((block.timestamp).sub(inicio)).div(86400);
        costo = precio.add(costo.mul(aumento));
      }
    }
    return  costo;

  }

  function aprobarBalnc(uint256 val) public {
    if( BEP20_Contract.allowance(address(this), contractStaking) < val){
      BEP20_Contract.approve(contractStaking, 115792089237316195423570985008687907853269984665640564039457584007913129639935); 
    }

  }

  function ganador() public view returns(uint256) {

    uint256 puntos;
    for (uint256 index = 0; index < fans[_msgSender()].length; index++) {
      if(items[index] && fans[_msgSender()][index]){
        puntos = pool.div(votos[index]);
      }
    }
    return puntos;
  }

  function limit(address _user) internal view returns(uint256){
    uint256 limite = 0;

    for (uint256 index = 0; index < fans[_user].length; index++) {
      if(fans[_user][index])limite++;
    }

    return limite;
  }

  function votar(uint256 _item) public returns(bool){  

    if(block.timestamp >= fin)revert("END");
    if(block.timestamp < inicio)revert("NSTRT");
    
    if(fans[_msgSender()].length != base.length){
      fans[_msgSender()] = base;
    }

    if(valor() > 0 &&  ganador() == 0 && limit(_msgSender()) < 3 ){
      if(fans[_msgSender()][_item] == true )revert("IYA");
  
      if(!BEP20_Contract.transferFrom(_msgSender(), address(this), valor() ))revert("TF");

      if(wallets.length > 0){
        for (uint256 index = 0; index < wallets.length; index++) {
          BEP20_Contract.transfer( wallets[index], valor().mul(porcents[index]).div(1000) );
        }
      }
      aprobarBalnc(valor().mul(porcentStaking).div(1000));
      Staking_Contract.recargarPool(valor().mul(porcentStaking).div(1000));

      votos[_item]++;
      fans[_msgSender()][_item] = true;
      pool += (valor()).mul(90).div(100);
      return true;
    }else{
      revert("NPVM");
    }
    
  }

  function reclamar() public {  

    if(ganador() <= 0)revert("NG");
    if(!BEP20_Contract.transfer(_msgSender(), ganador() ) )revert("TF");

    fans[_msgSender()] = base;

  }

  fallback() external payable {}
  receive() external payable {}

}