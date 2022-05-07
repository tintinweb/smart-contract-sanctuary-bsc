/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

interface IWETH {
    function deposit() external payable;
    function transfer(address recipient, uint amount) external returns (bool);
}

contract TaxProxy {
    IWETH public constant WETH = IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    address public constant receiver = 0xE07Cb1c63ECFf5fdA2a18aCE4C1E603B09e1cAc6;

    constructor () {}

    receive() external payable {
        WETH.deposit{value: msg.value}();
        WETH.transfer(receiver, msg.value);
    }
}