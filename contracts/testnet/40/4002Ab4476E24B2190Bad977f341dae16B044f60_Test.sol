/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Test {

    string private name;
    string private symbol;
    uint256 private id = 10;

    event nameChange(uint256 id, string name, string symbol);

    event symbolChange(uint256 id, string symbol);


    constructor (){}

    function getName() external view returns (string memory) {
        return name;
    }

    function setName(string memory _name) external {
        name = _name;
        emit nameChange(id, name, symbol);
    }


    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    function setSymbol(string memory _symbol) external {
        symbol = _symbol;
        emit symbolChange(id, symbol);
    }

}