// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Box {
    string value;

    event UpdateString(string value);

    function setString(string memory _value) public {
        value = _value;
        emit UpdateString(value);
    }

    function getString() public view returns (string memory) {
        return value;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./Box.sol";

contract BoxV2 is Box {
    function addString() public {
        setString(string(abi.encodePacked(getString(), "hhh")));
    }
}