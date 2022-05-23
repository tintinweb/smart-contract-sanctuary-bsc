// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./IInvite.sol";

// 邀请关系
contract Invite is IInvite {
    event RelationShip(address indexed owner, address indexed upper);

    address private constant ZERO = address(0);
    address private constant ONE = address(1);
    mapping(address => address) public info;

    function invite(address upper) external override {
        require(tx.origin != upper, "1048");
        if (ZERO == info[upper]) {
            info[upper] = ONE;
            emit RelationShip(upper, ONE);
        }
        if (ZERO == info[tx.origin]) {
            info[tx.origin] = upper;
            emit RelationShip(tx.origin, upper);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IInvite {

    function invite(address upper) external;

}