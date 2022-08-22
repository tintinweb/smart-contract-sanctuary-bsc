/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;
//uint = byte = 2^8 = 256 (0 - 255)
//deploy in testnet bscscan-------------------------------------------
// owner: 0x720b6754e1A5eE872179046Ac446a90Fa108E871
// Simple coin contrato: 0xC98d2A78F11827Fc273Fd1784b373fA7371CF0c9

contract simpleCoin{
 //Variáveis de estado//////////////////////////////////////////////////////////////////////  
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    address public owner;
   
    // informações do token--------------------
    string public name = "Meu Token";
    string public symbol = "MKT";
    uint8 public decimals = 8; //n. de decimais //precisa ser especificado!!!
    //-------------------------------------------
 //////////////////////////////////////////////////////////////////////////////////////////
    
    mapping(address => mapping(address =>uint)) public allowance; //Permite que um terceiro transfira seus tokens // Limitado a quantidade que vc tenha dado permissão // utilizado p/ swap

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed spender, uint256 _value);

    modifier onlyOwner{ //Será executado antes do fim da função, sempre que for chamado por uma função
        require(msg.sender == owner);
        _;
    }


    constructor(){  //função que é executada assim que um contrato é colocado na blockchain/ asim que é feito o deploy.
        owner = msg.sender;
        totalSupply = 1_000_000_000 * 10 ** decimals; //Tenho que explicitar o n de casas decimals (10 ** decimais = 10^8)
        balanceOf[owner]= totalSupply;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){ //F. usada p/ tranferir tokens de um terceiro
        require(allowance[_from][msg.sender] >= _value); //saldo da qtd que eu permitir p/ alguem manipular por mim
        require(balanceOf[_from] >=_value); //meu saldo tem que ser maior do q o valor a transferir
        require(_from != address(0));
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender]-= _value; //Atualização do saldo q eu permitir para o terceiro

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){ //função q faz a aprovação para casas de swap ou terceiros
        //require(balanceOf[msg.sender] >= _value);
        require(_spender != address(0)); //o spender não pode ser o endereço 0
        allowance[msg.sender][_spender] = _value; //Eu(msg.sender) aprovo o joao (_spender) a gastar o valor (_value)
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        //require(msg.sender == owner);
        owner = _newOwner;
    }

    function transfer(address _to, uint256 _value) public returns(bool success){ //F. usada p/ tranferir tokens
        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0));
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

}