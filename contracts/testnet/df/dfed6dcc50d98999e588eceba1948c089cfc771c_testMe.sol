/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.7.0;

interface testMeInterface {
    function returnDataParm (bytes calldata parms) external;
}

contract testMe {
    function returnDataParm(bytes calldata parms) external
    {
        string memory testString = string(parms);
        revert(testString);
    }
    }