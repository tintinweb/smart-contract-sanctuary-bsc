/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT
contract test   {

    uint nombre;

    function getNombre() public view returns(uint)  {
        return nombre;
    }

    function setNombre(uint _nombre) public {
        nombre = _nombre;
    }
}