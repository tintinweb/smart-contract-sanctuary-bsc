// contracts/BoxV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract BoxV2 {
    uint256 private _value;
    event ValueChanged(uint256 value);

    // Increments the stored value by 1
    function increment2() public {
        _value = _value + 1;
        emit ValueChanged(_value);
    }
}