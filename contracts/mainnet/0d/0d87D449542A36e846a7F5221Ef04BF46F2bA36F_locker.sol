/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

pragma solidity ^0.8.10;

//SPDX-License-Identifier: Unlicensed

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract locker {

    uint public lockUntill;
    address public depositerAddress;
    uint public blockNum = block.number;

    constructor() {

        lockUntill = block.number + 2592000;
        depositerAddress = msg.sender;
    }

    function retrieveTokens() public {
        require(block.number > lockUntill, "Trying to retrieve tokens within the lock period");
        ERC20 tokenContract = ERC20(0x4208e1F3588d6a6Da6f3842A2D9898a9c96aEEe1);
        uint amountToWithdrawl = tokenContract.balanceOf(address(this));
        require(amountToWithdrawl != 0, "Amount to witdrawl is zero");
        tokenContract.transfer(depositerAddress,amountToWithdrawl);
        selfdestruct(payable(depositerAddress));
    }
}