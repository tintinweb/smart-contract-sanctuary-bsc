/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
/** @title Aggregator */
/** @author Zergity */

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Unwrap {
    uint private constant LARGE_VALUE = 0x8000000000000000000000000000000000000000000000000000000000000000;
    address private constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    address private constant COIN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private constant WCOIN = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    receive() external payable {}

    function doIt() external payable {
        IWETH(WCOIN).deposit{value: msg.value}();
        // uint balance = IERC20(WCOIN).balanceOf(address(this));
        IWETH(WCOIN).withdraw(msg.value);
        // msg.sender.call{value: balance}(new bytes(0));
    }
}