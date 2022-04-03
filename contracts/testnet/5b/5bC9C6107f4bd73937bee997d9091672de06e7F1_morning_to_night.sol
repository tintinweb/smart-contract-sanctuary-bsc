/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract morning_to_night{ 
    function timeChange(uint256 time, string memory greetings) pure public returns(string memory){
        if(time<12){
            greetings = "Good Morning";
            return greetings;
        }
        else{
            greetings = "Good Night";
            return greetings;
        }
    } 
}