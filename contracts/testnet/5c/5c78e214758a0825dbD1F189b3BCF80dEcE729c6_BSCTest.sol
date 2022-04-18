/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

contract BSCTest {
    string public INPUT = 'Hello World';

    function setInput(string memory userInput) public {
        INPUT = userInput;
    }

}