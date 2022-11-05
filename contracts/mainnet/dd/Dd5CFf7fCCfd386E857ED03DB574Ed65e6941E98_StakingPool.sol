/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

pragma solidity >=0.8.17;
// SPDX-License-Identifier: Apache 2.0

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

interface BEP20_Interface {
  function allowance(address _owner, address _spender) external view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _value) external returns (bool);
  function transfer(address direccion, uint cantidad) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function decimals() external view returns (uint256);
  function totalSupply() external view returns (uint256);
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

contract StakingPool is Context{
  using SafeMath for uint;

  BEP20_Interface BEP20_Contract = BEP20_Interface(0xb775Aa16C216E34392e91e85676E58c3Ad72Ee77);

  mapping(address => uint256[]) public deposito;
  mapping(address => uint256[]) public tokenInterno;
  mapping(address => uint256[]) public fecha;

  uint public MIN_DEPOSIT = 84 * 10**18;
  uint public MAX_DEPOSIT = 84000 * 10**18;
  uint public DISTRIBUTION_POOL;
  uint public TIME_DISTRIBUTION = 1*86400;
  uint public TOTAL_STAKING;
  uint public TOTAL_PARTICIPACIONES;
  uint public PAYER_POOL_BALANCE;
  uint public inicio = 1667851200;
  uint public lastPay = 1667851200;

  uint public duracion = 60*86400;
  uint public precision = 18;

  constructor() { }

  function RATE() public view returns (uint){
    if(TOTAL_PARTICIPACIONES == 0){
      return 10**precision;
    }else{
      return (PAYER_POOL_BALANCE.mul(10**precision)).div(TOTAL_PARTICIPACIONES);
    }
  }

  function compra(uint _value) public view returns(uint){
    return (_value.mul(10**precision)).div(RATE());
  }
  
  function staking(uint _token) public  {

    if(block.timestamp < inicio )revert();
    if(_token < MIN_DEPOSIT)revert();
    if(depositoTotalToken(msg.sender)+_token > MAX_DEPOSIT)revert();

    if( !BEP20_Contract.transferFrom(msg.sender, address(this), _token) )revert();

    tokenInterno[msg.sender].push(compra(_token));
    TOTAL_PARTICIPACIONES += compra(_token);
    PAYER_POOL_BALANCE += _token;

    fecha[msg.sender].push(block.timestamp+duracion);
    deposito[msg.sender].push(_token);

    TOTAL_STAKING += _token;

  }

  function pago(uint _value) public view returns (uint256){
    return (_value.mul(RATE())).div(10**precision);
  }

  function retiro(uint _deposito) public {

    if(fecha[msg.sender][_deposito] > block.timestamp)revert();

    uint pagare = pago(tokenInterno[msg.sender][_deposito]);
    
    if( !BEP20_Contract.transfer(msg.sender, pagare) )revert();

    TOTAL_PARTICIPACIONES -= tokenInterno[msg.sender][_deposito];
    PAYER_POOL_BALANCE -= pagare;
    TOTAL_STAKING -= deposito[msg.sender][_deposito];

    tokenInterno[msg.sender][_deposito] = tokenInterno[msg.sender][tokenInterno[msg.sender].length - 1];
    tokenInterno[msg.sender].pop();

    deposito[msg.sender][_deposito] = deposito[msg.sender][deposito[msg.sender].length - 1];
    deposito[msg.sender].pop();

    fecha[msg.sender][_deposito] = fecha[msg.sender][fecha[msg.sender].length - 1];
    fecha[msg.sender].pop();

  }
  
  function depositoTotal(address _user) public view returns (uint[] memory){
    return deposito[_user];
  }

  function depositoTotalToken(address _user) public view returns (uint){

    uint sumatoria;
    for (uint256 index = 0; index < deposito[_user].length; index++) {
      sumatoria += deposito[_user][index];
    }
    return sumatoria;
  }

  function pagarDividendos() public{
    if( block.timestamp >= lastPay + TIME_DISTRIBUTION){
      uint pd = DISTRIBUTION_POOL.mul(2).div(100);
      DISTRIBUTION_POOL -= pd;
      PAYER_POOL_BALANCE += pd;
      lastPay = lastPay+TIME_DISTRIBUTION;
    }else{revert();}

  }

  function recargarPool(uint _token) public{

    if( !BEP20_Contract.transferFrom(msg.sender, address(this), _token) )revert();
    DISTRIBUTION_POOL += _token;

  }

  function dividendos(address _user) public view returns (uint[] memory){

    uint[] memory userpart = tokenInterno[_user];

    uint[] memory totDiv = new uint[](userpart.length);

    for (uint256 index = 0; index < userpart.length; index++) {
      totDiv[index] = userpart[index].sub(compra(deposito[_user][index]));
    }

    return totDiv;
  }

  function totalDividendos(address _user) public view returns (uint){

    uint[] memory userpart = dividendos(_user);

    uint totDiv;

    for (uint256 index = 0; index < userpart.length; index++) {
      totDiv += userpart[index] ;
    }

    return totDiv;
  }

  function retiroDividendos(address _user) public {

    uint tokenIN = totalDividendos(_user);
    uint tokenEX = pago(totalDividendos(_user));

    if( !BEP20_Contract.transfer(_user, tokenEX ))revert();

    for (uint256 index = 0; index < dividendos(_user).length; index++) {
      tokenInterno[_user][index] -= dividendos(_user)[index];
    }

    TOTAL_PARTICIPACIONES -= tokenIN;
    PAYER_POOL_BALANCE -= tokenEX;

  }

  fallback() external payable {}
  receive() external payable {}

}