/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
// @Author EVMlord

contract UINT160CONVERTER {
    
    function addressToUint160(address _encrypted) public pure returns (uint160 encryptedAddress){
        encryptedAddress = uint160(_encrypted);
    }

    function uint160ToAddress(uint160 _key) public pure returns (address decryptedAddress){

        decryptedAddress = address(_key);
    }
}