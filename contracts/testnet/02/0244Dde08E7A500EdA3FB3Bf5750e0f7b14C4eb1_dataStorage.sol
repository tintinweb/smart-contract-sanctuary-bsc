// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Registration {
    uint256 id;
    string name;
    string email;
    string country;
    string phone;
    uint256 age;
    address wallet;
}

contract dataStorage {
    uint256 count = 0;
    mapping(uint256 => Registration) list;

    event Creation(
        uint256 id,
        string name,
        string email,
        string country,
        string phone,
        uint256 age,
        address wallet
    );

    function create(
        string memory name,
        string memory email,
        string memory country,
        string memory phone,
        uint256 age,
        address wallet
    ) public {
        list[count] = Registration(
            count,
            name,
            email,
            country,
            phone,
            age,
            wallet
        );
          emit Creation( count,
            name,
            email,
            country,
            phone,
            age,
            wallet); 
          
    }

    function getData() public view returns (Registration[] memory) {
        Registration[] memory result = new Registration[](count);
        uint256 position = 0;
        for (uint256 i = 0; i < count; i++) {
            result[position] = list[i];
            position++;
        }
        return result;
    }

    function getCount() public view returns (uint256) {
        uint256 result;
        for (uint256 i = 0; i < count; i++) {
            result += 1;
        }
        return result;
    }
}