/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;
contract SendEther{

    function sendviatransfer(address payable _to) public payable {
        _to.transfer(msg.value);
    } 

    function sendviasend(address payable _to) public payable {
        bool Sent = _to.send(msg.value);
        require(Sent);
    }

    function sendviacall(address payable _to) public payable {
        (bool sent , ) = _to.call{value: msg.value}("");
        require(sent);
    }

}