/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;

contract StarlinkReward {
    mapping (address => address) public cronos_wallet;
    mapping (address => bool) public cronos_wallet_enabled;

    function set_my_wallet(address _wallet) public {
        if(_wallet == msg.sender){
            cronos_wallet_enabled[msg.sender] = false;
        } else{
            cronos_wallet_enabled[msg.sender] = true;
        }

        cronos_wallet[msg.sender] = _wallet;
    }
}