//SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.12;

import "./DaughterContract.sol";
import "./smart.sol";

contract MomContract {
 string public name;
 uint public age;

 DaughterContract public daughter;
 smart public ss;

    constructor(){ }

    function createCA(string memory dName, uint256 dAge)public{
        daughter = new DaughterContract(dName, dAge);
    }

     function createSmart()public{
        ss = new smart(msg.sender);
    }
}