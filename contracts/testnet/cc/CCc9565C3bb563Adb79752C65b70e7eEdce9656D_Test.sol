/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

pragma solidity ^0.8.0;

contract Test {
    mapping(address=>uint) addressToUserBalance;
    uint count;
    constructor(){

    }
    event manualRebase(uint _count);
    function externalFunction() external {
        internalFunction();
        emit manualRebase(count);
    }
    function internalFunction() private {
        addressToUserBalance[msg.sender] = count;
        count++;
    }
   
}