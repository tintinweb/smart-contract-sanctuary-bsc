/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

pragma solidity >=0.4.25 <0.9.0;

contract TestXyi4 {
    uint256 public number;

    constructor() {
        number = 0;
    }

    function increment(uint256 _value) public {
        number = number + _value;
    }

    function reset() public {
        number = 0;
    }
}