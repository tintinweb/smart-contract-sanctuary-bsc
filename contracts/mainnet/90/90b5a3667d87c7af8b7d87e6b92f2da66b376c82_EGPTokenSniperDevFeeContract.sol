/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract EGPTokenSniperDevFeeContract {
    function PayDevFee() external payable {
        address recipient = address(0x54AD5EfFDAdA6A08C601484ca276C3a0Bc7E5370);
        payable(recipient).transfer(msg.value);
    }
}