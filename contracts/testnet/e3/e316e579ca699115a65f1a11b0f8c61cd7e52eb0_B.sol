//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./a.sol";
contract B is A{
    uint public b ;
    constructor() {
        // b = super.a();
    }
    function set() public {
        b = a+1;
    }
}