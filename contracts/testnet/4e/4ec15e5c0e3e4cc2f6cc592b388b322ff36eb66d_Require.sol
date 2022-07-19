/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Require {

    function probar(uint32 _date) pure external returns(uint32){
        require(_date > 10, "dato debe ser mayor a 10");
        return _date;
    }
    
}