/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract TokenNelore {
    string public name = "GuttiTransportes"; 
    string public symbol = "[email protected]";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000*10**decimals;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint) public balanceOf;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor () {
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
         allowance[msg.sender][_spender] = _value;
         emit Approval(msg.sender, _spender, _value);
         return true;

    }
   
    function transfer (address recebedor, uint valor) public returns (bool success) {
        balanceOf[msg.sender] = balanceOf[msg.sender] - valor;
        balanceOf[recebedor] = balanceOf[recebedor] + valor;
        emit Transfer(msg.sender, recebedor, valor);  
        return true; 
    }

    function transferFrom (address deQuem, address paraQuem, uint valor) public returns (bool success) {
        balanceOf[deQuem] = balanceOf[deQuem] - valor;
        balanceOf[paraQuem] = balanceOf[paraQuem] + valor;
        require(allowance[deQuem][msg.sender] >= valor);
        allowance[deQuem][msg.sender] = allowance[deQuem][msg.sender] - valor;
        emit Transfer(deQuem, paraQuem, valor);
        return true;

    }
    
}