/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Counter {
    int public counter;

    function Election () public {
        counter = 0;
    }

    function increment () public {
        counter += 1;
    }
}