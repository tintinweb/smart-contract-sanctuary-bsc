/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: Apache-2.0

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) return 0;
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

contract MarketV2 is Context, Admin{
  using SafeMath for uint256;
  
  address payable public devsWallet = payable(0x1C261DE3DA6873c225079c73d7bA1B111eb9a5b3);
  address payable public stakingContract;
  uint256 public ventaPublica = 1653152400;
  uint256 public MAX_BNB = 1 * 10**18;
  uint256 public TIME_CLAIM = 1 * 86400;
  uint256[] public niveles = [3, 2, 1];

  struct Investor {
    uint256 balance;
    uint256 payAt;
  }

  struct Item {
    string nombre;
    uint256 valor;
    bool stakear;
  }
  
  mapping (address => address) public upline;
  mapping (address => Investor) public investors;
  mapping (address => Item[]) public inventario;
  
  Item[] public items;

  constructor() {}

  function referRedward(address _user, uint256 _value) private returns(uint entregado){

    for (uint256 index = 0; index < niveles.length; index++) {
      if(upline[_user] == address(0))break;
      investors[upline[_user]].balance += _value.mul(niveles[index]).div(100);
      _user = upline[_user];

      entregado += niveles[index];
      
    }
    return entregado;
  }
  
  function buyItem(uint256 _id, address _upline) public payable returns(bool){

    Item memory item = items[_id];
    if( msg.value < item.valor )revert("por favor envie suficiente bnb");

    if(block.timestamp < ventaPublica)revert("no es tiempo de la venta publica");

    devsWallet.transfer(msg.value.mul(10).div(100));

    if(_upline != address(0) && upline[_msgSender()] == address(0) && _upline != _msgSender()){
      upline[_msgSender()] = _upline;
    }
    if(upline[_msgSender()] != address(0)){
      uint256 envio = 90;
      stakingContract.transfer(msg.value.mul((envio).sub(referRedward(_msgSender(), item.valor))).div(100));
    }else{
      stakingContract.transfer(msg.value.mul(90).div(100));
    }
    inventario[_msgSender()].push(item);
    return true;
  
  }

   function buyCoins() public payable returns(bool){

    Investor storage usuario = investors[_msgSender()];
  
    uint _valor = msg.value;
    usuario.balance += _valor;
    devsWallet.transfer(_valor.mul(2).div(100));
    stakingContract.transfer(_valor.mul(8).div(100));

    return true;
    
  }

  function sellCoins(uint256 _value) public returns (bool) {
      Investor storage usuario = investors[_msgSender()];

      if (_value > usuario.balance)revert("no tienes ese saldo");
      if (_value > MAX_BNB)revert("maximo 1 bnb por dia");
      if (usuario.payAt+TIME_CLAIM > block.timestamp ) revert("no es tiempo de retirar");

      if (address(this).balance < _value) revert("no hay balance para transferir");
      if (!payable(_msgSender()).send(_value)) revert("fallo la transferencia");

      usuario.balance -= _value;
      usuario.payAt = block.timestamp;

      return true;
  }

  function addItem(string memory _nombre, uint256 _value, bool _stakear) public onlyOwner returns(bool){

    items.push(
      Item(
        {
          nombre: _nombre,
          valor: _value,
          stakear: _stakear
        }
      )
    );

    return true;
    
  }

  function editItem(uint256 _id, string memory _nombre, uint256 _value, bool _stakear) public onlyOwner returns(bool){

    items[_id] = Item(
    {
      nombre: _nombre,
      valor: _value,
      stakear: _stakear
    });

    return true;
    
  }

  function NoStakingCard(address _user,uint256 _carta)public returns(bool){

    if (_msgSender() != stakingContract)revert();
    Item[] storage invent = inventario[_user];
    if(invent[_carta].stakear == true){
      invent[_carta].stakear = false;
      return true;

    }else{
      return false;

    }
  }

  function consultarCarta(address _user, uint _carta) public view returns(uint256) {
    Item[] memory invent = inventario[_user];
    return invent[_carta].stakear == true ? invent[_carta].valor : 0 ;
  }

  function verInventario(address _user) public view returns(Item[] memory invent){
    invent = inventario[_user];
  }

  function largoInventario(address _user) public view returns(uint256){
    Item[] memory invent = inventario[_user];
    return invent.length;
  }

  function largoItems() public view returns(uint256){
    return items.length;
  }
  
  function UpdateDEVSWallet(address payable _adminWallet) public onlyOwner returns (bool){
    admin[devsWallet] = false;
    devsWallet = _adminWallet;
    admin[_adminWallet] = true;
    return true;
  }

  function UpdateStakingContract(address payable _stakingContract) public onlyOwner returns (bool){
    if(stakingContract != address(0)) revert();
    admin[stakingContract] = false;
    stakingContract = _stakingContract;
    admin[_stakingContract] = true;
    return true;

  }

}