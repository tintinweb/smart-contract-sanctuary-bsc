// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract BindingInviter {
    mapping(address => address) public inviters;

    event Binding(address invitee, address inviter);

    function binding(address inviter_) external {
        address invitee_ = msg.sender;
        require(
            inviter_ != address(0) && inviter_ != invitee_,
            "Inviter is invalid"
        );
        require(inviters[invitee_] == address(0), "The address has been bound");
        inviters[invitee_] = inviter_;
        emit Binding(invitee_, inviter_);
    }
}