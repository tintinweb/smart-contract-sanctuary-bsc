/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity ^0.8.7;

contract MyContract {
    string value;

    function getValue() public view returns (string memory) {
        return value;
    }

    function cuntT(string memory _value) public {
        value = _value;
    }

    constructor() public {
        value = "myValue";
    }
}