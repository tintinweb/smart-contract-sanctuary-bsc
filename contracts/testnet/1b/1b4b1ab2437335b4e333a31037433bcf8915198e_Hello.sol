/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

pragma solidity >=0.7.0 <0.9.0;

contract Hello {
    uint _a = 0;
    uint _b = 0;
    uint sum;
    function getResult() view public returns (uint) {
        return _a + _b;
    }

    function setA (uint num) payable public {
        _a = num;
    }

    function setB(uint num) public {
        _b = num;
    }


}