/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract babyToken {

    uint256 public number;

    constructor (uint256 _number, uint256 _number1) {
        number = _number;
        number = _number1;
    }

}

contract babyTokenFactory {

    address public contractAddresses;

    constructor(){

    }

    function deploy(uint256 number, uint256 number1) public returns(address) {
        
        babyToken deployed = new babyToken(number, number1);
        contractAddresses = address(deployed);
        return address(deployed);
    }



}