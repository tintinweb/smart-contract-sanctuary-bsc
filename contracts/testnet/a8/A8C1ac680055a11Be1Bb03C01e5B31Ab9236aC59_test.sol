/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract test {
   struct Book { 
      string title;
      string author;
      uint book_id;
   }
   Book book;
   Book book1;

   function setBook() public {
      book = Book('Learn Java', 'TP', 1);
   }
   function getBookId() public view returns (uint) {
      return book.book_id;
   }

   function getbookAuthor() public view returns(string memory){
       return book.author;
   }
    function getbookTitle() public view returns(string memory){
       return book.title;
   }


    function set() public {
      book1 = Book('Learn solidity', 'ss', 2);
   }

   function getId() public view returns (uint) {
      return book1.book_id;
   }

   function getAuthor() public view returns(string memory){
       return book1.author;
   }
    function getTitle() public view returns(string memory){
       return book1.title;
   }
}