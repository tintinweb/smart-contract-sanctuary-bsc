/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;



contract SubContract {
    function _msgSender() public view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() public view virtual returns (bytes calldata) {
        return msg.data;
    }

}