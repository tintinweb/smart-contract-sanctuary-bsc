/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Car{
    string public name;
    address public owner;

    constructor (string memory _model,address _owner) {
        name=_model;
        owner=_owner;
    }
}

contract factory{

    
    Car[] public cars;
    function create(string memory _model) public{
    Car car= new Car(_model, address(this));
    cars.push(car);
    }
}