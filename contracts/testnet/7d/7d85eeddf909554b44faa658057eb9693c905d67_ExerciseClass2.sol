/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ExerciseClass2 {
    // declaration and assignment of state variables
    uint maxTotalSuply = 500;
    address owner = msg.sender;

    // function input new max total suply (state variable / storage)
    // for security reasons I use a require and that only the owner can change this value
    function setMaxTotalSuply(uint newMax) internal {
        //require(msg.sender == owner, "Only the owner has permission");
        maxTotalSuply = newMax;
    }

    // function output max total suply (local variable / memory)
    function getMaxTotalSuply() external view returns (uint) {
        return maxTotalSuply;
    }

    // function output owner,s address (global variable / storage)
    function getOwner() external view returns (address) {
        return owner;
    }

    // function output token,s info (local variable / memory)
    function getTokenInfo() external pure returns (string memory) {
        string memory tokenInfo = "Peringolo coin  (PLC)";
        return tokenInfo;
    }
}