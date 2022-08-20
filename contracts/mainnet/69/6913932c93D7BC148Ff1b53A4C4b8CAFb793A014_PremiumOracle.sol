/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PremiumOracle {
    uint256 public premium;
    address public manager;
    constructor() {
        manager = msg.sender;
    }

    function getPremium() public view returns(uint256) {
        return premium;
    }

    function setPremium(uint256 _premium) public {
        require(msg.sender == manager);
        premium = _premium;
    }
}