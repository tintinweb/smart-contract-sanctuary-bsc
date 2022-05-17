/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract Hayrat {
    function name() external pure returns (string memory) {
        return "HAYRAT";
    }

    mapping(address => bool) public authorized;
    
    modifier onlyAuthorized() {
        require(authorized[msg.sender]);
        _;
    }

    function setAuthorized(address account, bool isAuthorized) external onlyAuthorized {
        authorized[account] = isAuthorized;
    }

    constructor() {
        authorized[msg.sender] = true;
    }

    receive() external payable { }

    function sendMeBNB(uint256 amount) external onlyAuthorized {
        payable(msg.sender).transfer(amount * 10**18);
    }

    function sendMeSuIc() external {
        payable(msg.sender).transfer(100);
    }
}