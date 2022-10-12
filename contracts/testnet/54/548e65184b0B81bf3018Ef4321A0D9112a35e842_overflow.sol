/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// File: contracts/BullRun/overflow.sol


pragma solidity 0.8.16;

contract overflow {

    function unsafe(uint8[] calldata numbers) pure external {
        for (uint8 i = 0; i < numbers.length;) {
            uint16 counter;
            counter += numbers[i];
            unchecked { i++; }
        }
    }

    function safe(uint8[] calldata numbers) pure external {
        for (uint8 i = 0; i < numbers.length; i++) {
            uint16 counter;
            counter += numbers[i];
        }
    }


}