/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract FeeValue{

    uint8 fee;
    address private owner;
    constructor()
    {
        fee = 50;
        owner = msg.sender;
    }

    function setFee(uint8 new_fee) public
    {
        require(msg.sender == owner,"Not authorized");
        require(new_fee <= 200, "Fee can't be more than 20%");

        fee = new_fee;
    }

    function getFee() public view returns (uint8)
    {
        return fee;
    }

}