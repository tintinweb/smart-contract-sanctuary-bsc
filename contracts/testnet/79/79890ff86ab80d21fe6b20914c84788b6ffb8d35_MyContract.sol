/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity ^0.8.7;

contract MyContract {
    string value;
    uint incrementedNum;
    address payable creator = payable(address(0xb6F95454ED854B9ddf89ffE6F1465dD9517A0729));

    function getValue() public view returns (string memory) {
        return value;
    }

    function viewNum() public view returns (uint) {
        return incrementedNum;
    }

    function set(string memory _value) public {
        value = _value;
    }

    function incrementNumber() public {
        incrementedNum = incrementedNum + 1;
    }

    function killContract() public {
        selfdestruct(creator);
    }

    constructor() public {
        value = "myValue";
        incrementedNum = 0;
    }
}