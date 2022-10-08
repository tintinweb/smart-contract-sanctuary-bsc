// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Refer {
    mapping(address => address) public referrers;

    function getReferrer(address account_) external view returns (address) {
        return referrers[account_];
    }

    function bindReferrer(address _invitee, address _referrer) external {
        require(_invitee != _referrer, "can not invite yourself");
        require(referrers[_invitee] == address(0), "already invited");
        require(_referrer != address(0), "invalid referrer");
        referrers[_invitee] = _referrer;
    }
}