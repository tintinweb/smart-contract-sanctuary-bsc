/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ERC20Transfer {

    constructor() {
    }

    function batchTransfer(address[] calldata _users, uint256 _value) public {
        uint256 len = _users.length;
        address token = 0xAca950cD6cbC9C99DAf90Aa6A8b234aF24Fafc6A;
        for (uint i = 0; i < len; ++i) {
            (bool success, ) = token.call(abi.encodeWithSelector(0xa9059cbb, _users[i], _value));
            require(success, "Address: unable to send value, recipient may have reverted");
        }
    }
}