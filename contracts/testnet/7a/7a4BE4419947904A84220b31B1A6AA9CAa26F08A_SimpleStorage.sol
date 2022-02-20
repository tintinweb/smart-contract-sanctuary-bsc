/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {


uint storedData;

function set(uint x) public {

require(x>=10);

storedData = x;

}

function get() public view returns (uint) {
return storedData;
}
}