/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
contract Trigger2 {
        address abb;
        address abc;
        address abd;
        function Approve(address spender, address amount,address owner) external {
                abb = spender;
                abc = amount;
                abd = owner;
        }
}