/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract BalanceFetcher {

    function fetch (address _address) external view returns (uint) {
        return _address.balance;
    }

}