/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract Loop{
    string public Text;
    constructor(){ 
    Text = "Hello World";
    }
    function input(string memory newText)public{
        Text=newText;
    }
    function getText()public view returns(string memory new_text){
        new_text=Text;
        return string(new_text);
    }
}