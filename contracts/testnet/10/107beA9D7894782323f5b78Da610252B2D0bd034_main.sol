/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// File: CryptoToon/Context.sol



pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: CryptoToon/Ownable.sol



pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: CryptoToon/SafeMath.sol


pragma solidity >=0.4.4 <0.7.0;


// Implementacion de la libreria SafeMath para realizar las operaciones de manera segura
// Fuente: "https://gist.github.com/giladHaimov/8e81dbde10c9aeff69a1d683ed6870be"

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

// File: CryptoToon/ERC20.sol


pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;



interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf (address account) external view returns (uint256);
    function allowance(address owner,address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve (address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

contract CryptotoonsToken is IERC20 {
    string public constant name = "CryptotoonsToken";
    string public constant symbol = "CTTO";
    uint8 public constant decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    mapping (address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;
    uint256 totalSupply_;
    
    using SafeMath for uint256;
    
    constructor (uint256 total) public{
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }
    
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    
    function increaseTotalSuply(uint newTokens) public{
        totalSupply_ += newTokens;
        balances[msg.sender] += newTokens;
    }
    
    function balanceOf (address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender,receiver,numTokens);
        return true;
    } 
    
    function approve (address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance (address owner, address delegate) public override view returns (uint){
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require (numTokens <= balances[owner]);
        require (numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner,buyer,numTokens);
        return true;
    }
    
}
// File: CryptoToon/Main.sol


pragma solidity >=0.4.4 <0.7.0;




contract main {
    
    // Instancia del contrato token 
    CryptotoonsToken private token;
    
    // Owner del contrato 
    address public owner;
    
    // Direccion del Smart Contract 
    address public contrato;
    
    // Constructor 
    constructor () public {
        token = new CryptotoonsToken(1000000);
        owner = msg.sender;
        contrato = address(this);
    }
    
    // Obtenemos la direccion del Owner
    function getOwner() public view returns (address) {
        return owner;
    }
    
    // Obtenemos la direccion del Smart Contract
    function getContract() public view returns (address){
        return contrato;
    }
    
    // Establecer el precio de un token 
    function PrecioTokens(uint _numTokens) internal pure returns (uint) {
        // Conversion de Tokens a ethers: 1 token -> 1 Ether
        return _numTokens*(0.00027 ether);
    }

    // Compramos tokens mediante: direccion de destino y cantidad de tokens 
    function send_tokens (address _destinatario, uint _numTokens) public payable {
        // Filtrar el numero de tokens a comprar
        require (_numTokens <= 10000, "La cantidad de tokens es demasiado alta.");
        // Establecer el precio de los tokens
        uint coste = PrecioTokens(_numTokens);
        // Se evalua la cantidad de ethers que paga el cliente
        require(msg.value >= coste, "Compra menos tokens o paga con más ethers");
        // Diferencia de lo que el cliente paga 
        uint returnValue = msg.value - coste;
        // Retorna la cantidad de tokens determinada
        msg.sender.transfer(returnValue);
        // Obtener el balance de tokens disponibles
        uint Balance = balance_total();
        require(_numTokens <= Balance, "Compra un número menor de tokens");
        // Transferencia de los tokens al destinatario
        token.transfer(_destinatario, _numTokens);
    }

    // Generacion de tokens al contrato
    function GeneraTokens(uint _numTokens) public onlybyOwner(){
        token.increaseTotalSuply(_numTokens);
    }

    // Modificador que permita la ejecución tan solo por el owner
    modifier onlybyOwner() {
        require(msg.sender == owner, "No tienes permisos para esta funcion");
        _;
    }

    function withdraw() payable onlybyOwner external {
      msg.sender.transfer(address(this).balance);
    }

    function moneySmartContract() public view returns (uint256){
        return address(this).balance;
    }

    // Obtenemos el balance de tokens de una direccion 
    function balance_direccion(address _direccion) public view returns (uint){
        return token.balanceOf(_direccion);
    }
    
    // Obtenemos el balance de tokens total del smart contract 
    function balance_total() public view returns (uint) {
        return token.balanceOf(contrato);
    }
    
}