/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15; 

contract Hashing  {

    function HashToSign (
        address authorizedWallet,
        uint coinAmount,
        uint userWallet,
        uint salt) public pure returns(bytes32 data) {
            data = keccak256(abi.encode(authorizedWallet,coinAmount,userWallet,salt));
    }

}