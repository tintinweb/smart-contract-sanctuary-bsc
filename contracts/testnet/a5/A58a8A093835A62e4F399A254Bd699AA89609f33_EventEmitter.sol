/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract EventEmitter {
    string private greeting;

    event TestEvent(uint256 num, address addr);
    event AnotherOne(bool flag, string str);

    constructor() {}

    function emitTest(uint256 num) public {
        emit TestEvent(num, msg.sender);
    }

    function emitAnother(bool flag, string memory str) public {
        emit AnotherOne(flag, str);
    }
}