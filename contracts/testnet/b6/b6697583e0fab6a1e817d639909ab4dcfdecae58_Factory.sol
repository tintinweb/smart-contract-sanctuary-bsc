/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity 0.5.1;

contract Template {

    address owner;
    uint something;

    constructor(address _owner, uint args) public {
        owner = _owner;
        something = args;
    }       
}  

contract Factory {
    mapping (address => address) internal games;

    Template[]  deployedContracts;

    function createNew(uint arg1) public returns(address newContract){
        Template t = new Template(msg.sender, arg1);
        deployedContracts.push(t);
        games[msg.sender] =  address(t);
        return address(t);
    }

    function getLastGame(address gameAddress) public view returns (address newContract){
        return games[msg.sender];
    }
}