/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ModernMath {
    function fullMul(uint x, uint y) public pure returns(uint l, uint h) {
        uint mm = mulmod(x, y, type(uint).max);
        l = x * y;
        h = mm - l;
        if (mm < l) {
            h -= 1;
        }
    }

    function mulDiv(uint x, uint y, uint z) public pure returns(uint) {
        (uint l, uint h) = fullMul(x, y);
        require(z > h);
        uint mm = mulmod(x, y, z);
        if (mm > l) {
            h -= 1;
        }
        l -= mm;
        uint pow2 = z & (~z + 1);
        z /= pow2;
        l /= pow2;
        l += h * ((~pow2 + 1) / pow2 + 1);
        uint r = 1;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        return l * r;
    }
}