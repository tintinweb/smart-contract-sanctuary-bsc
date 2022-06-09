/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: Apache-2.0

interface TRC20_Interface {
  function allowance(address _owner, address _spender) external view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _value) external returns (bool);
  function transfer(address direccion, uint cantidad) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function decimals() external view returns(uint);
}
interface OldInfinity_Interface {
  struct Deposito2 {
    uint256 inicio;
    uint256 value;
    uint256 amount;
    bool infinity;
  }
  struct Investor2 {
    bool registered;
    uint256 membership;
    uint256 balanceRef;
    uint256 totalRef;
    uint256 invested;
    uint256 paidAt;
    uint256 paidAt2;
    uint256 withdrawn;
    uint256 directos;
    string data;
    Deposito2[] depositos;
    uint256 blokesDirectos;
  }
    function investors(address) external view returns(Investor2 memory);
    function withdrawable(address any_user, bool _infinity) external view returns (uint256);
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
contract Admin {
  address payable public owner;
  mapping (address => bool) public admin;
  mapping (address => bool) public admin2;
  constructor(){
    owner = payable(msg.sender);
    admin[msg.sender] = true;
  }
  modifier onlyAdmin() {
    if(!admin[msg.sender])revert();
    _;
  }
  function makeNewAdmin(address payable _newadmin) public onlyAdmin {
    if(_newadmin == address(0))revert();
    admin[_newadmin] = true;
  }
  function makeRemoveAdmin(address payable _oldadmin) public onlyOwner {
    if(_oldadmin == address(0))revert();
    admin[_oldadmin] = false;
  }
  modifier onlyAdmin2() {
    if(!admin[msg.sender])revert();
    _;
  }
  function makeNewAdmin2(address payable _newadmin) public onlyAdmin {
    if(_newadmin == address(0))revert();
    admin2[_newadmin] = true;
  }
  function makeRemoveAdmin2(address payable _oldadmin) public onlyOwner {
    if(_oldadmin == address(0))revert();
    admin2[_oldadmin] = false;
  }
  modifier onlyOwner() {
    if(msg.sender != owner)revert();
    _;
  }
  function transferOwnership(address payable newOwner) public onlyOwner {
    if(newOwner == address(0))revert();
    admin[owner] = false;
    owner = newOwner;
    admin[newOwner] = true;
  }
}
contract Proxy is Admin {
    address public implementation;
    uint256 public upgraded;
    function upgradeImplementation(address _imp) external onlyOwner {
        implementation = _imp;
        upgraded++;
    }
    function _delegate(address _imp) internal virtual {
      assembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 {revert(0, returndatasize())}
        default {return(0, returndatasize())}
      }
    }
    fallback() external payable {
        _delegate(implementation);
    }
    receive() external payable {
        _delegate(implementation);
    }
}
contract InfinitySystemV2 is Proxy{
  using SafeMath for uint256;
  address public tokenPricipal = 0x55d398326f99059fF775485246999027B3197955;

  OldInfinity_Interface Anterior_Contrato = OldInfinity_Interface(0x47DA06e10CF59f00cCE3Aeb66F9779B5E1dA2b7f);
  TRC20_Interface USDT_Contract = TRC20_Interface(tokenPricipal);

  struct Deposito {
    uint256 inicio;
    uint256 value;
    uint256 amount;
  }

  struct Investor {
    bool registered;
    uint256 membership;
    uint256 balanceRef;
    uint256 balanceInfinit;
    uint256 totalRef;
    uint256 invested;
    uint256 paidAt;
    uint256 paidAt2;
    uint256 withdrawn;
    uint256 directos;
    string data;
    uint256 blokesDirectos;
  }

  uint public version = 2;
  uint256 public MIN_RETIRO = 5 * 10**18;
  uint256 public PRECIO_BLOCK = 50 * 10**18;
  uint256 public PRECIO_BLOCK_infinity = 30 * 10**18;
  uint256[] public primervez = [50, 30, 20, 10, 10];
  uint256[] public porcientos = [15, 9, 6, 3, 3];
  uint256[] public infinity = [5, 3, 2, 1, 1];
  bool[] public baserange = [false,false,false,false,false,false,false,false,false,false,false];
  uint256[] public gananciasRango = [75*10**18,150*10**18,375*10**18,750*10**18, 1500*10**18, 3750*10**18, 7500*10**18, 15000*10**18, 50000*10**18, 150000*10**18, 250000*10**18];
  uint256[] public puntosRango = [100*50*10**18, 200*50*10**18, 500*50*10**18, 1000*50*10**18, 2000*50*10**18, 5000*50*10**18, 10000*50*10**18, 20000*50*10**18, 100000*50*10**18, 300000*50*10**18, 500000*50*10**18];
  bool public onOffWitdrawl = true;
  uint256 public duracionMembership = 365;
  uint256 public dias = 900;
  uint256 public unidades = 86400;
  uint256 public porcent = 240;
  uint256 public descuento = 100;
  uint256 public personas = 2;
  uint256 public totalInvestors = 1;
  uint256 public totalInvested;
  uint256 public totalRefRewards;
  uint256 public totalRoiWitdrawl;
  uint256 public totalRefWitdrawl;
  uint256 public totalTeamWitdrawl;
  mapping (address => Investor) public investors;
  mapping (address => Deposito[]) public blokes;
  mapping (address => Deposito[]) public infinityBlokes;
  mapping (address => Deposito[]) public oldBlokes;
  mapping (address => address) public padre;
  mapping (address => address[]) public hijo;
  mapping (uint256 => address) public idToAddress;
  mapping (address => uint256) public addressToId;
  mapping (address => bool[]) public rangoReclamado;
  mapping (uint256 => uint256) public blockesRango;
  mapping (uint256 => uint256) public usdtRetirado;
  mapping (address => uint256) public adRoi;
  mapping (address => uint256) public adInfinity;
  uint256 public lastUserId = 1;
  address[] public walletFee = [0x4490566647735e8cBCe0ce96efc8FB91c164859b,0xd0f2fCDf7d399205E9709C6D0fBeE434335e42DD];
  uint256[] public valorFee = [5,95];
  uint256 public precioRegistro = 30 * 10**18;
  address[] public wallet = [0x17a7e5b2D9b5D191f7307e990e630C9DC18E1396,0xAFE9d039eC7D4409b1b8c2F1556f20843079B728,0x8DD59f5670e9809c8a800A49d1Ff1CEA471c53Da];
  uint256[] public valor = [70, 8, 5];

  constructor() {
    Investor storage usuario = investors[owner];
    usuario.registered = true;
    usuario.membership = block.timestamp + duracionMembership*unidades*1000000000000000000;
    rangoReclamado[msg.sender] = baserange;
    idToAddress[0] = msg.sender;
    addressToId[msg.sender] = 0;
  }
  function setPrecioRegistro(uint256 _precio) public onlyOwner returns(bool){
    precioRegistro = _precio;
    return true;
  }
  function setduracionMembership(uint256 _duracionMembership) public onlyOwner returns(bool){
    duracionMembership = _duracionMembership;
    return true;
  }
  function setDescuento(uint256 _descuento) public onlyOwner returns(bool){
    descuento = _descuento;
    return true;
  }
  function setWalletstransfers(address[] memory _wallets, uint256[] memory _valores) public onlyOwner returns(bool){
    wallet = _wallets;
    valor = _valores;
    return true;
  }
  function setWalletFee(address[] memory _wallet, uint256[] memory _fee ) public onlyOwner returns(bool){
    walletFee = _wallet;
    valorFee = _fee;
    return true;
  }
  function setRangos(bool[] memory _baserange ,uint256[] memory _gananciasRango , uint256[] memory _puntosRango ) public onlyOwner returns(bool){
    baserange = _baserange;
    gananciasRango = _gananciasRango;
    puntosRango = _puntosRango;
    rangoReclamado[msg.sender] = baserange;
    return true;
  }
  function baserangelength() public view returns(uint256){
    return baserange.length;
  }
  function setMIN_RETIRO(uint256 _min) public onlyOwner returns(uint256){
    MIN_RETIRO = _min;
    return _min;
  }
  function ChangeTokenPrincipal(address _tokenTRC20) public onlyOwner returns (bool){
    USDT_Contract = TRC20_Interface(_tokenTRC20);
    tokenPricipal = _tokenTRC20;
    return true;
  }
  function tiempo() public view returns (uint256){
     return dias.mul(unidades);
  }
  function setPorcientos(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){
    porcientos[_nivel] = _value;
    return porcientos;
  }
  function setPorcientosSalida(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){
    infinity[_nivel] = _value;
    return infinity;
  }
  function setPrimeravezPorcientos(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){
    primervez[_nivel] = _value;
    return primervez;
  }
  function setPriceBlock(uint256 _value, bool _infinity) public onlyOwner returns(bool){
    if(_infinity){
      PRECIO_BLOCK_infinity = _value;
    }else{
      PRECIO_BLOCK = _value;
    }
    return true;
  }
  function setTiempo(uint256 _dias) public onlyAdmin returns(uint256){
    dias = _dias;
    return (_dias);
  }
  function setTiempoUnidades(uint256 _unidades) public onlyOwner returns(uint256){
    unidades = _unidades;
    return (_unidades);
  }
  function controlWitdrawl(bool _true_false) public onlyAdmin returns(bool){
    onOffWitdrawl = _true_false;
    return (_true_false);
  }
  function setRetorno(uint256 _porcentaje) public onlyAdmin returns(uint256){
    porcent = _porcentaje;
    return (porcent);
  }
  function setContratoMigracion(address _contarct) public onlyOwner returns(bool){
    Anterior_Contrato = OldInfinity_Interface(_contarct);
    return true;
  }
  function column(address yo, uint256 _largo) public view returns(address[ ] memory) {
    address[] memory res;
    for (uint256 i = 0; i < _largo; i++) {
      res = actualizarNetwork(res);
      res[i] = padre[yo];
      yo = padre[yo];
    }
    return res;
  }
  function columnHijos(address yo) public view returns(address[] memory) {
    address[] memory res;
    for (uint256 i = 0; i < hijo[yo].length; i++) {
      res = actualizarNetwork(res);
      res[i] = hijo[yo][i];
    }
    return res;
  }
  function depositos(address _user, bool _infinity) public view returns(uint256[] memory, uint256[] memory, bool[] memory, uint256 ){
    Investor memory usuario = investors[_user];
    Deposito[] memory dep = blokes[_user];
    uint256[] memory amount;
    uint256[] memory time;
    bool[] memory activo;
    uint256 total;
    uint since;
    uint till;
    if(_infinity){
      dep = infinityBlokes[_user];
    }
    uint contador = dep.length;
    for (uint i = 0; i < contador; i++) {
      amount = actualizarArrayUint256(amount);
      time = actualizarArrayUint256(time);
      activo = actualizarArrayBool(activo);
      time[time.length-1] = dep[i].inicio;
      till = block.timestamp > dep[i].inicio + tiempo() ? dep[i].inicio + tiempo() : block.timestamp;
      if (_infinity) {
        since = usuario.paidAt2 > dep[i].inicio ? usuario.paidAt2 : dep[i].inicio;
      }else{
        since = usuario.paidAt > dep[i].inicio ? usuario.paidAt : dep[i].inicio;
      }    
      if (since != 0 && since < till ) {
        total += dep[i].amount * (till - since) / tiempo() ;
        activo[activo.length-1] = true;
      } 
      amount[amount.length-1] = dep[i].amount;    
    }
    return (amount, time, activo, total);
  }
  function rewardReferers(address yo, uint256 amount, uint256[] memory array) internal {
    address[] memory referi;
    referi = column(yo, array.length);
    uint256 a;
    uint256 b;
    Investor storage usuario;
    for (uint256 i = 0; i < array.length; i++) {
      if (array[i] != 0) {
        usuario = investors[referi[i]];
        if (usuario.registered && usuario.membership >= block.timestamp ){
          if ( referi[i] != address(0) ) {

            a = amount.mul(array[i]).div(1000);
            b = amount.mul(porcientos[i]).div(100);

            usuario.balanceRef += a;
            usuario.totalRef += a;
            usuario.balanceInfinit += b;

            totalRefRewards += a;
            
          }else{
            break;
          }
        }
      } else {
        break;
      }
    }
  }

  function totalRange() public view returns (uint256){
    uint256 cantidad;
    for (uint256 a = 0; a < lastUserId; a++) {
      for (uint256 index = 0; index < gananciasRango.length; index++) {
        if(blockesRango[a] >= puntosRango[index] ){
          cantidad += gananciasRango[index];
        }
      }
    }
    return cantidad;
  }

  function totalRangeWitdrawl() public view returns (uint256){
    uint256 cantidad;
    for (uint256 a = 0; a < lastUserId; a++) {
      cantidad += usdtRetirado[a];
    }
    return cantidad;
  }
  function _asignarBloke(address _user ,uint256 _value, bool _infinity) internal returns (bool){
    if(_value <= 0)return false;
    if(_infinity){
      infinityBlokes[_user].push(Deposito(block.timestamp, _value, _value));
    }else{
      blokes[_user].push(Deposito(block.timestamp, (_value.mul(porcent)).div(100), (_value.mul(porcent)).div(100)));
    }
    return true;
  }
  function updateBloke(address _user ,uint256 _value, bool _add) public onlyAdmin{
    if(_value <= 0)revert();
    if(_add){
      investors[_user].invested = investors[_user].invested.add(_value);
      if (padre[_user] != address(0) ){
        investors[padre[_user]].blokesDirectos += _value;
        blockesRango[addressToId[padre[_user]]] += _value;
        totalInvested += _value;
      }
    }else{
      investors[_user].invested = investors[_user].invested.sub(_value);
    }
  }
  function updateBlokeRange(address _user ,uint256 _value, bool _add) public onlyAdmin{
    if(_value <= 0)revert();
    if(_add){
      investors[_user].blokesDirectos = investors[_user].blokesDirectos.add(_value);
    }else{
      investors[_user].blokesDirectos = investors[_user].blokesDirectos.sub(_value);
    }
  }
  function asignarBlokePago(address _user ,uint256 _value) public onlyOwner returns (bool){
    if(_value <= 0)revert();
    if (padre[_user] != address(0) ){
      rewardReferers(_user, _value, primervez);
      investors[padre[_user]].blokesDirectos += _value;
      blockesRango[addressToId[padre[_user]]] += _value;
    }
    investors[_user].invested += _value;
    totalInvested += _value;
    return _asignarBloke(_user , _value, false);
  }
  function asignarBlokePago2(address _user ,uint256 _value, bool _infinit) public onlyAdmin2 returns (bool){
    if(_value <= 0)revert();
    if (padre[_user] != address(0) ){
      rewardReferers(_user, _value, primervez);
      investors[padre[_user]].blokesDirectos += _value;
      blockesRango[addressToId[padre[_user]]] += _value;
    }
    investors[_user].invested += _value;
    totalInvested += _value;
    return _asignarBloke(_user , _value, _infinit);
  }
  function asignarMembership(address _user, address _sponsor) public onlyAdmin returns (bool){
    if (_sponsor == address(0) )revert();
    Investor storage usuario = investors[_user];
    if(!usuario.registered){
      usuario.registered = true;
      usuario.membership = block.timestamp + duracionMembership*unidades;
      padre[_user] = _sponsor;
      investors[_sponsor].directos++;
      hijo[_sponsor].push(_user);
      totalInvestors++;
      rangoReclamado[_user] = baserange;
      idToAddress[lastUserId] = _user;
      addressToId[_user] = lastUserId;
      lastUserId++;
    }else{
      usuario.membership = usuario.membership + duracionMembership*unidades;
    }
    return true;
  }

  function registro(address _sponsor, string memory _datos) public{
    Investor storage usuario = investors[msg.sender];
    if(_sponsor == address(0))revert();
    if(precioRegistro > 0){
      if( USDT_Contract.allowance(msg.sender, address(this)) < precioRegistro)revert();
      if( !USDT_Contract.transferFrom(msg.sender, address(this), precioRegistro))revert();
    }
    for (uint256 i = 0; i < walletFee.length; i++) {
      USDT_Contract.transfer(walletFee[i], precioRegistro.mul(valorFee[i]).div(100));
    }
    if(!usuario.registered){
      usuario.registered = true;
      usuario.membership = block.timestamp + duracionMembership*unidades;
      padre[msg.sender] = _sponsor;
      investors[_sponsor].directos++;
      hijo[_sponsor].push(msg.sender);
      totalInvestors++;
      rangoReclamado[msg.sender] = baserange;
      idToAddress[lastUserId] = msg.sender;
      addressToId[msg.sender] = lastUserId;
      lastUserId++;
    }else{
      usuario.membership = usuario.membership + duracionMembership*unidades;
    }
    usuario.data = _datos;

  }
  function inMigracion(address _user, address _sponsor) public{
    Investor storage usuario = investors[_user];
    if(!usuario.registered){
      usuario.registered = true;
      usuario.membership = block.timestamp+duracionMembership*unidades;
      padre[_user] = _sponsor;
      investors[_sponsor].directos++;
      hijo[_sponsor].push(_user);
      totalInvestors++;
      rangoReclamado[_user] = baserange;
      idToAddress[lastUserId] = _user;
      addressToId[_user] = lastUserId;
      lastUserId++;
      usuario.paidAt = block.timestamp;
      usuario.paidAt2 = block.timestamp;
      uint256 _value1 = Anterior_Contrato.withdrawable(_user, false).mul(100).div(240);
      if(_value1 > 0){
        usuario.invested = _value1;
        if (padre[_user] != address(0) && padre[_user] != _user ){
          investors[padre[_user]].blokesDirectos += _value1;
          blockesRango[addressToId[padre[_user]]] += _value1;
          
        }
        totalInvested += _value1;
        _asignarBloke(_user , _value1, false);
      }

      uint256 _value2 = Anterior_Contrato.withdrawable(_user, true).mul(100).div(240);
      if(_value2 > 0){
        _asignarBloke(_user , _value2, true);
      }
    }
  }
  function addRoi(address _user, bool _sumar, uint256 _value) public onlyAdmin2 {
    if(_sumar){
      adRoi[_user] = adRoi[_user].add(_value);
    }else{
      adRoi[_user] = adRoi[_user].sub(_value);
    }
  }
  function addInfinity(address _user, bool _sumar, uint256 _value) public onlyAdmin2 {
    if(_sumar){
      adInfinity[_user] = adInfinity[_user].add(_value);
    }else{
      adInfinity[_user] = adInfinity[_user].sub(_value);
    }
  }
  function addReferal(address _user, bool _sumar, uint256 _value) public onlyAdmin2 {
    Investor storage usuario = investors[_user];
    if(_sumar){
      usuario.balanceRef = (usuario.balanceRef).add(_value);
      totalRefRewards = totalRefRewards.add(_value);
    }else{
      usuario.balanceRef = (usuario.balanceRef).sub(_value);
      totalRefRewards = totalRefRewards.sub(_value);
    }
  }
  
  function buyBlocks(uint256 _value) public {
    if(_value < PRECIO_BLOCK)revert();
    Investor storage usuario = investors[msg.sender];
    if (!usuario.registered)revert();
    if (block.timestamp >= usuario.membership )revert();
    if( USDT_Contract.allowance(msg.sender, address(this)) < _value)revert();
    if( !USDT_Contract.transferFrom(msg.sender, address(this), _value) )revert();
    if (padre[msg.sender] != address(0) ){
      rewardReferers(msg.sender, _value, primervez);
      Investor storage sponsor = investors[padre[msg.sender]];
      sponsor.blokesDirectos += _value;
      blockesRango[addressToId[padre[msg.sender]]] += _value;
    }
    blokes[msg.sender].push(Deposito(block.timestamp,(_value.mul(porcent)).div(100),(_value.mul(porcent)).div(100)));
    usuario.invested += _value;
    totalInvested += _value;
    for (uint256 i = 0; i < wallet.length; i++) {
      USDT_Contract.transfer(wallet[i], _value.mul(valor[i]).div(100));
    }
    if(usuario.balanceInfinit >= PRECIO_BLOCK_infinity) buyInfinityBlock(usuario.balanceInfinit);
  }
  function buyInfinityBlock(uint256 _value) public {
    if(_value < PRECIO_BLOCK_infinity)revert();
    Investor storage usuario = investors[msg.sender];
    if (!usuario.registered || block.timestamp >= usuario.membership || _value == 0 ||usuario.balanceInfinit < _value)revert();
    usuario.balanceInfinit -= _value;
    if (padre[msg.sender] != address(0) ){
      rewardReferers(msg.sender, _value, primervez);
      investors[padre[msg.sender]].blokesDirectos += _value;
      blockesRango[addressToId[padre[msg.sender]]] += _value;
    }
    infinityBlokes[msg.sender].push(Deposito(block.timestamp,_value,_value));
  }
  function withdrawableRange(address any_user) public view returns (uint256 amount) {
    Investor memory user = investors[any_user];
    for (uint256 index = 0; index < gananciasRango.length; index++) {
      if(user.blokesDirectos >= puntosRango[index] && !rangoReclamado[msg.sender][index]){
       amount = gananciasRango[index];
      }
    }
  }
  function newRecompensa() public {
    uint256 amount = withdrawableRange(msg.sender);
    if ( amount <= 0 )revert();
    Investor memory user = investors[msg.sender];
    for (uint256 index = 0; index < gananciasRango.length; index++) {
      if(user.blokesDirectos >= puntosRango[index] && !rangoReclamado[msg.sender][index]){
        USDT_Contract.transfer(msg.sender, gananciasRango[index]);
        rangoReclamado[msg.sender][index] = true;
        usdtRetirado[addressToId[msg.sender]] += gananciasRango[index];
      }
    }
  }
  function actualizarNetwork(address[] memory oldNetwork)public pure returns ( address[] memory) {
    address[] memory newNetwork =   new address[](oldNetwork.length+1);
    for(uint i = 0; i < oldNetwork.length; i++){
        newNetwork[i] = oldNetwork[i];
    }
    return newNetwork;
  }
  function actualizarArrayBool(bool[] memory old)public pure returns ( bool[] memory) {
    bool[] memory newA =   new bool[](old.length+1);
    for(uint i = 0; i < old.length; i++){
        newA[i] = old[i];
    }
    return newA;
  }
  function actualizarArrayUint256(uint256[] memory old)public pure returns ( uint256[] memory) {
    uint256[] memory newA =   new uint256[](old.length+1);
    for(uint i = 0; i < old.length; i++){
        newA[i] = old[i];
    }
    return newA;
  }
  function allnetwork( address[] memory network ) public view returns ( address[] memory) {
    Investor storage user;
    for (uint i = 0; i < network.length; i++) {
      user = investors[network[i]];
      address userLeft = address(0);
      for (uint u = 0; u < network.length; u++) {
        if (userLeft == network[u]){
          userLeft = address(0);
        }
      }
      if( userLeft != address(0) ){
        network = actualizarNetwork(network);
        network[network.length-1] = userLeft;
      }
    }
    return network;
  }
  function withdrawable(address any_user, bool _infinity) public view returns (uint256) {
    uint256[] memory amount;
    uint256[] memory time;
    bool[] memory activo;
    uint256 total;
    (amount, time, activo, total) = depositos(any_user, _infinity);
    if(_infinity){
      return total.add(adInfinity[any_user]);
    }else{
      return total.add(adRoi[any_user]);
    }
  }
  function withdraw() public {
    if (!onOffWitdrawl)revert();
    Investor storage usuario = investors[msg.sender];
    uint256 _value = withdrawable(msg.sender, false);
    if( USDT_Contract.balanceOf(address(this)) < _value )revert();
    if( _value < MIN_RETIRO )revert();
    USDT_Contract.transfer(msg.sender, _value.mul(descuento).div(100));
    usuario.withdrawn += _value;
    usuario.paidAt = block.timestamp;
    delete adRoi[msg.sender];
    totalRoiWitdrawl += _value;
  }
  function withdraw2() public {
    if (!onOffWitdrawl)revert();
    Investor storage usuario = investors[msg.sender];
    uint256 _value = withdrawable(msg.sender, true);
    if( USDT_Contract.balanceOf(address(this)) < _value )revert();
    if( _value < MIN_RETIRO )revert();
    USDT_Contract.transfer(msg.sender, _value.mul(descuento).div(100));
    usuario.withdrawn += _value;
    usuario.paidAt2 = block.timestamp;
    delete adInfinity[msg.sender];
    totalRefWitdrawl += _value;
  }
  function withdrawTeam() public {
    Investor storage usuario = investors[msg.sender];
    uint256 _value = usuario.balanceRef;
    if( USDT_Contract.balanceOf(address(this)) < _value )revert();
    if( _value < MIN_RETIRO )revert();
    USDT_Contract.transfer(msg.sender, _value.mul(descuento).div(100));
    delete usuario.balanceRef;
    totalTeamWitdrawl += _value;
  }
  function redimTokenPrincipal02(uint256 _value) public onlyOwner returns (uint256) {
    if ( USDT_Contract.balanceOf(address(this)) < _value)revert();
    USDT_Contract.transfer(owner, _value);
    return _value;
  }
  function redimBNB() public onlyOwner returns (uint256){
    owner.transfer(address(this).balance);
    return address(this).balance;
  }
}