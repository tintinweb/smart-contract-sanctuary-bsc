/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

//https://solidity-by-example.org/sending-ether/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Rec{
    receive() external payable {}
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Sen{
    function Tran(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function Send(address payable _to) public payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function Call(address payable _to) public payable {
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}