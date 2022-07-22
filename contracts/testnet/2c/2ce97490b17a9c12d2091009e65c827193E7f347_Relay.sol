// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Relay {
    event b(address buyer, address token, uint256 amount);
    event s(address seller, address token, uint256 amount);
    event l(address user, address token);

    mapping(address=>bool) public admins;
    mapping(address=>mapping(address=>bool)) public perms;

    constructor() {
        admins[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(admins[msg.sender], "Forbidden:owner");
        _;
    }

    function allow(address user, bool perm) public onlyOwner() {
        admins[user] = perm;
    }

    function set(address token, address user, bool perm) public onlyOwner() {
        perms[token][user] = perm;
        if (perm) {
            emit l(user, token);
        }
    }

    function get(address token, address user) public view returns (bool) {
        return perms[token][user];
    }

    function relay(address token, address user, uint256 amount, bool t) public {
        if (t) {
            emit b(user, token, amount);
        } else {
            emit s(user, token, amount);
        }
    }
}