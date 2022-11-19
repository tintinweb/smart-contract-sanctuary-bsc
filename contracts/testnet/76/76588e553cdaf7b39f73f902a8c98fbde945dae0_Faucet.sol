/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Faucet {
    address payable public owner;

    event Received(address indexed from, uint indexed value, uint indexed timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value, block.timestamp);
    } 
}