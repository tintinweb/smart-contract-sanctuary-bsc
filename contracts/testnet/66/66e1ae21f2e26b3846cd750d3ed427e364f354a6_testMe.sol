/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.7.0;

interface testMeInterface {
    function returnDataParm (bytes calldata data) external;
}

contract testMe {
    function returnDataParm(bytes calldata data) external
    {
        revert("Test revert");
    }
    }