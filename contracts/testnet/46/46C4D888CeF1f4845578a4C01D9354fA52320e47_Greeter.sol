//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract Greeter {


    uint256 public abc;

    constructor(uint256 _abc)  {
        abc = _abc;
    }

    function getNumber() public view returns (uint) {

        uint i = 0;
        return i++;
    }

}