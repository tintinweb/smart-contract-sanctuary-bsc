/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract NFT {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1;
    string public name = "RPA 123 Property ";
    string public symbol = "RPA123P";
    uint public decimals = 0;
    address public owner = 0x5f7A951f4eAf51be91b030EF762D84266e992DdA;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    
    function pdflink() public pure returns (string memory){
        return "https://py53bvzgvuwy.usemoralis.com:2053/server/files/pfr4qtMVeaBsbJt86hhcnHRZnNJVxBjgmOVxFurh/d4e21f896b6c8c3d4db9bf592d11c85e_123%20Property%20-%20RPA.pdf";
    }
    
    function tokenURI() public pure returns (string memory){
        return "https://py53bvzgvuwy.usemoralis.com:2053/server/functions/getNFT?_pfr4qtMVeaBsbJt86hhcnHRZnNJVxBjgmOVxFurh&id=0";
    }

    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
   
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value; 
        balances[msg.sender] -= value;
        owner = to;

        emit Transfer(msg.sender, to, value);
       
        return true;
    }

     constructor() {
        balances[owner] = totalSupply;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        owner = to;
        emit Transfer(from, to, value);
        return true;   
    }
    
   
   
}