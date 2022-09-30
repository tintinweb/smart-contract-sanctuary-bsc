/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Payment{

    mapping(string=>uint256) public orderToAmountPaid;
    address payable immutable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function pay (string memory _order) payable public{
        owner.transfer(msg.value);
        orderToAmountPaid[_order] = msg.value;
    }

    function getOrder (string memory _order) public view returns(uint256){
        return orderToAmountPaid[_order];
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {
        owner.transfer(msg.value);
    }

    fallback() external payable{
        owner.transfer(msg.value);
    }


}