/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract TestEvent {

    uint256 public myLovelyNumber;

    event LovelyNumberChanged(
        address indexed changer,
        uint256 oldNumber,
        uint256 newNumber
    );

    function changeNumber(uint256 newNumber) external {
        emit LovelyNumberChanged(
            msg.sender,
            myLovelyNumber,
            newNumber
            );
    myLovelyNumber = newNumber;  
    }


}