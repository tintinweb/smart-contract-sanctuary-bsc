// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

contract BoxV1 {
    uint public age;

    function initialize(uint val_) public {
        age = val_;
    }

    function version() public view returns (string memory) {
        return "1.0.0";
    }
}