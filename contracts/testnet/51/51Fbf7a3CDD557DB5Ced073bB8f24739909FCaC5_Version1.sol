/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// File: contracts/Version1.sol


pragma solidity ^0.8.0;

contract Version1 {
    uint256 public bal;
    address public owner;

    constructor()   {
        bal =100;
        owner=msg.sender;
    }

    function increment() external {
        bal +=10;
        owner = msg.sender;
    }
}