/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


interface IERC20 {
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function balanceOf(address tokenOwner)  external returns (uint balance);

}

contract Hi{

    address public sender;
    
    function hihi() public {

        sender = msg.sender;
    }
         }