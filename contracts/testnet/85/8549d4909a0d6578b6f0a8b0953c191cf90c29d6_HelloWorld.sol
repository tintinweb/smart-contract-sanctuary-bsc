/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
contract HelloWorld {
    string myText = "GG";

    function setString(string memory x) public {
        myText = x;
    }
    function getString() public view returns(string memory){
        return myText;
    }


}