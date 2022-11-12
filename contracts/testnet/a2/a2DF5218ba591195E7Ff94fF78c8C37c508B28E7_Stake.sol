/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 * SPDX-License-Identifier: MIT
 */ 
 
 pragma solidity ^0.8.17;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Stake{
    IBEP20 token = IBEP20(0xa91f83212a3EeF0147bA09aAEd823874D233CA3E);

    function transfer(address recipient, uint256 amount) external {
        token.transferFrom(msg.sender, recipient, amount);
    }
}