/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

pragma solidity ^0.8.0;


contract Invitation {

 
    mapping (address => bool) accounts;
    address public root = 0x7d1b5a54b17a4D2bC2CEA69ae29d1A441020bbE1;
    uint public price = 5e17;
    
    constructor(){}
    

    function bind() payable  external {
        require(msg.value == price, "none payable");
        accounts[msg.sender]= true;
        payable(root).transfer(msg.value);
    }

    function getInvitation(address user) external view returns(bool) {
        return accounts[user];
    }

    function updateRoot(address user) external  {
        require(msg.sender == root ,"not root address");
        root = user;
    }

    function updateAccounts(address user ,bool b) external  {
        require(msg.sender == root ,"not root address");
        accounts[user] = b;
    }

     function updatePrice(uint amount) external  {
        require(msg.sender == root ,"not root address");
        price = amount;
    }

}