/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract StoreCustomers {
    address private immutable owner;
    uint32 public count;

    constructor() {
        owner = msg.sender;
    }

    struct Customer {
        string name;
        uint8 age;
    }

    mapping(uint32 => Customer) public customers;

    uint32 private nextId = 0;

    function getNextId() private returns (uint32) {
        return ++nextId;
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function addCustomer(Customer memory customer) public {
        uint32 id = getNextId();
        customers[id] = customer;
        count++;
    }

    function getCustomer(uint32 id) public view returns (Customer memory) {
        return customers[id];
    }

    function editCustomer(uint32 id, Customer memory newCustomer) public {
        Customer memory oldCustomer = customers[id];
        if (bytes(oldCustomer.name).length == 0) return;

        if (bytes(newCustomer.name).length > 0 && !compareStrings(oldCustomer.name, newCustomer.name))
            oldCustomer.name = newCustomer.name;

        if (newCustomer.age > 0 && oldCustomer.age != newCustomer.age)
            oldCustomer.age = newCustomer.age;

        customers[id] = oldCustomer;
    }

    function removeCustomer(uint32 id) public {
        require(msg.sender == owner, "Caller is not owner");
        Customer memory oldCustomer = customers[id];
        if (bytes(oldCustomer.name).length > 0) {
            delete customers[id];
            count--;
        }
    }
}