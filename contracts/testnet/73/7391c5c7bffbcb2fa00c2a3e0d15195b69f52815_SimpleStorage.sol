/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

pragma solidity ^0.8.7;
contract SimpleStorage {
    uint storedData;
    function set(uint x) public {
        storedData = x;
    }
    function get() public view returns (uint) {
        return storedData;
    }
}