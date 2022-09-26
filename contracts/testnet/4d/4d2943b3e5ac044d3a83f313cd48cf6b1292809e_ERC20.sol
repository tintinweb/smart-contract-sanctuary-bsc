/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20 {
    using SafeMath for uint256;


string  _name;
string  _symbol;
uint256  _decimals;
uint256  _totalsupply;
constructor(string memory name, string memory symbol, uint256 decimals, uint256 Totalsupply){
     _name = name;
     _symbol = symbol;
     _decimals = decimals;
     _totalsupply = Totalsupply;

}

mapping(address => uint256) private balances;
mapping(address => mapping(address => uint256)) private allowance;
event Transfer(address from, address to, uint256 value);

function totalsupply() public view returns(uint256){

    return _totalsupply;
}

function name() public view returns(string memory){

    return _name;
}
function symbol() public view returns(string memory){

    return _symbol;
}

function decimals() public view returns(uint256){

    return _decimals;
}
function balanceof(address account) public view returns(uint256){
    return balances[account];

}

function transfer(address to, uint256 value) public {
   require(to != address(0), "enter correct address");
   require(msg.sender != address(0), "sender address is not valid");
   
    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer( msg.sender, to, value);

}
function Allowance(address owner , address spender) public view returns(bool){
    allowance[owner][spender];
    return true;

}
function increaseAllowance(address owner , address spender, uint256 increase) public view returns(bool){
    allowance[owner][spender].add(increase);
    return true;
    }

function decreaseAllowance(address owner , address spender, uint256 decrease) public view returns(bool){
    allowance[owner][spender].add(decrease);
    return true;
    }


function approve(address owner, address spender, uint256 amount) public{
    allowance[owner][spender] = amount;
}



function transferfrom(address owner, address spender, uint256 amount) public {
    transfer(spender, amount);
    approve(owner, spender,allowance[owner][spender].sub(amount));

}
function mint(address account, uint256 amount) public{
    require(account != address(0),"address is not valid");
    require(amount > 0,"incorrect amount");

    balances[account] = balances[account].add(amount);
    _totalsupply = _totalsupply.add(amount);
    emit Transfer( msg.sender,account, amount);

}
function burn(address account, uint256 amount) public{
    require(account != address(0),"address is not valid");
    require(amount > 0,"incorrect amount");

     balances[account] = balances[account].sub(amount);
    _totalsupply = _totalsupply.sub(amount);
    emit Transfer( msg.sender,account, amount);
}

}