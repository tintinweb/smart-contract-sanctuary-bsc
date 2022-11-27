/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

//SPDX-License-Identifier: MIT

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity 0.6.12;

contract MyContract {

address public nativ = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    function depositBNB() public payable {
    IWBNB(nativ).deposit{value : msg.value}();
    }

    receive() external payable {}

 
}