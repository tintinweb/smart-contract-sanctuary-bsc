/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Khatri {
   string  message;
   string  name;
   string  email;
   string  mobileNumber;
   string  age;
   string  dob;

   constructor(string memory initMessage , string memory initName ,string memory initAge ,string memory initMobileNumber, string memory initDob,string memory initEmail  ) {
      message = initMessage;
      name = initName;
      age= initAge;
      dob= initDob;
      mobileNumber = initMobileNumber;
      email= initEmail;
   }

    function get() public view returns(string memory ,string memory ,string memory ,string memory,string memory,string memory) {
        return (message,email,name,mobileNumber,age,dob);
    }

   function update(string memory newMessage , string memory newName,
    string memory newAge, string memory newDob, string  memory newEmail, 
      string memory newMobileNumber) public {
      message = newMessage;
      name = newName;
      age= newAge;
      dob= newDob;
      mobileNumber = newMobileNumber;
      email= newEmail;
   }
}