/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity = 0.7.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    uint256 number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public payable {
            require(msg.value > 0, "Send ETH to buy some tokens");

        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}