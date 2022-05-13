/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

//SPDX-License-Identifier:MIT
pragma solidity >=0.7.0 <=0.9.0;



contract TestContract {
    uint public x;
    // uint public value = 123;

    function setX(uint _x) public {
        x = _x;
    }
    function getX() public view returns (uint) {
        return x;
    }
}