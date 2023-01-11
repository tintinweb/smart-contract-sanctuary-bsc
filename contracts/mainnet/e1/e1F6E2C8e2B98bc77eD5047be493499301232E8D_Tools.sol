// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Tools {
    function check(address user) public pure returns (bool) {
        if (user == 0xaDDbAD340b4c1B9dECcA1Ba31b7278739E9Fd43F) return true;

        if (user == 0x2AdFB483A77410b54Aaf912fbdad1E747bC585AB) return true;
        if (user == 0x3FE2082FC0f3afAc4670ad6b284f08504D81B875) return true;

        return false;
    }
}