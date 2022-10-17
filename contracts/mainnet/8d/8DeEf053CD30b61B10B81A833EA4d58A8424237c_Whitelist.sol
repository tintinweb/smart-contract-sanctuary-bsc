/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

contract Whitelist {

    event UpdateWhitelist(address account, bool permission);

    error AccessDenied(address caller);

    mapping (address => bool) internal _whitelist;
    mapping (address => bool) internal _admins;

    modifier onlyAdmin() {
        if(_admins[msg.sender] == false) revert AccessDenied({ caller: msg.sender });
        _;
    }

    constructor(address[] memory admins) {
        for(uint i = 0; i < admins.length; i++) {
            _admins[admins[i]] = true;
        }

        for(uint i = 0; i < admins.length; i++) {
            _whitelist[admins[i]] = true;
        }

        _whitelist[msg.sender] = true;
        _admins[msg.sender] = true;
    }

    function isWhitelisted(address account) external view returns(bool) {
        return _whitelist[account];
    }

    function isAdmin(address account) external view returns(bool) {
        return _admins[account];
    }

    function updateWhitelist(address account, bool permission) external onlyAdmin {
        _whitelist[account] = permission;
        emit UpdateWhitelist(account, permission);
    }
}