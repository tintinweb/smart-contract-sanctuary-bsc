/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract EncodeFunction {


    function getAbiEncode(string memory data, string memory parameters) external pure returns (bytes memory) {
        return abi.encodeWithSignature(data, parameters);

    }
}