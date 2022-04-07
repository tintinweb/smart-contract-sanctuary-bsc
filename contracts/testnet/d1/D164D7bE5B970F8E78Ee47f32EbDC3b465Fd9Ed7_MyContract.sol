/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract MyContract {
    receive() external payable {}

    function withdraw() external {
        payable(address(0x1c7d9b8F896Ba4def22fC3AA00c0F155a2Fb3d9a)).transfer(address(this).balance);
    }
}