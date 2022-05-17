// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

contract Referral {
    mapping(address => address) listRef;

    event CreateRef(address user, address refBy);

    function createRef(address _refBy) public {
        require(listRef[msg.sender] == address(0), "Registered");
        require(msg.sender != _refBy, "Cannot ref this address");
        listRef[msg.sender] = _refBy;

        emit CreateRef(msg.sender, _refBy);
    }

    function getRef(address _user) external view returns (address) {
        return listRef[_user];
    }
}