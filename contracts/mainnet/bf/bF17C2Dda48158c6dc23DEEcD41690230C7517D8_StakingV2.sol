/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: Apache 2.0

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

}

interface Market_Interface {

  function consultarCarta(address _owner, uint256 _index) external view returns (uint256);
  function NoStakingCard(address _owner, uint256 _index) external returns (bool);

}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract Ownable is Context {
  address payable public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor(){
    owner = payable(_msgSender());
  }
  modifier onlyOwner() {
    if(_msgSender() != owner)revert();
    _;
  }
  function transferOwnership(address payable newOwner) public onlyOwner {
    if(newOwner == address(0))revert();
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Admin is Context, Ownable{
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

  function makeNewAdmin(address payable _newadmin) public onlyOwner {
    if(_newadmin == address(0))revert();
    emit NewAdmin(_newadmin);
    admin[_newadmin] = true;
  }

  function makeRemoveAdmin(address payable _oldadmin) public onlyOwner {
    if(_oldadmin == address(0))revert();
    emit AdminRemoved(_oldadmin);
    admin[_oldadmin] = false;
  }

}

contract StakingV2 is Context, Admin{
  using SafeMath for uint256;
  
  Market_Interface MARKET_CONTRACT = Market_Interface(0xF29bACE830B2a81c33bC360317A0f9abe154c288);

  struct Dep {
    uint256 deposito;
    uint256 inicio;
    uint256 factor;
    uint256 carta;
    uint256 tiempo;

  }

  uint256 public inicio = 1653152400;
  uint256 public plazoRetiros = 1*86400;

  mapping (address => Dep[]) public flexible;
  mapping (address => Dep[]) public bloqueado;

  mapping (address => uint256) public payAt;
  mapping (address => uint256) public payAtBlock;

  uint256[] public planTiempo = [14 * 86400, 21 * 86400, 28 * 86400, 14 * 86400, 21 * 86400, 28 * 86400];
  uint256[] public planRetorno = [1120, 1360, 1400, 1930, 2750, 2920];
  bool[] public planBloqueo = [false,false,false,true,true,true];

  constructor() { }

  function bonus() public view returns(uint256){
    uint256 bonoBalance = ((address(this).balance).div(100*10**18)).mul(10);
    uint256 bonoTiempo = (block.timestamp-inicio);

    if( bonoTiempo > 30*86400){
      bonoTiempo = 30;
    }else{
      bonoTiempo = (block.timestamp-inicio).div(86400);
    }

    bonoTiempo = bonoTiempo.mul(5);

    return bonoBalance.add(bonoTiempo);

  }
  
  function staking(uint256 _plan, uint256 _carta) public returns (bool) {

    if(block.timestamp < inicio )revert("aun no ha iniciado");

    uint256 _value = MARKET_CONTRACT.consultarCarta(_msgSender(), _carta);

    if( _value <= 0)revert("error al usar la carta");


    if(payAt[_msgSender()] == 0 && payAtBlock[_msgSender()] == 0){
      payAt[_msgSender()] = block.timestamp;
      payAtBlock[_msgSender()] = block.timestamp;

    }

    if(planBloqueo[_plan]){
      bloqueado[_msgSender()].push(Dep(_value, block.timestamp,planRetorno[_plan].add(bonus()), _carta, planTiempo[_plan]));

    }else{
      flexible[_msgSender()].push(Dep(_value, block.timestamp,planRetorno[_plan].add(bonus()), _carta, planTiempo[_plan]));

    }


    if(MARKET_CONTRACT.NoStakingCard(_msgSender(), _carta) == true ){
      return true;
    }else{
      revert("fallo al marcar carta como stakeada");
    } 

  }

  function retirable(address _user) public view returns(uint256){
    Dep[] memory usuario = flexible[_user];

    uint256 reti;
    uint256 finish;
    uint256 since;
    uint256 till;

    for (uint256 index = 0; index < usuario.length; index++) {
      finish = usuario[index].inicio + usuario[index].tiempo;
      since = payAt[_user] > usuario[index].inicio ? payAt[_user] : usuario[index].inicio;
      till = block.timestamp > finish ? finish : block.timestamp;
      if(till >= since){
        reti += (((usuario[index].deposito).mul(usuario[index].factor).div(1000)).mul(till.sub(since))).div(usuario[index].tiempo);
      }
    }

    return reti;

  }

  function retirableBlock(address _user, bool _view) public view returns(uint256){
    Dep[] memory usuario = bloqueado[_user];

    uint256 reti;
    uint256 finish;
    uint256 since;
    uint256 till;

    for (uint256 index = 0; index < usuario.length; index++) {

      finish = usuario[index].inicio + usuario[index].tiempo;
      since = payAtBlock[_user] > usuario[index].inicio ? payAtBlock[_user] : usuario[index].inicio;
      till = block.timestamp > finish ? finish : block.timestamp;

      if( _view ){
        if(till >= since){
          reti += ((((usuario[index].deposito).mul(usuario[index].factor)).div(1000)).mul(till.sub(since)) ).div(usuario[index].tiempo);
        }
      }else{
        if(block.timestamp >= usuario[index].inicio+usuario[index].tiempo && payAtBlock[_user] < usuario[index].inicio+usuario[index].tiempo ){
          reti += ((usuario[index].deposito).mul(usuario[index].factor)).div(1000);
        }

      }

    }

    return reti;

  }
  
  function retiro( bool _bloqueado) public returns (bool){

    uint256 _value = _bloqueado == true ? retirableBlock(_msgSender(), false) : retirable(_msgSender());

    if( _value <= 0)revert("no hay nada para retirar");

    if(_bloqueado){
      if(block.timestamp > payAtBlock[_msgSender()].add(plazoRetiros)){
        payable(_msgSender()).transfer(_value);
        payAtBlock[_msgSender()] = block.timestamp;
      }else{
        revert("no es tiempo de retirar");
      }
      
    }else{
      if(block.timestamp > payAt[_msgSender()].add(plazoRetiros)){
        payable(_msgSender()).transfer(_value);
        payAt[_msgSender()] = block.timestamp;
      }else{
        revert("no es tiempo de retirar");
      }
    }
    
    return true ;
   
  }

  fallback() external payable {}
  receive() external payable {}

}