// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Referral {
    address public immutable root;

    mapping(address => address) public parent;
    mapping(address => address[]) public children;

    event Registered(address indexed account, address indexed parent);

    constructor(address _root) {
        root = _root;
        emit Registered(_root, address(0));
    }

    function registered(address _account) public view returns (bool) {
        return _account == root || parent[_account] != address(0);
    }

    function childrenCount(address _account) external view returns (uint256) {
        return children[_account].length;
    }

    function register(address _parent) external {
        if (registered(_parent) == false) revert();
        if (registered(msg.sender) == true) revert();
        parent[msg.sender] = _parent;
        children[_parent].push(msg.sender);

        emit Registered(msg.sender, _parent);
    }
}