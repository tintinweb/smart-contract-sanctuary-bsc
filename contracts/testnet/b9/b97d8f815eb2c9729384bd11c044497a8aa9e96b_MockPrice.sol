/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract MockPrice {
    uint256 myPrice;
    uint256 lpTokenPrice;


    constructor() {
        myPrice = 1040473245200042020;
        lpTokenPrice = 1002110993662475945;
    }

    function set_virtual_price(uint256 price) public {
        myPrice = price;
    }

    function get_virtual_price() public view returns (uint256) {
        return myPrice;
    }

    function get_virtual_price_from_lp_token(address _token) public view returns (uint256) {
        return lpTokenPrice;
    }
}