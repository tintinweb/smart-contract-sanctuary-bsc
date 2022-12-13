// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Person.sol";

contract Book {
    uint public maxPeople;
    Person[] public people;
    constructor(uint _maxPeople) {
        maxPeople = _maxPeople;
    }

    function addPerson(string memory _name, uint _age) public{
        people.push(new Person(_name, _age));
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Person {
    string name; 
    uint age;
    constructor(string memory _name, uint _age) {
        name = _name;
        age = _age;
    }

    function getName() public view returns(string memory){
        return name;
    }

    function getAge() public view returns(uint){
        return age;
    }

    function setName(string memory _name) public {
        name = _name;
    }

    function setAge(uint _age) public {
        age = _age;
    }
}