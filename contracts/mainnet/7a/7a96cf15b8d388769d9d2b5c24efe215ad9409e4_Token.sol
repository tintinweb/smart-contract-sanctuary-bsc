/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity >=0.8.0;

contract Token {
    mapping (address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 42000000 * 10 ** 18; // Holds the total suppy of the token
    string public name = "SMARToken"; // Holds the name of the token
    string public symbol = "SMART"; // Holds the symbol of the token
    uint public decimals = 18; // Holds the decimal places of the token

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval (address indexed owner, address indexed spender, uint value);

constructor() {
        balances[msg.sender] = totalSupply; // Transfers all tokens to owner
    }

function balanceOf(address owner) public view returns (uint) {
    return balances[owner];
}

function transfer(address to, uint value) public returns (bool) {
    require(balanceOf(msg.sender) >= value, "Not enough balance");
    balances[to] += value;
    balances[msg.sender] -= value;
    emit Transfer(msg.sender,to,value);
    return true;
}

function transferfrom(address from, address to, uint value) public returns (bool){
    require(balanceOf(from)>= value, "Not enough balance");
    require(allowance[from][msg.sender] >= value, "Not enough balance");
    balances[to] += value;
    balances[from] -= value;
    emit Transfer(from, to, value);
    return true;
}
    
function approve(address spender, uint value) public returns(bool){
   allowance[msg.sender][spender] = value;
   emit Approval(msg.sender, spender, value);
   return true;
}

}