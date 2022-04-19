/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

//SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 <0.9.0;

contract Hello {
    mapping(address=>uint) addressVote;

    function vote() public {
        addressVote[msg.sender] += 1;
    }

    function get(address _addr) public view returns (uint){
        return addressVote[_addr];
    }
}