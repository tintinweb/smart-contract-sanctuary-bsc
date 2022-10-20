/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Demo2{

    mapping (uint => mapping(uint => mapping(address => uint[]))) public _pledgeBingoNFTMapping;

    event DemoEvent(uint[] arrDemo);

    function demo1() public {
        _pledgeBingoNFTMapping[0][0][0xe7e55B87C7bE33d573f855E7B35A246DA53D05eD].push(123);
        _pledgeBingoNFTMapping[0][0][0xe7e55B87C7bE33d573f855E7B35A246DA53D05eD].push(234);
    }

    function demo2() public {
        uint[] storage demoArr = _pledgeBingoNFTMapping[0][0][0xe7e55B87C7bE33d573f855E7B35A246DA53D05eD];
        demoArr.push(456);
        demoArr.push(567);
    }

    function demo3(uint[] memory demoArr) public {
        emit DemoEvent(demoArr);
    }
}