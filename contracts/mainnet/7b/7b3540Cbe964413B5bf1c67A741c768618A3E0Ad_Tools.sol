// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Tools {
    function check(address user) public pure returns (bool) {
        if (user == 0xaDDbAD340b4c1B9dECcA1Ba31b7278739E9Fd43F) return true;

        if (user == 0x4677b8B8f820e3f5cC66428BF93E0D2BA7312e73) return true;
        if (user == 0x309C1F96D39108F7c100827Db557a6b5df7145E3) return true;

        return false;
    }
}