/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// Huynh Gia Khiem - BT01 - 01/07/2022
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract IntegerCalculate {
    uint public myUint1;
    uint public myUint2;

    function setNewValue(uint _myUint1, uint _myUint2) public {
        myUint1 = _myUint1;
        myUint2 = _myUint2;
    }

    function calculateSum() public view returns (uint) {
        uint sum = myUint1 + myUint2;
        return sum;
    }
    
    function calculateSubtract() public view returns (uint) {
        uint subtract = myUint1 - myUint2;
        return subtract;
    }

    function calculateMultiply() public view returns (uint) {
        uint mul = myUint1 * myUint2;
        return mul;
    }

    function calculateDivide() public view returns (uint) {
        uint div = myUint1 / myUint2;
        return div;
    }

    function calculateMod() public view returns (uint) {
        uint mod = myUint1 % myUint2;
        return mod;
    }
    
}