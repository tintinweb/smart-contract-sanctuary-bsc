// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract StoreCustomers {
    struct Customer {
        string name;
        uint8 age;
    }

    address private immutable owner;
    uint32 private nextId = 0;
    uint32 public count = 0;

    constructor(){
        owner = msg.sender;
    }

    function getNextId() private returns (uint32) {
        return ++nextId;
    }

    mapping(uint32 => Customer) public customers;

    function addCustomer(Customer memory newCustomer) public {
        customers[getNextId()] = newCustomer;
        count++;
    }

    function getCustomer(uint32 id) public view returns (Customer memory) {
        return customers[id];
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function editCustomer(uint32 id, Customer memory newCustomer) public {
        Customer memory oldCustomer = customers[id];
        if (oldCustomer.age == 0) return;

        if (newCustomer.age > 0 && oldCustomer.age != newCustomer.age)
            oldCustomer.age = newCustomer.age;

        if (
            bytes(newCustomer.name).length > 0 &&
            !compareStrings(oldCustomer.name, newCustomer.name)
        ) oldCustomer.name = newCustomer.name;

        customers[id] = oldCustomer;
    }

    function removeCustomer(uint32 id) public {
        require(owner == msg.sender, "Caller is not the owner.");

        Customer memory oldCustomer = customers[id];
        if (bytes(oldCustomer.name).length > 0) {
            delete customers[id];
            count--;
        }
    }
}