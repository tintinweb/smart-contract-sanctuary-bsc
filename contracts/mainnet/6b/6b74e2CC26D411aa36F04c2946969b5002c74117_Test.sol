/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.8.6;

contract Test{

    //Solidity te hace un metodo get al poner public la variables
    //el metodo tendra el mismo nombre de la variable

    bool public status; 
    address public owner;
    string public name;  //nombre de la moneda
    string public symbol; //el simbolo o nomenclatura de la moneda
    uint8 public decimals; //decimales de la moneda
    uint256 public totalSupply; //la cantidad de monedas existentes
    mapping(address => uint256) public balanceOf; //va llevar las direcciones con su respectivo saldo   (lista de holders)

    //un mapping que tiene de valor una direccion y esa direccion tiene asociado un mapping de direcciones y valores
    //cada direccion corresponde a cada holders que a su vez tendrá asociado un mapping que son las direcciones de terceros que pueden administrar sus tokens con su respectiva cantidad
    mapping(address => mapping(address => uint256)) public allowance;
    
    constructor() {   //funciona inicializadora del contrato, del deploy. 

        name = "Test Coin";
        symbol = "TESTC";
        decimals = 18;
        totalSupply = 1000000 * (uint256(10) ** decimals);  //x10 evelado a la 18
        //a la cantidad de tokens hay que sumarle toda la cantidad de ceros de decimales que haya puesto

        owner = msg.sender;
        balanceOf[owner] = totalSupply;  //soy el dueno de todos los tokens

    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(status == true);
        require(balanceOf[msg.sender] >= _value);     //verifica que el que llamo la funcion tenga igual o mas de la cantidad a enviar.
        balanceOf[msg.sender] -= _value;   //se le resta el valor de tokens a la persona que llamó
        balanceOf[_to] += _value;          //se le suma los tokens al destino
        emit Transfer(msg.sender, _to, _value);     //evento
        return true;
    }

    function changeStatus(bool _newStatus) public {
        require(msg.sender == owner);
        status = _newStatus;
    }


    //se le pasa la direccion de la persona tercera que va tener derecho a usar los tokens de la otra persona
    //recibe la cantidad de tokens que tendra derecho a gestionar

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;    //la persona que ejecuto el approve se le asocia el spender que es la persona que podra gestionar x cantidad de tokens
        emit Approval(msg.sender, _spender, _value);  //se emite el evento para logs
        return true;
    
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(status == true);
        require(balanceOf[_from] >= _value);  //compruebo que el dueño tiene esos tokens a transferir
        require(allowance[_from][msg.sender] >= _value); //comprueba que el que esta llamando la funcion tenga derecho a gestionar esos tokens
        balanceOf[_from] -= _value;      //se le restan los tokens al dueño
        balanceOf[_to] += _value;        //se le suman a la direccion destino
        allowance[_from][msg.sender] -= _value;  //se le restan la cantidad de tokens que gestiona el tercero
        emit Transfer(_from, _to, _value);
        return true;

    }








}