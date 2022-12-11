// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract StoreCustomers {


    struct Customer {
        string name;
        uint8 age;
    }

    uint32 private nextId = 0;
    uint32 public count = 0;

    address private immutable owner;

    // Command constructor - Função especial que é chamada quando o contrato é inicializado.
    // constructor - Tem sempre de existir, mesmo que seja vazia.
    constructor() {
        /**
        Criar uma função que permita unicamente o dono do contrato realizar a operação de eliminar cliente
        - Antes temos de saber quem é o dono do contrato. 
            Como saber quem é o dono?
            Uma das formas é saber quem fez o deply, e este será o dono. - owner > address private owner
            Temos de defenir uma variaveis (const ou immutable) para fixar o  address da carteira        
        */
        
        owner = msg.sender;
    }

    mapping(uint32 => Customer) public customers;

    // --- Methods ---
    function getNextId() private returns(uint32) {
        return ++nextId;
    }

    function addCustomer(Customer memory newCustomer) public {
        customers[getNextId()] = newCustomer;
        count++;
    }

    function getCustomer(uint32 id) public view returns(Customer memory) {
        return customers[id];
    }

    function compareStrings(string memory a, string memory b) private pure returns(bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function editCustomer(uint32 id, Customer memory newCustomer) public {
        Customer memory oldCustomer = customers[id];

        if(oldCustomer.age == 0) return;
        if(newCustomer.age > 0 && oldCustomer.age != newCustomer.age)  oldCustomer.age = newCustomer.age;
        if(bytes(newCustomer.name).length > 0 && !compareStrings(oldCustomer.name, newCustomer.name))  oldCustomer.name = newCustomer.name; 

        customers[id] = oldCustomer;
    }

    function removeCustomer(uint32 id) public {

        //-- Tornar que só o dono do contrato pode eliminar clientes
        require(owner == msg.sender, "Caller is not the owner.");

        Customer memory oldCustomer = customers[id];
        if(bytes(oldCustomer.name).length > 0 ) {
            delete customers[id];
            count--;
        }
    }

}