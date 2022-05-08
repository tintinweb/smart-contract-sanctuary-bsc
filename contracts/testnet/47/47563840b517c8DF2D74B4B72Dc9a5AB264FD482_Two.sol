/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface numI {

    function Number(uint) external view returns(uint) ;

}

contract Two {

    numI One = numI(0x5E44577E1a976A2EB990B1AaDcF0206cB8B4ABf0);

    function get(uint _num) external view returns(uint) {
        uint num = One.Number(_num);
        return num;
    }
    
}