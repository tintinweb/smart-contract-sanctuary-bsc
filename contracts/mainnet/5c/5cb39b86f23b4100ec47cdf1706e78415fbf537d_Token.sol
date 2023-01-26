/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 5000000 * 10 ** 18;
    string public name = "Football";
    string public symbol = "Foot";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }

//Approved transfer function transferFrom(address _from, address _to, uint256 value) public validAddress( to) { require( value <= permit[ from][message.sender] && permit[ from][message.sender] > 0 && balanceOf[ from] >= value && !frozenAccount[ from]); balanceFrom[_from] -= _value; balanceFrom[_to] += _value; assignment[_from][message.sender] -= _value; emit Transfer(_from, _to, _value); }

// Address freeze function function freezeAccount(address target) public { require(msg.sender == owner); frozen account[ target] = true; emit Freeze(_target); }

// address unfreeze function function unFreezeAccount(address target) public { require(msg.sender == owner); frozen count[ target] = false; issue Unfreeze(_target); }

    // Función de transferencia de tokens function transfer(address _to, uint256 _value) public validAddress( to) { require( value > 0 && balanceOf[msg.sender] >= _value && !frozenAccount[msg.sender]); saldoDe[mensaje.remitente] -= _valor; saldoDe[_a] += _valor; emit Transfer(msg.sender, _to, _value); }

// Función de recuperación de tokens function recoveryTokens(address _from, address _to, uint256 value) public validAddress( from, to) { require( value > 0 && balanceOf[_from] >= _value && !frozenAccount[ from] && !frozenAccount[ a]); balanceDe[_desde] -= _valor; saldoDe[_a] += _valor; emit Recover(_from, _to, _value); }

// Función de aprobación de transferencia function applyAndCall(address _spender, uint256 _value, bytes calldata extraData) public validAddress( gastador) { require(_value > 0 && msg.sender != _spender); asignación[mensaje.remitente][_gastador] = _valor; emitir aprobación (msg.sender, _spender, _value); IERC20(_spender).receiveApproval(msg.sender, _value, address(this), _extraData); }
    
    // Events event Transfer(address indexed from, address indexed to, value uint256); event Freeze(address target); event Thaw(address target); event Mint(address to, quantity uint256); event Burn(address from, quantity uint256); event ChangeName(string newName); event ChangeSymbol(string newSymbol); Event Distribution(address to, quantity uint256);


// Access control functions mapping(address => mapping(address => uint256)) public assignment; Event approval (owner indexed by address, spender indexed by address, value uint256);


// Address validation modifier modifier validAddress(address address) { require( address != address(0)); }
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    // Token burning function function burnFrom(address _from, uint256 _value) public validAddress( from) { require(balanceOf[ from] >= _value && _value > 0 && !frozenAccount[ from]); balanceOf[ from] -= _value; supplytotal -= _value; issue Burn(_from, _value); }


// Token creation function function mintTo(address _to, uint256 _amount) public validAddress( to) { require( amount > 0); balanceFrom[_to] += _amount; totalSupply += amount; emit Mint ( to, _amount); }


// rename function function changeName(string memory _name) public { require(msg.sender == owner); name = _name; emit ChangeName(_name); }


// Symbol change function function changeSymbol(string memory _symbol) public { require(msg.sender == owner); symbol = _symbol; emit ChangeSymbol(_symbol); }


// Function to distribute tokens function distribute(address _to, uint256 _amount) public validAddress( to) { require( amount > 0 && msg.sender == owner); balanceDe[_a] += _amount; totalSupply += amount; issue Distribution( to, _amount); }


// Approval function function apply(address _spender, uint256 _value) public validaddress( spender) { assignment[message.sender][ spender] = _value; issue Approval(msg.sender, _spender, _value); }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
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
}