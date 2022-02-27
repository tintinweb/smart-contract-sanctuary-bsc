/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

pragma solidity ^0.4.17; 
// SPDX-License-Identifier: UNLICENCED


contract Contador{
    uint256 count;

    function Contador(uint256 _count) public {
        count = _count;
    }

    function setCount(uint256 _count) public {
        count = _count;
    }

    function incrementCount() public {
        count += 1;
    }

    function getCount() public view returns(uint256) { //view es para que solo lea, no modifica nada en contrato.
        return count; // ni pure ni view consumen gas
    }

    function getNumber() public pure returns(uint256) { //pure es para que no escriba ni lea ninguna funcion del estado del contrato
        return 34;
    }
}