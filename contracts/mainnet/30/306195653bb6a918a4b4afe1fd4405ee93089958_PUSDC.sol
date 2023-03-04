/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.17;

contract PUSDC {
    uint256 public dummyVar;

    constructor() {}

    function method_payable0() public payable {
        dummyVar = 1;
    }

    function method_payable1(uint256 p1) public payable {
        dummyVar = 1000 * p1;
    }

    function method_payable2(uint256 p1, uint256 p2) public {
        dummyVar = 100 * (p1 + p2);
    }

    function method_payable3(
        uint256 p1,
        uint256 p2,
        uint256 p3
    ) public {
        dummyVar = 1000 * (p1 + p2 + p3);
    }

    function trigger_method0() public {
        dummyVar = 2;
    }

    function trigger_method1(uint256 p1) public {
        dummyVar = 100 * p1;
    }

    function trigger_method2(uint256 p1, uint256 p2) public {
        dummyVar = 100 * (p1 + p2);
    }

    function trigger_method3(
        uint256 p1,
        uint256 p2,
        uint256 p3
    ) public {
        dummyVar = 100 * (p1 + p2 + p3);
    }

    function method0() public {
        dummyVar = 3;
    }

    function method1(uint256 p1) public {
        dummyVar = 10 * p1;
    }

    function method2(uint256 p1, uint256 p2) public {
        dummyVar = 10 * (p1 + p2);
    }

    function method3(
        uint256 p1,
        uint256 p2,
        uint256 p3
    ) public {
        dummyVar = 10 * (p1 + p2 + p3);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}