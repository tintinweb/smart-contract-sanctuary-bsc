/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
// @dev: @PatoVerde
pragma solidity ^0.8.14;

contract simpleEmit {

    event Deposit(uint Amount);
    event Release(uint Amount);

    function deposit(uint Amount) public {
        emit Deposit(Amount);
    }

    function release(uint Amount) public {
         emit Release(Amount);
    }
}