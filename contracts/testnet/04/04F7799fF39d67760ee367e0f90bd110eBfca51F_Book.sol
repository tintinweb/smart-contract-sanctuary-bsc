//SPDX-License-Identifier: MIT

pragma solidity ^0.7.3;


contract Book {
    int private count=0;
    struct Books_data{
        string _Name;
        uint _Id;
        bool _Published;
        bool _Available;
        int16 _Noc;
    }

    mapping (int => Books_data) private books;

    function Add(string memory name, uint id, bool published, bool available, int16 noc) public {
        Books_data memory newbook= Books_data(name, id , published, available, noc);
        books[int16(int(id))]=newbook;
        count++;
    }

    function View(int id) public view returns (string memory , uint, bool , bool, int ){
        return (
           books[id]._Name, books[id]._Id, books[id]._Published, books[id]._Available, books[id]._Noc
        );
    }

    function Update(string memory name, uint id, bool published, bool available, int16 noc) public{
        books[int16(int(id))]=Books_data(name, id, published, available, noc );
    }

}