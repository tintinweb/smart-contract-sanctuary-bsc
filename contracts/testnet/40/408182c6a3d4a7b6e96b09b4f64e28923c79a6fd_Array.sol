/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Array {
    uint[] public arr; // dynamic array

    function set(uint p,uint s) public {
        arr[p] = s;  // setting value at defined position
    }

    function pushElement (uint i) public {
        arr.push(i); // appending value to the dynamic array
    }

    function get(uint i) public view returns(uint){
        return arr[i]; // retreiving value from the array
    }

    function popElement() public {
        arr.pop(); // delete last element of the array
    }

    function getLength() public view returns(uint){
        return arr.length; // get length of array
    }

    function remove(uint index) public {
        delete arr[index];  // remove element from specified index
    }
}