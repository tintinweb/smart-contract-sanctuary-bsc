// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract CV {
    function convert(address addr) public view returns (uint256) {
        return uint256(addr);
    }

    function convert2(uint256 numb) public view returns (address) {
        return address(numb);
    }
}