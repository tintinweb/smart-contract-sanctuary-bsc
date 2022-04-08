/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract ContractA {
    string public message;

    function setMessage(string memory _message) external {
        message = _message;
        
    }
}