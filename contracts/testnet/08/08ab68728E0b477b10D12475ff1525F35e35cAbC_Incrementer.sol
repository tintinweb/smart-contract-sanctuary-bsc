/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// File: contracts/3_Ballot.sol


pragma solidity >=0.7.0 <0.9.0;

contract Incrementer {
    uint256 public inc;

    function inrement() external {
        inc = inc + 1; 
    }
}