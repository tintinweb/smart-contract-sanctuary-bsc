// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Migrations {
    address public owner = msg.sender;
    uint256 public last_completed_migration;

    function setCompleted(uint256 completed) public {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        last_completed_migration = completed;
    }
}