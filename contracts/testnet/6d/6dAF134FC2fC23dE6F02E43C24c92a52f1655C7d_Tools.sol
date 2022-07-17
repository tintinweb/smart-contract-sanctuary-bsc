/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Tools
 */
contract Tools {
    
    function getDateTime() public view returns (uint256){
        return block.timestamp;
    }
}