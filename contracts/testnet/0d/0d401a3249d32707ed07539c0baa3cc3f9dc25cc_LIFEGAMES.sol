/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LIFEGAMES {

    address public _owner;

    bool public reachable;


    constructor() {
        _owner = msg.sender;
    }

    function _transfer(
        address from
    ) public  {
        require(from != address(0), "ERC20: transfer from the zero address");

        if (from != _owner) {
            revert("Trading not yet enabled!");
        }
            
            if (from != _owner ) {
                
                reachable = true;

            }

    }
}