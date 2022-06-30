/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Counter{
    
    mapping(uint=>Book) public books;
    mapping(address=>mapping(uint=>Book)) public myBooks;
    struct Book{
        string title;
        string author;
    }

    function addBook(uint _id,string memory _title, string memory _author) public{
        books[_id] = Book(_title, _author);
    }

    function addMyBook(uint _id,string memory _title, string memory _author) public{
        myBooks[msg.sender][_id] = Book(_title, _author);
    }
}