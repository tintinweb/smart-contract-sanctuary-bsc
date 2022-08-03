/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;
//pragma experimental ABIEncoderV2;

contract gasLeft  {
    function a() external view returns(uint256 gasLimit) {
       gasLimit = gasleft();
    }
}