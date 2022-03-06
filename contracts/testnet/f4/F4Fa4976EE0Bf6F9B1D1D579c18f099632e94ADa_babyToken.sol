/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract babyToken {

    uint256 public number;

    constructor (uint256 _number) {
        number = _number;
    }

}

contract babyTokenFactory {

    address public contractAddresses;

    constructor(){

    }

    function deploy(uint256 number) public returns(address) {
        
        babyToken deployed = new babyToken(number);
        contractAddresses = address(deployed);
        return address(deployed);
    }



}