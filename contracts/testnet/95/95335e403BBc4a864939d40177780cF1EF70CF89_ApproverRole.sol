/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account));
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account));
        role.bearer[account] = false;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract ApproverRole {
    using Roles for Roles.Role;

    event ApproverAdded(address indexed account);
    event ApproverRemoved(address indexed account);

    Roles.Role private _approvers;

    address firstSignAddress;
    address secondSignAddress;

    mapping(address => bool) signed; // Signed flag

    constructor() {
        _addApprover(msg.sender);

        firstSignAddress = 0xd6a2597C9DA2e800ECC741adFf746dEc2C938074; // You should change this address to your first sign address
        secondSignAddress = 0xFCa97C899A3bc2ae6EFdbe6b36298a6DBDD75dB2; // You should change this address to your second sign address
    }

    modifier onlyApprover() {
        require(isApprover(msg.sender));
        _;
    }

    function sign() external {
        require(
            msg.sender == firstSignAddress || msg.sender == secondSignAddress
        );
        require(!signed[msg.sender]);
        signed[msg.sender] = true;
    }

    function isApprover(address account) public view returns (bool) {
        return _approvers.has(account);
    }

    function addApprover(address account) external onlyApprover {
        require(signed[firstSignAddress] && signed[secondSignAddress]);
        _addApprover(account);

        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function removeApprover(address account) external onlyApprover {
        require(signed[firstSignAddress] && signed[secondSignAddress]);
        _removeApprover(account);

        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function renounceApprover() external {
        require(signed[firstSignAddress] && signed[secondSignAddress]);
        _removeApprover(msg.sender);

        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function _addApprover(address account) internal {
        _approvers.add(account);
        emit ApproverAdded(account);
    }

    function _removeApprover(address account) internal {
        _approvers.remove(account);
        emit ApproverRemoved(account);
    }
}