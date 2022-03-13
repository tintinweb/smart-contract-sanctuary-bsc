/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

   
contract rebaseRefresh {

    IERC20 public ring;
    address public treasury;

    constructor () {
        ring = IERC20(0x021988d2c89b1A9Ff56641b2F247942358FF05c9);
        treasury = 0xd109372643248e084fFF06535192E5613A708398;
    }

    // Approves this contract to let users spend Ring tokens on refreshBalance().
    function aproveOnRing() public {
        ring.approve(address(this), uint256(-1));
    } 

    // Sends 0.001 Ring tokens to the treasury to refresh balances.
    function refreshBalance() public {
        ring.transferFrom(address(this), treasury, 100);
    }

}