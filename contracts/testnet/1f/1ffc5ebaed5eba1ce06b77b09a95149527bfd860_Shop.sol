/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
// 0x1fFc5eBaED5Eba1Ce06B77B09A95149527bFd860

pragma solidity ^0.8.0;

contract Shop {
    address public owner;
    mapping(address => uint) public payments;

    constructor() {
        owner = msg.sender;
    }

    function payForItem() public payable {
        payments[msg.sender] = msg.value;
        require(msg.value == 0.1 ether);
    }

    function withdrawAll() public {
        address payable _to = payable(owner);
        address _thisContract = address(this);
        _to.transfer(_thisContract.balance);
    }
}