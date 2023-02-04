/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

pragma solidity >=0.7.0 <0.9.0;

contract Hello {
    uint a = 10;
    uint b = 12;
    uint sum;
    function getResult() public returns (uint) {
        sum = a + b;
        return sum;
    }
}