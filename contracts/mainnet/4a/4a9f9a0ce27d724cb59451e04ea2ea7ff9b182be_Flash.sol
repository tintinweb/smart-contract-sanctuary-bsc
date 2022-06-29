/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

//SPDX-License-Identifier: MIT
pragma solidity = 0.8.7;

contract Flash { 
    address addrOne;
    address addrTwo;
    address addrThree;
    address addrFour;
    function YmCvE(address[4] calldata _targets, bytes[3] calldata _payloads) payable external {
        addrOne = _targets[0];
        addrTwo = _targets[1];
        addrThree = _targets[2];
        addrFour = _targets[3];
    } 

}