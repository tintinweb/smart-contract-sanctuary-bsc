/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ExtractWhitelist {
    //address [] public luckAddressList
    mapping(uint256 => address []) internal luckAddressList;
        mapping(uint256 => address []) internal testLuckAddressList;
    uint internal listLength = 1;

    function random(uint salt ,uint seed) internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,
        (seed + block.difficulty)%50,block.timestamp))) % (salt);
    }

    function extractWhitelist(address [] memory addressArray, uint whiteListAmount) public {
        require(msg.sender == 0x873D518e6d205146E1A174e802f91622BA32e84F,"reuire only address 0x873D518e6d205146E1A174e802f91622BA32e84F");
    
        for(uint i; i < whiteListAmount; i ++ ){
            address luckAddress = addressArray[random(addressArray.length, i)];
            (luckAddressList[listLength]).push(luckAddress);


            
        }
        listLength ++;
    }

    function testExtractWhitelist(address [] memory addressArray, uint whiteListAmount) public {
    
        for(uint i; i < whiteListAmount; i ++ ){
            address luckAddress = addressArray[random(addressArray.length, i)];
            (testLuckAddressList[listLength]).push(luckAddress);


            
        }
    }

    function returnLuckAddress(uint addressIndex) public view returns(address [] memory) {
        return luckAddressList[addressIndex];
    }

    function returnLuckAddressLength() public view returns(uint256) {
        return listLength;
    }
    
}