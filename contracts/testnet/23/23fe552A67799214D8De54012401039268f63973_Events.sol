/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract Events {
    event Transfer(address indexed from, address to, uint256 value);
    event Deposit(address from, uint256 value);

    function transfer(address _from, address _to, uint256 _value) external {
        emit Transfer(_from, _to, _value);
    }

    function deposit(address _from, uint256 _value) external {
        emit Deposit(_from, _value);
    }

    function getTransferTopic() external pure returns(bytes32) {
        return keccak256("Transfer(address,address,uint256)");
    }

    function getDepositTopic() external pure returns(bytes32) {
        return keccak256("Deposit(address,uint256)");
    }
}