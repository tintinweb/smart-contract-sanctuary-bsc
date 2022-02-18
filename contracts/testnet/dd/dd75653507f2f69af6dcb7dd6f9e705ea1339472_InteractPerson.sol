//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract InteractPerson{
    PersonManangeFactory personManange;
    constructor(address personContract){
        personManange = PersonManangeFactory(personContract);
    }
    function addPersonInteract(bool active, string memory name, uint8 age) public{
        personManange.addPerson(active, name, age);
    }
    function getPersonInteract(uint256 personId) public view returns(bool active, string memory name, uint8 age){
        return personManange.getPerson(personId);
    }
}
interface PersonManangeFactory{
    function addPerson(bool active, string memory name, uint8 age) external;
    function getPerson(uint256 personId) external view returns(bool active, string memory name, uint8 age);
}