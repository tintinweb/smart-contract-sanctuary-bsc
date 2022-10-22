// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract BookDatabase {
    struct Book {
        string title;
        uint16 year;
    }

    mapping(uint32 => Book) public books;

    uint32 private nextId = 0;
    uint32 public count;
    address private immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function getNextId() private returns (uint32) {
        return ++nextId;
    }

    function addBook(Book memory book) public {
        uint32 id = getNextId();
        books[id] = book;
        count++;
    }

    function getBook(uint32 id) public view returns (Book memory) {
        return books[id];
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function editBook(uint32 id, Book memory newBook) public {
        Book memory oldBook = books[id];
        if (bytes(oldBook.title).length == 0) return;

        if (
            bytes(newBook.title).length > 0 &&
            !compareStrings(oldBook.title, newBook.title)
        ) oldBook.title = newBook.title;

        if (newBook.year > 0 && oldBook.year != newBook.year)
            oldBook.year = newBook.year;

        books[id] = oldBook;
    }

    function removeBook(uint32 id) public {
        require(msg.sender == owner, "Caller is not owner");
        Book memory oldBook = books[id];
        if (bytes(oldBook.title).length > 0) {
            delete books[id];
            count--;
        }
    }
}