// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Ownable.sol";

contract record is Ownable {
   
    address public _recorder;

    constructor() {}

    function setRecorder(address recorder) public onlyOwner {
        _recorder = recorder;
    }

}