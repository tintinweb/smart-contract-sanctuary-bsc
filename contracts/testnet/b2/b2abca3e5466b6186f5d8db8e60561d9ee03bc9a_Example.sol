/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
// Creating a contract
contract Example {

// Declaring private
// state variable
string username;
string useremail;
uint256 usermobile;
uint256 userage;
string userdob;

// Defining public functions
function updateValue(
    string memory name,
    string memory email,
    uint256 mobile,
    uint256 age,
    string memory dob) public { 
		username = name;
		useremail = email;
		usermobile = mobile;
		userage = age;
		userdob = dob;
	}
function getValue()
    public 
	view
    returns(string memory name, string memory email, uint256 mobile, uint256 age, string memory dob)
  {
    return(
      username, 
      useremail, 
      usermobile,
      userage,
      userdob
	  );
  } 

}