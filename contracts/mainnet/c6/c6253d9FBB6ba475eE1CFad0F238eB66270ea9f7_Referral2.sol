// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Referral {
    address public immutable root;

    mapping(address => address) public parent;
    mapping(address => address[]) public children;

    event Registered(address indexed account, address indexed parent);

    constructor(address _root) {
        root = _root;
    }

    function isRegistered(address _account) public view returns (bool) {
        if (_account == root) {
            return true;
        }

        return parent[_account] != address(0);
    }

    function childrenCount(address _account) external view returns (uint256) {
        return children[_account].length;
    }

    function _register(address _account, address _parent) internal {
        if (_account == root) revert();
        if (_parent == address(0)) revert();
        if (isRegistered(_parent) == false) revert();

        if (isRegistered(_account) == true) return;

        parent[_account] = _parent;
        children[_parent].push(_account);

        emit Registered(_account, _parent);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../Referral.sol";

contract Referral2 {
    Referral public referral;

    address public root;

    mapping(address => address) private _parent;
    mapping(address => address[]) private _children;

    event Registered(address indexed account, address indexed parent);

    constructor(address _referral) {
        referral = Referral(_referral);
        root = referral.root();
    }

    function parent(address _account) public view returns (address) {
        if (_parent[_account] == address(0)) {
            return referral.parent(_account);
        }

        return _parent[_account];
    }

    function children(address _account, uint256 _index) public view returns (address) {
        uint256 count = referral.childrenCount(_account);
        if (_index < count) {
            return referral.children(_account, _index);
        }

        return _children[_account][_index - count];
    }

    function isRegistered(address _account) public view returns (bool) {
        if (_account == root) {
            return true;
        }

        return referral.isRegistered(_account) || _parent[_account] != address(0);
    }

    function childrenCount(address _account) external view returns (uint256) {
        return referral.childrenCount(_account) + _children[_account].length;
    }

    function register(address parent_) public {
        if (isRegistered(parent_) == false) revert();
        if (isRegistered(msg.sender) == true) revert();

        _parent[msg.sender] = parent_;
        _children[parent_].push(msg.sender);

        emit Registered(msg.sender, parent_);
    }
}