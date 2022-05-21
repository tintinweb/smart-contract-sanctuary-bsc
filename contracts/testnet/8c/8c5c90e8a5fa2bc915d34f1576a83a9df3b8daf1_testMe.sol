/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.7.0;

interface testMeInterface {
    function returnDataParm (string calldata parms) external;
}

contract testMe {
    function returnDataParm(string calldata parms) external
    {
        string memory testString = parms;
        revert(testString);
    }
    }