/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract ABI_X {
    event SuccessExecute(bool success, string message);
    event SuccessExecute(bool success);
    function execTransaction(
        address from, 
        address to, 
        uint value, 
        bytes memory data, 
        uint operation, 
        address gasToken,
        uint safeTxGas,
        uint baseGas,
        bytes memory signature
    ) external payable
    {

    }
}