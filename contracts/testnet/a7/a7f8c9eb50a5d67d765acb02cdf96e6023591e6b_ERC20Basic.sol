/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: UNLICENSED
// File: Contracts-Raul/ERC20-TEST.sol



pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;
library SafeMath{
// La Resta
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
// La Suma
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
// La Multiplicación
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b, "SafeMath: multiplication overflow");
return c;
}
}
//Interface token ERC
interface IERC20{
//El suministro total de tokens
function totalsupply()external view returns (uint256);
//Devuelve el número de tokens de una dirección
function balanceOf(address account)external view returns (uint256);
//Un usuario tiene la cantidad de tokens suficientes (y devuelve el número)
function allowance(address owner, address spender)external view returns (uint256);
//Tokens del suministro inicial a un usuario
function transfer(address recipient, uint256 amount) external returns (bool);
//Si el contrato puede mandar una cantidad de tokens a un usuario
function approve(address spender, uint256 amount) external returns (bool);
//Habilita la transferencia de tokens entre usuarios
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
//Evento número 1
event Transfer(address indexed from, address indexed to, uint256 value);
//Evento número 2
event Approval(address indexed owner, address indexed spender, uint256 value);
}
//Implementacion funciones token ERC20
contract ERC20Basic is IERC20{
string public constant name = "ERC-20 Betseven Blockchain ";
string public constant symbol = "BBC";
uint public constant decimals= 2;
event Transfer(address indexed from, address indexed to, uint256 tokens);
event Approval(address indexed owner, address indexed spender, uint256 tokens);
using SafeMath for uint256;
mapping(address=>uint) balances;
mapping (address => mapping (address => uint)) allowed;
uint256 totalSupply_;
constructor (uint256 initialSupply) public{
    totalSupply_ = initialSupply;
    balances[msg.sender]= totalSupply_;
}
function totalsupply() public override view returns (uint256){
 return totalSupply_;
}
function increaseTotalSupply(uint newTokensAmount) public {
    totalSupply_+=newTokensAmount;
    balances[msg.sender]+= newTokensAmount;
}
function balanceOf(address tokenOwner) public override view returns (uint256){
    return balances[tokenOwner];
    }
    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }
    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <=balances[msg.sender]);
        balances[msg.sender]=balances[msg.sender]. sub(numTokens);
        balances[recipient]=balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }
    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate]=numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner]=balances[owner].sub(numTokens);
        allowed[owner][msg.sender]=allowed[owner][msg.sender].sub(numTokens);
        balances[buyer]=balances[buyer].add(numTokens);
        emit Transfer (owner, buyer, numTokens);
        return true;
    }
}