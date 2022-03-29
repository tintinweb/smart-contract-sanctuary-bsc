/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT
// Liquififier for Sorex.io
pragma solidity >=0.8.2;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SorexLiquifier {
  
    constructor () {
    }

    function transfer(address tokenAdr) public returns (bool) {
        address sorex = address(0xB89c4468Bd7df78282363548c41a4918FECE2A00);
        require(msg.sender == sorex, "Only the Sorex contract can call this");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(sorex, balance);
 
        return true;
    }
}