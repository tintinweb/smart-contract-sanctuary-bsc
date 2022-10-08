/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 < 0.9.0;
 
//Safe Math Interface
 
contract SafeMath {
 
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}    
 
//ERC Token Standard #20 Interface 1000000000000000000000000
 
interface IERC20 {
    //function totalSupply() external returns (uint);

    function balanceOf(address account) external returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    //function allowance(address owner, address spender) external returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

 
//Actual token contract
 
contract CannabisBit is IERC20, SafeMath {
    string public symbol = "CBC";
    string public name = "CannabisBit";
    uint8 public decimals = 18;

    uint public _initialSupply = 1000000;
    uint public _totalSupply = 0;
    address public _owner = msg.sender; 
 
    uint256 public founderCoreteamAdvisor = 0;
    uint256 public reserved = 0;
    //mapping(address => uint256) public founderCoreteamAdvisor;
    //mapping(address => uint256) public reserved;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    modifier OnlyOwner(){
        require(_owner == msg.sender, "Sorry you are not the owner");
        _;
        }
    constructor(){
        mint(_initialSupply);
    }

    function mint(uint256 amount) public OnlyOwner{
        
        founderCoreteamAdvisor += (amount * 10)/100;
        reserved += (amount * 10)/100;
        uint256 supply = amount -((amount * 20)/100);    
        balances[_owner] += supply;
        _totalSupply += supply;
        emit Transfer(address(0), _owner, amount);
    }

 
    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address to, uint tokens) public override OnlyOwner returns (bool success) {
        balances[_owner] = safeSub(balances[_owner], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
 
    function approve(address spender, uint tokens) public override OnlyOwner returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
 
    function transferFrom(address from, address to, uint tokens) public override OnlyOwner returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function burn(uint amount) public OnlyOwner {
        require(_owner != address(0), "ERC20: burn from the zero address");
        balances[_owner] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function withdrawBal() public returns (bool success){
        require(_owner == msg.sender,"Sorry! You are not allowed to withdraw balance");
        payable(_owner).transfer(address(this).balance);
        return true;
    } 
 
}