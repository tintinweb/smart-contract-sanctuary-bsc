/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract RDNAccountLinking {
    event AccountLinked (
        address indexed addr,
        uint256 indexed code
    );

    function linkAccount(uint256 _code) public {
        emit AccountLinked(msg.sender, _code);
    }
}