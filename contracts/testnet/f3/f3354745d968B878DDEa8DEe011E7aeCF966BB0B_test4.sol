/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity >=0.8.17;

contract test4 {

    string public name;
    string public symbol;

    mapping(address => address) public first;
    mapping(address => address) public second;

    event SetTest(address f, address s);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function setTest(address f, address s) external {
        first[msg.sender] = f;
        second[msg.sender] = s;

        emit SetTest(f, s);
    }

}