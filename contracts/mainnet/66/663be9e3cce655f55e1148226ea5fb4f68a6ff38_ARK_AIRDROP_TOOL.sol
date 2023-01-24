/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

/*  
 * ARK Airdrop Tool
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
    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public constant CEO = 0xdf0048DF98A749ED36553788B4b449eA7a7BAA88;
    IBEP20 public constant ARK = IBEP20(0x111120a4cFacF4C78e0D6729274fD5A5AE2B1111);

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }

    constructor(){
        ARK.approveMax(address(vault));
    }
  
    function airdropFullBusd(address[] calldata wallets, uint256[] calldata amounts) external {
        for (uint i = 0; i < wallets.length; i++) BUSD.transferFrom(msg.sender, wallets[i], amounts[i]*10**18);
    }

    function airdropFractionalBusd(address[] calldata wallets, uint256[] calldata amounts) external {
        for (uint i = 0; i < wallets.length; i++) BUSD.transferFrom(msg.sender, wallets[i], amounts[i]);
    }

    function airdropFullArkAfterTaxBelowGuardian(address[] calldata wallets, uint256[] calldata amounts) external onlyCEO {
        uint256 total;
        for (uint i = 0; i < wallets.length; i++) total += amounts[i];
        ARK.transferFrom(msg.sender, address(this), total * 1092 * 10**18 / 1000);
        for (uint i = 0; i < wallets.length; i++) vault.depositFor(wallets[i], amounts[i]*1092 * 10**18 / 1000, address(0));
    }

    function airdropFractionalArkAfterTaxBelowGuardian(address[] calldata wallets, uint256[] calldata amounts) external onlyCEO {
        uint256 total;
        for (uint i = 0; i < wallets.length; i++) total += amounts[i];
        ARK.transferFrom(msg.sender, address(this), total * 1092 / 1000);
        for (uint i = 0; i < wallets.length; i++) vault.depositFor(wallets[i], amounts[i] * 1092 / 1000, address(0));
    }

    function airdropFullArkBeforeTaxBelowGuardian(address[] calldata wallets, uint256[] calldata amounts) external onlyCEO {
        uint256 total;
        for (uint i = 0; i < wallets.length; i++) total += amounts[i];
        ARK.transferFrom(msg.sender, address(this), total * 10**18);
        for (uint i = 0; i < wallets.length; i++) vault.depositFor(wallets[i], amounts[i] * 10**18, address(0));
    }

    function airdropFractionalArkBeforeTaxBelowGuardian(address[] calldata wallets, uint256[] calldata amounts) external onlyCEO {
        uint256 total;
        for (uint i = 0; i < wallets.length; i++) total += amounts[i];
        ARK.transferFrom(msg.sender, address(this), total);
        for (uint i = 0; i < wallets.length; i++) vault.depositFor(wallets[i], amounts[i], address(0));
    }
}