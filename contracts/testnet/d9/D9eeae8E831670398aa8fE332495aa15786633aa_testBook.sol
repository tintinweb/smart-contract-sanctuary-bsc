//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract testBook {
   struct Book { 
      string title;
      string author;
      uint book_id;
      uint price;
   }
   mapping(uint256 => Book) private idToBookItem;
   Book book;

   function setBook(string memory _title, string memory _author, uint _book_id, uint _price ) public {
       idToBookItem[_book_id].title = _title;
       idToBookItem[_book_id].author = _author;
       idToBookItem[_book_id].book_id = _book_id;
       idToBookItem[_book_id].price = _price;
   }
   function getBookId(uint _book_id ) public view returns (Book memory) {
      return idToBookItem[_book_id];
   }
}