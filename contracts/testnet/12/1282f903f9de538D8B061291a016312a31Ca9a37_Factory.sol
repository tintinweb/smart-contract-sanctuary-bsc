/**
 *Submitted for verification at BscScan.com on 2022-03-11
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

    Template[] deployedContracts;

    function createNew(uint arg1) public {
        Template t = new Template(msg.sender, arg1);
        deployedContracts.push(t);
    }
}