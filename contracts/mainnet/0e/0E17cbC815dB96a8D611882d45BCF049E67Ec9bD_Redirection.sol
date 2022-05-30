pragma solidity ^0.8.6;

contract Redirection{

    string  hsh;
    address private owner;

    constructor(){
        owner = msg.sender;
    }

    function getHsh() public view returns (string memory){
        return hsh;
    }

    function setHsh(string memory new_hsh) public returns (bool){
        require(msg.sender == owner);
        hsh = new_hsh;
        return true;    
    }


}