/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: Apache 2.0

interface TRC20_Interface {
  function allowance(address _owner, address _spender) external view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _value) external returns (bool);
  function transfer(address direccion, uint cantidad) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function decimals() external view returns(uint);
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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Admin is Context {
  address payable public owner;
  mapping (address => bool) public admin;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event NewAdmin(address indexed admin);
  event AdminRemoved(address indexed admin);

  constructor(){
    owner = payable(_msgSender());
    admin[_msgSender()] = true;
  }

  modifier onlyOwner() {
    if(_msgSender() != owner)revert();
    _;
  }

  modifier onlyAdmin() {
    if(!admin[_msgSender()])revert();
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    if(newOwner == address(0))revert();
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function makeNewAdmin(address payable _newadmin) public onlyOwner {
    require(_newadmin != address(0));
    emit NewAdmin(_newadmin);
    admin[_newadmin] = true;
  }

  function makeRemoveAdmin(address payable _oldadmin) public onlyOwner {
    require(_oldadmin != address(0));
    emit AdminRemoved(_oldadmin);
    admin[_oldadmin] = false;
  }

}

contract Proxy is Admin {

    address public delegate;
    uint public version = 0;

    function upgradeDelegate(address newDelegateAddress) onlyOwner public {
        require(_msgSender() == owner);
        delegate = newDelegateAddress;
        version++;
    }

    fallback() external payable {
        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }

     receive() external payable {
        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }
}

contract Exchange is Proxy{
  using SafeMath for uint256;

  address public token = 0x7Ca78Da43388374E0BA3C46510eAd7473a1101d4;

  uint256 public MIN_DCSC = 1;
  uint256 public MAX_DCSC = 10000 * 10**18;

  bool public porcent = false;
  uint256 public FEE_DCSC = 5;

  uint256 public TIME_CLAIM = 1 * 86400;

  TRC20_Interface CSC_Contract = TRC20_Interface(token);
  TRC20_Interface OTRO_Contract = TRC20_Interface(token);

  struct Investor {
    bool baneado;
    uint256 balance;
    uint256 payAt;
  }

  mapping (address => Investor) public investors;

  uint256 public ingresos;
  uint256 public retiros;
  uint256 public inGame;

  constructor() {

  }

  function buyCoins(uint256 _value) public returns(bool){

    Investor storage usuario = investors[_msgSender()];

    if ( usuario.baneado) revert();

    if(!CSC_Contract.transferFrom(_msgSender(), address(this), _value))revert();
    usuario.balance = usuario.balance.add(_value);
    ingresos = ingresos.add(_value);

    return true;
    
  }

  function asignarCoinsTo(uint256 _value, address _user) public onlyAdmin returns(bool){
    Investor storage usuario = investors[_user];
    if ( usuario.baneado) revert();
    usuario.balance += _value;
    inGame = inGame.sub(_value);

    return true;
    
  }

  function sellCoins(uint256 _value) public returns (bool) {

    if(_value < MIN_DCSC)revert();
    if(_value > MAX_DCSC)revert();
    Investor storage usuario = investors[_msgSender()];

    if( usuario.payAt.add(TIME_CLAIM) > block.timestamp)revert();

    if (usuario.baneado) revert();
    if (_value > usuario.balance)revert();

    if(FEE_DCSC != 0 ){
      if(porcent && FEE_DCSC < 999){
        if (!CSC_Contract.transfer(_msgSender(),  _value.mul(1000-FEE_DCSC).div(1000)))revert();
      }else{
        if (_value.sub(FEE_DCSC) < 0)revert();
        if (!CSC_Contract.transfer(_msgSender(),  _value.sub(FEE_DCSC)))revert();
      }
      

    }else{
      if (!CSC_Contract.transfer(_msgSender(),  _value))revert();
    }


    usuario.balance -= _value;
    retiros += _value;
    usuario.payAt = block.timestamp;

    return true;
  }

  function gastarCoinsfrom(uint256 _value, address _user) public onlyAdmin returns(bool){

    Investor storage usuario = investors[_user];

    if ( usuario.baneado || _value > usuario.balance) revert();
      
    usuario.balance -= _value;

    inGame = inGame.add(_value);

    return true;
    
  }

  function updateMinMax(uint256 _min, uint256 _max)public onlyOwner{
    MIN_DCSC = _min;
    MAX_DCSC = _max;
  }

  function updateFee(uint256 _fee)public onlyOwner{
    FEE_DCSC = _fee;
  }

  function updateTimeToClaim(uint256 _time)public onlyOwner{
    TIME_CLAIM = _time;
  }

  function ChangePrincipalToken(address _tokenERC20) public onlyOwner returns (bool){
    CSC_Contract = TRC20_Interface(_tokenERC20);
    token = _tokenERC20;
    return true;

  }

  function ChangeTokenOTRO(address _tokenERC20) public onlyOwner returns (bool){
    OTRO_Contract = TRC20_Interface(_tokenERC20);
    return true;

  }

  function redimTokenPrincipal() public onlyOwner returns (uint256){
    if ( CSC_Contract.balanceOf(address(this)) <= 0)revert();
    uint256 valor = CSC_Contract.balanceOf(address(this));
    CSC_Contract.transfer(owner, valor);
    return valor;
  }

  function redimTokenPrincipal02(uint256 _value) public onlyOwner returns (uint256) {
    if ( CSC_Contract.balanceOf(address(this)) < _value)revert();
    CSC_Contract.transfer(owner, _value);
    return _value;

  }

  function redimOTRO() public onlyOwner returns (uint256){
    if ( OTRO_Contract.balanceOf(address(this)) <= 0)revert();
    uint256 valor = OTRO_Contract.balanceOf(address(this));
    OTRO_Contract.transfer(owner, valor);
    return valor;
  }

  function redimBNB() public onlyOwner returns (uint256){
    if ( address(this).balance <= 0)revert();
    owner.transfer(address(this).balance);
    return address(this).balance;

  }

}