/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract ArrayTesting {
    
    struct Test {
        uint8 aSmallNumber;
        uint256 aNumber;
    }

    struct Test2 {
        uint8 aSmallNumber;
        uint256 aNumber;
    }
    uint256 test2count = 0;

    Test public test;

    mapping(uint256 => Test2) public test2;
    mapping(uint256 => uint256) public test3;
    mapping(uint256 => mapping(uint256 => uint256)) public test4;
    
    constructor() {
        test.aSmallNumber = 0;
        test.aNumber = 0;

        Test2 storage _test2 = test2[0];

        _test2.aSmallNumber = 1;
        _test2.aNumber = 100;
        test2count++;

        _test2 = test2[1];
        _test2.aSmallNumber = 2;
        _test2.aNumber = 200;
        test2count++;

        _test2 = test2[2];
        _test2.aSmallNumber = 3;
        _test2.aNumber = 300;
        test2count++;

        test3[1] = 2;
        test3[2] = 4;

        test4[1][0] = 6;
        test4[1][1] = 7;

        test4[2][0] = 8;
        test4[2][1] = 9;
        test4[2][2] = 10;
        test4[2][3] = 11;
        
    }

    function getTest() public view returns(Test memory) {
        return(test);
    }

    function getTest2() public view returns(Test2[] memory) {
        Test2[] memory testing = new Test2[](test2count);

        for (uint256 i = 0; i < test2count; i++) {
            Test2 storage testloop = test2[i];
            testing[i] = testloop;
        }

        return testing;
    }

    function getTest4(uint256 _round) public view returns(uint256[] memory) {

        uint256[] memory _test4 = new uint256[](test3[_round]);

        for (uint256 i = 0; i < test3[_round]; i++) {
            _test4[i] = test4[_round][i];
        }

        return (_test4);
    }

}