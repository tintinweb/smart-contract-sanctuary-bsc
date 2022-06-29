/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

contract Rescue{
    address owner;
    constructor(){
        owner=msg.sender;
    }

    function rescueToken(address tokenAddress) external{
        require(msg.sender==owner);
        IERC20 token=IERC20(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}