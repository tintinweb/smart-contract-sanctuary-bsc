pragma solidity ^0.8.2;

contract Box {
    uint256 private _value;
    event ValueChanged(uint256 value);

    constructor(uint256 value) {
        _value = value;
        emit ValueChanged(value);
    }

    function retrieve() public view returns (uint256) {
        return _value;
    }

    function increment() public {
        _value = _value + 1;
        emit ValueChanged(_value);
    }
}