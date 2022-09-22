//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract testBook {
   struct Book { 
      string title;
      string author;
      uint book_id;
   }
   Book book;

   function setBook(string memory _name, string memory _author, uint book_id ) public {
      book = Book(_name, _author, book_id);
   }
   function getBookId() public view returns (uint) {
      return book.book_id;
   }
}