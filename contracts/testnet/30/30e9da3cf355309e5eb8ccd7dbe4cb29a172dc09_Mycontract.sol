/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.5.1;

contract Mycontract {
    string public value;

    constructor() public {
        value = "myValue";
    }

    function set(string memory _value) public {
        value = _value;
    }
}