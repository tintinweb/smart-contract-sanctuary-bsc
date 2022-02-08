/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HostionCoin {
    //  Especificando las variables publicas y globales se generan automaticamente getters al generar
    //  el contrato para ver cada variable, asi no tenemos que crear las funciones.
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    //  Variables para dividendos
    uint256 dividendPerToken;
    mapping(address => uint256) dividendBalanceOf;
    mapping(address => uint256) dividendCreditedTo;
    
    //  Funciones dividendos
    function update(address _address) internal {
        uint256 debit = dividendPerToken - dividendCreditedTo[_address];
        dividendBalanceOf[_address] += balanceOf[_address] * debit;
        dividendCreditedTo[_address] = dividendPerToken;
    }

    function withdraw() public {
        update(msg.sender);
        uint256 amount = dividendBalanceOf[msg.sender];
        dividendBalanceOf[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function deposit() public payable {
        dividendPerToken += msg.value / totalSupply;
    }
    //  -------------------------------------------  \\


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() {
        name = "HostionCoin";
        symbol = "HC";
        decimals = 18;
        totalSupply = 1000000 * (uint256(10) ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        //  Para actualizar dividendos
        update(msg.sender);
        update(_to);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);        
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}