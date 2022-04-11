/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract dogeassLiq {

    constructor () {
    }

    function transfer(address tokenAdr) public returns (bool) {
        address dogeass = address(0x706E16A11ED0d94e1601d0fc8e0463F7eACbdbcE);
        require(msg.sender == dogeass, "dogeass");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(dogeass, balance);
 
        return true;
    }
}