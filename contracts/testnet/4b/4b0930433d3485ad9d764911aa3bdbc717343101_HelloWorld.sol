/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
contract HelloWorld {
    string myText = "Hello Dennis Ritche";

    function setString(string memory x) public {
        myText = x;
    }
    
    function getString() public view returns(string memory) {
        return myText;
    }
}