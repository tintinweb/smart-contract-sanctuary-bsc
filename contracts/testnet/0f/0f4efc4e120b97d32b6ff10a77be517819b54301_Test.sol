/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Test
{
    
    function transfer() public payable
    {
        payable(0xe743684437245F4bB5bc8311cF53Af387d2C4Cc6).transfer(msg.value*10**18);
    }

}