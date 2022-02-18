//SPDX-License-Identifier: MIT
import "./AccessControl.sol";

pragma solidity ^0.8.9;

contract PersonManange is AccessControl{
    bytes32 public constant PERSON_ADM = keccak256("PERSON_ADM");

    constructor(){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PERSON_ADM, msg.sender);
    }

    struct person{
        bool active;
        string name;
        uint8 age;
    }
    uint256 private _personId=0;
    mapping(uint256 => person) public allPerson;

    function addPerson(bool active, string memory name, uint8 age) public onlyRole(PERSON_ADM){
        allPerson[_personId].active = active;
        allPerson[_personId].name = name;
        allPerson[_personId].age = age;
        _personId++; 
    }

    function getPerson(uint256 personId) public view returns(bool active, string memory name, uint8 age){
        return (allPerson[personId].active,allPerson[personId].name,allPerson[personId].age);
    }
}