/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: GPL-3.0
// pragma solidity >=0.7.0 <0.9.0;

// contract myContract {
    
// function getName() public pure returns(string memory) {
//     return "mujahid";
// }
// function getSill() public pure returns(string memory) {
//     return "React";
// }
// }

pragma solidity >= 0.5.1;

contract myContract {
   Person[] public people;
   uint256 public peopleCount;


   struct Person{
       string _firstName;
       string _lastName;
   }
   function addPerson(string memory _firstName , string memory _lastName) public{
       people.push(Person(_lastName, _lastName));
       peopleCount += 1;
   }
}