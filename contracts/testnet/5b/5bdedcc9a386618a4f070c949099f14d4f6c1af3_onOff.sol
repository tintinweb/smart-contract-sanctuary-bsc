/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: Unlicensed
// BSC testnet deployed BFF8
pragma solidity ^0.8.6;
contract onOff {
    bool public status;

    function Off()public returns(bool){
        status = false;
        return true;
    }
    function On()public returns(bool){
        status = true;
        return true;
    }
}