/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.4.0;
contract SimpleStorage {
uint storedData;
function set(uint x) {
storedData = x;
}
function get() constant returns (uint retVal) {
return storedData;
}
}