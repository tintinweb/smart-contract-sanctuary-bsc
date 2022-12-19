/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

pragma solidity ^0.4.24;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);

    
    //function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    //function approve(address spender, uint tokens) public returns (bool success);
    //function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract CrowdFundingPlatform is ERC20Interface{
    string public name = "CrowdFundingPlatform Token";
    string public symbol = "CRPF";
    uint public decimals = 18;
    
    uint public supply;
    address public founder;
    
    mapping(address => uint) public balances;
    
  
    
    
    event Transfer(address indexed from, address indexed to, uint tokens);


    constructor() public{
        supply = 100000000000000000000000000;
        founder = 0xb4C023A4Da5a24f8db360c7951C967b7BB01F23c;
        balances[founder] = supply;
    }
    
    
    function totalSupply() public view returns (uint){
        return supply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance){
         return balances[tokenOwner];
     }
     
     
    //transfer from the owner balance to another address
    function transfer(address to, uint tokens) public returns (bool success){
         require(balances[msg.sender] >= tokens && tokens > 0);
         
         balances[to] += tokens;
         balances[msg.sender] -= tokens;
         emit Transfer(msg.sender, to, tokens);
         return true;
     }
    
}