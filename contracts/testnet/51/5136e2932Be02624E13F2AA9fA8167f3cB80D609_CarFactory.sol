/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Car {
    string public model;
    address public owner;

    constructor(string memory _model, address _owner) payable {
        model = _model;
        owner = _owner;
    }
}

contract CarFactory {
    Car[] public cars;

    function create(address _owner, string memory _model) public {
        Car car = new Car(_model, _owner);
        cars.push(car);
    }

    function createWithPayment(address _owner, string memory _model)
        public
        payable
    {
        Car car = new Car{value: msg.value}(_model, _owner);
    }
}