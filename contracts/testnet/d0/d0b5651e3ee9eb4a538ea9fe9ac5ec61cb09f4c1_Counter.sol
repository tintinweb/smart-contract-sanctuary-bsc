/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

contract Counter
{
    uint public counter;

    constructor()
    {
        counter = 0;
    }

    function Count() external
    {
        ++counter;
    }

}