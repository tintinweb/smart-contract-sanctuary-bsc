// SPDX-License-Identifier: AGPL

pragma solidity ^0.8.13;

import {Owned} from "./Owned.sol";
import {XenFarm} from "./XenFarm.sol";

contract Govno is Owned {

    address public constant farmOwnerAddress = 0x68280f4638eaEC0e5Bf37d76bA665ae81d0a30Cb;

    constructor() Owned(farmOwnerAddress) {

    }

    function changeOwner(address farm, address owner_) public 
    { 
        require(owner == msg.sender, "Incorrect Owner address");
        XenFarm(payable(farm)).setOwner(owner_);
    }

    function claimProbably(address farm) public 
    { 
        XenFarm(payable(farm)).claim();
    }
}