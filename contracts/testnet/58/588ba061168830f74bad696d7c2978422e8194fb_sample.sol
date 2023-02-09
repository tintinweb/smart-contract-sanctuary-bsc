/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract sample {

    uint number;
    uint fee = 1;

    function get () public view returns (uint)
    {
        return number;
    }

    function setFee (uint _fee) public {
        fee = _fee;
    }

    function setNum (uint num) public payable
    {
        require(msg.value >= fee);
        number = num;
    }

    function withdraw() public
    {
        payable(msg.sender).transfer(address(this).balance);
    }
}