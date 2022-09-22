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

   function setBook(string memory _name, string memory _author, uint _book_id, uint _price ) public {
      book = Book(_name, _author, _book_id,_price);
   }
   function getBookId(uint _book_id ) public view returns (uint) {
      return idToBookItem[_book_id].price;
   }
}