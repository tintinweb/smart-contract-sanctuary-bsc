/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Esium_Pay{

    mapping(string=>uint256) public orderToAmountPaid;
    address payable owner;

    constructor(address payable _owner) {
        owner = _owner;
    }

    function pay (string memory _order) payable public{
        owner.transfer(msg.value);
        orderToAmountPaid[_order] = msg.value;
    }

    function getOrder (string memory _order) public view returns(uint256){
        return orderToAmountPaid[_order];
    }

    function changeOwner(address payable _newOwner) public onlyOwner{
        owner = _newOwner;
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