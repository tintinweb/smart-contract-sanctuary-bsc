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

//address public nativ = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
address public nativ = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function depositBNB() public payable {
    IWBNB(nativ).deposit{value : msg.value}();
    }

    receive() external payable {}

 
}