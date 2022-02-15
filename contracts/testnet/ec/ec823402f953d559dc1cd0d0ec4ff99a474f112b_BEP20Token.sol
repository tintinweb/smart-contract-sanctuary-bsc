/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

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
    this; // Silencia el state mutability warning sin generar bytecode- checa https://github.com/ethereum/solidity/issues/2691
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
    // Gas optimization: Esto es mas que barato que el uso de require 'a' que no sea cero, pero el beneficio se pierde si B es probado
    // checa: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow"); // muy bueno

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }


  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
  address private _owner; // guardamos de forma privada lo que sera el owner del contrato

// Este evento emitira la transferencia de un owner a otro 
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Se inicia el contrato estableciendo el deployer como el nuevo owner 
   */
  constructor () internal {
    address msgSender = _msgSender(); // Acuda de forma algo primitiva a la funcion en context la cual retorna al msg.sender
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender); // se especificala trannsferencia desde la direccion 0 al msg.sender
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Only owner, para que solo el owner pueda ejecutar todo gracias al onlyOwner
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _; // Recuerda esto importante, el _; para que se ejecute las demas lineas de codigo 
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0)); 
    _owner = address(0); //Nota como se puede cambiar facilito a otra que tengas tu
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner); // Aqui se ejecuta la funcion de abajo y de cumplirse, se ejecuta todo
  }

  function _transferOwnership(address newOwner) internal { // Recuerda que cuando es internak solo puede ser heredada
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// Este es el contrato inicial, este hereda de cada uno de los que hicimos por partes, inclusive se especifica cada una de las librerias
contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256; // "usando la libreria safemath para(for) uint256(numeros sin signo)"

  mapping (address => uint256) private _balances; // Mapping que lleva el balance de cada direccion en tokens

  mapping (address => mapping (address => uint256)) private _allowances;


  uint256 private _totalSupply; // Variable que lleva el conteo del suministro total de la moneda
  uint8 private _decimals; // Variable que lleva el conteo de los decimales 
  string private _symbol; //variable que lleva el symbolo
  string private _name; //variable que lleva el nombre

  constructor(string memory tokenName, string memory tokenSymbol,uint8 decimals, uint TotalSupply) public {
    _name = tokenName;
    _symbol = tokenSymbol;
    _decimals = decimals;
    _totalSupply = TotalSupply;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /** ESTAS SON LAS FUNCIONES QUE LE HICIMOS EL INTERFACE, AHORA LAS VAMOS A RELLENAR 
   * @dev Retorna el owner
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account]; // Recurre al mapping el cual parece ser algo universal para el reconocimiento de tokens
  }

 
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount); // Esta funcion llama a otro que esta unas 100 lineas mas adelante...
    return true; 

  }


  function allowance(address owner, address spender) external view returns (uint256) { 
    return _allowances[owner][spender]; 
    // Igualmente esta funcion es como una especie de llamadora a otra que esta lineas adelante
  }


  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount); // Se utiliza el msg.sender para que la persona misma pueda permitirselo
    return true; // Esta funcion es una llamadora a otra que esta especificada mas abajo 
  }


  function transferFrom(address  sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

 
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }


  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }
  function burn(address account, uint256 amount)public onlyOwner returns(bool){
  _burn(account, amount); 
      return true;
  }
function burnFrom(address account, uint256 amount)public onlyOwner returns(bool){
_burn(account, amount);
return true; 
}

//Funciones madre
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);

  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);

  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);

  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);

  }
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}