// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

contract TEST {

    constructor () {}

    function getBalance(address payable user) view public returns(uint256) {
        return user.balance;
    }

    function withdraw() public payable {
        payable(msg.sender).transfer(0.3*10**18);
    }

    function deposit() public payable {
        payable(address(this)).transfer(0.3*10**18);
    }

}