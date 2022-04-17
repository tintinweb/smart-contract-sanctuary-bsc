/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract GoldKu {
    address public own;
    receive() external payable {}
    constructor() payable{
        own = msg.sender;
    }
    function withdraw() public payable{
        require(msg.sender == own);
    }

    function get() public view returns(address){
        return own;
    }
}