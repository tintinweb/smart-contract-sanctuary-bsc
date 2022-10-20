/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Car {
    address public owner;
    string public model;
    address public carAddr;

    constructor() payable {
        carAddr = address(this);
    }

    function init(address _owner, string memory _model) external {

        owner = _owner;
        model = _model;

    }
}