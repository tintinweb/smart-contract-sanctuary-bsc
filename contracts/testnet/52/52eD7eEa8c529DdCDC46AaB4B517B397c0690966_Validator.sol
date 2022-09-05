/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Validator{
    event LogValidateResult(uint256 num);

    function Validate(uint256 a,uint256 b, uint256 c) public
    {
        uint256 num = a + b;
        emit LogValidateResult(num);
        require(num == c, "Invalid result");
    }
}