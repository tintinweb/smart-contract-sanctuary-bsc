// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// https://www.youtube.com/watch?v=urQlDxtRu70&list=PLsGmTzb4NxK0hRfnjfcg0f9rc0lleY28O&index=13
// video aula do luizTools
contract StoreCustomers{

    // variavel(propriedade) de controle para id unico
    uint32 private nextId = 0;
    uint32 public count = 0;

    function getNextId() private returns (uint32){
        return ++nextId;
    }

    struct Customer {
        string name;
        uint8 age; // inteiros sem sinal  . evitar o uint256  . tentar usar sempre o menor dado que puder
    }

    // para varios consumidores usar : um array OU mapping   (no solidity mapping mas em outras linguagens tem outro nome)
    mapping(uint32 => Customer) public customers; // mapping muito bom pra consulta

    // tipo de dado, modificador de visibilidade e nome da propriedade
    string public message = "Ola novo emprego promissor!";

    function addCustomer(Customer memory newCustomer  ) public {

        customers[getNextId()] = newCustomer;
        count++;
    }

    function getCustomer(uint32 id) public view returns(Customer memory){
        return customers[id];
    }




}