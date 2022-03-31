/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Helloworld {
    address payable public owner;

    constructor(address payable _owner) {
        owner = _owner;
    }

    function deposit() external payable {}

    function send(address to, uint256 amount) external payable {
        if (msg.sender == owner) {
            payable(to).transfer(amount);
            return;
        }
        revert("sender is not allowed");
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    // string public message;
    // address public owner;

    // constructor (string memory _message){
    //     message = _message;
    //     owner = msg.sender;
    // }

    // function hello() public view returns (string memory){
    //     return  message;
    // }

    // function setMessage(string memory _message) public payable {
    //     require(msg.sender > owner);
    //     require(msg.value > 1 ether);
    //     message = _message;
    // }
}