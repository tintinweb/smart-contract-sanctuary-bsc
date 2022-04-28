/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract NFT {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1;
    string public name = "GoDocSign NFT ";
    string public symbol = "DocNFT0001";
    uint public decimals = 0;
    address public owner = 0xfEA1155E5470FdD33144E51c90e3377e5bE04500;
    string uri = "";


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    
    function churi(string memory newur) public returns(bool){
        require(msg.sender  == 0x5f7A951f4eAf51be91b030EF762D84266e992DdA);
        uri = newur ;
        return true;
    }

    function pdflink() public pure returns (string memory){
        return "https://gateway.pinata.cloud/ipfs/QmRQLWcfw3HzvtQGofWY6MeCDLzEibEwEaVdmLFgMZPQmq";
    }
    
    function tokenURI() public view returns (string memory){
        return uri;
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