// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EventsExercise {

    /**
     * @dev onChange Event
     */
    event onChange(
        uint256 value
    );

    /**
     * @dev _value variable
     */
    uint256 public _value;

    /**
     * @dev constructor
     */
    constructor() {
        setValue(0);
    }

    /**
     * @dev setValue function
     * @param _newValue New value
     * 
     * Emit event {onChange}
     */
    function setValue(uint256 _newValue) public {
        _value = _newValue;
        emit onChange(_newValue);
    }

}