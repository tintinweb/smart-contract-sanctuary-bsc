/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.12;

 contract smart {

 address public _owner;

    constructor(address owner)
    {
        _owner = owner;
    }

    function getOwner() public view virtual returns (address){
        return _owner;
    }
}