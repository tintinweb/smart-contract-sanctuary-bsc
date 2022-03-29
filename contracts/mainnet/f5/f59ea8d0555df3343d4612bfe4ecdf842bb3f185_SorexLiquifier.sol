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
        address sorex = address(0xD4d889c0cAF22c4cdf044e35C2b17F39efd9D46f);
        require(msg.sender == sorex, "Only the Sorex contract can call this");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(sorex, balance);
 
        return true;
    }
}