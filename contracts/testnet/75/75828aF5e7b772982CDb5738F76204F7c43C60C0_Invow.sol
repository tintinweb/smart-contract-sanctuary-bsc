/* //
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InvowContract is ERC20 {
    constructor() ERC20("Invow Token", "INV"){
        _mint(msg.sender, 1000000 * 10 ** 18);
    } 
} */

//------------------------------------------------------------------------
//------------------------------------------------------------------------

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";
import "./SafeMath.sol";

contract Invow {

    // ------------------------------ initial declarations ------------------------------

    // instacia del contrato token
    ERC20Basic private token;

    // direccion de disney
    address payable public owner;

    // estructura de una aventura
    struct Adventure {
        address owner;
        string title;
        uint fundingGoal;
        uint amountRaised;
        uint256 createdAt;
    }

    // estructura de un cliente
    struct Client {
        address id;
        uint256 amount_contribuited;
    }

    // array para almacenar los nombres de la aventuras
    string [] Adventures;

    // relacion entre una aventura y la estructura de datos de una atraccion con ese nombre
    mapping (string => Adventure) public titleWithAdventure;

    // relacion entre la aventura y sus aportantes
    mapping (string => Client[]) public contributionsToAdventure;

    // EVENTOS
    // evento cuando se contribuye a una aventura, emito el id de la aventura
    event contribution(
        address sender,
        string adventure,
        uint256 amount
    );

    // evento cuando una aventura alcanza el monto objetivo
    event amountReached(uint256);

    // evento cuando se crea una aventura
    event new_adventure(
        string _adventureTitle,
        uint fundingGoal
    );

    constructor () {
        // indicamos el numero de tokens que invow va crear cuando creemos el contrato
        token = new ERC20Basic(1000);
        owner = payable(msg.sender);
    }

    // ------------------------------ tokens gestion ------------------------------

    // function para establecer el precio de un token 
    function precioToken(uint _numTokens) internal pure returns(uint){

        // convierto tokens a ethers: 1 token -> 1 ether
        return _numTokens*(1 ether);
    }

    // funcion para cambiar la moneda de un cliente por invowTokens
    function comprarTokens(uint _numTokens) public payable {
         
        // establecer el precio de los tokens que desea comprar
        uint costo = precioToken(_numTokens);

        // evaluo el dinero que ingresa el usuario para la compra de tokens invow
        require(msg.value >= costo, "Paga con mas ethers o compra menos tokens");

        // diferencia de lo que el cliente paga
        uint returnValue = msg.value - costo;

        // invow retorna la diferencia entre el costo de la operacion y el valor ingresado por el cliente
        payable(msg.sender).transfer(returnValue);

        // es necesario tener el control de el balance de tokens de invow por si se acaban
        // obtencion del numTokens disponibles
        uint Balance = balanceOf();
        require(_numTokens < Balance, "Compra un numero menor de tokens");

        // se transfiere el numero de tokens al cliente
        token.transfer(msg.sender, _numTokens);
    }

    // devovler la cantidad de tokens disponibles en nuestro contrato
    function balanceOf() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    // ver los tokens disponibles de un cliente
    function verMisTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    // generar mas tokens de invow
    function generateTokens(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    // crear una aventura
    function crearAventura(string memory _title, uint fundingGoal) public {

        // chequear si la aventura existe
        require(existAdventure(_title), "Ya existe un proyecto con ese nombre");

        // guardo el titulo de mi aventura
        Adventures.push(_title);

        // creo la estructura de la aventura y la guardo referenciada a su titulo
        titleWithAdventure[_title] = Adventure(msg.sender, _title, fundingGoal, 0, block.timestamp);

        // emito el evento de la creacion de la aventura
        emit new_adventure(_title, fundingGoal);
    }

    // dar de baja una aventura AdventureOwnerOnly(msg.sender)
    function deleteAdventure(string memory _titleAdventure) public AdventureOwnerOnly(msg.sender, _titleAdventure) {
        delete titleWithAdventure[_titleAdventure];
    }

    // listar aventuras
    function listAdventures() public view returns(string[] memory) {
        return Adventures;
    }

    function removeAdventureTitleFromList(uint index) public {
        //uint index = findElementInArray(element);
        delete Adventures[index];
    } 

    // contribuir con tokens a una aventura
    function contributionForAdventure(string memory _titleAdventure, uint _numTokens) public {
        
        // verifico si la persona tiene tokens para transferir
        require(verMisTokens() >= _numTokens, "No tienes fondos para realizar esta accion"); 

        // chequeo si existe la aventura
        require(existAdventure(_titleAdventure), "No existe un proyecto con el nombre introducido");

        //transferencia de los _numTokens a la aventura
        address adventureRecipient = titleWithAdventure[_titleAdventure].owner;
        token.transfer_to_adventure(payable(msg.sender), payable(adventureRecipient), _numTokens);

        // guardo el address y la cantidad de tokens del contribuidor relacionado con el titulo de la adventure
        contributionsToAdventure[_titleAdventure].push(Client(msg.sender, _numTokens));

        // actualizo la cantidad recolectada en el contrato
        titleWithAdventure[_titleAdventure].amountRaised += _numTokens;

        // emito el evento de la contribucion
        emit contribution(msg.sender, _titleAdventure, _numTokens); 
    }

    // obtener el address y el monto contribuido de los aportantes de una aventura
    function getContribution(string memory _titleAdventure) public view returns(Client[] memory) {
        return contributionsToAdventure[_titleAdventure];
    }

    // obtener los tokens de una "persona" o address en particular
    function getBalanceOfPerson(address person) public view returns(uint256){
        return token.balanceOf(person);
    }

    // verificar si ya existe una aventura por su nombre
    function existAdventure(string memory name) public view returns(bool){
        string memory adventureTitle = titleWithAdventure[name].title;
        if (keccak256(abi.encodePacked(adventureTitle)) == keccak256(abi.encodePacked(name))){
            return false;
        } else{
            return true;
        }
    }

    // ------------------------------ secondary functions --------------------
    /* function findElementInArray(string memory element) public returns(uint){
        for (uint i = 0; i < Adventures.length; i++){
            if(keccak256(abi.encodePacked(Adventures[i])) == keccak256(abi.encodePacked(element))){
                return i;
            }
        }
    } */

    // ------------------------------ modifiers ------------------------------ 
    //Modificador para controlar las funciones 
    modifier Unicamente(address direccion) {
        require(direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    modifier AdventureOwnerOnly(address direccion, string memory _adventureTitle) {
        require(direccion == titleWithAdventure[_adventureTitle].owner, 
        "Solo el propietario de la aventura puede borrarla");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

interface IERC20 {

    // devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns(uint256);

    // devuelve la cantidad de tokens para una direccion indicada por parametro
    // el address cuantos tokens tiene de nuestro token virtual
    function balanceOf(address account) external view returns(uint256);

    // devuelve el numero de tokens que el spender puede gastar en nombre del propietario
    function allowance(address owner, address spender) external view returns(uint256);

    // devuelve un valor boolean resultado de la operacion indicada, en este caso transferir
    // recipient (quien puede recibir los tokens)
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    // devuelve un valor boolean resultado de la operacion indicada, en este caso transferir
    // recipient (quien puede recibir los tokens)
    function transfer_to_adventure(address client, address recipient, uint256 numTokens) external returns (bool);

    // devuelve un valor boolean con el resultado de la operacion de gasto
    function approve(address spender, uint256 amount) external returns(bool);

    // devuelve un valor boolean con el resultado de la operacion de paso de una cantidad de tokens
    // usando el metodo allowance
    function transferFrom(address sender, address recipient, uint256 amount)  external returns(bool);

    // evento que se debe emitir cuando una cant de tokens pase de un origen a un destino
    // indexed por que se tiene que pasar por parametro, no lo establezco yo
    event Transfer(address indexed from, address indexed to, uint256 value);

    // evento que se debe emitir cuando se establece una asignacion con el metodo allowance()
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Basic is IERC20 {

    string public constant name = "ERC20Invow";
    uint8 public constant decimals = 2;

/*     event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens); */

    using SafeMath for uint256;

    mapping (address => uint) balances; // a cada direccion le corresponden X tokens
    mapping (address => mapping (address => uint)) allowed; 
    // a cada direccion le corresponde un mapping de direcciones con respecto a cantidades uint. 
    //Cada persona que la minado es la due;o pero la cede a otros para gastarla
    uint256 _totalSupply;

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply;
        balances[msg.sender] = _totalSupply;
    }


    function totalSupply() public override view returns(uint256){
        return _totalSupply;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        _totalSupply +=  newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns(uint256){
        return balances[tokenOwner];
    }

    // invow es el owner de los tokens y delega la capacidad de usar esos tokens para las transacciones 
    // entonces aca devolvemos, de mi address de invow, cuantos tokes tiene asignados el delegado pasado por params
    function allowance(address owner, address delegate) public override view returns(uint256){
        return allowed[owner][delegate];
    }

    // evaluar si se puede hacer una transferencia
    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        // primero evaluo si el numero de tokens que quiero transferir es menor o igual a la cantidad que poseo
        require(numTokens <= balances[msg.sender], '');
        // si los tengo actualizo la cant de tokens que tengo restando con la resta segura de SafeMath  
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        // le sumo los tokes al destinatario
        // IMPORTANTE: es necesario primero restarmelos a mi y luego sumarselos al otro
        balances[recipient] = balances[recipient].add(numTokens);

        // emitir la transaccion
        emit Transfer(msg.sender, recipient, numTokens);
        // si llegamos acá, es por que ocurrio satisfactoriamente
        return true;
    }
    
    // evaluar si se puede hacer una transferencia
    function transfer_to_adventure(address client, address recipient, uint256 numTokens) public override returns (bool){
        // primero evaluo si el numero de tokens que quiero transferir es menor o igual a la cantidad que poseo
        require(numTokens <= balances[client]);
        // si los tengo actualizo la cant de tokens que tengo restando con la resta segura de SafeMath  
        balances[client] = balances[client].sub(numTokens);
        //console.log(balances[client]);
        // le sumo los tokes al destinatario
        // IMPORTANTE: es necesario primero restarmelos a mi y luego sumarselos al otro
        //console.log(balances[recipient]);
        balances[recipient] = balances[recipient].add(numTokens);
        //console.log(balances[recipient]);

        // emitir la transaccion
        emit Transfer(client, recipient, numTokens);
        // si llegamos acá, es por que ocurrio satisfactoriamente
        return true;
    }

    // soy el propietarioo de un numero de tokens y los delego, para esto, 
    // debo aprobar que el delegado haga uso de un numero de tokes
    function approve(address delegate, uint256 numTokens) public override returns(bool){
        // yo, propietario de los tokens, le permito al delegado el uso de un numTokens
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
        // el propietario debe disponer de los tokens para que el buyer pueda comprarlos
        require(numTokens <= balances[owner]);

        // no los vende el owner directamente, sino que los vendemos nosotros como delegados del owner,
        // entonces tenemos que tener permisos.
        // Esos tokens tienen que estar dentro de los que nosotros, como vendedor,
        // tenemos y que por ender el owner(propietario original de esos tokes) nos cedió
        require(numTokens <= allowed[owner][msg.sender]);

        // le restamos al owner la cantidad de tokens a transferir
        balances[owner] = balances[owner].sub(numTokens);
        
        // nosotros somos el intermediario asi que nos tenemos que quitar esos tokens de los permitidos de vender
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        
        // le sumo al comprador los numTokens
        balances[buyer] = balances[buyer].add(numTokens);

        // emito el evento de ka transferencia
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}