// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Test.sol";
import "./ITestFactory.sol";

contract TestFactory is ITestFactory {
    mapping(uint256 => bool) public checkId;

    function newChainPay(uint256 id) external override {
        require(!checkId[id], "ChainPayFactory: id exists");
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, block.number));
        ChainPay chainPay = new ChainPay{salt: salt}(id);
        checkId[id] = true;
        emit ChainPayLog(id, address(chainPay));
    }
}