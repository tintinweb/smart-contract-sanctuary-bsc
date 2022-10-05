/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract myContract {
    string welcomeString = "Hi from the blockchain";

    function getString() public view returns (string memory welcome){
        return welcomeString;
    }

    function setString(string memory newString) public {
        welcomeString = newString;
    }
    
}