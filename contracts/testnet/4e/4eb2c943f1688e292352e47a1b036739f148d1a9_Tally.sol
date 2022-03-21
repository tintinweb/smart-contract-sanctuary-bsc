/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Tally {

    uint public count;
    
    event Count(string method, uint count, address caller);

    function increase() public {

        count++;

        emit Count('Increase', count, msg.sender);

    }

    function decrease() public {

        count--;
        emit Count('Decrease', count, msg.sender); 

    }

    function getCount() public view returns (uint) {
        return count; 
    }

}