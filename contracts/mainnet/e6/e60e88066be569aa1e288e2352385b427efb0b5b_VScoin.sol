/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

pragma solidity ^0.8.9;
contract VScoin{  
    mapping (address => uint) public balances;
    mapping (address => mapping (address=>uint)) public allowance;
    uint public totalSupply = 1000000 * 10 ** 18;
    string public name="26coin";
    string public symbol="VSC";
    uint public decimals = 18;
    constructor(){
        balances[msg.sender] = totalSupply;
        }
    function balanceOf (address owner) public view returns (uint) {
    return balances [owner];
    }
    event Transfer (address indexed from, address indexed to, uint value);
    event Approval (address indexed owner, address indexed spender, uint value) ;
    function transfer (address to, uint value) public returns (bool){
        require (balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] = balances[to]+ value;
        balances[msg.sender]=
        balances[msg.sender]-value;
        emit Transfer (msg.sender, to, value);
        return true;
        }
}