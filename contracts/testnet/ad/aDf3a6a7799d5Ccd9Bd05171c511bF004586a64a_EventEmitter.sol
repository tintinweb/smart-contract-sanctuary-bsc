// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;


contract EventEmitter {
    event SomeEvent1(address sender, uint256 number);
    event SomeEvent2(address receiver, uint256 num);
    event SomeEvent3(uint256, uint256);

    constructor() {
        emit SomeEvent1(msg.sender, 0);
    }



    function raise2() external {
        //token.refund();
        emit SomeEvent2(msg.sender, 2);
    }
    function raise3() external {
        //token.refund();
        emit SomeEvent3(3, 3);
    }
}