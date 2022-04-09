/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract MarathonGame {
    uint256 public boxPrice;
    address private owner;

    constructor() {
        boxPrice = 100000000000000000; //0.1 bnb
        owner = msg.sender;
    }

    function buyBox() public payable{
        require(msg.value == boxPrice, "Invalid value");
    
    }

    function setBoxPrice(uint256 _boxPrice) public {
        require(msg.sender == owner, "Caller is not owner");
        boxPrice = _boxPrice;
    }


    function getOwner() external view returns (address) {
        return owner;
    }


}