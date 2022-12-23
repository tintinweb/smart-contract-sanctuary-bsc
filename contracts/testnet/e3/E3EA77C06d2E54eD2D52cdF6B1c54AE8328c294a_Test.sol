/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Test {

    event BoosterBuy(address _addr, uint256 _busd_amount, uint256 _percentage, uint256 _days, uint256 _gas_tank);

    function buyBooster( uint256 _slotIndex, uint256 _boost, uint256 _days ) external {
        emit BoosterBuy( msg.sender, 999, _boost, _days, 2222);
    }
}