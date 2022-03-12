/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    uint256 tumeric;

    
    function store(uint256 herda) public {
        tumeric = herda;
    }

   
    function retrieve() public view returns (uint256){
        return tumeric;
    }
}