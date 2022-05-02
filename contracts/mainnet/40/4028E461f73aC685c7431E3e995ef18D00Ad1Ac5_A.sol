// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface B {
    function f() external;
}

contract A {
    address b;
    event ACalled();

    constructor(address _b) {
        b = _b;
    }

    function g() external {
        emit ACalled();
        B(b).f();
    }
}

contract BImpl {
    event BCalled();

    function f() external {
        emit BCalled();
    }
}