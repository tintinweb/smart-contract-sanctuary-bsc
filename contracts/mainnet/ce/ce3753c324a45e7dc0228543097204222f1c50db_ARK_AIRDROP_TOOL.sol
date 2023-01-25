/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

/*  
 * ARK Airdrop Tool With Referrer
 * 
 * Written by: MrGreenCrypto
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.16;

interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    function approveMax(address spender) external returns (bool);
}

interface IVAULT {
    function depositFor(address investor, uint256 amount, address referrer) external returns (uint256);
}

contract ARK_AIRDROP_TOOL {
    IVAULT public vault = IVAULT(0x66665CA5cb0f83E9cB813E89Ca64bD6cDd4C6666);
    IBEP20 public constant ARK = IBEP20(0x111120a4cFacF4C78e0D6729274fD5A5AE2B1111);

    constructor(){
        ARK.approveMax(address(vault));
    }

    function airdropFullArkWithReferral(address[] calldata wallets, uint256[] calldata amounts, address referrer) external {
        uint256 total;
        for (uint i = 0; i < wallets.length; i++) total += amounts[i];
        ARK.transferFrom(msg.sender, address(this), total * 10**18);
        for (uint i = 0; i < wallets.length; i++) vault.depositFor(wallets[i], amounts[i] * 10**18, referrer);
    }

}