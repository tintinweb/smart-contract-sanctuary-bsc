/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity ^0.8.7;

interface ChiToken {
    function mint(uint256 value) external;
}

contract test {
    ChiToken public chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    constructor() public{ }
    function PP(uint256 C) public {
       chi.mint(C);
    }   
}