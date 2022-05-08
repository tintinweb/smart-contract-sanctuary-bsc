/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Iteya {
    string private _nombre;
    string private _apellido;

    constructor(string memory nombre_, string memory apellido_) {
        _nombre = nombre_;
        _apellido = apellido_;
    }

    function getNombre() public view virtual returns (string memory) {
        return _nombre;
    }
}