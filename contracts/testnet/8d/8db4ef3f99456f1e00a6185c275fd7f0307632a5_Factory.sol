/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity 0.8.12;

contract Template {

    address owner;
    uint something;

    constructor(address _owner, uint args) public {
        owner = _owner;
        something = args;
    }   
            function test() public view returns (address newContract){
                return address(this);
            }


}  

contract Factory {
    mapping (address => Template) internal games;

    Template[]  deployedContracts;

    function createNew(uint arg1) public returns(address newContract){
        Template t = new Template(msg.sender, arg1);
        deployedContracts.push(t);
        games[msg.sender] =  t;
        return address(t);
    }

    function getLastGame(uint gameAddress) public view returns (address newContract){
        return deployedContracts[gameAddress].test();
    }
   
}