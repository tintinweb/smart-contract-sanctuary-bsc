/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.4.24;

contract Mycontract {
    string value;

    constructor() public {
        value = "myValue";
    }

    function get() public view returns(string) {
        return value;
    }
    function set(string _value) public {
        value = _value;
    }
}