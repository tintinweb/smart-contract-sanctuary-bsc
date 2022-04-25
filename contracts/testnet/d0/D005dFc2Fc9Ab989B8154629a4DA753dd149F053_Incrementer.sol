/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.9;

contract Incrementer {
    string private _name;
    string private _symbol;
    address private _router;
    uint256 private _number;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress
        //uint256 _initialNumber
        
    ) {
        _name = Name;
        _symbol = Symbol;
        _router = routerAddress;
       //_number = _initialNumber;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function router() public view returns (address) {
        return _router;
    }
}