// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    uint public x=3;
    struct User {
        string name;
        uint age;
    }

    User public users;

    function c(bytes32 _pos) internal pure returns(User storage us) {
        bytes32 position = _pos;
        assembly {
            us.slot := position
        }
    }

    function writeToStruct(bytes32  _pos) external {
        User storage u = c(_pos);
        u.name= "fd";
    }

    function returnKe(bytes memory _name) external pure returns(bytes32) {
        return keccak256(_name);
    }

    function returnSload() external view {
 assembly {
    let v := sload(0) // read from slot #0
    mstore(0x80, v) // store v at position 0x80 in memory
    return(0x80, 32) // v is 32 bytes (uint256)
}
    }
}