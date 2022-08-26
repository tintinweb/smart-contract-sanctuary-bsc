/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity ^0.8.7;

interface T {
    function PP(uint256 C) external;
}

contract test {
    T T1 = T(0xA2b4820626378455F1C2DD42c3998eD53228B2e5);
    constructor() public { }
    function PP(uint256 C) public {
       T1.PP(C);
    }   
}