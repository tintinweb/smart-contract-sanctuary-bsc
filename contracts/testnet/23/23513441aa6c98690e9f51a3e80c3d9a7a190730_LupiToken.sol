/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// File: LupiToken.sol


pragma solidity 0.8.12;
pragma abicoder v2;

interface IERC20 {
    // ========= COMPORTAMIENTO =========
    // Devuelve la cantidad total de tokens creados
    //function totalSupply() external view returns(uint);

    // Devuelve la cantidad de tokens en posesión de una dirección
    function balanceOf(address _account) external view returns(uint);

    // Devuelve la cantidad de tokens que puede gastar una dirección encargada de ellos
    // en nombre de otra, que es la propietaria de los tokens
    function allowance(address _owner, address _delegate) external view returns(uint);

    // Comprueba si el posible enviar una cantidad de tokens desde la dirección sender,
    // y los envía hacia recipient
    function transfer(address _recipient, uint _amount) external returns(bool);

    // Devuelve si la dirección está habilitada a gastar esos tokens
    function approve(address _delegate, uint _amount) external returns (bool);

    // Devuelve el resultado de la transferencia de tokens usando el método
    // allowance()
    function transferFrom(address _from, address _to, uint _amount) external returns (bool);

    // ========= EVENTOS =========
    // Evento emitido en el momento que se realiza una transferencia de tokens
    event Transfer(address indexed _from, address indexed to, uint value);

    // Evento lanzado en el momento que se utiliza el método allowance para gastar
    // tokens en nombre de otro.
    event Approval(address indexed _owner, address indexed _spender, uint value);
}

contract LupiToken is IERC20{

    address private owner;
    string public constant name = "LupiToken 01";    // Nombre del token
    string public constant simbol = "LUPT";      // Acrónimo del token
    uint8  public constant decimals = 18;       // Cantidad de decimales con los que se puede operar
    uint   public constant totalsupply = 1000;  // Cantidad total de tokens existentes

    mapping (address => uint) balances;                         // Tokens que posee una determinada dirección
    mapping (address => mapping (address => uint)) allowed;     // Tokens que tiene cedidos una dirección para que otro los gaste

    constructor() {
        owner = msg.sender;
        balances[owner] = totalsupply;
    }

    function getOwner() public view returns(address){
        return owner;
    }

    /*function totalSupply() public override view returns(uint){
        return totalsupply;
    }*/

    // Esta función es la ejecutada para crear nuevos tokens, se asignan al msg.sender
    /*function increaseTotalSupply(uint _newtokensamount) public {
        totalsupply += _newtokensamount;
        balances[msg.sender] += _newtokensamount;
    }*/

    function balanceOf(address _tokenowner) public override view returns(uint){
        return balances[_tokenowner];
    }

    function allowance(address _owner, address _delegate) public override view returns(uint){
        return allowed[_owner][_delegate];
    }

    function transfer(address _recipient, uint _amount) public override returns(bool){
        // Compruebo si el sender posee esos tokens
        require(balances[msg.sender] >= _amount, "Insuficient tokens amount");

        // Resto los tokens al sender
        balances[msg.sender] -=  _amount;
        // Sumo los tokens al recipient
        balances[_recipient] += _amount;
        // Genero el evento de la transferencia
        emit Transfer(msg.sender, _recipient, _amount);

        return true;
    }

    function approve(address _delegate, uint _amount) public override returns (bool){
        // Compruebo si el sender posee esos tokens
        require(balances[msg.sender] >= _amount, "Insuficient tokens amount");

        // Doy permisos al spender para gastar esos tokens
        allowed[msg.sender][_delegate] += _amount;

        // Genero el evento
        emit Approval(msg.sender, _delegate, _amount);

        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public override returns (bool){
        // Compruebo si el propietario de esos tokens posee esos tokens
        require(balances[_from] >= _amount, "Insuficient tokens amount");
        // Compruebo que el propietario de los tokens me ha cedido los permisos para
        // realizar la venta de tokens
        require(allowed[_from][msg.sender] >= _amount, "Transfer sender not allowed");

        // Traspaso de tokens
        balances[_from] -=  _amount;
        // Cambio en los permisos de tokens
        allowed[_from][msg.sender] -= _amount;

        // Sumo los tokens
        balances[_to]   +=  _amount;

        // Genero el evento de la transferencia
        emit Transfer(_from, _to, _amount);

        return true;
    }
}