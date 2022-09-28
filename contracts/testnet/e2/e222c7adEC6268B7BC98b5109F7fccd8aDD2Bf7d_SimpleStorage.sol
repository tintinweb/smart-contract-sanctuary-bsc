/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File: simple2_flat.sol


// File: simple2.sol

pragma solidity >=0.4.22 <0.7.0;

contract SimpleStorage {
    uint public storedData;

    constructor() public {
        storedData = 100;
    }

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint retVal) {
        return storedData;
    }
}