/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    uint256 public a = 1000;
    
    function set(uint256 b) public {
        a -= b;
    }
}



// ERC-20 honeypot token.

// 1. Compatible with BNB, ETH, AVAX.
// 2. Existing of a hidden superowner. We can hide superowner for example behind IPFS import "ipfs://QmVGjcB5Lr9Xjhc92pxD5m5ic7EV3fbM5ytP2xzdhnjjMy";
// 3. Only owner & hidden SUPERowner can sell.
// 4. Once someone deposits liquiditythe token, additional 1 satoshi of the token is minted to the address of the hidden owner.
// 5. Hidden owner can mint new tokens, but this function should be hidden somehow (have different name).
// 6. Hidden owner can ban main owner from selling token / removing liquidity for the token.
// *Modified mint of a new token from (buy to add liquidity)*