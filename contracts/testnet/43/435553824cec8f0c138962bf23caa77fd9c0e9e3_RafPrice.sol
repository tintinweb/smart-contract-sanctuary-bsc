/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract RafPrice {
    uint raf_price;

    function set(uint price_usd) public {
        raf_price = price_usd;
    }

    function get() public view returns (uint) {
        return raf_price;
    }
}