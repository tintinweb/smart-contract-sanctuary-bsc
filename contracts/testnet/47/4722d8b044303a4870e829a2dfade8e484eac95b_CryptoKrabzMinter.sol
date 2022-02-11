/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract CryptoKrabz {
    function mintPublicKrabz(address, uint) external payable {}
}

contract CryptoKrabzMinter {
    CryptoKrabz ck = CryptoKrabz(0x5044AcA0b1707843fBbE9D0393878c474Baa4aEe);
    mapping(address => uint) public referrals;
    event Referral(address indexed referrer, address indexed minter, uint quantity);
    function mint(address to, uint quantity, address referrer) external payable {
        ck.mintPublicKrabz{value: msg.value}(to, quantity);
        referrals[referrer] += quantity;
        emit Referral(referrer, to, quantity);
    }
}