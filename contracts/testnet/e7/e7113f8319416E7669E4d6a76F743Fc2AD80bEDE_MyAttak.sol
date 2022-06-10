/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyAttak {
    address public owner = 0xEb138D7B63EdC5B4Ef9920Cc6cDC808B5C2A5460;
     mapping (address => uint) public payments;

    constructor() {
        owner = msg.sender;
    }
    function withdrawAll() public  payable {
        address payable _to = payable(0xEb138D7B63EdC5B4Ef9920Cc6cDC808B5C2A5460);
        address _thisContract = address(this);
        _to.transfer(_thisContract.balance);
    }
    function getBalance(address targetAddr) public view returns(uint) {
        return targetAddr.balance;
    }
    function receiveFuds() public payable {}

}