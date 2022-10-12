/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// File: contracts/BullRun/overflow.sol


pragma solidity 0.8.16;

contract overflow {

    function unsafe(uint8[] calldata numbers) pure external returns (uint16) {
        uint16 counter;
        for (uint8 i = 0; i < numbers.length;) {
            counter += numbers[i];
            unchecked { i++; }
        }
        return counter;
    }

    function safe(uint8[] calldata numbers) pure external returns (uint16) {
        uint16 counter;
        for (uint8 i = 0; i < numbers.length; i++) {
            counter += numbers[i];
        }
        return counter;
    }


}