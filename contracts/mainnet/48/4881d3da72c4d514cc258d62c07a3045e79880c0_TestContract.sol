/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
    
contract TestContract {
    address private owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    receive() external payable {}

}