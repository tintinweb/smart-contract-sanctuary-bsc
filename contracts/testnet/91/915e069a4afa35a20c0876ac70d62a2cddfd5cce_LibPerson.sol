/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library LibPerson {
    struct Person {
        string name;
        uint256 age;
    }

    struct Storage {
        uint256 personsCount;
        mapping(uint256 => Person) persons;
    }

    bytes32 private constant STORAGE_SLOT = keccak256("LibPerson");

    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;

        assembly {
            s.slot := slot
        }
    }

    function getPersonsCount() internal view returns (uint256 personsCount) {
        personsCount = _storage().personsCount;
    }

    function getPerson(
        uint256 id
    ) internal view returns (Person memory person) {
        person = _storage().persons[id];
    }

    function addPerson(Person memory person) internal returns (uint256 id) {
        Storage storage s = _storage();

        id = ++s.personsCount;
        s.persons[id] = person;
    }
}