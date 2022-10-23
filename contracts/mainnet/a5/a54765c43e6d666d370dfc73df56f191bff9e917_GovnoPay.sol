// SPDX-License-Identifier: AGPL

pragma solidity ^0.8.13;

import {Owned} from "./Owned.sol";

contract GovnoPay is Owned {
    address public constant god = 0x11e03363b2156521F5C4024733a961FC7E73B494;
    address public directAddress;

    event Forward(address indexed from, address indexed to, uint256 amount); 

    constructor() Owned(god) {
        directAddress = 0x4542bC427026eDE6D3c1AF67333be0733dAD1502;
    }

    receive() external payable {
        payable(directAddress).transfer(msg.value);
        emit Forward(msg.sender, directAddress, msg.value);
    }

    function setNewAddress(address directAddress_) public {
        require(msg.sender == god, "UNAUTHORIZED");
        directAddress = directAddress_;
    }
}