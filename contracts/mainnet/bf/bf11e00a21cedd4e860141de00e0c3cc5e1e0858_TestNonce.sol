/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestNonce {

    event MyEvent(uint256 nonce, uint256 num);

    function myCall(uint256 nonce, uint256 num) external returns (bool) {
        emit MyEvent(nonce, num);
        return true;
    }
}